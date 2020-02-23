`timescale 1ns / 1ps
//****************************************************************//
//  File name: <AISO.v>                                           //
//                                                                //
//  Created by       <Alina Suon> on <04/29/19>.                  //
//  Copyright © 2019 <Alina Suon>. All rights reserved.           //
//                                                                //
//  Purpose:This module helps with the timing constraint          //
//          violations of the clock. Sends a signal to rst all    // 
//          the design logic When rst is a 0, the clock will be   // 
//          in line with rst making it synchronous. When rst      // 
//          is a 1, the clock will not be in line with            //
//          rst making it asynchronous.  	   						   //
//                                                                //
//  In submitting this file for class work at CSULB               //
//  I am confirming that this is my work and the work             //
//  of no one else. In submitting this code I acknowledge that    //
//  plagiarism in student project work is subject to dismissal.   // 
//  from the class                                                //
//****************************************************************//
module AISO(clk, rst, sync_rst);
//Input
	input  clk, rst;
//Output
	output sync_rst;
	reg Q, Q_Meta;

//Sequential Logic	
	always @(posedge clk or posedge rst)
		{Q_Meta, Q} <= (rst == 1'b1)?{1'b0, 1'b0}:{1'b1, Q_Meta};

	assign sync_rst = ~Q;
	 
endmodule
