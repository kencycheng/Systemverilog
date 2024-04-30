// https://www.edaplayground.com/x/q6w8
// Define the interface class for Coffee
class Coffee;
   function new();
   endfunction

   virtual function int cost();
      return 1000;
   endfunction
endclass

virtual class DecoratorBase extends Coffee;
   pure virtual function int cost();
   pure virtual function Coffee decorate(Coffee coffee);
endclass

class Mocha extends DecoratorBase;
   Coffee coffee; 
   function new();
   endfunction 

   virtual function Coffee decorate(Coffee coffee);
      this.coffee=coffee;
      return this;
   endfunction

   virtual function int cost();
      return coffee.cost()+10;
   endfunction
endclass

class Milk extends DecoratorBase;
   Coffee coffee;
   function new();
   endfunction

   virtual function Coffee decorate(Coffee coffee);
      this.coffee=coffee;
      return this;
   endfunction
   
   virtual function int cost();
      return coffee.cost()+100;
   endfunction
endclass
  
module tb();
   initial begin
      Coffee c1;
      Mocha  d1, d2;
      Milk   d3;
      Coffee x1; // pointer to Coffee object

      c1 = new();
      d1 = new(); 
      d2 = new(); 
      d3 = new();
      x1=d1.decorate(c1);
      $display("## C1+D1 cost is %d", x1.cost());
      x1=d2.decorate(x1);
      $display("## D1+D2 cost is %d", x1.cost());
      x1=d3.decorate(x1);
      $display("## D2+D3 cost is %d", x1.cost()); 
   end
endmodule
