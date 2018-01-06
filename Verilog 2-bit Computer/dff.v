module dff(Q, Q_BAR, D, CLK,Set, Reset);     //a Single positive-edge triggered D flip flop
  
  input D, CLK, Set, Reset;                    //CLK stands for a general CLK input, specific clock input determined by parent module
  output Q, Q_BAR;
  wire D, CLK, Set, Reset; 
  wire f3, f4, f5, f6; //misc nand gate connection wires

  not (Set_BAR, Set);
  not (Reset_BAR, Reset);

  nand (f3, Set_BAR, f6, f4);           //made from six nand gates total
  nand (f4, f3, CLK, Reset_BAR);
  nand (f5, f4, Set_BAR, CLK, f6);
  nand (f6, f5, D, Reset_BAR);

  nand (Q, Set_BAR, f4, Q_BAR);
  nand (Q_BAR, Q, f5, Reset_BAR);

endmodule 
