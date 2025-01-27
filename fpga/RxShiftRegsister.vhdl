/* RxShiftRegister.vhdl
 * Author: Andrew Streng
 * Description: Implements a Rx shift register to convert serial to parallel UART data
 */
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity RxShiftRegister is
	generic (
		RX_SIZE : integer
	);
	port(
		Clk : in std_logic;
		Reset : in std_logic;
		DataIn : in std_logic;												-- The Rx pin (Tx pin of the host)
		StartDetected : out std_logic;									-- DataReady signal indicating a start bit was detected from the host
		DataOut : out std_logic_vector(RX_SIZE - 1 downto 0); 	-- Parallel data out to be stored in RAM
		DataReady : out std_logic
	);
end entity;

architecture rtl of RxShiftRegister is

	signal previous_edge : std_logic;											-- Buffered reading of the DataIn signal
	signal data_register : std_logic_vector(RX_SIZE - 1 downto 0);
	signal random_signal : std_logic;
	signal current_frame_count : integer;										-- The current number of bits that has been sampled from DataIn

	-- Baud Rate Generator Component
	component BaudGenerator
	port (
		Clk : in std_logic;				-- Input clock from from the FPGA
		Reset : in std_logic;			-- Board reset signal
		BaudOut : out std_logic;		-- Output pulse from the baud generator
		BaudEnabled : in std_logic 	-- Signal to start the baud generator
	);
	end component;

	-- Baud Generator internal signal connections
	signal internal_clk : std_logic := Clk;
	signal internal_reset : std_logic := Reset;
	signal internal_baud_out : std_logic;
	signal internal_baud_enabled : std_logic;

begin

	-- Instantiate the Baud Component
	RxBaud: BaudGenerator
	port map (
		Clk => internal_clk,
		Reset => internal_reset,
		BaudOut => internal_baud_out,
		BaudEnabled => internal_baud_enabled
	);

	-- When a falling edge on the data line has been detected (start bit), then we need to start the Rx procedure
	detect_falling_edge : process(Reset, Clk) begin
		if Reset = '0' then
			previous_edge <= '1';
		elsif rising_edge(Clk) then
			-- If DataIn is low and previous_edge is high, then we have a falling edge (start bit)
			if previous_edge = '1' and DataIn = '0' then
				StartDetected <= '1';
			else
				previous_edge <= DataIn;
			end if;
		end if;
	end process;
	
	handle_baud_start : process(Clk) begin
		if Reset = '0' then
			internal_baud_enabled <= '0';
		elsif rising_edge(Clk) then
			if StartDetected = '1' then
				internal_baud_enabled <= '1';
			elsif DataReady = '1' then
				internal_baud_enabled <= '0';
			end if;
		end if;
	end process;

	do_rx: process(Reset, Clk) begin

		if Reset = '0' then
			random_signal <= '1';
			current_frame_count <= RX_SIZE;
			data_register <= (others => '0');
		elsif rising_edge(clk) then
			if internal_baud_out = '1' then
				-- No more data to receive, disable baud generator and reset frame count
				if current_frame_count = 0 then
					current_frame_count <= RX_SIZE;
					DataOut <= data_register;
					DataReady <= '1';
				else
					-- If the baud generator has pulsed, then sample DataIn and append to the data register
					data_register <= DataIn & data_register(data_register'left downto 1);
					-- Decrement the frame count
					current_frame_count <= current_frame_count - 1;
				end if;
			end if;
		end if;
	end process;

end architecture;