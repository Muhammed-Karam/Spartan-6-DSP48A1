module DSP48A1_tb();

    // Data Input Ports
    reg [17:0] A, B, D;
    reg [47:0] C;
    reg CARRYIN;
    // Data Output Ports
    wire [35:0] M;
    wire [47:0] P;
    wire CARRYOUT, CARRYOUTF;
    // Control Ports
    reg CLK;
    reg [7:0] OPMODE;
    // Clock Enable Ports
    reg CEA, CEB, CEC, CED, CEM, CEP;
    reg CECARRYIN, CEOPMODE;
    // Reset Ports (Active High)
    reg RSTA, RSTB, RSTC, RSTD, RSTM, RSTP;
    reg RSTCARRYIN, RSTOPMODE;
    // Cascade Ports
    reg [17:0] BCIN;
    wire [17:0] BCOUT;
    reg [47:0] PCIN;
    wire [47:0] PCOUT;
    // previous P and CARRYOUT for comparison
    reg [47:0] prev_P;
    reg prev_CARRYOUT;

    // Clock generation
    initial begin
        CLK = 0;
        forever 
            #1 CLK = ~CLK;
    end

    // DUT instantiation with default parameters
    DSP48A1 #(
        .A0REG(0), .A1REG(1), .B0REG(0), .B1REG(1),
        .CREG(1), .DREG(1), .MREG(1), .PREG(1),
        .CARRYINREG(1), .CARRYOUTREG(1), .OPMODEREG(1),
        .CARRYINSEL("OPMODE5"), .B_INPUT("DIRECT"), .RSTTYPE("SYNC")
    ) dut (
            A, B, C, D, CARRYIN,
            M, P, CARRYOUT, CARRYOUTF, 
            CLK, OPMODE,
            CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP, 
            RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP,
            BCIN, BCOUT, PCIN, PCOUT
    );

    // Test stimulus
    initial begin
        // Initialize inputs
        A = 0; B = 0; C = 0; D = 0; CARRYIN = 0;
        OPMODE = 0; BCIN = 0; PCIN = 0; prev_P = 0; prev_CARRYOUT = 0;
        //========================================================================
        // Verify Reset Operation
        $display("Verify Reset Operation");
        RSTA = 1; RSTB = 1; RSTC = 1; RSTD = 1; RSTM = 1; RSTP = 1;
        RSTCARRYIN = 1; RSTOPMODE = 1;

        A = $random; B = $random; C = $random; D = $random; 
        CARRYIN = $random; OPMODE = $random; BCIN = $random; PCIN = $random;
        CEA = $random; CEB = $random; CEC = $random; CED = $random; 
        CEM = $random; CEP = $random; CECARRYIN = $random; CEOPMODE = $random;

        @(negedge CLK);

        if (M == 0 && P == 0 && CARRYOUT == 0 && CARRYOUTF == 0 &&
            BCOUT == 0 && PCOUT == 0) begin
            $display("Reset test - All outputs are zero");
        end 
        else begin
            $display("Error: Reset test - Outputs not zero:\n",
                     "M=%h, P=%h, CARRYOUT=%b, CARRYOUTF=%b, BCOUT=%h, PCOUT=%h", 
                      M, P, CARRYOUT, CARRYOUTF, BCOUT, PCOUT);
            $stop;
        end

        RSTA = 0; RSTB = 0; RSTC = 0; RSTD = 0; RSTM = 0; RSTP = 0;
        RSTCARRYIN = 0; RSTOPMODE = 0;
        CEA = 1; CEB = 1; CEC = 1; CED = 1; CEM = 1; CEP = 1; 
        CECARRYIN = 1; CEOPMODE = 1;
        //========================================================================
        // Verify DSP Path 1
        $display("Verify DSP Path 1");
        OPMODE = 8'b11011101;
        A = 20; B = 10; C = 350; D = 25;
        BCIN = $random; PCIN = $random; CARRYIN = $random;

        repeat(4) @(negedge CLK);

        if (BCOUT == 18'hf && M == 36'h12c && P == 48'h32 && PCOUT == 48'h32 && 
            CARRYOUT == 0 && CARRYOUTF == 0) begin
            $display("DSP Path 1 test passed");
        end
        else begin
            $display("Error: DSP Path 1 test failed");
            $stop;
        end
        //========================================================================
        // Verify DSP Path 2
        $display("Verify DSP Path 2");
        OPMODE = 8'b00010000;
        A = 20; B = 10; C = 350; D = 25;
        BCIN = $random; PCIN = $random; CARRYIN = $random;

        repeat(3) @(negedge CLK);

        if (BCOUT == 18'h23 && M == 36'h2bc && P == 48'h0 && PCOUT == 48'h0 && 
            CARRYOUT == 0 && CARRYOUTF == 0) begin
            $display("DSP Path 2 test passed");
        end 
        else begin
            $display("Error: DSP Path 2 test failed");
            $stop;
        end
        //========================================================================
        // Verify DSP Path 3
        $display("Verify DSP Path 3");
        prev_P = P; prev_CARRYOUT = CARRYOUT;

        OPMODE = 8'b00001010;
        A = 20; B = 10; C = 350; D = 25;
        BCIN = $random; PCIN = $random; CARRYIN = $random;

        repeat(3) @(negedge CLK);

        if (BCOUT == 18'ha && M == 36'hc8 && P == prev_P &&
            CARRYOUT == prev_CARRYOUT) begin
            $display("DSP Path 3 test passed");
        end 
        else begin
            $display("Error: DSP Path 3 test failed");
            $stop;
        end
        //========================================================================
        // Verify DSP Path 4
        $display("Verify DSP Path 4");
        OPMODE = 8'b10100111;
        A = 5; B = 6; C = 350; D = 25; PCIN = 3000;
        BCIN = $random; CARRYIN = $random;

        repeat(3) @(negedge CLK);

        if (BCOUT == 18'h6 && M == 36'h1e && P == 48'hfe6fffec0bb1 &&
            PCOUT == 48'hfe6fffec0bb1 && 
            CARRYOUT == 1 && CARRYOUTF == 1) begin
            $display("DSP Path 4 test passed");
        end 
        else begin
            $display("Error: DSP Path 4 test failed");
            $stop;
        end

        $stop;
        end
endmodule