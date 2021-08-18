# Fn - Bacterial dynamics --------------------

function bacto_dyno!(AnimalAgent)
    if AnimalAgent.bactopop > 0.5 && AnimalAgent.status == :ER
        AnimalAgent.status = :IR
    else return
    end

end

