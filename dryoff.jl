"""
**dryoff!(AnimalAgent)
"""
function dryoff!(AnimalAgent, animalModel)

# Split calving system -----------------------------------------------------------------------------------------------    
if animalModel.system == :Split
    if AnimalAgent.dim ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(305), 290, 330)))) && AnimalAgent.agenttype != :CO
        if AnimalAgent.pregstat == :E
            if rand(animalModel.rng) > 0.4 && AnimalAgent.dim < 330
                if AnimalAgent.calving_season == :Spring
                    AnimalAgent.calving_season = :Autumn
                    AnimalAgent.agenttype = :CO
                    println("Carried over")
                elseif AnimalAgent.calving_season == :Autumn && AnimalAgent.dim < 330
                    AnimalAgent.calving_season = :Spring
                    println("Carried over")
                    AnimalAgent.agenttype = :CO

                end
            end
        else
            AnimalAgent.stage = :D
            AnimalAgent.days_dry = 1
            AnimalAgent.dim = 0
            # Add to the dry cow plane
            pos = (rand(animalModel.rng, 1:100, 2)..., 6)
            while !isempty(pos, animalModel)
                pos = (rand(animalModel.rng, 1:100, 2)..., 6)
            end
            move_agent!(AnimalAgent, pos, animalModel)
        end
    end
end
# Spring calving system -------------------------------------------------------------
if animalModel.system == :Seasonal|| animalModel.system == :Continuous
    if AnimalAgent.dim ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(305), 290, 330))))
            AnimalAgent.stage = :D
            AnimalAgent.days_dry = 1
            AnimalAgent.dim = 0
            pos = (rand(animalModel.rng, 1:100, 2)..., 6)
            while !isempty(pos, animalModel)
                pos = (rand(animalModel.rng, 1:100, 2)..., 6)
            end
            move_agent!(AnimalAgent, pos, animalModel)
    end
end

# Batch calving system ----------------------------------------------------------------

if animalModel.system == :Batch
    if AnimalAgent.dim ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(305), 290, 330)))) && AnimalAgent.agenttype != :CO
        if AnimalAgent.pregstat == :E
            if rand(animalModel.rng) > 0.4 && AnimalAgent.dim < 330
                if AnimalAgent.calving_season == :B1
                    AnimalAgent.calving_season = :B2
                    AnimalAgent.agenttype = :CO
                    println("Carried over")
                elseif AnimalAgent.calving_season == :B2
                    AnimalAgent.calving_season = :B3
                    println("Carried over")
                    AnimalAgent.agenttype = :CO
                elseif AnimalAgent.calving_season == :B3 
                    AnimalAgent.calving_season = :B4
                    println("Carried over")
                    AnimalAgent.agenttype = :CO
                elseif AnimalAgent.calving_season == :B4 
                    AnimalAgent.calving_season = :B1
                    println("Carried over")
                    AnimalAgent.agenttype = :CO
                end
            end
        elseif AnimalAgent.pregstat == :P
            AnimalAgent.stage = :D
            AnimalAgent.days_dry = 1
            AnimalAgent.dim = 0
            pos = (rand(animalModel.rng, 1:100, 2)..., 6)
            while !isempty(pos, animalModel)
                pos = (rand(animalModel.rng, 1:100, 2)..., 6)
            end
            move_agent!(AnimalAgent, pos, animalModel)
            println("Dried off")
        end
    end
end

end