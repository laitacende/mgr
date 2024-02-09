module robustOpt
    using JuMP
    using Cbc

    include("./minmax.jl")
    include("./recoverable.jl")
end