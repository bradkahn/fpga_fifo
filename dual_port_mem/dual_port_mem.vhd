-------------------------------------------------------------------------------
-- NAME:        dual_port_mem.vhd
-- DESCRIPTION: Parameterized, symmetric, dual-port, asynchronous RAM.
--              Port A: write port.
--              Port B: read port.
-- AUTHOR:      Brad Kahn
-- DATE:        10/11/2017
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dual_port_mem is
  generic(
    g_DATA_WIDTH  : positive := 16;
    g_ADDR_WIDTH  : positive := 3
  );
  port (
    -- Port A
    i_CLK_a   : in  std_logic;
    i_ADDR_a  : in  std_logic_vector(g_ADDR_WIDTH-1 downto 0);
    i_DIN_a   : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);

    -- Port B
    i_CLK_b   : in  std_logic;
    i_ADDR_b  : in  std_logic_vector(g_ADDR_WIDTH-1 downto 0);
    o_DOUT_b  : out std_logic_vector(g_DATA_WIDTH-1 downto 0)
  );
end entity;

architecture behavior of dual_port_mem is

  type t_mem_type is array ((2**g_ADDR_WIDTH)-1 downto 0) of std_logic_vector(g_DATA_WIDTH-1 downto 0);
  signal r_memory : t_mem_type := (others=>(others=>'0'));

begin

  port_a : process(i_CLK_a)
  begin
    if rising_edge(i_CLK_a) then
      r_memory(to_integer(unsigned(i_ADDR_a))) <= i_DIN_a;
    end if;
  end process;

  port_b : process(i_CLK_b)
  begin
    if rising_edge(i_CLK_b) then
      o_DOUT_b <= r_memory(to_integer(unsigned(i_ADDR_b)));
    end if;
  end process;

end architecture;
