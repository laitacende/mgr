using robustOpt
using JuMP
using Cbc

println("------ one-stage -----")
c = [30, 25]
l = [0, 0]
u = [4000, 6000]
A = [200 140]
b = [40*200*140]
Gamma = [0]
J = [[1, 2]]
AU = [80 50]
m = onestageMax(c, l, u, b, A, Gamma, J, AU, true, false, true)

println("------ worst -----")
model = Model(Cbc.Optimizer)
@variable(model, 0 <= x1 <= 4000)
@variable(model, 0 <= x2 <= 6000)
@constraint(model, 280*x1+190*x2 <= 40*200*140)
@objective(model, Max, 30x1+ 25x2)
optimize!(model)
println("  objective value = ", objective_value(model))
 println("x1 = ", value(x1))
 println("x2 = ", value(x2))
