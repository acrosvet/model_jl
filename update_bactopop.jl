function update_bactopop!(animalModel)

    @async Threads.@threads for i in 1:length(animalModel.agents)
        if haskey(animalModel.agents, i)
            num_sense = [a.status == :IS for a in allagents(animalModel[i].submodel)]
            num_sense = sum(num_sense)/length(animalModel[i].submodel.agents)
            animalModel[i].bactopop_is = num_sense


            num_res = [a.status == :R for a in allagents(animalModel[i].submodel)]
            num_res = sum(num_res)/length(animalModel[i].submodel.agents)
            animalModel[i].bactopop_r = num_res


        end
    end


end