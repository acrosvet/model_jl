function recrudescence!(AnimalAgent, animalModel)

# If the animal is recovered for more than 60 to 180 days, it becomes suceptible again.
if AnimalAgent.days_recovered > rand(animalModel.rng, 60:180)
    if AnimalAgent.status == :RR || AnimalAgent.status == :RS
        AnimalAgent.status = :S
        AnimalAgent.days_recovered = 0
    end
end

# Stressed animals can shed again

if AnimalAgent.stress == true
    if AnimalAgent.status == :CR
        AnimalAgent.status = :ER
        AnimalAgent.days_exposed = 1
    elseif AnimalAgent.status == :CS
        AnimalAgent.status = :ES
        AnimalAgent.days_exposed = 1
    end
end

end