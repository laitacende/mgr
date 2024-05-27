using LinearAlgebra
using robustOpt
using JuMP
using Cbc

println("------ one-stage -----")
o = [1, 3, 5]
for d in o
    println("-- " * string(d) * " --")
    c = [0, 0, 0, 0, 0, 1]
    l = [0, 0, 0, 0, 0, 0]
    u = [1, 1, 1, 1, 1, 100000000]
    A = [10 50 5 50 10  -1; 1 -1 -1 0 0 0; -1 1 1 0 0 0; 0 0 1 1 -1 0; 0 0 -1 -1 1 0;
    0 1 0 0 1 0; 0 -1 0 0 -1 0;
    1 0 0 1 0 0; -1 0 0 -1 0 0]
    b = [0, 0, 0, 0, 0, 1, -1, 1, -1]
    Gamma = [d, 0, 0, 0, 0, 0, 0, 0, 0]
    J = [[1, 2, 3, 4, 5], Int64[], Int64[], Int64[], Int64[], Int64[], Int64[], Int64[], Int64[]]
    AU = [10 30 10 30 10 0]
    model, dict, cost = onestageMin(c, l, u, b, A, Gamma, J, AU, true, false, true)
end

println("------nominal -----")
model = Model(Cbc.Optimizer)
@variable(model, 0 <= x[1:5] <= 1)
@constraint(model, x[1] == x[3] + x[2])
@constraint(model, x[4] + x[3] == x[5])
@constraint(model, x[4] + x[1] == 1)
@constraint(model, x[2] + x[5] == 1)
@objective(model, Min, 10*x[1]+ 50*x[2] + 10*x[5] + 50*x[4] + 5*x[3])
optimize!(model)
println("  objective value = ", objective_value(model))
println("x1 = ", value(x[1]))
println("x2 = ", value(x[2]))
println("x3 = ", value(x[3]))
println("x4 = ", value(x[4]))
println("x5 = ", value(x[5]))
