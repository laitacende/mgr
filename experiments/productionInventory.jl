include("../robustLP/robustOpt.jl")

using .robustOpt

using Random, SparseArrays, Distributions, LinearAlgebra, Base
import Base.stderr

per = 0.5
# redirect_stdout(open("/dev/null", "w"))

# periods
T = 7
# no of factories
n = 5

# jak to zrównoważyć?

c = spzeros(n * T)
c .+= rand.((Uniform(0, 100)))
# maximum nad minimum storage at warehause
VMax = rand(Uniform(1000, 100000))
VMin = rand(Uniform(0, 900))
# total production of factory accumulated over time
Cap = spzeros(n)
Cap .+= rand.((Uniform(500, 10000)))

# demands
d = spzeros(T)
d .+= rand.((Uniform(0, 100)))

# uncertainty
dU = spzeros(T)
for r in 1:length(c)
    dU[r] = rand(Uniform(0, d[i] * per))
end
A = spzeros(n + T + T + n * T, n * T)
for i in 1:n

end
# function adjustableMinB(c::Union{Vector, SparseVector, SparseMatrixCSC},
#     b::Union{Vector, SparseVector, SparseMatrixCSC},
#     A::Union{Matrix, Vector, SparseVector, SparseMatrixCSC},
#     D::Union{Matrix, Vector, SparseVector, SparseMatrixCSC},
#     Gamma::Float64, bU::Union{Vector, SparseVector},
#     printModel::Bool, printSolution::Bool)

redirect_stdout(stdout)
