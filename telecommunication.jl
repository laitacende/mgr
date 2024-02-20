include("./robustLP/robustOpt.jl")

using .robustOpt

d = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
c = [1, 1,1, 1,1, 1,1, 1,1, 1,1, 1,1, 1]
cu = [100, 100, 50, 50, 150, 150, 20, 20, 200, 200, 30, 30, 70, 70]
b = [-5, -3, 5, 3, 0]
A = [1 -1 1 -1 0 0 0 0 0 0 1 -1 0 0;
    0 0 -1 1 1 -1 0 0 1 -1 0 0 0 0;
    0 0 0 0 -1 1 1 -1 0 0 0 0 1 -1;
    0 0 0 0 0 0 -1 1 0 0 -1 1 0 0;
    -1 1 0 0 0 0 0 0 -1 1 0 0 -1 1]
g = [1.0, 3.0, 5.0, 7.0]
for t in g
    Gamma = t
    K = 4.0
    robustOpt.recoverableMin(d, c, cu, b, A, Gamma, K, false)
end

# using JuMP
# using Cbc
# println("Nominal")
# model = Model(Cbc.Optimizer)
# @variable(model, 0 <= x[1:14])
# for i in 1:5
#     @constraint(model, sum(A[i, j] * x[j] for j in 1:14) == b[i])
# end
# # i = 1
# # while i < 14
# #     @constraint(model, x[i] == x[i + 1])
# #     global i += 2
# # end
#
# @objective(model, Min, sum(x[i] for i in 1:14) / 2)
# println(model)
# optimize!(model)
# println("  objective value = ", objective_value(model))
# for i in 1:14
#  println(i, " ", value(x[i]))
# end