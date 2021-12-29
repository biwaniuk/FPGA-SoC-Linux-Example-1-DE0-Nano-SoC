################################################################################
#
# TEST
#
################################################################################

TEST_VERSION = 1.0
TEST_SITE    = $(BR2_EXTERNAL_E2B_MINI_PATH)/src/test
TEST_SITE_METHOD = local
TEST_LICENSE = LGPLv2.1/GPLv2 
TEST_DEPENDENCIES += linux

define TEST_BUILD_CMDS
   $(MAKE) $(TARGET_CONFIGURE_OPTS) test -C $(@D)
endef
define TEST_INSTALL_TARGET_CMDS 
   $(INSTALL) -D -m 0755 $(@D)/test $(TARGET_DIR)/usr/bin 
endef

$(eval $(generic-package))
