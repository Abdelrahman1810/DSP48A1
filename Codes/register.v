module register #(
    parameter FF = 0, N = 18,
    parameter RSTTYPE = "SYNC"
) (
    input reset, CLK, enable, [N-1:0]d,
    output [N-1:0]out
);
    reg [N-1:0] q;
    assign out = (FF)? q:d;
    generate
        if (RSTTYPE == "SYNC") begin
            always @(posedge CLK) begin
                if (enable) begin
                    if (reset) q <= 0;
                    else q <= d;
                end
            end
        end
        else if (RSTTYPE == "ASYNC") begin
            always @(posedge CLK or posedge reset) begin
                if (reset) q <= 0;
                else if (enable) q <= d;
            end
        end 
    endgenerate
endmodule