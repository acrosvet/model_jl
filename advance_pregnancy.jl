function advance_pregnancy!(AnimalAgent)

    if AnimalAgent.pregstat == :P
        AnimalAgent.dic += 1
    end
end