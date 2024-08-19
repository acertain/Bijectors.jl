#######################################################
# Constrained to unconstrained distribution bijectors #
#######################################################
struct TruncatedBijector{T1,T2} <: Bijector
    lb::T1
    ub::T2
end

Functors.@functor TruncatedBijector

function Base.:(==)(b1::TruncatedBijector, b2::TruncatedBijector)
    return b1.lb == b2.lb && b1.ub == b2.ub
end

function transform(b::TruncatedBijector, x)
    a, b = b.lb, b.ub
    return truncated_link.(_clamp.(x, a, b), a, b)
end

function truncated_link(x::Real, a, b)
    lowerbounded, upperbounded = isfinite(a), isfinite(b)
    if lowerbounded && upperbounded
        return LogExpFunctions.logit((x - a) / (b - a))
    elseif lowerbounded
        return log(x - a)
    elseif upperbounded
        return log(b - x)
    else
        return x
    end
end

function transform(ib::Inverse{<:TruncatedBijector}, y)
    a, b = ib.orig.lb, ib.orig.ub
    return _clamp.(truncated_invlink.(y, a, b), a, b)
end

function truncated_invlink(y, a, b)
    lowerbounded, upperbounded = isfinite(a), isfinite(b)
    if lowerbounded && upperbounded
        return (b - a) * LogExpFunctions.logistic(y) + a
    elseif lowerbounded
        return exp(y) + a
    elseif upperbounded
        return b - exp(y)
    else
        return y
    end
end

function logabsdetjac(b::TruncatedBijector, x)
    a, b = b.lb, b.ub
    return sum(truncated_logabsdetjac.(_clamp.(x, a, b), a, b))
end

function truncated_logabsdetjac(x, a, b)
    lowerbounded, upperbounded = isfinite(a), isfinite(b)
    if lowerbounded && upperbounded
        return -log((x - a) * (b - x) / (b - a))
    elseif lowerbounded
        return -log(x - a)
    elseif upperbounded
        return -log(b - x)
    else
        return zero(x)
    end
end

with_logabsdet_jacobian(b::TruncatedBijector, x) = transform(b, x), logabsdetjac(b, x)

function truncated_inv_logabsdetjac(y, a, b)
    y, a, b = promote(y, a, b)
    lowerbounded, upperbounded = isfinite(a), isfinite(b)
    if lowerbounded && upperbounded
        return log(b - a) + y - 2 * LogExpFunctions.log1pexp(y)
    elseif lowerbounded || upperbounded
        return y
    else
        return zero(y)
    end
end

function logabsdetjac(ib::Inverse{<:TruncatedBijector}, y)
    a, b = ib.orig.lb, ib.orig.ub
    return sum(truncated_inv_logabsdetjac.(y, a, b))
end

function with_logabsdet_jacobian(ib::Inverse{<:TruncatedBijector}, y)
    return transform(ib, y), logabsdetjac(ib, y)
end

# It's only monotonically decreasing if it's only upper-bounded.
# In the multivariate case, we can only say something reasonable if entries are monotonic.
function is_monotonically_increasing(b::TruncatedBijector)
    lowerbounded, upperbounded = all(isfinite, b.lb), all(isfinite, b.ub)
    return if lowerbounded
        true
    elseif upperbounded
        # => decreasing
        false
    elseif all(!isfinite, b.lb) && all(!isfinite, b.ub)
        # => all are unbounded so we have the identity
        true
    else
        # => some are unbounded and some are bounded
        false
    end
end
function is_monotonically_decreasing(b::TruncatedBijector)
    lowerbounded, upperbounded = all(isfinite, b.lb), all(isfinite, b.ub)
    return if lowerbounded
        false
    elseif upperbounded
        # => decreasing
        true
    elseif all(!isfinite, b.lb) && all(!isfinite, b.ub)
        # => all are unbounded so we have the identity
        false
    else
        # => some are unbounded and some are bounded
        true
    end
end
