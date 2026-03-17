# ==============================================================================
# 1. THE CLOCK (Timing & Physical Pin)
# ==============================================================================
# Replace 'W5' with the actual clock pin on your specific board
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# This is the magic line that fixes your "non-clocked sequential cell" warning
# 20.000 ns period = 50 MHz
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} [get_ports clk]

# ==============================================================================
# 2. THE SENSOR INPUTS (3.3V Logic)
# ==============================================================================
set_property PACKAGE_PIN V17 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

set_property PACKAGE_PIN V16 [get_ports flow_sense]
set_property IOSTANDARD LVCMOS33 [get_ports flow_sense]

set_property PACKAGE_PIN V15 [get_ports low_sense]
set_property IOSTANDARD LVCMOS33 [get_ports low_sense]

set_property PACKAGE_PIN W16 [get_ports mid_sense]
set_property IOSTANDARD LVCMOS33 [get_ports mid_sense]

set_property PACKAGE_PIN W17 [get_ports max_sense]
set_property IOSTANDARD LVCMOS33 [get_ports max_sense]

# ==============================================================================
# 3. THE ACTUATOR OUTPUTS (To your Optocouplers/Relays)
# ==============================================================================
set_property PACKAGE_PIN U16 [get_ports motor]
set_property IOSTANDARD LVCMOS33 [get_ports motor]

set_property PACKAGE_PIN E19 [get_ports valve]
set_property IOSTANDARD LVCMOS33 [get_ports valve]