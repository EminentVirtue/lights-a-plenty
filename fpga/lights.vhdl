/* lights.vhdl
 * Author: Andrew Streng
 * Description: Top level entity that is responsible for initializing the UART interface and 
 * parsing any messages that come over the interface from the controller MCU. It will then take this
 * data and redirect the output to the appropriate shift register controlling the designated light strand.
 */

library ieee;
use ieee.std_logic_1164.all;


entity lights is
	port(
		Clk : in std_logic;
		Reset : in std_logic;
		UART_RxPin : in std_logic;
		UART_TxPin : out std_logic
	);
end entity;


architecture rtl of lights is
	
	constant UART_DATA_WIDTH_INTERNAL : integer := 8;
	
	component UART is
		generic(UART_DATA_WIDTH : integer);
		port(
			Clk : in std_logic;
			Reset : in std_logic;
			RxData : in std_logic_vector;
			TxData : out std_logic_vector;
			RxPin : in std_logic;
			TxPin : out std_logic;
			RxMasked : in std_logic
		);
	end component;

	signal clk_internal : std_logic := Clk;
	signal reset_internal : std_logic := Reset;
	signal rx_data_internal : std_logic_vector(UART_DATA_WIDTH_INTERNAL - 1 downto 0);
	signal tx_data_internal : std_logic_vector(UART_DATA_WIDTH_INTERNAL - 1 downto 0); 
	signal rx_masked : std_logic;
begin
	-- UART component initialization
	U1: UART 
	generic map(UART_DATA_WIDTH => UART_DATA_WIDTH_INTERNAL)
	port map ( 
		Clk => clk_internal,
		Reset => Reset,
		RxData => rx_data_internal,
		TxData => tx_data_internal,
		RxPin => UART_RxPin,
		TxPin => UART_TxPin,
		RxMasked => rx_masked
	);
	
	
	synchronize_reset_signal : process(Reset) begin
	
	end process;
	-- Tx data handler
	process_tx_data : process(tx_data_internal) begin

	end process;

	-- Rx data handler
	process_rx_data : process(rx_data_internal) begin

	end process;

end architecture;
