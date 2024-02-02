module test;
  event reset_exit, reset_enter;
  reg resetn;
  int n;
  initial begin
    
   
    while(1) begin
      @(posedge resetn) 
        -> reset_exit;
        $display("reset_exit = %d, at %t", reset_enter.triggered, $time);
     
      @(negedge resetn) 
        -> reset_enter;
        $display("reset_enter = %d, at %t", reset_enter.triggered, $time);
    end
    
  end
  
  initial begin
    /*
    resetn=1'b0;
    #0.1ns
    resetn=1'b1;
    #0.1ns 
    resetn=1'b0;
    */
    #200ns;
    resetn=1'b0;
    #100ns;
    resetn=1'bX;
    #100ns;
    resetn=1'b0;
    
    #200ns;
    resetn=1'b1;
    #100ns;
    resetn=1'bX;
    #100ns;
    resetn=1'b1;
    
  end
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    
    n = 0;
    forever begin
      wait(reset_enter.triggered);
      
      $display("got reset_enter = %d, at %t", reset_enter.triggered, $time);
      n=n+1;
      if(n==20) $finish();
    end
  end
endmodule
