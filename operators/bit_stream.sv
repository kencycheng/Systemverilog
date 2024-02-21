// Studying the behavor of bit stream operator
// https://www.edaplayground.com/x/Lv7y
module test;
  initial begin
    bit [7:0] byte_array[12];
    bit [31:0] reg_array[3];

     reg_array[0] = 32'h01020304;
     reg_array[1] = 32'h05060708;
     reg_array[2] = 32'h090a0b0c;  
    
    
    byte_array = {<<32{reg_array}};
    foreach(byte_array[i]) 
      $display("byte[%d] = %2h", i, byte_array[i]);
    
    byte_array = {<<8{ {<<32{reg_array}} }};
    foreach(byte_array[i]) 
      $display("byte[%d] = %2h", i, byte_array[i]);
    
  end
  
  
  
endmodule
