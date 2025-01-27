/* SinglePortRAM.vhdl
 * Author: Andrew Streng
 * Description: Simple single port RAM interface that will be used to store serial data LED patterns
 * that don't change often and/or have a set pattern in order to reduce traffic over the COMM port.
 */

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SinglePortRAM is 
	generic (
		DataWidth : integer;		-- The size of the data stored
		AddressWidth : integer  -- The depth of the memory
	);
	port(
		WriteEnable : in std_logic;
		ReadEnable : in std_logic;
		ReadData : out std_logic_vector(DataWidth - 1 downto 0);
		WriteData : in std_logic_vector(DataWidth - 1 downto 0);
		Address : in std_logic_vector(AddressWidth - 1 downto 0);
		Clk : in std_logic
	);
end entity;

architecture rtl of SinglePortRAM is 

	constant RAM_SIZE : integer := 40;

begin
	
	do_write : process(Clk) begin
	end process;
	
	do_read : process(Clk) begin
	end process;
end architecture;
