library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_ctrl is

  port (
    clk   : in std_logic;
    reset : in std_logic;

    swrite   : in  std_logic;
    req_data : in  std_logic;
    done     : out std_logic;

    mem_num  : out unsigned(2 downto 0);
    rd_addr  : out std_logic_vector(4 downto 0);
    wrt_addr : out std_logic_vector(4 downto 0));

end entity reg_ctrl;

architecture rtl of reg_ctrl is

  type T_STATE is (ST_INIT, ST_LISTEN, ST_FLUSH);

  -- cnt_words as 10 bit:
  -- column = cnt_words(2 downto 0)
  -- row = cnt_words(7 downto 3)

  type T_REGS is record
    cnt_words : unsigned(7 downto 0);
    state     : T_STATE;
  end record T_REGS;

  constant REGS_INIT : T_REGS := (
    cnt_words => (others => '0'),
    state     => ST_INIT
    );

  signal r, r_n : T_REGS := REGS_INIT;

  type T_COMB is record
    done     : std_logic;
    mem_num  : unsigned(2 downto 0);
    rd_addr  : std_logic_vector(4 downto 0);
    wrt_addr : std_logic_vector(4 downto 0);
  end record T_COMB;

  constant COMB_DEFAULT : T_COMB := (
    done     => '0',
    mem_num  => (others => '0'),
    rd_addr  => (others => '0'),
    wrt_addr => (others => '0')
    );

  signal c : T_COMB := COMB_DEFAULT;

  signal done_1, done_2, done_0 : std_logic := '0';
  
begin  -- architecture rtl

  mem_num  <= c.mem_num;
  done_2     <= c.done;
  rd_addr  <= c.rd_addr;
  wrt_addr <= c.wrt_addr;

  reg_comb : process(r, req_data, swrite)
    variable raddr : unsigned(7 downto 0) := (others => '0');
  -- If using in linux some 64b long data type, remember that
  -- 32b subwords inside 64b word come in reverse order
  -- So to swap each pair of incoming 32b subwords
  -- Calculate adress normally, then negate LSB
  --variable mem_num_swap_32b : unsigned(2 downto 0) := (others => '0');
  begin  -- process reg_comb
    c   <= COMB_DEFAULT;
    r_n <= r;
    case r.state is
      when ST_INIT =>
        r_n.state <= ST_LISTEN;
      when ST_LISTEN =>
        if swrite = '1' then
          c.wrt_addr <= std_logic_vector(r.cnt_words(7 downto 3));
          c.mem_num  <= r.cnt_words(2 downto 0);
          --mem_num_swap_32b    := r.cnt_words(2 downto 0);
          --mem_num_swap_32b(0) := not mem_num_swap_32b(0);
          --c.mem_num           <= mem_num_swap_32b;

          r_n.cnt_words <= r.cnt_words + 1;
        end if;  -- swrite = '1'

        if r.cnt_words = 255 then
          c.done    <= '1';
          r_n.state <= ST_FLUSH;
        end if;

      when ST_FLUSH =>
        raddr := r.cnt_words + 1;
        if req_data = '1' then
          r_n.cnt_words <= r.cnt_words + 1;
          if r.cnt_words = 255 then
            r_n.state <= ST_LISTEN;
          end if;
        end if;  -- req_data = '1'
        c.rd_addr <= std_logic_vector(raddr(7 downto 3));
        c.mem_num <= r.cnt_words(2 downto 0);
        --mem_num_swap_32b    := r.cnt_words(2 downto 0);
        --mem_num_swap_32b(0) := not mem_num_swap_32b(0);
        --c.mem_num           <= mem_num_swap_32b;

      when others => null;
    end case;

  end process;

  regseq : process(clk)
  begin  -- process regseq
    if rising_edge(clk) then
      if reset = '1' then
        r <= REGS_INIT;
        done_0 <= '0';
        done_1 <= '0';
        done <= '0';
      else
        r <= r_n;
        done_1 <= done_2;
        done_0 <= done_1;
        done <= done_0;
      end if;
    end if;
  end process;


end architecture rtl;
