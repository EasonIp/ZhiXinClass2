
	#set_global_assignment -name FAMILY "Cyclone IV"
	#set_global_assignment -name DEVICE ep4ce10f17c8n


set_location_assignment PIN_E1    -to    clk 	

# LED
set_location_assignment PIN_T12   -to   led_rd          
set_location_assignment PIN_P8    -to   led_wr         


	

        
# KEY Çá´¥°´¼ü
set_location_assignment PIN_L3    -to   rst_n          

set_location_assignment PIN_N1    -to   key            
         
# EEPROM
set_location_assignment PIN_L2    -to   eeprom_scl          
set_location_assignment PIN_L4    -to   eeprom_sda    
         
# SEG7 x 8 Æß¶ÎÊýÂë¹Ü
set_location_assignment PIN_L6    -to   sel[2]
set_location_assignment PIN_N6    -to   sel[1]
set_location_assignment PIN_M7    -to   sel[0] 
set_location_assignment PIN_T11   -to   seg[0]     
set_location_assignment PIN_T10   -to   seg[1]    
set_location_assignment PIN_T9    -to   seg[2]     
set_location_assignment PIN_T8    -to   seg[3]     
set_location_assignment PIN_T7    -to   seg[4]     
set_location_assignment PIN_T6    -to   seg[5]     
set_location_assignment PIN_T5    -to   seg[6]     
set_location_assignment PIN_T4    -to   seg[7] 
   
