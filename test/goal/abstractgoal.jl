context("abstractgoal.jl") do
  context("stdctx") do
    g1 = BasicGoal(1, 1)
    g2 = BasicGoal(2, 1)
    g3 = BasicGoal(3, 1)

    context("1 input") do
      ctx = stdctx(g1)
      @fact length(ctx) --> 1
      @fact ctx[1] --> BitString(0b10)
    end

    context("2 input") do
      ctx = stdctx(g2)
      @fact length(ctx) --> 2
      @fact ctx[1] --> BitString(0b1100)
      @fact ctx[2] --> BitString(0b1010)
    end

    context("3 input") do
      ctx = stdctx(g3)
      @fact length(ctx) --> 3
      @fact ctx[1] --> BitString(0b11110000)
      @fact ctx[2] --> BitString(0b11001100)
      @fact ctx[3] --> BitString(0b10101010)
    end
  end
end
