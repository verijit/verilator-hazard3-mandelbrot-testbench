module soc(input clock,
           output [31:0] keep_alive,
           output reg finished);
  
  initial finished = 1'b0;
  
  // Reset in the first cycle
  reg reset = 1'b1;
  always @(posedge clock)
    reset <= 1'b0;

  wire pwrup_req;
  wire unblock_out;

  localparam W_ADDR = 32;
  localparam W_DATA = 32;

  // Instruction fetch port
  wire [W_ADDR-1:0]  i_haddr;
  wire               i_hwrite;
  wire [1:0]         i_htrans;
  wire [2:0]         i_hsize;
  wire [2:0]         i_hburst;
  wire [3:0]         i_hprot;
  wire               i_hmastlock;
  wire [7:0]         i_hmaster;
  wire               i_hready;
  wire               i_hresp;
  wire [W_DATA-1:0]  i_hwdata;
  wire [W_DATA-1:0]  i_hrdata;

  // Load/store port
  wire [W_ADDR-1:0]  d_haddr;
  wire               d_hwrite;
  wire [1:0]         d_htrans;
  wire [2:0]         d_hsize;
  wire [2:0]         d_hburst;
  wire [3:0]         d_hprot;
  wire               d_hmastlock;
  wire [7:0]         d_hmaster;
  wire               d_hexcl;
  wire               d_hready;
  wire               d_hresp;
  wire               d_hexokay;
  wire [W_DATA-1:0]  d_hwdata;
  wire [W_DATA-1:0]  d_hrdata;

  localparam RESET_VECTOR = ${reset_vector};
  localparam RESET_REGFILE = 0;

  // From config_min.vh
  //localparam RESET_VECTOR        = 32'h80000040;
  localparam MTVEC_INIT          = 32'h80000000;
  localparam EXTENSION_A         = 0;
  localparam EXTENSION_C         = 1;
  localparam EXTENSION_E         = 0;
  localparam EXTENSION_M         = 1;
  localparam EXTENSION_ZBA       = 0;
  localparam EXTENSION_ZBB       = 0;
  localparam EXTENSION_ZBC       = 0;
  localparam EXTENSION_ZBKB      = 0;
  localparam EXTENSION_ZBKX      = 0;
  localparam EXTENSION_ZBS       = 0;
  localparam EXTENSION_ZCB       = 0;
  localparam EXTENSION_ZCLSD     = 0;
  localparam EXTENSION_ZCMP      = 0;
  localparam EXTENSION_ZIFENCEI  = 0;
  localparam EXTENSION_ZILSD     = 0;
  localparam EXTENSION_XH3BEXTM  = 0;
  localparam EXTENSION_XH3IRQ    = 0;
  localparam EXTENSION_XH3PMPM   = 0;
  localparam EXTENSION_XH3POWER  = 0;
  localparam CSR_M_MANDATORY     = 0;
  localparam CSR_M_TRAP          = 0;
  localparam CSR_COUNTER         = 0;
  localparam U_MODE              = 0;
  localparam PMP_REGIONS         = 0;
  localparam PMP_GRAIN           = 0;
  localparam PMP_MATCH_NAPOT     = 1;
  localparam PMP_MATCH_TOR       = 0;
  localparam PMP_HARDWIRED       = {(PMP_REGIONS > 0 ? PMP_REGIONS : 1){1'b0}};
  localparam PMP_HARDWIRED_ADDR  = {(PMP_REGIONS > 0 ? PMP_REGIONS : 1){32'h0}};
  localparam PMP_HARDWIRED_CFG   = {(PMP_REGIONS > 0 ? PMP_REGIONS : 1){8'h00}};
  localparam DEBUG_SUPPORT       = 0;
  localparam BREAKPOINT_TRIGGERS = 4;
  localparam NUM_IRQS            = 32;
  localparam IRQ_PRIORITY_BITS   = 0;
  localparam IRQ_INPUT_BYPASS    = {NUM_IRQS{1'b0}};
  localparam MVENDORID_VAL       = 32'hdeadbeef;
  localparam MCONFIGPTR_VAL      = 32'h9abcdef0;
  localparam REDUCED_BYPASS      = 1;
  localparam MULDIV_UNROLL       = 32;
  localparam MUL_FAST            = 1;
  localparam MUL_FASTER          = 1;
  localparam MULH_FAST           = 1;
  localparam FAST_BRANCHCMP      = 0;
  //localparam RESET_REGFILE       = 1;
  localparam BRANCH_PREDICTOR    = 0;
  localparam MTVEC_WMASK         = 32'hfffffffd;
  // End from

  hazard3_cpu_2port #(
    `include "hazard3_config_inst.vh"
  ) core(
    // Global signals
    .clk(clock),
    .clk_always_on(clock),
    .rst_n(!reset),

    // Power control signals
    .pwrup_req(pwrup_req),
    .pwrup_ack(pwrup_req), // Tied back, see example_soc.v
    .clk_en(/* unused */),
    .unblock_out(unblock_out),
    .unblock_in(unblock_out), // Tied back, see example_soc.v

    // Instruction fetch port
    .i_haddr(i_haddr),
    .i_hwrite(i_hwrite),
    .i_htrans(i_htrans),
    .i_hsize(i_hsize),
    .i_hburst(i_hburst),
    .i_hprot(i_hprot),
    .i_hmastlock(i_hmastlock),
    .i_hmaster(i_hmaster),
    .i_hready(i_hready),
    .i_hresp(i_hresp),
    .i_hwdata(i_hwdata),
    .i_hrdata(i_hrdata),

    // Load/store port
    .d_haddr(d_haddr),
    .d_hwrite(d_hwrite),
    .d_htrans(d_htrans),
    .d_hsize(d_hsize),
    .d_hburst(d_hburst),
    .d_hprot(d_hprot),
    .d_hmastlock(d_hmastlock),
    .d_hmaster(d_hmaster),
    .d_hexcl(d_hexcl),
    .d_hready(d_hready),
    .d_hresp(d_hresp),
    .d_hexokay(d_hexokay),
    .d_hwdata(d_hwdata),
    .d_hrdata(d_hrdata),

    // Memory ordering signals
    .fence_i_vld(/* unused */),
    .fence_d_vld(/* unused */),
    .fence_rdy(1'b1),

    // Debugger run/halt control
    .dbg_req_halt(1'b0),
    .dbg_req_halt_on_reset(1'b0),
    .dbg_req_resume(1'b0),
    .dbg_halted(/* unused */),
    .dbg_running(/* unused */),
    
    .dbg_data0_rdata(/* unused */),
    .dbg_data0_wdata(/* unused */),
    .dbg_data0_wen(/* unused */),
    .dbg_instr_data(/* unused */),
    .dbg_instr_data_vld(1'b0),
    .dbg_instr_data_rdy(/* unused */),
    .dbg_instr_caught_exception(/* unused */),
    .dbg_instr_caught_ebreak(/* unused */),

    .dbg_sbus_addr(32'b0),
    .dbg_sbus_write(1'b0),
    .dbg_sbus_size(2'b0),
    .dbg_sbus_vld(1'b0),
    .dbg_sbus_rdy(/* unused */),
    .dbg_sbus_err(/* unused */),
    .dbg_sbus_wdata(32'b0),
    .dbg_sbus_rdata(/* unused */),
    
    // Identification CSR values
    .mhartid_val(32'd0),
    .eco_version(4'd0),

    // Level-sensitive interrupt sources
    .irq(0),
    .soft_irq(1'b0),
    .timer_irq(1'b0)
  );

  ahb_sync_sram #(
    .DEPTH(1 << 24),
    .W_ADDR(W_ADDR),
    .W_DATA(W_DATA),
    .HAS_WRITE_PORT(0),
    .HAS_WRITE_BUFFER(0),
    .PRELOAD_FILE("${i_ram_preload}")
  ) i_ram (
    .clk(clock),
    .rst_n(!reset),

    .ahbls_hready_resp(i_hready),
    .ahbls_hready(i_hready),
    .ahbls_hresp(i_hresp),
    .ahbls_haddr(i_haddr),
    .ahbls_hwrite(i_hwrite),
    .ahbls_htrans(i_htrans),
    .ahbls_hsize(i_hsize),	
    .ahbls_hburst(i_hburst),
    .ahbls_hprot(i_hprot),
    .ahbls_hmastlock(i_hmastlock),
    .ahbls_hwdata(i_hwdata),
    .ahbls_hrdata(i_hrdata)
  );

  ahb_sync_sram #(
    .DEPTH(1 << 24),
    .W_ADDR(W_ADDR),
    .W_DATA(W_DATA),
    .HAS_WRITE_PORT(1),
    .PRELOAD_FILE("${d_ram_preload}")
  ) d_ram (
    .clk(clock),
    .rst_n(!reset),

    .ahbls_hready_resp(d_hready),
    .ahbls_hready(d_hready),
    .ahbls_hresp(d_hresp),
    .ahbls_haddr(d_haddr),
    .ahbls_hwrite(d_hwrite),
    .ahbls_htrans(d_htrans),
    .ahbls_hsize(d_hsize),	
    .ahbls_hburst(d_hburst),
    .ahbls_hprot(d_hprot),
    .ahbls_hmastlock(d_hmastlock),
    .ahbls_hwdata(d_hwdata),
    .ahbls_hrdata(d_hrdata)
  );

  assign keep_alive = i_haddr;

`ifndef VERILATOR
  (* keep, hierconn *)
  wire [31:0] core.core.fd_cir;
`endif

  always @(posedge clock)
    if (30'b1000000000000011100 == core.core.fd_cir[31:2])
      finished <= 1'b1;
endmodule
