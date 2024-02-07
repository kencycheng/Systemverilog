// Code your testbench here
// or browse Examples
// 100 lines of SV code example to run uvm_sequence on a uvm_agent
// It is a very good example to do some experiment on it
// https://www.edaplayground.com/x/cjf
class spi_sequence_item extends uvm_sequence_item;
       rand bit [3:0] data;
       rand bit en;
  `uvm_object_utils_begin(spi_sequence_item)
  `uvm_field_int(data, UVM_ALL_ON)
  `uvm_field_int(en, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name="spi_sequence_item");
     super.new(name);
endfunction
endclass

class spi_sequence extends uvm_sequence#(spi_sequence_item);
  `uvm_object_utils(spi_sequence)
  function new(string name ="spi_sequence_item");
   super.new(name);
  endfunction
task body();
  if(starting_phase != null) 
      starting_phase.raise_objection(this, "");
    `uvm_do(req)
  if(starting_phase != null)
      starting_phase.drop_objection(this,"");
endtask
endclass       
class spi_sequencer extends uvm_sequencer #(spi_sequence_item);
  `uvm_component_utils(spi_sequencer);
  function new(string name="", uvm_component parent);
  super.new(name, parent);
endfunction
endclass 


class spi_driver extends uvm_driver #(spi_sequence_item);
`uvm_component_utils(spi_driver)
virtual spi_if vif;
  function new(string name="spi_driver", uvm_component parent);
   super.new(name, parent);
endfunction
  
function void build_phase(uvm_phase phase); 
  if(!uvm_config_db#(virtual spi_if)::get(this, "", "spi_if", vif))
    `uvm_fatal("NOIVF", "");
endfunction 
task run_phase(uvm_phase phase);
     while(1) begin
         seq_item_port.get_next_item(req);
       @(posedge vif.clk);
 
               vif.data <= req.data;
               vif.en <= req.en;
         seq_item_port.item_done();
     end
endtask
endclass

class spi_agent extends uvm_agent;
  `uvm_component_utils(spi_agent)
spi_driver drv;
spi_sequencer seqr; 


  function new(string name="", parent);
   super.new(name, parent);
endfunction
function void build_phase(uvm_phase phase); 
  drv = spi_driver::type_id::create("drv", this);
  seqr = spi_sequencer::type_id::create("seqr", this);
  
endfunction 
function void connect_phase(uvm_phase phase);
   drv.seq_item_port.connect(seqr.seq_item_export);
endfunction
endclass


interface spi_if;
wire en;
wire [15:0] data;
wire clk;  
endinterface

module test;
  reg clk;
  
initial begin
  forever clk = #10 ~clk;
  
end
  spi_if spi_if0();
  assign spi_if0.clk = clk;
initial begin
  
  spi_sequence spi_seq;
  spi_agent m_spi_agent;
  uvm_config_db#(spi_sequence)::set(null, "m_spi_agent.seqr.run_phase", "default_sequence",       spi_seq.get_type()  );
  uvm_config_db#(virtual spi_if)::set(null, "m_spi_agent.drv", "spi_if",   spi_if0);
  m_spi_agent = spi_agent::type_id::create("m_spi_agent", null);
  run_test();
end
endmodule
