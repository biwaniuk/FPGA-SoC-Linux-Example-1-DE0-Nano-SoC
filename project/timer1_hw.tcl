# TCL File Generated by Component Editor 21.1
# Wed Apr 13 22:21:45 CEST 2022
# DO NOT MODIFY


# 
# timer1 "timer" v1.0
# WZab 2022.04.13.22:21:45
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module timer1
# 
set_module_property DESCRIPTION ""
set_module_property NAME timer1
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP wzperiphs
set_module_property AUTHOR WZab
set_module_property DISPLAY_NAME timer
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL timer1
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file timer1.vhd VHDL PATH ../tim_src/timer1.vhd TOP_LEVEL_FILE


# 
# parameters
# 
add_parameter C_S_AXI_ACLK_FREQ_HZ INTEGER 100000000
set_parameter_property C_S_AXI_ACLK_FREQ_HZ DEFAULT_VALUE 100000000
set_parameter_property C_S_AXI_ACLK_FREQ_HZ DISPLAY_NAME C_S_AXI_ACLK_FREQ_HZ
set_parameter_property C_S_AXI_ACLK_FREQ_HZ TYPE INTEGER
set_parameter_property C_S_AXI_ACLK_FREQ_HZ UNITS None
set_parameter_property C_S_AXI_ACLK_FREQ_HZ ALLOWED_RANGES -2147483648:2147483647
set_parameter_property C_S_AXI_ACLK_FREQ_HZ HDL_PARAMETER true
add_parameter C_S_AXI_DATA_WIDTH INTEGER 32
set_parameter_property C_S_AXI_DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property C_S_AXI_DATA_WIDTH DISPLAY_NAME C_S_AXI_DATA_WIDTH
set_parameter_property C_S_AXI_DATA_WIDTH TYPE INTEGER
set_parameter_property C_S_AXI_DATA_WIDTH UNITS None
set_parameter_property C_S_AXI_DATA_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property C_S_AXI_DATA_WIDTH HDL_PARAMETER true
add_parameter C_S_AXI_ADDR_WIDTH INTEGER 5 ""
set_parameter_property C_S_AXI_ADDR_WIDTH DEFAULT_VALUE 5
set_parameter_property C_S_AXI_ADDR_WIDTH DISPLAY_NAME C_S_AXI_ADDR_WIDTH
set_parameter_property C_S_AXI_ADDR_WIDTH TYPE INTEGER
set_parameter_property C_S_AXI_ADDR_WIDTH UNITS None
set_parameter_property C_S_AXI_ADDR_WIDTH ALLOWED_RANGES -2147483648:2147483647
set_parameter_property C_S_AXI_ADDR_WIDTH DESCRIPTION ""
set_parameter_property C_S_AXI_ADDR_WIDTH HDL_PARAMETER true


# 
# module assignments
# 
set_module_assignment embeddedsw.dts.compatible wzab,timer1
set_module_assignment embeddedsw.dts.group wzperiphs
set_module_assignment embeddedsw.dts.vendor WZab


# 
# display items
# 


# 
# connection point irq
# 
add_interface irq interrupt end
set_interface_property irq associatedAddressablePoint ""
set_interface_property irq bridgedReceiverOffset ""
set_interface_property irq bridgesToReceiver ""
set_interface_property irq ENABLED true
set_interface_property irq EXPORT_OF ""
set_interface_property irq PORT_NAME_MAP ""
set_interface_property irq CMSIS_SVD_VARIABLES ""
set_interface_property irq SVD_ADDRESS_GROUP ""

add_interface_port irq irq irq Output 1


# 
# connection point axi_slave
# 
add_interface axi_slave axi4lite end
set_interface_property axi_slave associatedClock clock_sink
set_interface_property axi_slave associatedReset reset_sink
set_interface_property axi_slave readAcceptanceCapability 1
set_interface_property axi_slave writeAcceptanceCapability 1
set_interface_property axi_slave combinedAcceptanceCapability 1
set_interface_property axi_slave readDataReorderingDepth 1
set_interface_property axi_slave bridgesToMaster ""
set_interface_property axi_slave ENABLED true
set_interface_property axi_slave EXPORT_OF ""
set_interface_property axi_slave PORT_NAME_MAP ""
set_interface_property axi_slave CMSIS_SVD_VARIABLES ""
set_interface_property axi_slave SVD_ADDRESS_GROUP ""

add_interface_port axi_slave S_AXI_AWADDR awaddr Input "((c_s_axi_addr_width-1)) - (0) + 1"
add_interface_port axi_slave S_AXI_AWVALID awvalid Input 1
add_interface_port axi_slave S_AXI_AWREADY awready Output 1
add_interface_port axi_slave S_AXI_ARADDR araddr Input "((c_s_axi_addr_width-1)) - (0) + 1"
add_interface_port axi_slave S_AXI_ARVALID arvalid Input 1
add_interface_port axi_slave S_AXI_ARREADY arready Output 1
add_interface_port axi_slave S_AXI_WDATA wdata Input "((c_s_axi_data_width-1)) - (0) + 1"
add_interface_port axi_slave S_AXI_WSTRB wstrb Input "(((c_s_axi_data_width/8)-1)) - (0) + 1"
add_interface_port axi_slave S_AXI_WVALID wvalid Input 1
add_interface_port axi_slave S_AXI_WREADY wready Output 1
add_interface_port axi_slave S_AXI_RDATA rdata Output "((c_s_axi_data_width-1)) - (0) + 1"
add_interface_port axi_slave S_AXI_RRESP rresp Output 2
add_interface_port axi_slave S_AXI_RVALID rvalid Output 1
add_interface_port axi_slave S_AXI_RREADY rready Input 1
add_interface_port axi_slave S_AXI_BRESP bresp Output 2
add_interface_port axi_slave S_AXI_BVALID bvalid Output 1
add_interface_port axi_slave S_AXI_BREADY bready Input 1
add_interface_port axi_slave S_AXI_ARPROT arprot Input 3
add_interface_port axi_slave S_AXI_AWPROT awprot Input 3


# 
# connection point clock_sink
# 
add_interface clock_sink clock end
set_interface_property clock_sink clockRate 0
set_interface_property clock_sink ENABLED true
set_interface_property clock_sink EXPORT_OF ""
set_interface_property clock_sink PORT_NAME_MAP ""
set_interface_property clock_sink CMSIS_SVD_VARIABLES ""
set_interface_property clock_sink SVD_ADDRESS_GROUP ""

add_interface_port clock_sink S_AXI_ACLK clk Input 1


# 
# connection point reset_sink
# 
add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock_sink
set_interface_property reset_sink synchronousEdges DEASSERT
set_interface_property reset_sink ENABLED true
set_interface_property reset_sink EXPORT_OF ""
set_interface_property reset_sink PORT_NAME_MAP ""
set_interface_property reset_sink CMSIS_SVD_VARIABLES ""
set_interface_property reset_sink SVD_ADDRESS_GROUP ""

add_interface_port reset_sink S_AXI_ARESETN reset_n Input 1

