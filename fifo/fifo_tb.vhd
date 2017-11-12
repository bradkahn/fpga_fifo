-------------------------------------------------------------------------------
-- NAME:        fifo_tb.vhd
-- DESCRIPTION: Test bench for top-level fifo.
-- AUTHOR:      Brad Kahn
-- DATE:        12/11/2017
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity fifo_tb is
end entity;

architecture behavior of fifo_tb is


    -----------------------------------------------------------------------------
    -- Unit under test
    -----------------------------------------------------------------------------
    component fifo
    port(
      i_CLK_WR    : in  std_logic;
      i_INC_WR    : in  std_logic;
      i_RST_WR    : in  std_logic;
      i_DAT_WR    : in  std_logic_vector(16-1 downto 0);
      o_FULL_FLAG : out std_logic;
      i_CLK_RD    : in  std_logic;
      i_INC_RD    : in  std_logic;
      i_RST_RD    : in  std_logic;
      o_DAT_RD    : out std_logic_vector(16-1 downto 0);
      o_EMPTY_FLAG: out std_logic
    );
    end component;

    -----------------------------------------------------------------------------
    -- Inputs
    -----------------------------------------------------------------------------
    signal i_CLK_WR    : in  std_logic := '0';
    signal i_INC_WR    : in  std_logic := '0';
    signal i_RST_WR    : in  std_logic := '0';
    signal i_DAT_WR    : in  std_logic_vector(g_DATA_WIDTH-1 downto 0) := (others => '0');

    signal i_CLK_RD    : in  std_logic := '0';
    signal i_INC_RD    : in  std_logic := '0';
    signal i_RST_RD    : in  std_logic := '0';

    -----------------------------------------------------------------------------
    -- Outputs
    -----------------------------------------------------------------------------
    signal o_FULL_FLAG : out std_logic;
    signal o_DAT_RD    : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
    signal o_EMPTY_FLAG: out std_logic;

    -----------------------------------------------------------------------------
    -- Clock period definitions
    -----------------------------------------------------------------------------
    constant c_CLK_WR_PERIOD : time := 10 ns;
    constant c_CLK_RD_PERIOD : time := 32 ns;

  begin

    uut: fifo port map (
      i_CLK_WR      => i_CLK_WR,
      i_INC_WR      => i_INC_WR,
      i_RST_WR      => i_RST_WR,
      i_DAT_WR      => i_DAT_WR,
      o_FULL_FLAG   => o_FULL_FLAG,
      i_CLK_RD      => i_CLK_RD,
      i_INC_RD      => i_INC_RD,
      i_RST_RD      => i_RST_RD,
      o_DAT_RD      => o_DAT_RD,
      o_EMPTY_FLAG  => o_EMPTY_FLAG
    );

    clock : process
    begin

    end process;

  stimulus : process
  begin



    wait;
  end process;

end behavior;
