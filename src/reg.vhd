library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
  port(
    clk      : in  std_logic;
    reset    : in  std_logic;
    in_data  : in  std_logic_vector(31 downto 0);
    swrite   : in  std_logic;
    req_data : in  std_logic;
    done     : out std_logic;
    to_xor   : out unsigned(31 downto 0)
    );
end reg;

architecture rtl of reg is

  component reg_ctrl is
    port (
      clk   : in std_logic;
      reset : in std_logic;

      swrite   : in  std_logic;
      req_data : in  std_logic;
      done     : out std_logic;

      mem_num  : out unsigned(2 downto 0);
      rd_addr  : out std_logic_vector(4 downto 0);
      wrt_addr : out std_logic_vector(4 downto 0));
  end component reg_ctrl;

  component mem is
    port (
      clock     : in  std_logic;
      data      : in  std_logic_vector(31 downto 0);
      rdaddress : in  std_logic_vector(4 downto 0);
      wraddress : in  std_logic_vector(4 downto 0);
      wren      : in  std_logic;
      q         : out std_logic_vector(31 downto 0));
  end component mem;

  type T_Q is array (7 downto 0) of std_logic_vector(31 downto 0);

  signal mem_num  : unsigned(2 downto 0)         := (others => '0');
  signal rd_addr  : std_logic_vector(4 downto 0) := (others => '0');
  signal wrt_addr : std_logic_vector(4 downto 0) := (others => '0');

  signal q    : T_Q                          := (others => (others => '0'));
  signal wren : std_logic_vector(7 downto 0) := (others => '0');

begin

  ctrl : component reg_ctrl
    port map (
      clk   => clk,
      reset => reset,

      swrite   => swrite,
      req_data => req_data,
      done     => done,

      mem_num  => mem_num,
      rd_addr  => rd_addr,
      wrt_addr => wrt_addr
      );

  mem_gen : for i in 0 to 7 generate
    memx : component mem
      port map (
        clock     => clk,
        data      => in_data,
        rdaddress => rd_addr,
        wraddress => wrt_addr,
        wren      => wren(i),
        q         => q(i)
        );
  end generate mem_gen;

  to_xor <= unsigned(q(to_integer(mem_num)));

  mem_mux : process (mem_num, swrite) is
  begin  -- process mem_mux
    wren <= (others => '0');
    if swrite = '1' then
      wren(to_integer(mem_num)) <= '1';
    end if;
  end process mem_mux;

end rtl;
