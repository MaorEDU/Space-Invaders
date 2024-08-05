/*module spaceship_projectile(
    input logic clk,
    input logic reset,
    input logic fire,           // Signal to fire the projectile
    input logic [9:0] ship_x,   // X position of the spaceship
    input logic [9:0] ship_y,   // Y position of the spaceship
    output logic [9:0] proj_x,  // X position of the projectile
    output logic [9:0] proj_y,  // Y position of the projectile
    output logic proj_active    // Projectile active state
);

    // Parameters for initial position and speed
    parameter int INIT_X = 0;
    parameter int INIT_Y = 0;
    parameter int SPEED_Y = 1; // Speed at which the projectile moves in the Y direction

    // Internal signals
    logic [9:0] current_x;
    logic [9:0] current_y;

    // State machine states
    typedef enum logic [1:0] {
        IDLE,
        FIRED
    } state_t;

    state_t state, next_state;

    // State machine for projectile behavior
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            current_x <= INIT_X;
            current_y <= INIT_Y;
            proj_active <= 0;
        end else begin
            state <= next_state;
            if (state == FIRED) begin
                current_y <= current_y + SPEED_Y;
            end
        end
    end

    // Next state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (fire) begin
                    next_state = FIRED;
                    current_x = ship_x; // Set the projectile's X position to the spaceship's X position
                    current_y = ship_y; // Set the projectile's Y position to the spaceship's Y position
                    proj_active = 1;
                end else begin
                    proj_active = 0; // Projectile is inactive (transparent) when not fired
                end
            end
            FIRED: begin
                if (current_y >= 1023) begin // Example condition to deactivate the projectile
                    next_state = IDLE;
                    proj_active = 0;
                end
            end
        endcase
    end

    // Output assignments
    assign proj_x = current_x;
    assign proj_y = current_y;

endmodule
*/ 