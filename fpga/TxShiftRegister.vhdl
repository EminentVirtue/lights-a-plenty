/* TxShiftRegister.vhdl
 * Author: Andrew Streng
 * Description: Implements a TxShiftRegister to convert parallel UART data to serial data stream
*/

library ieee;
use ieee.std_logic_1164.all;


entity TxShiftRegister is
	generic(TX_SIZE : integer);
	port(
		Clk : in std_logic;
		Reset : in std_logic;
		DataIn: in std_logic_vector(TX_SIZE - 1 downto 0);
		DataOut : out std_logic;
		LoadEnable : in std_logic		-- Active low
	);

end entity;

architecture rtl of TxShiftRegister is
	
	signal empty_buffer : std_logic_vector(TX_SIZE - 1 downto 0) := (others => '0');
	signal tx_data_register : std_logic_vector(TX_SIZE - 1 downto 0);
	signal buffered_din_edge : std_logic;
	
	-- Tx Baud Rate Generator Component
	component BaudGenerator
	port (
		Clk : in std_logic;				-- Input clock from from the FPGA
		Reset : in std_logic;			-- Board reset signal
		BaudOut : out std_logic;		-- Output pulse from the baud generator
		BaudEnabled : in std_logic 	-- Signal to start the baud generator	
	);
	end component;
	
	-- Tx Baud Generator signals
	signal clk_internal : std_logic := Clk;
	signal reset_internal : std_logic := Reset;
	signal baudout_internal : std_logic;
	signal baudenabled_internal : std_logic;
	
begin

	-- Initialize the Baud Generator
	TxBaud:BaudGenerator 
	port map (
		Clk => clk_internal,
		Reset => reset_internal,
		BaudOut => baudout_internal,
		BaudEnabled => baudenabled_internal
	);
	
	
	handle_tx_data: process(Reset, Clk) begin

		if Reset = '0' then
			tx_data_register <= (others => '0');
			buffered_din_edge <= '0';
			baudenabled_internal <= '0';
		elsif rising_edge(Clk) then
		
			-- Check to see if load enable is asserted 
			if LoadEnable = '0' then 
				tx_data_register <= DataIn;
				
				-- Data has been loaded into the register, therefore we need to shift it out
				baudenabled_internal <= '1';
			end if;
				
			-- If the baud produced a pulse, shift the data out LSB first
			if baudout_internal = '1' then
			
				-- If the data register is = 0, there's nothing to transfer, so disable the baud generator 
				if tx_data_register = empty_buffer then
					baudenabled_internal <= '0';
				else
					tx_data_register <= tx_data_register(tx_data_register'left downto 1) & '0';
					DataOut <= tx_data_register(tx_data_register'right); 
				end if;
			end if;
		end if;
	end process;
end architecture;