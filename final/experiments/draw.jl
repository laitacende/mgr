using Plots, CSV, DataFrames, DelimitedFiles, Statistics
using LaTeXStrings

function adjAll(fileName, objectiveA, timeA, constraintsA, x)
    p = plot(x, objectiveA[1][2], label="średnia " * namesHist[1],
    title="Wartość funkcji celu")
    xlabel!(p, "Γ")
    ylabel!(p, "wartość funkcji celu")
    for i in 2:length(hist)
        plot!(p, x, objectiveA[i][2], label="średnia " * namesHist[i])
    end
    savefig(p, fileName * "_obj.png")
    savefig(p, fileName * "_obj.pdf")

    p = plot(x, timeA[1][2], label="średnia " * namesHist[1], title="Czas" )
    xlabel!(p, "Γ")
    ylabel!(p, "czas, s")
    for i in 2:length(namesHist)
        plot!(p, x, timeA[i][2], label="średnia " * namesHist[i])
    end
    savefig(p, fileName * "_time.png")
    savefig(p, fileName * "_time.pdf")

    p = plot(x, constraintsA[1][2], label="średnia " * namesHist[1],
    title="Liczba naruszonych ograniczeń" )
    xlabel!(p, "Γ")
    ylabel!(p, "naruszone ograniczenia, %")
    for i in 2:length(namesHist)
     if namesHist[i] != "all" && namesHist[i] != "1" && namesHist[i] != "0"
        plot!(p, x, constraintsA[i][2], label="średnia " * namesHist[i])
        end
    end
    savefig(p, fileName * "_constraints.png")
    savefig(p, fileName * "_constraints.pdf")
end

function recovAll(fileName, objectiveR, timeR, constraintsR, KPerc, x)
    p = plot(x, objectiveR[1][2], label="średnia K=" * string(KPerc[1]),
    title="Wartość funkcji celu")
    xlabel!(p, "Γ")
    ylabel!(p, "wartość funkcji celu")
    for i in 2:length(KPerc)
        plot!(p, x, objectiveR[i][2], label="średnia K=" * string(KPerc[i]))
    end
    savefig(p, fileName * "_obj.png")
    savefig(p, fileName * "_obj.pdf")

    p = plot(x, timeR[1][2], label="średnia K=" * string(KPerc[1]), title="Czas" )
    xlabel!(p, "Γ")
    ylabel!(p, "czas, s")
    for i in 2:length(KPerc)
        plot!(p, x, timeR[i][2], label="średnia K=" * string(KPerc[i]))
    end
    savefig(p, fileName * "_time.png")
    savefig(p, fileName * "_time.pdf")

    p = plot(x, constraintsR[1][2], label="średnia K=" * string(KPerc[1]),
    title="Liczba naruszonych ograniczeń" )
    xlabel!(p, "Γ")
    ylabel!(p, "naruszone ograniczenia, %")
    for i in 2:length(KPerc)
        plot!(p, x, constraintsR[i][2], label="średnia K=" * string(KPerc[i]))
    end
    savefig(p, fileName * "_constraints.png")
    savefig(p, fileName * "_constraints.pdf")
end

function recovAllInf(fileName, objectiveRInf, timeRInf, constraintsRInf, KPerc, x)
    p = plot(x, objectiveRInf[1][2], label="średnia K=" * string(KPerc[1]),
    title="Wartość funkcji celu")
    xlabel!(p, "Γ")
    ylabel!(p, "wartość funkcji celu")
    for i in 2:length(KPerc)
        plot!(p, x, objectiveRInf[i][2], label="średnia K=" * string(KPerc[i]))
    end
    savefig(p, fileName * "_obj.png")
    savefig(p, fileName * "_obj.pdf")

    p = plot(x, timeRInf[1][2], label="średnia K=" * string(KPerc[1]), title="Czas" )
    xlabel!(p, "Γ")
    ylabel!(p, "czas, s")
    for i in 2:length(KPerc)
        plot!(p, x, timeRInf[i][2], label="średnia K=" * string(KPerc[i]))
    end
    savefig(p, fileName * "_time.png")
    savefig(p, fileName * "_time.pdf")

    p = plot(x, constraintsRInf[1][2], label="średnia K=" * string(KPerc[1]),
    title="Liczba naruszonych ograniczeń" )
    xlabel!(p, "Γ")
    ylabel!(p, "naruszone ograniczenia, %")
    for i in 2:length(KPerc)
        plot!(p, x, constraintsRInf[i][2], label="średnia K=" * string(KPerc[i]))
    end
    savefig(p, fileName * "_constraints.png")
    savefig(p, fileName * "_constraints.pdf")
end

function lightAll(fileName, objectiveL, timeL, constraintsL, rhos, x)
    p = plot(x, [objectiveL[i][2] for i in 1:length(rhos)],
    labels=reshape(["średnia ρ=" * string(rhos[i]) for i in 1:length(rhos)], (1, length(rhos))) , title="Wartość funkcji celu")
    xlabel!(p, "Γ")
    ylabel!(p, "wartość funkcji celu")
    savefig(p, fileName * "_obj.png")
    savefig(p, fileName * "_obj.pdf")

    p = plot(x, timeL[1][2], label="średnia ρ=" * string(rhos[1]), title="Czas" )
    xlabel!(p, "Γ")
    ylabel!(p, "czas, s")
    for i in 2:length(rhos)
        plot!(p, x, timeL[i][2], label="średnia ρ=" * string(rhos[i]) )
    end
    savefig(p, fileName * "_time.png")
    savefig(p, fileName * "_time.pdf")

    p = plot(x, constraintsL[1][2], label="średnia ρ=" * string(rhos[1]), title="Liczba naruszonych ograniczeń",)
    xlabel!(p, "Γ")
    ylabel!(p, "naruszone ograniczenia, %")
    for i in 2:length(rhos)
        plot!(p, x, constraintsL[i][2], label="średnia ρ=" * string(rhos[i]) )
    end
    savefig(p, fileName * "_constraints.png")
    savefig(p, fileName * "_constraints.pdf")
end


function all(kperIdx, rhoIdx, fileName, dfNom, objectiveW, timeW,
    objectiveMM, timeMM, constraintsMM, objectiveR, timeR, constraintsR,
    objectiveRInf, timeRInf, constraintsRInf, objectiveL, timeL, constraintsL, KPerc, rhos, x)
    # nominalny
    p = plot([0.0, 1.0], [dfNom[!, 1][1], dfNom[!, 1][1]], label="Nom", title="Wartość funkcji celu", c=:turquoise, legend=:bottomright)
    xlabel!(p, "Γ")
    ylabel!(p, "wartość funkcji celu")
    # worst
    plot!(p, [0.0, 1.0], [objectiveW[1], objectiveW[1]], label="min W", c=:palevioletred1)
    plot!(p, [0.0, 1.0], [objectiveW[2], objectiveW[2]], label="średnia W", c=:deeppink2)
    plot!(p, [0.0, 1.0], [objectiveW[3], objectiveW[3]], label="max W", c=:violetred4)
    # minmax
    plot!(p, x, objectiveMM, labels=["min MM" "średnia MM" "max MM"], c=[:skyblue2 :dodgerblue2 :midnightblue])
    # light
    plot!(p, x, objectiveL[rhoIdx],
    labels=["min L ρ=" * string(rhos[rhoIdx]) "średnia L ρ=" * string(rhos[rhoIdx]) "max L ρ=" * string(rhos[rhoIdx])],
    c=[:olivedrab1 :limegreen :darkgreen])
    # recov
    plot!(p, x, objectiveR[kperIdx],
    labels=["min R K=" * string(KPerc[kperIdx]) "średnia R K=" * string(KPerc[kperIdx]) "max R K=" * string(KPerc[kperIdx])],
    c=[:coral1 :red1 :darkred])
    # recov inf
    plot!(p, x, objectiveRInf[kperIdx],
    labels=["min RInf K=" * string(KPerc[kperIdx]) "średnia RInf K=" * string(KPerc[kperIdx]) "max RInf K=" * string(KPerc[kperIdx])],
    c=[:gray65 :gray27 :gray6])
    savefig(p, fileName * "_obj.png")
    savefig(p, fileName * "_obj.pdf")

    p = plot([0.0, 1.0], [dfNom[!, 2][1], dfNom[!, 2][1]], label="Nom", title="Czas", c=:turquoise, legend=:bottomright)
    xlabel!(p, "Γ")
    ylabel!(p, "czas, s")
    # worst
    plot!(p, [0.0, 1.0], [timeW[1], timeW[1]], label="min W", c=:palevioletred1)
    plot!(p, [0.0, 1.0], [timeW[2], timeW[2]], label="średnia W", c=:deeppink2)
    plot!(p, [0.0, 1.0], [timeW[3], timeW[3]], label="max W", c=:violetred4)
#     minmax
    plot!(p, x, timeMM, labels=["min MM" "średnia MM" "max MM"], c=[:skyblue2 :dodgerblue2 :midnightblue])
    # light
    plot!(p, x, timeL[rhoIdx],
    labels=["min L ρ=" * string(rhos[rhoIdx]) "średnia L ρ=" * string(rhos[rhoIdx]) "max L ρ=" * string(rhos[rhoIdx])],
    c=[:olivedrab1 :limegreen :darkgreen])
    # recov
    plot!(p, x, timeR[kperIdx],
    labels=["min R K=" * string(KPerc[kperIdx]) "średnia R K=" * string(KPerc[kperIdx]) "max R K=" * string(KPerc[kperIdx])],
    c=[:coral1 :red1 :darkred])
    # recov Inf
    plot!(p, x, timeRInf[kperIdx],
    labels=["min RInf K=" * string(KPerc[kperIdx]) "średnia RInf K=" * string(KPerc[kperIdx]) "max RInf K=" * string(KPerc[kperIdx])],
    c=[:gray65 :gray27 :gray6])
    savefig(p, fileName * "_time.png")
    savefig(p, fileName * "_time.pdf")

    p = plot(x, constraintsMM, labels=["min MM" "średnia MM" "max MM"], title="Liczba naruszonych ograniczeń",
    c=[:skyblue2 :dodgerblue2 :midnightblue], legend=:bottomright)
    xlabel!(p, "Γ")
    ylabel!(p, "naruszone ograniczenia, %")
    # light
    plot!(p, x, constraintsL[rhoIdx],
    labels=["min L ρ=" * string(rhos[rhoIdx]) "średnia L ρ=" * string(rhos[rhoIdx]) "max L ρ=" * string(rhos[rhoIdx])],
    c=[:olivedrab1 :limegreen :darkgreen])
    # recov
    plot!(p, x, constraintsR[kperIdx],
    labels=["min R K=" * string(KPerc[kperIdx]) "średnia R K=" * string(KPerc[kperIdx]) "max R K=" * string(KPerc[kperIdx])],
     c=[:coral1 :red1 :darkred])
     # recov Inf
     plot!(p, x, constraintsRInf[kperIdx],
    labels=["min RInf K=" * string(KPerc[kperIdx]) "średnia RInf K=" * string(KPerc[kperIdx]) "max RInf K=" * string(KPerc[kperIdx])],
     c=[:gray65 :gray27 :gray6])
    savefig(p, fileName * "_constraints.png")
    savefig(p, fileName * "_constraints.pdf")
end

function allAdj(rhoIdx, adjIdx, fileName, dfNom, objectiveW, timeW,
    objectiveMM, timeMM, constraintsMM, objectiveA, timeA, constraintsA,
     objectiveL, timeL, constraintsL, rhos, namesHist, x)
 # nominalny
    p = plot([0.0, 1.0], [dfNom[!, 1][1], dfNom[!, 1][1]], label="Nom", title="Wartość funkcji celu", c=:turquoise, legend=:topleft)
    xlabel!(p, "Γ")
    ylabel!(p, "wartość funkcji celu")
    # worst
    plot!(p, [0.0, 1.0], [objectiveW[1], objectiveW[1]], label="min W", c=:palevioletred1)
    plot!(p, [0.0, 1.0], [objectiveW[2], objectiveW[2]], label="średnia W", c=:deeppink2)
    plot!(p, [0.0, 1.0], [objectiveW[3], objectiveW[3]], label="max W", c=:violetred4)
    # minmax
    plot!(p, x, objectiveMM, labels=["min MM" "średnia MM" "max MM"], c=[:skyblue2 :dodgerblue2 :midnightblue])
    # light
    plot!(p, x, objectiveL[rhoIdx],
    labels=["min L ρ=" * string(rhos[rhoIdx]) "średnia L ρ=" * string(rhos[rhoIdx]) "max L ρ=" * string(rhos[rhoIdx])],
    c=[:olivedrab1 :limegreen :darkgreen])

    # adjustable
    plot!(p, x, objectiveA[adjIdx],
    labels=["min A " * namesHist[adjIdx] "średnia A" * namesHist[adjIdx] "max A " * namesHist[adjIdx]], c=[:coral1 :red1 :darkred])

    savefig(p, fileName * "_obj.png")
    savefig(p, fileName * "_obj.pdf")

    p = plot([0.0, 1.0], [dfNom[!, 2][1], dfNom[!, 2][1]], label="Nom", title="Czas", c=:turquoise, legend=:topleft)
    xlabel!(p, "Γ")
    ylabel!(p, "czas, s")
    # worst
    plot!(p, [0.0, 1.0], [timeW[1], timeW[1]], label="min W", c=:palevioletred1)
    plot!(p, [0.0, 1.0], [timeW[2], timeW[2]], label="średnia W", c=:deeppink2)
    plot!(p, [0.0, 1.0], [timeW[3], timeW[3]], label="max W", c=:violetred4)
#     minmax
    plot!(p, x, timeMM, labels=["min MM" "średnia MM" "max MM"], c=[:skyblue2 :dodgerblue2 :midnightblue])
    # light
    plot!(p, x, timeL[rhoIdx],
    labels=["min L ρ=" * string(rhos[rhoIdx]) "średnia L ρ=" * string(rhos[rhoIdx]) "max L ρ=" * string(rhos[rhoIdx])],
    c=[:olivedrab1 :limegreen :darkgreen])
    # adjustable
    plot!(p, x, timeA[adjIdx],
    labels=["min A " * namesHist[adjIdx]  "średnia A "* namesHist[adjIdx] "max A "* namesHist[adjIdx]],
    c=[:coral1 :red1 :darkred])

    savefig(p, fileName * "_time.png")
    savefig(p, fileName * "_time.pdf")

    p = plot(x, constraintsMM, labels=["min MM" "średnia MM" "max MM"], title="Liczba naruszonych ograniczeń",
    c=[:skyblue2 :dodgerblue2 :midnightblue], legend=:topleft)
    xlabel!(p, "Γ")
    ylabel!(p, "naruszone ograniczenia, %")
    # light
    plot!(p, x, constraintsL[rhoIdx],
    labels=["min L ρ=" * string(rhos[rhoIdx]) "średnia L ρ=" * string(rhos[rhoIdx]) "max L ρ=" * string(rhos[rhoIdx])],
    c=[:olivedrab1 :limegreen :darkgreen])
    # adjustable
    plot!(p, x, constraintsA[adjIdx],
    labels=["min A " * namesHist[adjIdx] "średnia A " * namesHist[adjIdx] "max A " * namesHist[adjIdx]],
     c=[:coral1 :red1 :darkred])
    savefig(p, fileName * "_constraints.png")
    savefig(p, fileName * "_constraints.pdf")
end

function drawFlow(fileName, fileNameOut, kperIdx, rhoIdx)
    # read data
    dfNom = CSV.read("./" * fileName * "_nom.txt", DataFrame, delim=" ", header=false)
    dfLight = CSV.read("./" * fileName * "_light.txt", DataFrame, delim=" ", header=false)
    dfWorst = CSV.read("./" * fileName * "_nomWorst.txt", DataFrame, delim=" ", header=false)
    dfRecov = CSV.read("./" * fileName * "_recov.txt", DataFrame, delim=" ", header=false)
    dfRecovInf = CSV.read("./" * fileName * "_recov_inf.txt", DataFrame, delim=" ", header=false)
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
    KPerc =  [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
    objectiveR = []
    timeR = []
    constraintsR = []
    for i in 1:length(KPerc)
        append!(objectiveR, [[combine(groupby(dfRecov, 1), 4*(i - 1) + 2 => minimum)[!, 2], combine(groupby(dfRecov, 1), 4*(i - 1) + 2 => mean)[!, 2], combine(groupby(dfRecov, 1), 4*(i - 1) + 2 => maximum)[!, 2]]])
        append!(timeR, [[combine(groupby(dfRecov, 1), 4*(i - 1) + 4 => minimum)[!, 2], combine(groupby(dfRecov, 1), 4*(i - 1) + 4 => mean)[!, 2], combine(groupby(dfRecov, 1), 4*(i - 1) + 4 => maximum)[!, 2]]])
        append!(constraintsR, [[combine(groupby(dfRecov, 1), 4*(i - 1) + 3 => minimum)[!, 2], combine(groupby(dfRecov, 1), 4*(i - 1) + 3 => mean)[!, 2], combine(groupby(dfRecov, 1), 4*(i - 1) + 3 => maximum)[!, 2]]])
    end

    objectiveRInf = []
    timeRInf = []
    constraintsRInf = []
    for i in 1:length(KPerc)
        append!(objectiveRInf, [[combine(groupby(dfRecovInf, 1), 4*(i - 1) + 2 => minimum)[!, 2], combine(groupby(dfRecovInf, 1), 4*(i - 1) + 2 => mean)[!, 2], combine(groupby(dfRecovInf, 1), 4*(i - 1) + 2 => maximum)[!, 2]]])
        append!(timeRInf, [[combine(groupby(dfRecovInf, 1), 4*(i - 1) + 4 => minimum)[!, 2], combine(groupby(dfRecovInf, 1), 4*(i - 1) + 4 => mean)[!, 2], combine(groupby(dfRecovInf, 1), 4*(i - 1) + 4 => maximum)[!, 2]]])
        append!(constraintsRInf, [[combine(groupby(dfRecovInf, 1), 4*(i - 1) + 3 => minimum)[!, 2], combine(groupby(dfRecovInf, 1), 4*(i - 1) + 3 => mean)[!, 2], combine(groupby(dfRecovInf, 1), 4*(i - 1) + 3 => maximum)[!, 2]]])
    end

    # light robustness
    rhos = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
    objectiveL = []
    timeL = []
    constraintsL = []
    for i in 1:length(rhos)
        append!(objectiveL, [[combine(groupby(dfLight, 1), 4*(i - 1) + 2 => minimum)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 2 => mean)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 2 => maximum)[!, 2]]])
        append!(timeL, [[combine(groupby(dfLight, 1), 4*(i - 1) + 4 => minimum)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 4 => mean)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 4 => maximum)[!, 2]]])
        append!(constraintsL, [[combine(groupby(dfLight, 1), 4*(i - 1) + 3 => minimum)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 3 => mean)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 3 => maximum)[!, 2]]])
    end

    recovAll(fileNameOut * "_recov", objectiveR, timeR, constraintsR, KPerc, x)
    recovAllInf(fileNameOut * "_recov_inf", objectiveRInf, timeRInf, constraintsRInf, KPerc, x)
    lightAll(fileNameOut * "_light", objectiveL, timeL, constraintsL, rhos, x)
    all(kperIdx, rhoIdx, fileNameOut,  dfNom, objectiveW, timeW,
    objectiveMM, timeMM, constraintsMM, objectiveR, timeR, constraintsR,
    objectiveRInf, timeRInf, constraintsRInf, objectiveL, timeL, constraintsL, KPerc, rhos, x)
end

function drawProd(fileName, fileNameOut, rhoIdx, adjIdx)
    dfNom = CSV.read("./" * fileName * "_nom.txt", DataFrame, delim=" ", header=false)
    dfLight = CSV.read("./" * fileName * "_light.txt", DataFrame, delim=" ", header=false)
    dfAdj = CSV.read("./" * fileName * "_adj.txt", DataFrame, delim=" ", header=false)
    dfWorst = CSV.read("./" * fileName * "_nomWorst.txt", DataFrame, delim=" ", header=false)
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

    # light robustness
    rhos = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
    objectiveL = []
    timeL = []
    constraintsL = []
    for i in 1:length(rhos)
        append!(objectiveL, [[combine(groupby(dfLight, 1), 4*(i - 1) + 2 => minimum)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 2 => mean)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 2 => maximum)[!, 2]]])
        append!(timeL, [[combine(groupby(dfLight, 1), 4*(i - 1) + 4 => minimum)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 4 => mean)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 4 => maximum)[!, 2]]])
        append!(constraintsL, [[combine(groupby(dfLight, 1), 4*(i - 1) + 3 => minimum)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 3 => mean)[!, 2], combine(groupby(dfLight, 1), 4*(i - 1) + 3 => maximum)[!, 2]]])
    end

    # adj
    hist = [8, 4, 1, 0, 10, -10]
    namesHist = ["7", "3", "1", "0", "past", "all"]
    objectiveA = []
    timeA = []
    constraintsA = []
    for i in 1:length(hist)
        append!(objectiveA, [[combine(groupby(dfAdj, 1), 4*(i-1) + 2 => minimum)[!, 2], combine(groupby(dfAdj, 1), 4*(i-1) + 2 => mean)[!, 2], combine(groupby(dfAdj, 1), 4*(i-1) + 2 => maximum)[!, 2]]])
        append!(timeA, [[combine(groupby(dfAdj, 1), 4*(i-1) + 4 => minimum)[!, 2], combine(groupby(dfAdj, 1), 4*(i-1) + 4 => mean)[!, 2], combine(groupby(dfAdj, 1), 4*(i-1) + 4 => maximum)[!, 2]]])
        append!(constraintsA, [[combine(groupby(dfAdj, 1), 4*(i-1) + 3 => minimum)[!, 2], combine(groupby(dfAdj, 1), 4*(i-1) + 3 => mean)[!, 2], combine(groupby(dfAdj, 1), 4*(i-1) + 3 => maximum)[!, 2]]])
    end

    lightAll(fileNameOut * "_light", objectiveL, timeL, constraintsL, rhos, x)
    adjAll(fileNameOut * "_adj", objectiveA, timeA, constraintsA, namesHist, x)
    allAdj(rhoIdx, adjIdx, fileNameOut, objectiveW, timeW,
    objectiveMM, timeMM, constraintsMM, objectiveA, timeA, constraintsA,
     objectiveL, timeL, constraintsL, rhos, namesHist, x)
end


