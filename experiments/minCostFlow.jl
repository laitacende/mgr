include("../robustLP/robustOpt.jl")

using .robustOpt

using Random, SparseArrays, Distributions, LinearAlgebra, Base
import Base.stderr

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
# wypadku nie mówimy o naruszeniu ograniczeń; wartość optymalna

# file format: funkcja_celu, naruszone_ograniczenia (w procentach), czas
redirect_stdout(open("/dev/null", "w"))

function checkConstraints(A, B, b, dict, n, k, mode)
    bad = 0
    all = size(A)[1]
    for i in 1:(size(A)[1])
        # min max
        if mode == 0 && !(sum(A[i, j] * dict[:x][j] for j in 1:n) <= b[i])
            bad += 1
        # light robustness
        elseif mode == 1 && !(sum(A[i, j] * dict[:x][j] for j in 1:n) <= b[i])
            bad += 1
        # recoverable
        elseif mode == 2 && !(sum(A[i, j] * dict[:x][j] for j in 1:n) == b[i])
            bad += 1
        elseif mode == 3
            res1 = B * d'
            if !(sum(A[i, j] * dict[:x][j] for j in 1:n)
                + sum(B[i, j] * dict[:d][j] for j in 1:k) <= b[i])
                bad += 1
            end
        end
    end
    return bad / all
end

# Gamma to procent liczby zmiennych wszystkich lub sumy niepewnosci
# percent czy niepewności to procenty nominalnych
# steps  liczba różnych losowań niepewności
function test(fileName, percent, steps, Gammas, n, per, KPer, rhos)

    fMinMax = open("./" * fileName * "_minmax.txt", "a")
    fLight = open("./" * fileName * "_light.txt", "a")
    fRecov = open("./" * fileName * "_recov.txt", "a")
    fAdj = open("./" * fileName * "_adj.txt", "a")
    fNom = open("./" * fileName * "_nom.txt", "a")
    fNomWorst = open("./" * fileName * "_nomWorst.txt", "a")

    # generate graph

    # vertices
    # n = rand(10:500)
    # n = 150
    # probability of creating and edge
    p = 1
    # incident matrix
    A = spzeros(n, n * n)
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

    # u = Vector{Float64}(undef, n * n)
    u = zeros(n * n)
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
    c = zeros(n * n)
    c .+= rand.((Uniform(0, 100)))

    # nominal
    identity = Matrix(1I, n*n, n*n)
    model0, dict0, obj0 = robustOpt.nominal(c, [b; -b; u], [A; -A; identity], false, false)

    time = @elapsed robustOpt.nominal(c, [b; -b; u], [A; -A; identity], false, false)
    write(fNom, string(obj0) * " " * string(time) * "\n")


    for i in 1:steps
        println(stderr, string(i))
        cU = zeros(n * n)
        if (percent)
            cU .+= per * c
        else
            cU .+= rand.((Uniform(0, 80)))
        end

        # nominal with worst case
        # modify vector c to obtain its worst case +- with obb 1/2
        cWorst = copy(c)
        for i in 1:length(c)
            if rand() < 0.5
                cWorst[i] += cU[i]
            else
                cWorst[i] -= cU[i]
            end
        end
        model01, dict01, obj01 = robustOpt.nominal(cWorst, [b; -b; u], [A; -A; identity], false, false)
        time = @elapsed robustOpt.nominal(cWorst, [b; -b; u], [A; -A; identity], false, false)
        write(fNomWorst, string(obj01) * " " * string(time) * "\n")

         for Gamma in Gammas
            # minmax
            c1 = zeros(n*n + 1)
            c1[n * n + 1] = 1
            cC = copy(c)
            A1 = [sparse([cC' -1]); A zeros(n, 1); -A zeros(n, 1)]
            # all of the costs can be uncertain
            J1 = [Int64[] for i in 1:(2*n + 1)]
            J1[1] = [i for i in 1:(n*n)]
            Gamma1 = [0.0 for i in 1:(2*n + 1)]
            Gamma1[1] = Gamma * n * n
            cU1 = reshape(cU, 1, length(cU))
            model1, dict1, obj1 = robustOpt.minmax(c1, zeros(n*n + 1), [u; 100000000000000000],
            [0; b; -b], A1, Gamma1, J1, cU1, true, false, false)


            time = @elapsed robustOpt.minmax(c1, zeros(n*n + 1), [u; 100000000000000000],
            [0; b; -b], A1, Gamma1, J1, cU1, true, false, false)
            constraints = checkConstraints(A, [], b, dict1, n * n, 0, 0)
            write(fMinMax, string(Gamma) * " " * string(obj1) * " " * string(constraints) * " " * string(time) * "\n")

            # light robustness
            identity = [Matrix(1I, n*n, n*n) zeros(n*n, 1)]
            Gamma2 = [0.0 for i in 1:(2*n + 1 + n*n)]
            Gamma2[1] = Gamma * n * n
            cU2 = [cU1 0; zeros(2*n + n*n, n*n + 1)]
            for i in 1:length(rhos)
                model2, dict2, obj2 =  robustOpt.lightRobustnessMin(c1, [0; b; -b; u], [A1; identity], Gamma2,
                cU2, rhos[i], false, false, false)

                time = @elapsed robustOpt.lightRobustnessMin(c1, [0; b; -b; u], [A1; identity], Gamma2,
                cU2, rhos[i], false, false, false)
                constraints = checkConstraints(A, [], b, dict2, n * n, 0, 1)
                if i == length(rhos)
                    write(fLight, string(Gamma) * " " * string(obj2) * " " * string(constraints) * " " * string(time) * "\n")
                else
                   write(fLight, string(Gamma) * " " * string(obj2) * " " * string(constraints) * " " * string(time) * " ")
                end
            end
            # recoverable - continous budget!
            sumUnc = sum(cU)
            Gamma3 = Gamma * sumUnc
            K = maximum(cU) * n * KPer
            model3, dict3, obj3 = robustOpt.recoverableMin(zeros(2*n*n), [c; zeros(n*n)],
            [cU; zeros(n * n)], [b; u], [A zeros(n, n*n); Matrix(1I, n*n, n*n) Matrix(1I, n*n, n*n)], Gamma3, K, false, false)

            time = @elapsed robustOpt.recoverableMin(zeros(2*n*n), [c; zeros(n*n)],
            [cU; zeros(n * n)], [b; u], [A zeros(n, n*n); Matrix(1I, n*n, n*n) Matrix(1I, n*n, n*n)], Gamma3, K, false, false)
            constraints = checkConstraints(A, [], b, dict3, n * n, 0, 2)
            write(fRecov, string(Gamma) * " " * string(obj3) * " " * string(constraints) * " " * string(time) * "\n")
        end
    end
    close(fMinMax)
    close(fLight)
    close(fRecov)
    close(fAdj)
    close(fNom)
end

# test(fileName, percent, steps, Gamma, n, per, Kper, rhos)
test("test1", false, 1, [0.3, 0.5], 4, 0.2, 0.5, [0.1, 0.2, 0.5, 0.8])

redirect_stdout(stdout)