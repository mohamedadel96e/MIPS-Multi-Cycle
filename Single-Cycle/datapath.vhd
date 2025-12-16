library ieee;
use ieee.std_logic_1164.all;


entity datapath is
		generic (
    		         nbit_width : integer := 32
   			);
    		Port (
		     clk : in  std_logic
		     );
end datapath;

architecture BEHAV of datapath is

	COMPONENT pc
		Port (
         	      clk : in  std_logic;
       	 	      input : in  std_logic_vector(nbit_width-1 downto 0);
      		      output : out  std_logic_vector(nbit_width-1 downto 0)
        	      );
	END COMPONENT;

	COMPONENT pc_adder
		Port (
         	      input : in  std_logic_vector(nbit_width-1 downto 0);
      	              output : out  std_logic_vector(nbit_width-1 downto 0)
    		     );
	END COMPONENT;
	
	COMPONENT instruction_memory
		Port (
        	      address : in std_logic_vector(nbit_width-1 downto 0);
      	              instruction : out std_logic_vector(nbit_width-1 downto 0)
      		     );
	END COMPONENT;
	
	COMPONENT control_unit
 		Port ( 
		     opcode , funct : in  std_logic_vector (5 downto 0);
       		     RegDst , Branch , MemRead , MemtoReg , MemWrite , AluSrc , RegWrite : out  std_logic;
    	             ALUOp : out  std_logic_vector (2 downto 0)
		    );
	END COMPONENT;
	
	COMPONENT register_File
		Port (
		      clk : in std_logic;
    		      read_register1, read_register2 : in std_logic_vector(4 downto 0);
      		      write_register : in std_logic_vector(4 downto 0);
      		      write_data : in std_logic_vector(nbit_width-1 downto 0);
      		      register_write_ctrl : in std_logic;
 	              read_data1, read_data2 : out std_logic_vector(nbit_width-1 downto 0)
    		     );
	END COMPONENT;

	COMPONENT sign_extend
		Port (
       		      input : in  std_logic_vector (15 downto 0);
        	      output : out  std_logic_vector (nbit_width-1 downto 0)
		      );
	END COMPONENT;


	COMPONENT shift_left_2
		Port ( 
	 	      input : in  std_logic_vector (31 downto 0);
                      output : out  std_logic_vector (31 downto 0)
		     );
	END COMPONENT;	

	COMPONENT alu
		Port (
       		      opcode : in std_logic_vector(2 downto 0);
        	      input1,input2 : in std_logic_vector(nbit_width-1 downto 0); 
        	      result : out std_logic_vector(nbit_width-1 downto 0); 
   	              zero : out std_logic 
    		      );
	END COMPONENT;

	COMPONENT data_memory
		Port (
		      clk : in std_logic;
    	       	      address : in std_logic_vector(nbit_width-1 downto 0);
       		      write_data : in std_logic_vector(nbit_width-1 downto 0);
      		      memory_write_ctrl , memory_read_ctrl : in std_logic;
      		      read_data : out std_logic_vector(nbit_width-1 downto 0)
   		      );
	END COMPONENT;
	
	COMPONENT mux generic (
        	      nbit_width : integer := 32
  		      );
		      Port (
		      sel : in  std_logic;
 	              input0,input1 : in  std_logic_vector (nbit_width-1 downto 0);
 	              output : out  std_logic_vector (nbit_width-1 downto 0)
		      );
	END COMPONENT;
	
	--dn
	signal sig_MemtoReg,sig_Branch,sig_AluSrc,sig_RegDst,sig_RegWrite,sig_zero,sig_MemRead,sig_MemWrite : std_logic;
	--dn
	signal sig_ALUOp : std_logic_vector(2 downto 0);
	--dn
	signal sig_pc_output: std_logic_vector(31 downto 0);
	--dn
	signal sig_instruction: std_logic_vector(31 downto 0);
	--dn
	signal sig_pc_plus4_result : std_logic_vector(31 downto 0);
	--dn
	signal sig_write_register : std_logic_vector(4 downto 0);
	--dn
	signal sig_read_data1,sig_read_data2: std_logic_vector(31 downto 0);
	--dn
	signal sign_extend_out : std_logic_vector(31 downto 0);
	--dn
	signal data_out_of_usememmux : std_logic_vector(31 downto 0);
	--dn
	signal alu_src_outof_mux,alu_result,alu_just_adder_result : std_logic_vector(31 downto 0);
	--dn
	signal data_out_of_mem : std_logic_vector(31 downto 0);
	--dn
	signal sig_out_of_shift : std_logic_vector(31 downto 0);
	--dn	 
	--adress of instruction 
	signal pcsrc_mux_sel : std_logic;
	--dn 
	signal pcsrc_out_of_mux : std_logic_vector(31 downto 0);

	
	
	-- define each part of instruction with alias
	--dn all
	alias sig_opcode : std_logic_vector(5 downto 0) is sig_instruction(31 downto 26);
	alias sig_funct : std_logic_vector(5 downto 0) is sig_instruction(5 downto 0);
	alias rs : std_logic_vector(4 downto 0) is sig_instruction(25 downto 21);
	alias rt : std_logic_vector(4 downto 0) is sig_instruction(20 downto 16);
	alias rd : std_logic_vector(4 downto 0) is sig_instruction(15 downto 11);
	alias shamt : std_logic_vector(4 downto 0) is sig_instruction(10 downto 6);
	alias offset : std_logic_vector(15 downto 0) is sig_instruction(15 downto 0);
	
begin

	U_control_unit: control_unit PORT MAP(
		opcode => sig_opcode,
		funct => sig_funct,
		RegDst => sig_RegDst,
		Branch => sig_Branch,
		MemRead => sig_MemRead,
		MemtoReg => sig_MemtoReg,
		MemWrite => sig_MemWrite,
		AluSrc => sig_AluSrc,
		RegWrite => sig_RegWrite,
		ALUOp => sig_ALUOp
		);

	U_PC: pc PORT MAP(
		clk => clk,
		input => pcsrc_out_of_mux,
		output => sig_pc_output
		);
	
	U_instruction_memory: instruction_memory PORT MAP(
		address => sig_pc_output,
		instruction => sig_instruction
		);
	
	U_pc_adder: pc_adder PORT MAP(
		input => sig_pc_output,
		output => sig_pc_plus4_result
		);
	
	U_mux_rtORrd: mux generic map (
   		 nbit_width => 5
		) port map (
  		  sel => sig_RegDst,
   		  input0 => rt,
   		  input1 => rd,
  		  output => sig_write_register
		);

	U_register_file: register_file PORT MAP(
		clk => clk,
		register_write_ctrl => sig_RegWrite,
		read_register1 => rs,
		read_register2 => rt,
		write_register => sig_write_register,
		read_data1 => sig_read_data1,
		read_data2 => sig_read_data2,
		write_data => data_out_of_usememmux
		);

	U_sign_extend: sign_extend PORT MAP(
		input => offset,
		output => sign_extend_out
		);

	U_shift_left_2 :shift_left_2 PORT MAP ( 
	 	      input => sign_extend_out,
                      output => sig_out_of_shift
		      );

	U_alu_just_adder: alu PORT MAP(
		opcode => "111",  -- means it should add
		input1 => sig_pc_plus4_result,
	        input2 => sig_out_of_shift,
		--input2 => sign_extend_out,
	        zero => sig_zero,  -- the result is not zero
		result => alu_just_adder_result
		);	 
		-- control of translate
pcsrc_mux_sel <= sig_zero and sig_Branch ;

	U_mux_pcsrc: mux port map (
                 sel => pcsrc_mux_sel,
          	 input0 => sig_pc_plus4_result,
         	 input1 => alu_just_adder_result,
		 output => pcsrc_out_of_mux
     		 );

	U_mux_alusrc: mux port map (
                 sel => sig_AluSrc,
          	 input0 => sig_read_data2,
         	 input1 => sign_extend_out,
		 output => alu_src_outof_mux
     		 );

	U_alu_main: alu PORT MAP(
		opcode => sig_ALUOp,
		input1 => sig_read_data1,
	    input2 => alu_src_outof_mux,
		zero=>sig_zero,
		result => alu_result
		);	 
		

	U_data_memory: data_memory PORT MAP(
		clk => clk,
    	       	address => alu_result,
       		write_data => sig_read_data2,
      		memory_write_ctrl => sig_MemWrite,
		memory_read_ctrl => sig_MemRead,
      		read_data => data_out_of_mem
		);


	U_mux_usemem: mux PORT MAP (
                  sel => sig_MemtoReg,
          	  input0 => alu_result,
         	  input1 => data_out_of_mem,
		  output => data_out_of_usememmux
     		  );


end BEHAV;