module robustOpt

    using JuMP
    """
    n - number of decision variables
    l - lower bound on decision variables
    u - upper bound on decision variables
    b - right sides vector
    A - nominal values for constraint matrix
    Gamma - array of Gammas for rows
    J - J[i] is the list of indices in the ith row which are uncertain
    AU - uncertainties in order dictated by J
    """
    function minmax(l::Vector, u::Vector, b::Vector, A::Array{Array},
        Gamma::Vector, J::Vector, AU::Array{Array})
        n = size(x)

        if (size(l) != n)
            throw("Vector l has wrong dimension")
        end
        if (size(u) != n)
            throw("Vector u has wrong dimension")
        end

        m = size(A)[1] # number of contraints
        if (size(A)[2] != n)
            throw("Matrix A has wrong dimensions")
        end

        if (size(AU)[2] != n || size(AU)[1] != m)
            throw("Matrix AU has wrong dimensions")
        end

        if (size(J)[2] != m)
            throw("Vector J has wrong dimension")
        end

        if (size(Gamma)[2] != m)
            throw("Vector Gamma has wrong dimension")
        end


        model = Model(Cbc.Optimizer)
        set_attribute(model, "logLevel", 1)
        @variable(model, l[i] <= x[i = 1:n] <= u[i])
        @variable(model, z[1:m] >= 0)
        @variable(model, p[i in 1:m, j in J[i]] >= 0)
        @variable(model, y[1:n] >= 0)

        for i in 1:m
            @constraint(model, sum{a[i, j] * x[j], j=1:n} - z[i] * Gamma[i] - sum{p[i, j], j in J[i]} >= b[i])
        end

        for i in 1:m
            for j in J[i]
                @variable(model, z[i] + p[i, j] >= y[j] * AU)
            end
        end


        for j in 1:n
            @constraint(model, -y[j] <= x[j])
            @constraint(model, x[j] <= y[j])
        end

        @setObjective(model, Min, sum{c[i] * x[i], i=1:n})



    end


    function maxmin()

    end

end