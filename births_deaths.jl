function births_deaths!(animalModel)

    if animalModel.calday != (animalModel.psc + 305) - 185
        return
    else
    
            
            for i in 1:length(animalModel.births)
                kill_agent!(animalModel.deaths[i], animalModel)
                println("Agent culled")
            end

            animalModel.deaths = []

    end
end