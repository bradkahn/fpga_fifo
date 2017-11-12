-------------------------------------------------------------------------------
-- NAME:        dual_port_mem_tb.vhd
-- DESCRIPTION: Testbench for dual port memory component.
-- AUTHOR:      Brad Kahn
-- DATE:        10/11/2017
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dual_port_mem_tb is
end entity;

architecture behavior of dual_port_mem_tb is


    ---------------------------------------------------------------------------
    -- Unit under test
    ---------------------------------------------------------------------------
    component dual_port_mem
    port(
      i_CLK_a   : in  std_logic;
      i_CLKEN_a : in  std_logic;
      i_ADDR_a  : in  std_logic_vector(3-1 downto 0);
      i_DIN_a   : in  std_logic_vector(16-1 downto 0);
      i_CLK_b   : in  std_logic;
      i_ADDR_b  : in  std_logic_vector(3-1 downto 0);
      o_DOUT_b  : out std_logic_vector(16-1 downto 0)
    );
    end component;

    ---------------------------------------------------------------------------
    -- Inputs
    ---------------------------------------------------------------------------
    signal i_CLK_a   : std_logic := '0';
    signal i_CLKEN_a : std_logic := '0';
    signal i_ADDR_a  : std_logic_vector(3-1 downto 0) := (others => '0');
    signal i_DIN_a   : std_logic_vector(16-1 downto 0) := (others => '0');
    signal i_CLK_b   : std_logic := '0';
    signal i_ADDR_b  : std_logic_vector(3-1 downto 0) := (others => '0');

    ---------------------------------------------------------------------------
    -- Outputs
    ---------------------------------------------------------------------------
    signal o_DOUT_b  : std_logic_vector(16-1 downto 0) := (others => '0');

    ---------------------------------------------------------------------------
    -- Clock period definitions
    ---------------------------------------------------------------------------
    constant c_CLK_A_PERIOD : time := 10 ns;
    constant c_CLK_B_PERIOD : time := 84 ns;

    ---------------------------------------------------------------------------
    -- Test data
    ---------------------------------------------------------------------------
    type rom_type is array (0 to 7) of std_logic_vector(15 downto 0);
    constant c_TEST_DATA : rom_type := (x"12AB", x"34CD", x"56EF", x"ABAB", x"FEFE", x"4321", x"ABCD", x"BABE");

  begin

    uut: dual_port_mem port map (
    i_CLK_a   => i_CLK_a,
    i_CLKEN_a => i_CLKEN_a,
    i_ADDR_a  => i_ADDR_a,
    i_DIN_a   => i_DIN_a,
    i_CLK_b   => i_CLK_b,
    i_ADDR_b  => i_ADDR_b,
    o_DOUT_b  => o_DOUT_b
    );

  stimulus : process
  begin

    ---------------------------------------------------------------------------
    -- Populate memory
    ---------------------------------------------------------------------------

    i_CLKEN_a <= '1';
    write_loop : for i in 0 to 7 loop
      i_CLK_a   <= '0';
      i_ADDR_a  <= std_logic_vector(to_unsigned(i, 3));
      i_DIN_a   <= c_TEST_DATA(i);
      wait for c_CLK_A_PERIOD / 2;
      i_CLK_a   <= '1';
      wait for c_CLK_A_PERIOD / 2;
    end loop;
    i_CLK_a   <= '0';
    i_CLKEN_a <= '0';

    ---------------------------------------------------------------------------
    -- Read memory
    ---------------------------------------------------------------------------

    read_loop : for i in 0 to 7 loop
      i_CLK_b   <= '0';
      i_ADDR_b  <= std_logic_vector(to_unsigned(i, 3));
      wait for c_CLK_B_PERIOD / 2;
      i_CLK_b <= '1';
      wait for c_CLK_B_PERIOD / 2;
      assert (o_DOUT_b = c_TEST_DATA(i)) report "Incorrect value read back from memory" severity ERROR;
    end loop;

    wait;
  end process;

end architecture;
