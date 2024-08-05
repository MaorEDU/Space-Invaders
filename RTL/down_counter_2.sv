// (c) Technion IIT, Department of Electrical Engineering 2022 
// Updated by Mor Dahan - January 2022

// Implements a 4 bits down counter 9  down to 0 with several enable inputs and loadN data.
// It outputs count and asynchronous terminal count, tc, signal 

module down_counter_2
	(
	input logic clk, 
	input logic resetN, 
	
	output logic tc
   );

// Down counter
int count;
always_ff @(posedge clk or negedge resetN)
   begin
	      
      if ( !resetN )	begin// Asynchronic reset
			count <= 4'h2;
		
		end
					// Synchronic logic	
		 else if(count == 4'h0) begin 
					count <= 4'h2; //9
			end
		else begin 
				count <= count-1; //Decrement
			end
		 //Synch
	end //always

	
	// Asynchronic tc

	
	always_comb begin
		tc =  1'b0; 
		if( count == 4'b0000) begin 
			tc = 1'b1; //Raise tc when count = 0
		end 
		else begin 
			tc = 1'b0; //else
		end
	end
//--------------------------------------------------------------------------------------------------------------------
// &&&&&&&&&&&&&&  end of fill the report #1 
//--------------------------------------------------------------------------------------------------------------------			


	
endmodule
