-------------------------------------------------------------------------------
-- NAME:        rd_ctrl_tb.vhd
-- DESCRIPTION: Testbench for the write controller component.
-- AUTHOR:      Brad Kahn
-- DATE:        11/11/2017
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rd_ctrl_tb is
end entity;

architecture behavior of rd_ctrl_tb is

    ---------------------------------------------------------------------------
    -- Unit under test
    ---------------------------------------------------------------------------
    component rd_ctrl
    port(
      i_CLK         : in  std_logic;
      i_RST         : in  std_logic;
      i_INC         : in  std_logic;
      i_SYNC_WR_PTR : in  std_logic_vector(4 downto 0);
      o_EMPTY_FLAG  : out std_logic;
      o_RD_ADDR     : out std_logic_vector(4-1 downto 0);
      o_RD_PTR      : out std_logic_vector(4 downto 0)
    );
    end component;

    ---------------------------------------------------------------------------
    -- Inputs
    ---------------------------------------------------------------------------
    signal i_CLK : std_logic := '0';
    signal i_RST : std_logic := '0';
    signal i_INC : std_logic := '0';
    signal i_SYNC_WR_PTR : std_logic_vector(4 downto 0) := (others => '0');

    ---------------------------------------------------------------------------
    -- Outputs
    ---------------------------------------------------------------------------
    signal o_EMPTY_FLAG : std_logic;
    signal o_RD_ADDR    : std_logic_vector(4-1 downto 0);
    signal o_RD_PTR     : std_logic_vector(4 downto 0);

    ---------------------------------------------------------------------------
    -- Clock period definitions
    ---------------------------------------------------------------------------
    constant c_CLK_PERIOD     : time := 10 ns;
    constant c_CLK_WR_PERIOD  : time := 12 ns;

  begin

    uut: rd_ctrl port map (
      i_CLK         => i_CLK,
      i_RST         => i_RST,
      i_INC         => i_INC,
      i_SYNC_WR_PTR => i_SYNC_WR_PTR,
      o_EMPTY_FLAG  => o_EMPTY_FLAG,
      o_RD_ADDR     => o_RD_ADDR,
      o_RD_PTR      => o_RD_PTR
    );

    clock : process
    begin
      i_CLK <= '0';
      wait for c_CLK_PERIOD / 2;
      i_CLK <= '1';
      wait for c_CLK_PERIOD / 2;
    end process;

  stimulus : process
  begin
    -- set write ptr to "00111" (5 words written)
    i_SYNC_WR_PTR <= "00111";
    i_INC <= '1';
    wait for c_CLK_PERIOD*5;

    wait;
  end process;

end behavior;
