// Code your testbench here
// or browse Examples
// 100 lines of SV code example to run uvm_sequence on a uvm_agent
// It is a perfect example to do some experiments on it
// Essential uvm components and objects:
// virtual interface, sequences, driver, monitor, TLM port, agent, environment and tests
//
// https://www.edaplayground.com/x/KUBq

interface my_ip_if (input wire clk, output wire[3:0] data, output en);
endinterface

module test_my_ip;
import uvm_pkg::*;

  class my_ip_sequence_item extends uvm_sequence_item;
    `uvm_object_utils_begin(my_ip_sequence_item)
    `uvm_field_queue_int(data, UVM_DEFAULT)
    `uvm_object_utils_end
    rand bit[3:0] data[$];
    function new(string name = "my_ip_sequence_item");
      super.new(name);
    endfunction
    
  endclass
  
  class my_seq extends uvm_sequence#(my_ip_sequence_item);
    `uvm_object_utils(my_seq)
    function new(string name = "my_seq");
      super.new(name);
    endfunction
  
    task body();
      if(starting_phase != null)
        starting_phase.raise_objection(this);
      `uvm_do_with(req , {data.size() <12;})
      
      if(starting_phase != null)
        starting_phase.drop_objection(this);
    endtask
        
  endclass
   
  class my_ip_sequencer extends uvm_sequencer #(my_ip_sequence_item);
    `uvm_component_utils(my_ip_sequencer)
    
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
  
  endclass
      
  class my_ip_driver extends uvm_driver #(my_ip_sequence_item);
    `uvm_component_utils(my_ip_driver) 
    virtual my_ip_if vif;
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);
      uvm_config_db #(virtual my_ip_if)::get(this, "", "my_ip_if", vif);
    endfunction
    virtual task run_phase(uvm_phase phase);
      while(1) begin
        seq_item_port.try_next_item(req);
        if(req != null) begin
          for(int i = 0; i< req.data.size(); i++) begin
            @(posedge vif.clk);
            vif.en <= 1'b1;
            vif.data <= req.data[i];         
          end
        end else begin
          @(posedge vif.clk);
          vif.en <= 1'b0;
          vif.data <= 4'b0;
        end
        seq_item_port.item_done();  
      end
        
    endtask
  endclass 
  class my_ip_monitor extends uvm_monitor;
    `uvm_component_utils(my_ip_monitor)
    uvm_analysis_port#(my_ip_sequence_item) mon_port;
    virtual my_ip_if vif;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      mon_port = new("mon_port", parent);
    endfunction
    virtual function void build_phase(uvm_phase phase);
      uvm_config_db #(virtual my_ip_if)::get(this, "", "my_ip_if", vif);
            
    endfunction
    virtual task run_phase(uvm_phase phase);
      my_ip_sequence_item t;
      bit receiving_data = 0;
      while(1) begin
        @(posedge vif.clk);
        if(vif.en == 1'b1 && ~receiving_data) begin
          t = my_ip_sequence_item::type_id::create("t");
          t.data = {};
          receiving_data = 1'b1;
        end else if(receiving_data == 1'b1 && vif.en == 0) begin
          receiving_data = 1'b0;
          mon_port.write(t);
        end else if(vif.en == 1'b1) begin
          t.data.push_back(vif.data);
        end
      end
    endtask
  endclass
        
  class my_ip_agent extends uvm_agent;
    `uvm_component_utils(my_ip_agent)
    my_ip_sequencer m_my_ip_sequencer;
    my_ip_driver    m_my_ip_driver;
    my_ip_monitor   m_my_ip_monitor;
    uvm_analysis_export #(my_ip_sequence_item) mon_port;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      mon_port = new("mon_port", parent);
    endfunction
   
    virtual function void build_phase(uvm_phase phase);
      m_my_ip_sequencer = my_ip_sequencer::type_id::create("m_my_ip_sequencer", this);
      m_my_ip_driver    = my_ip_driver::type_id::create("m_my_ip_driver", this);
      m_my_ip_monitor   = my_ip_monitor::type_id::create("m_my_ip_monitor", this);
    endfunction
    virtual function void connect_phase(uvm_phase phase);
      m_my_ip_driver.seq_item_port.connect(m_my_ip_sequencer.seq_item_export);
      m_my_ip_monitor.mon_port.connect(mon_port);      
    endfunction
    
  endclass
        
  class my_ip_cov extends uvm_subscriber #(my_ip_sequence_item);
    `uvm_component_utils(my_ip_cov)
    my_ip_sequence_item this_tr;
    covergroup my_ip_cg;
      cp_data_size: coverpoint this_tr.data.size() {
        bins SIZE[] = {[1:10]}; 
      }
    endgroup
    function new(string name, uvm_component parent);
      super.new(name, parent);
      my_ip_cg = new();
    endfunction
    
    virtual function void write(my_ip_sequence_item t);
      t.print();
      this_tr = t;
      my_ip_cg.sample();
    endfunction
    
  endclass     
        
  class my_ip_env extends uvm_env;
    `uvm_component_utils(my_ip_env);
    my_ip_cov m_my_ip_cov;
    my_ip_agent m_my_ip_agent;
    
    function new(string name, uvm_component parent);
      super.new(name, parent);    
    endfunction
    
    function void build_phase(uvm_phase phase);
      m_my_ip_cov = my_ip_cov::type_id::create("m_my_ip_cov", this);
      m_my_ip_agent = my_ip_agent::type_id::create("m_my_ip_agent", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
      m_my_ip_agent.mon_port.connect(m_my_ip_cov.analysis_export);
    endfunction
  endclass
    
  class base_test extends uvm_test;
    `uvm_component_utils(base_test);
    my_ip_env m_my_ip_env;
    function new(string name, uvm_component parent);
      super.new(name, parent);    
    endfunction
    function void build_phase(uvm_phase phase);
      m_my_ip_env = my_ip_env::type_id::create("m_my_ip_env", this);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
      my_seq m_my_seq;
      m_my_seq = my_seq::type_id::create("m_my_seq");
      phase.raise_objection(this);
      repeat(10) begin
        m_my_seq.start(m_my_ip_env.m_my_ip_agent.m_my_ip_sequencer);
      end
      phase.drop_objection(this);
    endtask

  endclass 
        
  bit[3:0] data;
  reg clk;
  my_ip_if my_ip_if1(clk, data, en);
        
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end
        
  initial begin
    uvm_config_db#(virtual my_ip_if)::set(null, "uvm_test_top.m_my_ip_env.m_my_ip_agent.*", "my_ip_if", my_ip_if1);
    run_test("base_test");
  end
 initial begin
   $dumpfile("my_ip.vcd");
   $dumpvars(0, test_my_ip);
 end

    
    
        
endmodule


