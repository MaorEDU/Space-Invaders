module BananaMove (
    input logic clk,
    input logic resetN,
    input logic startOfFrame,      // short pulse every start of frame 30Hz  
    input logic collision,         // collision if smiley hits an object
    input logic [3:0] HitEdgeCode, // one bit per edge
    input logic [10:0] initial_y,
	 input logic appear,
	 output logic active,
    output logic signed [10:0] topLeftX, // output the top left corner 
    output logic signed [10:0] topLeftY  // can be negative, if the object is partly outside 
	 
);

parameter int INITIAL_X = 280;
parameter int INITIAL_X_SPEED = 40;
parameter int INITIAL_Y_SPEED = 20;
parameter int Y_ACCEL = -10;

const int MAX_Y_SPEED = 100;
const int FIXED_POINT_MULTIPLIER = 64; // note it must be 2^n 

const int OBJECT_WIDTH_X = 16;
const int OBJECT_HEIGHT_Y = 16;
const int SafetyMargin = 2;

const int x_FRAME_LEFT = (SafetyMargin) * FIXED_POINT_MULTIPLIER; 
const int x_FRAME_RIGHT = (639 - SafetyMargin - OBJECT_WIDTH_X) * FIXED_POINT_MULTIPLIER; 
const int y_FRAME_TOP = (SafetyMargin) * FIXED_POINT_MULTIPLIER;
const int y_FRAME_BOTTOM = (479 - SafetyMargin - OBJECT_HEIGHT_Y) * FIXED_POINT_MULTIPLIER;

enum logic [2:0] {
    IDLE_ST,          // initial state
    MOVE_ST,          // moving no collision 
    START_OF_FRAME_ST,// startOfFrame activity-after all data collected 
    POSITION_CHANGE_ST,// position interpolate 
    POSITION_LIMITS_ST // check if inside the frame  
} SM_Motion;

int flag = 0;
int Xspeed;
int Yspeed;
int Xposition;
int Yposition;

logic [15:0] hit_reg = 16'b0;  // register to collect all the collisions in the frame. |corner|left|top|right|bottom|

always_ff @(posedge clk or negedge resetN) begin : fsm_sync_proc
    if (!resetN) begin 
        SM_Motion <= IDLE_ST; 
        Xspeed <= 0; 
        Yspeed <= 0; 
        Xposition <= 0; 
        Yposition <= 0; 
        hit_reg <= 16'b0;
		  flag <= 0; 
    end else begin
        
		  case (SM_Motion)
            IDLE_ST: begin
                Xspeed <= Xspeed; 
                Yspeed <= Yspeed; 
                Xposition <= INITIAL_X * FIXED_POINT_MULTIPLIER; 
                Yposition <= initial_y * FIXED_POINT_MULTIPLIER; 
                if (startOfFrame) 
                    SM_Motion <= MOVE_ST;
            end

            MOVE_ST: begin
                if (collision) begin
                    hit_reg[HitEdgeCode] <= 1'b1;
                end
					 if (appear == 1'b1 && flag == 0) begin
						 Xspeed <= INITIAL_X_SPEED;
						 Yspeed <= INITIAL_Y_SPEED;
						 active <= 1;
						 flag <= 1;
						 Yposition <=initial_y*FIXED_POINT_MULTIPLIER;
						 end
						 
						 
                if (startOfFrame)
                    SM_Motion <= START_OF_FRAME_ST;
            end 

            START_OF_FRAME_ST: begin
                case (hit_reg)
                    16'h0000: begin // no collision in the frame 
                        Yspeed <= Yspeed;
                        Xspeed <= Xspeed;
                    end
                    16'h1000, 16'h0040, 16'h0008, 16'h0200: begin // one of the four corners
                        Yspeed <= -Yspeed;
                        Xspeed <= -Xspeed;
                    end
                    16'h0100, 16'h1100, 16'h0300, 16'h1200, 16'h1300: begin // left side 
                        if (Xspeed < 0)
                            Xspeed <= -Xspeed;
                    end
                    16'h0010, 16'h1010, 16'h0050, 16'h1040, 16'h1050: begin // top side 
                        if (Yspeed < 0)
                            Yspeed <= -Yspeed;
                    end
                    16'h0004, 16'h0044, 16'h000C, 16'h0048, 16'h004C: begin // right side 
                        if (Xspeed > 0)
                            Xspeed <= -Xspeed;
                    end
                    16'h0002, 16'h0202, 16'h000A, 16'h0028, 16'h002A: begin // bottom side 
                        if (Yspeed > 0)
                            Yspeed <= -Yspeed;
                    end
                    default: begin // complex corner 
                        Yspeed <= Yspeed;
                        Xspeed <= Xspeed;
								active <= active;
                    end
                endcase
                hit_reg <= 16'h0000;  // clear for next time 
                SM_Motion <= POSITION_CHANGE_ST;
            end 

            POSITION_CHANGE_ST: begin
                Xposition <= Xposition + Xspeed; 
                Yposition <= Yposition + Yspeed;
                SM_Motion <= POSITION_LIMITS_ST;
            end

            POSITION_LIMITS_ST: begin
                if (Xposition < x_FRAME_LEFT) 
                    Xposition <= x_FRAME_LEFT; 
                if (Xposition > x_FRAME_RIGHT)
                    Xposition <= x_FRAME_RIGHT; 
                if (Yposition < y_FRAME_TOP) 
                    Yposition <= y_FRAME_TOP; 
                if (Yposition > y_FRAME_BOTTOM) 
                    Yposition <= y_FRAME_BOTTOM; 
                SM_Motion <= MOVE_ST;
            end
        endcase
    end
end

// Return from FIXED point trunc back to frame size parameters
assign topLeftX = Xposition / FIXED_POINT_MULTIPLIER;   // note it must be 2^n 
assign topLeftY = Yposition / FIXED_POINT_MULTIPLIER;

endmodule
