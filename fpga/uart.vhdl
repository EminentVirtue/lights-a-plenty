/* Author: Andrew Streng
* Description: Top level entity for UART package 
*/

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART is
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
end entity;

architecture rtl of UART is 

	signal rx_data : std_logic_vector(UART_DATA_WIDTH - 1 downto 0);
	signal tx_data : std_logic_vector(UART_DATA_WIDTH - 1 downto 0);
	signal rx_data_detected : std_logic;
	signal tx_load_enable : std_logic;
	
	-- RxShiftRegister component declaration
	component RxShiftRegister 
	generic(RX_SIZE : integer);
	port(
		Clk : in std_logic;
		Reset : in std_logic;
		DataIn : in std_logic;
		StartDetected : out std_logic;
		DataOut : out std_logic_vector(7 downto 0)
	);
	end component;
	
	-- TxShiftRegister component declaration
	component TxShiftRegister
	generic(TX_SIZE : integer);
	port(
		Clk : in std_logic;
		Reset : in std_logic;
		DataIn : in std_logic_vector(TX_SIZE - 1 downto 0);
		DataOut : out std_logic;
		LoadEnable: in std_logic
	);
	end component;
	
begin

	-- RxShiftRegister component initialization 
	RxEntity:RxShiftRegister
	generic map(RX_SIZE => UART_DATA_WIDTH)
	port map( 
		Clk => Clk,
		Reset => Reset,
		DataIn => RxPin,
		StartDetected => rx_data_detected,
		DataOut => rx_data
	);
	
	-- TxShiftRegister component initialization 
	TxEntity:TxShiftRegister
	generic map(TX_SIZE => UART_DATA_WIDTH)
	port map (
		Clk => Clk,
		Reset => Reset,
		DataIn => tx_data,
		DataOut => TxPin,
		LoadEnable => tx_load_enable
	);

	handle_tx_data:process(Reset, Clk) begin
	end process;

	handle_rx_data:process(Reset,Clk) begin
	end process;

end architecture;