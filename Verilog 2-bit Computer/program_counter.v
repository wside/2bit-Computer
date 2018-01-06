module program_counter(PC0_counter_output, PC1_counter_output, CLK, Set, Reset, over);  //asynchrnous 3-bit up counter from two D flipflops.
  
  output PC0_counter_output, PC1_counter_output, RS;
  input CLK;                                                              //CLK stands for a general CLK input, specific clock input determined by parent module
  input Set,Reset,over;

  dff_c first (PC0_counter_output,    Q_BAR,   CLK,     Set, Reset);          
  dff_c second(PC1_counter_output,  Q_BAR_1, Q_BAR,   Set, over);        //Q_BAR from previous ff becomes clock of next

endmodule