// https://www.edaplayground.com/x/qck8
// 
typedef class Subject;
  
virtual class Observer;
  protected Subject subject_m;
  pure virtual function void update(int value);
endclass 
    
class Subject;
  protected int value_m;
  protected Observer observers_m[$];
  
  function new();
    observers_m = {};
  endfunction : new
  
  virtual function void register(Observer observer_a);
    observers_m.push_back(observer_a);
  endfunction : register
  
  virtual function void unregister(Observer observer_a);
    int indx_q[$] = observers_m.find_index(x) with (x == observer_a);
    // delete larger index first to avoid queue index operation issue
    indx_q.rsort();
    while(indx_q.size()) begin
      observers_m.delete(indx_q.pop_front());
    end
  endfunction : unregister
  
  virtual function void notifyAll();
    foreach(observers_m[i]) begin
      observers_m[i].update(value_m);
    end
  endfunction : notifyAll
  
  virtual function void setValue(int value_a);
    this.value_m = value_a;
    notifyAll();
  endfunction : setValue
  
  virtual function int getValue();
    return value_m;
  endfunction : getValue
endclass

    
class BinObserver extends Observer;
  function new(Subject subject_a);
    subject_m = subject_a;
    subject_m.register(this);
  endfunction 
  
  virtual function void update(int value);
    $display("Bin observer value = %0b", value);
  endfunction : update
endclass : BinObserver
   
class OctObserver extends Observer;
  function new(Subject subject_a);
    subject_m = subject_a;
    subject_m.register(this);
  endfunction 
  
  virtual function void update(int value);
    $display("Oct observer value = %0o", value);
  endfunction : update
endclass : OctObserver
    
class HexObserver extends Observer;
  function new(Subject subject_a);
    subject_m = subject_a;
    subject_m.register(this);
  endfunction 
  
  virtual function void update(int value);
    $display("Hex observer value = %0h", value);
  endfunction : update
endclass : HexObserver
    

program top;
  initial begin
    Subject subject = new;
    HexObserver hexObserver = new(subject);
    BinObserver binObserver = new(subject);
    OctObserver octObserver = new(subject);
    subject.register(octObserver);   // register twice
    subject.setValue(10);
    subject.unregister(octObserver);
    subject.setValue(12);
    subject.unregister(binObserver);
    subject.setValue(14);
    subject.unregister(hexObserver);
    subject.setValue(16);
  end
endprogram
