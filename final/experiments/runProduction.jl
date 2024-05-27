include("./productionInventory.jl")
include("./draw.jl")
include("./statTests.jl")

redirect_stdout(open("/dev/null", "w"))

fileName = "test4"
# (fileName, steps, Gammas, per, rhos, T, n)
# test("test4", 10, [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0],
# 0.7, [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0], 24, 5)
drawProd(fileName, "t4", 2, 5)
statProd(fileName)
redirect_stdout(stdout)