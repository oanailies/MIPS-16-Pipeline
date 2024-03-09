----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/21/2023 05:26:51 PM
-- Design Name: 
-- Module Name: lab7 - Behavioral
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

entity lab7_4 is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end lab7_4;

architecture Behavioral of lab7_4 is

component MPG is
    Port ( en : out STD_LOGIC;
           input : in STD_LOGIC;
           clock : in STD_LOGIC);
end component;

component SSD is
    Port ( clk: in STD_LOGIC;
           digits: in STD_LOGIC_VECTOR(15 downto 0);
           an: out STD_LOGIC_VECTOR(3 downto 0);
           cat: out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch
    Port ( clk: in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR(15 downto 0);
           JumpAddress : in STD_LOGIC_VECTOR(15 downto 0);
           Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           Instruction : out STD_LOGIC_VECTOR(15 downto 0);
           PCinc : out STD_LOGIC_VECTOR(15 downto 0));
end component;

component IDecode
    Port ( clk: in STD_LOGIC;
           en : in STD_LOGIC;    
           Instr : in STD_LOGIC_VECTOR(12 downto 0);
           WD : in STD_LOGIC_VECTOR(15 downto 0);
           WA: in std_logic_vector(2 downto 0);
           RegWrite : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           RD1 : out STD_LOGIC_VECTOR(15 downto 0);
           RD2 : out STD_LOGIC_VECTOR(15 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR(15 downto 0);
           func : out STD_LOGIC_VECTOR(2 downto 0);
           sa : out STD_LOGIC);
end component;

component MainControl
    Port ( Instr : in STD_LOGIC_VECTOR(2 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end component;

component ExecutionUnit is
    Port ( PCinc : in STD_LOGIC_VECTOR(15 downto 0);
           RD1 : in STD_LOGIC_VECTOR(15 downto 0);
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR(15 downto 0);
           func : in STD_LOGIC_VECTOR(2 downto 0);
           regdst:in std_logic;
           instr:in std_logic_vector(15 downto 0);
           sa : in STD_LOGIC;
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
           writeAddress:out std_logic_vector(2 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR(15 downto 0);
           ALURes : out STD_LOGIC_VECTOR(15 downto 0);
           Zero : out STD_LOGIC);
end component;

component MEM
    port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR(15 downto 0);
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
           MemWrite : in STD_LOGIC;			
           MemData : out STD_LOGIC_VECTOR(15 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(15 downto 0));
end component;



signal Instruction, PCinc, RD1, RD2, WD, Ext_imm, JumpAddress, BranchAddress, ALURes, ALURes1, MemData, digits : STD_LOGIC_VECTOR(15 downto 0); 
signal en, rst, PCSrc, sa, zero : STD_LOGIC; 
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp, func, func_reg2 : STD_LOGIC_VECTOR(2 downto 0);

signal instruction_reg1, pcinc_reg1, pcinc_reg2, RD1_reg2, RD2_reg2, Ext_Imm_reg2 : STD_LOGIC_VECTOR(15 downto 0);
signal sa_reg2 : STD_LOGIC;

signal RegDst_reg2, ExtOp_reg2, ALUSrc_reg2, Branch_reg2, Branch_reg3 : STD_LOGIC;
signal ALUOp_reg2 : STD_LOGIC_VECTOR(2 downto 0);
signal MemWrite_reg2, MemWrite_reg3, MemtoReg_reg2, MemtoReg_reg3, MemtoReg_reg4 : STD_LOGIC;
signal RegWrite_reg2, RegWrite_reg3, RegWrite_reg4 : STD_LOGIC;
signal instruction_reg2 : STD_LOGIC_VECTOR(15 downto 0);

signal BranchAddress_reg3, ALURes_reg3 : STD_LOGIC_VECTOR(15 downto 0);
signal Zero_reg3 : STD_LOGIC;
signal RD2_reg3 : STD_LOGIC_VECTOR(15 downto 0);

signal MemData_reg4, ALUResOut_reg4 : STD_LOGIC_VECTOR(15 downto 0);

signal writeaddress, writeaddress_3, writeaddress_4, WA : std_logic_vector(2 downto 0);

begin

    MPG1: MPG port map(en, btn(0), clk);
    MPG2: MPG port map(rst, btn(1), clk);
    InstructionF: IFetch port map(clk, rst, en, BranchAddress_reg3, JumpAddress, Jump, PCSrc, Instruction, PCinc);
    InstructionD: IDecode port map(clk, en, instruction_reg1(12 downto 0), WD,writeaddress_4, RegWrite_reg4, ExtOp, RD1, RD2, Ext_imm, func, sa);
    UC: MainControl port map(instruction_reg1(15 downto 13), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);
    ExecuteUnit: ExecutionUnit port map(pcinc_reg2, RD1_reg2, RD2_reg2, Ext_Imm_reg2, func_reg2,RegDst_reg2,instruction_reg2, sa_reg2, ALUSrc_reg2, ALUOp_reg2, writeaddress,BranchAddress, ALURes, Zero); 
    Memory: MEM port map(clk, en, ALURes_reg3, RD2_reg2, MemWrite_reg3, MemData, ALURes1);
    Afisor7seg : SSD port map (clk, digits, an, cat);
    
    process(clk,rst)
    begin
    if clk='1' and clk'event then
     if rst = '1' then
               instruction_reg1 <= (others => '0');
               pcinc_reg1 <= (others => '0');
               pcinc_reg2 <= (others => '0');
               RD1_reg2 <= (others => '0');
               RD2_reg2 <= (others => '0');
               Ext_Imm_reg2 <= (others => '0');
               func_reg2 <= (others => '0');
               sa_reg2 <= '0';
               instruction_reg2 <= (others => '0');
               RegDst_reg2 <= '0';
               ExtOp_reg2 <= '0';
               ALUSrc_reg2 <= '0';
               Branch_reg2 <= '0';
               Branch_reg3 <= '0';
               ALUOp_reg2 <= (others => '0');
               MemWrite_reg2 <= '0';
               MemWrite_reg3 <= '0';
               MemtoReg_reg2 <= '0';
               MemtoReg_reg3 <= '0';
               MemtoReg_reg4 <= '0';
               RegWrite_reg2 <= '0';
               RegWrite_reg3 <= '0';
               RegWrite_reg4 <= '0';
               BranchAddress_reg3 <= (others => '0');
               ALURes_reg3 <= (others => '0');
               Zero_reg3 <= '0';
               RD2_reg3 <= (others => '0');
               MemData_reg4 <= (others => '0');
               ALUResOut_reg4 <= (others => '0');
               writeaddress_3 <= (others => '0');
               writeaddress_4 <= (others => '0');
           else
        instruction_reg1<=Instruction;
        pcinc_reg1<=PCinc;
        pcinc_reg2<=pcinc_reg1;
        RD1_reg2<=RD1;
        RD2_reg2<=RD2;
        Ext_Imm_reg2<=Ext_imm;
        func_reg2<=func;
        sa_reg2<=sa;
        instruction_reg2<=instruction_reg1;
        RegDst_reg2 <=RegDst;
        ExtOp_reg2 <=ExtOp;
        ALUSrc_reg2 <=ALUSrc;
        Branch_reg2 <=Branch;
        Branch_reg3<= Branch_reg2;
        ALUOp_reg2<=ALUOp;
        MemWrite_reg2 <=MemWrite;
        MemWrite_reg3 <=MemWrite_reg2;
        MemtoReg_reg2 <=MemtoReg;
        MemtoReg_reg3 <=MemtoReg_reg2;
        MemtoReg_reg4 <=MemtoReg_reg3;
        RegWrite_reg2 <=RegWrite;
        RegWrite_reg3 <=RegWrite_reg2;
        RegWrite_reg4 <=RegWrite_reg3;
        BranchAddress_reg3<=BranchAddress;
        ALURes_reg3<=ALURes;
        Zero_reg3<=Zero;
        RD2_reg3<=RD2_reg2;
        MemData_reg4<=MemData;
        ALUResOut_reg4<=ALURes1;
        writeaddress_3<=writeaddress;
        writeaddress_4<=writeaddress_3;
    end if;
    end if;
    end process;
  
    process (MemtoReg_reg4)
    begin
        case MemtoReg_reg4 is
            when '1' =>
                WD <= MemData_reg4;
            when '0' =>
                WD <= ALUResOut_reg4;
            when others =>
                WD <= (others => '0');
        end case;
    end process;

    PCSrc <= Zero_reg3 and Branch_reg3;

    JumpAddress <= PCinc(15 downto 13) & Instruction(12 downto 0);

    process (sw)
begin
    case sw(7 downto 5) is
        when "000" =>
            digits <= Instruction;
        when "001" =>
            digits <= PCinc;
        when "010" =>
            digits <= RD1;
        when "011" =>
            digits <= RD2;
        when "100" =>
            digits <= Ext_Imm;
        when "101" =>
            digits <= ALURes;
        when "110" =>
            digits <= MemData;
        when "111" =>
            digits <= WD;
        when others =>
            digits <= (others => '0');
    end case;
end process;

    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;
    
end Behavioral;
