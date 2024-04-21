module robustOpt
    export minmax, maxmin, recoverableMin, lightRobustnessMin, lightRobustnessMax, recoverableMinInf,
    lightRobustnessMinOpt, lightRobustnessMaxOpt
    using JuMP, Cbc, SparseArrays

    include("./minmax.jl")
    include("./recoverable.jl")
    include("./lightRobustness.jl")
    include("./nominal.jl")

end