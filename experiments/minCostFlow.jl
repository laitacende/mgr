include("../robustLP/robustOpt.jl")

using .robustOpt

using Random, SparseArrays, Distributions, LinearAlgebra


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
#             println("adding edge ", i, " ", j)
            A[i, n * (i - 1) + j] = 1
            A[j, n * (i - 1) + j] = -1
        end
    end
end

# generate vectors
c = Vector{Float64}(undef, n * n)
c .+= rand.((Uniform(0, 100)))
u = Vector{Float64}(undef, n * n)
u .+= rand.((Uniform(0, 150)))
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

cU = Vector{Float64}(undef, n * n)
cU .+= rand.((Uniform(0, 80)))


# minmax
c1 = zeros(n*n + 1)
c1[n * n + 1] = 1
cC = copy(c)
A1 = [append!(cC, -1)'; A zeros(n, 1); -A zeros(n, 1)]
# all of the costs can be uncertain
J1 = [Int64[] for i in 1:(2*n + 1)]
J1[1] = [i for i in 1:(n*n)]
Gamma1 = [0 for i in 1:(2*n + 1)]
Gamma1[1] = 4
cU1 = reshape(cU, 1, length(cU))
model1, x1, y1, p1, z1, obj1 = robustOpt.minmax(c1, zeros(n*n + 1), [u; 100000000000000000],
[0; b; -b], A1, Gamma1, J1, cU1, true, false, false)
println(obj1)

# light robustness
identity = [Matrix(1I, n*n, n*n) zeros(n*n, 1)]
rho = 0.5
Gamma2 = [0 for i in 1:(2*n + 1 + n*n)]
Gamma2[1] = 4
cU2 = [cU1 0; zeros(2*n + n*n, n*n + 1)]
model2, n2, x2, zOpt2, y2, p2, z2, obj2 =  robustOpt.lightRobustnessMin(c1, [0; b; -b; u], [A1; identity], Gamma2,
 cU2, rho, false, false, false)
println(obj2, " ", zOpt2)

# recoverable - continous budget!
Gamma3 = 100.0
K = 50.0
model3, n3, x3, q3, zP3, zM3, beta3, obj3 = robustOpt.recoverableMin(zeros(2*n*n), [c; zeros(n*n)],
 [cU; zeros(n * n)], [b; u], [A zeros(n, n*n); Matrix(1I, n*n, n*n) Matrix(1I, n*n, n*n)], Gamma3, K, false, false)
println(obj3)