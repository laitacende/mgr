using Plots, CSV, DataFrames, DelimitedFiles, Statistics


fileName = "test1"

dfNom = CSV.read("./" * fileName * "_nom.txt", DataFrame, delim=" ", header=false)
dfLight = CSV.read("./" * fileName * "_light.txt", DataFrame, delim=" ", header=false)
dfAdj = CSV.read("./" * fileName * "_adj.txt", DataFrame, delim=" ", header=false)
dfWorst = CSV.read("./" * fileName * "_nomWorst.txt", DataFrame, delim=" ", header=false)
dfRecov = CSV.read("./" * fileName * "_recov.txt", DataFrame, delim=" ", header=false)
dfMM = CSV.read("./" * fileName * "_minmax.txt", DataFrame, delim=" ", header=false)

x = combine(groupby(dfMM, 1), 2 => mean)[!, 1]
# worst
w = mean.(eachcol(dfWorst))
wMax = maximum.(eachcol(dfWorst))
wMin = minimum.(eachcol(dfWorst))
objectiveW = [wMin[1], w[1], wMax[1]]
timeW = [wMin[2], w[2], wMax[2]]

# minmax
objectiveMM = [combine(groupby(dfMM, 1), 2 => minimum)[!, 2], combine(groupby(dfMM, 1), 2 => mean)[!, 2], combine(groupby(dfMM, 1), 2 => maximum)[!, 2]]
timeMM = [combine(groupby(dfMM, 1), 4 => minimum)[!, 2], combine(groupby(dfMM, 1), 4 => mean)[!, 2], combine(groupby(dfMM, 1), 4 => maximum)[!, 2]]
constraintsMM = [ combine(groupby(dfMM, 1), 3 => minimum)[!, 2], combine(groupby(dfMM, 1), 3 => mean)[!, 2], combine(groupby(dfMM, 1), 3 => maximum)[!, 2]]

# recov
KPerc = [0.1, 0.3, 0.5, 0.8]
# 4 wartości dla każdego kPer
objectiveR = []
timeR = []
constraintsR = []
for i in 1:length(KPerc)
    append!(objectiveR, [[combine(groupby(dfRecov, 1), 4*(i - 1) + 2 => minimum)[!, 2], combine(groupby(dfRecov, 1), 4*(i - 1) + 2 => mean)[!, 2], combine(groupby(dfRecov, 1), 4*(i - 1) + 2 => maximum)[!, 2]]])
    append!(timeR, [[combine(groupby(dfRecov, 1), 4*(i - 1) + 4 => minimum)[!, 2], combine(groupby(dfRecov, 1), 4*(i - 1) + 4 => mean)[!, 2], combine(groupby(dfRecov, 1), 4*(i - 1) + 4 => maximum)[!, 2]]])
    append!(constraintsR, [[combine(groupby(dfRecov, 1), 4*(i - 1) + 3 => minimum)[!, 2], combine(groupby(dfRecov, 1), 4*(i - 1) + 3 => mean)[!, 2], combine(groupby(dfRecov, 1), 4*(i - 1) + 3 => maximum)[!, 2]]])
end

# light robustness
rhos = [0.1, 0.2, 0.5, 0.8]
objectiveL = []
timeL = []
constraintsL = []
for i in 1:length(rhos)
    append!(objectiveL, [[combine(groupby(dfLight, 1), 4*(i - 1) + 2 => minimum)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 2 => mean)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 2 => maximum)[!, 2]]])
    append!(timeL, [[combine(groupby(dfLight, 1), 4*(i - 1) + 4 => minimum)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 4 => mean)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 4 => maximum)[!, 2]]])
    append!(constraintsL, [[combine(groupby(dfLight, 1), 4*(i - 1) + 3 => minimum)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 3 => mean)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 3 => maximum)[!, 2]]])
end

# adj
# objectiveA = [combine(groupby(dfAdj, 1), 2 => mean)[!, 2], combine(groupby(dfAdj, 1), 2 => maximum)[!, 2], combine(groupby(dfAdj, 1), 2 => minimum)[!, 2]]
# timeA = [combine(groupby(dfAdj, 1), 4 => mean)[!, 2], combine(groupby(dfAdj, 1), 4 => maximum)[!, 2], combine(groupby(dfAdj, 1), 4 => minimum)[!, 2]]
# constraintsA = [combine(groupby(dfAdj, 1), 3 => mean)[!, 2], combine(groupby(dfAdj, 1), 3 => minimum)[!, 2], combine(groupby(dfAdj, 1), 3 => maximum)[!, 2]]

function recovAll(fileName)
#     p = plot(x, objectiveR[1], labels=["min " * string(KPerc[1]) "średnia " * string(KPerc[1]) "max " * string(KPerc[1])],
#     title="Wartość funkcji celu", c=:blue)
#     xlabel!(p, "Γ")
#     ylabel!(p, "wartość funkcji celu")
#     for i in 2:length(KPerc)
#         plot!(p, x, objectiveR[i], labels=["min " * string(KPerc[i]) "średnia " * string(KPerc[i]) "max " * string(KPerc[i])])
#     end
#     savefig(p, fileName * "_obj.png")
#
#     p = plot(x, timeR[1], labels=["min " * string(KPerc[1]) "średnia " * string(KPerc[1]) "max " * string(KPerc[1])], title="Czas")
#     xlabel!(p, "Γ")
#     ylabel!(p, "czas, s")
#     for i in 2:length(KPerc)
#         plot!(p, x, timeR[i], labels=["min " * string(KPerc[i]) "średnia " * string(KPerc[i]) "max " * string(KPerc[i])])
#     end
#     savefig(p, fileName * "_time.png")
#
#     p = plot(x, constraintsR[1], labels=["min " * string(KPerc[1]) "średnia " * string(KPerc[1]) "max " * string(KPerc[1])], title="Liczba naruszonych ograniczeń")
#     xlabel!(p, "Γ")
#     ylabel!(p, "naruszone ograniczenia, %")
#     for i in 2:length(KPerc)
#         plot!(p, x, timeR[i], labels=["min " * string(KPerc[i]) "średnia " * string(KPerc[i]) "max " * string(KPerc[i])])
#     end
#     savefig(p, fileName * "_constraints.png")
    p = plot(x, objectiveR[1][2], label="średnia " * string(KPerc[1]),
    title="Wartość funkcji celu", c=:blue)
    xlabel!(p, "Γ")
    ylabel!(p, "wartość funkcji celu")
    for i in 2:length(KPerc)
        plot!(p, x, objectiveR[i][2], label="średnia " * string(KPerc[i]))
    end
    savefig(p, fileName * "_obj.png")
    savefig(p, fileName * "_obj.pdf")

    p = plot(x, timeR[1][2], label="średnia " * string(KPerc[1]), title="Czas")
    xlabel!(p, "Γ")
    ylabel!(p, "czas, s")
    for i in 2:length(KPerc)
        plot!(p, x, timeR[i][2], label="średnia " * string(KPerc[i]))
    end
    savefig(p, fileName * "_time.png")
    savefig(p, fileName * "_time.pdf")

    p = plot(x, constraintsR[1][2], label="średnia " * string(KPerc[1]), title="Liczba naruszonych ograniczeń")
    xlabel!(p, "Γ")
    ylabel!(p, "naruszone ograniczenia, %")
    for i in 2:length(KPerc)
        plot!(p, x, constraintsR[i][2], label="średnia " * string(KPerc[i]))
    end
    savefig(p, fileName * "_constraints.png")
    savefig(p, fileName * "_constraints.pdf")
end

function lightAll(fileName)
#     p = plot(x, objectiveL[1], labels=["min " * string(rhos[1]) "średnia " * string(rhos[1]) "max " * string(rhos[1])], title="Wartość funkcji celu")
#     xlabel!(p, "Γ")
#     ylabel!(p, "wartość funkcji celu")
#     for i in 2:length(rhos)
#         plot!(p, x, objectiveL[i], labels=["min " * string(rhos[i]) "średnia " * string(rhos[i]) "max " * string(rhos[i])])
#     end
#     savefig(p, fileName * "_obj.png")
#
#     p = plot(x, timeL[1], labels=["min " * string(rhos[1]) "średnia " * string(rhos[1]) "max " * string(rhos[1])], title="Czas")
#     xlabel!(p, "Γ")
#     ylabel!(p, "czas, s")
#     for i in 2:length(rhos)
#         plot!(p, x, timeL[i], labels=["min " * string(rhos[i]) "średnia " * string(rhos[i]) "max " * string(rhos[i])])
#     end
#     savefig(p, fileName * "_time.png")
#
#     p = plot(x, constraintsL[1], labels=["min " * string(rhos[1]) "średnia " * string(rhos[1]) "max " * string(rhos[1])], title="Liczba naruszonych ograniczeń")
#     xlabel!(p, "Γ")
#     ylabel!(p, "naruszone ograniczenia, %")
#     for i in 2:length(rhos)
#         plot!(p, x, timeL[i], labels=["min " * string(rhos[i]) "średnia " * string(rhos[i]) "max " * string(rhos[i])])
#     end
#     savefig(p, fileName * "_constraints.png")

    p = plot(x, objectiveL[1][2], label="średnia " * string(rhos[1]), title="Wartość funkcji celu")
    xlabel!(p, "Γ")
    ylabel!(p, "wartość funkcji celu")
    for i in 2:length(rhos)
        plot!(p, x, objectiveL[i][2], label="średnia " * string(rhos[i]))
    end
    savefig(p, fileName * "_obj.png")
    savefig(p, fileName * "_obj.pdf")

    p = plot(x, timeL[1][2], label="średnia " * string(rhos[1]), title="Czas")
    xlabel!(p, "Γ")
    ylabel!(p, "czas, s")
    for i in 2:length(rhos)
        plot!(p, x, timeL[i][2], label="średnia " * string(rhos[i]))
    end
    savefig(p, fileName * "_time.png")
    savefig(p, fileName * "_time.pdf")

    p = plot(x, constraintsL[1][2], label="średnia " * string(rhos[1]), title="Liczba naruszonych ograniczeń")
    xlabel!(p, "Γ")
    ylabel!(p, "naruszone ograniczenia, %")
    for i in 2:length(rhos)
        plot!(p, x, timeL[i][2], label="średnia " * string(rhos[i]))
    end
    savefig(p, fileName * "_constraints.png")
    savefig(p, fileName * "_constraints.pdf")
end


function all(kperIdx, rhoIdx, fileName)
    # nominalny
    p = plot(x, [dfNom[!, 1] for i in 1:length(x)], label="Nom", title="Wartość funkcji celu")
    xlabel!(p, "Γ")
    ylabel!(p, "wartość funkcji celu")
    # worst
    plot!(p, x, objectiveW, labels=["min W" "średnia W" "max W"])
    # minmax
    plot!(p, x, objectiveMM, labels=["min MM" "średnia MM" "max MM"])
    # light
    plot!(p, x, objectiveL[rhoIdx], labels=["min L" * string(rhos[rhoIdx]) "średnia L" * string(rhos[rhoIdx]) "max L" * string(rhos[rhoIdx])])
    # recov
    plot!(p, x, objectiveR[kperIdx], labels=["min L" * string(rhos[kperIdx]) "średnia L" * string(rhos[kperIdx]) "max L" * string(rhos[kperIdx])])
    savefig(p, fileName * "_obj.png")
    savefig(p, fileName * "_obj.pdf")


    p = plot(x, [dfNom[!, 2] for i in 1:length(x)], label="Nom", title="Czas")
    xlabel!(p, "Γ")
    ylabel!(p, "czas, s")
    # worst
    plot!(p, x, timeW, labels=["min W" "średnia W" "max W"])
    # minmax
    plot!(p, x, timeMM, labels=["min MM" "średnia MM" "max MM"])
    # light
    plot!(p, x, timeL[rhoIdx], labels=["min L" * string(rhos[rhoIdx]) "średnia L" * string(rhos[rhoIdx]) "max L" * string(rhos[rhoIdx])])
    # recov
    plot!(p, x, timeR[kperIdx], labels=["min L" * string(rhos[kperIdx]) "średnia L" * string(rhos[kperIdx]) "max L" * string(rhos[kperIdx])])
    savefig(p, fileName * "_time.png")
    savefig(p, fileName * "_time.pdf")

    p = plot(x, constraintsMM, labels=["min MM" "średnia MM" "max MM"], title="Liczba naruszonych ograniczeń")
    xlabel!(p, "Γ")
    ylabel!(p, "naruszone ograniczenia, %")
    # light
    plot!(p, x, constraintsL[rhoIdx], labels=["min L" * string(rhos[rhoIdx]) "średnia L" * string(rhos[rhoIdx]) "max L" * string(rhos[rhoIdx])])
    # recov
    plot!(p, x, constraintsR[kperIdx], labels=["min L" * string(rhos[kperIdx]) "średnia L" * string(rhos[kperIdx]) "max L" * string(rhos[kperIdx])])
    savefig(p, fileName * "_time.png")
    savefig(p, fileName * "_time.pdf")

    # TODO adjustable
end

recovAll("t1_recov")
lightAll("t1_light")


