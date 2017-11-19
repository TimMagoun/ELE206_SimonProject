//===============================================================================
// Testbench Module for Simon Datapath
//===============================================================================
`timescale 1ns/100ps

`include "SimonDatapath.v"

// Print an error message (MSG) if value ONE is not equal
// to value TWO.
`define ASSERT_EQ(ONE, TWO, MSG)               \
	begin                                      \
		if ((ONE) !== (TWO)) begin             \
			$display("\t[FAILURE]:%s", (MSG)); \
		end                                    \
	end #0

// Set the variable VAR to the value VALUE, printing a notification
// to the screen indicating the variable's update.
// The setting of the variable is preceeded and followed by
// a 1-timestep delay.
`define SET(VAR, VALUE) $display("Setting %s to %s...", "VAR", "VALUE"); #1; VAR = (VALUE); #1

// Cycle the clock up and then down, simulating
// a button press.
`define CLOCK $display("Pressing uclk..."); #1; clk = 1; #1; clk = 0; #1

module SimonDatapathTest;

	// Local Vars
	reg clk = 0;
	reg level = 0;
	reg [3:0] pattern = 4'b0000;

	reg count_cnt = 0;
	reg count_clr = 0;

	reg index_cnt = 0;
	reg index_clr = 0;

	reg write_en = 0;
	reg load_level = 0;
	reg disp_mem = 0;

	wire index_lt_count;
	wire pattern_eq_mem;
	wire pattern_valid;

	wire [3:0] pattern_leds;

	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// VCD Dump
	integer idx;
	initial begin
		$dumpfile("SimonDatapathTest.vcd");
		$dumpvars;
		for (idx = 0; idx < 64; idx = idx + 1) begin
			$dumpvars(0, dpath.mem.mem[idx]);
		end
	end

	// Simon DataPath Module
	SimonDatapath dpath(
		.clk     (clk),
		.level   (level),
		.pattern (pattern),

		.count_cnt (count_cnt),
		.count_clr(count_clr),

		.index_cnt(index_cnt),
		.index_clr(index_clr),

		.write_en(write_en),
		.load_level(load_level),
		.disp_mem(disp_mem),

		.index_lt_count(index_lt_count),
		.pattern_eq_mem(pattern_eq_mem),
		.pattern_valid(pattern_valid),

		.pattern_leds(pattern_leds)
	);

	// Main Test Logic
	initial begin
		
		// Test Pattern Valid Module
			//with Easy Level
		`SET(level,0);
		`SET(load_level, 1);
		`CLOCK;
		`SET(load_level, 0);
		
		`SET(pattern, 4'b0001);
		#5
		`ASSERT_EQ(pattern_valid, 1'b1, "Pattern Valid Failed for 0001");
		#5
		`SET(pattern, 4'b0010);
		#5
		`ASSERT_EQ(pattern_valid, 1'b1, "Pattern Valid Failed for 0010");
		#5
		`SET(pattern, 4'b0101);
		#5
		`ASSERT_EQ(pattern_valid, 1'b0, "Pattern Valid Failed for 0101");
		#5
		`SET(pattern, 4'b1011);
		#5
		`ASSERT_EQ(pattern_valid, 1'b0, "Pattern Valid Failed for 1011");
		#5

			//with Hard Level
		`SET(level,1);
		`SET(load_level, 1);
		`CLOCK;
		`SET(load_level, 0);
		
		`SET(pattern, 4'b0100);
		#1
		`ASSERT_EQ(pattern_valid, 1, "Pattern Valid Failed for 0001");
		#1
		`SET(pattern, 4'b0010);
		#1
		`ASSERT_EQ(pattern_valid, 1, "Pattern Valid Failed for 0010");
		#1
		`SET(pattern, 4'b1111);
		#1
		`ASSERT_EQ(pattern_valid, 1, "Pattern Valid Failed for 0101");
		#1
		`SET(pattern, 4'b1001);
		#1
		`ASSERT_EQ(pattern_valid, 1, "Pattern Valid Failed for 1011");

		`CLOCK;		

		//Test Writing to Reg File
			//Write to index 0
		`SET(count_clr, 1);
		`CLOCK;
		`SET(count_clr, 0);
		`SET(pattern, 4'b1001);
		`SET(write_en, 1);
		`CLOCK;
		`SET(write_en, 0);
		
			//Write to index 1
		`SET(count_cnt, 1);		
		`CLOCK;
		`SET(count_cnt, 0);
		`SET(pattern, 4'b0110);
		`SET(write_en, 1);
		`CLOCK;
		`SET(write_en, 0);
		`SET(count_cnt, 1);
		`CLOCK;
		`SET(count_cnt,0);
		
		`CLOCK;

		//Test Reading from Reg File and Comparing with Pattern and Display LEDS
		`SET(index_clr, 1);
		`CLOCK;
		`SET(index_clr, 0);
		`CLOCK;
		
			//Reading from Index 0
		`SET(pattern, 4'b1001); //Correct Pattern
		#1
		`ASSERT_EQ(pattern_eq_mem, 1'b1, "Pattern_eq_mem failed for 1001 at index = 0");
		`SET(disp_mem, 1);
		#1
		`ASSERT_EQ(pattern_leds, 4'b1001, "Pattern_leds - from regfile - failed for 1001 at index = 0");
		#1
		`SET(disp_mem, 0);
		#1
		`ASSERT_EQ(pattern_leds, 4'b1001, "Pattern_leds - from pattern- failed for 1001 at index = 0");
		#1
		
		`CLOCK;
		
		`SET(pattern, 4'b0111); //Wrong Pattern
		#1
		`ASSERT_EQ(pattern_eq_mem, 1'b0, "Pattern_eq_mem failed for 0111 at index = 0");
		`SET(disp_mem, 1);
		#1
		`ASSERT_EQ(pattern_leds, 4'b1001, "Pattern_leds - from regfile - failed for 1001 at index = 0");
		#1
		`SET(disp_mem, 0);
		#1
		`ASSERT_EQ(pattern_leds, 4'b0111, "Pattern_leds - from pattern- failed for 0111 at index = 0");
		#1

			//Reading from Index 1
		`SET(index_cnt, 1);
		`CLOCK;
		`SET(index_cnt,0);
		`CLOCK;
	
		`SET(pattern, 4'b0110); //Correct Pattern
		#1
		`ASSERT_EQ(pattern_eq_mem, 1'b1, "Pattern_eq_mem failed for 0110 at index = 1");
		`SET(disp_mem, 1);
		#1
		`ASSERT_EQ(pattern_leds, 4'b0110, "Pattern_leds - from regfile - failed for 0110 at index = 1");
		#1
		`SET(disp_mem, 0);
		#1
		`ASSERT_EQ(pattern_leds, 4'b0110, "Pattern_leds - from pattern- failed for 0110 at index = 1");
		#1
		
		`CLOCK;
		
		`SET(pattern, 4'b1111); //Wrong Pattern
		#1
		`ASSERT_EQ(pattern_eq_mem, 1'b0, "Pattern_eq_mem failed for 1111 at index = 1");
		`SET(disp_mem, 1);
		#1
		`ASSERT_EQ(pattern_leds, 4'b0110, "Pattern_leds - from regfile - failed for 0110 at index = 1");
		#1
		`SET(disp_mem, 0);
		#1
		`ASSERT_EQ(pattern_leds, 4'b1111, "Pattern_leds - from pattern- failed for 1111 at index = 1");
		#1


		//Testing Index_lt_count
		`SET(count_clr, 1);
		`SET(index_clr, 1);
		`CLOCK;
		`SET(count_clr,0);
		`SET(index_clr,0);
		
			//Index > Count
		`SET(index_cnt, 1);
		`CLOCK;
		`SET(index_cnt, 0);
		`ASSERT_EQ(index_lt_count, 1'b0, "Index_lt_count failed at Index = 1, Count = 0");
		#1

			//Index = Count
		`SET(count_cnt, 1);
		`CLOCK;
		`SET(count_cnt, 0);
		`ASSERT_EQ(index_lt_count, 1'b0, "Index_lt_count failed at Index = 1, Count = 1");
		#1

			//Index < Count
		`SET(count_cnt, 1);
		`CLOCK;
		`SET(count_cnt, 0);
		`ASSERT_EQ(index_lt_count, 1'b1, "Index_lt_count failed at Index = 1, Count = 2");
		#1

		$finish;
	end

endmodule
