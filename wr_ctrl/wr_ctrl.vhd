-------------------------------------------------------------------------------
-- NAME:        wr_ctrl.vhd
-- DESCRPTION:  Controller for the write pointer and full flag.
--              Synchronous to the write clock domain.
-- AUTHOR:      Brad Kahn
-- DATE:        10/11/2017
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wr_ctrl is
  generic(
    g_ADDR_WIDTH : positive := 4
  );
  port (
    i_CLK         : in  std_logic;
    i_RST         : in  std_logic;
    i_INC         : in  std_logic;
    i_SYNC_RD_PTR : in  std_logic_vector(g_ADDR_WIDTH downto 0);
    o_FULL_FLAG   : out std_logic;
    o_WR_ADDR     : out std_logic_vector(g_ADDR_WIDTH-1 downto 0);
    o_WR_PTR      : out std_logic_vector(g_ADDR_WIDTH downto 0)
  );
end entity;

architecture RTL of wr_ctrl is

  signal r_binary_addr : unsigned(g_ADDR_WIDTH downto 0) := (others => '0'); -- set to (others => '1') if address zero gets skipped
  signal s_bin_next    : unsigned(g_ADDR_WIDTH downto 0) := (others => '0');
  signal s_gray_next   : std_logic_vector(g_ADDR_WIDTH downto 0) := (others => '0');
  signal r_full, s_full_val  : std_logic := '0';

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
      o_WR_PTR <= (others => '0');
    elsif rising_edge(i_CLK) then
      o_WR_PTR <= s_gray_next;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Infer full flag flip-flop
  -----------------------------------------------------------------------------
  full_flag : process(i_CLK, i_RST)
  begin
    if i_RST = '1' then
      r_full <= '0';
    elsif rising_edge(i_CLK) then
      r_full <= s_full_val;
    end if;
  end process;
  o_FULL_FLAG <= r_full;

-------------------------------------------------------------------------------
-- Binary memory write address
-------------------------------------------------------------------------------
o_WR_ADDR <= std_logic_vector(r_binary_addr(g_ADDR_WIDTH-1 downto 0));

-------------------------------------------------------------------------------
-- Gray code
-------------------------------------------------------------------------------
s_bin_next  <= r_binary_addr + 1 when ((i_INC and (not r_full)) = '1') else r_binary_addr;
s_gray_next <= std_logic_vector(shift_right(s_bin_next, 1)) xor std_logic_vector(s_bin_next);

-------------------------------------------------------------------------------
-- Full flag logic
-------------------------------------------------------------------------------
s_full_val  <=  '1' when  (((s_gray_next(g_ADDR_WIDTH) ) /= (i_SYNC_RD_PTR(g_ADDR_WIDTH))) and
                          ((s_gray_next(g_ADDR_WIDTH-1)) /= (i_SYNC_RD_PTR(g_ADDR_WIDTH-1))) and
                          ((s_gray_next(g_ADDR_WIDTH-2 downto 0)) = (i_SYNC_RD_PTR(g_ADDR_WIDTH-2 downto 0))))
                    else '0';


end architecture;
