using CGP
using Base.Test

p = default_parameters()
g = goal_half_adder()
n = 10
perf = 1.0

# TODO: Add correctness tests
mu_lambda(p, g, n, perf)

