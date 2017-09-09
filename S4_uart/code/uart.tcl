
	#set_global_assignment -name FAMILY "Cyclone IV"
	#set_global_assignment -name DEVICE ep4ce10f17c8n

set_location_assignment PIN_E1    -to    clk 	
	
# UART
set_location_assignment PIN_K5    -to    uart_rxd        
set_location_assignment PIN_K2    -to    uart_txd 
	
# # LED
# set_location_assignment PIN_T12   -to   LED[0]          
# set_location_assignment PIN_P8    -to   LED[1]         
# set_location_assignment PIN_M8    -to   LED[2]          
# set_location_assignment PIN_M10   -to   LED[3]         
	

	                              
# #BEEP ·äÃùÆ÷                      
# set_location_assignment PIN_P9    -to    beep  
	

rdempty
rdreq


# tdata[7]
# tdata[6]
# tdata[5]
# tdata[4]
# tdata[3]
# tdata[2]
# tdata[1]
# tdata[0]
# tfull
# twrreq



        
# KEY Çá´¥°´¼ü
set_location_assignment PIN_L3    -to   rst_n          
# set_location_assignment PIN_L1    -to   key[1]          
# set_location_assignment PIN_J6    -to   key[2]          
# set_location_assignment PIN_N1    -to   key[3]            
         
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
   

