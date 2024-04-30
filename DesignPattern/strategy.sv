//
// https://www.edaplayground.com/x/cFJb
virtual class IBrakeBehavior;
  // Abstract method for brake
  pure virtual function void brake();
endclass

// Brake with ABS implementation
class BrakeWithABS extends IBrakeBehavior;
  // Overriding the brake method
  virtual function void brake();
    $display("Brake with ABS applied");
  endfunction
endclass

// Simple Brake implementation
class Brake extends IBrakeBehavior;
  // Overriding the brake method
  virtual function void brake();
    $display("Simple Brake applied");
  endfunction
endclass

// Abstract Car class
class Car;
  protected IBrakeBehavior brakeBehavior;
  string name;
  // Constructor
  function new(IBrakeBehavior brakeBehavior);
    this.brakeBehavior = brakeBehavior ;
  endfunction

  // Method to apply brake
  virtual function void applyBrake();
    brakeBehavior.brake();
  endfunction

  // Method to set brake behavior
  virtual function void setBrakeBehavior(IBrakeBehavior brakeType);
    this.brakeBehavior = brakeType;    
  endfunction
endclass



// Testbench to use the Car example
module CarExample;
  initial begin
    Car sedanCar;
    Car suvCar;
    Brake brake_m;
    BrakeWithABS abs_m;
    
    // Creating Sedan and SUV cars
    brake_m = new();
    abs_m = new();
    sedanCar = new(brake_m);
    suvCar = new(abs_m);

    // Applying brakes
    sedanCar.applyBrake();  // This will display "Simple Brake applied"
    suvCar.applyBrake();    // This will display "Brake with ABS applied"

    // Changing brake behavior dynamically
    brake_m = new();
    suvCar.setBrakeBehavior(brake_m);
    suvCar.applyBrake();    // This will display "Simple Brake applied"
  end
endmodule
