// (c) Technion IIT, Department of Electrical Engineering 2022 
// Updated by Mor Dahan - January 2022

// Implements a 4 bits down counter 9  down to 0 with several enable inputs and loadN data.
// It outputs count and asynchronous terminal count, tc, signal 

module down_counter
	(
	input logic clk, 
	input logic resetN, 
	input logic [3:0] load ,
	input logic enable_counter,
	
	output logic tc
   );

// Down counter
int count;
int flag;
always_ff @(posedge clk or negedge resetN)
   begin
	      
      if ( !resetN )	begin// Asynchronic reset
			count <= 4'h99;
			flag <= 0;
		end
				
      else 	begin		// Synchronic logic	
//--------------------------------------------------------------------------------------------------------------------
// &&&&&&&&&&&&&&  fill your code and paste to the report #1 
//--------------------------------------------------------------------------------------------------------------------			
		//count <= 4'h0; //  ##  initializing a variable,  to enable compilation, change if needed //changed to 9
		
		if (enable_counter && flag == 1'b0) begin
				count <= load;//Loading datain into count
				flag <= 1'b1;
		end else if(count == 4'h0) begin 
					flag <= 1'b0;
					count <= load;
			end
		else begin 
				if (flag  == 1'b1)
				count <= count-1; //Decrement
			end
		 //Synch
	end //always
end
	
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
