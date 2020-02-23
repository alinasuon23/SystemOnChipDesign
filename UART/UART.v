`timescale 1ns / 1ps
//****************************************************************//
//  File name: <UART.v>                                           //
//                                                                //
//  Created by       <Alina Suon> on <04/29/19>.                  //
//  Copyright © 2019 <Alina Suon>. All rights reserved.           //
//                                                                //
//  Purpose:Instantiates the transmit engine, recieve engine and  //
//				baud decoder together.                                //
//                                                                //
//  In submitting this file for class work at CSULB               //
//  I am confirming that this is my work and the work             //
//  of no one else. In submitting this code I acknowledge that    //
//  plagiarism in student project work is subject to dismissal.   // 
//  from the class                                                //
//****************************************************************//
module UART(clk, rst, out_port, WRITES, READS, baud, RX, eight,
				parity, OHEL, UART_DS, UART_INT, TX);
//Input
	input        clk, rst, WRITES, RX, eight, parity, OHEL;
	input	 [1:0] READS;
	input  [3:0] baud;
	input  [7:0] out_port;
	
//Output	
	output       TX, UART_INT;
	output [7:0] UART_DS;
	reg    [7:0] UART_DS;

//Wire	
	wire        TXRDY, TX_PE, RX_PE;
	wire  [7:0] STATUS, UART_RDATA, RX_STATUS;
	wire [18:0] K;
	
//Assign UART_INT
	assign UART_INT = TX_PE | RX_PE;
	
//Assign Status 
	assign STATUS = {RX_STATUS[7:2], TXRDY, RX_STATUS[0]};

//(BAUD, K);
//K: Counts per bit
	baud_decoder 
		baud_decoder(.baud(baud), .K(K));

//(clk, rst, RX, eight, READS, RX, K, UART_RDATA, RX_STATUS);
	Rx_Engine 
		Rx_Engine(.clk(clk), .rst(rst), 
					  .eight(eight), .parity(parity), 
					  .OHEL(OHEL), .READS(READS[0]),.RX(RX), 
					  .K(K), 
					  .UART_RDATA(UART_RDATA), 
					  .RX_STATUS(RX_STATUS));
					  
//(clk, rst, WRITES, out_port, eight, parity, OHEL, TX, K);
	Tx_Engine
		Tx_Engine(.clk(clk), .rst(rst), 
					 .LOAD(WRITES), .out_port(out_port), 
					 .eight(eight), .parity(parity),
					 .OHEL(OHEL), .TXRDY(TXRDY), .TX(TX), 
					 .K(K));
	
//(clk, rst, signal_IN, PE_signal)	
	PED
		PED_0(.clk(clk), .rst(rst), .signal_IN(TXRDY), 
			   .PE_signal(TX_PE));
	
	PED
		PED_1(.clk(clk), .rst(rst), .signal_IN(TXRDY), 
			   .PE_signal(RX_PE));
			
//Combinational Logic
	always @(*) 
	begin
		if(READS[1] == 1'b1)
			UART_DS = STATUS;
		else if(READS[0] == 1'b1)
			UART_DS = UART_RDATA;
	end
endmodule
