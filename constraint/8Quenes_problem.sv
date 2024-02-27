// Code your testbench here
// or browse Examples
// https://www.edaplayground.com/x/sRwe
class Queens;
  parameter SIZE = 8;
  rand int Q[SIZE];
  
  constraint Qi{
    foreach(Q[i])
      Q[i] inside {[0:7]};
  }
  constraint Qi_n_Qj{
    foreach(Q[i]) {
      foreach(Q[j])
        if(i!=j){
          Q[i] != Q[j];
          !((Q[i]-Q[j]) inside {(i-j), (j-i)});
        }
    }
  }        
          
  function void print(int id="");
    string s;  
      $display("============%0d=============", id);
      for(int i=0; i<SIZE; i++) begin
        s="";
        for(int j=0; j< SIZE; j++) begin
          string t;
          t = (j==Q[i])? "Q":"."; 
          $sformat(s,"%s%3s",s,t);          
        end  
        $display(s);
      end
      
    
            
  endfunction
endclass
      
module test;          
initial begin
  int runs;
  Queens q;
  q = new();
  runs = 0;
  repeat (10) begin
    runs++;
    assert(q.randomize())
      q.print(runs);    
  end
end
  
endmodule
