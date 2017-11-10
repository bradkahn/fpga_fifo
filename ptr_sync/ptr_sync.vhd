-------------------------------------------------------------------------------
-- NAME:        ptr_sync.vhd
-- DESCRPTION:  Synchronizer component used to pass an n-bit pointer from one
--              clock domain to another.
-- AUTHOR:      Brad Kahn
-- DATE:        10/11/2017
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ptr_sync is
  generic(
    g_ADDR_WIDTH : positive := 4
  );
  port(
    i_PTR_IN  : in  std_logic_vector((g_ADDR_WIDTH - 1) downto 0);
    i_CLK     : in  std_logic;
    i_RST     : in  std_logic;
    o_PTR_OUT : out std_logic_vector((g_ADDR_WIDTH - 1) downto 0)
  );
end entity;

architecture RTL of ptr_sync is

  signal r_synch_reg : std_logic_vector((g_ADDR_WIDTH - 1) downto 0) := (others => '0');

begin

  process(i_CLK, i_RST)
  begin
    if i_RST = '1' then
      r_synch_reg <= (others => '0');
      o_PTR_OUT   <= (others => '0');
    elsif rising_edge(i_CLK) then
      r_synch_reg <= i_PTR_IN;
      o_PTR_OUT   <= r_synch_reg;
    end if;
  end process;

end RTL;
