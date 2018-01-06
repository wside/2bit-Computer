module dff_c(Q, Q_BAR, CLK, Set, Reset); //dff_c stands for dff with Q_BAR connected as the D input
  
  output Q, Q_BAR;
  input CLK, Set, Reset;                 //CLK stands for a general CLK input, specific clock input determined by parent module
  wire CLK, Set, Reset; 
  wire f3, f4, f5, f6; //misc nand gate connection wires

  not (Set_BAR, Set);
  not (Reset_BAR, Reset);

  nand (f3, Set_BAR, f6, f4);     //made from six nand gates total
  nand (f4, f3, CLK, Reset_BAR);
  nand (f5, f4, Set_BAR, CLK, f6);
  nand (f6, f5, Q_BAR, Reset_BAR);

  nand (Q, Set_BAR, f4, Q_BAR);
  nand (Q_BAR, Q, f5, Reset_BAR);

endmodule