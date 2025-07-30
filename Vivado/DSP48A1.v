module DSP48A1 (
                A, B, C, D, CARRYIN,
                M, P, CARRYOUT, CARRYOUTF, 
                CLK, OPMODE,
                CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP, 
                RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP,
                BCIN, BCOUT, PCIN, PCOUT
        );

    parameter A0REG = 0, A1REG = 1;
    parameter B0REG = 0, B1REG = 1;
    parameter CREG = 1, DREG = 1, MREG = 1, PREG = 1;
    parameter CARRYINREG = 1, CARRYOUTREG = 1, OPMODEREG = 1;
    parameter CARRYINSEL = "OPMODE5", B_INPUT = "DIRECT", RSTTYPE = "SYNC";

    // Data Input Ports
    input [17:0] A, B, D;
    input [47:0] C;
    input CARRYIN;
    // Data Output Ports
    output [35:0] M;
    output [47:0] P;
    output CARRYOUT, CARRYOUTF;
    // Control Ports
    input CLK;
    input [7:0] OPMODE;
    // Clock Enable Ports
    input CEA, CEB, CEC, CED, CEM, CEP;
    input CECARRYIN, CEOPMODE;
    // Reset Ports (Active High)
    input RSTA, RSTB, RSTC, RSTD, RSTM, RSTP;
    input RSTCARRYIN, RSTOPMODE;
    // Cascade Ports
    input [17:0] BCIN;
    output [17:0] BCOUT;
    input [47:0] PCIN;
    output [47:0] PCOUT;
    // Internal Wires
    wire [17:0] a0_out, a1_out, a0_reg_out, a1_reg_out;
    wire [17:0] b0_out, b1_out, b_mux_out, b0_reg_out, b1_reg_out;
    wire [47:0] c_out, c_reg_out;
    wire [17:0] d_out, d_reg_out;
    wire [7:0] opmode_out, opmode_reg_out;
    wire carryin_mux_out, carryin_reg_out, cyi_out;
    wire carryout_wire, carryout_reg_out;
    wire [17:0] pre_add_sub_out;
    wire [17:0] opmode4_mux_out;
    wire [35:0] mult_out, m_out, m_reg_out;
    wire [47:0] concatenated_buses;
    wire [47:0] x_mux_out, z_mux_out;
    wire [47:0] post_add_sub_out;
    wire [47:0] p_reg_out;

    // ==============Input Pipeline Registers==============
    // -----------------------A Path-----------------------
    // A0 Register and Mux
    DFF #(.WIDTH(18), .RSTTYPE(RSTTYPE)) a0_reg (
          .clk(CLK), .rst(RSTA), .CE(CEA), .D(A), .Q(a0_reg_out)
    );
    MUX #(.WIDTH(18), .INPUTS(2)) a0_mux (
        .in0(A),           // Direct input
        .in1(a0_reg_out),  // Registered input
        .in2(18'b0), .in3(18'b0),  // Unused
        .sel(A0REG[0]), .out(a0_out)
    );
    // A1 Register and Mux
    DFF #(.WIDTH(18), .RSTTYPE(RSTTYPE)) a1_reg (
        .clk(CLK), .rst(RSTA), .CE(CEA), .D(a0_out), .Q(a1_reg_out)
    );
    MUX #(.WIDTH(18), .INPUTS(2)) a1_mux (
        .in0(a0_out),      // Direct input
        .in1(a1_reg_out),  // Registered input
        .in2(18'b0), .in3(18'b0),  // Unused
        .sel(A1REG[0]), .out(a1_out)
    );

    // -----------------------B Path-----------------------
    // B input port mux
    MUX #(.WIDTH(18), .INPUTS(2)) b_input_mux (
        .in0(B),     // DIRECT
        .in1(BCIN),  // CASCADE
        .in2(18'b0), .in3(18'b0),  // Unused
        .sel(B_INPUT == "CASCADE"), .out(b_mux_out)
    );
    // B0 Register and Mux
    DFF #(.WIDTH(18), .RSTTYPE(RSTTYPE)) b0_reg (
        .clk(CLK), .rst(RSTB), .CE(CEB), .D(b_mux_out), .Q(b0_reg_out)
    );
    MUX #(.WIDTH(18), .INPUTS(2)) b0_mux (
        .in0(b_mux_out),   // Direct input
        .in1(b0_reg_out),  // Registered input
        .in2(18'b0), .in3(18'b0),  // Unused
        .sel(B0REG[0]), .out(b0_out)
    );
    // B1 Register and Mux
    DFF #(.WIDTH(18), .RSTTYPE(RSTTYPE)) b1_reg (
        .clk(CLK), .rst(RSTB), .CE(CEB), .D(opmode4_mux_out), .Q(b1_reg_out)
    );
    MUX #(.WIDTH(18), .INPUTS(2)) b1_mux (
        .in0(opmode4_mux_out),    // Direct input
        .in1(b1_reg_out),        // Registered input
        .in2(18'b0), .in3(18'b0),       // Unused
        .sel(B1REG[0]), .out(b1_out)
    );
    assign BCOUT = b1_out;

    // -----------------------C Path-----------------------
    // C Register and Mux
    DFF #(.WIDTH(48), .RSTTYPE(RSTTYPE)) c_reg (
        .clk(CLK), .rst(RSTC), .CE(CEC), .D(C), .Q(c_reg_out)
    );
    MUX #(.WIDTH(48), .INPUTS(2)) c_mux (
        .in0(C),          // Direct input
        .in1(c_reg_out),  // Registered input
        .in2(48'b0), .in3(48'b0), // Unused
        .sel(CREG[0]), .out(c_out)
    );

    // -----------------------D Path-----------------------
    // D Register and Mux
    DFF #(.WIDTH(18), .RSTTYPE(RSTTYPE)) d_reg (
        .clk(CLK), .rst(RSTD), .CE(CED), .D(D), .Q(d_reg_out)
    );
    MUX #(.WIDTH(18), .INPUTS(2)) d_mux (
        .in0(D),          // Direct input
        .in1(d_reg_out),  // Registered input
        .in2(18'b0), .in3(18'b0),  // Unused
        .sel(DREG[0]), .out(d_out)
    );

    // ====================================================
    // -----------------------OPMODE-----------------------
    // OPMODE Register and Mux
    DFF #(.WIDTH(8), .RSTTYPE(RSTTYPE)) opmode_reg (
        .clk(CLK), .rst(RSTOPMODE), .CE(CEOPMODE), .D(OPMODE), .Q(opmode_reg_out)
    );
    MUX #(.WIDTH(8), .INPUTS(2)) opmode_mux (
        .in0(OPMODE),         // Direct input
        .in1(opmode_reg_out), // Registered input
        .in2(8'b0), .in3(8'b0),  // Unused
        .sel(OPMODEREG[0]), .out(opmode_out)
    );
    
    // -----------------Pre-Adder/Subtracter-----------------
    assign pre_add_sub_out = opmode_out[6] ? (d_out - b0_out) : (d_out + b0_out);

    // --------------------OPMODE[4] Mux---------------------
    assign opmode4_mux_out = opmode_out[4] ? pre_add_sub_out : b0_out;

    // -----Multiplier ((A * B) or (A * pre_add_sub_out))----
    assign mult_out = a1_out * b1_out;

    // M Register and Mux
    DFF #(.WIDTH(36), .RSTTYPE(RSTTYPE)) m_reg (
        .clk(CLK), .rst(RSTM), .CE(CEM), .D(mult_out), .Q(m_reg_out)
    );
    MUX #(.WIDTH(36), .INPUTS(2)) m_mux (
        .in0(mult_out),   // Direct input
        .in1(m_reg_out),  // Registered input
        .in2(36'b0), .in3(36'b0),  // Unused
        .sel(MREG[0]), .out(m_out)
    );
    assign M = m_out;

    // -----Concatenated Buses D[11:0], A[17:0], B[17:0]------
    assign concatenated_buses = {d_out[11:0], a1_out, b1_out};

    // --------------------X Mux---------------------
    MUX #(.WIDTH(48), .INPUTS(4)) x_mux (
        .in0(48'b0),
        .in1({{12{1'b0}}, m_out}), // Extended with zeros
        .in2(P), // P feedback
        .in3(concatenated_buses),
        .sel(opmode_out[1:0]), .out(x_mux_out)
    );

    // --------------------Z Mux---------------------
    MUX #(.WIDTH(48), .INPUTS(4)) z_mux (
        .in0(48'b0),
        .in1(PCIN),
        .in2(P), // P feedback
        .in3(c_out),
        .sel(opmode_out[3:2]), .out(z_mux_out)
    );

    // -----------------Carry Input------------------
    // Carry input mux (CARRYIN or OPMODE5)
    MUX #(.WIDTH(1), .INPUTS(2)) carryin_mux (
        .in0(CARRYIN),        
        .in1(opmode_out[5]),  
        .in2(1'b0), .in3(1'b0),  // Unused
        .sel(CARRYINSEL == "OPMODE5"), .out(carryin_mux_out)
    );

    // Carry Input Register and Mux (CYI)
    DFF #(.WIDTH(1), .RSTTYPE(RSTTYPE)) carryin_reg (
        .clk(CLK), .rst(RSTCARRYIN), .CE(CECARRYIN), .D(carryin_mux_out), .Q(carryin_reg_out)
    );
    MUX #(.WIDTH(1), .INPUTS(2)) carryin_reg_mux (
        .in0(carryin_mux_out),   // Direct input
        .in1(carryin_reg_out), // Registered input
        .in2(1'b0), .in3(1'b0),  // Unused
        .sel(CARRYINREG[0]), .out(cyi_out)
    );

    // ------------Post-Adder/Subtracter-------------
    assign {carryout_wire, post_add_sub_out} = opmode_out[7] ? 
            (z_mux_out - (x_mux_out + cyi_out)) : 
            (z_mux_out + x_mux_out + cyi_out);

    // --------------P Output Register---------------
    // P Register and Mux
    DFF #(.WIDTH(48), .RSTTYPE(RSTTYPE)) p_reg (
        .clk(CLK), .rst(RSTP), .CE(CEP), .D(post_add_sub_out), .Q(p_reg_out)
    );
    MUX #(.WIDTH(48), .INPUTS(2)) p_mux (
        .in0(post_add_sub_out), // Direct input
        .in1(p_reg_out),        // Registered input
        .in2(48'b0), .in3(48'b0),  // Unused
        .sel(PREG[0]), .out(P)
    );
    assign PCOUT = P;

    // ------------Carry Output Register-------------
    // Carry Output Register and Mux (CYO)
    DFF #(.WIDTH(1), .RSTTYPE(RSTTYPE)) carryout_reg (
        .clk(CLK), .rst(RSTCARRYIN), .CE(CECARRYIN),
        .D(carryout_wire), .Q(carryout_reg_out)
    );
    MUX #(.WIDTH(1), .INPUTS(2)) carryout_mux (
        .in0(carryout_wire), // Direct input
        .in1(carryout_reg_out),  // Registered input
        .in2(1'b0), .in3(1'b0),  // Unused
        .sel(CARRYOUTREG[0]), .out(CARRYOUT)
    );
    assign CARRYOUTF = CARRYOUT;

endmodule