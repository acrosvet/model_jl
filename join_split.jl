function join_split(AnimalAgent, animalModel)

    # Additional split calving options ---------------------------------
if animalModel.system == :Split

    if AnimalAgent.calving_season == :Spring
        if (AnimalAgent.pregstat == :E && AnimalAgent.stage == :L) && (animalModel.date == (animalModel.msd + Month(3)))
            if rand(animalModel.rng) < 0.85
                AnimalAgent.pregstat = :P
                AnimalAgent.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
                AnimalAgent.agenttype = :Joined
            end
        end
    end

    if AnimalAgent.calving_season == :Autumn
        if (AnimalAgent.pregstat == :E && AnimalAgent.stage == :L) && (animalModel.date == (animalModel.msd_2 + Month(3)))
            if rand(animalModel.rng) < 0.85
                AnimalAgent.pregstat = :P
                AnimalAgent.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
                AnimalAgent.agenttype = :Joined
            end
        end
    end
end


end