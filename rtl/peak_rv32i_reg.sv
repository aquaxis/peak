`default_nettype none

module peak_rv32im_reg (
    input  wire        RST_N,
    input  wire        CLK,
    input  wire        TASKNUM,
    input  wire [ 4:0] WADDR,
    input  wire        WE,
    input  wire [31:0] WDATA,
    input  wire [ 4:0] RS1ADDR,
    input  wire [ 4:0] RS2ADDR,
    output wire [31:0] RS1,
    output wire [31:0] RS2,
    input  wire        AR_EN,
    input  wire        AR_WR,
    input  wire [15:0] AR_AD,
    input  wire [31:0] AR_DI,
    output wire [31:0] AR_DO
);

  localparam AR_REGADDR = 8'h10;

  wire        w_ena;
  wire [ 5:0] w_addr;
  wire [31:0] w_data;
  wire [5:0] r1_addr, r2_addr;
  reg [31:0] r1_data, r2_data;
  reg r1_zero, r2_zero;

  reg [31:0] mem_rs1[0:63];
  reg [31:0] mem_rs2[0:63];

  assign w_ena   = (AR_EN & AR_WR) | (!AR_EN & WE);
  assign w_addr  = (AR_EN & (AR_AD[15:8] == AR_REGADDR)) ? {1'd0, AR_AD[4:0]} : {TASKNUM, WADDR};
  assign w_data  = (AR_EN & (AR_AD[15:8] == AR_REGADDR)) ? AR_DI : WDATA;
  assign r1_addr = (AR_EN & (AR_AD[15:8] == AR_REGADDR)) ? {1'd0, AR_AD[4:0]} : {TASKNUM, RS1ADDR};
  assign r2_addr = {TASKNUM, RS2ADDR};

  always @(posedge CLK) begin
    r1_zero <= (r1_addr == 0);
    r2_zero <= (RS2ADDR == 0);
  end

  always @(posedge CLK) begin
    if (w_ena) mem_rs1[w_addr] <= w_data;
  end
  always @(posedge CLK) begin
    r1_data <= mem_rs1[r1_addr];
  end
  assign RS1   = (r1_zero) ? 0 : r1_data;
  assign AR_DO = RS1;

  always @(posedge CLK) begin
    if (w_ena) mem_rs2[w_addr] <= w_data;
  end
  always @(posedge CLK) begin
    r2_data <= mem_rs2[r2_addr];
  end
  assign RS2 = (r2_zero) ? 0 : r2_data;

endmodule
`default_nettype wire
