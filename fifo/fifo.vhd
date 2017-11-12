-------------------------------------------------------------------------------
-- NAME:        fifo.vhd
-- DESCRPTION:  Top-level entity for asynchronous FIFO.
-- AUTHOR:      Brad Kahn
-- DATE:        11/11/2017
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity fifo is
  generic (
    constant g_DATA_WIDTH : positive := 16;
    constant g_ADDR_WIDTH : positive := 4
  );
  port (
    -- Write Port
    i_CLK_WR    : in  std_logic;
    i_INC_WR    : in  std_logic;
    i_RST_WR    : in  std_logic;
    i_DAT_WR    : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);
    o_FULL_FLAG : out std_logic;

    -- Read Port
    i_CLK_RD    : in  std_logic;
    i_INC_RD    : in  std_logic;
    i_RST_RD    : in  std_logic;
    o_DAT_RD    : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
    o_EMPTY_FLAG: out std_logic
  );
end entity;

architecture structural of fifo is

-------------------------------------------------------------------------------
-- Interconnecting signal declarations
-------------------------------------------------------------------------------
signal s_addr_wr, s_addr_rd : std_logic_vector(g_ADDR_WIDTH-1 downto 0);
signal s_ptr_wr, s_synch_ptr_wr, s_ptr_rd, s_synch_ptr_rd : std_logic_vector(g_ADDR_WIDTH downto 0);
signal s_full_flag, s_clk_wr_en : std_logic;

-------------------------------------------------------------------------------
-- Component declarations
-------------------------------------------------------------------------------
  component ptr_sync
  generic (
    g_ADDR_WIDTH : positive := g_ADDR_WIDTH
  );
  port(
    i_PTR_IN  : in  std_logic_vector(g_ADDR_WIDTH downto 0);
    i_CLK     : in  std_logic;
    i_RST     : in  std_logic;
    o_PTR_OUT : out std_logic_vector(g_ADDR_WIDTH downto 0)
  );
  end component;

  component dual_port_mem
  generic (
    g_DATA_WIDTH : positive := g_DATA_WIDTH;
    g_ADDR_WIDTH : positive := g_ADDR_WIDTH
  );
  port(
    i_CLK_a   : in  std_logic;
    i_ADDR_a  : in  std_logic_vector(g_ADDR_WIDTH-1 downto 0);
    i_DIN_a   : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);
    i_CLK_b   : in  std_logic;
    i_ADDR_b  : in  std_logic_vector(g_ADDR_WIDTH-1 downto 0);
    o_DOUT_b  : out std_logic_vector(g_DATA_WIDTH-1 downto 0)
  );
  end component;

  component rd_ctrl
  generic (
    g_ADDR_WIDTH : positive := g_ADDR_WIDTH
  );
  port(
    i_CLK         : in  std_logic;
    i_RST         : in  std_logic;
    i_INC         : in  std_logic;
    i_SYNC_WR_PTR : in  std_logic_vector(g_ADDR_WIDTH downto 0);
    o_EMPTY_FLAG  : out std_logic;
    o_RD_ADDR     : out std_logic_vector(g_ADDR_WIDTH-1 downto 0);
    o_RD_PTR      : out std_logic_vector(g_ADDR_WIDTH downto 0)
  );
  end component;

  component wr_ctrl
  generic (
    g_ADDR_WIDTH : positive := g_ADDR_WIDTH
  );
  port(
    i_CLK         : in  std_logic;
    i_RST         : in  std_logic;
    i_INC         : in  std_logic;
    i_SYNC_RD_PTR : in  std_logic_vector(g_ADDR_WIDTH downto 0);
    o_FULL_FLAG   : out std_logic;
    o_WR_ADDR     : out std_logic_vector(g_ADDR_WIDTH-1 downto 0);
    o_WR_PTR      : out std_logic_vector(g_ADDR_WIDTH downto 0)
  );
  end component;


begin

  o_FULL_FLAG <= s_full_flag;
  s_clk_wr_en <= (i_INC_WR and (not s_full_flag));

  mem: dual_port_mem
  generic map (
    g_DATA_WIDTH => g_DATA_WIDTH,
    g_ADDR_WIDTH => g_ADDR_WIDTH
  )
  port map (
    i_CLK_a   => s_clk_wr_en,  -- check
    i_ADDR_a  => s_addr_wr,
    i_DIN_a   => i_DAT_WR,
    i_CLK_b   => i_CLK_RD,
    i_ADDR_b  => s_addr_rd,
    o_DOUT_b  => o_DAT_RD
  );

  wr_ctrllr: wr_ctrl
  generic map (
    g_ADDR_WIDTH => g_ADDR_WIDTH
  )
  port map (
    i_CLK         => i_CLK_WR,
    i_RST         => i_RST_WR,
    i_INC         => i_INC_WR,
    i_SYNC_RD_PTR => s_synch_ptr_rd,
    o_FULL_FLAG   => s_full_flag,
    o_WR_ADDR     => s_addr_wr,
    o_WR_PTR      => s_ptr_wr
  );

  rd_ctrllr: rd_ctrl
  generic map (
    g_ADDR_WIDTH => g_ADDR_WIDTH
  )
  port map (
    i_CLK         => i_CLK_RD,
    i_RST         => i_RST_RD,
    i_INC         => i_INC_RD,
    i_SYNC_WR_PTR => s_synch_ptr_wr,
    o_EMPTY_FLAG  => o_EMPTY_FLAG,
    o_RD_ADDR     => s_addr_rd,
    o_RD_PTR      => s_ptr_rd
  );

  rd_2_wr: ptr_sync
  generic map (
    g_ADDR_WIDTH => g_ADDR_WIDTH
  )
  port map (
    i_PTR_IN  => s_ptr_rd,
    i_CLK     => i_CLK_RD,
    i_RST     => i_RST_WR,
    o_PTR_OUT => s_synch_ptr_rd
  );

  wr_2_rd: ptr_sync
  generic map (
    g_ADDR_WIDTH => g_ADDR_WIDTH
  )
  port map (
    i_PTR_IN  => s_ptr_wr,
    i_CLK     => i_CLK_WR,
    i_RST     => i_RST_RD,
    o_PTR_OUT => s_synch_ptr_wr
  );

end architecture;
