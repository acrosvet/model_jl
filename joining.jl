"""
**joining!(AnimalAgent)**\n

* Start joining pregnant cows after msd and once cow has calved
* Ensures the current date is greater than or equal to mating start date
* Animal DIM must be greater than 42 to allow for uterine involution

"""
function joining!(AnimalAgent, animalModel)

# Seasonal systems ---------------------------------------------------------------
if animalModel.system == :Seasonal
    if (AnimalAgent.pregstat == :E && AnimalAgent.stage == :L) && (animalModel.date == (animalModel.msd + Month(3)))
        if rand(animalModel.rng) < 0.85
            AnimalAgent.pregstat = :P
            AnimalAgent.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
            AnimalAgent.agenttype = :Joined
        end
    end
end

# Continuous systems ---------------------------------------------------------------
if animalModel.system == :Continuous
    if (AnimalAgent.pregstat == :E && AnimalAgent.stage == :L) 
        if AnimalAgent.dim == 100 && rand(animalModel.rng) < 0.53
            AnimalAgent.pregstat = :P
            AnimalAgent.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(50), 1, 58))))
            AnimalAgent.agenttype = :Joined
        elseif AnimalAgent.dim == 200 && rand(animalModel.rng) < 0.85
            AnimalAgent.pregstat = :P
            AnimalAgent.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(50), 1, 58))))
            AnimalAgent.agenttype = :Joined
        end
    end
end


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
        if (AnimalAgent.pregstat == :E && AnimalAgent.stage == :L) && (animalModel.date == (animalModel.msd + Month(3)))
            if rand(animalModel.rng) < 0.85
                AnimalAgent.pregstat = :P
                AnimalAgent.dic = Int(floor(rand(animalModel.rng, truncated(Rayleigh(63), 1, 84))))
                AnimalAgent.agenttype = :Joined
            end
        end
    end
end

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

