"""
    Ax <= b
    l - lower bound on decision variables
    u - upper bound on decision variables
    b - right sides vector
    c - costs vector
    A - nominal values for constraint matrix
    Gamma - array of Gammas for rows
    J - J[i] is the list of indices in the ith row which are uncertain
    AU - uncertainties in order dictated by J
    bounds - if there are upper and lower bounds on decision variables
"""
function minmax(c::Vector, l::Vector, u::Vector, b::Vector, A::Union{Matrix, Vector},
    Gamma::Vector, J::Vector{Vector{Int64}}, AU::Union{Matrix, Vector}, bounds::Bool, printModel::Bool)
    n = size(l)[1]

    if (size(u)[1] != n)
        throw("Vector u has wrong dimension")
    end

    if (size(c)[1] != n)
        throw("Vector c has wrong dimension")
    end

    m = size(A)[1] # number of contraints
    if (length(size(A)) > 1 && size(A)[2] != n)
        throw("Matrix A has wrong dimensions")
    end
    if ((length(size(AU)) > 1 && size(AU)[2] > n) || size(AU)[1] > m)
        throw("Matrix AU has wrong dimensions")
    end

    if (size(b)[1] != m)
        throw("Vector b has wrong dimension")
    end

    if (size(J)[1] > m)
        throw("Vector J has wrong dimension")
    end

    if (size(Gamma)[1] > m)
        throw("Vector Gamma has wrong dimension")
    end

    for j in 1:size(J)[1]
        if (Gamma[j] > length(J[j]))
            throw("Gamma " + string(j), " has wrong value")
        end
    end


    model = Model(Cbc.Optimizer)
    set_attribute(model, "logLevel", 1)
    if (bounds)
        @variable(model, l[i] <= x[i=1:n] <= u[i])
    else
        @variable(model, x[i=1:n] >= 0)
    end
    @variable(model, z[1:m] >= 0)
    @variable(model, p[i in 1:m, j in J[i]] >= 0)
    @variable(model, y[1:n] >= 0)

    for i in 1:m
        @constraint(model, sum(A[i, j] * x[j] for j in 1:n) + z[i] * Gamma[i] + sum(p[i, j] for j in J[i]) <= b[i])
    end

    for i in 1:m
        k = 1
        for j in J[i]
            @constraint(model, z[i] + p[i, j] >= y[j] * AU[i, k])
            k += 1
        end
    end


    for j in 1:n
        @constraint(model, -y[j] <= x[j])
        @constraint(model, x[j] <= y[j])
    end

    @objective(model, Min, sum(c[i] * x[i] for i in 1:n))
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
            println("  x", j, " = ", value(x[j]))
        end
    end

#      println(value(x[1]), " & ", value(x[2]), " & ", value(x[3]), " & ", value(x[4]), " & ", value(x[5]),
#      " & ", objective_value(model), "\\\\")
end

 """
    Ax <= b
    l - lower bound on decision variables
    u - upper bound on decision variables
    b - right sides vector
    c - costs vector
    A - nominal values for constraint matrix
    Gamma - array of Gammas for rows
    J - J[i] is the list of indices in the ith row which are uncertain
    AU - uncertainties in order dictated by J
    bounds - if there are upper and lower bounds on decision variables
"""
function maxmin(c::Vector, l::Vector, u::Vector, b::Vector, A::Union{Matrix, Vector},
    Gamma::Vector, J::Vector{Vector{Int64}}, AU::Union{Matrix, Vector}, bounds::Bool, printModel::Bool)
     n = size(l)[1]

    if (size(u)[1] != n)
        throw("Vector u has wrong dimension")
    end

    if (size(c)[1] != n)
        throw("Vector c has wrong dimension")
    end

    m = size(A)[1] # number of contraints
    if (length(size(A)) > 1 && size(A)[2] != n)
        throw("Matrix A has wrong dimensions")
    end
    if ((length(size(AU)) > 1 && size(AU)[2] > n) || size(AU)[1] > m)
        throw("Matrix AU has wrong dimensions")
    end

    if (size(b)[1] != m)
        throw("Vector b has wrong dimension")
    end

    if (size(J)[1] > m)
        throw("Vector J has wrong dimension")
    end

    if (size(Gamma)[1] > m)
        throw("Vector Gamma has wrong dimension")
    end

    for j in 1:size(J)[1]
        if (Gamma[j] > length(J[j]))
            throw("Gamma " + string(j), " has wrong value")
        end
    end


    model = Model(Cbc.Optimizer)
    set_attribute(model, "logLevel", 1)
    if (bounds)
        @variable(model, l[i] <= x[i=1:n] <= u[i])
    else
        @variable(model, x[i=1:n] >= 0)
    end

    @variable(model, z[1:m] >= 0)
    @variable(model, p[i in 1:m, j in J[i]] >= 0)
    @variable(model, y[1:n] >= 0)

    for i in 1:m
        @constraint(model, sum(A[i, j] * x[j] for j in 1:n) + z[i] * Gamma[i] + sum(p[i, j] for j in J[i]) <= b[i])
    end

    for i in 1:m
        k = 1
        for j in J[i]
            @constraint(model, z[i] + p[i, j] >= y[j] * AU[i, k])
            k += 1
        end
    end


    for j in 1:n
        @constraint(model, -y[j] <= x[j])
        @constraint(model, x[j] <= y[j])
    end

    @objective(model, Max, sum(c[i] * x[i] for i in 1:n))
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
            println("  x", j, " = ", value(x[j]))
        end
    end
end