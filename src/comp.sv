`timescale 1ns / 1ps

module comp(
    input logic [127:0] a,
    input logic [127:0] b,
    output logic gt,
    output logic eq,
    output logic lt
);

    logic [127:0] eq_prefix, gt_prefix, lt_prefix;

    // начальные условия для самого старшего бита
    assign eq_prefix[127] = a[127] ~^ b[127];
    assign gt_prefix[127] = a[127] & ~b[127];
    assign lt_prefix[127] = ~a[127] & b[127];

    // последовательное формирование префиксов от старших битов к младшим
    genvar i;
    generate
        for (i = 126; i >= 0; i--) begin : comp_chain
            assign eq_prefix[i] = eq_prefix[i+1] & (a[i] ~^ b[i]);
            assign gt_prefix[i] = gt_prefix[i+1] | (eq_prefix[i+1] & a[i] & ~b[i]);
            assign lt_prefix[i] = lt_prefix[i+1] | (eq_prefix[i+1] & ~a[i] & b[i]);
        end
    endgenerate

    // результаты после обработки всех битов
    assign eq = eq_prefix[0];
    assign gt = gt_prefix[0];
    assign lt = lt_prefix[0];

endmodule
/*
128-bit comparator testbench (7 tests)

a = 00000000000000000000000000000000, b = 00000000000000000000000000000000
  gt = 0, eq = 1, lt = 0
  PASS

a = ffffffffffffffffffffffffffffffff, b = ffffffffffffffffffffffffffffffff
  gt = 0, eq = 1, lt = 0
  PASS

a = 00000000000000000000000000000001, b = 00000000000000000000000000000000
  gt = 1, eq = 0, lt = 0
  PASS

a = 00000000000000000000000000000000, b = 00000000000000000000000000000001
  gt = 0, eq = 0, lt = 1
  PASS

a = 80000000000000000000000000000000, b = 7fffffffffffffffffffffffffffffff
  gt = 1, eq = 0, lt = 0
  PASS

a = 7fffffffffffffffffffffffffffffff, b = 80000000000000000000000000000000
  gt = 0, eq = 0, lt = 1
  PASS

a = ffffffffffffffffffffffffffffffff, b = 00000000000000000000000000000000
  gt = 1, eq = 0, lt = 0
  PASS

All tests passed*/
