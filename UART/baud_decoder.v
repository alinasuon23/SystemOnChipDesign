`timescale 1ns / 1ps
//****************************************************************//
//  File name: <baud_decoder.v>                                   //
//                                                                //
//  Created by       <Alina Suon> on <04/29/19>.                  //
//  Copyright © 2019 <Alina Suon>. All rights reserved.           //
//                                                                //
//  Purpose:Allows for the selection of different baud rates      //
//          as specified by the Baud decode document				   //
//                                                                //
//  In submitting this file for class work at CSULB               //
//  I am confirming that this is my work and the work             //
//  of no one else. In submitting this code I acknowledge that    //
//  plagiarism in student project work is subject to dismissal.   // 
//  from the class                                                //
//****************************************************************//
module baud_decoder(baud, K);
//Input
	input	 	   [3:0]  baud;
//Output
	output reg [18:0] K;
	
//Combinational Logic
	always @ (*)
		case(baud)
			4'h0: K = 19'd333333;
			4'h1: K = 19'd83333; 
			4'h2: K = 19'd41667;
			4'h3: K = 19'd20833;
			4'h4: K = 19'd10417;
			4'h5: K = 19'd5208;
			4'h6: K = 19'd2604;
			4'h7: K = 19'd1736;
			4'h8: K = 19'd868;
			4'h9: K = 19'd434;
			4'hA: K = 19'd217;
			4'hB: K = 19'd109;
		default: K = 19'd333333;
		endcase

endmodule
