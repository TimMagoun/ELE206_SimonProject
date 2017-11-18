//===============================================================================
// Testbench Module for Simon Controller
//===============================================================================
`timescale 1ns/100ps

`include "SimonControl.v"

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

module SimonControlTest;

	// Local Vars
	reg clk = 0;
	reg rst = 0;
	reg pattern_valid = 0;
	reg index_lt_count = 0;
	reg pattern_eq_mem = 0;
	wire count_cnt, count_clr, index_cnt, index_clr, disp_mem, w_en, load_level;
	wire [2:0] mode_leds;


	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// VCD Dump
	initial begin
		$dumpfile("SimonControlTest.vcd");
		$dumpvars;
	end

	// Simon Control Module
	SimonControl ctrl(
		.clk (clk),
		.rst (rst),
		.index_lt_count (index_lt_count),
		.pattern_eq_mem (pattern_eq_mem),
		.pattern_valid (pattern_valid),
		.count_cnt(count_cnt),
		.count_clr(count_clr),
		.index_clr(index_clr),
		.index_cnt(index_cnt),
		.disp_mem(disp_mem),
		.w_en(w_en),
		.load_level(load_level),
		.mode_leds(mode_leds)
	);

	// Main Test Logic
	initial begin
		// Reset the game
		`SET(rst, 1);
		`ASSERT_EQ(count_clr,1,"Count not cleared on reset");
		`ASSERT_EQ(load_level, 1, "Level load not 1 on reset");
		`CLOCK;
		`SET(rst, 0);
		`ASSERT_EQ(count_clr,0,"Count clear not 0");
		`ASSERT_EQ(load_level, 0, "Level load not 0");
		`ASSERT_EQ(mode_leds, LED_MODE_INPUT, "Wrong mode");

		`SET(pattern_valid, 1);
		`ASSERT_EQ(w_en, 1 , "write enable when valid pattern");
		`ASSERT_EQ(index_clr, 1, "clear index when valid pattern");
		`ASSERT_EQ(disp_mem, 0, "displaying pattern in input mode");
		
		`CLOCK;

		`SET(pattern_valid, 0);
		`ASSERT_EQ(mode_leds, LED_MODE_PLAYBACK, "mode not in playback");
		`ASSERT_EQ(disp_mem, 1, "playback not displaying mem");
		
		`SET(index_lt_count, 1)

		`ASSERT_EQ(index_cnt, 1, "not incrementing index");
		`ASSERT_EQ(index_clr, 0, "clearing index too soon");

		`CLOCK;
		`ASSERT_EQ(mode_leds, LED_MODE_PLAYBACK, "mode didn't stay in playback");

		`SET(index_lt_count, 0);
		`CLOCK;

		`SET(index_lt_count, 0);
		`SET(pattern_eq_mem, 1);

		`ASSERT_EQ(mode_leds, LED_MODE_REPEAT, "mode not in repeat");
		`ASSERT_EQ(disp_mem, 0, "not displaying switches");
		`ASSERT_EQ(index_clr, 0, "clearing without being done");
		`ASSERT_EQ(count_cnt, 1, "not incrementing count");

		`CLOCK;
		`ASSERT_EQ(mode_leds, LED_MODE_INPUT, "Did not go into input mode");	

		`SET(pattern_valid,0);
		`ASSERT_EQ(w_en, 0, "writing incorrect pattern");
		`ASSERT_EQ(disp_mem, 0, "not displaying pattern");

		`CLOCK;
		`ASSERT_EQ(mode_leds, LED_MODE_INPUT, "advanced to playback without correct pattern");

		`SET(pattern_valid, 1);
		`CLOCK;
		`SET(index_lt_count, 0);
		`CLOCK;

		`ASSERT_EQ(mode_leds, LED_MODE_REPEAT, "Mode not in repeat");

		`SET(pattern_eq_mem, 0);
		`CLOCK;
		`ASSERT_EQ(mode_leds, LED_MODE_DONE, "Mode not done after incorrect pattern");

		$finish;
	end

endmodule
