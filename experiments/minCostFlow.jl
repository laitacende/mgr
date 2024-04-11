include("../robustLP/robustOpt.jl")

using .robustOpt

using Random, SparseArrays, Distributions

# generate graph

# vertices
n = rand(10:500)
n = 4
# probability of creating and edge
p = 1
# incident matrix
A = zeros(n, n*n)
for i in 1:n
    for j in 1:n
        # if edge from i to j exists
        if i != j && A[i, n * (i - 1) + j] == 0 && rand() <= p
            println("adding edge ", i, " ", j)
            A[i, n * (i - 1) + j] = 1
            A[j, n * (i - 1) + j] = -1
        end
    end
end

# generate vectors
c = Vector{Float64}(undef, n * n)
c .+= rand.((Uniform(0, 100)))
u = Vector{Float64}(undef, n * n)
u .+= rand.((Uniform(0, 50)))
b = zeros(n)
# must sum to 0
# generate supply
for j in 1:100
    supply = rand(Uniform(0, 10))
    # add suply to random node
    b[rand(1:n)] += supply
    # add demand to random node
    b[rand(1:n)] -= supply
end
display(b)

cU = Vector{Float64}(undef, n * n)
cU .+= rand.((Uniform(0, 80)))


# minmax
c1 = zeros(n*n + 1)
c1[n * n + 1] = 1
A1 = [append!(c, -1)'; A zeros(n, 1); -A zeros(n, 1)]
# all of the costs can be uncertain
J1 = [Int64[] for i in 1:(2*n + 1)]
J1[1] = [i for i in 1:(n*n)]
Gamma1 = [0 for i in 1:(2*n + 1)]
Gamma1[1] = 4
cU1 = reshape(cU, 1, length(cU))
model1, x1, y1, p1, z1, obj1 = robustOpt.minmax(c1, zeros(n*n + 1), [u; 100000000000000000],
[0; b; -b], A1, Gamma1, J1, cU1, true, true, false)
println(obj1)

# light robustness
# robustOpt. lightRobustnessMin(c::Vector, b::Vector, A::Union{Matrix, Vector}, Gamma::Vector,  AU::Union{Matrix, Vector},
#     rho::Float64, val::Bool, printModel::Bool, printSolution::Bool)




