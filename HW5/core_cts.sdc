###################################################################

# Created by write_sdc on Mon Nov  4 19:27:44 2024

###################################################################
set sdc_version 1.8

set_units -time ns -resistance kOhm -capacitance pF -power mW -voltage V       \
-current mA
set_operating_conditions slow -library slow
# set_wire_load_model -name tsmc13_wl10 -library slow
set_load -pin_load 0.05 [get_ports o_op_ready]
set_load -pin_load 0.05 [get_ports o_in_ready]
set_load -pin_load 0.05 [get_ports o_out_valid]
set_load -pin_load 0.05 [get_ports {o_out_data[13]}]
set_load -pin_load 0.05 [get_ports {o_out_data[12]}]
set_load -pin_load 0.05 [get_ports {o_out_data[11]}]
set_load -pin_load 0.05 [get_ports {o_out_data[10]}]
set_load -pin_load 0.05 [get_ports {o_out_data[9]}]
set_load -pin_load 0.05 [get_ports {o_out_data[8]}]
set_load -pin_load 0.05 [get_ports {o_out_data[7]}]
set_load -pin_load 0.05 [get_ports {o_out_data[6]}]
set_load -pin_load 0.05 [get_ports {o_out_data[5]}]
set_load -pin_load 0.05 [get_ports {o_out_data[4]}]
set_load -pin_load 0.05 [get_ports {o_out_data[3]}]
set_load -pin_load 0.05 [get_ports {o_out_data[2]}]
set_load -pin_load 0.05 [get_ports {o_out_data[1]}]
set_load -pin_load 0.05 [get_ports {o_out_data[0]}]
set_max_fanout 20 [get_ports i_clk]
set_max_fanout 20 [get_ports i_rst_n]
set_max_fanout 20 [get_ports i_op_valid]
set_max_fanout 20 [get_ports {i_op_mode[3]}]
set_max_fanout 20 [get_ports {i_op_mode[2]}]
set_max_fanout 20 [get_ports {i_op_mode[1]}]
set_max_fanout 20 [get_ports {i_op_mode[0]}]
set_max_fanout 20 [get_ports i_in_valid]
set_max_fanout 20 [get_ports {i_in_data[7]}]
set_max_fanout 20 [get_ports {i_in_data[6]}]
set_max_fanout 20 [get_ports {i_in_data[5]}]
set_max_fanout 20 [get_ports {i_in_data[4]}]
set_max_fanout 20 [get_ports {i_in_data[3]}]
set_max_fanout 20 [get_ports {i_in_data[2]}]
set_max_fanout 20 [get_ports {i_in_data[1]}]
set_max_fanout 20 [get_ports {i_in_data[0]}]
# set_ideal_network [get_ports i_clk]
create_clock [get_ports i_clk]  -period 3.35  -waveform {0 1.675}
# set_clock_latency 0.5  [get_clocks i_clk]
# set_clock_uncertainty 0.1  [get_clocks i_clk]
set_input_delay -clock i_clk  1.675  [get_ports i_clk]
set_input_delay -clock i_clk  1.675  [get_ports i_rst_n]
set_input_delay -clock i_clk  1.675  [get_ports i_op_valid]
set_input_delay -clock i_clk  1.675  [get_ports {i_op_mode[3]}]
set_input_delay -clock i_clk  1.675  [get_ports {i_op_mode[2]}]
set_input_delay -clock i_clk  1.675  [get_ports {i_op_mode[1]}]
set_input_delay -clock i_clk  1.675  [get_ports {i_op_mode[0]}]
set_input_delay -clock i_clk  1.675  [get_ports i_in_valid]
set_input_delay -clock i_clk  1.675  [get_ports {i_in_data[7]}]
set_input_delay -clock i_clk  1.675  [get_ports {i_in_data[6]}]
set_input_delay -clock i_clk  1.675  [get_ports {i_in_data[5]}]
set_input_delay -clock i_clk  1.675  [get_ports {i_in_data[4]}]
set_input_delay -clock i_clk  1.675  [get_ports {i_in_data[3]}]
set_input_delay -clock i_clk  1.675  [get_ports {i_in_data[2]}]
set_input_delay -clock i_clk  1.675  [get_ports {i_in_data[1]}]
set_input_delay -clock i_clk  1.675  [get_ports {i_in_data[0]}]
set_output_delay -clock i_clk  1.675  [get_ports o_op_ready]
set_output_delay -clock i_clk  1.675  [get_ports o_in_ready]
set_output_delay -clock i_clk  1.675  [get_ports o_out_valid]
set_output_delay -clock i_clk  1.675  [get_ports {o_out_data[13]}]
set_output_delay -clock i_clk  1.675  [get_ports {o_out_data[12]}]
set_output_delay -clock i_clk  1.675  [get_ports {o_out_data[11]}]
set_output_delay -clock i_clk  1.675  [get_ports {o_out_data[10]}]
set_output_delay -clock i_clk  1.675  [get_ports {o_out_data[9]}]
set_output_delay -clock i_clk  1.675  [get_ports {o_out_data[8]}]
set_output_delay -clock i_clk  1.675  [get_ports {o_out_data[7]}]
set_output_delay -clock i_clk  1.675  [get_ports {o_out_data[6]}]
set_output_delay -clock i_clk  1.675  [get_ports {o_out_data[5]}]
set_output_delay -clock i_clk  1.675  [get_ports {o_out_data[4]}]
set_output_delay -clock i_clk  1.675  [get_ports {o_out_data[3]}]
set_output_delay -clock i_clk  1.675  [get_ports {o_out_data[2]}]
set_output_delay -clock i_clk  1.675  [get_ports {o_out_data[1]}]
set_output_delay -clock i_clk  1.675  [get_ports {o_out_data[0]}]
