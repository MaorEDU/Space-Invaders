// (c) Technion IIT, Department of Electrical Engineering 2022 
// Written By Liat Schwartz August 2018 
// Updated by Mor Dahan - January 2022

// Implements a BCD down counter 99 down to 0 with several enable inputs and loadN data
// having countL, countH and tc outputs
// by instantiating two one bit down-counters


module bcddn
	(
	input  logic clk, 
	input  logic resetN, 
	input  logic loadN, 
	input  logic enable1, 
	input  logic enable2, 
	
	output logic [3:0] countL, 
	output logic [3:0] countH,
	output logic tc
   );

// Parameters defined as external, here with a default value - to be updated 
// in the upper hierarchy file with the actial bomb down counting values
// -----------------------------------------------------------
	parameter  logic [3:0] datainL = 4'h2 ; 
	parameter  logic [3:0] datainH = 4'h1 ;
// -----------------------------------------------------------
	
	logic  tclow, tchigh;// internal variables terminal count 
	
// Low counter instantiation
	down_counter lowc(.clk(clk), 
							.resetN(resetN),
							.loadN(loadN),	
							.enable1(1'b1), 
							.enable2(enable2),
							.enable3(1'b1), 	
							.datain(datainL), 
							.count(countL), 
							.tc(tclow) );
	
// High counter instantiation
//--------------------------------------------------------------------------------------------------------------------
// &&&&&&&&&&&&&&  fill your code and paste to the report #2 
//--------------------------------------------------------------------------------------------------------------------			
	//assign countH = 4'h0 ; //  ## initializing a variable,  to enable compilation, change if needed
	
	down_counter upc(.clk(clk), 
							.resetN(resetN),
							.loadN(loadN),	
							.enable1(1'b1 & tclow), //Enabled by tclow and enable1
							.enable2(enable2),
							.enable3(1'b1), 	
							.datain(datainH), 
							.count(countH), 
							.tc(tchigh) );
  //Terminal count logic
	
	always_comb begin 
		if (countL==4'b0 && countH == 4'b0) begin
			tc = 1'b1; //when both digits are 0
		end
		else begin
			tc = 1'b0;
		end
	end
	
//--------------------------------------------------------------------------------------------------------------------
// &&&&&&&&&&&&&&  end of paste to the report #2
//--------------------------------------------------------------------------------------------------------------------			
				
  

endmodule
