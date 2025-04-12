function y = Cal_Tax_All(x)
    Tax_coefficient = [
        0.04091 -0.05554 0.0649  0.0002 6.667;
        0.02543 -0.06047 0.05638 0.0005 3.333;
        0        0       0       0      0;
        0.05326 -0.0355  0.0338  0.002  2;
    ];
    %% 计算标幺值 100MVA / 1.0 p.u.
    gen_1 = x(20) / 100;
    gen_2 = x(21) / 100;
    gen_4 = x(23) / 100;

    gen_1_Tax = 20 * (Tax_coefficient(1, 1) + Tax_coefficient(1, 2) * gen_1 + Tax_coefficient(1, 3) * gen_1^2 ...
        + Tax_coefficient(1, 4) * exp(Tax_coefficient(1, 5) * gen_1));
    gen_2_Tax = 20 * (Tax_coefficient(2, 1) + Tax_coefficient(2, 2) * gen_2 + Tax_coefficient(2, 3) * gen_2^2 ...
        + Tax_coefficient(2, 4) * exp(Tax_coefficient(2, 5) * gen_2));
    gen_4_Tax = 20 * (Tax_coefficient(4, 1) + Tax_coefficient(4, 2) * gen_4 + Tax_coefficient(4, 3) * gen_4^2 ...
        + Tax_coefficient(4, 4) * exp(Tax_coefficient(4, 5) * gen_4));
    y = gen_1_Tax + gen_2_Tax + gen_4_Tax;
end
