include("../robustLP/robustOpt.jl")

using .robustOpt

using Random, SparseArrays, Distributions, LinearAlgebra, Base
import Base.stderr

redirect_stdout(open("/dev/null", "w"))
# TODO różne informacje dla adjustable
function checkConstraints(A, B, b, dict, n, k, mode)
#     bad = 0
#     all = size(A)[1]
#     for i in 1:(size(A)[1])
#         # min max
#         if mode == 0 && !(sum(A[i, j] * dict[:x][j] for j in 1:n) <= b[i])
#             bad += 1
#         # light robustness
#         elseif mode == 1 && !(sum(A[i, j] * dict[:x][j] for j in 1:n) <= b[i])
#             bad += 1
#         # adjustable
#         elseif mode == 2
#              res1 = sum(B[i, j] * dict[:y][j] for j in 1:k)
# #              if !()
# #                 bad += 1
# #              end
#         end
#     end
#     return bad / all
return 0
end


function test(fileName, steps, Gammas, per, rhos, T, n)
    tmp = abs(rand(Int))
    println(stderr, tmp)
    Random.seed!(8443422321741948758)
# 1353344747400700187
# 6087208597166880550
# 8288897616298075162 <- fajne
# 5343414465449820459 też spoko
# 8443422321741948758 dla tego dziwne rzeczy
    fMinMax = open("./" * fileName * "_minmax_demands.txt", "a")
    fLight = open("./" * fileName * "_light_demands.txt", "a")
    fAdj = open("./" * fileName * "_adj_demands.txt", "a")
    fNom = open("./" * fileName * "_nom_demands.txt", "a")
    fNomWorst = open("./" * fileName * "_nomWorst_demands.txt", "a")

    # periods - T, no of factories - n

    c = spzeros(n * T)
    for t in 1:length(c)
        c[t] += rand((Uniform(0, 100)))
    end
    println(stderr, " c " * string(c))

    # maximum nad minimum storage at warehause
    VMax = rand(Uniform(1000, 100000))
    VMin = rand(Uniform(0, 100))
    # total production of factory accumulated over time
    Cap = spzeros(n)
    for t in 1:length(Cap)
        Cap[t] += rand((Uniform(500, 10000)))
    end

    # demands
    d = spzeros(T)
    for t in 1:length(d)
        d[t] += rand((Uniform(0, 100)))
    end
    # ile produktu w magazynie na poczatku
    v1 = rand(Uniform(0, 50))

    # maximum production at facotry in period t
    P = spzeros(n * T)
    for i in 1:(n*T)
        P[i] = rand(Uniform(50, 900))
    end
    # klasyczny problem, ale z przerzuconym wektorem prawych stron
    A = zeros(n + T + T + n * T + 2, n * T + 1)
#     ANom = spzeros(n + T + T + n * T + 2, n * T + 1)
    A[n + T + T + n * T + 1, n * T + 1] = 1
    A[n + T + T + n * T + 2, n * T + 1] = -1
#     ANom[n + T + T + n * T + 1, n * T + 1] = 1
#     ANom[n + T + T + n * T + 2, n * T + 1] = -1

    # dla adjustable, jedna zmienna bez dodatkowych info i przenisienie
    # f kosztu do ograniczenia i dodatkowo nowa zmienna, żeby w min
    # i v max przerzucić do ograniczeń
    # + ograniczenia na te zmienna zeby byla 1
    AA = zeros(n + T + T + n * T + 1 + 2, n + 2)
    # fabryka1_okres1 fabryka1_okres2...
    # pierwszy okres w AA
    B = zeros(n + T + T + n * T + 1 + 2, (n) * (T - 1))
    # produkcja wszystkich fabryk w pierwszym okresie
    for i in 1:n
        AA[1, i] = c[(i - 1) * T  + 1]
    #     println(stderr, "AA " * string(i) * " " * string(c[(i - 1) * T  + 1]))
    end
    for i in 1:n
        for j in 1:(T - 1)
            B[1, (i - 1) * (T - 1) + j] = c[(i - 1) * (T) + j + 1]
    #         println(stderr, "B " * string((i - 1) * (T - 1) + j) * " " * string(c[(i - 1) * (T) + j + 1]))
        end
    end

    AA[1, n + 1] = -1
    AA[n + T + T + n * T + 1 + 1, n + 2] = 1
    AA[n + T + T + n * T + 1 + 2, n + 2] = -1

    # zmienne decyzyjne x_it
    for i in 1:n
        # suma x_it dla każdego <= cap
        for j in 1:T
            A[i, j + T * (i - 1)] = 1
#             ANom[i, j + T * (i - 1)] = 1
        end
        A[i, n*T+1] = 0
#         ANom[i, n*T+1] = 0
    end
    for i in 2:(n+1)
        AA[i, i - 1] = 1
        for j in 1:(T-1)
            B[i, (i - 2) * (T - 1) + j] = 1
        end
    end

    # vmin
    for i in (n + 2):(n + 1 + T)
        for j in 1:n
        # pierwszy okres jest zawsze
            AA[i, j] = -1
        end
        AA[i, n + 2] = VMin - v1
        for k in 1:n
            for j in 1:(i - n - 2)
                B[i, (k - 1) * (T - 1) + j] = -1
            end
        end
    end
    # v max
    for i in (n + 2 + T):(n + 1 + T + T)
        for j in 1:n
        # pierwszy okres jest zawsze
            AA[i, j] = 1
        end
        AA[i, n + 2] = v1 - VMax
        for k in 1:n
            for j in 1:(i - n - 2 - T)
                B[i, (k - 1) * (T - 1) + j] = 1
            end
        end
    end

    # produkcja w okresie
    for i in 1:n
        for j in 1:T
            # było (n + T + T + 1)
            A[(n + T + T) + (i - 1) * T + j, (i - 1) * T + j] = 1
#             ANom[(n + T + T + 1) + (i - 1) * T + j, (i - 1) * T + j] = 1
        end
         A[i, n*T+1] = 0
#          ANom[i, n*T+1] = 0
    end

    for i in 1:n
        AA[(n + T + T + 2) + (i - 1) * T, i] = 1
    end

    for i in 1:n
        for j in 1:(T - 1)
            # było (n + T + T + 2)
            B[(n + T + T + 2) + (i - 1) * T + j, (i - 1) * (T - 1) + j] = 1
        end
    end

    zeroQ = []
    # tylko tam zerujemy gdzie są demandy
    # v amin
    for k in 1:n
        for j in 1:(T - 1)
            for i in (j + 2):T # j + 2
                append!(zeroQ, [((k - 1) * (T - 1) + j, n + i + 1)])
            end
        end
    end
    # v max
    for k in 1:n
        for j in 1:(T - 1)
            for i in (j + 2):T # j + 2
               append!(zeroQ, [((k - 1) * (T - 1) + j, n + T + i + 1)])
            end
        end
    end

    vm = [-VMin + v1 for i in 1:T]
    vma = [VMax - v1 for i in 1:T]
    b  = sparse([Cap; vm; vma; P; [1]; [-1]])
    z = zeros(n + T + T + n * T + 2, n * T)
    J = [Int64[] for i in 1:size(A)[1]]
    for i in (n + 1):(n + T + T)
        J[i] = [n*T + 1]
    end

#     Random.seed!(456789)
    for s in 1:steps
        println(stderr, s)
        # uncertainty
        dU = spzeros(T)
        for r in 1:length(dU)
            dU[r] = rand(Uniform(0, d[r] * per))
        end

        # sumy cząstkowe d i du
        dSum = zeros(T)
        dUSum = zeros(T)
        dSum[1] = d[1]
        dUSum[1] = dU[1]
        for t in 2:T
            dSum[t] = dSum[t - 1]
            dSum[t] += d[t]
            dUSum[t] = dUSum[t - 1]
            dUSum[t] += dU[t]
        end

        # popyt i ograniczenia na produkcję razem
        # v_min <= v_1 + adjustable -> -v1-... >= -v_min
        for i in (n + 1):(n + T)
            for k in 1:n
                for j in 1:(i - n)
                    A[i, (k - 1) * T + j] = -1
    #                 ANom[i, (k - 1) * T + j] = -1
                end
            end
            A[i, n*T+1] = dSum[i - n]
        end

        # ograniczenie <= v_max - v_1
        for i in (n + 1 + T):(n + T + T)
            for k in 1:n
                for j in 1:(i - n - T)
                    A[i, (k - 1) * T + j] = 1
                end
            end
             A[i, n*T+1] = -dSum[i - n - T]
        end

        ANom = A[:, 1:(size(A)[2] - 1)]
        ANom = ANom[1:(size(A)[1] - 2), :]

        if s == 1
            vmNom = [-VMin + v1 - dSum[i] for i in 1:T]
            vmaNom = [VMax - v1 + dSum[i] for i in 1:T]
            # nominal
            model0, dict0, obj0 = robustOpt.nominal(c, [Cap; vmNom; vmaNom; P], ANom, false, false)
            time = @elapsed robustOpt.nominal(c, [Cap; vmNom; vmaNom; P], ANom, false, false)
#             write(fNom, string(obj0) * " " * string(time) * "\n")
            println(stderr, "nom " * string(obj0) * " " * string(time))
            println(stderr, dict0[:x])
        end

println(stderr, "v max v min v1 " * string(VMax) * " " * string(VMin) * " " * string(v1))
println(stderr, "d " * string(dSum))
println(stderr, "du " * string(dUSum))
println(stderr, "vmin + uncertainty ")
for t in 1:T
println(stderr,"okres min" * string(t) * " " * string(-v1 + dSum[t] + dUSum[t] + VMin))
println(stderr,"okres max" * string(t) * " " * string(v1 - dSum[t] - dUSum[t] - VMax))
end
println(stderr, "nom")
for t in 1:T
println(stderr,"okres min" * string(t) * " " * string(-v1 + dSum[t]  + VMin))
println(stderr,"okres max" * string(t) * " " * string(v1 - dSum[t]  - VMax))
end

        # worst
        vmNomW = [-VMin + v1 - dSum[i] - dUSum[i] for i in 1:T]
        vmaNomW = [VMax - v1 + dSum[i] + dUSum[i] for i in 1:T]
        model01, dict01, obj01 = robustOpt.nominal(c, [Cap; vmNomW; vmaNomW; P], ANom, false, false)
        time = @elapsed robustOpt.nominal(c, [Cap; vmNomW; vmaNomW; P], ANom, false, false)
#         write(fNomWorst, string(obj01) * " " * string(time) * "\n")
        print(stderr,"worst " * string(obj01) * " " * string(time) * "\n")

        for g in Gammas
            Gamma = spzeros(size(A)[1])
            for i in (n + 1):(n + T + T)
                Gamma[i] = g
            end
            # min max
            bMU = [spzeros(length(Cap)); dUSum; -dUSum; spzeros(length(P) + 2)]
            model1, dict1, obj1 = robustOpt.minmax(sparse([c; 0]), [], [], b, A, Gamma, J, bMU, false, false, false)
            time = @elapsed robustOpt.minmax(sparse([c; 0]), [], [], b, A, Gamma, J, bMU, false, false, false)
            constraints = checkConstraints(A, [], b, dict1, n * n, 0, 0)
#             write(fMinMax, string(g) * " " * string(obj1) * " " * string(constraints) * " " * string(time) * "\n")
            print(stderr, "minmax " * string(g) * " " * string(obj1) * " " * string(constraints) * " " * string(time) * "\n")

            # light robustness
            for j in 1:length(rhos)
                model2, dict2, obj2 =  robustOpt.lightRobustnessMin(sparse([c; 0]), b, A, Gamma, [z bMU], rhos[j], false, false, false)
                time = @elapsed robustOpt.lightRobustnessMin(sparse([c; 0]), b, A, Gamma, [z bMU], rhos[j], false, false, false)
                constraints = checkConstraints(A, [], b, dict2, n * n, 0, 1)
                if j == length(rhos)
#                     write(fLight, string(g) * " " * string(obj2) * " " * string(constraints) * " " * string(time) * "\n")
                    print(stderr, "light " * string(g) * " " * string(obj2) * " " * string(constraints) * " " * string(time) * "\n")
                else
#                    write(fLight, string(g) * " " * string(obj2) * " " * string(constraints) * " " * string(time) * " ")
                   println(stderr, "light " * string(g) * " " * string(obj2) * " " * string(constraints) * " " * string(time) * " ")
                end
            end
#             display(A)
#             display(AA)
#             display(B)
            # adjustable
            bA = sparse([0; Cap; -dSum; dSum; P; [1]; [-1]])
            bAU = sparse([spzeros(1 + n); -dUSum; dUSum; spzeros(n*T); 0; 0])
            model3, dict3, obj3 = robustOpt.adjustableMinB(sparse([zeros(n); [1]; [0]]), bA, AA, B, g, bAU, zeroQ, false, false)
            time = @elapsed robustOpt.adjustableMinB(sparse([zeros(n); [1]; [0]]), bA, AA, B, g, bAU, zeroQ, false, false)
            constraints = checkConstraints(A, [], b, dict3, n * n, 0, 0)
#             write(fAdj, string(g) * " " * string(obj3) * " " * string(constraints) * " " * string(time) * "\n")
            print(stderr, "adj " *  string(g) * " " * string(obj3) * " " * string(constraints) * " " * string(time) * "\n")
            println(stderr, "x "  * string(dict3[:x]))
            println(stderr, "y " * string(dict3[:y]))
       end
    end
    close(fMinMax)
    close(fLight)
    close(fAdj)
    close(fNom)
    close(fNomWorst)
end
# (fileName, steps, Gammas, per, rhos, T, n)
test("test3", 1, [1.0], 0.7, [0.1], 24, 5)

redirect_stdout(stdout)
