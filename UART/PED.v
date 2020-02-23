`timescale 1ns / 1ps
//****************************************************************//
//  File name: <PED.v>                                            //
//                                                                //
//  Created by       <Alina Suon> on <04/29/19>.                  //
//  Copyright © 2019 <Alina Suon>. All rights reserved.           //
//                                                                //
//  Purpose: Detects the positive edge of the clock.					//
//  			 It detects the PED as the output will only 		   	//
//	 			 change on the PED.								  			   //
//                                                                //
//  In submitting this file for class work at CSULB               //
//  I am confirming that this is my work and the work             //
//  of no one else. In submitting this code I acknowledge that    //
//  plagiarism in student project work is subject to dismissal.   // 
//  from the class                                                //
//****************************************************************//
module PED(clk, rst, signal_IN, PE_signal);
//Input
	input  clk, rst, signal_IN;
//Output
	output PE_signal;	
	reg	 Q1, Q2;
//Sequential Logic
	always @(posedge clk or posedge rst)
		{Q1, Q2} <= (rst == 1'b1)? {1'b0, 1'b0}:{signal_IN, Q1};
		
	assign PE_signal = Q1 & ~Q2;

endmodule
