"""
    Ax = b
    d - costs of initial decision (without uncertainties)
    c - nominal costs of second stage
    cU - uncertainties on costs vector
    b - right sides vector
    A - constraint matrix
    Gamma - array of Gammas for rows
    K - maximum distance of modifications

    Continuous budget uncertainty
"""
function recoverableMin(d::Vector, c::Vector, cU::Vector, b::Vector, A::Union{Matrix, Vector},
    Gamma::Float64, K::Float64, printModel::Bool)

    n = size(d)[1]

    if (size(c)[1] != n)
        throw("Vector c has wrong dimension")
    end

    if (size(cU)[1] != n)
        throw("Vector cU has wrong dimension")
    end


    m = size(A)[1] # number of contraints
    if (size(A)[2] != n)
        throw("Matrix A has wrong dimensions")
    end


    if (size(b)[1] != m)
        throw("Vector b has wrong dimension")
    end



    model = Model(Cbc.Optimizer)
    set_attribute(model, "logLevel", 1)
    @variable(model, x[1:n] >= 0)
    @variable(model, zP[1:n] >= 0)
    @variable(model, zM[1:n] >= 0)
    @variable(model, q[1:n] >= 0)
    @variable(model, beta >= 0)

    for i in 1:m
        @constraint(model, sum(A[i, j] * x[j] for j in 1:n) == b[i])
        @constraint(model, sum(A[i, j] * (zP[j] - zM[j]) for j in 1:n) == 0)
    end

    @constraint(model, sum(zP[j] + zM[j] for j in 1:n) <= K)

    for j in 1:n
        @constraint(model, -zP[j] + zM[j] + beta + q[j] >= x[j])
        @constraint(model, zM[j] <= x[j])
    end

    @objective(model, Min, sum(d[i] * x[i] for i in 1:n) +
    sum(c[i] * (x[i] + zP[i] - zM[i]) for i in 1:n) + beta * Gamma + sum(cU[i] * q[i] for i in 1 :n))

    if (printModel)
        println(model)
    end
    optimize!(model)
    if termination_status(model) == OPTIMAL
       println("Solution is optimal")
    elseif termination_status(model) == TIME_LIMIT && has_values(model)
       println("Solution is suboptimal due to a time limit, but a primal solution is available")
    else
       error("The model was not solved correctly.")
    end
    println("  objective value = ", objective_value(model))
    if primal_status(model) == FEASIBLE_POINT
        for j in 1:n
            println("  x", j, " = ", value(x[j]), " y = ", value(zP[j]) - value(zM[j]) + value(x[j]))
        end
    end

end