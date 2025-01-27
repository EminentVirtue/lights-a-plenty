/*
 * Author: Andrew Streng
 * Description: Baud generator for UART transmissions. Based on a UART baud rate,
 * pulses will be delivered at a regular interval up to FrameCount to an Rx or Tx shift register.
 */
library ieee;
use ieee.std_logic_1164.all;


entity BaudGenerator is
	port (
		Clk : in std_logic;			-- Input clock from from the FPGA
		Reset : in std_logic;			-- Board reset signal
		BaudOut : out std_logic;		-- Output pulse from the baud generator
		BaudEnabled : in std_logic 	-- Signal to start the baud generator - active high
	);
	end entity;


architecture rtl of BaudGenerator is 

	constant BAUD_RATE : integer := 115200;
	
	/* For a UART baud rate of 115200, each clock cycle is 
	 * is 1/115200 or ~8.68 microseconds. Therefore, the required clock
	 * increments we should count before issuing a pulse on the baud clock output
	 * Assuming the 'Clk' frequency is 50 MHz 
	 * should be 8.64 microseconds / 2 ns = 434 
	 */

	constant CLOCK_CNT : integer := 434;
	signal current_clock_pulse : integer;	-- The current clock increment
	signal current_frame_count : integer;
	
	begin
	
		handle_pulse: process (Reset, Clk) begin
			if Reset = '1' then
				current_clock_pulse <= 0;
				current_frame_count <= 0;
				BaudOut <= '1';	-- Baud clock out is initially high
		
			/* Check the current clock count. If the current clock count = the
			* required clock count, then output high and restart 
			*/
			elsif rising_edge(Clk) then
				if BaudEnabled = '1' then 
					if current_clock_pulse < CLOCK_CNT then
						BaudOut <= '0';
						current_clock_pulse <= current_clock_pulse + 1;	
					else
						current_clock_pulse <= 0;
						BaudOut <= '1';
					end if;
				end if;
			end if;	
		end process;
end architecture;
