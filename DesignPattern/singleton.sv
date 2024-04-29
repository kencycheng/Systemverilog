// A typical example in UVM is uvm_event_pool
// Everywhere you create the uvm_event_pool instances are the same one
https://www.edaplayground.com/x/UJDH

class Singleton extends uvm_object;
  // Static variable to hold the single instance of the class
  static protected Singleton m_instance;
  // variable
  static int id =0 ;
  // Protected constructor to prevent direct instantiation
  protected function new();

  endfunction

  // Static method to get the instance of the class
  // There is one and only one instance to be created
  static function Singleton get_instance();
    if (m_instance == null) begin
      m_instance = new();
    end
    m_instance.id ++;
    return m_instance;
  endfunction
endclass

module test;
  Singleton singleton;

  initial begin
    // Get the instance of the Singleton class
    repeat(10) begin
      singleton = Singleton::get_instance();
      // Further code to use the singleton instance
      $display("id=%d", singleton.id);
    end
   
  end
endmodule
