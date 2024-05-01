include("../robustLP/robustOpt.jl")

using .robustOpt

using Random, SparseArrays, Distributions, LinearAlgebra, Base
import Base.stderr

per = 0.5
redirect_stdout(open("/dev/null", "w"))

# periods
T = 7
# no of factories
n = 5

# jak to zrównoważyć?

c = spzeros(n * T)
for t in 1:length(c)
    c[t] += rand((Uniform(0, 100)))
end

# maximum nad minimum storage at warehause
VMax = rand(Uniform(1000, 100000))
VMin = rand(Uniform(0, 900))
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

# uncertainty
dU = spzeros(T)
for r in 1:length(dU)
    dU[r] = rand(Uniform(0, d[r] * per))
end

# maximum production at facotry in period t
P = spzeros(n * T)
for i in 1:(n*T)
    P[i] = rand(Uniform(50, 900))
end
# klasyczny problem, ale z przerzuconym wektorem prawych stron
A = spzeros(n + T + T + n * T + 2, n * T + 1)
A[n + T + T + n * T + 1, n * T + 1] = 1
A[n + T + T + n * T + 2, n * T + 1] = -1
# dla adjustable, jedna zmienna bez dodatkowych info i przenisienie
# f kosztu do ograniczenia i dodatkowo nowa zmienna, żeby w min
# i v max przerzucić do ograniczeń
# + ograniczenia na te zmienna zeby byla 1
AA = spzeros(n + T + T + n * T + 1 + 2, n + 2)
# fabryka1_okres1 fabryka1_okres2...
# pierwszy okres w AA
B = spzeros(n + T + T + n * T + 1 + 2, (n) * (T - 1))
# produkcja wszystkich fabryk w pierwszym okresie
for i in 1:n
    AA[1, i] = c[i]
end
for i in 2:n
    for j in 1:T
        B[1, (i - 2) * (T - 1) + j] = c[(i - 1) * (T - 1) + j]
    end
end
AA[1, n + 1] = -1
AA[n + T + T + n * T + 1 + 1, n + 2] = 1
AA[n + T + T + n * T + 1 + 2, n + 2] = -1


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


# zmienne decyzyjne x_it
for i in 1:n
    # suma x_it dla każdego <= cap
    for j in 1:T
        A[i, j + T * (i - 1)] = 1
    end
    A[i, n*T+1] = 0
end
for i in 2:(n+1)
    AA[i, i - 1] = 1
    for j in 1:(T-1)
        B[i, (i - 2) * (T - 1) + j] = 1
    end
end

# popyt i ograniczenia na produkcję razem
# v_min <= v_1 + adjustable -> -v1-... >= -v_min
for i in (n + 1):(n + T)
    for k in 1:n
        for j in 1:(i - n)
            A[i, (k - 1) * T + j] = -1
        end
    end
    A[i, n*T+1] = dSum[i - n]
end

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

# ograniczenie <= v_max - v_1
for i in (n + 1 + T):(n + T + T)
    for k in 1:n
        for j in 1:(i - n - T)
            A[i, (k - 1) * T + j] = 1
        end
    end
     A[i, n*T+1] = -dSum[i - n - T]
end


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
        A[(n + T + T + 1) + (i - 1) * T + j, (i - 1) * T + j] = 1
    end
     A[i, n*T+1] = 0
end

for i in 1:n
    AA[(n + T + T + 2) + (i - 1) * T, i] = 1
end

for i in 1:n
    for j in 2:(T - 1)
        B[(n + T + T + 2) + (i - 1) * T + j, (i - 1) * (T - 1) + j] = 1
    end
end

zeroQ = []
# tylko tam zerujemy gdzie są demandy
# v amin
for k in 1:n
    for j in 1:(T - 1)
        for i in (j + 2):T
            append!([((k - 1) * (T - 1) + j + n + 2, i)])
        end
    end
end
# v max
for k in 1:n
    for j in 1:(T - 1)
        for i in (j + 2):T
            append!([((k - 1) * (T - 1) + j + n + 2 + T, i)])
        end
    end
end

vm = [-VMin + v1 for i in 1:T]
vma = [VMax - v1 for i in 1:T]
b  = sparse([Cap; vm; vma; P; [1]; [-1]])
bA = sparse([0; Cap; -dSum; dSum; P; [1]; [-1]])
bAU = sparse([spzeros(1 + n); -dUSum; dUSum; spzeros(n*T); 0; 0])
model, dict, opt = adjustableMinB(sparse([zeros(n); [1]; [0]]), bA, AA, B, 1.0, bAU, zeroQ, false, true)
println(stderr, dict[:x])
println(stderr, dict[:y])
# println(stderr, dict[:Q])
println(stderr, "adj " * string(opt))
J = [Int64[] for i in 1:size(A)[1]]
for i in (n + 1):(n + T + T)
    J[i] = [n*T + 1]
end

Gamma = spzeros(size(A)[1])
for i in (n + 1):(n + T + T)
    Gamma[i] = 1
end
bMU = [spzeros(length(Cap)); -dUSum; dUSum; spzeros(length(P) + 2)]
z = zeros(n + T + T + n * T + 2, n * T)
model, dict, opt = robustOpt.minmax(sparse([c; 0]), [], [], b, A, Gamma, J, [z bMU], false, false, false)
println(stderr, "min max " * string(opt))
println(stderr, dict[:x])
ANom = A[:, 1:(size(A)[2] - 1)]
ANom = ANom[1:(size(A)[1] - 2), :]
# worst
vmNom = [-VMin - v1 - dSum[i] - dUSum[i] for i in 1:T]
vmaNom = [VMax - v1 + dSum[i] + dUSum[i] for i in 1:T]
model, dict, opt = robustOpt.nominal(c, [Cap; vmNom; vmaNom; P], ANom, false, false)
println(stderr, "worst " * string(opt))
println(stderr, dict[:x])
redirect_stdout(stdout)
