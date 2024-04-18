using Plots, CSV, DataFrames, DelimitedFiles, Statistics

# # data = readdlm("./test1_minmax.txt", ' ', header=false);
# df = DataFrame(CSV.File("./test1_minmax.txt", deli=" "))

df = CSV.read("./test1_minmax.txt", DataFrame, delim=" ")

objective = combine(groupby(df, 1), 2 => sum)
time = combine(groupby(df, 1), 4 => sum)
constraints = combine(groupby(df, 1), 3 => sum)