module robustOpt
    export minmax, maxmin, recoverableMin, lightRobustnessMin, lightRobustnessMax
    using JuMP
    using Cbc

    include("./minmax.jl")
    include("./recoverable.jl")
    include("./lightRobustness.jl")

end