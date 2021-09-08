"""
**joining!(AnimalAgent)**\n

* Start joining pregnant cows after msd and once cow has calved
* Ensures the current date is greater than or equal to mating start date
* Animal DIM must be greater than 42 to allow for uterine involution

"""
function joining!(AnimalAgent, animalModel)

    function heat_detection_efficiency(animalModel)
        if animalModel.date ≤ (animalModel.msd + Day(21))
            0.1 # 90% chance in the first few weeks of mating
        else 
            0.2 # 80% thereafter
        end
    end

    if animalModel.Date ≥ animalModel.msd
            if AnimalAgent.dim ≥ 42 && AnimalAgent.heat == true
                if rand(animalModel.rng) > heat_detection_efficiency(animalModel) # Allow for a 90% chance of detecting heat in the first service
                    if rand(animalModel.rng) > 0.5 # and a 50% chance of conception
                        AnimalAgent.pregstat = :P                    
                    end
                end
            end   
    end
end