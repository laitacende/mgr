using robustOpt
using JuMP
using Cbc


println("------ light robustness -----")
c = [30, 25]
A = [120 90; 1 0; 0 1]
b = [40*200*140, 4000, 6000]
Gamma = [2, 0, 0]
AU = [80*2 50*2; 0 0; 0 0]
rho = 0.2
while rho <= 0.8
    println("-- " * string(rho) * " --")
    model, dict, cost = lightRobustnessMax(c, b, A,  Gamma, AU, rho, false, false, true)
    global rho += 0.2
end

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