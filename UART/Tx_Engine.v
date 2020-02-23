`timescale 1ns / 1ps
//****************************************************************//
//  File name: <Tx_Engine.v>                                      //
//                                                                //
//  Created by       <Alina Suon> on <04/29/19>.                  //
//  Copyright © 2019 <Alina Suon>. All rights reserved.           //
//                                                                //
//  Purpose: Transmit Engine architecture			  			    	   //
// communicates with the Tramelblaze in order to acquire          //
//          the data written from the Tramelblaze and then uses   //
//          the signal, tx, to upload the information onto the    //
//          terminal.                                             //
//  In submitting this file for class work at CSULB               //
//  I am confirming that this is my work and the work             //
//  of no one else. In submitting this code I acknowledge that    //
//  plagiarism in student project work is subject to dismissal.   // 
//  from the class                                                //
//****************************************************************//
module Tx_Engine(clk, rst, LOAD, out_port, eight, parity, OHEL,
						TXRDY, TX, K);
//Input
	input 		 clk, rst, eight, parity, LOAD, OHEL; 
	input  [7:0] out_port;
	input [18:0] K;
//Output
	output 		 TX;
	output reg	 TXRDY;
	
	wire 		   DONE, BTU;
	reg			DO_IT, LOAD_D1, B8, B7;
	reg   [3:0] BIT_COUNT;
	reg   [7:0] DATA;
	reg  [10:0]	shift_reg;
	reg  [18:0] BIT_TIME_COUNT; 

//Assign	statement
	assign BTU  = (BIT_TIME_COUNT == K);
	assign DONE = (BIT_COUNT == 11);
	assign TX = shift_reg[0];
	
//Sequential Logic	
	always @(posedge clk, posedge rst) 
	begin
		if(rst == 1'b1)
			TXRDY <= 1'b1;
		else if(DONE == 1'b1)
			TXRDY <= 1'b1;
		else if(LOAD == 1'b1)
			TXRDY <= 1'b0;
			
		if(rst == 1'b1)
			DO_IT <= 1'b0;
		else if(LOAD_D1 == 1'b1)
			DO_IT <= 1'b1;
		else if(DONE == 1'b1)
			DO_IT <= 1'b0;
		
		if(rst == 1'b1)
			DATA <= 8'b0;
		else if(LOAD == 1'b0)
			DATA <= DATA;
		else if(LOAD == 1'b1)
			DATA <= out_port;
			
		if(rst == 1'b1)
			LOAD_D1 <= 1'b0;
		else
			LOAD_D1 <= LOAD;
			
		if(rst == 1'b1)
			BIT_TIME_COUNT <= 19'b0;
		else 
			begin
				case({DO_IT, BTU})
					2'b00: BIT_TIME_COUNT <= 19'b0;
					2'b01: BIT_TIME_COUNT <= 19'b0;
					2'b10: BIT_TIME_COUNT <= BIT_TIME_COUNT + 19'b1;
					2'b11: BIT_TIME_COUNT <= 19'b0;
				endcase
			end
		
		if(rst == 1'b1)
			BIT_COUNT <= 4'b0;
		else
			begin
				case({DO_IT, BTU})
					2'b00: BIT_COUNT <= 4'b0;
					2'b01: BIT_COUNT <= 4'b0;
					2'b10: BIT_COUNT <= BIT_COUNT;
					2'b11: BIT_COUNT <= BIT_COUNT + 4'b1;
				endcase
			end
		
		if(rst == 1'b1)
			shift_reg <= 11'b11111111111;
		else if(LOAD_D1 == 1'b1) 
			begin
				shift_reg[0] <= 1'b1;
				shift_reg[1] <= 1'b0;
				shift_reg[2] <= DATA[0];
				shift_reg[3] <= DATA[1];
				shift_reg[4] <= DATA[2];
				shift_reg[5] <= DATA[3];
				shift_reg[6] <= DATA[4];
				shift_reg[7] <= DATA[5];
				shift_reg[8] <= DATA[6];
				shift_reg[9] <= B7;
				shift_reg[10]<= B8;
			end
		else if(BTU == 1'b1) 
			begin
				shift_reg[0] <= shift_reg[1];
				shift_reg[1] <= shift_reg[2];
				shift_reg[2] <= shift_reg[3];
				shift_reg[3] <= shift_reg[4];
				shift_reg[4] <= shift_reg[5];
				shift_reg[5] <= shift_reg[6];
				shift_reg[6] <= shift_reg[7];
				shift_reg[7] <= shift_reg[8];
				shift_reg[8] <= shift_reg[9];
				shift_reg[9] <= shift_reg[10];
				shift_reg[10]<= 1'b1;
			end
	end

//Combinational Logic					  
	always @ (*) 
		begin
			case({eight, parity, OHEL})
				3'd0:{B8, B7} = {1'b1, 1'b1};
				3'd1:{B8, B7} = {1'b1, 1'b1};
				3'd2:{B8, B7} = {1'b1, ^DATA[6:0]};
				3'd3:{B8, B7} = {1'b1, ~^DATA[6:0]};
				3'd4:{B8, B7} = {1'b1, DATA[7]};
				3'd5:{B8, B7} = {1'b1, DATA[7]};
				3'd6:{B8, B7} = {^DATA,  DATA[7]};
				3'd7:{B8, B7} = {~^DATA, DATA[7]};
				default:	{B8, B7} = {1'b1, 1'b1};
			endcase
		end
endmodule
