# TCL File Generated by Component Editor 21.1
# Tue Dec 28 19:02:31 CET 2021
# DO NOT MODIFY


# 
# testblk "testblk" v1.0
# WZab, based on BZab work 2021.12.28.19:02:31
# Simple block working as a Avalon slave and master
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module testblk
# 
set_module_property DESCRIPTION "Simple block working as a Avalon slave and master"
set_module_property NAME testblk
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR "WZab, based on BZab work"
set_module_property DISPLAY_NAME testblk
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL gsrd
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file gsrd.vhd VHDL PATH ../src/gsrd.vhd TOP_LEVEL_FILE
add_fileset_file comm.vhd VHDL PATH ../src/comm.vhd
add_fileset_file mem.cmp OTHER PATH ../src/mem.cmp
add_fileset_file mem.qip OTHER PATH ../src/mem.qip
add_fileset_file mem.vhd VHDL PATH ../src/mem.vhd
add_fileset_file reg.vhd VHDL PATH ../src/reg.vhd
add_fileset_file reg_ctrl.vhd VHDL PATH ../src/reg_ctrl.vhd


# 
# parameters
# 

# 
# module assignments
# 
set_module_assignment embeddedsw.dts.compatible wzab,testblk
set_module_assignment embeddedsw.dts.group wzperiphs
set_module_assignment embeddedsw.dts.vendor WZab

# 
# display items
# 


# 
# connection point avalon_slave
# 
add_interface avalon_slave avalon end
set_interface_property avalon_slave addressUnits WORDS
set_interface_property avalon_slave associatedClock clock_sink
set_interface_property avalon_slave associatedReset reset_sink
set_interface_property avalon_slave bitsPerSymbol 8
set_interface_property avalon_slave burstOnBurstBoundariesOnly false
set_interface_property avalon_slave burstcountUnits WORDS
set_interface_property avalon_slave explicitAddressSpan 0
set_interface_property avalon_slave holdTime 0
set_interface_property avalon_slave linewrapBursts false
set_interface_property avalon_slave maximumPendingReadTransactions 0
set_interface_property avalon_slave maximumPendingWriteTransactions 0
set_interface_property avalon_slave readLatency 0
set_interface_property avalon_slave readWaitTime 1
set_interface_property avalon_slave setupTime 0
set_interface_property avalon_slave timingUnits Cycles
set_interface_property avalon_slave writeWaitTime 0
set_interface_property avalon_slave ENABLED true
set_interface_property avalon_slave EXPORT_OF ""
set_interface_property avalon_slave PORT_NAME_MAP ""
set_interface_property avalon_slave CMSIS_SVD_VARIABLES ""
set_interface_property avalon_slave SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave avalon_slave_address address Input 3
add_interface_port avalon_slave avalon_slave_read read Input 1
add_interface_port avalon_slave avalon_slave_readdata readdata Output 32
add_interface_port avalon_slave avalon_slave_waitrequest waitrequest Output 1
add_interface_port avalon_slave avalon_slave_write write Input 1
add_interface_port avalon_slave avalon_slave_writedata writedata Input 32
add_interface_port avalon_slave avalon_slave_response response Output 2
set_interface_assignment avalon_slave embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave embeddedsw.configuration.isPrintableDevice 0


# 
# connection point avalon_master
# 
add_interface avalon_master avalon start
set_interface_property avalon_master addressUnits SYMBOLS
set_interface_property avalon_master associatedClock clock_sink
set_interface_property avalon_master associatedReset reset_sink
set_interface_property avalon_master bitsPerSymbol 8
set_interface_property avalon_master burstOnBurstBoundariesOnly false
set_interface_property avalon_master burstcountUnits WORDS
set_interface_property avalon_master doStreamReads false
set_interface_property avalon_master doStreamWrites false
set_interface_property avalon_master holdTime 0
set_interface_property avalon_master linewrapBursts false
set_interface_property avalon_master maximumPendingReadTransactions 0
set_interface_property avalon_master maximumPendingWriteTransactions 0
set_interface_property avalon_master readLatency 0
set_interface_property avalon_master readWaitTime 1
set_interface_property avalon_master setupTime 0
set_interface_property avalon_master timingUnits Cycles
set_interface_property avalon_master writeWaitTime 0
set_interface_property avalon_master ENABLED true
set_interface_property avalon_master EXPORT_OF ""
set_interface_property avalon_master PORT_NAME_MAP ""
set_interface_property avalon_master CMSIS_SVD_VARIABLES ""
set_interface_property avalon_master SVD_ADDRESS_GROUP ""

add_interface_port avalon_master avalon_master_write write Output 1
add_interface_port avalon_master avalon_master_read read Output 1
add_interface_port avalon_master avalon_master_readdata readdata Input 32
add_interface_port avalon_master avalon_master_readdatavalid readdatavalid Input 1
add_interface_port avalon_master avalon_master_writedata writedata Output 32
add_interface_port avalon_master avalon_master_address address Output 32
add_interface_port avalon_master avalon_master_waitrequest waitrequest Input 1
add_interface_port avalon_master avalon_master_response response Input 2
add_interface_port avalon_master avalon_master_burstcount burstcount Output 28


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

add_interface_port clock_sink clock_sink_clk clk Input 1


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

add_interface_port reset_sink reset_sink_reset reset Input 1

