//==============================================================================
// Datapath for Simon Project
//==============================================================================

`include "Memory.v"

module SimonDatapath(
	// External Inputs
	input        clk,           // Clock
	input        level,         // Switch for setting level
	input  [3:0] pattern,       // Switches for creating pattern

	// Inputs from Controller
	input     count_cnt,
	input     count_clr,

	input 	  index_cnt,
	input 	  index_clr,

	input 	  write_en,

	input 	  load_level,

	input 	  disp_mem,

	// Outputs to Controller
	output    index_lt_count,
	output 	  pattern_eq_mem,
	output 	  pattern_valid,

	// External Outputs
	output [3:0] pattern_leds   // LED outputs for pattern
);

	// Declare Local Vars Here
	reg [5:0] count = 6'b0;
	reg [5:0] index = 6'b0;
	wire [3:0] mem_read;
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
		.rst     (1'b0),
		.r_addr  (index),
		.w_addr  (count),
		.w_data  (pattern),
		.w_en    (write_en),
		.r_data  (mem_read)
	);

	//----------------------------------------------------------------------
	// Output Logic -- Set Datapath Outputs
	//----------------------------------------------------------------------

	assign index_lt_count = (index<count); // Compare index and count
	assign pattern_eq_mem = (mem_read == pattern); //Check pattern input match with memory
	assign pattern_leds = (disp_mem) ? mem_read : pattern; //Multiplexer for output leds
	
	// Check pattern input valid
	assign pattern_valid = (pattern == 4'b0001) || (pattern == 4'b0010) || (pattern == 4'b0100) || (pattern == 4'b1000) || level_reg;
endmodule
