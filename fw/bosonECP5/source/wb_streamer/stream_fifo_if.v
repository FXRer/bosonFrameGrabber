//Public domain: Copied from http://billauer.co.il/reg_fifo.html.
//Modified by Olof Kindgren to provide streaming interface
module stream_fifo_if
  #(parameter DW = 0)
   (input 	wire	clk,
    input 	wire	rst,
    //FIFO Interface    
    input wire [DW-1:0] 	fifo_data_i,
    output 	wire 	fifo_rd_en_o,
    input wire		fifo_empty_i,
    //Stream Interface
    output reg [DW-1:0] stream_m_data_o,
    output reg 		stream_m_valid_o,
    input wire		stream_m_ready_i);
    
   reg 		    fifo_valid, middle_valid;
   reg [DW-1:0]     middle_dout;
   
   wire will_update_dout = (middle_valid || fifo_valid) && (stream_m_ready_i || !stream_m_valid_o);
   wire will_update_middle = fifo_valid && (middle_valid == will_update_dout);

   assign fifo_rd_en_o = (!fifo_empty_i) && !(middle_valid && stream_m_valid_o && fifo_valid);
   always @(posedge clk)
      if (rst)
         begin
            fifo_valid <= 0;
            middle_valid <= 0;
            stream_m_valid_o <= 0;
            stream_m_data_o <= 0;
            middle_dout <= 0;
         end
      else
         begin
            if (will_update_middle)
               middle_dout <= fifo_data_i;
            
            if (will_update_dout)
               stream_m_data_o <= middle_valid ? middle_dout : fifo_data_i;
            
            if (fifo_rd_en_o)
               fifo_valid <= 1;
            else if (will_update_middle || will_update_dout)
               fifo_valid <= 0;
            
            if (will_update_middle)
               middle_valid <= 1;
            else if (will_update_dout)
               middle_valid <= 0;
            
            if (will_update_dout)
               stream_m_valid_o <= 1;
            else if (stream_m_ready_i)
               stream_m_valid_o <= 0;
         end 
endmodule
