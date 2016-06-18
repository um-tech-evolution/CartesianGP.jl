using CartesianGP
using FactCheck

facts("CartesianGP") do
  include("fun.jl")

  context("goal/") do
    include("goal/abstractgoal.jl")
  end
end

