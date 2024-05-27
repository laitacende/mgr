using robustOpt
using JuMP
using Cbc

println("------ recoverable with first norm -----")
g = [150.0, 200.0, 300.0]
c = [380, 420, 0, 0]
cu = [200, 100, 0, 0]
b = [10000, 3500, 8500]
A = [1 1 0 0; 1 0 1 0; 0 1 0 1]
for t in g
    println("-- " * string(t) * " --")
    Gamma = t
    K = 250.0
    recoverableMin(d, c, cu, b, A, Gamma, K, false, true)
end

println("------ nominal -----")
model = Model(Cbc.Optimizer)
@variable(model, 0 <= x1 <= 3500)
@variable(model, 0 <= x2 <= 8500)
@constraint(model, x1+x2 == 10000)
@objective(model, Min, 580x1+ 520x2)
optimize!(model)
println("  objective value = ", objective_value(model))
 println("x1 = ", value(x1))
 println("x2 = ", value(x2))
