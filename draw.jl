using Plots, CSV, DataFrames, DelimitedFiles, Statistics


fileName = "test1"

dfNom = CSV.read("./" * fileName * "_nom.txt", DataFrame, delim=" ", header=false)
dfLight = CSV.read("./" * fileName * "_light.txt", DataFrame, delim=" ", header=false)
dfAdj = CSV.read("./" * fileName * "_adj.txt", DataFrame, delim=" ", header=false)
dfWorst = CSV.read("./" * fileName * "_nomWorst.txt", DataFrame, delim=" ", header=false)
dfRecov = CSV.read("./" * fileName * "_recov.txt", DataFrame, delim=" ", header=false)
dfMM = CSV.read("./" * fileName * "_minmax.txt", DataFrame, delim=" ", header=false)

x = combine(groupby(dfNom, 1), 2 => mean)[!, 1]

# nominalny
p = plot(x, [dfNom[!, 1] for i in 1:length(x)], labels=["Nom"], title="Wartość funkcji celu")
xlabel!(p, "Γ")
ylabel!(p, "wartość funkcji celu")

# worst
println(dfWorst)
println(mean(eachcol(dfWorst)))
# objective = [mean(eachcol(df)), combine(dfWorst), 1 => maximum)[!, 1], combine(dfWorst, 1 => minimum)[!, 1]]
# time = [combine(dfWorst, 2 => mean)[!, 2], combine(dfWorst, 2 => maximum)[!, 2], combine(dfWorst), 2 => minimum)[!, 2]]
# plot(x, , labels=["średnia Worst" "max Worst" "min Worst"])

# min max
# objective = [combine(groupby(dfMM, 1), 2 => mean)[!, 2], combine(groupby(dfMM, 1), 2 => maximum)[!, 2], combine(groupby(dfMM, 1), 2 => minimum)[!, 2]]
# time = [combine(groupby(dfMM, 1), 4 => mean)[!, 2], combine(groupby(dfMM, 1), 4 => maximum)[!, 2], combine(groupby(dfMM, 1), 4 => minimum)[!, 2]]
# constraints = [combine(groupby(dfMM, 1), 3 => mean)[!, 2], combine(groupby(dfMM, 1), 3 => minimum)[!, 2], combine(groupby(dfMM, 1), 3 => maximum)[!, 2]]
# plot!(p, x, objective, labels=["średnia MM" "max MM" "min MM"])
#
#
# # light - todo najpierw zanalizować wykres dla tego dla różnych procentów i wybrać jakiś do porównani
# objective = [combine(groupby(dfMM, 1), 2 => mean)[!, 2], combine(groupby(dfMM, 1), 2 => maximum)[!, 2], combine(groupby(dfMM, 1), 2 => minimum)[!, 2]]
# time = [combine(groupby(dfMM, 1), 4 => mean)[!, 2], combine(groupby(dfMM, 1), 4 => maximum)[!, 2], combine(groupby(dfMM, 1), 4 => minimum)[!, 2]]
# constraints = [combine(groupby(dfMM, 1), 3 => mean)[!, 2], combine(groupby(dfMM, 1), 3 => minimum)[!, 2], combine(groupby(dfMM, 1), 3 => maximum)[!, 2]]
# plot!(p, x, objective, labels=["średnia MM" "max MM" "min MM"])



savefig(p, "myplot.png")

