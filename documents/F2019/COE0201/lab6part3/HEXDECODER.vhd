LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY HEXDECODER IS
	PORT(C: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	D: OUT STD_LOGIC_VECTOR(0 TO 6));
END HEXDECODER;


ARCHITECTURE HEX OF HEXDECODER IS
BEGIN

	D(0) <= C(2) OR C(0);
	D(1) <= C(2) OR (C(1) AND NOT(C(0)));
	D(2) <= C(2) OR (C(1) AND NOT(C(0)));
	D(3) <= C(2) OR (NOT(C(1)) AND C(0));
	D(4) <= C(2) OR (NOT(C(1)) AND C(0));
	D(5) <= C(2) OR C(0);
	D(6) <= C(2) OR NOT(C(1));
	


END HEX;