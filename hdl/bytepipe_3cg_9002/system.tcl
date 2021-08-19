
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu3cg-sbva484-1-e
   set_property BOARD_PART nextgenrf.com:bytepipe_3cg_som:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:xlconstant:1.1\
analog.com:user:axi_adrv9001:1.0\
analog.com:user:axi_dmac:1.0\
xilinx.com:ip:smartconnect:1.0\
analog.com:user:axi_sysid:1.0\
xilinx.com:ip:clk_wiz:6.0\
analog.com:user:sysid_rom:1.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:zynq_ultra_ps_e:3.3\
analog.com:user:util_cpack2:1.0\
analog.com:user:util_upack2:1.0\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set gpio_i [ create_bd_port -dir I -from 94 -to 0 gpio_i ]
  set gpio_o [ create_bd_port -dir O -from 94 -to 0 gpio_o ]
  set gpio_rx1_enable_in [ create_bd_port -dir I gpio_rx1_enable_in ]
  set gpio_rx2_enable_in [ create_bd_port -dir I gpio_rx2_enable_in ]
  set gpio_t [ create_bd_port -dir O -from 94 -to 0 gpio_t ]
  set gpio_tx1_enable_in [ create_bd_port -dir I gpio_tx1_enable_in ]
  set gpio_tx2_enable_in [ create_bd_port -dir I gpio_tx2_enable_in ]
  set mssi_sync [ create_bd_port -dir I mssi_sync ]
  set rx1_dclk_in_n [ create_bd_port -dir I rx1_dclk_in_n ]
  set rx1_dclk_in_p [ create_bd_port -dir I rx1_dclk_in_p ]
  set rx1_enable [ create_bd_port -dir O rx1_enable ]
  set rx1_idata_in_n [ create_bd_port -dir I rx1_idata_in_n ]
  set rx1_idata_in_p [ create_bd_port -dir I rx1_idata_in_p ]
  set rx1_qdata_in_n [ create_bd_port -dir I rx1_qdata_in_n ]
  set rx1_qdata_in_p [ create_bd_port -dir I rx1_qdata_in_p ]
  set rx1_strobe_in_n [ create_bd_port -dir I rx1_strobe_in_n ]
  set rx1_strobe_in_p [ create_bd_port -dir I rx1_strobe_in_p ]
  set rx2_dclk_in_n [ create_bd_port -dir I rx2_dclk_in_n ]
  set rx2_dclk_in_p [ create_bd_port -dir I rx2_dclk_in_p ]
  set rx2_enable [ create_bd_port -dir O rx2_enable ]
  set rx2_idata_in_n [ create_bd_port -dir I rx2_idata_in_n ]
  set rx2_idata_in_p [ create_bd_port -dir I rx2_idata_in_p ]
  set rx2_qdata_in_n [ create_bd_port -dir I rx2_qdata_in_n ]
  set rx2_qdata_in_p [ create_bd_port -dir I rx2_qdata_in_p ]
  set rx2_strobe_in_n [ create_bd_port -dir I rx2_strobe_in_n ]
  set rx2_strobe_in_p [ create_bd_port -dir I rx2_strobe_in_p ]
  set spi0_csn [ create_bd_port -dir O -from 2 -to 0 spi0_csn ]
  set spi0_miso [ create_bd_port -dir I spi0_miso ]
  set spi0_mosi [ create_bd_port -dir O spi0_mosi ]
  set spi0_sclk [ create_bd_port -dir O spi0_sclk ]
  set spi1_csn [ create_bd_port -dir O -from 2 -to 0 spi1_csn ]
  set spi1_miso [ create_bd_port -dir I spi1_miso ]
  set spi1_mosi [ create_bd_port -dir O spi1_mosi ]
  set spi1_sclk [ create_bd_port -dir O spi1_sclk ]
  set tdd_sync [ create_bd_port -dir I tdd_sync ]
  set tdd_sync_cntr [ create_bd_port -dir O tdd_sync_cntr ]
  set tx1_dclk_in_n [ create_bd_port -dir I tx1_dclk_in_n ]
  set tx1_dclk_in_p [ create_bd_port -dir I tx1_dclk_in_p ]
  set tx1_dclk_out_n [ create_bd_port -dir O tx1_dclk_out_n ]
  set tx1_dclk_out_p [ create_bd_port -dir O tx1_dclk_out_p ]
  set tx1_enable [ create_bd_port -dir O tx1_enable ]
  set tx1_idata_out_n [ create_bd_port -dir O tx1_idata_out_n ]
  set tx1_idata_out_p [ create_bd_port -dir O tx1_idata_out_p ]
  set tx1_qdata_out_n [ create_bd_port -dir O tx1_qdata_out_n ]
  set tx1_qdata_out_p [ create_bd_port -dir O tx1_qdata_out_p ]
  set tx1_strobe_out_n [ create_bd_port -dir O tx1_strobe_out_n ]
  set tx1_strobe_out_p [ create_bd_port -dir O tx1_strobe_out_p ]
  set tx2_dclk_in_n [ create_bd_port -dir I tx2_dclk_in_n ]
  set tx2_dclk_in_p [ create_bd_port -dir I tx2_dclk_in_p ]
  set tx2_dclk_out_n [ create_bd_port -dir O tx2_dclk_out_n ]
  set tx2_dclk_out_p [ create_bd_port -dir O tx2_dclk_out_p ]
  set tx2_enable [ create_bd_port -dir O tx2_enable ]
  set tx2_idata_out_n [ create_bd_port -dir O tx2_idata_out_n ]
  set tx2_idata_out_p [ create_bd_port -dir O tx2_idata_out_p ]
  set tx2_qdata_out_n [ create_bd_port -dir O tx2_qdata_out_n ]
  set tx2_qdata_out_p [ create_bd_port -dir O tx2_qdata_out_p ]
  set tx2_strobe_out_n [ create_bd_port -dir O tx2_strobe_out_n ]
  set tx2_strobe_out_p [ create_bd_port -dir O tx2_strobe_out_p ]
  set tx_output_enable [ create_bd_port -dir I tx_output_enable ]

  # Create instance: GND_1, and set properties
  set GND_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 GND_1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {1} \
 ] $GND_1

  # Create instance: VCC_1, and set properties
  set VCC_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 VCC_1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {1} \
   CONFIG.CONST_WIDTH {1} \
 ] $VCC_1

  # Create instance: axi_adrv9001, and set properties
  set axi_adrv9001 [ create_bd_cell -type ip -vlnv analog.com:user:axi_adrv9001:1.0 axi_adrv9001 ]
  set_property -dict [ list \
   CONFIG.CMOS_LVDS_N {0} \
   CONFIG.USE_RX_CLK_FOR_TX {1} \
 ] $axi_adrv9001

  # Create instance: axi_adrv9001_rx1_dma, and set properties
  set axi_adrv9001_rx1_dma [ create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_adrv9001_rx1_dma ]
  set_property -dict [ list \
   CONFIG.AXI_SLICE_DEST {false} \
   CONFIG.AXI_SLICE_SRC {false} \
   CONFIG.CYCLIC {false} \
   CONFIG.DMA_2D_TRANSFER {false} \
   CONFIG.DMA_DATA_WIDTH_SRC {64} \
   CONFIG.DMA_TYPE_DEST {0} \
   CONFIG.DMA_TYPE_SRC {2} \
   CONFIG.SYNC_TRANSFER_START {false} \
 ] $axi_adrv9001_rx1_dma

  # Create instance: axi_adrv9001_rx2_dma, and set properties
  set axi_adrv9001_rx2_dma [ create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_adrv9001_rx2_dma ]
  set_property -dict [ list \
   CONFIG.AXI_SLICE_DEST {false} \
   CONFIG.AXI_SLICE_SRC {false} \
   CONFIG.CYCLIC {false} \
   CONFIG.DMA_2D_TRANSFER {false} \
   CONFIG.DMA_DATA_WIDTH_SRC {32} \
   CONFIG.DMA_TYPE_DEST {0} \
   CONFIG.DMA_TYPE_SRC {2} \
   CONFIG.SYNC_TRANSFER_START {false} \
 ] $axi_adrv9001_rx2_dma

  # Create instance: axi_adrv9001_tx1_dma, and set properties
  set axi_adrv9001_tx1_dma [ create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_adrv9001_tx1_dma ]
  set_property -dict [ list \
   CONFIG.AXI_SLICE_DEST {false} \
   CONFIG.AXI_SLICE_SRC {false} \
   CONFIG.CYCLIC {true} \
   CONFIG.DMA_2D_TRANSFER {false} \
   CONFIG.DMA_DATA_WIDTH_DEST {64} \
   CONFIG.DMA_TYPE_DEST {1} \
   CONFIG.DMA_TYPE_SRC {0} \
 ] $axi_adrv9001_tx1_dma

  # Create instance: axi_adrv9001_tx2_dma, and set properties
  set axi_adrv9001_tx2_dma [ create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_adrv9001_tx2_dma ]
  set_property -dict [ list \
   CONFIG.AXI_SLICE_DEST {false} \
   CONFIG.AXI_SLICE_SRC {false} \
   CONFIG.CYCLIC {true} \
   CONFIG.DMA_2D_TRANSFER {false} \
   CONFIG.DMA_DATA_WIDTH_DEST {32} \
   CONFIG.DMA_TYPE_DEST {1} \
   CONFIG.DMA_TYPE_SRC {0} \
 ] $axi_adrv9001_tx2_dma

  # Create instance: axi_cpu_interconnect, and set properties
  set axi_cpu_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_cpu_interconnect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {6} \
 ] $axi_cpu_interconnect

  # Create instance: axi_hp1_interconnect, and set properties
  set axi_hp1_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_hp1_interconnect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {4} \
 ] $axi_hp1_interconnect

  # Create instance: axi_sysid_0, and set properties
  set axi_sysid_0 [ create_bd_cell -type ip -vlnv analog.com:user:axi_sysid:1.0 axi_sysid_0 ]
  set_property -dict [ list \
   CONFIG.ROM_ADDR_BITS {9} \
 ] $axi_sysid_0

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_JITTER {281.091} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {38.4} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {28.375} \
   CONFIG.USE_LOCKED {false} \
   CONFIG.USE_RESET {false} \
 ] $clk_wiz_0

  # Create instance: rom_sys_0, and set properties
  set rom_sys_0 [ create_bd_cell -type ip -vlnv analog.com:user:sysid_rom:1.0 rom_sys_0 ]
  set_property -dict [ list \
   CONFIG.PATH_TO_FILE {$script_folder/mem_init_sys.txt} \
   CONFIG.ROM_ADDR_BITS {9} \
 ] $rom_sys_0

  # Create instance: spi0_csn_concat, and set properties
  set spi0_csn_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 spi0_csn_concat ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {3} \
 ] $spi0_csn_concat

  # Create instance: spi1_csn_concat, and set properties
  set spi1_csn_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 spi1_csn_concat ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {3} \
 ] $spi1_csn_concat

  # Create instance: sys_250m_rstgen, and set properties
  set sys_250m_rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_250m_rstgen ]
  set_property -dict [ list \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $sys_250m_rstgen

  # Create instance: sys_500m_rstgen, and set properties
  set sys_500m_rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_500m_rstgen ]
  set_property -dict [ list \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $sys_500m_rstgen

  # Create instance: sys_concat_intc_0, and set properties
  set sys_concat_intc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 sys_concat_intc_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {8} \
 ] $sys_concat_intc_0

  # Create instance: sys_concat_intc_1, and set properties
  set sys_concat_intc_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 sys_concat_intc_1 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {8} \
 ] $sys_concat_intc_1

  # Create instance: sys_ps8, and set properties
  set sys_ps8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.3 sys_ps8 ]
  set_property -dict [ list \
   CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
   CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS33} \
   CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
   CONFIG.PSU_DDR_RAM_HIGHADDR {0x7FFFFFFF} \
   CONFIG.PSU_DDR_RAM_HIGHADDR_OFFSET {0x00000002} \
   CONFIG.PSU_DDR_RAM_LOWADDR_OFFSET {0x80000000} \
   CONFIG.PSU_DYNAMIC_DDR_CONFIG_EN {0} \
   CONFIG.PSU_MIO_0_DIRECTION {inout} \
   CONFIG.PSU_MIO_0_POLARITY {Default} \
   CONFIG.PSU_MIO_10_DIRECTION {in} \
   CONFIG.PSU_MIO_10_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_10_POLARITY {Default} \
   CONFIG.PSU_MIO_10_SLEW {fast} \
   CONFIG.PSU_MIO_11_DIRECTION {out} \
   CONFIG.PSU_MIO_11_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_11_POLARITY {Default} \
   CONFIG.PSU_MIO_12_DIRECTION {inout} \
   CONFIG.PSU_MIO_12_POLARITY {Default} \
   CONFIG.PSU_MIO_13_DIRECTION {inout} \
   CONFIG.PSU_MIO_13_POLARITY {Default} \
   CONFIG.PSU_MIO_14_DIRECTION {inout} \
   CONFIG.PSU_MIO_14_POLARITY {Default} \
   CONFIG.PSU_MIO_15_DIRECTION {inout} \
   CONFIG.PSU_MIO_15_POLARITY {Default} \
   CONFIG.PSU_MIO_16_DIRECTION {inout} \
   CONFIG.PSU_MIO_16_POLARITY {Default} \
   CONFIG.PSU_MIO_17_DIRECTION {inout} \
   CONFIG.PSU_MIO_17_POLARITY {Default} \
   CONFIG.PSU_MIO_18_DIRECTION {inout} \
   CONFIG.PSU_MIO_18_POLARITY {Default} \
   CONFIG.PSU_MIO_19_DIRECTION {inout} \
   CONFIG.PSU_MIO_19_POLARITY {Default} \
   CONFIG.PSU_MIO_1_DIRECTION {inout} \
   CONFIG.PSU_MIO_1_POLARITY {Default} \
   CONFIG.PSU_MIO_20_DIRECTION {inout} \
   CONFIG.PSU_MIO_20_POLARITY {Default} \
   CONFIG.PSU_MIO_21_DIRECTION {inout} \
   CONFIG.PSU_MIO_21_POLARITY {Default} \
   CONFIG.PSU_MIO_22_DIRECTION {out} \
   CONFIG.PSU_MIO_22_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_22_POLARITY {Default} \
   CONFIG.PSU_MIO_23_DIRECTION {inout} \
   CONFIG.PSU_MIO_23_POLARITY {Default} \
   CONFIG.PSU_MIO_24_DIRECTION {inout} \
   CONFIG.PSU_MIO_24_POLARITY {Default} \
   CONFIG.PSU_MIO_25_DIRECTION {inout} \
   CONFIG.PSU_MIO_25_POLARITY {Default} \
   CONFIG.PSU_MIO_26_DIRECTION {inout} \
   CONFIG.PSU_MIO_26_POLARITY {Default} \
   CONFIG.PSU_MIO_27_DIRECTION {out} \
   CONFIG.PSU_MIO_27_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_27_POLARITY {Default} \
   CONFIG.PSU_MIO_28_DIRECTION {in} \
   CONFIG.PSU_MIO_28_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_28_POLARITY {Default} \
   CONFIG.PSU_MIO_28_SLEW {fast} \
   CONFIG.PSU_MIO_29_DIRECTION {out} \
   CONFIG.PSU_MIO_29_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_29_POLARITY {Default} \
   CONFIG.PSU_MIO_2_DIRECTION {inout} \
   CONFIG.PSU_MIO_2_POLARITY {Default} \
   CONFIG.PSU_MIO_30_DIRECTION {in} \
   CONFIG.PSU_MIO_30_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_30_POLARITY {Default} \
   CONFIG.PSU_MIO_30_SLEW {fast} \
   CONFIG.PSU_MIO_31_DIRECTION {inout} \
   CONFIG.PSU_MIO_31_POLARITY {Default} \
   CONFIG.PSU_MIO_32_DIRECTION {inout} \
   CONFIG.PSU_MIO_32_POLARITY {Default} \
   CONFIG.PSU_MIO_33_DIRECTION {inout} \
   CONFIG.PSU_MIO_33_POLARITY {Default} \
   CONFIG.PSU_MIO_34_DIRECTION {inout} \
   CONFIG.PSU_MIO_34_POLARITY {Default} \
   CONFIG.PSU_MIO_35_DIRECTION {inout} \
   CONFIG.PSU_MIO_35_POLARITY {Default} \
   CONFIG.PSU_MIO_36_DIRECTION {inout} \
   CONFIG.PSU_MIO_36_POLARITY {Default} \
   CONFIG.PSU_MIO_37_DIRECTION {inout} \
   CONFIG.PSU_MIO_37_POLARITY {Default} \
   CONFIG.PSU_MIO_38_DIRECTION {inout} \
   CONFIG.PSU_MIO_38_POLARITY {Default} \
   CONFIG.PSU_MIO_39_DIRECTION {inout} \
   CONFIG.PSU_MIO_39_POLARITY {Default} \
   CONFIG.PSU_MIO_3_DIRECTION {inout} \
   CONFIG.PSU_MIO_3_POLARITY {Default} \
   CONFIG.PSU_MIO_40_DIRECTION {inout} \
   CONFIG.PSU_MIO_40_POLARITY {Default} \
   CONFIG.PSU_MIO_41_DIRECTION {inout} \
   CONFIG.PSU_MIO_41_POLARITY {Default} \
   CONFIG.PSU_MIO_42_DIRECTION {inout} \
   CONFIG.PSU_MIO_42_POLARITY {Default} \
   CONFIG.PSU_MIO_43_DIRECTION {inout} \
   CONFIG.PSU_MIO_43_POLARITY {Default} \
   CONFIG.PSU_MIO_44_DIRECTION {inout} \
   CONFIG.PSU_MIO_44_POLARITY {Default} \
   CONFIG.PSU_MIO_45_DIRECTION {in} \
   CONFIG.PSU_MIO_45_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_45_POLARITY {Default} \
   CONFIG.PSU_MIO_45_SLEW {fast} \
   CONFIG.PSU_MIO_46_DIRECTION {inout} \
   CONFIG.PSU_MIO_46_POLARITY {Default} \
   CONFIG.PSU_MIO_47_DIRECTION {inout} \
   CONFIG.PSU_MIO_47_POLARITY {Default} \
   CONFIG.PSU_MIO_48_DIRECTION {inout} \
   CONFIG.PSU_MIO_48_POLARITY {Default} \
   CONFIG.PSU_MIO_49_DIRECTION {inout} \
   CONFIG.PSU_MIO_49_POLARITY {Default} \
   CONFIG.PSU_MIO_4_DIRECTION {inout} \
   CONFIG.PSU_MIO_4_POLARITY {Default} \
   CONFIG.PSU_MIO_50_DIRECTION {inout} \
   CONFIG.PSU_MIO_50_POLARITY {Default} \
   CONFIG.PSU_MIO_51_DIRECTION {out} \
   CONFIG.PSU_MIO_51_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_51_POLARITY {Default} \
   CONFIG.PSU_MIO_52_DIRECTION {in} \
   CONFIG.PSU_MIO_52_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_52_POLARITY {Default} \
   CONFIG.PSU_MIO_52_SLEW {fast} \
   CONFIG.PSU_MIO_53_DIRECTION {in} \
   CONFIG.PSU_MIO_53_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_53_POLARITY {Default} \
   CONFIG.PSU_MIO_53_SLEW {fast} \
   CONFIG.PSU_MIO_54_DIRECTION {inout} \
   CONFIG.PSU_MIO_54_POLARITY {Default} \
   CONFIG.PSU_MIO_55_DIRECTION {in} \
   CONFIG.PSU_MIO_55_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_55_POLARITY {Default} \
   CONFIG.PSU_MIO_55_SLEW {fast} \
   CONFIG.PSU_MIO_56_DIRECTION {inout} \
   CONFIG.PSU_MIO_56_POLARITY {Default} \
   CONFIG.PSU_MIO_57_DIRECTION {inout} \
   CONFIG.PSU_MIO_57_POLARITY {Default} \
   CONFIG.PSU_MIO_58_DIRECTION {out} \
   CONFIG.PSU_MIO_58_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_58_POLARITY {Default} \
   CONFIG.PSU_MIO_59_DIRECTION {inout} \
   CONFIG.PSU_MIO_59_POLARITY {Default} \
   CONFIG.PSU_MIO_5_DIRECTION {inout} \
   CONFIG.PSU_MIO_5_POLARITY {Default} \
   CONFIG.PSU_MIO_60_DIRECTION {inout} \
   CONFIG.PSU_MIO_60_POLARITY {Default} \
   CONFIG.PSU_MIO_61_DIRECTION {inout} \
   CONFIG.PSU_MIO_61_POLARITY {Default} \
   CONFIG.PSU_MIO_62_DIRECTION {inout} \
   CONFIG.PSU_MIO_62_POLARITY {Default} \
   CONFIG.PSU_MIO_63_DIRECTION {inout} \
   CONFIG.PSU_MIO_63_POLARITY {Default} \
   CONFIG.PSU_MIO_64_DIRECTION {out} \
   CONFIG.PSU_MIO_64_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_64_POLARITY {Default} \
   CONFIG.PSU_MIO_65_DIRECTION {out} \
   CONFIG.PSU_MIO_65_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_65_POLARITY {Default} \
   CONFIG.PSU_MIO_66_DIRECTION {out} \
   CONFIG.PSU_MIO_66_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_66_POLARITY {Default} \
   CONFIG.PSU_MIO_67_DIRECTION {out} \
   CONFIG.PSU_MIO_67_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_67_POLARITY {Default} \
   CONFIG.PSU_MIO_68_DIRECTION {out} \
   CONFIG.PSU_MIO_68_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_68_POLARITY {Default} \
   CONFIG.PSU_MIO_69_DIRECTION {out} \
   CONFIG.PSU_MIO_69_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_69_POLARITY {Default} \
   CONFIG.PSU_MIO_6_DIRECTION {inout} \
   CONFIG.PSU_MIO_6_POLARITY {Default} \
   CONFIG.PSU_MIO_70_DIRECTION {in} \
   CONFIG.PSU_MIO_70_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_70_POLARITY {Default} \
   CONFIG.PSU_MIO_70_SLEW {fast} \
   CONFIG.PSU_MIO_71_DIRECTION {in} \
   CONFIG.PSU_MIO_71_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_71_POLARITY {Default} \
   CONFIG.PSU_MIO_71_SLEW {fast} \
   CONFIG.PSU_MIO_72_DIRECTION {in} \
   CONFIG.PSU_MIO_72_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_72_POLARITY {Default} \
   CONFIG.PSU_MIO_72_SLEW {fast} \
   CONFIG.PSU_MIO_73_DIRECTION {in} \
   CONFIG.PSU_MIO_73_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_73_POLARITY {Default} \
   CONFIG.PSU_MIO_73_SLEW {fast} \
   CONFIG.PSU_MIO_74_DIRECTION {in} \
   CONFIG.PSU_MIO_74_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_74_POLARITY {Default} \
   CONFIG.PSU_MIO_74_SLEW {fast} \
   CONFIG.PSU_MIO_75_DIRECTION {in} \
   CONFIG.PSU_MIO_75_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_75_POLARITY {Default} \
   CONFIG.PSU_MIO_75_SLEW {fast} \
   CONFIG.PSU_MIO_76_DIRECTION {out} \
   CONFIG.PSU_MIO_76_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_76_POLARITY {Default} \
   CONFIG.PSU_MIO_77_DIRECTION {inout} \
   CONFIG.PSU_MIO_77_POLARITY {Default} \
   CONFIG.PSU_MIO_7_DIRECTION {inout} \
   CONFIG.PSU_MIO_7_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_7_POLARITY {Default} \
   CONFIG.PSU_MIO_8_DIRECTION {out} \
   CONFIG.PSU_MIO_8_INPUT_TYPE {cmos} \
   CONFIG.PSU_MIO_8_POLARITY {Default} \
   CONFIG.PSU_MIO_9_DIRECTION {in} \
   CONFIG.PSU_MIO_9_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_9_POLARITY {Default} \
   CONFIG.PSU_MIO_9_SLEW {fast} \
   CONFIG.PSU_MIO_TREE_PERIPHERALS {GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#UART 1#UART 1#UART 0#UART 0#GPIO0 MIO#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#GPIO0 MIO#I2C 1#I2C 1#GPIO1 MIO#DPAUX#DPAUX#DPAUX#DPAUX#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#MDIO 3#MDIO 3} \
   CONFIG.PSU_MIO_TREE_SIGNALS {gpio0[0]#gpio0[1]#gpio0[2]#gpio0[3]#gpio0[4]#gpio0[5]#gpio0[6]#gpio0[7]#txd#rxd#rxd#txd#gpio0[12]#sdio0_data_out[0]#sdio0_data_out[1]#sdio0_data_out[2]#sdio0_data_out[3]#sdio0_data_out[4]#sdio0_data_out[5]#sdio0_data_out[6]#sdio0_data_out[7]#sdio0_cmd_out#sdio0_clk_out#gpio0[23]#scl_out#sda_out#gpio1[26]#dp_aux_data_out#dp_hot_plug_detect#dp_aux_data_oe#dp_aux_data_in#gpio1[31]#gpio1[32]#gpio1[33]#gpio1[34]#gpio1[35]#gpio1[36]#gpio1[37]#gpio1[38]#gpio1[39]#gpio1[40]#gpio1[41]#gpio1[42]#gpio1[43]#gpio1[44]#sdio1_cd_n#sdio1_data_out[0]#sdio1_data_out[1]#sdio1_data_out[2]#sdio1_data_out[3]#sdio1_cmd_out#sdio1_clk_out#ulpi_clk_in#ulpi_dir#ulpi_tx_data[2]#ulpi_nxt#ulpi_tx_data[0]#ulpi_tx_data[1]#ulpi_stp#ulpi_tx_data[3]#ulpi_tx_data[4]#ulpi_tx_data[5]#ulpi_tx_data[6]#ulpi_tx_data[7]#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#gem3_mdc#gem3_mdio_out} \
   CONFIG.PSU_SD0_INTERNAL_BUS_WIDTH {8} \
   CONFIG.PSU_SD1_INTERNAL_BUS_WIDTH {4} \
   CONFIG.PSU_USB3__DUAL_CLOCK_ENABLE {1} \
   CONFIG.PSU__ACT_DDR_FREQ_MHZ {526.661438} \
   CONFIG.PSU__CAN1__GRP_CLK__ENABLE {0} \
   CONFIG.PSU__CAN1__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__ACT_FREQMHZ {1099.989014} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__DIVISOR0 {1} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__FREQMHZ {1100} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__SRCSEL {APLL} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__FBDIV {66} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRF_APB__APLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRF_APB__APLL_TO_LPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__ACT_FREQMHZ {263.330719} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {533} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__ACT_FREQMHZ {549.994507} \
   CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__FREQMHZ {550} \
   CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__SRCSEL {APLL} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__FBDIV {79} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRF_APB__DPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRF_APB__DPLL_TO_LPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__ACT_FREQMHZ {24.999750} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__DIVISOR0 {16} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__FREQMHZ {25} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRF_APB__DP_AUDIO__FRAC_ENABLED {0} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__ACT_FREQMHZ {26.666401} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__FREQMHZ {27} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__ACT_FREQMHZ {299.997009} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__FREQMHZ {300} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__SRCSEL {VPLL} \
   CONFIG.PSU__CRF_APB__DP_VIDEO__FRAC_ENABLED {0} \
   CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__ACT_FREQMHZ {549.994507} \
   CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__FREQMHZ {550} \
   CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__SRCSEL {APLL} \
   CONFIG.PSU__CRF_APB__GPU_REF_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRF_APB__GPU_REF_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRF_APB__GPU_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__ACT_FREQMHZ {438.884521} \
   CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__FREQMHZ {475} \
   CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__SRCSEL {DPLL} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__FBDIV {90} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRF_APB__VPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRF_APB__VPLL_TO_LPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__ACT_FREQMHZ {499.994995} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__AFI6_REF_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__ACT_FREQMHZ {49.999500} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__DIVISOR0 {30} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__ACT_FREQMHZ {499.994995} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__DLL_REF_CTRL__ACT_FREQMHZ {1499.984985} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__ACT_FREQMHZ {124.998749} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__FBDIV {90} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRL_APB__IOPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRL_APB__IOPLL_TO_FPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__ACT_FREQMHZ {499.994995} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__NAND_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__NAND_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PCAP_CTRL__ACT_FREQMHZ {187.498123} \
   CONFIG.PSU__CRL_APB__PCAP_CTRL__DIVISOR0 {8} \
   CONFIG.PSU__CRL_APB__PCAP_CTRL__FREQMHZ {200} \
   CONFIG.PSU__CRL_APB__PCAP_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__ACT_FREQMHZ {499.994995} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__PL3_REF_CTRL__DIVISOR0 {4} \
   CONFIG.PSU__CRL_APB__PL3_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__FREQMHZ {125} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__FBDIV {72} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__SRCSEL {PSS_REF_CLK} \
   CONFIG.PSU__CRL_APB__RPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRL_APB__RPLL_TO_FPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__ACT_FREQMHZ {199.998001} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__ACT_FREQMHZ {199.998001} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__FREQMHZ {200} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__FREQMHZ {100} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__ACT_FREQMHZ {249.997498} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__ACT_FREQMHZ {19.999800} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__DIVISOR0 {25} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__DIVISOR1 {3} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__FREQMHZ {20} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__USB3__ENABLE {1} \
   CONFIG.PSU__DDRC__ADDR_MIRROR {1} \
   CONFIG.PSU__DDRC__AL {0} \
   CONFIG.PSU__DDRC__BANK_ADDR_COUNT {3} \
   CONFIG.PSU__DDRC__BG_ADDR_COUNT {NA} \
   CONFIG.PSU__DDRC__BRC_MAPPING {ROW_BANK_COL} \
   CONFIG.PSU__DDRC__BUS_WIDTH {32 Bit} \
   CONFIG.PSU__DDRC__CL {NA} \
   CONFIG.PSU__DDRC__CLOCK_STOP_EN {0} \
   CONFIG.PSU__DDRC__COL_ADDR_COUNT {10} \
   CONFIG.PSU__DDRC__COMPONENTS {Components} \
   CONFIG.PSU__DDRC__CWL {NA} \
   CONFIG.PSU__DDRC__DDR3L_T_REF_RANGE {NA} \
   CONFIG.PSU__DDRC__DDR3_T_REF_RANGE {NA} \
   CONFIG.PSU__DDRC__DDR4_ADDR_MAPPING {NA} \
   CONFIG.PSU__DDRC__DDR4_CAL_MODE_ENABLE {NA} \
   CONFIG.PSU__DDRC__DDR4_CRC_CONTROL {NA} \
   CONFIG.PSU__DDRC__DDR4_MAXPWR_SAVING_EN {NA} \
   CONFIG.PSU__DDRC__DDR4_T_REF_MODE {NA} \
   CONFIG.PSU__DDRC__DDR4_T_REF_RANGE {NA} \
   CONFIG.PSU__DDRC__DEEP_PWR_DOWN_EN {0} \
   CONFIG.PSU__DDRC__DEVICE_CAPACITY {16384 MBits} \
   CONFIG.PSU__DDRC__DIMM_ADDR_MIRROR {0} \
   CONFIG.PSU__DDRC__DM_DBI {DM_NO_DBI} \
   CONFIG.PSU__DDRC__DQMAP_0_3 {0} \
   CONFIG.PSU__DDRC__DQMAP_12_15 {0} \
   CONFIG.PSU__DDRC__DQMAP_16_19 {0} \
   CONFIG.PSU__DDRC__DQMAP_20_23 {0} \
   CONFIG.PSU__DDRC__DQMAP_24_27 {0} \
   CONFIG.PSU__DDRC__DQMAP_28_31 {0} \
   CONFIG.PSU__DDRC__DQMAP_32_35 {0} \
   CONFIG.PSU__DDRC__DQMAP_36_39 {0} \
   CONFIG.PSU__DDRC__DQMAP_40_43 {0} \
   CONFIG.PSU__DDRC__DQMAP_44_47 {0} \
   CONFIG.PSU__DDRC__DQMAP_48_51 {0} \
   CONFIG.PSU__DDRC__DQMAP_4_7 {0} \
   CONFIG.PSU__DDRC__DQMAP_52_55 {0} \
   CONFIG.PSU__DDRC__DQMAP_56_59 {0} \
   CONFIG.PSU__DDRC__DQMAP_60_63 {0} \
   CONFIG.PSU__DDRC__DQMAP_64_67 {0} \
   CONFIG.PSU__DDRC__DQMAP_68_71 {0} \
   CONFIG.PSU__DDRC__DQMAP_8_11 {0} \
   CONFIG.PSU__DDRC__DRAM_WIDTH {32 Bits} \
   CONFIG.PSU__DDRC__ECC {Disabled} \
   CONFIG.PSU__DDRC__ENABLE_2T_TIMING {0} \
   CONFIG.PSU__DDRC__ENABLE_DP_SWITCH {1} \
   CONFIG.PSU__DDRC__ENABLE_LP4_HAS_ECC_COMP {0} \
   CONFIG.PSU__DDRC__ENABLE_LP4_SLOWBOOT {0} \
   CONFIG.PSU__DDRC__FGRM {NA} \
   CONFIG.PSU__DDRC__LPDDR3_T_REF_RANGE {NA} \
   CONFIG.PSU__DDRC__LPDDR4_T_REF_RANGE {High (95 Max)} \
   CONFIG.PSU__DDRC__LP_ASR {NA} \
   CONFIG.PSU__DDRC__MEMORY_TYPE {LPDDR 4} \
   CONFIG.PSU__DDRC__PARITY_ENABLE {NA} \
   CONFIG.PSU__DDRC__PER_BANK_REFRESH {0} \
   CONFIG.PSU__DDRC__PHY_DBI_MODE {0} \
   CONFIG.PSU__DDRC__RANK_ADDR_COUNT {0} \
   CONFIG.PSU__DDRC__ROW_ADDR_COUNT {16} \
   CONFIG.PSU__DDRC__SB_TARGET {NA} \
   CONFIG.PSU__DDRC__SELF_REF_ABORT {NA} \
   CONFIG.PSU__DDRC__SPEED_BIN {LPDDR4_1066} \
   CONFIG.PSU__DDRC__STATIC_RD_MODE {0} \
   CONFIG.PSU__DDRC__TRAIN_DATA_EYE {1} \
   CONFIG.PSU__DDRC__TRAIN_READ_GATE {1} \
   CONFIG.PSU__DDRC__TRAIN_WRITE_LEVEL {1} \
   CONFIG.PSU__DDRC__T_FAW {40.0} \
   CONFIG.PSU__DDRC__T_RAS_MIN {42} \
   CONFIG.PSU__DDRC__T_RC {63} \
   CONFIG.PSU__DDRC__T_RCD {10} \
   CONFIG.PSU__DDRC__T_RP {12} \
   CONFIG.PSU__DDRC__VENDOR_PART {OTHERS} \
   CONFIG.PSU__DDRC__VREF {0} \
   CONFIG.PSU__DDR_HIGH_ADDRESS_GUI_ENABLE {0} \
   CONFIG.PSU__DDR_QOS_ENABLE {1} \
   CONFIG.PSU__DDR_QOS_FIX_HP0_RDQOS {7} \
   CONFIG.PSU__DDR_QOS_FIX_HP0_WRQOS {15} \
   CONFIG.PSU__DDR_QOS_FIX_HP1_RDQOS {3} \
   CONFIG.PSU__DDR_QOS_FIX_HP1_WRQOS {3} \
   CONFIG.PSU__DDR_QOS_FIX_HP2_RDQOS {3} \
   CONFIG.PSU__DDR_QOS_FIX_HP2_WRQOS {3} \
   CONFIG.PSU__DDR_QOS_FIX_HP3_RDQOS {3} \
   CONFIG.PSU__DDR_QOS_FIX_HP3_WRQOS {3} \
   CONFIG.PSU__DDR_QOS_HP0_RDQOS {7} \
   CONFIG.PSU__DDR_QOS_HP0_WRQOS {15} \
   CONFIG.PSU__DDR_QOS_HP1_RDQOS {3} \
   CONFIG.PSU__DDR_QOS_HP1_WRQOS {3} \
   CONFIG.PSU__DDR_QOS_HP2_RDQOS {3} \
   CONFIG.PSU__DDR_QOS_HP2_WRQOS {3} \
   CONFIG.PSU__DDR_QOS_HP3_RDQOS {3} \
   CONFIG.PSU__DDR_QOS_HP3_WRQOS {3} \
   CONFIG.PSU__DDR_QOS_PORT0_TYPE {Low Latency} \
   CONFIG.PSU__DDR_QOS_PORT1_VN1_TYPE {Low Latency} \
   CONFIG.PSU__DDR_QOS_PORT1_VN2_TYPE {Best Effort} \
   CONFIG.PSU__DDR_QOS_PORT2_VN1_TYPE {Low Latency} \
   CONFIG.PSU__DDR_QOS_PORT2_VN2_TYPE {Best Effort} \
   CONFIG.PSU__DDR_QOS_PORT3_TYPE {Video Traffic} \
   CONFIG.PSU__DDR_QOS_PORT4_TYPE {Best Effort} \
   CONFIG.PSU__DDR_QOS_PORT5_TYPE {Best Effort} \
   CONFIG.PSU__DDR_QOS_RD_HPR_THRSHLD {0} \
   CONFIG.PSU__DDR_QOS_RD_LPR_THRSHLD {16} \
   CONFIG.PSU__DDR_QOS_WR_THRSHLD {16} \
   CONFIG.PSU__DDR__INTERFACE__FREQMHZ {266.500} \
   CONFIG.PSU__DISPLAYPORT__LANE0__ENABLE {1} \
   CONFIG.PSU__DISPLAYPORT__LANE0__IO {GT Lane3} \
   CONFIG.PSU__DISPLAYPORT__LANE1__ENABLE {1} \
   CONFIG.PSU__DISPLAYPORT__LANE1__IO {GT Lane2} \
   CONFIG.PSU__DISPLAYPORT__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__DLL__ISUSED {1} \
   CONFIG.PSU__DPAUX__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__DPAUX__PERIPHERAL__IO {MIO 27 .. 30} \
   CONFIG.PSU__DP__LANE_SEL {Dual Higher} \
   CONFIG.PSU__DP__REF_CLK_FREQ {27} \
   CONFIG.PSU__DP__REF_CLK_SEL {Ref Clk2} \
   CONFIG.PSU__ENET3__FIFO__ENABLE {0} \
   CONFIG.PSU__ENET3__GRP_MDIO__ENABLE {1} \
   CONFIG.PSU__ENET3__GRP_MDIO__IO {MIO 76 .. 77} \
   CONFIG.PSU__ENET3__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__ENET3__PERIPHERAL__IO {MIO 64 .. 75} \
   CONFIG.PSU__ENET3__PTP__ENABLE {0} \
   CONFIG.PSU__ENET3__TSU__ENABLE {0} \
   CONFIG.PSU__FPDMASTERS_COHERENCY {0} \
   CONFIG.PSU__FPD_SLCR__WDT1__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__FPD_SLCR__WDT1__FREQMHZ {99.999001} \
   CONFIG.PSU__FPD_SLCR__WDT_CLK_SEL__SELECT {APB} \
   CONFIG.PSU__FPGA_PL0_ENABLE {1} \
   CONFIG.PSU__FPGA_PL1_ENABLE {1} \
   CONFIG.PSU__FPGA_PL2_ENABLE {1} \
   CONFIG.PSU__GEM3_COHERENCY {0} \
   CONFIG.PSU__GEM3_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__GEM__TSU__ENABLE {0} \
   CONFIG.PSU__GPIO0_MIO__IO {MIO 0 .. 25} \
   CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__GPIO1_MIO__IO {MIO 26 .. 51} \
   CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__GPIO_EMIO_WIDTH {95} \
   CONFIG.PSU__GPIO_EMIO__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__GPIO_EMIO__PERIPHERAL__IO {95} \
   CONFIG.PSU__GT__LINK_SPEED {HBR} \
   CONFIG.PSU__GT__PRE_EMPH_LVL_4 {0} \
   CONFIG.PSU__GT__VLT_SWNG_LVL_4 {0} \
   CONFIG.PSU__HIGH_ADDRESS__ENABLE {0} \
   CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__I2C1__PERIPHERAL__IO {MIO 24 .. 25} \
   CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC0_SEL {APB} \
   CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC1_SEL {APB} \
   CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC2_SEL {APB} \
   CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC3_SEL {APB} \
   CONFIG.PSU__IOU_SLCR__TTC0__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC0__FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC1__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC1__FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC2__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC2__FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC3__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC3__FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__WDT0__ACT_FREQMHZ {99.999001} \
   CONFIG.PSU__IOU_SLCR__WDT0__FREQMHZ {99.999001} \
   CONFIG.PSU__IOU_SLCR__WDT_CLK_SEL__SELECT {APB} \
   CONFIG.PSU__MAXIGP2__DATA_WIDTH {32} \
   CONFIG.PSU__OVERRIDE__BASIC_CLOCK {0} \
   CONFIG.PSU__PCIE__BAR0_64BIT {0} \
   CONFIG.PSU__PCIE__BAR0_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR0_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR0_VAL {} \
   CONFIG.PSU__PCIE__BAR1_64BIT {0} \
   CONFIG.PSU__PCIE__BAR1_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR1_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR1_VAL {} \
   CONFIG.PSU__PCIE__BAR2_64BIT {0} \
   CONFIG.PSU__PCIE__BAR2_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR2_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR2_VAL {} \
   CONFIG.PSU__PCIE__BAR3_64BIT {0} \
   CONFIG.PSU__PCIE__BAR3_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR3_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR3_VAL {} \
   CONFIG.PSU__PCIE__BAR4_64BIT {0} \
   CONFIG.PSU__PCIE__BAR4_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR4_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR4_VAL {} \
   CONFIG.PSU__PCIE__BAR5_64BIT {0} \
   CONFIG.PSU__PCIE__BAR5_ENABLE {0} \
   CONFIG.PSU__PCIE__BAR5_PREFETCHABLE {0} \
   CONFIG.PSU__PCIE__BAR5_VAL {} \
   CONFIG.PSU__PCIE__CLASS_CODE_VALUE {} \
   CONFIG.PSU__PCIE__CRS_SW_VISIBILITY {0} \
   CONFIG.PSU__PCIE__EROM_ENABLE {0} \
   CONFIG.PSU__PCIE__EROM_VAL {} \
   CONFIG.PSU__PCIE__LANE0__ENABLE {0} \
   CONFIG.PSU__PCIE__LANE1__ENABLE {0} \
   CONFIG.PSU__PCIE__LANE2__ENABLE {0} \
   CONFIG.PSU__PCIE__LANE3__ENABLE {0} \
   CONFIG.PSU__PCIE__MSIX_BAR_INDICATOR {} \
   CONFIG.PSU__PCIE__MSIX_PBA_BAR_INDICATOR {} \
   CONFIG.PSU__PCIE__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__PCIE__PERIPHERAL__ENDPOINT_ENABLE {1} \
   CONFIG.PSU__PCIE__PERIPHERAL__ROOTPORT_ENABLE {0} \
   CONFIG.PSU__PL_CLK0_BUF {TRUE} \
   CONFIG.PSU__PL_CLK1_BUF {TRUE} \
   CONFIG.PSU__PL_CLK2_BUF {TRUE} \
   CONFIG.PSU__PROTECTION__MASTERS {USB1:NonSecure;0|USB0:NonSecure;1|S_AXI_LPD:NA;0|S_AXI_HPC1_FPD:NA;0|S_AXI_HPC0_FPD:NA;0|S_AXI_HP3_FPD:NA;0|S_AXI_HP2_FPD:NA;0|S_AXI_HP1_FPD:NA;1|S_AXI_HP0_FPD:NA;0|S_AXI_ACP:NA;0|S_AXI_ACE:NA;0|SD1:NonSecure;1|SD0:NonSecure;1|SATA1:NonSecure;1|SATA0:NonSecure;1|RPU1:Secure;1|RPU0:Secure;1|QSPI:NonSecure;0|PMU:NA;1|PCIe:NonSecure;0|NAND:NonSecure;0|LDMA:NonSecure;1|GPU:NonSecure;1|GEM3:NonSecure;1|GEM2:NonSecure;0|GEM1:NonSecure;0|GEM0:NonSecure;0|FDMA:NonSecure;1|DP:NonSecure;1|DAP:NA;1|Coresight:NA;1|CSU:NA;1|APU:NA;1} \
   CONFIG.PSU__PROTECTION__SLAVES {LPD;USB3_1_XHCI;FE300000;FE3FFFFF;0|LPD;USB3_1;FF9E0000;FF9EFFFF;0|LPD;USB3_0_XHCI;FE200000;FE2FFFFF;1|LPD;USB3_0;FF9D0000;FF9DFFFF;1|LPD;UART1;FF010000;FF01FFFF;1|LPD;UART0;FF000000;FF00FFFF;1|LPD;TTC3;FF140000;FF14FFFF;1|LPD;TTC2;FF130000;FF13FFFF;1|LPD;TTC1;FF120000;FF12FFFF;1|LPD;TTC0;FF110000;FF11FFFF;1|FPD;SWDT1;FD4D0000;FD4DFFFF;1|LPD;SWDT0;FF150000;FF15FFFF;1|LPD;SPI1;FF050000;FF05FFFF;1|LPD;SPI0;FF040000;FF04FFFF;1|FPD;SMMU_REG;FD5F0000;FD5FFFFF;1|FPD;SMMU;FD800000;FDFFFFFF;1|FPD;SIOU;FD3D0000;FD3DFFFF;1|FPD;SERDES;FD400000;FD47FFFF;1|LPD;SD1;FF170000;FF17FFFF;1|LPD;SD0;FF160000;FF16FFFF;1|FPD;SATA;FD0C0000;FD0CFFFF;1|LPD;RTC;FFA60000;FFA6FFFF;1|LPD;RSA_CORE;FFCE0000;FFCEFFFF;1|LPD;RPU;FF9A0000;FF9AFFFF;1|LPD;R5_TCM_RAM_GLOBAL;FFE00000;FFE3FFFF;1|LPD;R5_1_Instruction_Cache;FFEC0000;FFECFFFF;1|LPD;R5_1_Data_Cache;FFED0000;FFEDFFFF;1|LPD;R5_1_BTCM_GLOBAL;FFEB0000;FFEBFFFF;1|LPD;R5_1_ATCM_GLOBAL;FFE90000;FFE9FFFF;1|LPD;R5_0_Instruction_Cache;FFE40000;FFE4FFFF;1|LPD;R5_0_Data_Cache;FFE50000;FFE5FFFF;1|LPD;R5_0_BTCM_GLOBAL;FFE20000;FFE2FFFF;1|LPD;R5_0_ATCM_GLOBAL;FFE00000;FFE0FFFF;1|LPD;QSPI_Linear_Address;C0000000;DFFFFFFF;1|LPD;QSPI;FF0F0000;FF0FFFFF;0|LPD;PMU_RAM;FFDC0000;FFDDFFFF;1|LPD;PMU_GLOBAL;FFD80000;FFDBFFFF;1|FPD;PCIE_MAIN;FD0E0000;FD0EFFFF;0|FPD;PCIE_LOW;E0000000;EFFFFFFF;0|FPD;PCIE_HIGH2;8000000000;BFFFFFFFFF;0|FPD;PCIE_HIGH1;600000000;7FFFFFFFF;0|FPD;PCIE_DMA;FD0F0000;FD0FFFFF;0|FPD;PCIE_ATTRIB;FD480000;FD48FFFF;0|LPD;OCM_XMPU_CFG;FFA70000;FFA7FFFF;1|LPD;OCM_SLCR;FF960000;FF96FFFF;1|OCM;OCM;FFFC0000;FFFFFFFF;1|LPD;NAND;FF100000;FF10FFFF;0|LPD;MBISTJTAG;FFCF0000;FFCFFFFF;1|LPD;LPD_XPPU_SINK;FF9C0000;FF9CFFFF;1|LPD;LPD_XPPU;FF980000;FF98FFFF;1|LPD;LPD_SLCR_SECURE;FF4B0000;FF4DFFFF;1|LPD;LPD_SLCR;FF410000;FF4AFFFF;1|LPD;LPD_GPV;FE100000;FE1FFFFF;1|LPD;LPD_DMA_7;FFAF0000;FFAFFFFF;1|LPD;LPD_DMA_6;FFAE0000;FFAEFFFF;1|LPD;LPD_DMA_5;FFAD0000;FFADFFFF;1|LPD;LPD_DMA_4;FFAC0000;FFACFFFF;1|LPD;LPD_DMA_3;FFAB0000;FFABFFFF;1|LPD;LPD_DMA_2;FFAA0000;FFAAFFFF;1|LPD;LPD_DMA_1;FFA90000;FFA9FFFF;1|LPD;LPD_DMA_0;FFA80000;FFA8FFFF;1|LPD;IPI_CTRL;FF380000;FF3FFFFF;1|LPD;IOU_SLCR;FF180000;FF23FFFF;1|LPD;IOU_SECURE_SLCR;FF240000;FF24FFFF;1|LPD;IOU_SCNTRS;FF260000;FF26FFFF;1|LPD;IOU_SCNTR;FF250000;FF25FFFF;1|LPD;IOU_GPV;FE000000;FE0FFFFF;1|LPD;I2C1;FF030000;FF03FFFF;1|LPD;I2C0;FF020000;FF02FFFF;0|FPD;GPU;FD4B0000;FD4BFFFF;0|LPD;GPIO;FF0A0000;FF0AFFFF;1|LPD;GEM3;FF0E0000;FF0EFFFF;1|LPD;GEM2;FF0D0000;FF0DFFFF;0|LPD;GEM1;FF0C0000;FF0CFFFF;0|LPD;GEM0;FF0B0000;FF0BFFFF;0|FPD;FPD_XMPU_SINK;FD4F0000;FD4FFFFF;1|FPD;FPD_XMPU_CFG;FD5D0000;FD5DFFFF;1|FPD;FPD_SLCR_SECURE;FD690000;FD6CFFFF;1|FPD;FPD_SLCR;FD610000;FD68FFFF;1|FPD;FPD_GPV;FD700000;FD7FFFFF;1|FPD;FPD_DMA_CH7;FD570000;FD57FFFF;1|FPD;FPD_DMA_CH6;FD560000;FD56FFFF;1|FPD;FPD_DMA_CH5;FD550000;FD55FFFF;1|FPD;FPD_DMA_CH4;FD540000;FD54FFFF;1|FPD;FPD_DMA_CH3;FD530000;FD53FFFF;1|FPD;FPD_DMA_CH2;FD520000;FD52FFFF;1|FPD;FPD_DMA_CH1;FD510000;FD51FFFF;1|FPD;FPD_DMA_CH0;FD500000;FD50FFFF;1|LPD;EFUSE;FFCC0000;FFCCFFFF;1|FPD;Display Port;FD4A0000;FD4AFFFF;1|FPD;DPDMA;FD4C0000;FD4CFFFF;1|FPD;DDR_XMPU5_CFG;FD050000;FD05FFFF;1|FPD;DDR_XMPU4_CFG;FD040000;FD04FFFF;1|FPD;DDR_XMPU3_CFG;FD030000;FD03FFFF;1|FPD;DDR_XMPU2_CFG;FD020000;FD02FFFF;1|FPD;DDR_XMPU1_CFG;FD010000;FD01FFFF;1|FPD;DDR_XMPU0_CFG;FD000000;FD00FFFF;1|FPD;DDR_QOS_CTRL;FD090000;FD09FFFF;1|FPD;DDR_PHY;FD080000;FD08FFFF;1|DDR;DDR_LOW;0;7FFFFFFF;1|DDR;DDR_HIGH;800000000;800000000;0|FPD;DDDR_CTRL;FD070000;FD070FFF;1|LPD;Coresight;FE800000;FEFFFFFF;1|LPD;CSU_DMA;FFC80000;FFC9FFFF;1|LPD;CSU;FFCA0000;FFCAFFFF;0|LPD;CRL_APB;FF5E0000;FF85FFFF;1|FPD;CRF_APB;FD1A0000;FD2DFFFF;1|FPD;CCI_REG;FD5E0000;FD5EFFFF;1|FPD;CCI_GPV;FD6E0000;FD6EFFFF;1|LPD;CAN1;FF070000;FF07FFFF;0|LPD;CAN0;FF060000;FF06FFFF;0|FPD;APU;FD5C0000;FD5CFFFF;1|LPD;APM_INTC_IOU;FFA20000;FFA2FFFF;1|LPD;APM_FPD_LPD;FFA30000;FFA3FFFF;1|FPD;APM_5;FD490000;FD49FFFF;1|FPD;APM_0;FD0B0000;FD0BFFFF;1|LPD;APM2;FFA10000;FFA1FFFF;1|LPD;APM1;FFA00000;FFA0FFFF;1|LPD;AMS;FFA50000;FFA5FFFF;1|FPD;AFI_5;FD3B0000;FD3BFFFF;1|FPD;AFI_4;FD3A0000;FD3AFFFF;1|FPD;AFI_3;FD390000;FD39FFFF;1|FPD;AFI_2;FD380000;FD38FFFF;1|FPD;AFI_1;FD370000;FD37FFFF;1|FPD;AFI_0;FD360000;FD36FFFF;1|LPD;AFIFM6;FF9B0000;FF9BFFFF;1|FPD;ACPU_GIC;F9010000;F907FFFF;1} \
   CONFIG.PSU__PSS_REF_CLK__FREQMHZ {33.333} \
   CONFIG.PSU__QSPI_COHERENCY {0} \
   CONFIG.PSU__QSPI_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {0} \
   CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__SATA__LANE0__ENABLE {0} \
   CONFIG.PSU__SATA__LANE1__ENABLE {1} \
   CONFIG.PSU__SATA__LANE1__IO {GT Lane1} \
   CONFIG.PSU__SATA__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SATA__REF_CLK_FREQ {125} \
   CONFIG.PSU__SATA__REF_CLK_SEL {Ref Clk1} \
   CONFIG.PSU__SAXIGP3__DATA_WIDTH {128} \
   CONFIG.PSU__SD0_COHERENCY {0} \
   CONFIG.PSU__SD0_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__SD0__DATA_TRANSFER_MODE {8Bit} \
   CONFIG.PSU__SD0__GRP_CD__ENABLE {0} \
   CONFIG.PSU__SD0__GRP_POW__ENABLE {0} \
   CONFIG.PSU__SD0__GRP_WP__ENABLE {0} \
   CONFIG.PSU__SD0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SD0__PERIPHERAL__IO {MIO 13 .. 22} \
   CONFIG.PSU__SD0__SLOT_TYPE {eMMC} \
   CONFIG.PSU__SD1_COHERENCY {0} \
   CONFIG.PSU__SD1_ROUTE_THROUGH_FPD {0} \
   CONFIG.PSU__SD1__DATA_TRANSFER_MODE {4Bit} \
   CONFIG.PSU__SD1__GRP_CD__ENABLE {1} \
   CONFIG.PSU__SD1__GRP_CD__IO {MIO 45} \
   CONFIG.PSU__SD1__GRP_POW__ENABLE {0} \
   CONFIG.PSU__SD1__GRP_WP__ENABLE {0} \
   CONFIG.PSU__SD1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SD1__PERIPHERAL__IO {MIO 46 .. 51} \
   CONFIG.PSU__SD1__RESET__ENABLE {0} \
   CONFIG.PSU__SD1__SLOT_TYPE {SD 2.0} \
   CONFIG.PSU__SPI0__GRP_SS0__ENABLE {1} \
   CONFIG.PSU__SPI0__GRP_SS0__IO {EMIO} \
   CONFIG.PSU__SPI0__GRP_SS1__ENABLE {1} \
   CONFIG.PSU__SPI0__GRP_SS1__IO {EMIO} \
   CONFIG.PSU__SPI0__GRP_SS2__ENABLE {1} \
   CONFIG.PSU__SPI0__GRP_SS2__IO {EMIO} \
   CONFIG.PSU__SPI0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SPI0__PERIPHERAL__IO {EMIO} \
   CONFIG.PSU__SPI1__GRP_SS0__ENABLE {1} \
   CONFIG.PSU__SPI1__GRP_SS0__IO {EMIO} \
   CONFIG.PSU__SPI1__GRP_SS1__ENABLE {1} \
   CONFIG.PSU__SPI1__GRP_SS1__IO {EMIO} \
   CONFIG.PSU__SPI1__GRP_SS2__ENABLE {1} \
   CONFIG.PSU__SPI1__GRP_SS2__IO {EMIO} \
   CONFIG.PSU__SPI1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SPI1__PERIPHERAL__IO {EMIO} \
   CONFIG.PSU__SWDT0__CLOCK__ENABLE {0} \
   CONFIG.PSU__SWDT0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SWDT0__RESET__ENABLE {0} \
   CONFIG.PSU__SWDT1__CLOCK__ENABLE {0} \
   CONFIG.PSU__SWDT1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SWDT1__RESET__ENABLE {0} \
   CONFIG.PSU__TSU__BUFG_PORT_PAIR {0} \
   CONFIG.PSU__TTC0__CLOCK__ENABLE {0} \
   CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__TTC0__WAVEOUT__ENABLE {0} \
   CONFIG.PSU__TTC1__CLOCK__ENABLE {0} \
   CONFIG.PSU__TTC1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__TTC1__WAVEOUT__ENABLE {0} \
   CONFIG.PSU__TTC2__CLOCK__ENABLE {0} \
   CONFIG.PSU__TTC2__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__TTC2__WAVEOUT__ENABLE {0} \
   CONFIG.PSU__TTC3__CLOCK__ENABLE {0} \
   CONFIG.PSU__TTC3__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__TTC3__WAVEOUT__ENABLE {0} \
   CONFIG.PSU__UART0__BAUD_RATE {115200} \
   CONFIG.PSU__UART0__MODEM__ENABLE {0} \
   CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 10 .. 11} \
   CONFIG.PSU__UART1__BAUD_RATE {115200} \
   CONFIG.PSU__UART1__MODEM__ENABLE {0} \
   CONFIG.PSU__UART1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__UART1__PERIPHERAL__IO {MIO 8 .. 9} \
   CONFIG.PSU__USB0_COHERENCY {0} \
   CONFIG.PSU__USB0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__USB0__PERIPHERAL__IO {MIO 52 .. 63} \
   CONFIG.PSU__USB0__REF_CLK_FREQ {52} \
   CONFIG.PSU__USB0__REF_CLK_SEL {Ref Clk0} \
   CONFIG.PSU__USB0__RESET__ENABLE {0} \
   CONFIG.PSU__USB1__RESET__ENABLE {0} \
   CONFIG.PSU__USB2_0__EMIO__ENABLE {0} \
   CONFIG.PSU__USB3_0__EMIO__ENABLE {1} \
   CONFIG.PSU__USB3_0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__USB3_0__PERIPHERAL__IO {GT Lane0} \
   CONFIG.PSU__USB__RESET__MODE {Boot Pin} \
   CONFIG.PSU__USB__RESET__POLARITY {Active Low} \
   CONFIG.PSU__USE__IRQ0 {1} \
   CONFIG.PSU__USE__IRQ1 {1} \
   CONFIG.PSU__USE__M_AXI_GP0 {0} \
   CONFIG.PSU__USE__M_AXI_GP1 {0} \
   CONFIG.PSU__USE__M_AXI_GP2 {1} \
   CONFIG.PSU__USE__S_AXI_GP3 {1} \
   CONFIG.SUBPRESET1 {Custom} \
 ] $sys_ps8

  # Create instance: sys_rstgen, and set properties
  set sys_rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_rstgen ]
  set_property -dict [ list \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $sys_rstgen

  # Create instance: util_adc_1_pack, and set properties
  set util_adc_1_pack [ create_bd_cell -type ip -vlnv analog.com:user:util_cpack2:1.0 util_adc_1_pack ]
  set_property -dict [ list \
   CONFIG.NUM_OF_CHANNELS {4} \
   CONFIG.SAMPLE_DATA_WIDTH {16} \
 ] $util_adc_1_pack

  # Create instance: util_adc_2_pack, and set properties
  set util_adc_2_pack [ create_bd_cell -type ip -vlnv analog.com:user:util_cpack2:1.0 util_adc_2_pack ]
  set_property -dict [ list \
   CONFIG.NUM_OF_CHANNELS {2} \
   CONFIG.SAMPLE_DATA_WIDTH {16} \
 ] $util_adc_2_pack

  # Create instance: util_dac_1_upack, and set properties
  set util_dac_1_upack [ create_bd_cell -type ip -vlnv analog.com:user:util_upack2:1.0 util_dac_1_upack ]
  set_property -dict [ list \
   CONFIG.NUM_OF_CHANNELS {4} \
   CONFIG.SAMPLE_DATA_WIDTH {16} \
 ] $util_dac_1_upack

  # Create instance: util_dac_2_upack, and set properties
  set util_dac_2_upack [ create_bd_cell -type ip -vlnv analog.com:user:util_upack2:1.0 util_dac_2_upack ]
  set_property -dict [ list \
   CONFIG.NUM_OF_CHANNELS {2} \
   CONFIG.SAMPLE_DATA_WIDTH {16} \
 ] $util_dac_2_upack

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins axi_cpu_interconnect/S00_AXI] [get_bd_intf_pins sys_ps8/M_AXI_HPM0_LPD]
  connect_bd_intf_net -intf_net axi_adrv9001_rx1_dma_m_dest_axi [get_bd_intf_pins axi_adrv9001_rx1_dma/m_dest_axi] [get_bd_intf_pins axi_hp1_interconnect/S00_AXI]
  connect_bd_intf_net -intf_net axi_adrv9001_rx2_dma_m_dest_axi [get_bd_intf_pins axi_adrv9001_rx2_dma/m_dest_axi] [get_bd_intf_pins axi_hp1_interconnect/S01_AXI]
  connect_bd_intf_net -intf_net axi_adrv9001_tx1_dma_m_axis [get_bd_intf_pins axi_adrv9001_tx1_dma/m_axis] [get_bd_intf_pins util_dac_1_upack/s_axis]
  connect_bd_intf_net -intf_net axi_adrv9001_tx1_dma_m_src_axi [get_bd_intf_pins axi_adrv9001_tx1_dma/m_src_axi] [get_bd_intf_pins axi_hp1_interconnect/S02_AXI]
  connect_bd_intf_net -intf_net axi_adrv9001_tx2_dma_m_axis [get_bd_intf_pins axi_adrv9001_tx2_dma/m_axis] [get_bd_intf_pins util_dac_2_upack/s_axis]
  connect_bd_intf_net -intf_net axi_adrv9001_tx2_dma_m_src_axi [get_bd_intf_pins axi_adrv9001_tx2_dma/m_src_axi] [get_bd_intf_pins axi_hp1_interconnect/S03_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M00_AXI [get_bd_intf_pins axi_cpu_interconnect/M00_AXI] [get_bd_intf_pins axi_sysid_0/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M01_AXI [get_bd_intf_pins axi_adrv9001/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M01_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M02_AXI [get_bd_intf_pins axi_adrv9001_rx1_dma/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M02_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M03_AXI [get_bd_intf_pins axi_adrv9001_rx2_dma/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M03_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M04_AXI [get_bd_intf_pins axi_adrv9001_tx1_dma/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M04_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M05_AXI [get_bd_intf_pins axi_adrv9001_tx2_dma/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M05_AXI]
  connect_bd_intf_net -intf_net axi_hp1_interconnect_M00_AXI [get_bd_intf_pins axi_hp1_interconnect/M00_AXI] [get_bd_intf_pins sys_ps8/S_AXI_HP1_FPD]
  connect_bd_intf_net -intf_net util_adc_1_pack_packed_fifo_wr [get_bd_intf_pins axi_adrv9001_rx1_dma/fifo_wr] [get_bd_intf_pins util_adc_1_pack/packed_fifo_wr]
  connect_bd_intf_net -intf_net util_adc_2_pack_packed_fifo_wr [get_bd_intf_pins axi_adrv9001_rx2_dma/fifo_wr] [get_bd_intf_pins util_adc_2_pack/packed_fifo_wr]

  # Create port connections
  connect_bd_net -net GND_1_dout [get_bd_pins GND_1/dout] [get_bd_pins sys_concat_intc_0/In0] [get_bd_pins sys_concat_intc_0/In1] [get_bd_pins sys_concat_intc_0/In2] [get_bd_pins sys_concat_intc_0/In3] [get_bd_pins sys_concat_intc_0/In4] [get_bd_pins sys_concat_intc_0/In5] [get_bd_pins sys_concat_intc_0/In6] [get_bd_pins sys_concat_intc_0/In7] [get_bd_pins sys_concat_intc_1/In0] [get_bd_pins sys_concat_intc_1/In1] [get_bd_pins sys_concat_intc_1/In6] [get_bd_pins sys_concat_intc_1/In7] [get_bd_pins sys_ps8/emio_spi0_s_i] [get_bd_pins sys_ps8/emio_spi0_sclk_i] [get_bd_pins sys_ps8/emio_spi1_s_i] [get_bd_pins sys_ps8/emio_spi1_sclk_i]
  connect_bd_net -net VCC_1_dout [get_bd_pins VCC_1/dout] [get_bd_pins sys_ps8/emio_spi0_ss_i_n] [get_bd_pins sys_ps8/emio_spi1_ss_i_n]
  connect_bd_net -net axi_adrv9001_adc_1_clk [get_bd_pins axi_adrv9001/adc_1_clk] [get_bd_pins axi_adrv9001_rx1_dma/fifo_wr_clk] [get_bd_pins util_adc_1_pack/clk]
  connect_bd_net -net axi_adrv9001_adc_1_data_i0 [get_bd_pins axi_adrv9001/adc_1_data_i0] [get_bd_pins util_adc_1_pack/fifo_wr_data_0]
  connect_bd_net -net axi_adrv9001_adc_1_data_i1 [get_bd_pins axi_adrv9001/adc_1_data_i1] [get_bd_pins util_adc_1_pack/fifo_wr_data_2]
  connect_bd_net -net axi_adrv9001_adc_1_data_q0 [get_bd_pins axi_adrv9001/adc_1_data_q0] [get_bd_pins util_adc_1_pack/fifo_wr_data_1]
  connect_bd_net -net axi_adrv9001_adc_1_data_q1 [get_bd_pins axi_adrv9001/adc_1_data_q1] [get_bd_pins util_adc_1_pack/fifo_wr_data_3]
  connect_bd_net -net axi_adrv9001_adc_1_enable_i0 [get_bd_pins axi_adrv9001/adc_1_enable_i0] [get_bd_pins util_adc_1_pack/enable_0]
  connect_bd_net -net axi_adrv9001_adc_1_enable_i1 [get_bd_pins axi_adrv9001/adc_1_enable_i1] [get_bd_pins util_adc_1_pack/enable_2]
  connect_bd_net -net axi_adrv9001_adc_1_enable_q0 [get_bd_pins axi_adrv9001/adc_1_enable_q0] [get_bd_pins util_adc_1_pack/enable_1]
  connect_bd_net -net axi_adrv9001_adc_1_enable_q1 [get_bd_pins axi_adrv9001/adc_1_enable_q1] [get_bd_pins util_adc_1_pack/enable_3]
  connect_bd_net -net axi_adrv9001_adc_1_rst [get_bd_pins axi_adrv9001/adc_1_rst] [get_bd_pins util_adc_1_pack/reset]
  connect_bd_net -net axi_adrv9001_adc_1_valid_i0 [get_bd_pins axi_adrv9001/adc_1_valid_i0] [get_bd_pins util_adc_1_pack/fifo_wr_en]
  connect_bd_net -net axi_adrv9001_adc_2_clk [get_bd_pins axi_adrv9001/adc_2_clk] [get_bd_pins axi_adrv9001_rx2_dma/fifo_wr_clk] [get_bd_pins util_adc_2_pack/clk]
  connect_bd_net -net axi_adrv9001_adc_2_data_i0 [get_bd_pins axi_adrv9001/adc_2_data_i0] [get_bd_pins util_adc_2_pack/fifo_wr_data_0]
  connect_bd_net -net axi_adrv9001_adc_2_data_q0 [get_bd_pins axi_adrv9001/adc_2_data_q0] [get_bd_pins util_adc_2_pack/fifo_wr_data_1]
  connect_bd_net -net axi_adrv9001_adc_2_enable_i0 [get_bd_pins axi_adrv9001/adc_2_enable_i0] [get_bd_pins util_adc_2_pack/enable_0]
  connect_bd_net -net axi_adrv9001_adc_2_enable_q0 [get_bd_pins axi_adrv9001/adc_2_enable_q0] [get_bd_pins util_adc_2_pack/enable_1]
  connect_bd_net -net axi_adrv9001_adc_2_rst [get_bd_pins axi_adrv9001/adc_2_rst] [get_bd_pins util_adc_2_pack/reset]
  connect_bd_net -net axi_adrv9001_adc_2_valid_i0 [get_bd_pins axi_adrv9001/adc_2_valid_i0] [get_bd_pins util_adc_2_pack/fifo_wr_en]
  connect_bd_net -net axi_adrv9001_dac_1_clk [get_bd_pins axi_adrv9001/dac_1_clk] [get_bd_pins axi_adrv9001_tx1_dma/m_axis_aclk] [get_bd_pins util_dac_1_upack/clk]
  connect_bd_net -net axi_adrv9001_dac_1_enable_i0 [get_bd_pins axi_adrv9001/dac_1_enable_i0] [get_bd_pins util_dac_1_upack/enable_0]
  connect_bd_net -net axi_adrv9001_dac_1_enable_i1 [get_bd_pins axi_adrv9001/dac_1_enable_i1] [get_bd_pins util_dac_1_upack/enable_2]
  connect_bd_net -net axi_adrv9001_dac_1_enable_q0 [get_bd_pins axi_adrv9001/dac_1_enable_q0] [get_bd_pins util_dac_1_upack/enable_1]
  connect_bd_net -net axi_adrv9001_dac_1_enable_q1 [get_bd_pins axi_adrv9001/dac_1_enable_q1] [get_bd_pins util_dac_1_upack/enable_3]
  connect_bd_net -net axi_adrv9001_dac_1_rst [get_bd_pins axi_adrv9001/dac_1_rst] [get_bd_pins util_dac_1_upack/reset]
  connect_bd_net -net axi_adrv9001_dac_1_valid_i0 [get_bd_pins axi_adrv9001/dac_1_valid_i0] [get_bd_pins util_dac_1_upack/fifo_rd_en]
  connect_bd_net -net axi_adrv9001_dac_2_clk [get_bd_pins axi_adrv9001/dac_2_clk] [get_bd_pins axi_adrv9001_tx2_dma/m_axis_aclk] [get_bd_pins util_dac_2_upack/clk]
  connect_bd_net -net axi_adrv9001_dac_2_enable_i0 [get_bd_pins axi_adrv9001/dac_2_enable_i0] [get_bd_pins util_dac_2_upack/enable_0]
  connect_bd_net -net axi_adrv9001_dac_2_enable_q0 [get_bd_pins axi_adrv9001/dac_2_enable_q0] [get_bd_pins util_dac_2_upack/enable_1]
  connect_bd_net -net axi_adrv9001_dac_2_rst [get_bd_pins axi_adrv9001/dac_2_rst] [get_bd_pins util_dac_2_upack/reset]
  connect_bd_net -net axi_adrv9001_dac_2_valid_i0 [get_bd_pins axi_adrv9001/dac_2_valid_i0] [get_bd_pins util_dac_2_upack/fifo_rd_en]
  connect_bd_net -net axi_adrv9001_rx1_dma_irq [get_bd_pins axi_adrv9001_rx1_dma/irq] [get_bd_pins sys_concat_intc_1/In5]
  connect_bd_net -net axi_adrv9001_rx1_enable [get_bd_ports rx1_enable] [get_bd_pins axi_adrv9001/rx1_enable]
  connect_bd_net -net axi_adrv9001_rx2_dma_irq [get_bd_pins axi_adrv9001_rx2_dma/irq] [get_bd_pins sys_concat_intc_1/In4]
  connect_bd_net -net axi_adrv9001_rx2_enable [get_bd_ports rx2_enable] [get_bd_pins axi_adrv9001/rx2_enable]
  connect_bd_net -net axi_adrv9001_tdd_sync_cntr [get_bd_ports tdd_sync_cntr] [get_bd_pins axi_adrv9001/tdd_sync_cntr]
  connect_bd_net -net axi_adrv9001_tx1_dclk_out_n_NC [get_bd_ports tx1_dclk_out_n] [get_bd_pins axi_adrv9001/tx1_dclk_out_n_NC]
  connect_bd_net -net axi_adrv9001_tx1_dclk_out_p_dclk_out [get_bd_ports tx1_dclk_out_p] [get_bd_pins axi_adrv9001/tx1_dclk_out_p_dclk_out]
  connect_bd_net -net axi_adrv9001_tx1_dma_irq [get_bd_pins axi_adrv9001_tx1_dma/irq] [get_bd_pins sys_concat_intc_1/In3]
  connect_bd_net -net axi_adrv9001_tx1_enable [get_bd_ports tx1_enable] [get_bd_pins axi_adrv9001/tx1_enable]
  connect_bd_net -net axi_adrv9001_tx1_idata_out_n_idata0 [get_bd_ports tx1_idata_out_n] [get_bd_pins axi_adrv9001/tx1_idata_out_n_idata0]
  connect_bd_net -net axi_adrv9001_tx1_idata_out_p_idata1 [get_bd_ports tx1_idata_out_p] [get_bd_pins axi_adrv9001/tx1_idata_out_p_idata1]
  connect_bd_net -net axi_adrv9001_tx1_qdata_out_n_qdata2 [get_bd_ports tx1_qdata_out_n] [get_bd_pins axi_adrv9001/tx1_qdata_out_n_qdata2]
  connect_bd_net -net axi_adrv9001_tx1_qdata_out_p_qdata3 [get_bd_ports tx1_qdata_out_p] [get_bd_pins axi_adrv9001/tx1_qdata_out_p_qdata3]
  connect_bd_net -net axi_adrv9001_tx1_strobe_out_n_NC [get_bd_ports tx1_strobe_out_n] [get_bd_pins axi_adrv9001/tx1_strobe_out_n_NC]
  connect_bd_net -net axi_adrv9001_tx1_strobe_out_p_strobe_out [get_bd_ports tx1_strobe_out_p] [get_bd_pins axi_adrv9001/tx1_strobe_out_p_strobe_out]
  connect_bd_net -net axi_adrv9001_tx2_dclk_out_n_NC [get_bd_ports tx2_dclk_out_n] [get_bd_pins axi_adrv9001/tx2_dclk_out_n_NC]
  connect_bd_net -net axi_adrv9001_tx2_dclk_out_p_dclk_out [get_bd_ports tx2_dclk_out_p] [get_bd_pins axi_adrv9001/tx2_dclk_out_p_dclk_out]
  connect_bd_net -net axi_adrv9001_tx2_dma_irq [get_bd_pins axi_adrv9001_tx2_dma/irq] [get_bd_pins sys_concat_intc_1/In2]
  connect_bd_net -net axi_adrv9001_tx2_enable [get_bd_ports tx2_enable] [get_bd_pins axi_adrv9001/tx2_enable]
  connect_bd_net -net axi_adrv9001_tx2_idata_out_n_idata0 [get_bd_ports tx2_idata_out_n] [get_bd_pins axi_adrv9001/tx2_idata_out_n_idata0]
  connect_bd_net -net axi_adrv9001_tx2_idata_out_p_idata1 [get_bd_ports tx2_idata_out_p] [get_bd_pins axi_adrv9001/tx2_idata_out_p_idata1]
  connect_bd_net -net axi_adrv9001_tx2_qdata_out_n_qdata2 [get_bd_ports tx2_qdata_out_n] [get_bd_pins axi_adrv9001/tx2_qdata_out_n_qdata2]
  connect_bd_net -net axi_adrv9001_tx2_qdata_out_p_qdata3 [get_bd_ports tx2_qdata_out_p] [get_bd_pins axi_adrv9001/tx2_qdata_out_p_qdata3]
  connect_bd_net -net axi_adrv9001_tx2_strobe_out_n_NC [get_bd_ports tx2_strobe_out_n] [get_bd_pins axi_adrv9001/tx2_strobe_out_n_NC]
  connect_bd_net -net axi_adrv9001_tx2_strobe_out_p_strobe_out [get_bd_ports tx2_strobe_out_p] [get_bd_pins axi_adrv9001/tx2_strobe_out_p_strobe_out]
  connect_bd_net -net axi_sysid_0_rom_addr [get_bd_pins axi_sysid_0/rom_addr] [get_bd_pins rom_sys_0/rom_addr]
  connect_bd_net -net clk_wiz_0_clk_out1 [get_bd_pins axi_adrv9001/ref_clk] [get_bd_pins clk_wiz_0/clk_out1]
  connect_bd_net -net gpio_i_1 [get_bd_ports gpio_i] [get_bd_pins sys_ps8/emio_gpio_i]
  connect_bd_net -net gpio_rx1_enable_in_1 [get_bd_ports gpio_rx1_enable_in] [get_bd_pins axi_adrv9001/gpio_rx1_enable_in]
  connect_bd_net -net gpio_rx2_enable_in_1 [get_bd_ports gpio_rx2_enable_in] [get_bd_pins axi_adrv9001/gpio_rx2_enable_in]
  connect_bd_net -net gpio_tx1_enable_in_1 [get_bd_ports gpio_tx1_enable_in] [get_bd_pins axi_adrv9001/gpio_tx1_enable_in]
  connect_bd_net -net gpio_tx2_enable_in_1 [get_bd_ports gpio_tx2_enable_in] [get_bd_pins axi_adrv9001/gpio_tx2_enable_in]
  connect_bd_net -net mssi_sync_1 [get_bd_ports mssi_sync] [get_bd_pins axi_adrv9001/mssi_sync]
  connect_bd_net -net rom_sys_0_rom_data [get_bd_pins axi_sysid_0/sys_rom_data] [get_bd_pins rom_sys_0/rom_data]
  connect_bd_net -net rx1_dclk_in_n_1 [get_bd_ports rx1_dclk_in_n] [get_bd_pins axi_adrv9001/rx1_dclk_in_n_NC]
  connect_bd_net -net rx1_dclk_in_p_1 [get_bd_ports rx1_dclk_in_p] [get_bd_pins axi_adrv9001/rx1_dclk_in_p_dclk_in]
  connect_bd_net -net rx1_idata_in_n_1 [get_bd_ports rx1_idata_in_n] [get_bd_pins axi_adrv9001/rx1_idata_in_n_idata0]
  connect_bd_net -net rx1_idata_in_p_1 [get_bd_ports rx1_idata_in_p] [get_bd_pins axi_adrv9001/rx1_idata_in_p_idata1]
  connect_bd_net -net rx1_qdata_in_n_1 [get_bd_ports rx1_qdata_in_n] [get_bd_pins axi_adrv9001/rx1_qdata_in_n_qdata2]
  connect_bd_net -net rx1_qdata_in_p_1 [get_bd_ports rx1_qdata_in_p] [get_bd_pins axi_adrv9001/rx1_qdata_in_p_qdata3]
  connect_bd_net -net rx1_strobe_in_n_1 [get_bd_ports rx1_strobe_in_n] [get_bd_pins axi_adrv9001/rx1_strobe_in_n_NC]
  connect_bd_net -net rx1_strobe_in_p_1 [get_bd_ports rx1_strobe_in_p] [get_bd_pins axi_adrv9001/rx1_strobe_in_p_strobe_in]
  connect_bd_net -net rx2_dclk_in_n_1 [get_bd_ports rx2_dclk_in_n] [get_bd_pins axi_adrv9001/rx2_dclk_in_n_NC]
  connect_bd_net -net rx2_dclk_in_p_1 [get_bd_ports rx2_dclk_in_p] [get_bd_pins axi_adrv9001/rx2_dclk_in_p_dclk_in]
  connect_bd_net -net rx2_idata_in_n_1 [get_bd_ports rx2_idata_in_n] [get_bd_pins axi_adrv9001/rx2_idata_in_n_idata0]
  connect_bd_net -net rx2_idata_in_p_1 [get_bd_ports rx2_idata_in_p] [get_bd_pins axi_adrv9001/rx2_idata_in_p_idata1]
  connect_bd_net -net rx2_qdata_in_n_1 [get_bd_ports rx2_qdata_in_n] [get_bd_pins axi_adrv9001/rx2_qdata_in_n_qdata2]
  connect_bd_net -net rx2_qdata_in_p_1 [get_bd_ports rx2_qdata_in_p] [get_bd_pins axi_adrv9001/rx2_qdata_in_p_qdata3]
  connect_bd_net -net rx2_strobe_in_n_1 [get_bd_ports rx2_strobe_in_n] [get_bd_pins axi_adrv9001/rx2_strobe_in_n_NC]
  connect_bd_net -net rx2_strobe_in_p_1 [get_bd_ports rx2_strobe_in_p] [get_bd_pins axi_adrv9001/rx2_strobe_in_p_strobe_in]
  connect_bd_net -net spi0_csn_concat_dout [get_bd_ports spi0_csn] [get_bd_pins spi0_csn_concat/dout]
  connect_bd_net -net spi0_miso_1 [get_bd_ports spi0_miso] [get_bd_pins sys_ps8/emio_spi0_m_i]
  connect_bd_net -net spi1_csn_concat_dout [get_bd_ports spi1_csn] [get_bd_pins spi1_csn_concat/dout]
  connect_bd_net -net spi1_miso_1 [get_bd_ports spi1_miso] [get_bd_pins sys_ps8/emio_spi1_m_i]
  connect_bd_net -net sys_250m_clk [get_bd_pins sys_250m_rstgen/slowest_sync_clk] [get_bd_pins sys_ps8/pl_clk1]
  connect_bd_net -net sys_250m_reset [get_bd_pins sys_250m_rstgen/peripheral_reset]
  connect_bd_net -net sys_250m_resetn [get_bd_pins sys_250m_rstgen/peripheral_aresetn]
  connect_bd_net -net sys_500m_clk [get_bd_pins axi_adrv9001/delay_clk] [get_bd_pins sys_500m_rstgen/slowest_sync_clk] [get_bd_pins sys_ps8/pl_clk2]
  connect_bd_net -net sys_500m_reset [get_bd_pins sys_500m_rstgen/peripheral_reset]
  connect_bd_net -net sys_500m_resetn [get_bd_pins sys_500m_rstgen/peripheral_aresetn]
  connect_bd_net -net sys_concat_intc_0_dout [get_bd_pins sys_concat_intc_0/dout] [get_bd_pins sys_ps8/pl_ps_irq0]
  connect_bd_net -net sys_concat_intc_1_dout [get_bd_pins sys_concat_intc_1/dout] [get_bd_pins sys_ps8/pl_ps_irq1]
  connect_bd_net -net sys_cpu_clk [get_bd_pins axi_adrv9001/s_axi_aclk] [get_bd_pins axi_adrv9001_rx1_dma/m_dest_axi_aclk] [get_bd_pins axi_adrv9001_rx1_dma/s_axi_aclk] [get_bd_pins axi_adrv9001_rx2_dma/m_dest_axi_aclk] [get_bd_pins axi_adrv9001_rx2_dma/s_axi_aclk] [get_bd_pins axi_adrv9001_tx1_dma/m_src_axi_aclk] [get_bd_pins axi_adrv9001_tx1_dma/s_axi_aclk] [get_bd_pins axi_adrv9001_tx2_dma/m_src_axi_aclk] [get_bd_pins axi_adrv9001_tx2_dma/s_axi_aclk] [get_bd_pins axi_cpu_interconnect/ACLK] [get_bd_pins axi_cpu_interconnect/M00_ACLK] [get_bd_pins axi_cpu_interconnect/M01_ACLK] [get_bd_pins axi_cpu_interconnect/M02_ACLK] [get_bd_pins axi_cpu_interconnect/M03_ACLK] [get_bd_pins axi_cpu_interconnect/M04_ACLK] [get_bd_pins axi_cpu_interconnect/M05_ACLK] [get_bd_pins axi_cpu_interconnect/S00_ACLK] [get_bd_pins axi_hp1_interconnect/aclk] [get_bd_pins axi_sysid_0/s_axi_aclk] [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins rom_sys_0/clk] [get_bd_pins sys_ps8/maxihpm0_lpd_aclk] [get_bd_pins sys_ps8/pl_clk0] [get_bd_pins sys_ps8/saxihp1_fpd_aclk] [get_bd_pins sys_rstgen/slowest_sync_clk]
  connect_bd_net -net sys_cpu_reset [get_bd_pins sys_rstgen/peripheral_reset]
  connect_bd_net -net sys_cpu_resetn [get_bd_pins axi_adrv9001/s_axi_aresetn] [get_bd_pins axi_adrv9001_rx1_dma/m_dest_axi_aresetn] [get_bd_pins axi_adrv9001_rx1_dma/s_axi_aresetn] [get_bd_pins axi_adrv9001_rx2_dma/m_dest_axi_aresetn] [get_bd_pins axi_adrv9001_rx2_dma/s_axi_aresetn] [get_bd_pins axi_adrv9001_tx1_dma/m_src_axi_aresetn] [get_bd_pins axi_adrv9001_tx1_dma/s_axi_aresetn] [get_bd_pins axi_adrv9001_tx2_dma/m_src_axi_aresetn] [get_bd_pins axi_adrv9001_tx2_dma/s_axi_aresetn] [get_bd_pins axi_cpu_interconnect/ARESETN] [get_bd_pins axi_cpu_interconnect/M00_ARESETN] [get_bd_pins axi_cpu_interconnect/M01_ARESETN] [get_bd_pins axi_cpu_interconnect/M02_ARESETN] [get_bd_pins axi_cpu_interconnect/M03_ARESETN] [get_bd_pins axi_cpu_interconnect/M04_ARESETN] [get_bd_pins axi_cpu_interconnect/M05_ARESETN] [get_bd_pins axi_cpu_interconnect/S00_ARESETN] [get_bd_pins axi_hp1_interconnect/aresetn] [get_bd_pins axi_sysid_0/s_axi_aresetn] [get_bd_pins sys_rstgen/peripheral_aresetn]
  connect_bd_net -net sys_ps8_emio_gpio_o [get_bd_ports gpio_o] [get_bd_pins sys_ps8/emio_gpio_o]
  connect_bd_net -net sys_ps8_emio_gpio_t [get_bd_ports gpio_t] [get_bd_pins sys_ps8/emio_gpio_t]
  connect_bd_net -net sys_ps8_emio_spi0_m_o [get_bd_ports spi0_mosi] [get_bd_pins sys_ps8/emio_spi0_m_o]
  connect_bd_net -net sys_ps8_emio_spi0_sclk_o [get_bd_ports spi0_sclk] [get_bd_pins sys_ps8/emio_spi0_sclk_o]
  connect_bd_net -net sys_ps8_emio_spi0_ss1_o_n [get_bd_pins spi0_csn_concat/In1] [get_bd_pins sys_ps8/emio_spi0_ss1_o_n]
  connect_bd_net -net sys_ps8_emio_spi0_ss2_o_n [get_bd_pins spi0_csn_concat/In2] [get_bd_pins sys_ps8/emio_spi0_ss2_o_n]
  connect_bd_net -net sys_ps8_emio_spi0_ss_o_n [get_bd_pins spi0_csn_concat/In0] [get_bd_pins sys_ps8/emio_spi0_ss_o_n]
  connect_bd_net -net sys_ps8_emio_spi1_m_o [get_bd_ports spi1_mosi] [get_bd_pins sys_ps8/emio_spi1_m_o]
  connect_bd_net -net sys_ps8_emio_spi1_sclk_o [get_bd_ports spi1_sclk] [get_bd_pins sys_ps8/emio_spi1_sclk_o]
  connect_bd_net -net sys_ps8_emio_spi1_ss1_o_n [get_bd_pins spi1_csn_concat/In1] [get_bd_pins sys_ps8/emio_spi1_ss1_o_n]
  connect_bd_net -net sys_ps8_emio_spi1_ss2_o_n [get_bd_pins spi1_csn_concat/In2] [get_bd_pins sys_ps8/emio_spi1_ss2_o_n]
  connect_bd_net -net sys_ps8_emio_spi1_ss_o_n [get_bd_pins spi1_csn_concat/In0] [get_bd_pins sys_ps8/emio_spi1_ss_o_n]
  connect_bd_net -net sys_ps8_pl_resetn0 [get_bd_pins sys_250m_rstgen/ext_reset_in] [get_bd_pins sys_500m_rstgen/ext_reset_in] [get_bd_pins sys_ps8/pl_resetn0] [get_bd_pins sys_rstgen/ext_reset_in]
  connect_bd_net -net tdd_sync_1 [get_bd_ports tdd_sync] [get_bd_pins axi_adrv9001/tdd_sync]
  connect_bd_net -net tx1_dclk_in_n_1 [get_bd_ports tx1_dclk_in_n] [get_bd_pins axi_adrv9001/tx1_dclk_in_n_NC]
  connect_bd_net -net tx1_dclk_in_p_1 [get_bd_ports tx1_dclk_in_p] [get_bd_pins axi_adrv9001/tx1_dclk_in_p_dclk_in]
  connect_bd_net -net tx2_dclk_in_n_1 [get_bd_ports tx2_dclk_in_n] [get_bd_pins axi_adrv9001/tx2_dclk_in_n_NC]
  connect_bd_net -net tx2_dclk_in_p_1 [get_bd_ports tx2_dclk_in_p] [get_bd_pins axi_adrv9001/tx2_dclk_in_p_dclk_in]
  connect_bd_net -net tx_output_enable_1 [get_bd_ports tx_output_enable] [get_bd_pins axi_adrv9001/tx_output_enable]
  connect_bd_net -net util_adc_1_pack_fifo_wr_overflow [get_bd_pins axi_adrv9001/adc_1_dovf] [get_bd_pins util_adc_1_pack/fifo_wr_overflow]
  connect_bd_net -net util_adc_2_pack_fifo_wr_overflow [get_bd_pins axi_adrv9001/adc_2_dovf] [get_bd_pins util_adc_2_pack/fifo_wr_overflow]
  connect_bd_net -net util_dac_1_upack_fifo_rd_data_0 [get_bd_pins axi_adrv9001/dac_1_data_i0] [get_bd_pins util_dac_1_upack/fifo_rd_data_0]
  connect_bd_net -net util_dac_1_upack_fifo_rd_data_1 [get_bd_pins axi_adrv9001/dac_1_data_q0] [get_bd_pins util_dac_1_upack/fifo_rd_data_1]
  connect_bd_net -net util_dac_1_upack_fifo_rd_data_2 [get_bd_pins axi_adrv9001/dac_1_data_i1] [get_bd_pins util_dac_1_upack/fifo_rd_data_2]
  connect_bd_net -net util_dac_1_upack_fifo_rd_data_3 [get_bd_pins axi_adrv9001/dac_1_data_q1] [get_bd_pins util_dac_1_upack/fifo_rd_data_3]
  connect_bd_net -net util_dac_1_upack_fifo_rd_underflow [get_bd_pins axi_adrv9001/dac_1_dunf] [get_bd_pins util_dac_1_upack/fifo_rd_underflow]
  connect_bd_net -net util_dac_2_upack_fifo_rd_data_0 [get_bd_pins axi_adrv9001/dac_2_data_i0] [get_bd_pins util_dac_2_upack/fifo_rd_data_0]
  connect_bd_net -net util_dac_2_upack_fifo_rd_data_1 [get_bd_pins axi_adrv9001/dac_2_data_q0] [get_bd_pins util_dac_2_upack/fifo_rd_data_1]
  connect_bd_net -net util_dac_2_upack_fifo_rd_underflow [get_bd_pins axi_adrv9001/dac_2_dunf] [get_bd_pins util_dac_2_upack/fifo_rd_underflow]

  # Create address segments
  create_bd_addr_seg -range 0x80000000 -offset 0x00000000 [get_bd_addr_spaces axi_adrv9001_rx1_dma/m_dest_axi] [get_bd_addr_segs sys_ps8/SAXIGP3/HP1_DDR_LOW] SEG_sys_ps8_HP1_DDR_LOW
  create_bd_addr_seg -range 0x80000000 -offset 0x00000000 [get_bd_addr_spaces axi_adrv9001_rx2_dma/m_dest_axi] [get_bd_addr_segs sys_ps8/SAXIGP3/HP1_DDR_LOW] SEG_sys_ps8_HP1_DDR_LOW
  create_bd_addr_seg -range 0x80000000 -offset 0x00000000 [get_bd_addr_spaces axi_adrv9001_tx1_dma/m_src_axi] [get_bd_addr_segs sys_ps8/SAXIGP3/HP1_DDR_LOW] SEG_sys_ps8_HP1_DDR_LOW
  create_bd_addr_seg -range 0x80000000 -offset 0x00000000 [get_bd_addr_spaces axi_adrv9001_tx2_dma/m_src_axi] [get_bd_addr_segs sys_ps8/SAXIGP3/HP1_DDR_LOW] SEG_sys_ps8_HP1_DDR_LOW
  create_bd_addr_seg -range 0x00010000 -offset 0x84A00000 [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs axi_adrv9001/s_axi/axi_lite] SEG_data_axi_adrv9001
  create_bd_addr_seg -range 0x00001000 -offset 0x84A30000 [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs axi_adrv9001_rx1_dma/s_axi/axi_lite] SEG_data_axi_adrv9001_rx1_dma
  create_bd_addr_seg -range 0x00001000 -offset 0x84A40000 [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs axi_adrv9001_rx2_dma/s_axi/axi_lite] SEG_data_axi_adrv9001_rx2_dma
  create_bd_addr_seg -range 0x00001000 -offset 0x84A50000 [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs axi_adrv9001_tx1_dma/s_axi/axi_lite] SEG_data_axi_adrv9001_tx1_dma
  create_bd_addr_seg -range 0x00001000 -offset 0x84A60000 [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs axi_adrv9001_tx2_dma/s_axi/axi_lite] SEG_data_axi_adrv9001_tx2_dma
  create_bd_addr_seg -range 0x00010000 -offset 0x85000000 [get_bd_addr_spaces sys_ps8/Data] [get_bd_addr_segs axi_sysid_0/s_axi/axi_lite] SEG_data_axi_sysid_0


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


