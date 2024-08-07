// (c) Technion IIT, Department of Electrical Engineering 2018 

// Implements the hexadecimal to 7Segment conversion unit
// by using a two-dimensional array

module hexss 
	(
	input logic [4:0] hexin, // Data input: hex numbers 0 to f
	//input logic darkN, 
	//input logic LampTest, 	// Aditional inputs
	output logic [6:0] ss 	// Output for 7Seg display
	);
	
//------------------------------------------------------------------------------------
// &&&&&&&&&&&&&&  fill your code and paste into the report
//------------------------------------------------------------------------------------
always_comb
begin
	 
	    logic [0:17] [6:0] SevenSeg =
		                          { 7'b1000000, //0
										    7'b1111001, //1
										    7'b0100100,
											 7'b0110000,
											 7'b0011001,
											 7'b0010010,
											 7'b0000010,
											 7'b1111000,
											 7'b0000000,
											 7'b0010000,
											 7'b0001000,
								  			 7'b0000011,
											 7'b1000110,
											 7'b0100001,
											 7'b0000110,
											 7'b0001110, //f
											 7'b0001100, // P
											 7'b0111111  // - (minus sign)
											 };  											
		 ss = SevenSeg[hexin];
	 
end

//-------------------------------------------------------------------------------------
// &&&&&&&&&&&&&&  end of paste into the report 
//-------------------------------------------------------------------------------------

endmodule


