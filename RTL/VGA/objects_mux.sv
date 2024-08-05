
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
		   // smiley 
					input		logic	spaceshipDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] spaceshipRGB, 
					     
		  // box here 
					input 	logic projectileDrawingRequest,
					input 	logic[7:0]  projectileRGB,
			//banana
					
		  
		  
		  
		  
		  ////////////////////////
		  // background 
					input    logic shield_DrawingRequest, // box of numbers
					input		logic	[7:0] shield_RGB,   
					
					//player hp
					input		logic				drawingRequestHP,
		    		input		logic				drawingRequestHP2,
							//output that the pixel should be dispalyed 
					input		logic	[7:0]		playerHP_RGB,				
					
					input		logic	[7:0]		playerHP2_RGB, 
					input		logic	BGDrawingRequest, 
					input		logic	[7:0] RGB_MIF, 
					input 	logic bananaDrawingRequest,
					input 	logic [7:0] bananaRGB,
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if (spaceshipDrawingRequest == 1'b1 )   
			RGBOut <= spaceshipRGB;  //fSirst priority 
	else if(bananaDrawingRequest == 1'b1)
				RGBOut <= bananaRGB;
			
   	else if(drawingRequestHP == 1'b1) 
				RGBOut <= playerHP_RGB;
		else if (drawingRequestHP2 == 1'b1)
				RGBOut <= playerHP2_RGB;
		 else if(projectileDrawingRequest == 1'b1)
			RGBOut <= projectileRGB; //second priority
		 	
 		else if (shield_DrawingRequest == 1'b1)
				RGBOut <= shield_RGB;
		
		else RGBOut <= RGB_MIF ;// last priority 
		end ; 
	end

endmodule


