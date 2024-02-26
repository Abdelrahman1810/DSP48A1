module dsp48a1 #(
    parameter A0REG = 0, A1REG = 1, B0REG = 0, B1REG = 1, CREG = 1, DREG = 1,
    parameter MREG = 1, PREG = 1, CARRYINREG = 1, CARRYOUTREG = 1, OPMODEREG = 1,
    parameter CARRYINSEL = "OPMODE5", B_INPUT = "DIRECT", RSTTYPE = "SYNC"
) (
    input CLK, [7:0]OPMODE,
    input CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP,
    input RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP,
    input CARRYIN, [17:0]A, B, D, BCIN, [47:0]C,
    input [47:0]PCIN,

    output CARRYOUT, CARRYOUTF, [35:0]M, [47:0]P,
    output [17:0]BCOUT, [47:0]PCOUT
);
     
    // defines whether the input to the B port is routed from the (B) input
    // or the cascaded input (BCIN) or will be zero
    wire [17:0]BIN;
    assign BIN = (B_INPUT=="DIRECT")? B:(B_INPUT=="CASCADE")? BCIN:0;
    
    // define if inputs will be registered or not
    wire [17:0]A0reg, B0reg, Dreg, A1reg, B1reg;
    wire [47:0]Creg;
    wire [7:0]OPMODEreg;
    register #(.FF(OPMODEREG),.N(8),.RSTTYPE(RSTTYPE))opmode_REGISTER(RSTOPMODE, CLK, CEOPMODE, OPMODE, OPMODEreg);
    
    register #(.FF(DREG),.N(18),.RSTTYPE(RSTTYPE))D_REGISTER(RSTD, CLK, CED, D, Dreg);
    register #(.FF(B0REG),.N(18),.RSTTYPE(RSTTYPE))B0_REGISTER(RSTB, CLK, CEB, BIN, B0reg);

    register #(.FF(A0REG),.N(18),.RSTTYPE(RSTTYPE))A0_REGISTER(RSTA, CLK, CEA, A, A0reg);
    register #(.FF(A1REG),.N(18),.RSTTYPE(RSTTYPE))A1_REGISTER(RSTA, CLK, CEA, A, A1reg);

    register #(.FF(CREG),.N(48),.RSTTYPE(RSTTYPE))C_REGISTER(RSTC, CLK, CEC, C, Creg);

    // Pre-Adder/Subtracter Block inputs and outputs
    wire [17:0]preAddSub, B1Muxin;
    assign preAddSub = (OPMODEreg[6])? (Dreg-B0reg):(Dreg+B0reg);
    assign B1Muxin = (OPMODEreg[4])? preAddSub:B0reg;
    register #(.FF(B1REG),.N(18),.RSTTYPE(RSTTYPE))B1_REGISTER(RSTB, CLK, CEB, B1Muxin, B1reg);
    assign BCOUT = B1reg;

    // Concatenated D, A and B to goto X_mux
    wire [47:0]DABconcat;
    assign DABconcat = {Dreg[11:0], A1reg[17:0], B1reg[17:0]};

    // multibler Block inputs and output (M)
    wire [35:0]mult_result, Mreg;
    assign mult_result = A1reg * B1reg;
    register #(.FF(MREG),.N(36),.RSTTYPE(RSTTYPE))M_REGISTER(RSTM, CLK, CEM, mult_result, Mreg);

    // take (M) output from buffer
    genvar i;
    generate
        for ( i=0; i<36; i=i+1)
            buf(M[i], Mreg[i]);
    endgenerate

    // X and Z muxs and there result
    wire [47:0]X_MUX, Z_MUX;
    assign X_MUX = (OPMODEreg[1:0]==0)? 0:(OPMODEreg[1:0]==1)? M:(OPMODEreg[1:0]==2)? P:DABconcat;
    assign Z_MUX = (OPMODEreg[3:2]==0)? 0:(OPMODEreg[3:2]==1)? PCIN:(OPMODEreg[3:2]==2)? P:Creg;
    assign PCOUT = P;
    
    wire [47:0] postAddSub;
    wire Carryout, CIN, CINreg;
    // define CIN of the Post-Adder/Subtracter will be (OPMODEreg[5])
    // or (CARRYIN) or will be zero
    generate
        if (CARRYINSEL=="OPMODE5") begin
            assign CIN = OPMODEreg[5];
        end else if (CARRYINSEL=="CARRYIN") begin
            assign CIN = CARRYIN;
        end else begin
            assign CIN = 0;
        end
    endgenerate

    // Post-Adder/Subtracter Block inputs (X_MUX_RESULT, Z_MUX_RESULT, CIN)
    // and outputs (CARRYOUT, CARRYOUTF, P)
    register #(.FF(CARRYINREG),.N(1),.RSTTYPE(RSTTYPE))CIN_REGISTER(RSTCARRYIN, CLK, CECARRYIN, CIN, CINreg);
    assign {Carryout, postAddSub} = (OPMODEreg[7])? Z_MUX-(X_MUX+CINreg):Z_MUX+(X_MUX+CINreg);
    register #(.FF(CARRYOUTREG),.N(1),.RSTTYPE(RSTTYPE))COUT_REGISTER(0, CLK, 1, Carryout, CARRYOUT);
    assign CARRYOUTF = CARRYOUT;
    register #(.FF(PREG),.N(48),.RSTTYPE(RSTTYPE))P_REGISTER(RSTP, CLK, CEP, postAddSub, P);

endmodule