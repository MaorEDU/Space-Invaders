// (c) Technion IIT, Department of Electrical Engineering 2022 
// Updated by Mor Dahan - January 2022

// Implements a 4 bits down counter 9  down to 0 with several enable inputs and loadN data.
// It outputs count and asynchronous terminal count, tc, signal 

module startGame
	(
	input logic clk, 
	input logic start,
	input logic reset,
	output logic rst
   );
	
	always_comb begin
		rst =  1'b0; 
		if(start) begin 
			rst = 1'b1; //Raise rst when game start
		end 
		else if(reset == 1'b0) 
			rst = 1'b0; //else
	end
//--------------------------------------------------------------------------------------------------------------------
// &&&&&&&&&&&&&&  end of fill the report #1 
//--------------------------------------------------------------------------------------------------------------------			


	
endmodule
