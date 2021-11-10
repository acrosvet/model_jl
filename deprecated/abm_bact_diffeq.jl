
using DifferentialEquations
using SimpleDiffEq
using DataFrames
using StatsPlots
using BenchmarkTools

function drug_ode!(du, u, p, t)
    (C, D) = u
    (kₐ, D, k₁₀, C) = p
    @inbounds begin
        du[1] = kₐ*D - k₁₀*C
        du[2] = -kₐ*D
    end
    nothing
end

δt = 0.1
tmax = 40.0
tspan = (0.0,tmax)
t = 0.0:δt:tmax;


u0 = [990.0,10.0,0.0]; # S,I.R


p = [0.05,10.0,0.25]; # β,c,γ



function bact_ode!(du,u,p,t)
    (R,S,M) = u
    #C = Cᵢ*ℯ^(-kα*t)

    (aᵣR, aₛS, aₘM, kᵣ, kₛ, kₘ, C, d, e, f) = p
    i = R + S + M
    @inbounds begin
        du[1] = aᵣR*(1 - R/kᵣ - S/kₛ - M/kₘ)
        du[2] = aₛS*(1 - R/kᵣ - S/kₛ - M/kₘ) - d*C*S - e*S*R - f*S*M
        du[3] = aₘM*(1 - R/kᵣ - S/kₛ - M/kₘ) + e*S*R + f*S*M
    end
    nothing
end;


δt = 0.1
tmax = 40.0
tspan = (0.0,tmax)
t = 0.0:δt:tmax;


u0 = [10.0,980.0,10.0]; # S,I.R


p = [1.0,2.0,1.1, 0.33, 0.33, 0.33, 1.0, 2.0, 0.0001, 0.0001]; # β,c,γ


prob_ode = ODEProblem(bact_ode!,u0,tspan,p);


@time sol_ode = solve(prob_ode);

plot(sol_ode)
