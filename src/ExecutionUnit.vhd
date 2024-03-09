----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/21/2023 09:30:47 PM
-- Design Name: 
-- Module Name: ExecutionUnit - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ExecutionUnit is
    Port (
         PCinc : in STD_LOGIC_VECTOR(15 downto 0);
          RD1 : in STD_LOGIC_VECTOR(15 downto 0);
          RD2 : in STD_LOGIC_VECTOR(15 downto 0);
          Ext_Imm : in STD_LOGIC_VECTOR(15 downto 0);
          func : in STD_LOGIC_VECTOR(2 downto 0);
          regdst:in std_logic;--!
          instr:in std_logic_vector(15 downto 0);--!
          sa : in STD_LOGIC;
          ALUSrc : in STD_LOGIC;
          ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
          writeAddress:out std_logic_vector(2 downto 0);
          BranchAddress : out STD_LOGIC_VECTOR(15 downto 0);
          ALURes : out STD_LOGIC_VECTOR(15 downto 0);
          Zero : out STD_LOGIC);
end ExecutionUnit;

architecture Behavioral of ExecutionUnit is

signal ALURes2 : STD_LOGIC_VECTOR(15 downto 0);
signal ALUIn2 : STD_LOGIC_VECTOR(15 downto 0);
signal ALUIn1 : STD_LOGIC_VECTOR(15 downto 0);
signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);


begin


with ALUSrc select
        ALUIn2 <= RD2 when '0', 
	              Ext_Imm when '1',
	              (others => '0') when others;
	              
	process (RegDst, Instr)
                  begin
                      case RegDst is
                          when '1' =>
                              writeAddress <= Instr(6 downto 4); -- rd
                          when '0' =>
                              writeAddress <= Instr(9 downto 7); -- rt
                          when others =>
                              writeAddress <= (others => '0'); -- unknown
                      end case;
                  end process;


process(ALUOp, func)
    begin
        case ALUOp is
            when "000" => -- R type 
                case func is
                    when "000" => ALUCtrl <= "000"; -- ADD
                    when "001" => ALUCtrl <= "001"; -- SUB
                    when "010" => ALUCtrl <= "010"; -- SLL
                    when "011" => ALUCtrl <= "011"; -- SRL
                    when "100" => ALUCtrl <= "100"; -- AND
                    when "101" => ALUCtrl <= "101"; -- OR
                    when "110" => ALUCtrl <= "110"; -- XOR
                    when "111" => ALUCtrl <= "111"; -- SLT
                    when others => ALUCtrl <= (others => '0'); -- unknown
                end case;
            when "001" => ALUCtrl <= "000"; -- +
            when "010" => ALUCtrl <= "001"; -- -
            when "101" => ALUCtrl <= "100"; -- &
            when "110" => ALUCtrl <= "101"; -- |
            when others => ALUCtrl <= (others => '0'); -- unknown
        end case;
    end process;
    
     -- ALU
       process(ALUCtrl, RD1, AluIn2, sa, ALURes2)
       begin
           case ALUCtrl  is
               when "000" => -- ADD
                   ALURes2 <= RD1 + ALUIn2;
               when "001" =>  -- SUB
                   ALURes2 <= RD1 - ALUIn2;                                    
               when "010" => -- SLL
                   case sa is
                       when '1' => ALURes2 <= ALUIn2(14 downto 0) & "0";
                       when '0' => ALURes2 <= ALUIn2;
                       when others => ALURes2 <= (others => '0');
                    end case;
               when "011" => -- SRL
                   case sa is
                       when '1' => ALURes2 <= "0" & ALUIn2(15 downto 1);
                       when '0' => ALURes2 <= ALUIn2;
                       when others => ALURes2 <= (others => '0');
                   end case;
               when "100" => -- AND
                   ALURes2<=RD1 and ALUIn2;        
               when "101" => -- OR
                   ALURes2<=RD1 or ALUIn2; 
               when "110" => -- XOR
                   ALURes2<=RD1 xor ALUIn2;        
               when "111" => -- SLT
                   if signed(RD1) < signed(ALUIn2) then
                       ALURes2 <= X"0001";
                   else 
                       ALURes2 <= X"0000";
                   end if;
               when others => -- unknown
                   ALURes2 <= (others => '0');              
           end case;
   
           -- zero detector
           case ALURes2 is
               when X"0000" => Zero <= '1';
               when others => Zero <= '0';
           end case;
       
       end process;
   
       -- ALU result
       ALURes <= ALURes2;
   
       -- generate branch address
       BranchAddress <= PCinc + Ext_Imm;


end Behavioral;
