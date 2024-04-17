include("../robustLP/robustOpt.jl")

using .robustOpt

using Random, SparseArrays, Distributions, LinearAlgebra

# losuję nominalne i kilka serii dla losowych scenariuszy
# statystyki: koszt (min max) rozwiązania, czas, nominalny koszt, worst case koszt przy czym +- odchylenie z pbb 1/2
# czas i naruszone ograniczenia można jako średnią, resztę raczej
# na konkretne przypadki, żeby dało się to jakoś porównać -- tutaj też można jedne nominalne, ale różne scenar.
# można też pojedynczo przebadac krytera i pokazywac co sie dzieje przy zwiekszaniu gammy
# 10000 symulacji w bs (różnych scenriuszy), goerig 50
# 1%, 5%, 10%, 25%, 50%, 60%, 70%, 80%, and 90% of s dla light robustness
# to czy ograniczenie spelnione mamy dla problemu nominalnego, bez zbednych odatkow i bierzemy rozwiazanie robust


# ustalone koszty nominalne, losujemy odchylenia i zapisujemy wyniki każdego z nich
# również nominalne, ale dla worst casów
# (potrzebne dla dlaszych porównań) wyniki czyli: funkcja celu; w tym
# wypadku nie mówimy o naruszeiu ograniczeń; wartość optymalna

# file format: funkcja_celu, naruszone_ograniczenia (w procentach), czas

function checkConstraints(A, B, b, dict, n, k, mode)
#     res = A
    bad = 0
    all = size(A)[1]
    for i in 1:(size(A)[1])
        # min max
        if mode == 0 && !(sum(A[i, j] * float(dict[:x][j]) for j in 1:n) <= b[i])
            bad += 1
        end
#         # light robustness
#         elseif mode == 1 && !(res[i] <= b[i])
#             bad += 1
#         # recoverable
#         elseif mode == 2 && !(res[i] == b[i])
#             bad += 1
#         elseif mode == 3
#             res1 = B * d'
#             if !(res[i] + res1[i] <= b[i])
#                 bad += 1
#             end
#         end
    end
    return bad / all
end

fileName = "test1"
percent = false # czy niepewności to procenty nominalnych
steps = 1 # liczba różnych losowań niepewności

fMinMax = open("./" * fileName * "_minmax.txt", "a")
fLight = open("./" * fileName * "_light.txt", "a")
fRecov = open("./" * fileName * "_recov.txt", "a")
fAdj = open("./" * fileName * "_adj.txt", "a")
fNom = open("./" * fileName * "_nom.txt", "a")

# generate graph

# vertices
# n = rand(10:500)
n = 4
# probability of creating and edge
p = 1
# incident matrix
A = zeros(n, n * n)
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

# generate vectors
c = Vector{Float64}(undef, n * n)
c .+= rand.((Uniform(0, 100)))

for i in 1:steps
    cU = Vector{Float64}(undef, n * n)
    if (percent)
        cU .+= 0.7 * c
    else
        cU .+= rand.((Uniform(0, 80)))
    end

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
    model1, dict1, obj1 = robustOpt.minmax(c1, zeros(n*n + 1), [u; 100000000000000000],
    [0; b; -b], A1, Gamma1, J1, cU1, true, false, false)

    time = @elapsed robustOpt.minmax(c1, zeros(n*n + 1), [u; 100000000000000000],
    [0; b; -b], A1, Gamma1, J1, cU1, true, false, false)
    constraints = checkConstraints(A, [], b, dict1, n * n, 0, 0)
    write(fMinMax, obj1 * " " * constraints * " " * time * " ")

    # light robustness
    identity = [Matrix(1I, n*n, n*n) zeros(n*n, 1)]
    rho = 0.5
    Gamma2 = [0 for i in 1:(2*n + 1 + n*n)]
    Gamma2[1] = 4
    cU2 = [cU1 0; zeros(2*n + n*n, n*n + 1)]
    model2, n2, x2, zOpt2, y2, p2, z2, obj2 =  robustOpt.lightRobustnessMin(c1, [0; b; -b; u], [A1; identity], Gamma2,
    cU2, rho, false, false, false)

    # recoverable - continous budget!
    Gamma3 = 100.0
    K = 50.0
    model3, n3, x3, q3, zP3, zM3, beta3, obj3 = robustOpt.recoverableMin(zeros(2*n*n), [c; zeros(n*n)],
    [cU; zeros(n * n)], [b; u], [A zeros(n, n*n); Matrix(1I, n*n, n*n) Matrix(1I, n*n, n*n)], Gamma3, K, false, false)
end

close(fMinMax)
close(fLight)
close(fRecov)
close(fAdj)
close(fNom)
