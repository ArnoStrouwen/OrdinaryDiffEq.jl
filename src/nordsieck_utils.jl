# This function computes the integral, from -1 to 0, of a polynomial
# `P(x)` from the coefficients of `P` with a offset `k`.
function ∫₋₁⁰dx(a, deg, k)
  @inbounds begin
    int = zero(eltype(a))
    sign = one(eltype(a))
    for i in 1:deg
      int += sign * a[i]/(i+k)
      sign = -sign
    end
    return int
  end
end

# `l` is the coefficients of the polynomial `Λ` that satisfies conditions
# Λ(0) = 1, Λ(-1) = 0, and Λ̇(-ξᵢ) = 0, where ξᵢ = (tₙ-tₙ₋₁)/dt
function calc_coeff!(cache)
  @inbounds begin
    @unpack m, l, tau = cache
    ZERO, ONE = zero(m[1]), one(m[1])
    dtsum = dt = tau[1]
    order = length(l) - 1
    m[1] = ONE
    for i in 2:order+1
      m[i] = ZERO
    end
    for j in 1:order-1
      ξ_inv = dt / dtsum
      for i in j:-1:1
        m[i+1] += m[i] * ξ_inv
      end
      dtsum += tau[j+1]
    end

    M0 = ∫₋₁⁰dx(m, order, 0)
    M1 = ∫₋₁⁰dx(m, order, 1)
    M0_inv = inv(M0)
    l[1] = ONE
    for i in 1:order
      l[i+1] = M0_inv * m[i] / i
    end
    cache.tq = M1 * M0_inv * ξ_inv
  end
end
