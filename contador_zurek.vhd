library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Prueba is
port(	
	clock50mhz:		in std_logic; -- 50 MHz clock
	reset:	in std_logic;	-- Switch 0
	frecuencia:	in std_logic; -- Switch 1
	pinInc1:	in std_logic; -- Switch 2
	pinInc2:	in std_logic; -- Switch 3
	pinInc3:	in std_logic; -- Switch 4
	pinRestar: in std_logic; -- Switch 5
	seg1: out std_logic_vector(6 downto 0); -- Right display
	seg2: out std_logic_vector(6 downto 0) -- Left display
);
end Prueba;

architecture FSM of Prueba is
	signal contador: std_logic_vector(7 downto 0) := "00000000";
   signal c2: std_logic := '1'; -- False clock to change the frequency
   signal c1: integer := 0;	 -- Counter to control the frequency
	signal cont: INTEGER := 0; -- Counter from 0 to 255
	signal inc: INTEGER := 0; -- Increasing value +-(1,2,3)
	 
	function binary_to_display(
		input: std_logic_vector(3 downto 0)) -- It takes a 4 bit length vector as an input
		return std_logic_vector is
		variable output : std_logic_vector(6 downto 0); -- Returns vector that represents an hexadecimal value on the display
	begin 
	 
		if (input = "0000") then --0
			output := "1000000";
		elsif (input = "0001") then --1
			output := "1111001";
		elsif (input = "0010") then --2
			output := "0100100";
		elsif (input = "0011") then --3 
			output := "0110000";
		elsif (input = "0100") then --4
			output := "0011001";
		elsif (input = "0101") then --5
			output := "0010010";
		elsif (input = "0110") then --6
			output := "0000010";
		elsif (input = "0111") then --7
			output := "1111000";
		elsif (input = "1000") then --8
			output := "0000000";
		elsif (input = "1001") then --9
			output := "0010000";
		elsif (input = "1010") then --A
			output := "0001000";
		elsif (input = "1011") then --B
			output := "0000011";
		elsif (input = "1100") then --C
			output := "1000110";
		elsif (input = "1101") then --D
			output := "0100001";
		elsif (input = "1110") then --E
			output := "0000100";
		elsif (input = "1111") then --F
			output := "0001110";
		end if;
		return output;
		
	end;

	begin
		clock50: process(clock50mhz)
		begin
			if (clock50mhz'event and clock50mhz='1') then
				
				c1 <= c1 + 1;
						
				if (frecuencia='1') then -- Frequency: 2 Hz
					
					if (c1 > 12500000) then
						c1 <= 0;
						c2 <= NOT c2; -- Negation of the value (0 to 1 or 1 to 0) for a signal edge		
					end if;
					
				else -- Frequency: 0.5 Hz
					
					if (c1 > 50000000) then
						c1 <= 0;
						c2 <= NOT c2;
					end if;	
					
				end if; 				
			end if;
		end process;
		 

		state_reg: process(c2)
		begin
		
			if (reset='1') then -- Resets values to 0
				contador <= "00000000";
				cont <= 0;
			elsif (c2'event and c2='1') then -- False clock signal edge
				
				if (cont = 255) then
					cont <= 0;
				end if;
				
				contador <= std_logic_vector(to_unsigned(cont, contador'length)); -- It converts the counter value into binary
				
				if (pinRestar = '1') then
					cont <= cont - inc;
				else
					cont <= cont + inc;
				end if;
				
			end if;
			
			-- Assigns the increasing value
			if (pinInc1 = '1' and pinInc2 = '0' and pinInc3 = '0') then
				inc <= 1;
			elsif (pinInc2 = '1' and pinInc1 = '0' and pinInc3 = '0') then
				inc <= 2;
			elsif (pinInc3 = '1' and pinInc1 = '0' and pinInc2 = '0') then
				inc <= 3;
			elsif ((pinInc1 = '0' and pinInc2 = '0' and pinInc3 ='0')
					or (pinInc1 = '1' and pinInc2 = '1' and pinInc3 ='0')
					or (pinInc1 = '1' and pinInc2 = '0' and pinInc3 ='1')
					or (pinInc1 = '0' and pinInc2 = '1' and pinInc3 ='1')
					or (pinInc1 = '1' and pinInc2 = '1' and pinInc3 ='1')) then
				inc <= 0;
			end if;
				
		end process;
	 

		comb_logic: process(cont)
		begin
			-- When it commutes it changes to the corresponding value
			-- Ex: 240 in Hex is 0xF0, in binary is 1111 0000
			-- 1111 represents the F and the 0000 represents the 0
			if (c2 = '1') then
				seg1 <= binary_to_display(contador(3 downto 0)); -- Right display
				seg2 <= binary_to_display(contador(7 downto 4)); -- Left display 
			end if;

		end process;

end FSM;
