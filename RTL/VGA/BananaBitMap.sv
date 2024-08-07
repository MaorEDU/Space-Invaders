//
// coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2021
// generating a number bitmap 



module BananaBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic appear,
					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout,  //rgb value from the bitmap 
					output   logic	[3:0] HitEdgeCode //one bit per edge 
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 
localparam  int OBJECT_NUMBER_OF_X_BITS = 5;  // 2^6 = 64 


localparam  int OBJECT_HEIGHT_Y = 1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam  int OBJECT_WIDTH_X = 1 <<  OBJECT_NUMBER_OF_X_BITS;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 3; // -2; how many pixel bits are in every collision pixel
localparam  int OBJECT_WIDTH_X_DIVIDER =  OBJECT_NUMBER_OF_X_BITS - 3; // -2

// generating a smiley bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel  


logic[0:31][0:31][7:0] object_colors = {
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h8d,8'h8d,8'hb1,8'hb1,8'h24,8'h24,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h8d,8'h8d,8'hb1,8'hb1,8'h24,8'h24,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'hb1,8'hb1,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'hb1,8'hb1,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h8d,8'h8d,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h8d,8'h8d,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'h24,8'h24,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'h24,8'h24,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'h24,8'h24,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'h24,8'h24,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h24,8'h24},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h24,8'h24},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h24,8'h24},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h24,8'h24},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h24,8'h24,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h24,8'h24,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h24,8'h24,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h24,8'h24,8'h00,8'h00},
	{8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfe,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00},
	{8'h24,8'h24,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h24,8'h24,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h24,8'h24,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h24,8'h24,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'hfd,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h24,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};														
	



logic [0:7] [0:7] [3:0] hit_colors = 
		  {32'hC4444446,     
			32'h8C444462,    
			32'h88C44622,    
			32'h888C6222,    
			32'h88893222,    
			32'h88911322,    
			32'h89111132,    
			32'h91111113};
 

 
 
// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		HitEdgeCode <= 4'h0;

	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  
		HitEdgeCode <= 4'h0;

		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket 
			RGBout <= object_colors[offsetY][offsetX];
			HitEdgeCode <= hit_colors[offsetY >> OBJECT_HEIGHT_Y_DIVIDER][offsetX >> OBJECT_WIDTH_X_DIVIDER];	//get hitting edge code from the colors table  
			
		end  	
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = ((RGBout != TRANSPARENT_ENCODING) && appear)  ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap  removed appear
endmodule