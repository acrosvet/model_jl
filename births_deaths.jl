function births_deaths!(animalModel)

    if animalModel.calday != animalModel.psc + 305
        return
    else
    
            
            for i in 1:length(animalModel.births)
                kill_agent!(animalModel.deaths[i], animalModel)
            end

            animalModel.deaths = []

    end
end