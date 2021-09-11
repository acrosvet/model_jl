"""
**joining!(AnimalAgent)**\n

* Start joining pregnant cows after msd and once cow has calved
* Ensures the current date is greater than or equal to mating start date
* Animal DIM must be greater than 42 to allow for uterine involution

"""
function joining!(AnimalAgent, animalModel)
if AnimalAgent.calving_season == :Spring
    if (AnimalAgent.pregstat == :E && AnimalAgent.stage == :L) && (animalModel.date == (animalModel.msd + Month(3)))
        if rand(animalModel.rng) < 0.85
            AnimalAgent.pregstat = :P
            AnimalAgent.dic = rand(animalModel.rng, truncated(Poisson(63), 1, 84))
        end
    end
end

    if AnimalAgent.calving_season == :Autumn
        if (AnimalAgent.pregstat == :E && AnimalAgent.stage == :L) && (animalModel.date == (animalModel.msd_2 + Month(3)))
            if rand(animalModel.rng) < 0.85
                AnimalAgent.pregstat = :P
                AnimalAgent.dic = rand(animalModel.rng, truncated(Poisson(63), 1, 84))
            end
        end
    end


end

