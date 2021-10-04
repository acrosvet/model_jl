
using DifferentialEquations
using SimpleDiffEq
using DataFrames
using StatsPlots
using BenchmarkTools


function sir_ode!(du,u,p,t)
    (S,I,R) = u
    (β,c,γ) = p
    N = S+I+R
    @inbounds begin
        du[1] = -β*c*I/N*S
        du[2] = β*c*I/N*S - γ*I
        du[3] = γ*I
    end
    nothing
end;


δt = 0.1
tmax = 40.0
tspan = (0.0,tmax)
t = 0.0:δt:tmax;


u0 = [990.0,10.0,0.0]; # S,I.R


p = [0.05,10.0,0.25]; # β,c,γ


prob_ode = ODEProblem(sir_ode!,u0,tspan,p);


@time sol_ode = solve(prob_ode);

plot(sol_ode)
