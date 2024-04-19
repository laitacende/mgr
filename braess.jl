include("./robustLP/robustOpt.jl")
using LinearAlgebra
using .robustOpt
o = [1, 3, 5]
for d in o
c = [0, 0, 0, 0, 0, 1]
l = [0, 0, 0, 0, 0, 0]
u = [1, 1, 1, 1, 1, 100000000]
A = [15 65 10 65 15 -1; 1 -1 -1 0 0 0; -1 1 1 0 0 0; 0 0 1 1 -1 0; 0 0 -1 -1 1 0;
 0 1 0 0 1 0; 0 -1 0 0 -1 0;
    1 0 0 1 0 0; -1 0 0 -1 0 0]
b = [0, 0, 0, 0, 0, 1, -1, 1, -1]
Gamma = [d, 0, 0, 0, 0, 0, 0, 0, 0]
J = [[1, 2, 3, 4, 5], Int64[], Int64[], Int64[], Int64[], Int64[], Int64[], Int64[], Int64[]]
AU = [5 15 5 15 5]
model, dict, cost = robustOpt.minmax(c, l, u, b, A, Gamma, J, AU, true, true, false)
println("tutej ",  15*dict[:x][1] + 65*dict[:x][2] + 10*dict[:x][3] +
 65*dict[:x][4] + 15*dict[:x][5] - dict[:x][6] + d * dict[:z][1] + dict[:p][1,1] + dict[:p][1,2] +
 dict[:p][1,3] + dict[:p][1,4] + dict[:p][1,5])
for i in 1:5
   print(round.(dict[:x][i]; sigdigits=2), " & ")
end
print(round.(sum(A[1, j] * dict[:x][j] for j in 1:5); sigdigits=2), "\n")
end
# # nominal
# using JuMP
# using Cbc
# println("Nominal")
# model = Model(Cbc.Optimizer)
# @variable(model, 0 <= x[1:5] <= 1)
# @constraint(model, x[1] == x[3] + x[2])
# @constraint(model, x[4] + x[3] == x[5])
# @constraint(model, x[4] + x[1] == 1)
# @constraint(model, x[2] + x[5] == 1)
# @objective(model, Min, 20*x[1]+ 80*x[2] + 20*x[5] + 80*x[4] + 15*x[3])
# optimize!(model)
# println("  objective value = ", objective_value(model))
# println("x1 = ", value(x[1]))
# println("x2 = ", value(x[2]))
# println("x3 = ", value(x[3]))
# println("x4 = ", value(x[4]))
# println("x5 = ", value(x[5]))
# c = [0, 0, 0, 0, 0, 1]
# A = [15 65 10 65 15 -1; 1 -1 -1 0 0 0; -1 1 1 0 0 0; 0 0 1 1 -1 0; 0 0 -1 -1 1 0;
#  0 1 0 0 1 0; 0 -1 0 0 -1 0;
#     1 0 0 1 0 0; -1 0 0 -1 0 0; 1 0 0 0 0 0; 0 1 0 0 0 0;0 0 1 0 0 0;
#     0 0 0 1 0 0; 0 0 0 0 1 0]
# b = [0, 0, 0, 0, 0, 1, -1, 1, -1, 1, 1, 1, 1, 1]
# AU = [5 15 5 15 5 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0;
# 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0; 0 0 0 0 0 0;
#  0 0 0 0 0 0;  0 0 0 0 0 0]
# for d in o
#     rho = 0.2
#     while rho <= 0.8
#         println("--------------------------------", rho, " ", d)
#         Gamma = [d, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
#         model, dict, cost = robustOpt.lightRobustnessMin(c, b, A,  Gamma, AU, rho,false, false, false)
#         for i in 1:5
#             print(round.(dict[:x][i]; sigdigits=2), " & ")
#         end
#         print(round.(sum(A[1, j] * dict[:x][j] for j in 1:5); sigdigits=2), "\n")
#         rho += 0.2
#     end
# end