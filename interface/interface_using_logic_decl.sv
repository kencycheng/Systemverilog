// https://www.edaplayground.com/x/kiyg
// In this example, the signal sdio is declared as logic. No I/O is declare for interface bus.
// Binding interface to dut by assign statement in this case
// This style will got problems when the signal sdio needs to have bidirectional behavior.


interface bus;
  logic sdio;
  wire  sclk;
  
  clocking cdp @(posedge sclk);
    output sdio;
  endclocking
  clocking cbn @(posedge sclk);
    output sdio;
  endclocking
  task init();
    cdp.sdio <= 1'b0;
  endtask
endinterface

module dut(input sclk, input sdio);
  
endmodule

module test;
  reg clk;
  wire sdio;
  
  dut i_dut(.sclk(clk), .sdio(sdio));
  bus i_bus();
  assign i_dut.sdio = i_bus.sdio;
  assign i_bus.sclk = clk;
  
  
  initial begin
    clk=0;
    #100;
    forever #10 clk = ~clk;
  end
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0, test);
  end
  
  // The driving part to sdio signal is as free as any sequencial statment.
  initial begin
    #100;
    for(int i=0; i<10; i++) begin
      @i_bus.cdp;
      i_bus.cdp.sdio <= $urandom();     
    end
    #100;
    for(int i=0; i<10; i++) begin
      @i_bus.cdp;
      i_bus.cdp.sdio <= 1'b1;
      @i_bus.cbn;
      i_bus.cbn.sdio <= $urandom();
    end
  
  $finish;
  end
  
endmodule
