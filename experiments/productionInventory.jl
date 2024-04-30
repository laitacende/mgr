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
# produkcja wszystkich fabryk w pierwszym okresie
for i in 1:n
    AA[1, i] = c[i]
end
AA[1, n + 1] = -1
AA[n + T + T + n * T + 1 + 1, n + 2] = 1
AA[n + T + T + n * T + 1 + 2, n + 2] = -1
# fabryka1_okres1 fabryka1_okres2...
B = spzeros(n + T + T + n * T + 1 + 1, (n - 1) * T)


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
    A[i, n*T+1] = -1
end
for i in 2:(n+1)
    if i == 2
        for j in 1:n
            AA[i, j] = 1
        end
#         AA[i, n + 1] = 0
    end
    if i != 2 # pierwszy okres ma same 0 tutaj
        for j in 1:T
            B[i, j + T * (i - 3)] = 1
        end
    end
end

# popyt i ograniczenia na produkcję razem
# v_min <= v_1 + adjustable -> -v1-... >= -v_min
for i in (n + 1):(n + 1 + T)
    for k in 1:n
        for j in 1:(i - n)
            A[i, (k - 1) * T + j] = -1
        end
    end
    A[i, n*T+1] = dSum[i - n]
end

for i in (n + 2):(n + 2 + T)
    for j in 1:n
    # pierwszy okres jest zawsze
        AA[i, j] = -1
    end
    AA[i, n + 2] = VMin - v1
    for k in 2:n
        for j in 1:(i - n - 1)
            B[i, (k - 1) * T + j] = -1
        end
    end
end

# ograniczenie <= v_max - v_1
for i in (n + 1):(n + 1 + T)
    for k in 1:n
        for j in 1:(i - n)
            A[i, (k - 1) * T + j] = 1
        end
    end
     A[i, n*T+1] = dSum[i - n]
end

for i in (n + 2):(n + 2 + T)
    for j in 1:n
    # pierwszy okres jest zawsze
        AA[i, j] = 1
    end
#     AA[i, n + 1] = 0
     AA[i, n + 2] = v1 - VMax
    for k in 2:n
        for j in 1:(i - n - 1)
            B[i, (k - 1) * T + j] = 1
        end
    end
end

# produkcja w okresie
for i in 1:n
    for j in 1:T
        A[(n + T + T + 1) + (i - 1) * T + j, (i - 1) * T + j] = 1
    end
     A[i, n*T+1] = -1
end

for i in 1:n
    for j in 1:T
        AA[(n + T + T + 2) + (i - 1) * T + j, j] = 1
    end
end

for i in 1:(n-1)
    for j in 1:T
        B[(n + T + T + 2) + (i - 1) * T + j, (i - 1) * T + j] = 1
    end
end

# VmIN I VmAX t RAZY!
vm = [-VMin + v1 for i in 1:T]
vma = [VMax - v1 for i in 1:T]
b  = [Cap; vm; vma; P; 1; -1]
bA = [0; Cap; -dSum; dSum; P; 1; -1]
bAU = [spzeros(1 + n); -dUSum; dUSum; spzeros(n*T); 0; 0]
adjustableMinB(c, bA, AA, B, 1.0, bAU,
    false, true)

redirect_stdout(stdout)
