-------------------------------------------------------------------------------
-- NAME:        fifo_tb.vhd
-- DESCRIPTION: Test bench for top-level fifo.
-- AUTHOR:      Brad Kahn
-- DATE:        12/11/2017
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_tb is
end entity;

architecture behavior of fifo_tb is


    ---------------------------------------------------------------------------
    -- Unit under test
    ---------------------------------------------------------------------------
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

    ---------------------------------------------------------------------------
    -- Inputs
    ---------------------------------------------------------------------------
    signal i_CLK_WR    : std_logic := '0';
    signal i_INC_WR    : std_logic := '0';
    signal i_RST_WR    : std_logic := '0';
    signal i_DAT_WR    : std_logic_vector(16-1 downto 0) := (others => '0');

    signal i_CLK_RD    : std_logic := '0';
    signal i_INC_RD    : std_logic := '0';
    signal i_RST_RD    : std_logic := '0';

    ---------------------------------------------------------------------------
    -- Outputs
    ---------------------------------------------------------------------------
    signal o_FULL_FLAG : std_logic;
    signal o_DAT_RD    : std_logic_vector(16-1 downto 0);
    signal o_EMPTY_FLAG: std_logic;

    ---------------------------------------------------------------------------
    -- Clock period definitions
    ---------------------------------------------------------------------------
    constant c_CLK_WR_PERIOD : time := 10 ns;
    constant c_CLK_RD_PERIOD : time := 32 ns;

    ---------------------------------------------------------------------------
    -- Test data
    ---------------------------------------------------------------------------
    type rom_type is array (0 to 15) of std_logic_vector(15 downto 0);
    -- constant c_TEST_DATA : rom_type := (x"12AB", x"34CD", x"56EF", x"ABAB",
    --                                     x"FEFE", x"4321", x"ABCD", x"BABE",
    --                                     x"DEAD", x"BEEF", x"ABCD", x"1234",
    --                                     x"5A5A", x"F0F0", x"B2AD", x"B0B0");
    constant c_TEST_DATA : rom_type := (x"f000", x"f111", x"f222", x"f333",
                                        x"f444", x"f555", x"f666", x"f777",
                                        x"f888", x"f999", x"faaa", x"fbbb",
                                        x"fccc", x"fddd", x"feee", x"ffff");


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

  write_clk : process
  begin
    i_CLK_WR  <=  '0';
    wait for c_CLK_WR_PERIOD/2;
    i_CLK_WR  <=  '1';
    wait for c_CLK_WR_PERIOD/2;
  end process;

  read_clk : process
  begin
    i_CLK_RD  <=  '0';
    wait for c_CLK_RD_PERIOD/2;
    i_CLK_RD  <=  '1';
    wait for c_CLK_RD_PERIOD/2;
  end process;


  stimulus : process
  begin

    ---------------------------------------------------------------------------
    -- Assert reset lines
    ---------------------------------------------------------------------------
    --  verify:
    --          full flag is low
    --          empty flag is high
    --          o_WR_ADDR, o_RD_ADDR, o_WR_PTR, o_RD_PTR is 0x0
    i_RST_WR  <= '1';
    i_RST_RD  <= '1';
    wait for 50 ns;
    assert o_FULL_FLAG = '0'  report "full flag did not clear after reset"    severity error;
    assert o_EMPTY_FLAG = '1' report "empty flag failed to set after reset" severity error;
    i_RST_WR  <= '0';
    i_RST_RD  <= '0';

    -- These are internal signals, can't be driven/read from this top-level.
    -- They can, however, be monitored in ISIM.
    -- assert o_WR_ADDR  = (others => '0') report "write address not set to 0x0" severity error;
    -- assert o_RD_ADDR  = (others => '0') report "read address not set to 0x0"  severity error;
    -- assert o_WR_PTR   = (others => '0') report "write pointer not set to 0x0" severity error;
    -- assert o_RD_PTR   = (others => '0') report "read pointer not set to 0x0"  severity error;

    -- TODO:drive write and read clocks for whole duration, assert en/inc lines
    --      to enable write/read.

    ---------------------------------------------------------------------------
    -- Fill FIFO
    ---------------------------------------------------------------------------
    -- verify:
    --          empty flag goes low after 1st write
    --          full flag goes high after 16th write

    -- *** NOTE: check if address 0x0 is skipped ***
    wait until (i_RST_WR and i_RST_RD) = '0';

    i_INC_WR  <= '1';
    writing : for i in 0 to 15 loop
      wait until i_CLK_WR = '1';
      i_DAT_WR  <=  c_TEST_DATA(i);
      assert o_EMPTY_FLAG = '0' report "Empty flag was not cleared after after a write" severity error;

    end loop;
    i_INC_WR  <= '0';
    wait until i_CLK_WR = '1';
    assert o_FULL_FLAG = '1' report "Full flag was not set after filling fifo contents" severity error;

    ---------------------------------------------------------------------------
    -- Empty FIFO
    ---------------------------------------------------------------------------
    -- verify:
    --          full flag goes low after 1st read
    --          empty flag goes high after 16th read

    wait until i_CLK_RD = '1';
    i_INC_RD  <= '1';
    reading : for i in 0 to 15 loop
      wait until i_CLK_RD = '1';
      wait until i_CLK_RD = '0';
      assert o_FULL_FLAG = '0' report "Full flag was not cleared after a read" severity error;
      assert o_DAT_RD = c_TEST_DATA(i) report "Extracted word [" & integer'image(to_integer(unsigned(o_DAT_RD))) &
                                              "] after count [" & integer'image(i) & "] does not match test data [" &
                                              integer'image(to_integer(unsigned(c_TEST_DATA(i)))) &"]" severity error;

    end loop;
    i_INC_RD  <= '0';
    assert o_EMPTY_FLAG = '1' report "Empty flag was not set after reading all the fifo contents" severity error;

    ---------------------------------------------------------------------------
    -- Read / write interleaving
    ---------------------------------------------------------------------------

    -- write x words
    -- try read x+1 words, on cycle x+1, there should be no change in read addr from cycle x

    wait until i_CLK_WR = '1';
    i_INC_WR <= '1';
    wait for c_CLK_WR_PERIOD;
    i_DAT_WR <= x"1234";
    wait for c_CLK_WR_PERIOD;
    i_DAT_WR <= x"5678";
    wait for c_CLK_WR_PERIOD;
    i_DAT_WR <= x"abcd";
    i_INC_WR <= '0';

    wait until i_CLK_RD = '1';
    i_INC_RD <= '1';
    wait for c_CLK_RD_PERIOD; -- pessimistic empty flag reset
    wait for c_CLK_RD_PERIOD; -- pessimistic empty flag reset
    wait for c_CLK_RD_PERIOD; -- read 1
    wait for c_CLK_RD_PERIOD; -- read 2
    wait for c_CLK_RD_PERIOD; -- read 3
    wait for c_CLK_RD_PERIOD; -- read 4 (illegal)
    i_INC_RD <= '0';


    wait;
  end process;

end behavior;
