## Princeton University -- ELE 206/COS 306
## This file is a .xdc for the Basys3 board
## It is to be used for the Simon Lab

## Clock signal
set_property PACKAGE_PIN W5 [get_ports sysclk]							
	set_property IOSTANDARD LVCMOS33 [get_ports sysclk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports sysclk]
 
## Pattern Switches
set_property PACKAGE_PIN V17 [get_ports {pattern[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pattern[0]}]
set_property PACKAGE_PIN V16 [get_ports {pattern[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pattern[1]}]
set_property PACKAGE_PIN W16 [get_ports {pattern[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pattern[2]}]
set_property PACKAGE_PIN W17 [get_ports {pattern[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pattern[3]}]

## Level Switch
set_property PACKAGE_PIN R2 [get_ports {level}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {level}]
 
## Pattern LEDs
set_property PACKAGE_PIN U16 [get_ports {pattern_leds[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pattern_leds[0]}]
set_property PACKAGE_PIN E19 [get_ports {pattern_leds[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pattern_leds[1]}]
set_property PACKAGE_PIN U19 [get_ports {pattern_leds[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pattern_leds[2]}]
set_property PACKAGE_PIN V19 [get_ports {pattern_leds[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {pattern_leds[3]}]

## Mode LEDs
set_property PACKAGE_PIN N3 [get_ports {mode_leds[0]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {mode_leds[0]}]
set_property PACKAGE_PIN P1 [get_ports {mode_leds[1]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {mode_leds[1]}]
set_property PACKAGE_PIN L1 [get_ports {mode_leds[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {mode_leds[2]}]

## Reset Button
set_property PACKAGE_PIN T17 [get_ports rst]						
	set_property IOSTANDARD LVCMOS33 [get_ports rst]

## Clock Button
set_property PACKAGE_PIN U18 [get_ports pclk]						
	set_property IOSTANDARD LVCMOS33 [get_ports pclk]