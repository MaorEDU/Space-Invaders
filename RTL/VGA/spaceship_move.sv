// (c) Technion IIT, Department of Electrical Engineering 2023 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updated Eyal Lev April 2023
// updated to state machine Dudy March 2023 
// update the hit and collision algoritm - Eyal Jan 2024

module	spaceship_move	(	
 
					input	 logic clk,
					input	 logic resetN,
					input	 logic startOfFrame,      //short pulse every start of frame 30Hz 
					input	 logic enable_sof,    // if want to stop the smiley move 
					input	 logic toggle_x_key,      //toggle X   
					input  logic collision,         //collision if smiley hits an object
					input  logic [3:0] HitEdgeCode, //one bit per edge
					input  logic [9:0] movement,         // move left when key is pressed
					input  logic shoot,
					
					output logic signed 	[10:0] topLeftX, // output the top left corner 
					output logic signed	[10:0] topLeftY  // can be negative , if the object is partliy outside 
					
);

// a module used to generate the ball trajectory.  
  

parameter int INITIAL_X = 280;
parameter int INITIAL_Y = 185;
parameter int INITIAL_X_SPEED = 1; // Reduced the speed for smoother movement

const int MAX_Y_SPEED = 500;
const int FIXED_POINT_MULTIPLIER = 64; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calculations,
// we divide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

// movement limits 
const int OBJECT_WIDTH_X = 32;
const int OBJECT_HEIGHT_Y = 32;
const int SafetyMargin = 2;

const int x_FRAME_LEFT = (SafetyMargin) * FIXED_POINT_MULTIPLIER; 
const int x_FRAME_RIGHT = (639 - SafetyMargin - OBJECT_WIDTH_X) * FIXED_POINT_MULTIPLIER; 
const int y_FRAME_TOP = (SafetyMargin) * FIXED_POINT_MULTIPLIER;
const int y_FRAME_BOTTOM = (479 - SafetyMargin - OBJECT_HEIGHT_Y) * FIXED_POINT_MULTIPLIER; //- OBJECT_HEIGHT_Y

typedef enum logic [2:0] {
    IDLE_ST,           // initial state
    MOVE_ST,           // moving no collision 
    START_OF_FRAME_ST, // startOfFrame activity-after all data collected 
    POSITION_CHANGE_ST,// position interpolate 
    POSITION_LIMITS_ST // check if inside the frame  
} state_t;

state_t SM_Motion;

int Xspeed; // speed     
int Xposition; // position     
int Yposition;
logic toggle_x_key_D;

logic [15:0] hit_reg; // register to collect all the collisions in the frame. |corner|left|top|right|bottom|

always_ff @(posedge clk or negedge resetN) begin : fsm_sync_proc
    if (resetN == 1'b0) begin 
        SM_Motion <= IDLE_ST; 
        Xspeed <= INITIAL_X_SPEED; // Set the initial speed
        Xposition <= 0;  
        toggle_x_key_D <= 0;
        hit_reg <= 16'b0;    
    end else begin
        toggle_x_key_D <= toggle_x_key; // shift register to detect edge 
    
        case (SM_Motion)
            //------------
            IDLE_ST: begin
                Xspeed <= INITIAL_X_SPEED; 
                Xposition <= INITIAL_X * FIXED_POINT_MULTIPLIER; 
                Yposition <= INITIAL_Y * FIXED_POINT_MULTIPLIER; 

                if (startOfFrame) 
                    SM_Motion <= MOVE_ST;
            end
    
            //------------
            MOVE_ST: begin // moving no collision               
                // collecting collisions     
                if (collision) begin
                    hit_reg[HitEdgeCode] <= 1'b1;
                end

                // Move left or right based on key press
                if (movement[4]) begin // Check if movement[4] (numpad 4) is pressed
                 
					  // Xposition <= Xposition - Xspeed * FIXED_POINT_MULTIPLIER; // Move left
						  Xspeed <= -INITIAL_X_SPEED;
                end else if (movement[6]) begin // Check if movement[6] (numpad 6) is pressed
                    //Xposition <= Xposition + Xspeed * FIXED_POINT_MULTIPLIER; // Move right
						  Xspeed <= INITIAL_X_SPEED;
                end

                if (startOfFrame) begin
                    SM_Motion <= START_OF_FRAME_ST; 					 
					end
            end 
            
            //------------
            START_OF_FRAME_ST: begin // check if any collision was detected 
                case (hit_reg)
                    16'h0000: begin // no collision in the frame 
                        Xspeed <= Xspeed;
                    end
                    //   CH       6H        3H         9H
                    16'h1000, 16'h0040, 16'h0008, 16'h0200: begin // one of the four corners     
                        Xspeed <= -Xspeed;
                    end
                    //   8H   ; (CH & 8H) ; (8H & 9H) ; (CH & 9H) ;(CH & 9H & 8H)   
                    16'h0100, 16'h1100, 16'h0300, 16'h1200, 16'h1300: begin // left side 
                        if (Xspeed < 0)
                            Xspeed <= -Xspeed;
                    end
                    //   2H  (2H & 6H) (2H & 3H) (6H & 3H )  (6H & 2H & 3H )
                    16'h0004, 16'h0044, 16'h000C, 16'h0048, 16'h004C: begin // right side 
                        if (Xspeed > 0)
                            Xspeed <= -Xspeed;
                    end
                    default: begin // complex corner 
                        Xspeed <= -Xspeed;
                    end
                endcase
                
                hit_reg <= 16'h0000; // clear for next time 
                SM_Motion <= POSITION_CHANGE_ST; 
            end 

            //------------------------
            POSITION_CHANGE_ST: begin // position interpolate 
                Xposition <= Xposition + Xspeed; 
                SM_Motion <= POSITION_LIMITS_ST; 
            end
        
            //------------------------
            POSITION_LIMITS_ST: begin // check if still inside the frame 
                if (Xposition < x_FRAME_LEFT) 
                    Xposition <= x_FRAME_LEFT; 
                if (Xposition > x_FRAME_RIGHT)
                    Xposition <= x_FRAME_RIGHT; 
					 Xspeed <= 0;
                SM_Motion <= MOVE_ST; 
            end
        endcase // case 
    end 
end // end fsm_sync

// return from FIXED point trunc back to frame size parameters 
assign topLeftX = Xposition / FIXED_POINT_MULTIPLIER; // note it must be 2^n 
assign topLeftY = Yposition / FIXED_POINT_MULTIPLIER;

endmodule
 
