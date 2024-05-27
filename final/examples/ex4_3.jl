using robustOpt

println("------ adjustable -----")
c = [0, 1]
b = [0, 2000, -150, -200, -250, -290, 350, 350, 350, 350]
bU = [0, 0, -70, -50, -100, -50, 0, 0, 0, 0]
A = [300 -1; 1 0; -1 0; 0 0; 0 0; 0 0; 1 0; 0 0; 0 0; 0 0]
D = [300 300 300; 1 1 1; 0 0 0; -1 0 0; 0 -1 0; 0 0 -1;0 0 0; 1 0 0; 0 1 0; 0 0 1]
Gammas = [0.1, 0.2, 0.5, 0.7,  1.0]
zeroQ = []
T = 4
n = 1
# v amin
for k in 1:n
    for j in 1:(T - 1)
        for i in (j + 2):T
            append!(zeroQ, [((k - 1) * (T - 1) + j, n + i + 1)])
        end
    end
end
# v max
for k in 1:n
    for j in 1:(T - 1)
        for i in (j + 2):T
           append!(zeroQ, [((k - 1) * (T - 1) + j, n + T + i + 1)])
        end
    end
end
# v min
for k in 1:n
    for j in 1:(T - 1)
        for i in 1:j
            append!(zeroQ, [((k - 1) * (T - 1) + j, n + i + 1)])
        end
    end
end
# v max
for k in 1:n
    for j in 1:(T - 1)
        for i in 1:j
           append!(zeroQ, [((k - 1) * (T - 1) + j, n + T + i + 1)])
        end
    end
end
for Gamma in Gammas
    println("-- " * string(Gamma) * " --")
    m, dict, opt = adjustableMinB(c, b, A, D, Gamma, bU, zeroQ, false, true)
end

println("------ worst -----")
m, dict, opt = nominal([300, 300, 300, 300], [2000, -220, -250, -350, -340, 350, 350, 350, 350],
     [1 1 1 1; -1 0 0 0; 0 -1 0 0; 0 0 -1 0; 0 0 0 -1; 1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1], false, true)

println("------ nominal -----")
m, dict, opt = nominal([300, 300, 300, 300], [2000, -150, -200, -250, -290, 350, 350, 350, 350],
     [1 1 1 1; -1 0 0 0; 0 -1 0 0; 0 0 -1 0; 0 0 0 -1; 1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1], false, true)