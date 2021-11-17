function cull_empty_dry!(AnimalAgent, animalModel)

#If cows have been dried off empty, cull them
if AnimalAgent.stage == :D && AnimalAgent.pregstat == :E
    if haskey(animalModel.agents, AnimalAgent.id)
        culling_reason = "Empty dry"
        export_culling!(AnimalAgent, animalModel, culling_reason)#Write out to the culling file
        kill_agent!(AnimalAgent, animalModel)
    end
end

#If the animals are more than 320 days in calf, but have not calved, cull them
if AnimalAgent.dic >= 320
    if haskey(animalModel.agents, AnimalAgent.id)
        culling_reason = "Slipped"
        export_culling!(AnimalAgent, animalModel, culling_reason)
        kill_agent!(AnimalAgent, animalModel)
    end
end


end
