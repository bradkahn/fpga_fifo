-------------------------------------------------------------------------------
-- NAME:        wr_ctrl_tb.vhd
-- DESCRPTION:  Testbench for the write controller component.
-- AUTHOR:      Brad Kahn
-- DATE:        10/11/2017
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wr_ctrl_tb is
end entity;

architecture behavior of wr_ctrl_tb is


    ---------------------------------------------------------------------------
    -- Unit under test
    ---------------------------------------------------------------------------
    component wr_ctrl
    port(
      i_CLK         : in  std_logic;
      i_RST         : in  std_logic;
      i_INC         : in  std_logic;
      i_SYNC_RD_PTR : in  std_logic_vector(4 downto 0);
      o_FULL_FLAG   : out std_logic;
      o_WR_ADDR     : out std_logic_vector(4-1 downto 0);
      o_WR_PTR      : out std_logic_vector(4 downto 0)
    );
    end component;

    --------------------------------------------------------------------------
    -- Inputs
    ---------------------------------------------------------------------------
    signal i_CLK         : std_logic := '0';
    signal i_RST         : std_logic := '0';
    signal i_INC         : std_logic := '0';
    signal i_SYNC_RD_PTR : std_logic_vector(4 downto 0) := (others => '0');

    ---------------------------------------------------------------------------
    -- Outputs
    ---------------------------------------------------------------------------
    signal o_FULL_FLAG   : std_logic;
    signal o_WR_ADDR     : std_logic_vector(4-1 downto 0);
    signal o_WR_PTR      : std_logic_vector(4 downto 0);

    ---------------------------------------------------------------------------
    -- Clock period definitions
    ---------------------------------------------------------------------------
    constant c_CLK_PERIOD : time := 10 ns;
    constant c_CLK_RD_PERIOD : time := 12 ns;

  begin

    uut: wr_ctrl port map (
      i_CLK         => i_CLK,
      i_RST         => i_RST,
      i_INC         => i_INC,
      i_SYNC_RD_PTR => i_SYNC_RD_PTR,
      o_FULL_FLAG   => o_FULL_FLAG,
      o_WR_ADDR     => o_WR_ADDR,
      o_WR_PTR      => o_WR_PTR
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

    ---------------------------------------------------------------------------
    -- Test: verify address increases
    ---------------------------------------------------------------------------
    -- perform 16 writes, verify WR_ADDR increments and that o_FULL_FLAG is
    -- asserted.
    -- NOTE:  address goes to 0x1 on the first edge.. is addr 0x0 skipped?
    --        if so, should initialize binary addr to 0xf
    i_INC <= '1';
    wait for c_CLK_PERIOD * 16;
    -- i_INC <= '0';

    ---------------------------------------------------------------------------
    -- Test: full flag
    ---------------------------------------------------------------------------
    -- performing a read now should clear the o_FULL_FLAG, as there is space
    -- available.
    wait for 20 ns;
    i_SYNC_RD_PTR <= "00001";
    wait for c_CLK_RD_PERIOD;
    i_SYNC_RD_PTR <= "00011";
    wait for c_CLK_RD_PERIOD;
    i_SYNC_RD_PTR <= "00010";
    -- wait for c_CLK_RD_PERIOD;
    -- i_SYNC_RD_PTR <= "00110";
    -- wait for c_CLK_RD_PERIOD;
    -- i_SYNC_RD_PTR <= "00111";
    -- wait for c_CLK_RD_PERIOD;

    ---------------------------------------------------------------------------
    -- Test: reset
    ---------------------------------------------------------------------------


    wait;
  end process;

end behavior;
