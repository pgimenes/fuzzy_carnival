
import top_pkg::*;
import node_scoreboard_pkg::*;

module node_scoreboard #(
    parameter AXIL_ADDR_WIDTH = 32,
    parameter NODESLOT_COUNT = 64
) (
    input logic core_clk,
    input logic resetn,

    // Regbank Slave AXI interface
    input  logic [AXIL_ADDR_WIDTH-1:0]                          s_axi_awaddr,
    input  logic [2:0]                                          s_axi_awprot,
    input  logic                                                s_axi_awvalid,
    output logic                                                s_axi_awready,
    input  logic [31:0]                                         s_axi_wdata,
    input  logic [3:0]                                          s_axi_wstrb,
    input  logic                                                s_axi_wvalid,
    output logic                                                s_axi_wready,
    input  logic [AXIL_ADDR_WIDTH-1:0]                          s_axi_araddr,
    input  logic [2:0]                                          s_axi_arprot,
    input  logic                                                s_axi_arvalid,
    output logic                                                s_axi_arready,
    output logic [31:0]                                         s_axi_rdata,
    output logic [1:0]                                          s_axi_rresp,
    output logic                                                s_axi_rvalid,
    input  logic                                                s_axi_rready,
    output logic [1:0]                                          s_axi_bresp,
    output logic                                                s_axi_bvalid,
    input  logic                                                s_axi_bready,

    // Controller -> Aggregation Engine Interface
    output logic                                                nsb_age_req_valid,
    input  logic                                                nsb_age_req_ready,
    output NSB_AGE_REQ_t                                        nsb_age_req,
    input  logic                                                nsb_age_resp_valid, // valid only for now
    input  NSB_AGE_RESP_t                                       nsb_age_resp,

    // Controller -> Transformation Engine Interface
    output logic                                                nsb_fte_req_valid,
    input  logic                                                nsb_fte_req_ready,
    output NSB_FTE_REQ_t                                        nsb_fte_req,
    input  logic                                                nsb_fte_resp_valid, // valid only for now
    input  NSB_FTE_RESP_t                                       nsb_fte_resp,

    // Controller -> Prefetcher Interface
    output logic                                                nsb_prefetcher_req_valid,
    input  logic                                                nsb_prefetcher_req_ready,
    output NSB_PREF_REQ_t                                       nsb_prefetcher_req,
    input  logic                                                nsb_prefetcher_resp_valid, // valid only for now
    input  NSB_PREF_RESP_t                                      nsb_prefetcher_resp,

    // Controller -> Output Buffer Interface
    output logic                                                nsb_output_buffer_req_valid,
    input  logic                                                nsb_output_buffer_req_ready,
    output NSB_OUT_BUFF_REQ_t                                   nsb_output_buffer_req,
    input  logic                                                nsb_output_buffer_resp_valid, // valid only for now
    input  NSB_OUT_BUFF_RESP_t                                  nsb_output_buffer_resp
);

parameter AXI_ADDRESS_MSB_BITS = AXI_ADDRESS_WIDTH % 32;

// ==================================================================================================================================================
// Declarations
// ==================================================================================================================================================

// Regbank
// ------------------------------------------------------------

// Host Control
logic ctrl_fetch_layer_weights_strobe;                                  // strobe signal for register 'CTRL_FETCH_LAYER_WEIGHTS' (pulsed when the register is written from the bus)
logic [0:0] ctrl_fetch_layer_weights_fetch;                             // value of field 'CTRL_FETCH_LAYER_WEIGHTS.FETCH'
logic ctrl_fetch_layer_weights_done_strobe;                             // strobe signal for register 'CTRL_FETCH_LAYER_WEIGHTS_DONE' (pulsed when the register is read from the bus)
logic [0:0] ctrl_fetch_layer_weights_done_done;                         // value of field 'CTRL_FETCH_LAYER_WEIGHTS_DONE.DONE'
logic ctrl_fetch_layer_weights_done_ack_strobe;                         // strobe signal for register 'CTRL_FETCH_LAYER_WEIGHTS_DONE_ACK' (pulsed when the register is written from the bus)
logic [0:0] ctrl_fetch_layer_weights_done_ack_ack;                      // value of field 'CTRL_FETCH_LAYER_WEIGHTS_DONE_ACK.ACK'

// Layer Config
logic layer_config_strobe;                                              // strobe signal for register 'LAYER_CONFIG' (pulsed when the register is written from the bus)
logic [9:0] layer_config_in_features;                                   // value of field 'LAYER_CONFIG.IN_FEATURES'
logic [9:0] layer_config_out_features;                                  // value of field 'LAYER_CONFIG.OUT_FEATURES'
logic [3:0] layer_config_weight_precision;                              // value of field 'LAYER_CONFIG.WEIGHT_PRECISION'
logic [3:0] layer_config_activation_precision;                          // value of field 'LAYER_CONFIG.ACTIVATION_PRECISION'

logic layer_config_weights_address_lsb_strobe;                          // strobe signal for register 'LAYER_CONFIG_WEIGHTS_ADDRESS_LSB' (pulsed when the register is written from the bus)
logic [31:0] layer_config_weights_address_lsb_lsb;                      // value of field 'LAYER_CONFIG_WEIGHTS_ADDRESS_LSB.LSB'
logic layer_config_weights_address_msb_strobe;                          // strobe signal for register 'LAYER_CONFIG_WEIGHTS_ADDRESS_MSB' (pulsed when the register is written from the bus)
logic [1:0] layer_config_weights_address_msb_msb;                       // value of field 'LAYER_CONFIG_WEIGHTS_ADDRESS_MSB.MSB'

logic layer_config_in_messages_adress_lsb_strobe;                       // strobe signal for register 'LAYER_CONFIG_IN_MESSAGES_ADRESS_LSB' (pulsed when the register is written from the bus)
logic [31:0] layer_config_in_messages_adress_lsb_lsb;                   // value of field 'LAYER_CONFIG_IN_MESSAGES_ADRESS_LSB.LSB'
logic layer_config_in_messages_adress_msb_strobe;                       // strobe signal for register 'LAYER_CONFIG_IN_MESSAGES_ADRESS_MSB' (pulsed when the register is written from the bus)
logic [1:0] layer_config_in_messages_adress_msb_msb;                    // value of field 'LAYER_CONFIG_IN_MESSAGES_ADRESS_MSB.MSB'

logic layer_config_out_messages_adress_lsb_strobe;                      // strobe signal for register 'LAYER_CONFIG_OUT_MESSAGES_ADRESS_LSB' (pulsed when the register is written from the bus)
logic [31:0] layer_config_out_messages_adress_lsb_lsb;                  // value of field 'LAYER_CONFIG_OUT_MESSAGES_ADRESS_LSB.LSB'
logic layer_config_out_messages_adress_msb_strobe;                      // strobe signal for register 'LAYER_CONFIG_OUT_MESSAGES_ADRESS_MSB' (pulsed when the register is written from the bus)
logic [31:0] layer_config_out_messages_adress_msb_value;                // value of field 'LAYER_CONFIG_OUT_MESSAGES_ADRESS_MSB.value'

// Nodeslots
logic [63:0] nsb_nodeslot_neighbour_count_strobe;                       // strobe signal for register 'NSB_NODESLOT_NEIGHBOUR_COUNT' (pulsed when the register is written from the bus)
logic [63:0] [19:0] nsb_nodeslot_neighbour_count_count;                 // value of field 'NSB_NODESLOT_NEIGHBOUR_COUNT.COUNT'
logic [63:0] nsb_nodeslot_node_id_strobe;                               // strobe signal for register 'NSB_NODESLOT_NODE_ID' (pulsed when the register is written from the bus)
logic [63:0] [19:0] nsb_nodeslot_node_id_id;                            // value of field 'NSB_NODESLOT_NODE_ID.ID'
logic [63:0] nsb_nodeslot_node_state_strobe;                            // strobe signal for register 'NSB_NODESLOT_NODE_STATE' (pulsed when the register is written from the bus)
logic [63:0] [3:0] nsb_nodeslot_node_state_state;                       // value of field 'NSB_NODESLOT_NODE_STATE.STATE'
logic [63:0] nsb_nodeslot_precision_strobe;                             // strobe signal for register 'NSB_NODESLOT_PRECISION' (pulsed when the register is written from the bus)
logic [63:0] [1:0] nsb_nodeslot_precision_precision;                    // value of field 'NSB_NODESLOT_PRECISION.PRECISION'
logic [63:0] nsb_nodeslot_adjacency_list_address_lsb_strobe;            // strobe signal for register 'NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB' (pulsed when the register is written from the bus)
logic [63:0] [31:0] nsb_nodeslot_adjacency_list_address_lsb_lsb;        // value of field 'NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_LSB.LSB'
logic [63:0] nsb_nodeslot_adjacency_list_address_msb_strobe;            // strobe signal for register 'NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB' (pulsed when the register is written from the bus)
logic [63:0] [1:0] nsb_nodeslot_adjacency_list_address_msb_msb;         // value of field 'NSB_NODESLOT_ADJACENCY_LIST_ADDRESS_MSB.MSB'
logic [63:0] nsb_nodeslot_out_messages_address_lsb_strobe;              // strobe signal for register 'NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB' (pulsed when the register is written from the bus)
logic [63:0] [31:0] nsb_nodeslot_out_messages_address_lsb_lsb;          // value of field 'NSB_NODESLOT_OUT_MESSAGES_ADDRESS_LSB.LSB'
logic [63:0] nsb_nodeslot_out_messages_address_msb_strobe;              // strobe signal for register 'NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB' (pulsed when the register is written from the bus)
logic [63:0] [1:0] nsb_nodeslot_out_messages_address_msb_msb;           // value of field 'NSB_NODESLOT_OUT_MESSAGES_ADDRESS_MSB.MSB'

logic nsb_nodeslot_config_make_valid_msb_strobe; // strobe signal for register 'NSB_NODESLOT_CONFIG_MAKE_VALID_MSB' (pulsed when the register is written from the bus)
logic [31:0] nsb_nodeslot_config_make_valid_msb_make_valid; // value of field 'NSB_NODESLOT_CONFIG_MAKE_VALID_MSB.MAKE_VALID'
logic nsb_nodeslot_config_make_valid_lsb_strobe; // strobe signal for register 'NSB_NODESLOT_CONFIG_MAKE_VALID_LSB' (pulsed when the register is written from the bus)
logic [31:0] nsb_nodeslot_config_make_valid_lsb_make_valid;// value of field 'NSB_NODESLOT_CONFIG_MAKE_VALID_LSB.MAKE_VALID'

logic nsb_config_aggregation_wait_count_strobe; // strobe signal for register 'NSB_CONFIG_AGGREGATION_WAIT_COUNT' (pulsed when the register is written from the bus)
logic [5:0] nsb_config_aggregation_wait_count_count; // value of field 'NSB_CONFIG_AGGREGATION_WAIT_COUNT.COUNT'
logic nsb_config_transformation_wait_count_strobe; // strobe signal for register 'NSB_CONFIG_TRANSFORMATION_WAIT_COUNT' (pulsed when the register is written from the bus)
logic [5:0] nsb_config_transformation_wait_count_count;// value of field 'NSB_CONFIG_TRANSFORMATION_WAIT_COUNT.COUNT'

// Other
// ------------------------------------------------------------

logic [NODESLOT_COUNT-1:0] [3:0] nodeslot_state, nodeslot_state_n; // not defined as enum to avoid VRFC 10-2649
logic [NODESLOT_COUNT-1:0] nodeslot_make_valid;

// Done masks
logic [NODESLOT_COUNT-1:0] fetch_nb_list_resp_received;
logic [NODESLOT_COUNT-1:0] fetch_nbs_resp_received;
logic [NODESLOT_COUNT-1:0] aggregation_done;
logic [NODESLOT_COUNT-1:0] transformation_done;

// State masks
logic [NODESLOT_COUNT-1:0] nodeslots_waiting_nb_list_fetch;
logic [NODESLOT_COUNT-1:0] nodeslots_waiting_neighbour_fetch;
logic [NODESLOT_COUNT-1:0] nodeslots_waiting_prefetcher;
logic [NODESLOT_COUNT-1:0] nodeslots_waiting_aggregation;
logic [NODESLOT_COUNT-1:0] nodeslots_waiting_transformation;
logic [NODESLOT_COUNT-1:0] nodeslots_waiting_writeback;

logic accepting_prefetch_request;
logic accepting_aggr_request;
logic accepting_transformation_request;
logic accepting_writeback_request;

logic [5:0] aggregation_buffer_population_count;
logic [5:0] transformation_buffer_population_count;

// ==================================================================================================================================================
// Instances
// ==================================================================================================================================================

// Regbank
// ------------------------------------------------------------
node_scoreboard_regbank_regs node_scoreboard_regbank_i (
    // Clock and Reset
    .axi_aclk                       (core_clk),
    .axi_aresetn                    (resetn),

    // AXI Write Address Channel
    .s_axi_awaddr,
    .s_axi_awprot,
    .s_axi_awvalid,
    .s_axi_awready,
    .s_axi_wdata,
    .s_axi_wstrb,
    .s_axi_wvalid,
    .s_axi_wready,
    .s_axi_araddr,
    .s_axi_arprot,
    .s_axi_arvalid,
    .s_axi_arready,
    .s_axi_rdata,
    .s_axi_rresp,
    .s_axi_rvalid,
    .s_axi_rready,
    .s_axi_bresp,
    .s_axi_bvalid,
    .s_axi_bready,

    // User Ports
    .layer_config_strobe,
    .layer_config_in_features,
    .layer_config_out_features,
    .layer_config_weight_precision,
    .layer_config_activation_precision,
    .layer_config_weights_address_lsb_strobe,
    .layer_config_weights_address_lsb_lsb,
    .layer_config_weights_address_msb_strobe,
    .layer_config_weights_address_msb_msb,
    .ctrl_fetch_layer_weights_strobe,
    .ctrl_fetch_layer_weights_fetch,
    .ctrl_fetch_layer_weights_done_strobe,
    .ctrl_fetch_layer_weights_done_done,
    .ctrl_fetch_layer_weights_done_ack_strobe,
    .ctrl_fetch_layer_weights_done_ack_ack,
    .layer_config_in_messages_adress_lsb_strobe,
    .layer_config_in_messages_adress_lsb_lsb,
    .layer_config_in_messages_adress_msb_strobe,
    .layer_config_in_messages_adress_msb_msb,
    .layer_config_out_messages_adress_lsb_strobe,
    .layer_config_out_messages_adress_lsb_lsb,
    .layer_config_out_messages_adress_msb_strobe,
    .layer_config_out_messages_adress_msb_value,
    .nsb_nodeslot_neighbour_count_strobe,
    .nsb_nodeslot_neighbour_count_count,
    .nsb_nodeslot_node_id_strobe,
    .nsb_nodeslot_node_id_id,
    .nsb_nodeslot_node_state_strobe,
    .nsb_nodeslot_node_state_state,
    .nsb_nodeslot_precision_strobe,
    .nsb_nodeslot_precision_precision,
    .nsb_nodeslot_adjacency_list_address_lsb_strobe,
    .nsb_nodeslot_adjacency_list_address_lsb_lsb,
    .nsb_nodeslot_adjacency_list_address_msb_strobe,
    .nsb_nodeslot_adjacency_list_address_msb_msb,
    .nsb_nodeslot_out_messages_address_lsb_strobe,
    .nsb_nodeslot_out_messages_address_lsb_lsb,
    .nsb_nodeslot_out_messages_address_msb_strobe,
    .nsb_nodeslot_out_messages_address_msb_msb,
    .nsb_nodeslot_config_make_valid_msb_strobe,
    .nsb_nodeslot_config_make_valid_msb_make_valid,
    .nsb_nodeslot_config_make_valid_lsb_strobe,
    .nsb_nodeslot_config_make_valid_lsb_make_valid,
    .nsb_config_aggregation_wait_count_strobe,
    .nsb_config_aggregation_wait_count_count,
    .nsb_config_transformation_wait_count_strobe,
    .nsb_config_transformation_wait_count_count,
    .*
);

// ==================================================================================================================================================
// Logic
// ==================================================================================================================================================

// Masks
assign nodeslot_make_valid[31:0] = nsb_nodeslot_config_make_valid_lsb_make_valid;
assign nodeslot_make_valid[63:32] = nsb_nodeslot_config_make_valid_msb_make_valid;

assign accepting_prefetch_request = nsb_prefetcher_req_valid && nsb_prefetcher_req_ready;
assign accepting_aggr_request = nsb_age_req_valid && nsb_age_req_ready;

assign accepting_transformation_request = nsb_fte_req_valid && nsb_fte_req_ready;
assign accepting_writeback_request = nsb_output_buffer_req_valid && nsb_output_buffer_req_ready;

// Per-Nodeslot Logic
// ------------------------------------------------------------

for (genvar nodeslot = 0; nodeslot < NODESLOT_COUNT; nodeslot = nodeslot + 1) begin

    assign nodeslot_state[nodeslot] = nsb_nodeslot_node_state_state[nodeslot];

    always_ff @( posedge core_clk or negedge resetn) begin
        if (!resetn) begin
            nsb_nodeslot_node_state_state[nodeslot] <= node_scoreboard_pkg::EMPTY;
            fetch_nb_list_resp_received[nodeslot]   <= '0;
            fetch_nbs_resp_received[nodeslot]       <= '0;
            aggregation_done [nodeslot]                    <= '0;
            transformation_done [nodeslot]                 <= '0;

        end else if (nodeslot_state_n[nodeslot] == EMPTY) begin
            nsb_nodeslot_node_state_state[nodeslot] <= nodeslot_state_n[nodeslot];

            // Update done mask from prefetcher response
            fetch_nb_list_resp_received [nodeslot]         <= '0;
            fetch_nbs_resp_received [nodeslot]             <= '0;
            aggregation_done [nodeslot]                    <= '0;
            transformation_done [nodeslot]                 <= '0;

        end else begin
            nsb_nodeslot_node_state_state[nodeslot] <= nodeslot_state_n[nodeslot];

            if ((nodeslot_state == FETCH_NB_LIST) && nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.nodeslot == nodeslot) && (nsb_prefetcher_resp.response_type == ADJACENCY_LIST)) begin
                fetch_nb_list_resp_received[nodeslot]         <= 1'b1;

            end else if ((nodeslot_state == FETCH_NEIGHBOURS) && nsb_prefetcher_resp_valid && (nsb_prefetcher_resp.nodeslot == nodeslot) && (nsb_prefetcher_resp.response_type == MESSAGES)) begin
                fetch_nbs_resp_received[nodeslot]             <= 1'b1;

            end else if ((nodeslot_state == AGGR) && nsb_age_resp_valid && (nsb_age_resp.nodeslot == nodeslot)) begin
                aggregation_done[nodeslot]                    <= 1'b1;

            end else if ((nodeslot_state == TRANS) && nsb_fte_resp_valid && (nsb_fte_resp.nodeslot == nodeslot)) begin
                transformation_done[nodeslot]                    <= 1'b1;
            end
        end
    end

    // Nodeslot State Machine
    // ------------------------------------------------------------

    always_comb begin
        nodeslot_state_n[nodeslot] = node_scoreboard_pkg::EMPTY;

        case (nodeslot_state[nodeslot])
            node_scoreboard_pkg::EMPTY: begin
                nodeslot_state_n[nodeslot] = nodeslot_make_valid[nodeslot] ? node_scoreboard_pkg::PROG_DONE
                                    : node_scoreboard_pkg::EMPTY;
            end

            node_scoreboard_pkg::PROG_DONE: begin
                nodeslot_state_n[nodeslot] = accepting_prefetch_request && (nsb_prefetcher_req.nodeslot == nodeslot) && (nsb_prefetcher_req.req_opcode == ADJACENCY_LIST) ? node_scoreboard_pkg::FETCH_NB_LIST
                                    : node_scoreboard_pkg::PROG_DONE;
            end

            node_scoreboard_pkg::FETCH_NB_LIST: begin // move when resp received and pref ready
                nodeslot_state_n[nodeslot] = fetch_nb_list_resp_received[nodeslot] && accepting_prefetch_request && (nsb_prefetcher_req.nodeslot == nodeslot) && (nsb_prefetcher_req.req_opcode == MESSAGES) ? node_scoreboard_pkg::FETCH_NEIGHBOURS
                                    : node_scoreboard_pkg::FETCH_NB_LIST;
            end

            node_scoreboard_pkg::FETCH_NEIGHBOURS: begin // move when resp received and age ready
                nodeslot_state_n[nodeslot] = fetch_nbs_resp_received[nodeslot] && accepting_aggr_request && (nsb_age_req.nodeslot == nodeslot) ? node_scoreboard_pkg::AGGR
                                    : node_scoreboard_pkg::FETCH_NEIGHBOURS;
            end

            node_scoreboard_pkg::AGGR: begin
                nodeslot_state_n[nodeslot] = aggregation_done[nodeslot] && accepting_transformation_request ? node_scoreboard_pkg::TRANS
                                    : node_scoreboard_pkg::AGGR;
            end

            node_scoreboard_pkg::TRANS: begin
                nodeslot_state_n[nodeslot] = transformation_done[nodeslot] && accepting_writeback_request ? node_scoreboard_pkg::WRITEBACK
                                    : node_scoreboard_pkg::TRANS;
            end

            node_scoreboard_pkg::PASS: begin // TO DO: implement (MS4)
                nodeslot_state_n[nodeslot] = node_scoreboard_pkg::EMPTY;
            end

            node_scoreboard_pkg::WRITEBACK: begin
                nodeslot_state_n[nodeslot] = nsb_output_buffer_resp_valid && (nsb_output_buffer_resp.nodeslot == nodeslot) ? node_scoreboard_pkg::EMPTY
                                    : node_scoreboard_pkg::WRITEBACK;
            end

            node_scoreboard_pkg::HALT: begin // TO DO: implement (MS5)
                nodeslot_state_n[nodeslot] = node_scoreboard_pkg::EMPTY;
            end

        endcase
    end

    // State masks for request logic
    assign nodeslots_waiting_nb_list_fetch   [nodeslot] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::PROG_DONE);
    assign nodeslots_waiting_neighbour_fetch [nodeslot] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::FETCH_NB_LIST) && fetch_nb_list_resp_received[nodeslot];
    assign nodeslots_waiting_prefetcher      [nodeslot] = nodeslots_waiting_nb_list_fetch[nodeslot] || nodeslots_waiting_neighbour_fetch[nodeslot];
    assign nodeslots_waiting_aggregation     [nodeslot] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::FETCH_NB_LIST) && fetch_nbs_resp_received[nodeslot];
    assign nodeslots_waiting_transformation  [nodeslot] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::AGGR) && aggregation_done[nodeslot];
    assign nodeslots_waiting_writeback       [nodeslot] = (nodeslot_state[nodeslot] == node_scoreboard_pkg::TRANS) && transformation_done[nodeslot];
end

always_ff @(posedge core_clk or negedge resetn) begin
    if (!resetn) begin
        aggregation_buffer_population_count         <= '0;
        transformation_buffer_population_count      <= '0;
    end else begin
        if (nsb_age_resp_valid) begin
            aggregation_buffer_population_count         <= aggregation_buffer_population_count + 1'b1;
        end else if (accepting_transformation_request) begin
            aggregation_buffer_population_count         <= '0;
        end

        if (nsb_fte_resp_valid) begin
            transformation_buffer_population_count         <= transformation_buffer_population_count + 1'b1;
        end else if (accepting_writeback_request) begin
            transformation_buffer_population_count         <= '0;
        end
    end
end

// Prefetcher requests
// ------------------------------------------------------------

logic [NODESLOT_COUNT-1:0]         prefetcher_arbiter_grant_oh;
logic [$clog2(NODESLOT_COUNT)-1:0] prefetcher_arbiter_grant_bin;

rr_arbiter #(
    .NUM_REQUESTERS     (NODESLOT_COUNT)
) prefetcher_req_arb (
    .clk                (core_clk),
    .resetn             (resetn),
    .request            (nodeslots_waiting_prefetcher),
    .update_lru         (nsb_prefetcher_req_valid && nsb_prefetcher_req_ready),
    .grant_oh           (prefetcher_arbiter_grant_oh)
);

onehot_to_binary #(
    .INPUT_WIDTH    (NODESLOT_COUNT)
) prefetcher_req_oh2bin (
    .clk            (core_clk), // not registered for now
    .resetn         (resetn),
    .input_data     (prefetcher_arbiter_grant_oh),
    .output_data    (prefetcher_arbiter_grant_bin)
);

always_comb begin : nsb_prefetcher_req_logic
    nsb_prefetcher_req_valid         = |nodeslots_waiting_prefetcher;
    nsb_prefetcher_req.req_opcode    = |(nodeslots_waiting_nb_list_fetch & prefetcher_arbiter_grant_oh) ? top_pkg::ADJACENCY_LIST
                                        : |(nodeslots_waiting_neighbour_fetch & prefetcher_arbiter_grant_oh) ? top_pkg::MESSAGES
                                        : top_pkg::ERROR;
    nsb_prefetcher_req.nodeslot      = prefetcher_arbiter_grant_bin;
    
    if (AXI_ADDR_MSB_BITS == 0)
        nsb_prefetcher_req.start_address = nsb_nodeslot_adjacency_list_address_lsb_lsb[prefetcher_arbiter_grant_bin];
    else
        nsb_prefetcher_req.start_address = {nsb_nodeslot_adjacency_list_address_msb_msb[prefetcher_arbiter_grant_bin][AXI_ADDR_MSB_BITS-1:0],
                                            nsb_nodeslot_adjacency_list_address_lsb_lsb[prefetcher_arbiter_grant_bin]};
    
    nsb_prefetcher_req.neighbour_count = nsb_nodeslot_neighbour_count_count[prefetcher_arbiter_grant_bin];
end

// Aggregation requests
// ------------------------------------------------------------

logic [NODESLOT_COUNT-1:0]         age_arbiter_grant_oh;
logic [$clog2(NODESLOT_COUNT)-1:0] age_arbiter_grant_bin;

rr_arbiter #(
    .NUM_REQUESTERS     (NODESLOT_COUNT)
) age_req_arb (
    .clk                (core_clk),
    .resetn             (resetn),
    .request            (nodeslots_waiting_aggregation),
    .update_lru         (nsb_age_req_valid && nsb_age_req_ready),
    .grant_oh           (age_arbiter_grant_oh)
);

onehot_to_binary #(
    .INPUT_WIDTH    (NODESLOT_COUNT)
) age_req_oh2bin (
    .clk            (core_clk), // not registered for now
    .resetn         (resetn),
    .input_data     (age_arbiter_grant_oh),
    .output_data    (age_arbiter_grant_bin)
);

assign nsb_age_req_valid                = |nodeslots_waiting_aggregation;
assign nsb_age_req.nodeslot             = age_arbiter_grant_bin;
assign nsb_age_req.node_precision       = top_pkg::FIXED_16; // TO DO: implement (MS3)
assign nsb_age_req.aggregation_function = top_pkg::SUM; // TO DO: implement (MS3). Layer wise or node wise?

// Transformation requests
// ------------------------------------------------------------

assign nsb_fte_req_valid                = (aggregation_buffer_population_count == nsb_config_aggregation_wait_count_count);
assign nsb_fte_req.nodeslots            = nodeslots_waiting_transformation;

// Writeback requests
// ------------------------------------------------------------

assign nsb_output_buffer_req_valid      = (transformation_buffer_population_count == nsb_config_transformation_wait_count_count);
assign nsb_output_buffer_req.nodeslots  = nodeslots_waiting_writeback;

// TO DO
// ------------------------------------------------------------

assign ctrl_fetch_layer_weights_done_done = '0;

// ==================================================================================================================================================
// Assertions
// ==================================================================================================================================================

endmodule