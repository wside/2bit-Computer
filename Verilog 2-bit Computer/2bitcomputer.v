// Matt Ferreria, Wendy Ide
//Feburary 24, 2016
//Gate level abstraction

`include "program_counter.v"
`include "register.v"                 //child module files  
`include "dff.v"
`include "dff_c.v"

module twobitcomputer();

  reg CLK_original, Set, Reset;   //Set is always held at 0. When Reset is high, all flip flops and counter outputs go to 0.
  reg X0, X1, X2, X3, Y0, Y1, Y2, Y3;  //multiplexer data inputs
  wire PC0_counter_output, PC1_counter_output;  //the actual bits coming out of a 2_bit counter
  wire PC0_final, PC1_final;       //make up the PC register (addresses of data) go into select pins of multiplexers
  wire D0, D1;                     //program data (the two output pins of the muxs)
  wire jump, jump_BAR, nojump, nojump_BAR;   //logic wires
  wire R1, RS;          //register that gets incremented (R1) and status register (RS) 
  wire INC, JNO, HLT;   //instructions determined by decoder (program data (D1 and D0) from mux goes into select lines of decoder)
  wire g0, g1, g2, g3, h0, h1, h2, h3, M0, M1; //various gate connection wires
  wire Q, Q_BAR, Q_1, Q_BAR_1, Q_2, Q_BAR_2; //wires for child modules

  /*RAM modeled by two 4:1 multiplexers. The output of one of them is treated as the lsb of data (D0) and 
  the output of the other one is the msb of the data (D1). The select lines (PC1_final and PC0_final) are treated as address pins.
  i.e. PC1_final goes into select line S1 on both muxs and PC0_final goes into select line S0 on both muxes. 
  The data is loaded in via the multiplexers input pins (X0-X3 and Y0-Y3) in testbench.*/
  not (PC0_final_BAR, PC0_final);
  not (PC1_final_BAR, PC1_final);
  and (g0, PC0_final_BAR, PC1_final_BAR, X0);
  and (g1, PC0_final, PC1_final_BAR, X1);
  and (g2, PC0_final_BAR, PC1_final, X2);
  and (g3, PC0_final, PC1_final, X3);
  or (D0, g0,g1, g2, g3);

  and (h0, PC0_final_BAR, PC1_final_BAR, Y0);
  and (h1, PC0_final, PC1_final_BAR, Y1);
  and (h2, PC0_final_BAR, PC1_final, Y2);
  and (h3, PC0_final, PC1_final, Y3);
  or (D1, h0,h1, h2, h3); 

  //buffer to PC. Shoves D1 onto output of PC when jump is high. 
  bufif1 (M0, D1, jump);
  bufif0 (M0, PC0_counter_output, jump);
  bufif1 (M1, D1, jump);
  bufif0 (M1, PC1_counter_output, jump);

  //forces PC to skip the 10 state when no jump and go straight to 11 from 01
  bufif1 (PC0_final, nojump, nojump);
  bufif0 (PC0_final, M0, nojump);
  bufif1 (PC1_final, nojump, nojump);
  bufif0 (PC1_final, M1, nojump);

  //"over" controls the msb of the program counter (PC1_counter_output)
  or (over, Reset, jump);  
  
  //insantiate program counter (PC)
  program_counter activate_0(PC0_counter_output, PC1_counter_output, CLK_final_input, Set, Reset, over);

  //decoder
  not (D0_BAR, D0);
  not (D1_BAR, D1);

  and (INC, D1_BAR, D0_BAR, Reset_BAR);   //Reset acts as decoder enable. When Reset=1, all instructions go low
  and (JNO, D1_BAR, D0, Reset_BAR);
  and (HLT, D1, D0_BAR, Reset_BAR);

  //jump and nojump flip flops
  not (RS_BAR, RS);
  and (D_a, JNO, RS_BAR);
  and (D_b, JNO, RS);

  //defining inversions of Set and Reset
  not (Set_BAR, Set);  
  not (Reset_BAR, Reset);

  //instantiate jump and nojump flip flops
  dff jump_ff (jump, jump_BAR, D_a, CLK_final_input, Set, Reset);
  dff nojump_ff (nojump, nojump_BAR, D_b, CLK_final_input, Set, Reset);

  //instantiate increment register (R1) and status register (RS). Puts INC in as clock.
  register activate_1(R_lsb, R_msb, RS, INC, Set, Reset); 

  //HLT instruction logic
  not (HLT_BAR, HLT);
  and(CLK_final_input, CLK_original, HLT_BAR) ;


  //testbench code starts here
    initial begin
    $dumpfile("2bc.vcd");
         $dumpvars(0,twobitcomputer);

    CLK_original=0;
       /*Set and Reset must be initiated so the Qs and Q_BARs in the D ffs have a starting value. Otherwise nothing happens.
       Qs and Q_BARs can't be initialized in a testbench because they are declared as wires not regs.*/
     
    Set=0;
    Reset=1; //starts all flip flops and counters at 0

    X0=0;  //LSB of data (D0) at address 00 (PC1_final, PC0_final)
    X1=1;  //LSB of data (D0) at address 01
    X2=0;  //LSB of data (D0) at address 10
    X3=0;  //LSB of data (D0) at address 11
    Y0=0;  //MSB of data (D1) at address 00 (PC1_final, PC0_final)
    Y1=0;  //MSB of data (D1) at address 01 
    Y2=0;  //MSB of data (D1) at address 10 
    Y3=1;  //MSB of data (D1) at address 11 
    
      
      #0 Reset=0; //allows program to begin
    
    //MASTER RESET BUTTON: demonstration by pulsing the Reset, universal since Reset is connected to all flip flops
      #81 Reset=1;
      #1 Reset=0;

      #50 $finish; 
      end
   always #2 CLK_original = ~CLK_original; 

        /*note that PC0_counter_output and PC1_counter_output are the original bits coming out of the counter making up the program counter,
          but PC0_final and PC1_final are the bits after they go through the correct logic for the instructions to work
          and are the bits that address the memory.
          Therefore, the PC register is printed out containing PC0_final and PC1_final.*/ 
          //R_msb and R_lsb make up register R1 (the register that gets incrmented) .
          initial begin
          $monitor ("PC =%b%b,  Data=%b%b,  R1 =%b%b,   RS=%b,   HLT=%b,   Reset=%b" , PC1_final,PC0_final,  D1,D0,  R_msb,R_lsb,  RS, HLT, Reset);
          end

endmodule
