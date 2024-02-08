using JuMPeR

n           = 3
weight_low  = [1.0, 3.0, 2.0]
weight_high = [3.0, 9.0, 6.0]
values      = [5.0, 6.0, 4.0]

# Create the model...
m = RobustModel()
# ... and set all constraints to use the Bertsimas-Sim set
setDefaultOracle!(m, BertSimOracle(1))

# Setup our problem
@defVar(m, x[1:n], Bin)
@defUnc(m, weight_low[i] <= u[i=1:n] <= weight_high[i])
@setObjective(m, Max, sum{values[i] * x[i], i=1:n})

# Notice we haven't provided an explicit uncertainty set,
# apart from the ranges on the uncertain values?
# The BertSimOracle looks at the range, and treats the
# nominal value for each uncertain parameter as the
# midpoint of the range. The parameter we passed is the
# number of uncertain parameters that can deviate from
# this nominal value. In other words:
#   |u - 4|/1  +  |u - 6|/3  +  |u - 4|/2  <=  1
#   |u - 4|/1  <=  1
#   |u - 6|/3  <=  1
#   |u - 4|/2  <=  1
@addConstraint(m, sum{u[i]*x[i], i=1:n} <= 8)

solve(m, prefer_cuts=true)