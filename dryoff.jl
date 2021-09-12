"""
**dryoff!(AnimalAgent)
"""
function dryoff!(AnimalAgent, animalModel)

    if AnimalAgent.dim ≥ Int(floor(rand(animalModel.rng, truncated(Rayleigh(305), 290, 330)))) && AnimalAgent.agenttype != :CO
        if AnimalAgent.pregstat == :E
            if rand(animalModel.rng) > 0.8 && AnimalAgent.dim < 330
                if AnimalAgent.calving_season == :Spring
                    AnimalAgent.calving_season = :Autumn
                    AnimalAgent.agenttype = :CO
                    println("Carried over")
                elseif AnimalAgent.calving_season == :Autumn && AnimalAgent.dim < 500
                    AnimalAgent.calving_season = :Spring
                    println("Carried over")
                    AnimalAgent.agenttype = :CO

                end
            end
        else
            AnimalAgent.stage = :D
            AnimalAgent.days_dry = 1
            AnimalAgent.dim = 0
        end
    end



        
end