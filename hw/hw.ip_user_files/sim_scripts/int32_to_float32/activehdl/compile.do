vlib work
vlib activehdl

vlib activehdl/xilinx_vip
vlib activehdl/xpm
vlib activehdl/xbip_utils_v3_0_10
vlib activehdl/axi_utils_v2_0_6
vlib activehdl/xbip_pipe_v3_0_6
vlib activehdl/xbip_dsp48_wrapper_v3_0_4
vlib activehdl/xbip_dsp48_addsub_v3_0_6
vlib activehdl/xbip_dsp48_multadd_v3_0_6
vlib activehdl/xbip_bram18k_v3_0_6
vlib activehdl/mult_gen_v12_0_16
vlib activehdl/floating_point_v7_1_9
vlib activehdl/xil_defaultlib

vmap xilinx_vip activehdl/xilinx_vip
vmap xpm activehdl/xpm
vmap xbip_utils_v3_0_10 activehdl/xbip_utils_v3_0_10
vmap axi_utils_v2_0_6 activehdl/axi_utils_v2_0_6
vmap xbip_pipe_v3_0_6 activehdl/xbip_pipe_v3_0_6
vmap xbip_dsp48_wrapper_v3_0_4 activehdl/xbip_dsp48_wrapper_v3_0_4
vmap xbip_dsp48_addsub_v3_0_6 activehdl/xbip_dsp48_addsub_v3_0_6
vmap xbip_dsp48_multadd_v3_0_6 activehdl/xbip_dsp48_multadd_v3_0_6
vmap xbip_bram18k_v3_0_6 activehdl/xbip_bram18k_v3_0_6
vmap mult_gen_v12_0_16 activehdl/mult_gen_v12_0_16
vmap floating_point_v7_1_9 activehdl/floating_point_v7_1_9
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xilinx_vip  -sv2k12 "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -sv2k12 "+incdir+/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/xilinx_vip/include" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"/mnt/applications/Xilinx/19.2/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xbip_utils_v3_0_10 -93 \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_6 -93 \
"../../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_6 -93 \
"../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_4 -93 \
"../../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_addsub_v3_0_6 -93 \
"../../../ipstatic/hdl/xbip_dsp48_addsub_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_multadd_v3_0_6 -93 \
"../../../ipstatic/hdl/xbip_dsp48_multadd_v3_0_vh_rfs.vhd" \

vcom -work xbip_bram18k_v3_0_6 -93 \
"../../../ipstatic/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_16 -93 \
"../../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work floating_point_v7_1_9 -93 \
"../../../ipstatic/hdl/floating_point_v7_1_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../hw.srcs/sources_1/ip/int32_to_float32/sim/int32_to_float32.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

