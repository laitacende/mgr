include("./robustLP/robustOpt.jl")

using .robustOpt

# # Ax <= b
# c = [300, 300, 300, 0]
# l = [0, 0, 0, 1]
# u = [350, 350, 350, 1]
# b = [0, 0, 0, 2000]
# A = [-1 0 0 150; 0 -1 0 250; 0 0 -1 290; 1 1 1 0]
# Gamma = [0, 0, 1, 0]
# J = [[4], [4], [4], Int64[]]
# AU = [70 ;100 ;50; 0]
#
# model, d , opt = robustOpt.minmax(c, l, u, b, A, Gamma, J, AU, true, true, false)
# println(d)
# println(opt, "min max")
# przejscie z funkcja celu do ograniczeń i dodanie nowej zmiennej "podstawowej"
# c = [0, 1]
c = [0, 1]
b = [0, 2000, -150, -200, -250, -290, 350, 350, 350, 350]
# b = [0, -1, -1]
bU = [0, 0, 0, -50, -100, -50, 0, 0, 0, 0]
A = [300 -1; 1 0; -1 0; 0 0; 0 0; 0 0; 1 0; 0 0; 0 0; 0 0]
# A = [300 -1; -1 0; 0 0]
D = [300 300 300; 1 1 1; 0 0 0; -1 0 0; 0 -1 0; 0 0 -1;0 0 0; 1 0 0; 0 1 0; 0 0 1]
# D = [300; 0; -1]
Gammas = [0.5, 1.0, 2.0, 3.0]
# adjustableMinB(c::Union{Vector, SparseVector, SparseMatrixCSC},
#     b::Union{Vector, SparseVector, SparseMatrixCSC},
#     A::Union{Matrix, Vector, SparseVector, SparseMatrixCSC},
#     D::Union{Matrix, Vector, SparseVector, SparseMatrixCSC},
#     Gamma::Float64, bU::Union{Vector, SparseVector},
#     printModel::Bool, printSolution::Bool)
for Gamma in Gammas
    m, dict = robustOpt.adjustableMinB(c, b, A, D, Gamma, bU, false, false)
    println(Gamma, " ", dict)
end
m, dict, opt = robustOpt.nominal([300, 300, 300, 300], [2000, -150, -250, -350, -340, 350, 350, 350, 350],
     [1 1 1 1; -1 0 0 0; 0 -1 0 0; 0 0 -1 0; 0 0 0 -1; 1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1], false, false)
println(opt, "obj worst")

m, dict, opt = robustOpt.nominal([300, 300, 300, 300], [2000, -150, -200, -250, -290, 350, 350, 350, 350],
     [1 1 1 1; -1 0 0 0; 0 -1 0 0; 0 0 -1 0; 0 0 0 -1; 1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1], false, false)
println(opt, "obj wnom")