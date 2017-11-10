-------------------------------------------------------------------------------
-- NAME:        ptr_sync_tb.vhd
-- DESCRIPTION: Testbench for pointer synchronizer component.
-- AUTHOR:      Brad Kahn
-- DATE:        10/11/2017
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ptr_sync_tb is
end ptr_sync_tb;

architecture behavior of ptr_sync_tb is

  -----------------------------------------------------------------------------
  -- Unit under test
  -----------------------------------------------------------------------------
  component ptr_sync
  port(
    i_PTR_IN  : in  std_logic_vector(4-1 downto 0);
    i_CLK     : in  std_logic;
    i_RST     : in  std_logic;
    o_PTR_OUT : out std_logic_vector(4-1 downto 0)
  );
  end component;

  -----------------------------------------------------------------------------
  -- Inputs
  -----------------------------------------------------------------------------
  signal i_PTR_IN  : std_logic_vector(4-1 downto 0) := (others => '0');
  signal i_CLK     : std_logic := '0';
  signal i_RST     : std_logic := '0';

  -----------------------------------------------------------------------------
  -- Outputs
  -----------------------------------------------------------------------------
  signal o_PTR_OUT : std_logic_vector(4-1 downto 0);

  -----------------------------------------------------------------------------
  -- Clock period definitions
  -----------------------------------------------------------------------------
  constant c_CLOCK_PERIOD : time := 10 ns;

begin

  uut: ptr_sync port map (
    i_PTR_IN  => i_PTR_IN,
    i_CLK     => i_CLK,
    i_RST     => i_RST,
    o_PTR_OUT => o_PTR_OUT
  );

  clock : process
  begin
    i_CLK <= '0';
    wait for c_CLOCK_PERIOD / 2;
    i_CLK <= '1';
    wait for c_CLOCK_PERIOD / 2;
  end process;

stimulus : process
begin
  i_PTR_IN  <= "0001";
  wait for c_CLOCK_PERIOD;
  i_PTR_IN <= "0010";
  wait for c_CLOCK_PERIOD;
  i_PTR_IN <= "0011";
  wait for c_CLOCK_PERIOD;
  i_RST   <= '1';
  wait for c_CLOCK_PERIOD;
  i_RST   <= '0';


  wait;
end process;

end behavior;
