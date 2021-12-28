library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gsrd is

  port (
    clock_sink_clk   : in std_logic := '0';
    reset_sink_reset : in std_logic := '0';

    avalon_master_write         : out std_logic;
    avalon_master_read          : out std_logic;
    avalon_master_readdata      : in  std_logic_vector(31 downto 0) := (others => '0');
    avalon_master_readdatavalid : in  std_logic                     := '0';
    avalon_master_writedata     : out std_logic_vector(31 downto 0);
    avalon_master_address       : out std_logic_vector(31 downto 0);
    avalon_master_waitrequest   : in  std_logic                     := '0';
    avalon_master_response      : in  std_logic_vector(1 downto 0)  := (others => '0');
    avalon_master_burstcount    : out std_logic_vector(27 downto 0);

    avalon_slave_address     : in  std_logic_vector(2 downto 0)  := (others => '0');
    avalon_slave_read        : in  std_logic                     := '0';
    avalon_slave_readdata    : out std_logic_vector(31 downto 0);
    avalon_slave_waitrequest : out std_logic                     := '1';
    avalon_slave_write       : in  std_logic                     := '0';
    avalon_slave_writedata   : in  std_logic_vector(31 downto 0) := (others => '0');
    avalon_slave_response    : out std_logic_vector(1 downto 0)
    );

end entity gsrd;

architecture df of gsrd is

  component comm is
    port (
      clock_sink_clk   : in  std_logic := '0';
      reset_sink_reset : in  std_logic := '0';
      internal_reset   : out std_logic := '0';

      avalon_master_write         : out std_logic;
      avalon_master_read          : out std_logic;
      avalon_master_readdata      : in  std_logic_vector(31 downto 0) := (others => '0');
      avalon_master_readdatavalid : in  std_logic                     := '0';
      avalon_master_writedata     : out std_logic_vector(31 downto 0);
      avalon_master_address       : out std_logic_vector(31 downto 0);
      avalon_master_waitrequest   : in  std_logic                     := '0';
      avalon_master_response      : in  std_logic_vector(1 downto 0)  := (others => '0');
      avalon_master_burstcount    : out std_logic_vector(27 downto 0);

      avalon_slave_address     : in  std_logic_vector(2 downto 0)  := (others => '0');
      avalon_slave_read        : in  std_logic                     := '0';
      avalon_slave_readdata    : out std_logic_vector(31 downto 0);
      avalon_slave_waitrequest : out std_logic                     := '1';
      avalon_slave_write       : in  std_logic                     := '0';
      avalon_slave_writedata   : in  std_logic_vector(31 downto 0) := (others => '0');
      avalon_slave_response    : out std_logic_vector(1 downto 0);

      data      : out std_logic_vector(31 downto 0) := (others => '0');
      xor_key   : out std_logic_vector(31 downto 0) := (others => '0');
      swrite    : out std_logic                     := '0';
      req_data1 : out std_logic                     := '0';

      data_ready : in std_logic;
      to_send    : in unsigned(31 downto 0)
      );

  end component comm;

  component reg is
    port (
      clk      : in  std_logic;
      reset    : in  std_logic;
      in_data  : in  std_logic_vector(31 downto 0);
      swrite   : in  std_logic;
      req_data : in  std_logic;
      done     : out std_logic;
      to_xor   : out unsigned(31 downto 0)
      );

  end component reg;

  signal int_reset              : std_logic                     := '0';
  signal comm_to_reg1_wrt       : std_logic                     := '0';
  signal comm_req_data_1        : std_logic                     := '0';
  signal reg_to_comm_data_ready : std_logic                     := '0';
  signal comm_to_reg            : std_logic_vector(31 downto 0) := (others => '0');
  signal comm_xor_key           : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_to_xor             : unsigned(31 downto 0)         := (others => '0');
  signal xor_to_comm            : unsigned(31 downto 0)         := (others => '0');

begin  -- architecture df

  comm_0 : component comm
    port map (
      clock_sink_clk   => clock_sink_clk,
      reset_sink_reset => reset_sink_reset,
      internal_reset   => int_reset,

      avalon_master_write         => avalon_master_write,
      avalon_master_read          => avalon_master_read,
      avalon_master_readdata      => avalon_master_readdata,
      avalon_master_readdatavalid => avalon_master_readdatavalid,
      avalon_master_writedata     => avalon_master_writedata,
      avalon_master_address       => avalon_master_address,
      avalon_master_waitrequest   => avalon_master_waitrequest,
      avalon_master_response      => avalon_master_response,
      avalon_master_burstcount    => avalon_master_burstcount,

      avalon_slave_address     => avalon_slave_address,
      avalon_slave_read        => avalon_slave_read,
      avalon_slave_readdata    => avalon_slave_readdata,
      avalon_slave_waitrequest => avalon_slave_waitrequest,
      avalon_slave_write       => avalon_slave_write,
      avalon_slave_writedata   => avalon_slave_writedata,
      avalon_slave_response    => avalon_slave_response,

      data      => comm_to_reg,
      xor_key   => comm_xor_key,
      swrite    => comm_to_reg1_wrt,
      req_data1 => comm_req_data_1,

      data_ready => reg_to_comm_data_ready,
      to_send    => xor_to_comm
      );

  r1 : component reg
    port map (
      clk   => clock_sink_clk,
      reset => int_reset,

      in_data  => comm_to_reg,
      swrite   => comm_to_reg1_wrt,
      req_data => comm_req_data_1,

      to_xor => reg_to_xor,
      done   => reg_to_comm_data_ready
      );

  xor_to_comm <= reg_to_xor xor unsigned(comm_xor_key);

end architecture df;
