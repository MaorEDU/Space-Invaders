
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_spaceship,
			input	logic	drawing_request_boarders,
			input logic drawing_request_shield,

//---------------------#1-add input drawing request of box/number
		
			input logic drawing_request_projectile,
			input logic drawing_request_banana,

//---------------------#1-end input drawing request of box/number




//---------------------#2-add  drawing request of hart

		//	input	logic	drawing_request_hart,

//---------------------#2-end drawing request of hart		

			
			output logic collision, // active in case of collision between two objects
			output logic collisionBanana,
			output logic SingleHitPulse // critical code, generating A single pulse in a frame 
			
			

//---------------------#3-add collision  smiley and hart   -------------------------------------


		//	output logic collision_Smiley_Hart // active in case of collision between Smiley and hart


//---------------------#3-end collision  smiley and hart	--------------------------------------
			


);

// drawing_request_smiley   -->  smiley
// drawing_request_boarders -->  brackets
// drawing_request_number   -->  number/box 

//assign collision = (drawing_request_smiley && drawing_request_boarders);// any collision --> comment after updating with #4 or #5 

//---------------------#4-update  collision  conditions - add collision between smiley and number   ----------------------------

//assign collision = <collision_before> +<collision smiley and number>;
assign collision =  ((drawing_request_boarders && drawing_request_projectile) || (drawing_request_shield && drawing_request_projectile)) ;

//---------------------#4-end update  collision  conditions	 - add collision between smiley and number	-------------------------
	
					
						

//---------------------#5-update  collision  sconditions - add collision between smiley and hart  ---------------------------------

assign collisionBanana = ((drawing_request_boarders && drawing_request_banana)
|| (drawing_request_spaceship && drawing_request_banana) || (drawing_request_shield && drawing_request_banana));
	


//---------------------#5-end update  collision  conditions	- add collision between smiley and hart	-----------------------------
	



//-------------------------- #6-add colision between Smiley and hart-----------------

//assign collision_Smiley_Hart = ( drawing_request_smiley && drawing_request_hart ) ;


//---------------------------#6-end colision betweenand Smiley and hart-----------------



logic flag ; // a semaphore to set the output only once per frame regardless of number of collisions 
logic collision_boarders_projectile; // collision between Smiley and number - is not output
logic collision_shield_projectile;
logic collision_banana_not_monster; 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0 ; 
		
	end 
	else begin 
	
//-------------------------- #7-add colision between Smiley and number-----------------

	if (drawing_request_boarders && drawing_request_projectile && flag == 1'b0) begin
			flag <= 1'b1;
				SingleHitPulse <= 1'b1;
				collision_boarders_projectile = 1'b1;
			end

	if (drawing_request_shield && drawing_request_projectile && flag == 1'b0) begin
				flag <= 1'b1;
				SingleHitPulse <= 1'b1;
				collision_boarders_projectile = 1'b1;
			end		
	if (collisionBanana && flag == 1'b0) begin
			flag <=1'b1;
			SingleHitPulse <= 1'b1;
			collision_banana_not_monster = 1'b1;
			end
    	
			SingleHitPulse <= 1'b0 ; // default 
			if(startOfFrame) 
				flag <= 1'b0 ; // reset for next time 
				
//	---#7 - change the condition below to collision between Smiley and number ---------

	if (collision_boarders_projectile  && collision) begin 
				flag	<= 1'b1; // to enter only once 
				SingleHitPulse <= 1'b1 ; 
			end 
	if (collision_shield_projectile  && collision) begin 
				flag	<= 1'b1; // to enter only once 
				SingleHitPulse <= 1'b1 ; 
			end 
	if (collision_banana_not_monster && collisionBanana) begin
				flag <= 1'b1;
				SingleHitPulse <= 1'b1;
			end
	end 
	
end

endmodule
