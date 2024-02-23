// https://www.edaplayground.com/x/Cy2W
// Modeling a bidirectional I/O 

module phy(mdio_if mdio_if_s );
  
 initial begin
   int preamble_cnt = 0;
   bit[15:0] read_data = 16'habcd;
   while(preamble_cnt<32) begin
     @(mdio_if_s.mdio_scb);
     if(mdio_if_s.mdio_scb.mdio == 1'b1) preamble_cnt +=1;
     else preamble_cnt = 0;     
   end
   repeat(4+5+5+1) @(mdio_if_s.mdio_scb);
   // if pa & ra is decoded and correct
   for(int i=0; i<16; i=i+1)begin
     @(mdio_if_s.mdio_sncb);
     mdio_if_s.mdio_sncb.mdio <= read_data[15-i];
     $display("phy read_data = %h, %1b", read_data, read_data[15-i] );
   end
   @(mdio_if_s.mdio_sncb);
     mdio_if_s.mdio_sncb.mdio <= 1'bz;
 end
endmodule  

interface mdio_if(input wire mdc, inout wire mdio);
  parameter SETUP = 10;
  parameter HOLD  = 10;
  
  
  clocking mdio_cb @(posedge mdc);
    input #SETUP mdio;
  endclocking
  
  clocking mdio_ncb @(negedge mdc);
    output #HOLD  mdio;
  endclocking
  
  clocking mdio_scb @(posedge mdc);
    input #SETUP mdio;
  endclocking
  
  clocking mdio_sncb @(posedge mdc);
    output #HOLD mdio;
  endclocking
  
  modport PHY(clocking mdio_scb, clocking mdio_sncb);
  
endinterface



    
module test;
  reg mdc;
  mdio_if mdio_if_m(.mdc(mdc), .mdio(mdio));
  phy     phy_1(mdio_if_m.PHY);
 initial begin
   $dumpfile("dump.vcd"); $dumpvars;
   mdc = 0;
   forever begin
     #200 mdc = ~mdc;
   end
 end
  // sta
 initial begin
   bit[4:0] pa;
   bit[4:0] ra;
   bit[15:0] read_data;
   
   //32 preambles
   @(mdio_if_m.mdio_ncb);
     mdio_if_m.mdio_ncb.mdio <= 1'b0;
   repeat(32) begin
     @(mdio_if_m.mdio_ncb);
     mdio_if_m.mdio_ncb.mdio <= 1'b1;
   end
   // cmd read
   @(mdio_if_m.mdio_ncb);
   mdio_if_m.mdio_ncb.mdio <= 1'b0;
   @(mdio_if_m.mdio_ncb);
   mdio_if_m.mdio_ncb.mdio <= 1'b1;
   @(mdio_if_m.mdio_ncb);
   mdio_if_m.mdio_ncb.mdio <= 1'b1;
   @(mdio_if_m.mdio_ncb);
   mdio_if_m.mdio_ncb.mdio <= 1'b0;
   // address
   pa = 5'h5;
   for(int i=0; i<5; i= i+1) begin
     @(mdio_if_m.mdio_ncb);
     mdio_if_m.mdio_ncb.mdio <= pa[4-i];
   end
   ra = 5'hc;
   for(int i=0; i<5; i= i+1) begin
     @(mdio_if_m.mdio_ncb);
     mdio_if_m.mdio_ncb.mdio <= ra[4-i];
   end
   // TA
   @(mdio_if_m.mdio_ncb);
     mdio_if_m.mdio_ncb.mdio <= 1'bz;
   @(mdio_if_m.mdio_ncb);
   @(mdio_if_m.mdio_ncb);
   // read data
   for(int i=0; i<16; i= i+1) begin
     @(mdio_if_m.mdio_cb);
     read_data[15-i] = mdio_if_m.mdio_cb.mdio;
     $display("mdio_master read_data = %h %1b", read_data, mdio_if_m.mdio_cb.mdio);
   end
 
  
   
   $finish();
   
 end

endmodule

    
