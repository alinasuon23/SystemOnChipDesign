`timescale 1ns / 1ps
//****************************************************************//
//  File name: <Rx_Engine.v>                                      //
//                                                                //
//  Created by       <Alina Suon> on <04/29/19>.                  //
//  Copyright © 2019 <Alina Suon>. All rights reserved.           //
//                                                                //
//  Purpose: Receive Engine architecture		  						   //
//                                                                //
//  In submitting this file for class work at CSULB               //
//  I am confirming that this is my work and the work             //
//  of no one else. In submitting this code I acknowledge that    //
//  plagiarism in student project work is subject to dismissal.   // 
//  from the class                                                //
//****************************************************************//
module Rx_Engine(clk, rst, eight, parity, OHEL, READS,
					  RX, K, UART_RDATA, RX_STATUS);
	
//Input
	input 	     clk, rst, eight, parity, OHEL, READS, RX;
	input  [18:0] K;
	
//Output
	output  [7:0] UART_RDATA, RX_STATUS;
	
//State Machine	
	reg	    CURRENT_START, NEXT_START, CURRENT_DO_IT, NEXT_DO_IT;
	reg [1:0] CURRENT_STATE, NEXT_STATE;
	
//Wires and Registers
	reg	      OVFE, FERR, PERR, RXRDY, LOCAL_PARITY;
	reg   [3:0] BIT_COUNT;
	reg   [9:0]	shift_reg;
	reg   [9:0]	RIGHT_JUSTIFIED_DATA;
	reg  [18:0] BIT_TIME_COUNT;
	
	wire PARITY_MISMATCH, STOP_BIT;
	
//Done Recieving 1 Bit
	assign BTU = (CURRENT_START)?(BIT_TIME_COUNT == (K >> 1)):
						(BIT_TIME_COUNT == K);
	
//Done Recieving All Data
	assign DONE = (eight)?(parity)?(BIT_COUNT == 11):(BIT_COUNT == 10): 
						(parity)?(BIT_COUNT == 10):(BIT_COUNT == 09);
	
//Receiver Status
	assign RX_STATUS = {3'b111, OVFE, FERR, PERR, 1'b0, RXRDY};
																	
//The UART Data
	assign UART_RDATA = RIGHT_JUSTIFIED_DATA[7:0];
	
//Parity mismatched 
	assign PARITY_MISMATCH = (eight)?LOCAL_PARITY^RIGHT_JUSTIFIED_DATA[8] :
												      LOCAL_PARITY^RIGHT_JUSTIFIED_DATA[7];														
//Stop Bit
	assign STOP_BIT =  (eight)?(parity)?RIGHT_JUSTIFIED_DATA[9]:
								RIGHT_JUSTIFIED_DATA[8]:(parity) ? RIGHT_JUSTIFIED_DATA[8]: 
								RIGHT_JUSTIFIED_DATA[7];
	
//Sequential Logic
	always @(posedge clk, posedge rst) 
		begin
//State Machine
		if(rst == 1'b1) 
			begin
				CURRENT_STATE <= 2'b00;
				CURRENT_START <= 1'b0;
				CURRENT_DO_IT <= 1'b0;
			end
		else
			begin
				CURRENT_STATE <= NEXT_STATE;
				CURRENT_START <= NEXT_START;
				CURRENT_DO_IT <= NEXT_DO_IT;
			end

//RX_RDY Flop
		if(rst == 1'b1)
			RXRDY <= 1'b0;
		else if(DONE == 1'b1)
			RXRDY <= 1'b1;
		else if (READS == 1'b1)
			RXRDY <= 1'b0;
		
//Parity Error Flop
		if(rst == 1'b1)
			PERR <= 1'b0;
		else if(parity && PARITY_MISMATCH && DONE)
			PERR <= 1'b1;
		else if(READS == 1'b1)
			PERR <= 1'b0;
			
//Framing Error Flop
		if(rst == 1'b1)
			FERR <= 1'b0;
		else if(DONE && ~STOP_BIT)
			FERR <= 1'b1;
		else if(READS == 1'b1)
			FERR <= 1'b0;
			
//Overflow Error Flop
		if(rst == 1'b1)
			OVFE <= 1'b0;
		else if(DONE && RXRDY)
			OVFE <= 1'b1;
		else if(READS == 1'b1)
			OVFE <= 1'b0;
			
//Bit Time Up Signal
		if(rst == 1'b1)
			BIT_TIME_COUNT <= 19'b0;
		else 
		begin
			case({CURRENT_DO_IT, BTU})
				2'b00: BIT_TIME_COUNT <= 19'b0;
				2'b01: BIT_TIME_COUNT <= 19'b0;
				2'b10: BIT_TIME_COUNT <= BIT_TIME_COUNT + 19'b1;
				2'b11: BIT_TIME_COUNT <= 19'b0;
			endcase
		end
		
//DONE Signal
		if(rst == 1'b1)
			BIT_COUNT <= 4'b0;
		else 
		begin
			case({CURRENT_DO_IT, BTU})
				2'b00: BIT_COUNT <= 4'b0;
				2'b01: BIT_COUNT <= 4'b0;
				2'b10: BIT_COUNT <= BIT_COUNT;
				2'b11: BIT_COUNT <= BIT_COUNT + 4'b1;
			endcase
		end
		
//Shift reg
		if(rst == 1'b1)
			shift_reg <= 10'b0;
		else if(BTU && ~CURRENT_START)
			shift_reg <= {RX, shift_reg[9:1]};
	end
	
//Combinational Logic
	always @(*) 
	begin
//State Machine Next State and Next Output
		{NEXT_STATE, NEXT_START, NEXT_DO_IT} = 4'b0000;
		case(CURRENT_STATE)
			2'b00:   
				begin
				NEXT_STATE = (RX)? 2'b00:2'b01;
				NEXT_START = (RX)? 1'b0 :1'b1;
				NEXT_DO_IT = (RX)? 1'b0 :1'b1;
				end
			2'b01:   
				begin
				NEXT_STATE = (RX)? 2'b00:(BTU)? 2'b10:2'b01;
				NEXT_START = (RX)? 1'b0 :(BTU)? 1'b0 :1'b1;
				NEXT_DO_IT = (RX)? 1'b0 :(BTU)? 1'b1 :1'b1;
				end
			2'b10:   
				begin
				NEXT_STATE = (DONE)? 2'b00:2'b10;
				NEXT_START = (DONE)? 1'b0 :1'b0;
				NEXT_DO_IT = (DONE)? 1'b0 :1'b1;
				end
			default: 
				begin
				NEXT_STATE = 2'b00;
				NEXT_START = 1'b0;
				NEXT_DO_IT = 1'b0;
				end
		endcase
		
//MUX For Right Justification
		case({eight, parity})
			2'b00: RIGHT_JUSTIFIED_DATA = {2'b11,shift_reg[9:2]};
			2'b01: RIGHT_JUSTIFIED_DATA = {1'b1, shift_reg[9:1]};
			2'b10: RIGHT_JUSTIFIED_DATA = {1'b1, shift_reg[9:1]};
			2'b11: RIGHT_JUSTIFIED_DATA = shift_reg[9:0];
		endcase
		
//Local Parity
		case({eight, OHEL})
			2'b00: LOCAL_PARITY =  ^RIGHT_JUSTIFIED_DATA[6:0];
			2'b01: LOCAL_PARITY = ~^RIGHT_JUSTIFIED_DATA[6:0];
			2'b10: LOCAL_PARITY =  ^RIGHT_JUSTIFIED_DATA[7:0];
			2'b11: LOCAL_PARITY = ~^RIGHT_JUSTIFIED_DATA[7:0];
		endcase
																	
		end
endmodule
