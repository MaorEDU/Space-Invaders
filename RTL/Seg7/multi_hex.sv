module multi_hex_display(
	 input logic resetN,
	 input logic monsterHit,
	 input logic clk,
    output logic [6:0] segments1, // 7-segment display segments for the first digit
    output logic [6:0] segments2, // 7-segment display segments for the second digit
    output logic [6:0] segments3, // 7-segment display segments for the third digit
    output logic [6:0] segments4, // 7-segment display segments for the fourth digit
    output logic [6:0] segments5, // 7-segment display segments for the fifth digit
    output logic [6:0] segments6  // 7-segment display segments for the sixth digit
);

    // Instantiate the hex_to_7segment module for each digit
   int countOnes;
	int countTens;
	int countHunderd;
	always_ff@(posedge clk or negedge resetN)
   begin
	if(!resetN) begin
			countOnes <= 0;
			countTens <= 0;
			countHunderd <= 0;
	end
	
	else begin
		if (monsterHit && countOnes == 0) begin
			countOnes <= 5;
			end
		 else if ( monsterHit && countOnes == 5) begin
			countOnes <= 0;
			countTens <= countTens +1;
			end
		 else if (monsterHit && countOnes == 5 && countTens == 9) begin
			countOnes <= 0;
			countTens <= 0;
			countHunderd <= countHunderd +1;;
			end
		end
end
	hexss display1 (
        .hexin(countOnes),
        .ss(segments1)
    );

    hexss display2 (
        .hexin(countTens),
        .ss(segments2)
    );

    hexss display3 (
        .hexin(countHunderd),
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
