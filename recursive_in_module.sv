// https://www.edaplayground.com/x/CMqV
// Code your testbench here
// or browse Examples
`define NUM 100
module test;
  function automatic int sum(int n);
    if(n <= 1) begin
      $display("n = %d", n);
      return n;
    end else begin
      int re;
      re = sum(n-1) + n;
      $display("re = %d", re);
      return re;
    end
  endfunction
  
  initial begin
    $display("sum(%0d)=%d",`NUM, sum(`NUM)); 
    
  end
  
endmodule
