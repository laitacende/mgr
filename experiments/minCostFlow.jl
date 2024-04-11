include("../robustLP/robustOpt.jl")

using .robustOpt

using Random, SparseArrays, Distributions

# generate graph

# vertices
n = rand(10:500)
# probability of creating and edge
p = 0.3
# incident matrix
A = spzeros(n, n)
for i in 1:n
    for j in 1:n
        # if edge from i to j exists
        if i != j && A[i, j] == 0 && rand() <= p
            A[i, j] = 1
            A[j, i] = -1
        end
    end
end

# generate vectors
c = Vector{Float64}(undef, n * n)
c .+= rand.((Uniform(0, 100)))
u = Vector{Float64}(undef, n * n)
u .+= rand.((Uniform(0, 50)))
b = Vector(Float64)(undef, n)
b .+= rand.((Uniform(-150, 150)))

cU = Vector{Float64}(undef, n * n)
cU .+= rand.((Uniform(0, 80)))

