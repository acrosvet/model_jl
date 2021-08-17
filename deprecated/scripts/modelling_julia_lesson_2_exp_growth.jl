# Defining a simple compartment model

I0  = 1
I_0 = 1
I₀ = 1

c = 0.01

λ = 1 + c

I_1 = λ * I_0
I_2 = λ * I_1
I_3 = λ * I_2

T = 10

I = zeros(T)

I[1] = I_0

for n in 1:T-1
    I[n+1] = λ * I[n]
    @show n, I[n]
end

using Plots

plot(I, m=:o, label = "I[n]", legend =:topleft)

T = 20

I = zeros(T)
I[1] = I_0

for n in 1:T-1
    I[n+1] = λ * I[n]
    @show n, I[n]
end

plot(I)

function run_infection(T=20)
    I = zeros(T)
    I[1] = I_0

    for n in 1:T-1
        I[n+1] = λ*I[n]
    end

    return I
end

methods(run_infection)

I_result = run_infection(40)

I_result

plot(I_result, m=:o)

# Adding stochasticity

function run_infection(I_0, λ, T=20)  # T=20 is default value

    I = zeros(T)
    I[1] = I_0

    for n in 1:T-1
        I[n+1] = λ * I[n]  
    end

    return I
end

run_infection(1.0, 0.1)

v = [1.0]

push!(v, 7.0)

length(v)

[v; 10]

v

function run_infection(I_0, λ, T=20)  # T=20 is default value

    Is = [I_0]
    
    I = I_0   # current value of I

    for n in 1:T-1
        I_next = λ * I
        
        push!(Is, I_next)

        I = I_next
    end

    return Is
end

run_infection(1.0, 1.1)

# Randomness

r = rand(50)

using Plots

scatter(r)

one(0.5)

scatter(r, 0.5 .* one.(r), ylim=(0, 1))

jump() = rand( (-1, +1) )

jump

jump()