using Bijectors

using ChainRulesTestUtils
using Combinatorics
using DistributionsAD
using Enzyme
using FiniteDifferences
using ForwardDiff
using Functors
using LogExpFunctions
using ReverseDiff
using Tracker
using Zygote

using Random, LinearAlgebra, Test

using Bijectors:
    Shift,
    Scale,
    Logit,
    SimplexBijector,
    PDBijector,
    Permute,
    PlanarLayer,
    RadialLayer,
    Stacked,
    TruncatedBijector

using ChangesOfVariables: ChangesOfVariables
using InverseFunctions: InverseFunctions
using LazyArrays: LazyArrays

if VERSION < v"1.9"
    using Compat: stack
end

# Sadly, Mooncake.jl cannot be installed on version 1.6, so we have to add it if we're testing
# on at least version 1.10.
if VERSION >= v"1.10"
    using Pkg
    Pkg.add("Mooncake")
    using Mooncake
end

const GROUP = get(ENV, "GROUP", "All")

# Always include this since it can be useful for other tests.
include("ad/utils.jl")
include("bijectors/utils.jl")

if GROUP == "All" || GROUP == "Interface"
    include("interface.jl")
    include("transform.jl")
    include("norm_flows.jl")
    include("bijectors/permute.jl")
    include("bijectors/rational_quadratic_spline.jl")
    include("bijectors/named_bijector.jl")
    include("bijectors/leaky_relu.jl")
    include("bijectors/coupling.jl")
    include("bijectors/ordered.jl")
    include("bijectors/pd.jl")
    include("bijectors/reshape.jl")
    include("bijectors/corr.jl")
    include("bijectors/product_bijector.jl")

    include("distributionsad.jl")
end

if GROUP == "All" || GROUP == "AD"
    include("ad/chainrules.jl")
    include("ad/flows.jl")
    include("ad/pd.jl")
    include("ad/corr.jl")
    include("ad/stacked.jl")
end
