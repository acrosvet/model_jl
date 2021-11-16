function join_batch(AnimalAgent, animalModel)


# Additional batch calving options ------------------------------------------------

if animalModel.system == :Batch
    if AnimalAgent.calving_season == :B1
        if (AnimalAgent.pregstat == :E && AnimalAgent.stage == :L) && (animalModel.date == (animalModel.msd + Month(3)))
            if rand(animalModel.rng) < 0.85
                AnimalAgent.pregstat = :P
                AnimalAgent.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
                AnimalAgent.agenttype = :Joined
            end
        end
    elseif AnimalAgent.calving_season == :B2
        if (AnimalAgent.pregstat == :E && AnimalAgent.stage == :L) && (animalModel.date == (animalModel.msd_2 - Year(1) +  Month(3)))
            if rand(animalModel.rng) < 0.85
                AnimalAgent.pregstat = :P
                AnimalAgent.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
                AnimalAgent.agenttype = :Joined
            end
        end
    elseif AnimalAgent.calving_season == :B3
        if (AnimalAgent.pregstat == :E && AnimalAgent.stage == :L) && (animalModel.date == (animalModel.msd_3 + Month(3)))
            if rand(animalModel.rng) < 0.85
                AnimalAgent.pregstat = :P
                AnimalAgent.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
                AnimalAgent.agenttype = :Joined
            end
        end
    elseif AnimalAgent.calving_season == :B4
        if (AnimalAgent.pregstat == :E && AnimalAgent.stage == :L) && (animalModel.date == (animalModel.msd_4 + Month(3)))
            if rand(animalModel.rng) < 0.85
                AnimalAgent.pregstat = :P
                AnimalAgent.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
                AnimalAgent.agenttype = :Joined
            end
        end    
    end
end

end