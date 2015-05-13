using CGP

numlevels = 5
raman_funcs = [AND, OR, XOR, NAND, NOR]

function Params(numinputs, numoutputs, numperlevel, numlevels, numlevelsback, mutrate, funcs )
    mu = 1
    lambda = 4
    targetfitness = 1.0
    fitfunc = hamming_max

    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs, fitfunc)
end

p = Params(3,1,1,numlevels,numlevels,0.05,raman_funcs)

X0 = convert(BitString,0x0)
XF = convert(BitString,0xF)
XFF = convert(BitString,0xFF)

goal_list2 = [Goal(2,(tt,)) for tt in [X0:XF]]
goal_list3 = [Goal(3,(tt,)) for tt in [X0:XFF]]
