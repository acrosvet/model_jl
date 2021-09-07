function births_deaths!(animalModel)

    if animalModel.calday != psc + 305 && return

    for i in 1:length(animalModel.births)
        kill_agent!(animalModel.deaths[i], animalModel)
    end

    animalModel.deaths = []


end