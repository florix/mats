----------------------------------------------------------------------------------
-- Engineer: 	Andrea Floridia
-- 
-- Create Date:    20:47:13 02/04/2016 
-- Design Name: 	 BIST March Algorithm - MATS
-- Module Name:    mats_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--					Controller that implements MATS March Algorithm for testing SRAM.
--					Controller has been designed with generics, in order to use any 
--					single port SRAM.
-- Dependencies: 
--
-- Revision: 
-- 			Version 1.0, High-Level Description
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


----------------------------------------------------------------------------------
----------------------------------------------------------------------------------



entity mats_controller is
	generic(	width	:	integer:=8;				-- these generic parameters depends on the SRAM used
				depth	:	integer:=256;
				addr	:	integer:=8);
	port(
			clk: in std_logic;
			reset: in std_logic;
			run: in std_logic;
			data_from: out std_logic_vector(width-1 downto 0);
			r: out std_logic;
			w: out std_logic;
			enable_ram: out std_logic;
			address_out: out std_logic_vector(addr-1 downto 0);
			data_in: out std_logic_vector(width-1 downto 0);
			data_out: in std_logic_vector(width-1 downto 0)
	);
end mats_controller;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


architecture Behavioral of mats_controller is

----------------------------------------------------------------------------------
-- Signals Declaration
----------------------------------------------------------------------------------

type state is (init, s1, s2, s3, s4, s5, s6, s7, IDLE);
signal current_state, next_state : state;
signal current_addr, next_addr: std_logic_vector(addr-1 downto 0);
signal current_data, next_data: std_logic;


begin

	Regs: process (clk, reset)
	begin
		if (reset = '1') then
			current_state <= init;
			current_addr <= (others => '0');
			current_data <=  '0';
		elsif (clk = '1' and clk'event) then
			current_state <= next_state;
			current_addr <= next_addr;
			current_data <= next_data;
		end if;
	end process;
	
	CombLogic: process (run, current_state, current_addr, current_data)
	begin
		next_addr <= current_addr;
		next_data <= current_data;
		case current_state is
			when init =>
				next_addr <= (others => '0');
				next_data <= '0';
				r <= '0';
				w <= '0';
				enable_ram <= '0';
				if (run = '1') then
					next_state <= s1;
				else 
					next_state <= init;
				end if;
				
			when s1 =>
				w <= '1';
				r <= '0';
				enable_ram <= '1';
				if (current_addr = std_logic_vector(to_unsigned(depth-1,addr))) then
						next_state <= s3;
				else
					next_state <= s2;
				end if;
			
			when s2 =>
				w <= '1';
				r <= '0';
				enable_ram <= '1';
				next_addr <= std_logic_vector(unsigned(current_addr) + 1);
				next_state <= s1;
			
			when s3 => 
				w <= '0';
				r <= '1';
				enable_ram <= '1';
				next_data <= '1';
				next_state <= s4;
			
			when s4 => 
				w <= '1';
				r <= '0';
				enable_ram <= '1';
				if (current_addr = std_logic_vector(to_unsigned(0, addr))) then
					next_state <= s6;
				else
					next_state <= s5;
				end if;
				
			when s5 => 
				w <= '0';
				r <= '1';
				enable_ram <= '1';
				next_addr <= std_logic_vector(unsigned(current_addr) - 1);
				next_state <= s3;
				
			when s6 => 
				w <= '0';
				r <= '1';
				enable_ram <= '1';
				if (current_addr = std_logic_vector(to_unsigned(depth-1, addr))) then
						next_state <= IDLE;
				else
					next_state <= s7;
				end if;
			
			when s7 => 
				w <= '0';
				r <= '1';
				enable_ram <= '1';
				next_addr <= std_logic_vector(unsigned(current_addr) + 1);
				next_state <= s6;

			when IDLE => 
				w <= '0';
				r <= '0';
				enable_ram <= '0';
				next_state <= IDLE;
				
			when others =>
				next_state <= init;
		end case;
	end process;
	
	data_in(width-1 downto 1) <= (others => '0');
	data_in(0) <= current_data;
	data_from <= data_out;
	address_out <= current_addr;



end Behavioral;

