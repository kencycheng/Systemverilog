// https://www.edaplayground.com/x/cqJy
// The interface signal sdio is declared as wire, 
// in this case, two clocking drive to a single wire

interface bus(
  output wire sdio,
  input wire sclk
  
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

module dut(input sclk, input sdio, output sig);
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
  // Binding by bind 
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
    // drive z to avoid bus contentions
    for(i=0; i<10; i++) begin 
      @i_dut.i_bus.cbp;
      i_dut.i_bus.cbn.sdio <= 1'bz;
      i_dut.i_bus.cbp.sdio <= $urandom();
      @i_dut.i_bus.cbn;
      i_dut.i_bus.cbp.sdio <= 1'bz;
      i_dut.i_bus.cbn.sdio <= $urandom();
    end
    #100;
    i_dut.i_bus.cbn.sdio <= 1'bz;
    for(i=0; i<10; i++) begin
      @i_dut.i_bus.cbp;
      i_dut.i_bus.cbp.sdio <= $urandom();
    end
  
  $finish;
  end
  
endmodule
