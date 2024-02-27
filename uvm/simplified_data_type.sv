// simplified data type of uvm_drivers and monitors
// https://www.edaplayground.com/x/m_mC

import uvm_pkg::*;
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
  repeat(10) `uvm_do(req)
  
  if(starting_phase != null)
      starting_phase.drop_objection(this,"");
endtask
endclass       
class spi_monitor extends uvm_monitor;
 `uvm_component_utils(spi_monitor)
  uvm_analysis_port#(uvm_sequence_item) mon_port; 
  spi_sequence_item spi_data;
  virtual spi_if vif; 
  
  function new(string name="spi_monitor", uvm_component parent);
   super.new(name, parent);
    
  endfunction 
    
  function void build_phase(uvm_phase phase); 
    mon_port = new("mon_port", this);
    if(!uvm_config_db#(virtual spi_if)::get(this, "", "spi_if", vif))
      `uvm_fatal("NOIVF", "");
  endfunction 
  task run_phase(uvm_phase phase);
    spi_data = spi_sequence_item::type_id::create("spi_data");
     while(1) begin
       @(posedge vif.clk);
       if(vif.en) begin
         spi_data.data <= vif.data;
         mon_port.write(spi_data); // upcasting
       end
       
     end     
  endtask
       
endclass

class spi_driver extends uvm_driver #(uvm_sequence_item);
`uvm_component_utils(spi_driver)
 spi_sequence_item spi_data;
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
       
       if(!$cast(spi_data,req))
         `uvm_fatal(get_type_name(), "data cast error")
       @(posedge vif.clk);
       vif.data <= spi_data.data;
       vif.en <= spi_data.en;
       seq_item_port.item_done();
       
     end
endtask
endclass

class spi_agent extends uvm_agent;
  `uvm_component_utils(spi_agent)
spi_driver drv;
spi_monitor mon;
uvm_sequencer seqr; 


function new(string name="", uvm_component parent);
  super.new(name, parent);
endfunction
function void build_phase(uvm_phase phase); 
  drv = spi_driver::type_id::create("drv", this);
  mon = spi_monitor::type_id::create("mon", this);
  seqr = uvm_sequencer#(uvm_sequence_item)::type_id::create("seqr", this);
    
endfunction 
function void connect_phase(uvm_phase phase);
   drv.seq_item_port.connect(seqr.seq_item_export);
endfunction
endclass
class spi_sb extends uvm_subscriber #(uvm_sequence_item);
  int total=0;
  `uvm_component_utils(spi_sb)
  function new(string name="", uvm_component parent);
   super.new(name, parent);
  endfunction
  virtual function void write(uvm_sequence_item t);
    t.print();
    total++;
  endfunction
  virtual function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("total valid data = %d",total), UVM_MEDIUM)
  endfunction
endclass

class spi_env extends uvm_component;
  `uvm_component_utils(spi_env)
  spi_agent m_spi_agent;
  spi_sb m_spi_sb;
  function new(string name="", uvm_component parent);
   super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
    m_spi_agent = spi_agent::type_id::create("m_spi_agent", this);
    m_spi_sb    = spi_sb::type_id::create("m_spi_sb", this);
  endfunction
  function void connect_phase(uvm_phase phase);
    m_spi_agent.mon.mon_port.connect(m_spi_sb.analysis_export);
  endfunction
  task run_phase(uvm_phase phase);
    spi_sequence spi_seq;
    spi_seq =  spi_sequence::type_id::create("m_seq");
    phase.raise_objection(this, "");
    spi_seq.starting_phase = phase;
    spi_seq.start(m_spi_agent.seqr);
    #100ns; 
    phase.drop_objection(this,"");
    
  endtask
endclass


interface spi_if;
logic en;
logic [15:0] data;
wire clk;  


endinterface

module test;
  reg clk;
  
initial begin
  clk = 0;
  forever clk = #10 ~clk;
  
end
  spi_if spi_if0();
  assign spi_if0.clk = clk;
initial begin
  
  spi_sequence spi_seq;
  spi_env m_env;
 
  
  uvm_config_db#(virtual spi_if)::set(null, "m_env.m_spi_agent.drv", "spi_if",   spi_if0);
  uvm_config_db#(virtual spi_if)::set(null, "m_env.m_spi_agent.mon", "spi_if",   spi_if0);
  m_env = spi_env::type_id::create("m_env", null);
  run_test();
end
endmodule
