module monster_health_bar(
    input	logic	clk,
	 input	logic	resetN,
	 
	 input logic got_hit,
	
	output	logic	drawingRequest, //output that the pixel should be dispalyed 
	output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;
	 
    parameter MAX_HEALTH = 32;
    parameter BAR_WIDTH = 100;        // Width of the health bar
    parameter BAR_HEIGHT = 10;        // Height of the health bar
	 
	 logic [7:0] health;
	logic [10:0] offsetX;
	logic [10:0] offsetY;
	assign drawingRequest = 1;
	logic [9:0] bar_width_scaled;
	logic [9:0] framebuffer [0:BAR_HEIGHT-1][0:BAR_WIDTH-1]; // Frame buffer memory
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            health <= MAX_HEALTH;  // Full health on reset
        end else if (got_hit) begin
            if (health > 1) begin
                health <= health - 1; // Reduce health by damage amount
            end else begin
                health <= 8'd0;  // Prevent underflow
            end
        end
    end

     // Update framebuffer based on bar_width_scaled
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            // Clear the frame buffer on reset
            for (int y = 0; y < BAR_HEIGHT; y++) begin
                for (int x = 0; x < BAR_WIDTH; x++) begin
                    framebuffer[y][x] <= 0;
                end
            end
        end else begin
            for (int y = 0; y < BAR_HEIGHT; y++) begin
                for (int x = 0; x < BAR_WIDTH; x++) begin
                    if (x < bar_width_scaled) begin
                        framebuffer[y][x] <= 1; // Set pixel for health bar
                    end else begin
                        framebuffer[y][x] <= 0; // Clear pixel
                    end
                end
            end
        end
    end

    // VGA output logic (purely combinational)
    always_comb begin
        if (framebuffer[offsetY][offsetX] == 1) begin
            RGBout = 8'hE0; // red color for health bar
        end else begin
            RGBout = 8'hFF; // transperent color for background
        end
    end

endmodule
