module projectile_object(
					input		logic	clk,
					input		logic	resetN,
					input 	logic signed	[10:0] pixelX,//  current VGA pixel 
					input 	logic signed	[10:0] pixelY,
					input 	logic signed	[10:0] proj_x, //position on the screen 
					input 	logic	signed [10:0] proj_y,   // can be negative , if the object is partliy outside 
					input 	logic active,
					output 	logic	[10:0] offsetX,// offset inside bracket from top left position 
					output 	logic	[10:0] offsetY,
					output	logic	drawingRequest, // indicates pixel inside the bracket
					output	logic	[7:0]	 RGBout //optional color output for mux 
);

parameter  int OBJECT_WIDTH_X = 32;
parameter  int OBJECT_HEIGHT_Y = 32;
parameter  logic [7:0] OBJECT_COLOR = 8'h5b ; 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 
 
int rightX ; //coordinates of the sides  
int bottomY ;
logic insideBracket ; 

//////////--------------------------------------------------------------------------------------------------------------=
// Calculate object right  & bottom  boundaries
assign rightX	= (proj_x + OBJECT_WIDTH_X);
assign bottomY	= (proj_y + OBJECT_HEIGHT_Y);
assign	insideBracket  = 	 ( (pixelX  >= proj_x) &&  (pixelX < rightX) // math is made with SIGNED variables  
						   && (pixelY  >= proj_y) &&  (pixelY < bottomY) )  ; // as the top left position can be negative
		


//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout			<=	8'b0;
		drawingRequest	<=	1'b0;
	end
	else begin 
		// DEFUALT outputs
	      RGBout <= TRANSPARENT_ENCODING ; // so it will not be displayed 
			drawingRequest <= 1'b0 ;// transparent color 
			offsetX	<= 0; //no offset
			offsetY	<= 0; //no offset
 
		if (insideBracket && active) // test if it is inside the rectangle 
		begin 
			RGBout  <= OBJECT_COLOR ;	// colors table 
			drawingRequest <= 1'b1 ;
			offsetX	<= (pixelX - proj_x); //calculate relative offsets from top left corner allways a positive number 
			offsetY	<= (pixelY - proj_y);
		end 
		

		
	end
end 
endmodule 