function dryoff_split!(AnimalAgent, animalModel)


# Split calving system -----------------------------------------------------------------------------------------------    
if animalModel.system == :Split
    if AnimalAgent.dim ≥ rand(animalModel.rng, 290:315) && AnimalAgent.agenttype != :CO
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
            higher_dimension!(AnimalAgent, animalModel, stage = :D, level = 6, density = 7)
        end
    end
end


end