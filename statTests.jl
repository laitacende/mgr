using CSV, DataFrames, DelimitedFiles, HypothesisTests, Statistics

fileName = "test4"

dfNom = CSV.read("./" * fileName * "_nom.txt", DataFrame, delim=" ", header=false)
dfLight = CSV.read("./" * fileName * "_light.txt", DataFrame, delim=" ", header=false)
dfAdj = CSV.read("./" * fileName * "_adj.txt", DataFrame, delim=" ", header=false)
dfWorst = CSV.read("./" * fileName * "_nomWorst.txt", DataFrame, delim=" ", header=false)
# dfRecov = CSV.read("./" * fileName * "_recov.txt", DataFrame, delim=" ", header=false)
# dfRecovInf = CSV.read("./" * fileName * "_recov_inf.txt", DataFrame, delim=" ", header=false)
dfMM = CSV.read("./" * fileName * "_minmax.txt", DataFrame, delim=" ", header=false)

# podsumuj recoverable
# 0 dla obj, 1 dla constrants
function meanRow(row, plus)
    vals = row[[2 + plus, 6 + plus, 10 + plus, 14 + plus, 18 + plus, 22 + plus, 26 + plus, 30 + plus, 34 + plus, 38 + plus]]
    return mean(skipmissing(vals))  # Skip missing values if any
end

function meanRowA(row, plus)
    vals = row[[2 + plus, 6 + plus, 10 + plus, 14 + plus, 18 + plus, 22 + plus]]
    return mean(skipmissing(vals))  # Skip missing values if any
end

# meansO = Float64[]
# meansC = Float64[]
# meansOI = Float64[]
# meansCI = Float64[]
# for row in eachrow(dfRecov)
#     push!(meansO, meanRow(row, 0))
#     push!(meansC, meanRow(row, 1))
# end
# dfRecov[!, 2] = meansO
# dfRecov[!, 3] = meansC
#
# for row in eachrow(dfRecovInf)
#     push!(meansOI, meanRow(row, 0))
#     push!(meansCI, meanRow(row, 1))
# end
# dfRecovInf[!, 2] = meansOI
# dfRecovInf[!, 3] = meansCI

# podsumuj light robustness
meansOL = Float64[]
meansCL = Float64[]
for row in eachrow(dfLight)
    push!(meansOL, meanRow(row, 0))
    push!(meansCL, meanRow(row, 1))
end
dfLight[!, 2] = meansOL
dfLight[!, 3] = meansCL
# podsumuj adjustable
meansOA = Float64[]
meansCA = Float64[]
for row in eachrow(dfAdj)
    push!(meansOA, meanRowA(row, 0))
    push!(meansCA, meanRowA(row, 1))
end
dfAdj[!, 2] = meansOA
dfAdj[!, 3] = meansCA
# dfs = [dfLight, dfRecov, dfMM, dfRecovInf]
# names = ["light robustness", "recoverable", "min-max", "recoverable inf"]
dfs = [dfLight, dfMM, dfAdj]
names= ["light robustness", "min-max", "adjustable"]

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