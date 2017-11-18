//==============================================================================
// Datapath for Simon Project
//==============================================================================

`include "Memory.v"

module SimonDatapath(
	// External Inputs
	input        clk,           // Clock
	input        level,         // Switch for setting level
	input  [3:0] pattern,       // Switches for creating pattern

	// Datapath Control Signals
	input     count_cnt,
	input     count_clr,

	input 	  index_cnt,
	input 	  index_clr,

	input 	  write_en,

	input 	  load_level,

	input 	  disp_mem,

	// Datapath Outputs to Control
	output    index_lt_count,
	output 	  pattern_eq_mem,
	output 	  pattern_valid,

	// External Outputs
	output [3:0] pattern_leds   // LED outputs for pattern
);

	// Declare Local Vars Here
	reg [5:0] count = 6'b0;
	reg [5:0] index = 6'b0;
	reg [3:0] mem_read;
	reg level_reg;
	//----------------------------------------------------------------------
	// Internal Logic -- Manipulate Registers, ALU's, Memories Local to
	// the Datapath
	//----------------------------------------------------------------------

	always @(posedge clk) begin
		// Sequential Internal Logic Here
		if(count_clr) begin
		  	count <= 0;
		end

		if(count_cnt) begin
			count <= count+1;
		end

		if(index_clr) begin
			index <= 0;
		end

		if(index_cnt) begin
			index <= index +1;
		end

		if(load_level) begin
			level_reg <= level;
		end

	end

	// 64-entry 4-bit memory (from Memory.v) -- Fill in Ports!
	Memory mem(
		.clk     (clk),
		.rst     (0),
		.r_addr  (index),
		.w_addr  (count),
		.w_data  (pattern),
		.w_en    (write_en),
		.r_data  (mem_read)
	);

	//----------------------------------------------------------------------
	// Output Logic -- Set Datapath Outputs
	//----------------------------------------------------------------------

	always @( * ) begin
		// Compare index and count
		if(count < index) begin
		  	index_lt_count = 1;
		end
		else begin
			index_lt_count = 0;
		end

		// Check pattern input match with mem
		if(mem_read == pattern) begin
			pattern_eq_mem = 1;
		end
		else begin
			pattern_eq_mem = 0;	  
		end

		// Multiplexor for output leds
		if(disp_mem) begin
			pattern_leds = mem_read;
		end
		else begin
			pattern_leds = pattern;
		end
		
		// Check pattern input valid
		pattern_valid = (!pattern[0] & pattern[1] & pattern[2] & pattern[3]) + 
						(pattern[0] & !pattern[1] & pattern[2] & pattern[3]) + 
						(pattern[0] & pattern[1] & !pattern[2] & pattern[3]) + 
						(pattern[0] & pattern[1] & pattern[2] & !pattern[3]) + level_reg;
	end

endmodule
