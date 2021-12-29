// Based on:
/* Quick and dirty WZENC1 device driver
 * This driver only allows to check, that the simulated
 * WZENC1 core works correctly.
 * Most functionality is simply passed to the user space
 * allowing you to use WZENC1 to completely crash your emulated
 * machine :-(.
 * This driver also does not allow to control multiple
 * instances of WZENC1
 * 
 * Copyright (C) 2011 by Wojciech M. Zabolotny
 * wzab<at>ise.pw.edu.pl
 * Significantly based on multiple drivers included in
 * sources of Linux
 * Therefore this saource is licensed under GPL v2
 */
 
 /* Edited for DE-0 Nano SoC by Bartosz M. Zabolotny, 2018-2021
 * b.zabolotny<at>tele.pw.edu.pl
 */
 
 

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/uaccess.h>
MODULE_LICENSE("GPL v2");
#include <linux/device.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/sched.h>
#include <linux/mm.h>
#include <linux/io.h>
#include <linux/interrupt.h>
#include <asm/uaccess.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/dma-mapping.h>

#include "fpga_ioc_cmds.h"

#define SUCCESS 0
#define DEVICE_NAME "fpga"
#define DEVICE_ID 0xb2002019

int irq=-1;
unsigned long phys_addr = 0;
bool is_open = false;
const size_t ALLOC_SIZE = 8192;

volatile uint32_t * fmem=NULL; /* Pointer to registers area */
volatile uint32_t * fdata=NULL; /* Pointer to data buffer */

dma_addr_t dma_addr;
struct platform_device * my_pdev = NULL;

int fpga_remove(struct platform_device * pdev);
static int fpga_init(void);
static void fpga_exit(void);
static int fpga_open(struct inode *inode, struct file *file);
static int fpga_release(struct inode *inode, struct file *file);
ssize_t fpga_read(struct file *filp,
		  char __user *buf,size_t count, loff_t *off);
long fpga_ioctl(struct file *filp, unsigned int cmd, unsigned long arg);
loff_t fpga_llseek(struct file *filp, loff_t off, int origin);

int fpga_mmap(struct file *filp, struct vm_area_struct *vma);

dev_t my_dev=0;
struct cdev * my_cdev = NULL;
static struct class *class_my_tst = NULL;

/* Queue for reading process */
DECLARE_WAIT_QUEUE_HEAD (readqueue);

struct file_operations Fops = {
  .owner = THIS_MODULE,
  .read=fpga_read,
  .open=fpga_open,
  .release=fpga_release,
  .llseek=no_llseek,
  .mmap=fpga_mmap,
  .unlocked_ioctl=fpga_ioctl
};

typedef struct device_registers {
  /* Map of registers from Slave process in comm.vhd */
  uint32_t id;
  uint32_t ctrl;
  uint32_t status;
  uint32_t addr;
  uint32_t len;
  uint32_t xor_key;
} dev_regs;

static volatile dev_regs * dregs = NULL;

/* Cleanup resources */
int fpga_remove( struct platform_device * pdev )
{
  if(dregs) {
    dregs = NULL;
  }
  if(fdata) {
    dmam_free_coherent(&pdev->dev, ALLOC_SIZE, fdata, dma_addr);
    fdata = NULL;
  }
  if(my_dev && class_my_tst) {
    device_destroy(class_my_tst,my_dev);
  }
  if(fmem) {
      devm_iounmap(&pdev->dev,fmem);
      fmem = NULL;
  }
  if(my_cdev) cdev_del(my_cdev);
  my_cdev=NULL;
  unregister_chrdev_region(my_dev, 1);
  if(class_my_tst) {
    class_destroy(class_my_tst);
    class_my_tst=NULL;
  }
  my_pdev = NULL;
  return SUCCESS;
}

static int fpga_open(struct inode *inode, 
		     struct file *file)
{
  if(is_open) return -EBUSY;
  nonseekable_open(inode, file);
  is_open = true;
  return SUCCESS;
}

static int fpga_release(struct inode *inode, 
			struct file *file)
{
  is_open = false;
  return SUCCESS;
}

ssize_t fpga_read(struct file *filp,
		  char __user *buf,size_t count, loff_t *off)
{
  uint32_t val;
  if (count != 4) return -EINVAL; /* Only 4-byte accesses allowed */
  val = *fmem; 
  if(__copy_to_user(buf,&val,4)) return -EFAULT;
  return 4;
}	

void fpga_vma_open (struct vm_area_struct * area)
{  }

void fpga_vma_close (struct vm_area_struct * area)
{  }

static struct vm_operations_struct fpga_vm_ops = {
  .open=fpga_vma_open,
  .close=fpga_vma_close,
};

int fpga_mmap(struct file *filp,
	      struct vm_area_struct *vma)
{
  int remap=0;
  unsigned long physical = virt_to_phys(fdata);
  unsigned long vsize = vma->vm_end - vma->vm_start;
  unsigned long psize = ALLOC_SIZE;
  dev_info(&my_pdev->dev, "mmap, physaddr: %lx\n",physical);
  if(vsize>psize)
    return -EINVAL;
  vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot); 
  remap=dma_mmap_coherent(&my_pdev->dev,vma,fdata, dma_addr, vsize);
  dev_info(&my_pdev->dev, "remap = %d\n", remap);
  if (vma->vm_ops)
    return -EINVAL;
  vma->vm_ops = &fpga_vm_ops;
  fpga_vma_open(vma); 
  return 0;
}

static int fpga_probe(struct platform_device * pdev)
{
  int res = 0;
  struct resource * resptr = NULL;
  resptr = platform_get_resource(pdev,IORESOURCE_MEM,0);
  if(resptr==0) {
    dev_err(&pdev->dev, "Error reading the register addresses.\n");
    res=-EINVAL;
    goto err1;
  }
  /* TODO: Rework basing on:
   * https://bootlin.com/doc/training/linux-kernel/linux-kernel-slides.pdf 289 */
  /* resptr = request_mem_region(resptr->start, resource_size(resptr), pdev->name);
  dev_info(&pdev->dev, "TEST+\n");
  if(resptr==0) {
    dev_err(&pdev->dev, "failed to request memory resource\n");
    res = -EBUSY;
    goto err1;
  } */

  phys_addr = resptr->start; 
  dev_info(&pdev->dev, "Connected registers at %lx\n",phys_addr);
  class_my_tst = class_create(THIS_MODULE, "my_tst");
  if (IS_ERR(class_my_tst)) {
    dev_err(&pdev->dev, "Error creating my_tst class.\n");
    res=PTR_ERR(class_my_tst);
    goto err1;
  }
  /* Alocate device number */
  res=alloc_chrdev_region(&my_dev, 0, 1, DEVICE_NAME);
  if(res) {
    dev_err(&pdev->dev, "Alocation of the device number for %s failed\n",
            DEVICE_NAME);
    goto err1; 
  };
  my_cdev = cdev_alloc( );
  if(my_cdev == NULL) {
    dev_err(&pdev->dev, "Alocation of cdev for %s failed\n",
            DEVICE_NAME);
    goto err1;
  }
  my_cdev->ops = &Fops;
  my_cdev->owner = THIS_MODULE;
  /* Add character device */
  res=cdev_add(my_cdev, my_dev, 1);
  if(res) {
    dev_err(&pdev->dev, "Registration of the device number for %s failed\n",
            DEVICE_NAME);
    goto err1;
  };//
  /* Create pointer needed to access registers */
  /* One page should be enough */
  fmem = devm_ioremap_resource(&pdev->dev,resptr);
  if(IS_ERR(fmem)) {
    dev_err(&pdev->dev, "Mapping of memory for %s registers failed\n",
            DEVICE_NAME);
    res= PTR_ERR(fmem);
    goto err1;
  }
  device_create(class_my_tst,NULL,my_dev,NULL,"FPGA%d",MINOR(my_dev));
  dev_info(&pdev->dev, "Registration is a succes. \
           The major device number is %d.\n", MAJOR(my_dev));
  fdata = dmam_alloc_coherent(&pdev->dev, ALLOC_SIZE, &dma_addr, GFP_KERNEL);
  if(!fdata) {
    dev_err(&pdev->dev, "Allocating DMA buffer for %s registers failed\n", 
            DEVICE_NAME);
	    goto err1;
  }
  dev_dbg(&pdev->dev, "fmem = %4.4lx\n", fmem);
  dev_dbg(&pdev->dev, "fdata = %4.4lx\n", fdata);
  dev_dbg(&pdev->dev, "dma_addr = %4.4lx\n", dma_addr);

  dregs = (dev_regs *) fmem;
  if(dregs->id != DEVICE_ID) {
    dev_err(&pdev->dev, "Incorrect ID of %s\n \
            ID: %4.4lx\n"
            "Expected: %4.4lx\n", DEVICE_NAME, dregs->id, DEVICE_ID);

	goto err1;
  }
  dev_info(&pdev->dev, "ID = %4.4lx\n", dregs->id);  
  my_pdev = pdev;
  return 0;
 err1:
  fpga_remove(pdev);
  return res;
}

long fpga_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
  switch(cmd) {
    case FPGA_IOC_READ_ID: {
      mb();
      return dregs->id;
    }
    case FPGA_IOC_READ_CTRL: {
      mb();
      return dregs->ctrl;
    }
    case FPGA_IOC_READ_STATUS: {
      mb();
      return dregs->status;
    }
    case FPGA_IOC_READ_XOR_KEY: {
      mb();
      return dregs->xor_key;
    }
    case FPGA_IOC_WRITE_CTRL: {
      dregs->ctrl = arg;
      mb();
      return SUCCESS;
    }
    case FPGA_IOC_WRITE_ADDR: {
      dregs->addr = dma_addr;
      mb();
      return SUCCESS;
    }
    case FPGA_IOC_WRITE_LEN: {
      dregs->len = arg;
      mb();
      return SUCCESS;
    }
    case FPGA_IOC_WRITE_XOR_KEY: {
      dregs->xor_key = arg;
      mb();
      return SUCCESS;
    }
    default:
      return -EINVAL;
  }
}

static struct of_device_id FPGA_driver_ids[] = {
  {
    .compatible = "wzab,testblk",
  },
  {},
};

struct platform_driver my_driver = {
  .driver = { 
    .name = "FPGA",
    .of_match_table = FPGA_driver_ids,
  },
  .probe = fpga_probe,
  .remove = fpga_remove,
};

static int fpga_init(void)
{
  int ret = platform_driver_register(&my_driver);
  if (ret < 0) {
    pr_err("Failed to register fpga driver: %d\n", ret);
    return ret;
  }
  pr_info("Fpga registered\n");
  return 0;
}
static void fpga_exit(void)
{
  platform_driver_unregister(&my_driver);
  pr_info("Fpga unregistered\n");
}

module_init(fpga_init);
module_exit(fpga_exit);

