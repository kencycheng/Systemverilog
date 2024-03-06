// Code your testbench here
// or browse Examples
// https://www.edaplayground.com/x/v3gb
`define NUM 100
program test;
  function int sum(int n);
    if(n <= 1) 
      return n;
    else 
      return n + sum(n-1);          
  endfunction
  
  initial begin
    $display("sum(%0d)=%d",`NUM, sum(`NUM)); 
    
  end
  
endprogram
