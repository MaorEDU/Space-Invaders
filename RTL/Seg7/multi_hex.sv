module multi_hex_display(
    input logic [4:0] hex1,       // First hexadecimal digit
    input logic [4:0] hex2,       // Second hexadecimal digit
    input logic [4:0] hex3,       // Third hexadecimal digit
    input logic [4:0] hex4,       // Fourth hexadecimal digit
    input logic [4:0] hex5,       // Fifth hexadecimal digit
    input logic [4:0] hex6,       // Sixth hexadecimal digit
    output logic [6:0] segments1, // 7-segment display segments for the first digit
    output logic [6:0] segments2, // 7-segment display segments for the second digit
    output logic [6:0] segments3, // 7-segment display segments for the third digit
    output logic [6:0] segments4, // 7-segment display segments for the fourth digit
    output logic [6:0] segments5, // 7-segment display segments for the fifth digit
    output logic [6:0] segments6  // 7-segment display segments for the sixth digit
);

    // Instantiate the hex_to_7segment module for each digit
    hexss display1 (
        .hexin(4'h0),
        .ss(segments1)
    );

    hexss display2 (
        .hexin(4'h0),
        .ss(segments2)
    );

    hexss display3 (
        .hexin(4'h0),
        .ss(segments3)
    );

    hexss display4 (
        .hexin(5'd17), //display -
        .ss(segments4)
    );

    hexss display5 ( //display 1
        .hexin(4'h1),
        .ss(segments5)
    );

    hexss display6 ( //display p
        .hexin(5'd16),
        .ss(segments6)
    );

endmodule
