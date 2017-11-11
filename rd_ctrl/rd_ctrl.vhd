-------------------------------------------------------------------------------
-- NAME:        rd_ctrl.vhd
-- DESCRPTION:  Controller for the read pointer and empty flag.
--              Synchronous to the read clock domain.
-- AUTHOR:      Brad Kahn
-- DATE:        11/11/2017
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rd_ctrl is
  generic (
    g_ADDR_WIDTH : positive := 4
  );
  port (
    i_CLK         : in  std_logic;
    i_RST         : in  std_logic;
    i_INC         : in  std_logic;
    i_SYNC_WR_PTR : in  std_logic_vector(g_ADDR_WIDTH downto 0);
    o_EMPTY_FLAG  : out std_logic;
    o_RD_ADDR     : out std_logic_vector(g_ADDR_WIDTH-1 downto 0);
    o_RD_PTR      : out std_logic_vector(g_ADDR_WIDTH downto 0)
  );
end entity;

architecture RTL of rd_ctrl is

  signal r_binary_addr : unsigned(g_ADDR_WIDTH downto 0) := (others => '0'); -- set to (others => '1') if address zero gets skipped
  signal s_bin_next    : unsigned(g_ADDR_WIDTH downto 0) := (others => '0');
  signal s_gray_next   : std_logic_vector(g_ADDR_WIDTH downto 0) := (others => '0');
  signal r_empty, s_empty_val  : std_logic := '0';

begin

    -----------------------------------------------------------------------------
    -- Infer binary address register
    -----------------------------------------------------------------------------
    bin_reg : process(i_CLK, i_RST)
    begin
      if i_RST = '1' then
        r_binary_addr <= (others => '0'); -- set to (others => '1') if address zero gets skipped
      elsif rising_edge(i_CLK) then
        r_binary_addr <= s_bin_next;
      end if;
    end process;

    -----------------------------------------------------------------------------
    -- Infer write pointer register
    -----------------------------------------------------------------------------
    ptr_reg : process(i_CLK, i_RST)
    begin
      if i_RST = '1' then
        o_RD_PTR <= (others => '0');
      elsif rising_edge(i_CLK) then
        o_RD_PTR <= s_gray_next;
      end if;
    end process;

    -----------------------------------------------------------------------------
    -- Infer empty flag flip-flop
    -----------------------------------------------------------------------------
    empty_flag : process(i_CLK, i_RST)
    begin
      if i_RST = '1' then
        r_empty <= '0';
      elsif rising_edge(i_CLK) then
        r_empty <= s_empty_val;
      end if;
    end process;
    o_EMPTY_FLAG <= r_empty;

  -------------------------------------------------------------------------------
  -- Binary memory write address
  -------------------------------------------------------------------------------
  o_RD_ADDR <= std_logic_vector(r_binary_addr(g_ADDR_WIDTH-1 downto 0));

  -------------------------------------------------------------------------------
  -- Gray code
  -------------------------------------------------------------------------------
  s_bin_next  <= r_binary_addr + 1 when ((i_INC and (not r_empty)) = '1') else r_binary_addr;
  s_gray_next <= std_logic_vector(shift_right(s_bin_next, 1)) xor std_logic_vector(s_bin_next);

  -------------------------------------------------------------------------------
  -- Empty flag logic
  -------------------------------------------------------------------------------
  s_empty_val  <=  '1'  when s_gray_next = i_SYNC_WR_PTR  
                        else '0';


end architecture;
