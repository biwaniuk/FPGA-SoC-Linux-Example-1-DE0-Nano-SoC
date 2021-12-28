library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity comm is
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
end entity comm;

architecture rtl of comm is

  type T_AM_STATE is (ST_AM_IDLE, ST_AM_INIT, ST_AM_READ_INIT, ST_AM_READ,
                      ST_AM_WAIT_FOR_REG, ST_AM_WRT_INIT_1, ST_AM_WRT_INIT_2,
                      ST_AM_WRT, ST_AM_DONE);

  type T_AM_REGS is record
    cnt    : unsigned(31 downto 0);
    buf    : std_logic_vector(31 downto 0);
    state  : T_AM_STATE;
    status : std_logic;
  end record T_AM_REGS;

  constant AM_REGS_INIT : T_AM_REGS := (
    cnt    => (others => '0'),
    buf    => (others => '0'),
    state  => ST_AM_INIT,
    status => '0'
    );

  signal am_r, am_r_n : T_AM_REGS := AM_REGS_INIT;

  type T_AM_COMB is record
    -- Avalon
    address    : std_logic_vector(31 downto 0);
    am_read    : std_logic;
    am_write   : std_logic;
    writedata  : std_logic_vector(31 downto 0);
    burstcount : std_logic_vector(27 downto 0);

    -- Internal
    data           : std_logic_vector(31 downto 0);
    internal_reset : std_logic;
    swrite         : std_logic;
    req_data1      : std_logic;
    req_data2      : std_logic;
  end record T_AM_COMB;

  constant AM_COMB_DEFAULT : T_AM_COMB := (
    -- Avalon
    address    => (others => '0'),
    am_read    => '0',
    am_write   => '0',
    writedata  => (others => '0'),
    burstcount => (others => '0'),

    -- Internal
    data           => (others => '0'),
    internal_reset => '0',
    swrite         => '0',
    req_data1      => '0',
    req_data2      => '0'
    );

  signal c           : T_AM_COMB                     := AM_COMB_DEFAULT;
  signal id          : std_logic_vector(31 downto 0) := x"b2002019";
  signal ctrl        : std_logic_vector(1 downto 0)  := "10";  -- reset cmd, start cmd
  signal xor_key_int : std_logic_vector(31 downto 0) := (others => '0');
  signal as_read_ack : std_logic                     := '0';
  signal addr0       : std_logic_vector(31 downto 0) := (others => '0');
  signal len         : std_logic_vector(27 downto 0) := (others => '0');
  signal burstcount  : std_logic_vector(27 downto 0) := (others => '0');

begin

  avalon_master_write      <= c.am_write;
  avalon_master_read       <= c.am_read;
  avalon_master_writedata  <= c.writedata;
  avalon_master_address    <= c.address;
  avalon_master_burstcount <= c.burstcount;

  data           <= c.data;
  internal_reset <= c.internal_reset;
  swrite         <= c.swrite;
  req_data1      <= c.req_data1;
  xor_key        <= xor_key_int;
  --
  -- Avalon Master
  --

  am_comb : process (addr0, am_r, avalon_master_readdata,
                     avalon_master_readdatavalid, avalon_master_waitrequest,
                     ctrl, data_ready, len, to_send) is
  begin  -- process am_comb
    c      <= AM_COMB_DEFAULT;
    am_r_n <= am_r;
    case am_r.state is
      when ST_AM_INIT =>
        am_r_n.state     <= ST_AM_IDLE;
        c.internal_reset <= '1';

      when ST_AM_IDLE =>
        if ctrl(0) = '1' then
          am_r_n.state <= ST_AM_READ_INIT;
          am_r_n.cnt   <= resize(unsigned(len) - 1, am_r_n.cnt'length);
          c.address    <= addr0;
          c.burstcount <= len;
          c.am_read    <= '1';
        end if;

      when ST_AM_READ_INIT =>
        c.address    <= addr0;
        c.burstcount <= len;
        c.am_read    <= '1';
        if avalon_master_waitrequest = '0' then
          am_r_n.state <= ST_AM_READ;
        end if;

      when ST_AM_READ =>
        if avalon_master_readdatavalid = '1' then
          c.data      <= avalon_master_readdata;
          c.swrite    <= '1';
          am_r_n.cnt  <= am_r.cnt - 1;
          if am_r.cnt <= 0 then
            am_r_n.state <= ST_AM_WAIT_FOR_REG;
            am_r_n.cnt   <= resize(unsigned(len) - 1, am_r_n.cnt'length);
          end if;
        end if;

      when ST_AM_WAIT_FOR_REG =>
        if data_ready = '1' then
          am_r_n.state <= ST_AM_WRT_INIT_1;
        end if;

      when ST_AM_WRT_INIT_1 =>
        am_r_n.state <= ST_AM_WRT_INIT_2;
        am_r_n.buf   <= std_logic_vector(to_send);
        c.req_data1  <= '1';
        c.req_data2  <= '1';

      when ST_AM_WRT_INIT_2 =>
        c.am_write   <= '1';
        c.address    <= addr0;
        c.writedata  <= am_r.buf;
        c.burstcount <= len;

        am_r_n.buf <= am_r.buf;

        if avalon_master_waitrequest = '0' then
          am_r_n.buf   <= std_logic_vector(to_send);
          am_r_n.cnt   <= am_r.cnt - 1;  -- Decrement cnt when reading val from buf
          am_r_n.state <= ST_AM_WRT;
          c.req_data1  <= '1';
          c.req_data2  <= '1';
        end if;

      when ST_AM_WRT =>
        c.am_write  <= '1';
        c.writedata <= am_r.buf;
        am_r_n.buf  <= am_r.buf;
        if avalon_master_waitrequest = '0' then
          if am_r.cnt = 0 then
            am_r_n.state  <= ST_AM_DONE;
            am_r_n.status <= '1';
          end if;
          am_r_n.buf <= std_logic_vector(to_send);
          if am_r.cnt >= 1 then  -- If zero - then last word is already in the buffer
            am_r_n.cnt  <= am_r.cnt - 1;
            c.req_data1 <= '1';
            c.req_data2 <= '1';
          end if;
        end if;  -- avalon_master_waitrequest

      when ST_AM_DONE =>
        if ctrl(0) = '0' then
          am_r_n.state     <= ST_AM_IDLE;
          am_r_n.status    <= '0';
          c.internal_reset <= '1';
        end if;
      when others => null;
    end case;
  end process am_comb;

  am_seq : process (clock_sink_clk) is
  begin  -- process am_seq
    if rising_edge(clock_sink_clk) then  -- rising clock edge
      if ((reset_sink_reset = '1') or (ctrl(1) = '1')) then  -- synchronous reset (active high)
        am_r <= AM_REGS_INIT;
      else
        am_r <= am_r_n;
      end if;

    end if;
  end process am_seq;

--
-- Avalon Slave
--
  avalon_slave_waitrequest <= '1' when ((avalon_slave_read = '1') and (as_read_ack = '0')) or (reset_sink_reset = '1') else '0';

  as : process (clock_sink_clk) is
    variable addr : integer;
  begin  -- process as

    if rising_edge(clock_sink_clk) then  -- rising clock edge
      avalon_slave_readdata <= (others => '0');
      avalon_slave_response <= (others => '0');
      as_read_ack           <= '0';
      addr                  := to_integer(unsigned(avalon_slave_address));

      if avalon_slave_read = '1' then
        as_read_ack <= '1';
        case addr is
          when 0 =>
            avalon_slave_readdata <= id;
          when 1 =>
            avalon_slave_readdata(1 downto 0) <= ctrl;
          when 2 =>
            avalon_slave_readdata(0) <= am_r.status;
          when 5 =>
            avalon_slave_readdata <= xor_key_int;
          when others =>
            avalon_slave_response <= "11";
        end case;
      end if;

      if avalon_slave_write = '1' then
        case addr is
          when 1 =>
            ctrl <= avalon_slave_writedata(1 downto 0);
          when 3 =>
            addr0 <= avalon_slave_writedata;
          when 4 =>
            len <= avalon_slave_writedata(27 downto 0);
          when 5 =>
            xor_key_int <= avalon_slave_writedata;
          when others =>
            avalon_slave_response <= "11";
        end case;
      end if;

      if ctrl(1) = '1' then             -- turn reset off after 1 tick
        ctrl(1) <= '0';
      end if;

    end if;
  end process as;

end architecture rtl;  -- of comm
