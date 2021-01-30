
`default_nettype none

module otma_bringup (
    // Clocks
    input           CLK_125M,
    input           CLK_R_REFCLK5,

    // I2C
    inout           I2C_IDT_SCL,
    inout           I2C_IDT_SDA,

    inout           I2C_QSFP0_SCL,
    inout           I2C_QSFP0_SDA,

    inout           I2C_QSFP1_SCL,
    inout           I2C_QSFP1_SDA,

    // DDR3
    output [15:0]   memory_mem_a,
    output [ 2:0]   memory_mem_ba,
    output [ 0:0]   memory_mem_ck,
    output [ 0:0]   memory_mem_ck_n,
    output [ 0:0]   memory_mem_cke,
    output [ 0:0]   memory_mem_cs_n,
    output [ 3:0]   memory_mem_dm,
    output [ 0:0]   memory_mem_ras_n,
    output [ 0:0]   memory_mem_cas_n,
    output [ 0:0]   memory_mem_we_n,
    output          memory_mem_reset_n,
    inout  [31:0]   memory_mem_dq,
    inout  [ 3:0]   memory_mem_dqs,
    inout  [ 3:0]   memory_mem_dqs_n,
    output [ 0:0]   memory_mem_odt,
    input           oct_rzqin,

    // QSFP0
    // input  [3:0]    XCVR_QSFP0_RX,
    // output [3:0]    XCVR_QSFP0_TX,

    // QSFP1
    // input  [3:0]    XCVR_QSFP1_RX,
    // output [3:0]    XCVR_QSFP1_TX,

    // LED
    output [7:0]    LEDS
);


//==============================================================================
// clocks

wire clk_125_int;  // generated by Qsys for the 40G MGMT interface
wire clk_312; // user logic clock for 40G Eth

fortygig_eth_pll inst_fortygig_eth_pll (
    .refclk     ( CLK_R_REFCLK5     ),
    .rst        ( 1'b0              ),
    .outclk_0   ( clk_312           ),
    .locked     (                   )
);

//==============================================================================
// blinky

logic [27:0] cntr = 0;

always_ff @(posedge CLK_125M) begin: proc_cntr
    cntr <= cntr + 1'd1;
end

assign LEDS[7] = cntr[26];


//==============================================================================
// clock connections

wire [7:0] clk_cntr_meas = {6'd0, clk_312, clk_125_int};

//==============================================================================
// I2C

wire i2c_idt_osc_sda_oe;
wire i2c_idt_osc_scl_oe;

assign I2C_IDT_SDA = i2c_idt_osc_sda_oe ? 1'b0 : 1'bz;
assign I2C_IDT_SCL = i2c_idt_osc_scl_oe ? 1'b0 : 1'bz;

wire i2c_qsfp_0_sda_oe;
wire i2c_qsfp_0_scl_oe;

assign I2C_QSFP0_SDA = i2c_qsfp_0_sda_oe ? 1'b0 : 1'bz;
assign I2C_QSFP0_SCL = i2c_qsfp_0_scl_oe ? 1'b0 : 1'bz;

wire i2c_qsfp_1_sda_oe;
wire i2c_qsfp_1_scl_oe;

assign I2C_QSFP1_SDA = i2c_qsfp_1_sda_oe ? 1'b0 : 1'bz;
assign I2C_QSFP1_SCL = i2c_qsfp_1_scl_oe ? 1'b0 : 1'bz;

//==============================================================================
// DDR3

wire ddr3_mem_status_local_init_done;
wire ddr3_mem_status_local_cal_success;
wire ddr3_mem_status_local_cal_fail;

assign LEDS[6] = ddr3_mem_status_local_init_done;
assign LEDS[5] = ddr3_mem_status_local_cal_success;
assign LEDS[4] = ddr3_mem_status_local_cal_fail;

//==============================================================================
// qsys

system inst_system (
    .clk_clk                            ( CLK_125M                              ),
    .reset_reset_n                      ( 1'b1                                  ),
    .clk_cntr_meas                      ( clk_cntr_meas                         ),
    .clk_cntr_led_dbg                   ( LEDS[2]                               ),
    .clk_125_clk                        ( clk_125_int                           ),
    .led_dbg_export                     ( LEDS[1:0]                             ),
    .i2c_idt_osc_sda_in                 ( I2C_IDT_SDA                           ),
    .i2c_idt_osc_scl_in                 ( I2C_IDT_SCL                           ),
    .i2c_idt_osc_sda_oe                 ( i2c_idt_osc_sda_oe                    ),
    .i2c_idt_osc_scl_oe                 ( i2c_idt_osc_scl_oe                    ),
    .i2c_qsfp_0_sda_in                  ( I2C_QSFP0_SDA                         ),
    .i2c_qsfp_0_scl_in                  ( I2C_QSFP0_SCL                         ),
    .i2c_qsfp_0_sda_oe                  ( i2c_qsfp_0_sda_oe                     ),
    .i2c_qsfp_0_scl_oe                  ( i2c_qsfp_0_scl_oe                     ),
    .i2c_qsfp_1_sda_in                  ( I2C_QSFP1_SDA                         ),
    .i2c_qsfp_1_scl_in                  ( I2C_QSFP1_SCL                         ),
    .i2c_qsfp_1_sda_oe                  ( i2c_qsfp_1_sda_oe                     ),
    .i2c_qsfp_1_scl_oe                  ( i2c_qsfp_1_scl_oe                     ),
    .ddr3_mem_status_local_init_done    ( ddr3_mem_status_local_init_done       ),
    .ddr3_mem_status_local_cal_success  ( ddr3_mem_status_local_cal_success     ),
    .ddr3_mem_status_local_cal_fail     ( ddr3_mem_status_local_cal_fail        ),
    .memory_mem_a                       ( memory_mem_a                          ),
    .memory_mem_ba                      ( memory_mem_ba                         ),
    .memory_mem_ck                      ( memory_mem_ck                         ),
    .memory_mem_ck_n                    ( memory_mem_ck_n                       ),
    .memory_mem_cke                     ( memory_mem_cke                        ),
    .memory_mem_cs_n                    ( memory_mem_cs_n                       ),
    .memory_mem_dm                      ( memory_mem_dm                         ),
    .memory_mem_ras_n                   ( memory_mem_ras_n                      ),
    .memory_mem_cas_n                   ( memory_mem_cas_n                      ),
    .memory_mem_we_n                    ( memory_mem_we_n                       ),
    .memory_mem_reset_n                 ( memory_mem_reset_n                    ),
    .memory_mem_dq                      ( memory_mem_dq                         ),
    .memory_mem_dqs                     ( memory_mem_dqs                        ),
    .memory_mem_dqs_n                   ( memory_mem_dqs_n                      ),
    .memory_mem_odt                     ( memory_mem_odt                        ),
    .oct_rzqin                          ( oct_rzqin                             )
);

endmodule

`default_nettype wire
