module projectile_move(
    input logic clk,
    input logic resetN,
    input logic [9:0] keyIsPressed,             // Signal to fire the projectile
	 input  logic startOfFrame,      //short pulse every start of frame 30Hz 
    input  logic enable_sof,    // if want to stop the smiley move 
	 input  logic collision,         //collision if smiley hits an object
	 input  logic [3:0] HitEdgeCode,
    input logic [10:0] ship_x,     // X position of the spaceship
    input logic [10:0] ship_y,     // Y position of the spaceship
    
	 output logic active,
	 
	 output logic [10:0] proj_x,    // X position of the projectile
    output logic [10:0] proj_y    // Y position of the projectile
);

 // a module used to generate the ball trajectory.  
  

//parameter int INITIAL_X = ship_x + 15;
//parameter int INITIAL_Y = ship_y - 2;
parameter int SPEED = 10; // Reduced the speed for smoother movement

const int MAX_Y_SPEED = 500;
const int FIXED_POINT_MULTIPLIER = 64; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calculations,
// we divide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

// movement limits 
const int OBJECT_WIDTH_X = 16;
const int OBJECT_HEIGHT_Y = 16;
const int SafetyMargin = 2;


const int y_FRAME_TOP = (SafetyMargin) * FIXED_POINT_MULTIPLIER;
const int y_FRAME_BOTTOM = (479 - SafetyMargin - OBJECT_HEIGHT_Y) * FIXED_POINT_MULTIPLIER; //- OBJECT_HEIGHT_Y
const int acc = -3;	 
  typedef enum logic [2:0] {
    IDLE_ST,           // initial state
    MOVE_ST,           // moving no collision 
    START_OF_FRAME_ST, // startOfFrame activity-after all data collected 
    POSITION_CHANGE_ST,// position interpolate 
    POSITION_LIMITS_ST // check if inside the frame  
} state_t;

state_t SM_Motion;
int flag = 0;
int Yspeed;    
int Xposition;    
int Yposition;
int Yoffset = 33;
logic [15:0] hit_reg; // register to collect all the collisions in the frame. |corner|left|top|right|bottom|

always_ff @(posedge clk or negedge resetN) begin : fsm_sync_proc
    if (resetN == 1'b0) begin 
        SM_Motion <= IDLE_ST; 
		  Yspeed <= 0; // Set the initial speed
        Xposition <= (ship_x ) * FIXED_POINT_MULTIPLIER;  
		  Yposition <= (ship_y -Yoffset) * FIXED_POINT_MULTIPLIER;
		  active <= 0;
        hit_reg <= 16'b0; 
		  flag <= 0;
    end else begin
    
        case (SM_Motion)
            //------------
            IDLE_ST: begin
                Yspeed <= 0; 
                Xposition <= (ship_x) * FIXED_POINT_MULTIPLIER; 
                Yposition <= (ship_y -Yoffset) * FIXED_POINT_MULTIPLIER; 
					 active <= 0;
					 flag <= 0;
                if (startOfFrame) 
                    SM_Motion <= MOVE_ST;
            end
    
            //------------
            MOVE_ST: begin // moving no collision               
                // collecting collisions     
                if (collision || Yposition == y_FRAME_TOP) begin
                    hit_reg[HitEdgeCode] <= 1'b1;
						  SM_Motion <= IDLE_ST;
                end

                // fire the projectile
                if (keyIsPressed[8] && flag == 0) begin // Check if enter is pressed
						  Yspeed <= -SPEED;
						  active <= 1;
						  flag <= 1;
						  Xposition <= (ship_x) * FIXED_POINT_MULTIPLIER; 
                end 

                if (startOfFrame) begin
                    SM_Motion <= START_OF_FRAME_ST; 					 
					end
            end 
            
            //------------
            START_OF_FRAME_ST: begin // check if any collision was detected 
                case (hit_reg)
                    16'h0000: begin // no collision in the frame 
								if (flag == 1) begin
								Yspeed <= Yspeed + acc;
								end
								active <= active;
                    end
                    //   CH       6H        3H         9H
                    16'h1000, 16'h0040, 16'h0008, 16'h0200: begin // one of the four corners     
                        Yspeed <= 0;
								active <= 0;
                    end
                    //   8H   ; (CH & 8H) ; (8H & 9H) ; (CH & 9H) ;(CH & 9H & 8H)   
                    16'h0100, 16'h1100, 16'h0300, 16'h1200, 16'h1300: begin // left side 
                        if (Yspeed < 0)
                            Yspeed <= 0;
									 active <= 0;
                    end
                    //   2H  (2H & 6H) (2H & 3H) (6H & 3H )  (6H & 2H & 3H )
                    16'h0004, 16'h0044, 16'h000C, 16'h0048, 16'h004C: begin // right side 
                        if (Yspeed > 0)
                            Yspeed <= 0;
									 active <= 0;
                    end
                    default: begin // complex corner 
                        Yspeed <= Yspeed;
								active <= active;
                    end
                endcase
                
                hit_reg <= 16'h0000; // clear for next time 
                SM_Motion <= POSITION_CHANGE_ST; 
            end 

            //------------------------
            POSITION_CHANGE_ST: begin // position interpolate 
                Yposition <= Yposition + Yspeed; 
                SM_Motion <= POSITION_LIMITS_ST; 
            end
        
            //------------------------
            POSITION_LIMITS_ST: begin // check if still inside the frame 
                if (Yposition < y_FRAME_TOP) 
                    Yposition <= y_FRAME_TOP; 
                if (Yposition > y_FRAME_BOTTOM)
                    Yposition <= y_FRAME_BOTTOM; 
                SM_Motion <= MOVE_ST; 
            end
        endcase // case 
    end
end // end fsm_sync

// return from FIXED point trunc back to frame size parameters 
assign proj_x = Xposition / FIXED_POINT_MULTIPLIER; // note it must be 2^n 
assign proj_y = Yposition / FIXED_POINT_MULTIPLIER;

endmodule
