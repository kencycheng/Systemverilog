// https://www.edaplayground.com/x/tEsR
// declare interface signals as wire logic
// wire logic == wire

interface bus(
  output wire logic sdio,
  input wire logic sclk
  
);
  
  clocking cbp @(posedge sclk);
    output sdio;
  endclocking
  clocking cbn @(posedge sclk);
    output sdio;
  endclocking
  task init();
    cbp.sdio <= 1'b0;
  endtask
endinterface

module dut(input sclk, input sdio);
  reg foo;  
  initial begin
    foo = 0;
  end
  
  always@(posedge sclk)
    foo <= ~foo ;
  assign sig = foo;
endmodule

module test;
  reg clk;
  int i;
  
  dut i_dut(.sclk(clk));
  bind test.i_dut bus i_bus(.sclk(sclk), .sdio(sdio));
  
  initial begin
    clk=0;
    #100;
    forever #10 clk = ~clk;
  end
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0, test);
  end
  initial begin

       
    #100;
    // two clocking blocks drive one wire 
    for(i=0; i<10; i++) begin 
      @i_dut.i_bus.cbp;
      i_dut.i_bus.cbn.sdio <= 1'bz;
      i_dut.i_bus.cbp.sdio <= $urandom();
      
      @i_dut.i_bus.cbn;
      i_dut.i_bus.cbp.sdio <= 1'bz;
      i_dut.i_bus.cbn.sdio <= $urandom();
    end
    #100;
    // bus contentions afterward
    for(i=0; i<10; i++) begin
      @i_dut.i_bus.cbp;
      i_dut.i_bus.cbp.sdio <= $urandom();
    end
  
  $finish;
  end
  
endmodule
