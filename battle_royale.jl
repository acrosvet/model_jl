mutable struct Fighter <: AbstractAgent
    id::Int
    pos::Dims{3}
    has_prisoner::Bool
    capture_time::Int
    shape::Symbol # For plotting
end

function battle(; fighters = 1)
    model = ABM(
        Fighter,
        GridSpace((100, 100, 10); periodic = false);
        scheduler = random_activation,
    )

    n = 0
    while n != fighters
        pos = (rand(MersenneTwister(42), 1:100, 2)..., 1) # Start at level 1
        if isempty(pos, model)
            add_agent!(pos, model, false, 0, :diamond)
            n += 1
        end
    end

    return model
end

model = battle()