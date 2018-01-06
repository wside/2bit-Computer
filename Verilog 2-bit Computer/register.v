module register(R_lsb, R_msb, RS, CLK, Set, Reset);  //asynchrnous 3-bit up counter from three D flipflops. 
                                                     //first and second dffs make up the register R1 (that gets incremented). 
                                                     //third flip flop is register RS (the Status Register)

  output R_lsb, R_msb, RS;
  input CLK;     //CLK stands for a general CLK input, specific clock input determined by parent module
  input Set,Reset;
  wire CLK;

  dff_c first (  R_lsb,    Q_BAR,     CLK,   Set, Reset );          
  dff_c second(  R_msb,  Q_BAR_1,   Q_BAR,   Set, Reset );        //Q_BAR from previous ff becomes clock of next
  dff_c third (     RS,  Q_BAR_2, Q_BAR_1,   Set, Reset );

endmodule