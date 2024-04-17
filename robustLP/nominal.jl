function nominal(c::Vector, b::Vector, A::Union{Matrix, Vector}, printModel::Bool, printSolution::Bool)
    n = size(c)[1]

    m = size(A)[1] # number of contraints
    if (size(A)[2] != n)
        throw("Matrix A has wrong dimensions")
    end

    if (size(b)[1] != m)
        throw("Vector b has wrong dimension")
    end

    modelNom = Model(Cbc.Optimizer)
    set_attribute(model, "logLevel", 0)
    @variable(modelNom, x[i=1:n] >= 0)

    for i in 1:m
        @constraint(model, sum(A[i, j] * x[j] for j in 1:n)  <= b[i])
    end

    @objective(model, Min, sum(c[i] * x[i] for i in 1:n))

    if (printModel)
        println(model)
    end
    if printSolution
        printNominal(model, n, x)
    end

    optimize!(model)
    zOpt = objective_value(model)

    return model, x, zOpt
end

function printNominal(model, n, x)
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
            println("  x", j, " = ", value(x[j]))
        end
    end
end