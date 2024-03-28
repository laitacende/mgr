include("./robustLP/robustOpt.jl")

using .robustOpt

c = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
d = [1, 1,1, 1,1, 1,1, 1,1, 1,1, 1,1, 1]
cu = [100, 100, 50, 50, 150, 150, 20, 20, 200, 200, 30, 30, 70, 70]
b = [-5, -3, 5, 3, 0]
A = [1 -1 1 -1 0 0 0 0 0 0 1 -1 0 0;
    0 0 -1 1 1 -1 0 0 1 -1 0 0 0 0;
    0 0 0 0 -1 1 1 -1 0 0 0 0 1 -1;
    0 0 0 0 0 0 -1 1 0 0 -1 1 0 0;
    -1 1 0 0 0 0 0 0 -1 1 0 0 -1 1]
g = [50.0, 100.0, 200.0]
for t in g
    Gamma = t
    K = 3.0
    robustOpt.recoverableMin(d, c, cu, b, A, Gamma, K, false, true)
end

using JuMP
using Cbc
println("Nominal")
model = Model(Cbc.Optimizer)
@variable(model, 0 <= x[1:14])
for i in 1:5
    @constraint(model, sum(A[i, j] * x[j] for j in 1:14) == b[i])
end

@objective(model, Min, sum(x[i]*cu[i] for i in 1:14))
println(model)
optimize!(model)
println("  objective value = ", objective_value(model))
for i in 1:14
 println(i, " ", value(x[i]))
end