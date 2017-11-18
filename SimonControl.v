//==============================================================================
// Control Module for Simon Project
//==============================================================================

module SimonControl(
	// External Inputs
	input        clk,           // Clock
	input        rst,           // Reset

	// Datapath Inputs
	input     index_lt_count,
	input 	  pattern_eq_mem,
	input 	  pattern_valid,

	// Datapath Control Outputs
	output    reg count_cnt,
	output	  reg count_clr,
	output	  reg index_cnt,
	output 	  reg index_clr,
	output 	  reg disp_mem,
	output 	  reg w_en,
	output 	  reg load_level,
	// External Outputs
	output reg [2:0] mode_leds
);

	// Declare Local Vars Here
	reg [1:0] state;
	reg [1:0] next_state;

	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// Declare State Names Here
	localparam STATE_INPUT = 2'd0;
	localparam STATE_PLAYBACK = 2'd1;
	localparam STATE_REPEAT = 2'd2;
	localparam STATE_DONE = 2'd3;

	// Output Combinational Logic
	always @( * ) begin

		count_clr <= rst;
		load_level <= rst;
		count_cnt <= 0;
		index_cnt <= 0;
		index_clr <= 0;
		disp_mem <= 0;
		w_en <= 0;
		mode_leds <= 3'd0;

		case (state)
		  STATE_INPUT: begin
			mode_leds <= LED_MODE_INPUT;
			w_en <= pattern_valid;
			index_clr <= pattern_valid;
		  end
		  STATE_PLAYBACK: begin
			mode_leds <= LED_MODE_PLAYBACK;
			disp_mem <= 1;
			index_cnt <= index_lt_count;
			index_clr <= !index_lt_count;
		  end
		  STATE_REPEAT: begin
			mode_leds <= LED_MODE_REPEAT;
			index_cnt <= index_lt_count & pattern_eq_mem;
			index_clr <= !pattern_eq_mem;
			count_cnt <= !index_lt_count & pattern_eq_mem;
		  end
		  STATE_DONE: begin
			mode_leds <= LED_MODE_DONE;
			disp_mem <= 1;
			index_cnt <= index_lt_count;
			index_clr <= !index_lt_count;
		  end
		endcase


	end

	// Next State Combinational Logic
	always @( * ) begin

		case (state)
		  STATE_INPUT: begin
			if (!pattern_valid) next_state = STATE_INPUT;
			else next_state = STATE_PLAYBACK;
		  end
		  STATE_PLAYBACK: begin
			if (index_lt_count) next_state = STATE_PLAYBACK;
			else next_state = STATE_REPEAT;
		  end
		  STATE_REPEAT: begin
			if (index_lt_count & pattern_eq_mem) next_state = STATE_REPEAT;
			else if (!index_lt_count & pattern_eq_mem) next_state = STATE_INPUT;
			else next_state = STATE_DONE;
		  end
		  STATE_DONE: begin
			next_state = STATE_DONE;
		  end
		endcase	

	end

	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
			// Update state to reset state
			state <= STATE_INPUT;
		end
		else begin
			// Update state to next state
			state <= next_state;
		end
	end

endmodule
