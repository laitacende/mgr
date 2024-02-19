include("./robustLP/robustOpt.jl")

using .robustOpt

# c = [30, 25]
# l = [0, 0]
# u = [4000, 6000]
# A = [200 140]
# b = [40*200*140]
# Gamma = [2]
# J = [[1, 2]]
# AU = [80 50]
# robustOpt.maxmin(c, l, u, b, A, Gamma, J, AU, true, true)
# using JuMP
# using Cbc
# println("Nominal")
# model = Model(Cbc.Optimizer)
# @variable(model, 0 <= x1 <= 4000)
# @variable(model, 0 <= x2 <= 6000)
# @constraint(model, 200*x1+140*x2 <= 40*200*140)
# @objective(model, Max, 30x1+ 25x2)
# optimize!(model)
# println("  objective value = ", objective_value(model))
#  println("x1 = ", value(x1))
#  println("x2 = ", value(x2))
# c = [30, 25]
# A = [200 140; 1 0; 0 1]
# b = [40*200*140, 4000, 6000]
# Gamma = [1, 0, 0]
# AU = [80 50; 0 0; 0 0]
# rho = 0.2
# while rho <= 0.8
#     robustOpt.lightRobustnessMax(c, b, A,  Gamma, AU, rho,false, false)
#     global rho += 0.2
# end


# using JuMP
# using Cbc
# println("Nominal")
# model = Model(Cbc.Optimizer)
# @variable(model, 0 <= x1 <= 3500)
# @variable(model, 0 <= x2 <= 8500)
# @constraint(model, x1+x2 == 10000)
# @objective(model, Min, 380x1+ 420x2)
# optimize!(model)
# println("  objective value = ", objective_value(model))
#  println("x1 = ", value(x1))
#  println("x2 = ", value(x2))
g = [150.0, 200.0, 300.0]
for t in g
d = [10, 0, 0, 0]
c = [380, 420, 0, 0]
cu = [200, 100, 0, 0]
b = [10000, 3500, 8500]
A = [1 1 0 0; 1 0 1 0; 0 1 0 1]
Gamma = t
K = 250.0
robustOpt.recoverableMin(d, c, cu, b, A, Gamma, K, false)
end