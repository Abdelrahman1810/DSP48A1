module testbench ();
    parameter A0REG = 0, A1REG = 1, B0REG = 0, B1REG = 1, CREG = 1, DREG = 1;
    parameter MREG = 1, PREG = 1, CARRYINREG = 1, CARRYOUTREG = 1, OPMODEREG = 1;
    parameter CARRYINSEL = "OPMODE5", B_INPUT = "DIRECT", RSTTYPE = "SYNC";

    reg [7:0]OPMODE;
    reg CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP, CLK, CARRYIN;
    reg RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;
    reg [17:0]A, B, D, BCIN;
    reg [47:0]PCIN, C;

    wire CARRYOUT, CARRYOUTF;
    wire [35:0]M;
    wire [17:0]BCOUT;
    wire [47:0]PCOUT, P;

    reg [47:0]P_ch_TEST, DABconcat_TEST, P_previous;
    reg [17:0]BCOUT_ch_TEST;
    reg [35:0]M_ch_TEST;
    reg CARRYOUT_ch_TEST;

    dsp48a1 #(
        .A0REG(A0REG), .A1REG(A1REG), .B0REG(B0REG), .B1REG(B1REG),
        .CREG(CREG), .DREG(DREG), .MREG(MREG), .PREG(PREG), 
        .CARRYINREG(CARRYINREG), .CARRYOUTREG(CARRYOUTREG), .OPMODEREG(OPMODEREG),
        .CARRYINSEL(CARRYINSEL), .B_INPUT(B_INPUT), .RSTTYPE(RSTTYPE)
    )dsp(
        .CLK(CLK), .OPMODE(OPMODE), .CEA(CEA), .CEB(CEB), .CEC(CEC), .RSTC(RSTC),
        .CECARRYIN(CECARRYIN), .CED(CED), .CEM(CEM), .CEOPMODE(CEOPMODE), .CEP(CEP),
        .RSTA(RSTA), .RSTB(RSTB), .RSTCARRYIN(RSTCARRYIN), .RSTD(RSTD), .RSTM(RSTM),
        .RSTOPMODE(RSTOPMODE), .RSTP(RSTP), .CARRYIN(CARRYIN), .A(A), .B(B), .D(D),
        .BCIN(BCIN), .C(C), .PCIN(PCIN), .CARRYOUT(CARRYOUT), .CARRYOUTF(CARRYOUTF),
        .M(M), .P(P), .BCOUT(BCOUT), .PCOUT(PCOUT)
    );

    initial begin
        CLK = 0;
        forever #1 CLK=~CLK;
    end

    integer i;
    initial begin
        {CEA,CEB,CEC,CECARRYIN,CED,CEM,CEOPMODE,CEP} = 8'hFF;
        {RSTA,RSTB,RSTC,RSTCARRYIN,RSTD,RSTM,RSTOPMODE,RSTP} = 0;
        //{OPMODE[7], OPMODE[6], OPMODE[5], OPMODE[4], OPMODE[3:2], OPMODE[1:0]} 

// Test case(1):
    // M & P & PCOUT & CARRYOUT & CARRYOUTF (FOUR(4) CLK CYCLE)
    // BCOUT (TOW(2) CLK CYCLE)
        OPMODE = {1'b0, 1'b0, 1'b1, 1'b1, 2'b11, 2'b01};
        // post-Add/Sub = Z_MUX+(X_MUX+CIN), preAdd/Sub = D+B, CIN=1, BCOUT = Pre-Add/Sub, Z_MUX = C, X_MUX = M
        repeat(5000) begin
            A = $random;
            B = $random;
            D = $random;
            C = $random;
            BCIN = $random;
            PCIN = $random;

            repeat(4) @(negedge CLK);
            BCOUT_ch_TEST = D + B;
            M_ch_TEST = A * BCOUT_ch_TEST;
            {CARRYOUT_ch_TEST, P_ch_TEST} = M_ch_TEST + C + OPMODE[5];
            if (BCOUT!=BCOUT_ch_TEST) begin
                $display("Error BCOUT");
                $stop;
            end 
            if (M!=M_ch_TEST) begin
                $display("Error M");
                $stop;
            end
            if (P_ch_TEST!=P || CARRYOUT_ch_TEST!=CARRYOUT) begin
                $display("Error P and CARRYOUT");
                $stop;
            end
        end

        OPMODE = {1'b1, 1'b1, 1'b0, 1'b1, 2'b01, 2'b01};
        // post-Add/Sub = Z_MUX-(X_MUX+CIN), preAdd/Sub = D-B, CIN=0, BCOUT = Pre-Add/Sub, Z_MUX = PCIN, X_MUX = M
        repeat(5000) begin
            A = $random;
            B = $random;
            D = $random;
            C = $random;
            BCIN = $random;
            PCIN = $random;

            repeat(4) @(negedge CLK);
            BCOUT_ch_TEST = D - B;
            M_ch_TEST = A * BCOUT_ch_TEST;
            {CARRYOUT_ch_TEST, P_ch_TEST} = PCIN - (M_ch_TEST + OPMODE[5]);
            if (BCOUT!=BCOUT_ch_TEST) begin
                $display("Error BCOUT");
                $stop;
            end 
            if (M!=M_ch_TEST) begin
                $display("Error M");
                $stop;
            end
            if (P_ch_TEST!=P || CARRYOUT_ch_TEST !=CARRYOUT) begin
                $display("Error P and CARRYOUT");
                $stop;
            end
        end

// Test case(2):
    // M & P & PCOUT & CARRYOUT & CARRYOUTF (THREE(3) CLK CYCLE)
    // COUT (after tow CLK CYCLE)
        OPMODE = {1'b1, 1'b1, 1'b1, 1'b1, 2'b01, 2'b11};
        // post-Add/Sub = Z_MUX-(X_MUX+CIN), preAdd/Sub = D-B, CIN=1, BCOUT = Pre-Add/Sub, Z_MUX = PCIN, X_MUX = DBAconcat
        repeat (5000) begin
            A = $random;
            B = $random;
            D = $random;
            C = $random;
            BCIN = $random;
            PCIN = $random;
            repeat(3) @(negedge CLK);

            BCOUT_ch_TEST = D - B;
            M_ch_TEST = A * BCOUT_ch_TEST;
            DABconcat_TEST = {D[11:0], A, BCOUT_ch_TEST};
            {CARRYOUT_ch_TEST,P_ch_TEST} = PCIN - (DABconcat_TEST + OPMODE[5]);
            if (BCOUT!=BCOUT_ch_TEST) begin
                $display("Error BCOUT");
                $stop;
            end 
            if (M!=M_ch_TEST) begin
                $display("Error M");
                $stop;
            end
            if (P_ch_TEST!=P || CARRYOUT_ch_TEST!=CARRYOUT) begin
                $display("Error P and CARRYOUT");
                $stop;
            end
        end

        OPMODE = {1'b0, 1'b0, 1'b1, 1'b1, 2'b00, 2'b11};
        // post-Add/Sub = Z_MUX+(X_MUX+CIN), preAdd/Sub = D+B, CIN=1, BCOUT = Pre-Add/Sub, Z_MUX = 0, X_MUX = DBAconcat
        repeat (5000) begin
            A = $random;
            B = $random;
            D = $random;
            C = $random;
            BCIN = $random;
            PCIN = $random;
            repeat(3) @(negedge CLK);

            BCOUT_ch_TEST = D + B;
            M_ch_TEST = A * BCOUT_ch_TEST;
            DABconcat_TEST = {D[11:0], A, BCOUT_ch_TEST};
            {CARRYOUT_ch_TEST,P_ch_TEST} = 0 + (DABconcat_TEST + OPMODE[5]);
            if (BCOUT!=BCOUT_ch_TEST) begin
                $display("Error BCOUT");
                $stop;
            end 
            if (M!=M_ch_TEST) begin
                $display("Error M");
                $stop;
            end
            if (P_ch_TEST!=P || CARRYOUT_ch_TEST!=CARRYOUT) begin
                $display("Error P and CARRYOUT");
                $stop;
            end
        end

// Test case(3):
    // BCOUT & P & PCOUT & CARRYOUT & CARRYOUTF (ONE(1) CLK CYCLE)
    // M (TOW(2) CLK CYCLE)
        OPMODE = {1'b0, 1'b1, 1'b1, 1'b0, 2'b10, 2'b00};
        // post-Add/Sub = Z_MUX+(X_MUX+CIN), preAdd/Sub = D-B, CIN=1, BCOUT = B, Z_MUX = P, X_MUX = 0
        @(negedge CLK); P_previous = P;
        repeat (5000) begin
            A = $random;
            B = $random;
            D = $random;
            C = $random;
            BCIN = $random;
            PCIN = $random;

            @(negedge CLK);
            {CARRYOUT_ch_TEST,P_ch_TEST} = P_previous + OPMODE[5];
            if ((P_ch_TEST!=P || CARRYOUT_ch_TEST!=CARRYOUT)&&i!=0) begin
                $display("Error P & CARRYOUT");
                $stop;
            end
            BCOUT_ch_TEST = B;
            if (BCOUT_ch_TEST!=BCOUT&&i!=0) begin
                $display("Error BCOUT");
                $stop;
            end
            @(negedge CLK);
            M_ch_TEST = A * BCOUT_ch_TEST;
            if (M_ch_TEST!=M&&i!=0) begin
                $display("Error M");
                $stop;
            end
            P_previous = P;
        end

        OPMODE = {1'b1, 1'b1, 1'b0, 1'b0, 2'b01, 2'b10};
        // post-Add/Sub = Z_MUX-(X_MUX+CIN), preAdd/Sub = D-B, CIN=0, BCOUT = B, Z_MUX = PCIN, X_MUX = P
        @(negedge CLK); P_previous = P;
        repeat (5000) begin
            A = $random;
            B = $random;
            D = $random;
            C = $random;
            BCIN = $random;
            PCIN = $random;

            @(negedge CLK);
            {CARRYOUT_ch_TEST,P_ch_TEST} = PCIN - (P_previous + OPMODE[5]);
            if ((P_ch_TEST!=P || CARRYOUT_ch_TEST!=CARRYOUT)&&i!=0) begin
                $display("Error P & CARRYOUT");
                $stop;
            end
            BCOUT_ch_TEST = B;
            if (BCOUT_ch_TEST!=BCOUT&&i!=0) begin
                $display("Error BCOUT");
                $stop;
            end
            @(negedge CLK);
            M_ch_TEST = A * BCOUT_ch_TEST;
            if (M_ch_TEST!=M&&i!=0) begin
                $display("Error M");
                $stop;
            end
            P_previous = P;
        end

        $stop;
    end
endmodule