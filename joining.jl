"""
**joining!(AnimalAgent)**\n

* Start joining pregnant cows after msd and once cow has calved
* Ensures the current date is greater than or equal to mating start date
* Animal DIM must be greater than 42 to allow for uterine involution

"""
function joining!(AnimalAgent, animalModel)
#= 
    function heat_detection_efficiency(animalModel)
        if animalModel.date ≤ (animalModel.msd + Day(21))
            0.1 # 90% chance in the first few weeks of mating
        else 
            0.2 # 80% thereafter
        end
    end
if AnimalAgent.pregstat == :E
    if animalModel.date ≥ animalModel.msd && animalModel.date ≤ (animalModel.msd + Day(12*7)) # End mating at 12 weeks
            if AnimalAgent.dim ≥ 28 && AnimalAgent.heat == true
                if rand(animalModel.rng) > heat_detection_efficiency(animalModel) # Allow for a 90% chance of detecting heat in the first service
                    if rand(animalModel.rng) > 0.5 # and a 50% chance of conception
                        AnimalAgent.pregstat = :P 
                        AnimalAgent.dic = 1                   
                    end
                end
            end   
    end
end =#

if AnimalAgent.pregstat == :E && (animalModel.date == (animalModel.msd + Month(3)))
    if rand(animalModel.rng) < 0.85
        AnimalAgent.pregstat = :P
        AnimalAgent.dic = rand(animalModel.rng, truncated(Poisson(63), 1, 84))
    end
end
end
