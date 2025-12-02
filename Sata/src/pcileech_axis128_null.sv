module pcileech_axis128_null(
    IfAXIS128.source source
);
    assign source.tvalid = 0;
    assign source.tdata = 0;
    assign source.tkeepdw = 0;
    assign source.tlast = 0;
    assign source.tuser = 0;
    assign source.has_data = 0;
endmodule
