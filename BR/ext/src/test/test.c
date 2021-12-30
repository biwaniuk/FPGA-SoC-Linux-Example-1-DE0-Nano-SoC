#include<stdio.h>
#include<sys/types.h>
#include<stdint.h>
#include<sys/stat.h>
#include<sys/mman.h>
#include<fcntl.h>
#include<unistd.h>
#include<stdlib.h>
#include<string.h>
#include<time.h>
#include<sys/ioctl.h>
#include<inttypes.h>

#include "fpga_ioc_cmds.h"

int plik;
volatile uint32_t * buf;


uint32_t get_rand32()
{
    uint32_t x = rand() & 0xff;
    x |= (rand() & 0xff) << 8;
    x |= (rand() & 0xff) << 16;
    x |= (rand() & 0xff) << 24;
    return x;
}

int main(int argc, char **argv)
{
  printf("I'm trying to open our device!\n");
  fflush(stdout);
  plik=-1;
  plik=open("/dev/fpga0", O_RDWR);
  if(plik==-1)
    {
      perror("/dev/fpga0");
      printf("I can't open device!\n");
      fflush(stdout);
      exit(1);
    }
  printf("Device opened!\n");
  fflush(stdout);
  long id = ioctl(plik, FPGA_IOC_READ_ID, NULL);
  printf("ID: %lx\n",id);
  fflush(stdout);

  //Map data buffer
  buf = (uint32_t *) mmap(0,0x1000,PROT_READ | PROT_WRITE,MAP_SHARED,
	 plik,0x0);
  if(buf == (void *) -1l)
  {
      perror("Can't map data buffer!\n");
  }
  
  //Prepare test data
  uint32_t xor_key = get_rand32();
  uint32_t random_data[256];
  for(int i=0; i<256; ++i) {
    random_data[i] = get_rand32();
  }
  memcpy((void *)(buf), random_data, 1024);
  //for(int i=0; i<8; ++i){
  //  printf("Byte %d: %lx\n", i+1, *((uint8_t *)buf+i));
  //}
  
  printf("Resetting FPGA\n");
  fflush(stdout);
  //TODO: ioctl ret values should be tested for error handling!!!
  //Reset
  ioctl(plik, FPGA_IOC_WRITE_CTRL, 2);
  //Idle
  usleep(1);

  ioctl(plik, FPGA_IOC_WRITE_ADDR, NULL);
  ioctl(plik, FPGA_IOC_WRITE_LEN, 256);
  ioctl(plik, FPGA_IOC_WRITE_XOR_KEY, xor_key);
  //Start
  ioctl(plik, FPGA_IOC_WRITE_CTRL, 1);
  printf("Start\n");
  fflush(stdout);
  
  //Prepare reference values
  for(int i=0; i<256; ++i) {
    random_data[i] ^= xor_key;
  }
  
  int cnt = -1;
  while(ioctl(plik, FPGA_IOC_WAIT_DONE, NULL)) {
      printf("Retrying\n");
      usleep(1000);
    }
  ioctl(plik, FPGA_IOC_WRITE_CTRL, 0);
  printf("FPGA stopped\n");
  
  uint8_t test_flg = 1;  
  for(int i=0; i<256; ++i) {
    if(random_data[i] != *((uint32_t *)buf+i)) {
      printf("TEST FAILED @ word #%d. Received %lx expected %lx\n",i,random_data[i],*((uint32_t *)buf+i));
      test_flg = 0;
      break;
    }
  }
  if (test_flg) {
    printf("TEST PASSED!\n");
  }
  fflush(stdout);

  exit(EXIT_SUCCESS);
}
