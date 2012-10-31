----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:12:57 10/31/2012 
-- Design Name: 
-- Module Name:    ARRAY - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SIMD_ARRAY is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           instr : in  STD_LOGIC_VECTOR (23 downto 0);
           data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           data_out : out  STD_LOGIC_VECTOR (7 downto 0));
end SIMD_ARRAY;

architecture Behavioral of SIMD_ARRAY is

	component node is
		Port (
			clk 						: in  STD_LOGIC;
			reset 					: in  STD_LOGIC;			
			instr 					: in  STD_LOGIC_VECTOR (NODE_IDATA_BUS-1 downto 0);
			node_state 				: out STD_LOGIC;		
			n_in						: in STD_LOGIC_VECTOR (NODE_DDATA_BUS-1 downto 0);
			s_in						: in STD_LOGIC_VECTOR (NODE_DDATA_BUS-1 downto 0);
			e_in						: in STD_LOGIC_VECTOR (NODE_DDATA_BUS-1 downto 0);
			w_in						: in STD_LOGIC_VECTOR (NODE_DDATA_BUS-1 downto 0);
			n_out						: out STD_LOGIC_VECTOR (NODE_DDATA_BUS-1 downto 0);
			s_out						: out STD_LOGIC_VECTOR (NODE_DDATA_BUS-1 downto 0);
			e_out						: out STD_LOGIC_VECTOR (NODE_DDATA_BUS-1 downto 0);
			w_out						: out STD_LOGIC_VECTOR (NODE_DDATA_BUS-1 downto 0);		
			step 						: in  STD_LOGIC;
			sr_in						: in  STD_LOGIC_VECTOR (NODE_SDATA_BUS-1 downto 0);
			sr_out					: out STD_LOGIC_VECTOR (NODE_SDATA_BUS-1 downto 0)
		);
	end component;

	constant ARRAY_COLS : integer := 3;
	constant ARRAY_ROWS : integer := 3;
	type DATA_T is array  (ARRAY_ROWS-1 downto 0) of STD_LOGIC_VECTOR ((ARRAY_COLS*8)-1 downto 0);
	type STATE_T is array (ARRAY_ROWS-1 downto 0) of STD_LOGIC_VECTOR  (ARRAY_COLS-1 downto 0);
	
	signal N_IN  : DATA_T := (others=> (others=> '0'));
	signal S_IN  : DATA_T := (others=> (others=> '0'));
	signal E_IN  : DATA_T := (others=> (others=> '0'));
	signal W_IN  : DATA_T := (others=> (others=> '0'));
	signal N_OUT : DATA_T := (others=> (others=> '0'));
	signal S_OUT : DATA_T := (others=> (others=> '0'));
	signal E_OUT : DATA_T := (others=> (others=> '0'));
	signal W_OUT : DATA_T := (others=> (others=> '0'));

	signal SR_IN  : DATA_T := (others=> (others=> '0'));
	signal SR_OUT : DATA_T := (others=> (others=> '0'));

	signal STATE : STATE_T := (others=> (others=> '0'));

--	signal step  : STD_LOGIC := '0';
--	signal instr : STD_LOGIC_VECTOR (NODE_IDATA_BUS-1 downto 0) := (others=> '0');
	

begin	
	-- GENERATE ALL ROWS
	GEN_ROWS : for row in 0 to ARRAY_ROWS-1 generate
		
		-- GENERATE ALL COLS
		GEN_COLS : for col in 0 to ARRAY_COLS-1 generate
		
			GEN_NODE : if row=0 generate

				ARR_NODE: NODE port map (
					clk 				=> clk,
					reset 			=> reset,
					instr 			=> instr,
					node_state 		=> STATE( row   )((col*8)+7 downto col*8),

					n_in				=> N_IN  ( row   )((col*8)+7 downto col*8),
					n_out				=> N_OUT ( row   )((col*8)+7 downto col*8),

					w_in				=> W_IN  ( row   )((col*8)+7 downto col*8),
					w_out				=> W_OUT ( row   )((col*8)+7 downto col*8),

					s_in				=> S_IN  ( row+1 )((col*8)+7 downto col*8),
					s_out				=> S_OUT ( row+1 )((col*8)+7 downto col*8),

					e_in				=> E_IN  ( row+1 )((col*8)+7 downto col*8),
					e_out				=> E_OUT ( row+1 )((col*8)+7 downto col*8),

					step 				=> step,
					sr_in				=> SR_IN ( row   )((col*8)+7 downto col*8),
					sr_out			=> SR_OUT( row+1 )((col*8)+7 downto col*8)
				);
			end generate LEFT;
		
		end generate GEN_COLS;
	end generate GEN_ROWS;
	
--	GEN_ARRAY:
--			for i in 1 to N-2 generate
--				NEXT_ALU1B:
--					ALU_1BIT port map (
--						X	=> X(i),
--						Y	=> Y(i),
--						LESS	=> '0',
--						BINVERT=> ALU_IN.Op2,
--						CIN	=> COUT_AUX(i-1),
--						OP1	=> ALU_IN.Op1,
--						OP0	=> ALU_IN.Op0,
--						RES	=> R_AUX(i),
--						COUT	=> COUT_AUX(i)
--					);
--			end generate;

	-- LAST COL

end Behavioral;

