
	#set_global_assignment -name FAMILY "Cyclone IV"
	#set_global_assignment -name DEVICE ep4ce10f17c8n

set_location_assignment PIN_E1    -to    clk 	
	

set_location_assignment PIN_A7    -to  vga_vs
set_location_assignment PIN_A6    -to  vga_hs
set_location_assignment PIN_C6    -to  vga_rgb[7]
set_location_assignment PIN_B5    -to  vga_rgb[6]
set_location_assignment PIN_E5    -to  vga_rgb[5]
set_location_assignment PIN_A4    -to  vga_rgb[4] 
set_location_assignment PIN_D4    -to  vga_rgb[3]
set_location_assignment PIN_C3    -to  vga_rgb[2]
set_location_assignment PIN_B1    -to  vga_rgb[1] 
set_location_assignment PIN_E8    -to  vga_rgb[0]          

# KEY Çá´¥°´¼ü
set_location_assignment PIN_L3    -to   rst_n          
