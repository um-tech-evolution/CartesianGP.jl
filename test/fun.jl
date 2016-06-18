context("fun.jl") do
  context("built-in functions") do
    context("ZERO") do
      @fact ZERO() --> UInt128(0)
    end

    context("ONE") do
      @fact ONE() --> ~UInt128(0)
    end

    context("AND") do
      @fact AND(ZERO(), ZERO()) --> ZERO()
      @fact AND(ONE(), ZERO()) --> ZERO()
      @fact AND(ZERO(), ONE()) --> ZERO()
      @fact AND(ONE(), ONE()) --> ONE()
    end

    context("OR") do
      @fact OR(ZERO(), ZERO()) --> ZERO()
      @fact OR(ONE(), ZERO()) --> ONE()
      @fact OR(ZERO(), ONE()) --> ONE()
      @fact OR(ONE(), ONE()) --> ONE()
    end

    context("XOR") do
      @fact XOR(ZERO(), ZERO()) --> ZERO()
      @fact XOR(ONE(), ZERO()) --> ONE()
      @fact XOR(ZERO(), ONE()) --> ONE()
      @fact XOR(ONE(), ONE()) --> ZERO()
    end

    context("NAND") do
      @fact NAND(ZERO(), ZERO()) --> ONE()
      @fact NAND(ONE(), ZERO()) --> ONE()
      @fact NAND(ZERO(), ONE()) --> ONE()
      @fact NAND(ONE(), ONE()) --> ZERO()
    end

    context("NOR") do
      @fact NOR(ZERO(), ZERO()) --> ONE()
      @fact NOR(ONE(), ZERO()) --> ZERO()
      @fact NOR(ZERO(), ONE()) --> ZERO()
      @fact NOR(ONE(), ONE()) --> ZERO()
    end

    context("NOT") do
      @fact NOT(ZERO()) --> ONE()
      @fact NOT(ONE()) --> ZERO()
    end
  end

  context("custom function") do
    context("and3") do
    and3 = Fun((x, y, z) -> x & y & z, 3, "AND3")
      @fact and3(ZERO(), ZERO(), ZERO()) --> ZERO()
      @fact and3(ZERO(), ZERO(), ONE()) --> ZERO()
      @fact and3(ZERO(), ONE(), ZERO()) --> ZERO()
      @fact and3(ZERO(), ONE(), ONE()) --> ZERO()
      @fact and3(ONE(), ZERO(), ZERO()) --> ZERO()
      @fact and3(ONE(), ZERO(), ONE()) --> ZERO()
      @fact and3(ONE(), ONE(), ZERO()) --> ZERO()
      @fact and3(ONE(), ONE(), ONE()) --> ONE()
    end
  end
end
