include("./robustLP/robustOpt.jl")

using .robustOpt

# Ax <= b
# c = [0, 0, 0, 0, 0, 1]
# l = [0, 0, 0, 0, 0, 0]
# u = [0, 0, 0, 0, 0, 0]
# b = [0, -1, 1 , 1, 1, 1, 1, 1]
# A = [50 10 10 50 1 -1; -1 -1 -1 -1 -1 0; 1 0 0 0 0 0;  0 1 0 0 0 0;  0 0 1 0 0 0;
#  0 0 0 1 0 0;  0 0 0 0 1 0; 1 1 1 1 1 0]
# Gamma = [1, 0, 0, 0, 0, 0, 0, 0]
# J = [[1, 2, 3, 4, 5], Int64[], Int64[], Int64[], Int64[], Int64[], Int64[], Int64[]]
# AU = [25 5 5 25 0 0 ; 0 0 0 0 0 0 ; 0 0 0 0 0 0 ; 0 0 0 0 0 0 ;
# 0 0 0 0 0 0 ; 0 0 0 0 0 0 ; 0 0 0 0 0 0 ; 0 0 0 0 0 0 ]
# J = [[1], [], [], [], [], [], []]
# AU = [0 0 0 0 0 0]


# robustOpt.minmax(c, l, u, b, A, Gamma, J, AU, false, true)
# przejscie z funkcja celu do ograniczeń i dodanie nowej zmiennej "podstawowej"
# c = [0, 1]
c = [0, 1]
b = [0, 10000, -150, -250, -290, 200, 350, 350]
# b = [0, -1, -1]
bU = [0, 0, -10, -50, -50, 0, 0, 0]
A = [300 -1; 1 0; -1 0; 0 0; 0 0; 1 0; 0 0; 0 0]
# A = [300 -1; -1 0; 0 0]
D = [300 300; 1 1; 0 0; -1 0; 0 -1;0  0; 1 0; 0 1]
# D = [300; 0; -1]
Gamma = 2.0
# adjustableMinB(c::Union{Vector, SparseVector, SparseMatrixCSC},
#     b::Union{Vector, SparseVector, SparseMatrixCSC},
#     A::Union{Matrix, Vector, SparseVector, SparseMatrixCSC},
#     D::Union{Matrix, Vector, SparseVector, SparseMatrixCSC},
#     Gamma::Float64, bU::Union{Vector, SparseVector},
#     printModel::Bool, printSolution::Bool)
robustOpt.adjustableMinB(c, b, A, D, Gamma, bU, true, false)

m, dict, opt = robustOpt.nominal([300, 300, 300], [1000, -160, -300, -340, 200, 350, 350],
     [1 1 1; -1 0 0; 0 -1 0; 0 0 -1; 1 0 0; 0 1 0; 0 0 1], true, false)
println(dict)