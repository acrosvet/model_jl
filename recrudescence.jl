function recrudescence!(AnimalAgent, animalModel)


if AnimalAgent.days_recovered > rand(animalModel.rng, 60:180)
    if AnimalAgent.status == :recovered
        AnimalAgent.status = :S
        AnimalAgent.days_recovered = 0
    end
end

if AnimalAgent.dim == rand(animalModel.rng, 0:60) && (AnimalAgent.status == :CR || AnimalAgent.status == :CS)
    if AnimalAgent.status == :CR
        AnimalAgent.status = :IR
    else
        AnimalAgent.status = :IS
    end
end

end