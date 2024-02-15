// https://www.edaplayground.com/x/2wW_
// UVM sequencer and driver playground
//  
module testbench;
import uvm_pkg::*;
// UVM sequencer and driver playground
class bus_seq_item extends uvm_sequence_item;
  rand bit[31:0] address;
  rand bit[31:0] data;
  rand bit wr;
  `uvm_object_utils_begin(bus_seq_item)
  `uvm_field_int(address, UVM_ALL_ON)
  `uvm_field_int(data, UVM_ALL_ON)
  `uvm_field_int(wr, UVM_ALL_ON)
  `uvm_object_utils_end
  function new(string name="bus_seq_item");
    super.new(name);
  endfunction
  function string convert2string();
    string s;
    $sformat(s,"wr=%1b, addr = %8h, data=%8h", wr, address, data);
    return s;
  endfunction

endclass
//----------------
// Driver
//----------------
class bus_driver extends uvm_driver #(bus_seq_item);
  `uvm_component_utils(bus_driver)

  function new(string name = "bus_driver", uvm_component parent);
    super.new(name, parent);
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    while(1) begin
      seq_item_port.get_next_item(req);
	  `uvm_info("REQ_TO_DRIVE",req.convert2string(),UVM_MEDIUM)
	  `uvm_info("REQ_TO_DRIVE",$sformatf("seq_id=%d,	 	trans_id=%d",req.get_sequence_id(), req.get_transaction_id()),UVM_MEDIUM)
	  #100ns //emualte driver time consuming
	  seq_item_port.item_done();
      if(req.wr==0) begin
        rsp = bus_seq_item::type_id::create("rsp");
	    rsp.copy(req);
	    rsp.set_id_info(req);
	    rsp.data = rsp.get_sequence_id()<< 16 + rsp.get_transaction_id();	
	    seq_item_port.put_response(rsp);
      end 
    end

  endtask: run_phase
endclass: bus_driver

//---------------------
// simplified sequencer
//---------------------
typedef uvm_sequencer #(bus_seq_item) bus_seqr;


//---------------------
// sequences
//---------------------
class bus_seq extends uvm_sequence #(bus_seq_item);
  `uvm_object_utils(bus_seq)
  `uvm_declare_p_sequencer(bus_seqr)
  int num = 10;
  bus_seq_item req, rsp;
  function new(string name = "bus_seq");
    super.new(name);
  endfunction
  task body();
    req = bus_seq_item::type_id::create("req");
// The starting_phase should be proper assigned from calling phase and parent sequence
// Once it is null, objection raising will no effect
    starting_phase.raise_objection(this, {get_type_name(), " body"});
    repeat(num) begin
      start_item(req);
      `uvm_info("SEQ",req.convert2string(), UVM_MEDIUM)
      if(!req.randomize())
        `uvm_fatal("RANDERR","")
      finish_item(req);
      if(req.wr == 0) begin
        get_response(rsp);
        `uvm_info("RSP",rsp.convert2string(), UVM_MEDIUM)
        `uvm_info("RSP",$sformatf("seq_id=%d, trans_id=%d",rsp.get_sequence_id(), rsp.get_transaction_id()),UVM_MEDIUM)
      end
    end
    starting_phase.drop_objection(this, {get_type_name(), " body"});
  endtask
endclass

class multi_seq extends uvm_sequence#(bus_seq_item);
  `uvm_object_utils(multi_seq)
  `uvm_declare_p_sequencer(bus_seqr)
  bus_seq bus_seq_inst1;
  bus_seq bus_seq_inst2;
  bus_seq bus_seq_inst3;
  function new(string name = "multi_seq");
    super.new(name);
  endfunction
  task body();
    bus_seq_inst1 = bus_seq::type_id::create("bus_seq_inst1"); 
    bus_seq_inst2 = bus_seq::type_id::create("bus_seq_inst2");
    bus_seq_inst3 = bus_seq::type_id::create("bus_seq_inst3");
    bus_seq_inst1.starting_phase = starting_phase;
    bus_seq_inst2.starting_phase = starting_phase;
    bus_seq_inst3.starting_phase = starting_phase;
    fork
      bus_seq_inst1.start(m_sequencer, this);
      bus_seq_inst2.start(m_sequencer, this);
      bus_seq_inst3.start(m_sequencer, this);
    join
  endtask
endclass

//---------------------
// tiny env
//---------------------
class env extends uvm_component;
  bus_seqr seqr;
  bus_driver drv;
  `uvm_component_utils(env)
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr = bus_seqr::type_id::create("seqr", this); 
    drv = bus_driver::type_id::create("drv", this);
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
    drv.rsp_port.connect(seqr.rsp_export);
   $display("PATH=%s",get_full_name());
  endfunction: connect_phase
  function new(string name = "env", uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    bus_seq bus_seq_inst;
    multi_seq multi_seq_inst;
    super.run_phase(phase);
    bus_seq_inst = bus_seq::type_id::create("bus_seq_inst");
    bus_seq_inst.starting_phase = phase;
    bus_seq_inst.start(seqr);
    bus_seq_inst.start(seqr);
    multi_seq_inst = multi_seq::type_id::create("multi_seq_inst");
    multi_seq_inst.starting_phase = phase;
    multi_seq_inst.start(seqr);
    multi_seq_inst.start(seqr);
  endtask
endclass




//-----------
// run_test();
//-----------

initial begin
env env_inst;
// If you don't like to create any uvm test 
// instantiate any uvm component here
// run_test will start it.  
  env_inst=env::type_id::create("env", null);
run_test();
 
end
