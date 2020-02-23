`timescale 1ns / 1ps
//****************************************************************//
//  File name: <TB_F.v>                                  	      //
//                                                                //
//  Created by       <Alina Suon> on <04/29/19>.                  //
//  Copyright © 2019 <Alina Suon>. All rights reserved.           //
//                                                                //
//  Purpose:Testbench module for Top Level. Used to test 			//
//				functionality of UART with TramelBlaze						//
//																						//
//  In submitting this file for class work at CSULB               //
//  I am confirming that this is my work and the work             //
//  of no one else. In submitting this code I acknowledge that    //
//  plagiarism in student project work is subject to dismissal.   // 
//  from the class                                                //
//****************************************************************//
module UART_TB;
//Input
	reg clk;
	reg reset;
	reg RX;
	reg [3:0] baud;
	reg eight;
	reg parity;
	reg OHEL;
//Output
	wire TX;
	wire [15:0] WALKING_ONES;
	wire [7:0] anode;
	
//Local Declarations
	integer z = 0;
	reg [9:0] DATA;

// Instantiate the Unit Under Test (UUT)
	Project3_TopLevel uut (
		.clk(clk), 
		.reset(reset), 
		.RX(RX), 
		.baud(baud), 
		.eight(eight), 
		.parity(parity), 
		.OHEL(OHEL), 
		.TX(TX), 
		.WALKING_ONES(WALKING_ONES), 
		.anode(anode)
	);
	
	always #10 clk = ~clk;

	initial 
		begin
//Initialize inputs
			clk = 0;
			z = 0;
			reset = 1;
			RX = 1;
			baud = 0;
			eight = 0;
			parity = 0;
			OHEL = 0;
			DATA = 10'b0100111011;

//Wait 100 ns for global reset to finish
			#100;
			baud = 4'hB;
			eight = 1;
			parity = 0;
			OHEL = 0;
			reset = 0;
			
//Wait to transmit banner and prompt
			#1100000; 
			
			for(z = 0; z <= 9; z = z + 1)
				begin
					RX = DATA[z];
					#1000;
				end
			RX = 1;
		end
endmodule

