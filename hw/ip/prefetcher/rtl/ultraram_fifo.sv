
/*

When FIFO receives pop, read pointer is updated directly but new data is available
on out_data when out_valid is asserted (RAM reads take 3 cycles)

*/

module ultraram_fifo #(
    parameter WIDTH = 512,
    parameter DEPTH = 4096
) (
    input  logic                      core_clk,
    input  logic                      resetn,
    input  logic                      push,
    input  logic [WIDTH-1:0]          in_data,
    input  logic                      pop,
    output logic                      out_valid,
    output logic [WIDTH-1:0]          out_data,
    output logic [$clog2(DEPTH)-1:0]  count,
    output logic                      empty,
    output logic                      full
);

parameter AWIDTH = $clog2(DEPTH);

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

logic [AWIDTH-1:0] wr_ptr;
logic [AWIDTH-1:0] rd_ptr;

logic pop1, pop2;

logic wr_wrap, rd_wrap;

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

ultraram #(
    .AWIDTH(AWIDTH),  // Address Width
    .DWIDTH(WIDTH),  // Data Width
    .NBPIPE(1)   // Number of pipeline Registers
) address_queue (
    .core_clk           (core_clk),
    .resetn             (resetn),
    .write_enable       (push),
    .regceb             ('1), // TO DO: change for power savings
    .mem_en             ('1), // TO DO: change for power savings
    .dina               (in_data),
    .addra              (wr_ptr),
    .addrb              (rd_ptr),
    .doutb              (out_data)
);

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        wr_ptr <= '0;
        rd_ptr <= '0;

        pop1      <= '0;
        pop2      <= '0;
        out_valid <= '0;

        wr_wrap   <= '0;
        rd_wrap   <= '0;

        count     <= '0;
    end else begin
        if (push) begin
            wr_ptr <= wr_ptr + 1'b1;
            count <= count + 1'b1;
        end
        
        if (pop) begin
            wr_ptr <= wr_ptr + 1'b1;
            count <= count - 1'b1;
        end

        // Latch out_valid to 0 when pop or to 1, 3 cycles later
        // This accounts for RAM delay
        if (pop) out_valid <= '0;
        else if (pop2) out_valid <= '1;

        pop1 <= pop;
        pop2 <= pop1;

        if (wr_ptr == {AWIDTH{1'b1}} && push) wr_wrap <= !wr_wrap;
        if (rd_ptr == {AWIDTH{1'b1}} && pop) rd_wrap <= !rd_wrap;
    end
end

assign empty = (wr_ptr == rd_ptr) && !(wr_wrap ^ rd_wrap);
assign full = (wr_ptr == rd_ptr) && (wr_wrap ^ rd_wrap);

endmodule