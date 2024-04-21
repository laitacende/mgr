using CSV, DataFrames, DelimitedFiles, HypothesisTests

fileName = "test1"

dfNom = CSV.read("./" * fileName * "_nom.txt", DataFrame, delim=" ", header=false)
dfLight = CSV.read("./" * fileName * "_light.txt", DataFrame, delim=" ", header=false)
dfAdj = CSV.read("./" * fileName * "_adj.txt", DataFrame, delim=" ", header=false)
dfWorst = CSV.read("./" * fileName * "_nomWorst.txt", DataFrame, delim=" ", header=false)
dfRecov = CSV.read("./" * fileName * "_recov.txt", DataFrame, delim=" ", header=false)
dfMM = CSV.read("./" * fileName * "_minmax.txt", DataFrame, delim=" ", header=false)

# TODO add adj !!!!!!!!!!!
dfs = [dfLight, dfRecov, dfMM]
names = ["light robustness", "recoverable", "min-max"]

fOM = open("./" * fileName * "_median_obj.txt", "w")
fCM = open("./" * fileName * "_median_constraints.txt", "w")
fOT = open("./" * fileName * "_t_obj.txt", "w")
fCT = open("./" * fileName * "_t_constraints.txt", "w")

alpha = 0.05

# czy powinniśmy grupować po gammach? (wydaje się, że nie, te próbki i tak
# są dobrze ułożone
# sign median test
# hipoteza zerowa - mediany są równe
for i in 1:length(dfs)
    for j in (i + 1):length(dfs)
        res = SignTest(dfs[i][!, 2], dfs[j][!, 2])
        pVal = pvalue(res)
        write(fOM, names[i] * " " * names[j] * " " *  string(pvalue(res)) * " " * string(pVal >= alpha) * "\n")
        # jeśli jest większe to hipoteza zerowa prawdiłowa
    end
end

# constraints
for i in 1:length(dfs)
    for j in (i + 1):length(dfs)
        res = SignTest(dfs[i][!, 3], dfs[j][!, 3])
        pVal = pvalue(res)
        write(fCM, names[i] * " " * names[j] * " " *  string(pvalue(res)) * " " * string(pVal >= alpha) * "\n")
        # jeśli jest większe to hipoteza zerowa prawdiłowa
    end
end

# t test
for i in 1:length(dfs)
    for j in (i + 1):length(dfs)
        res = OneSampleTTest(dfs[i][!, 2], dfs[j][!, 2])
        pVal = pvalue(res)
        write(fOT, names[i] * " " * names[j] * " " *  string(pvalue(res)) * " " * string(pVal >= alpha) * "\n")
        # jeśli jest większe to hipoteza zerowa prawdiłowa
    end
end

for i in 1:length(dfs)
    for j in (i + 1):length(dfs)
        res = OneSampleTTest(dfs[i][!, 3], dfs[j][!, 3])
        pVal = pvalue(res)
        write(fCT, names[i] * " " * names[j] * " " *  string(pvalue(res)) * " " * string(pVal >= alpha) * "\n")
        # jeśli jest większe to hipoteza zerowa prawdiłowa
    end
end

close(fCM)
close(fOT)
close(fCT)
close(fOM)