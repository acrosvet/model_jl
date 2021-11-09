function dryoff_batch!(AnimalAgent, animalModel)


# Batch calving system ----------------------------------------------------------------

if animalModel.system == :Batch
    if AnimalAgent.dim ≥ rand(animalModel.rng, 290:315) && AnimalAgent.agenttype != :CO
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
            higher_dimension!(AnimalAgent, animalModel, stage = :D, level = 6, density = 7)
            println("Dried off")
        end
    end
end

end