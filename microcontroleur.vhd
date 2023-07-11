----------------------------------------------------------------------------------
-- Company:  University of Burgundy
-- Engineer: Lauric GEHU, GABHY KIBA
-- 
-- Create Date:    11:42:45 02/27/2023 
-- Design Name: 
-- Module Name:    microcontroleur - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity microcontroleur is
Port(RESET : in std_logic;
	  CLK : in std_logic);
end microcontroleur;

architecture Behavioral of microcontroleur is

	-- Maximum 32 instructions
	-- type INSTRUCTION_TYPE is (NOP, ADDL, ADDWF, GOTO, IFW, MOVLW); 
	subtype OPCODE is std_logic_vector(5 downto 0);
	subtype OPCODED is std_logic_vector(4 downto 0);
	
	constant NOP 	: OPCODE := "000000";
	constant ADDL	: OPCODE := "000001";
	constant ADDWF : OPCODE := "000010";
	constant GOTO  : OPCODE := "000011";
	constant IFW   : OPCODE := "000100";
	constant MOVLW : OPCODE := "000101";
	constant MOVWF : OPCODE := "000110";
	
	constant IFEQU : OPCODE := "000111";
	constant IFGT  : OPCODE := "001000";
	constant IFLT  : OPCODE := "001001";
	
	
	
	-- Index instruction (5 bits = 32 instructions)
	type flash_type is array (255 downto 0) of std_logic_vector (13 downto 0);	-- Instruction sur 14 bits
	type reg_type is array (255 downto 0) of std_logic_vector (7 downto 0);
	
	signal FLASH: flash_type;									-- Mémoire programme
	signal REG: reg_type;   									-- Mémoire RAM

	signal PROG_INDEX : std_logic_vector(7 downto 0);  -- Index de l'instruction actuelle
	signal REG_W : std_logic_vector(7 downto 0);			-- Accés rapide à l'adresse du registre de travail
	
	signal current_ins : std_logic_vector(13 downto 0); -- Instruction courante

begin


REG(0) <= REG_W;
current_ins <= FLASH(conv_integer(PROG_INDEX));

SEQUENCEUR : process(CLK, RESET)
begin

	   -- ASYNC RESET ALL REGISTRE TO 0
		if RESET = '1' then
		
			for i in 0 to 255 loop
				REG(i) <= X"00";
			end loop;
			
			PROG_INDEX <= X"00";
			REG_W <= X"00";
			
			-- Le programme suivant initialise un registre  a 10 et effectue une boucle 
			
			FLASH(0) <= MOVLW & X"0A"; -- Met 10 dans W
			FLASH(1) <= MOVWF & X"0A"; -- Met W dans registre n°10
			FLASH(2) <= MOVLW & X"01"; -- Met 5 dans W
			FLASH(3) <= ADDWF & X"0A"; -- Additionne W a registre n°10
			FLASH(4) <= MOVLW & X"15"; -- Met 20 dans W
			FLASH(5) <= IFEQU & X"0A"; -- Compare W a registre 10
			FLASH(6) <= GOTO  & X"03"; -- Va à l'instruction n°3 si registre(10) != 20
			FLASH(7) <= MOVLW & X"01";	-- Met 1 dans W
			FLASH(8) <= MOVWF & X"07"; -- Met 1 dans registre n7
			
		elsif rising_edge(CLK) then	
			case current_ins(13 downto 8) is
				when NOP => 
			
					PROG_INDEX <= PROG_INDEX + 1;
				
				when ADDL => -- Additionne le litéral au registre de travail
				
					REG_W <= REG_W + current_ins(7 downto 0);
					PROG_INDEX <= PROG_INDEX + 1;
				
				when ADDWF => -- Additionne le registre de travail à l'adresse de F
				
					REG(conv_integer(current_ins(7 downto 0))) <= REG(conv_integer(current_ins(7 downto 0))) + REG_W;
					PROG_INDEX <= PROG_INDEX + 1;
				
				when GOTO => -- Va à l'adresse X
				
					PROG_INDEX <= current_ins(7 downto 0);
				
				when IFW => -- Va à l'adresse de X si W>1
				
					if(REG_W > X"01") then
						PROG_INDEX <= current_ins(7 downto 0);
					else
						PROG_INDEX <= PROG_INDEX + 1;
					end if;
				
				when MOVLW => -- Met le litéral dans W
				
					REG_W <= current_ins(7 downto 0);
					PROG_INDEX <= PROG_INDEX + 1;
				
				when MOVWF =>
				
					REG(conv_integer(current_ins(7 downto 0))) <= REG_W;
					PROG_INDEX <= PROG_INDEX + 1;
				
				when IFEQU => 
				
					if (REG(conv_integer(current_ins(7 downto 0))) = REG_W) then
						PROG_INDEX <= PROG_INDEX + 2;
					else
						PROG_INDEX <= PROG_INDEX + 1;
					end if;
					
				when others =>
			
				end case;
		end if;

end process;


end Behavioral;

