################################################################################
#
# FPGA-module
#
################################################################################

FPGA_MODULE_VERSION = 1.0
FPGA_MODULE_SITE    = $(BR2_EXTERNAL_E2B_MINI_PATH)/src/fpga
FPGA_MODULE_SITE_METHOD = local
FPGA_MODULE_LICENSE = LGPLv2.1/GPLv2 

$(eval $(kernel-module))
$(eval $(generic-package))
