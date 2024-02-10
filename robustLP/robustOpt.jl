module robustOpt
    using JuMP
    using Cbc

    include("./minmax.jl")
    include("./recoverable.jl")
    include("./lightRobustness.jl")
end