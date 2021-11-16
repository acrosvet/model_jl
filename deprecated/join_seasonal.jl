function join_seasonal!(AnimalAgent, animalModel)
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

end