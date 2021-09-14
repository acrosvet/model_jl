
function birth!(AnimalAgent, animalModel)
position_counter = 0

    while position_counter == 0
            # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
            pos = (rand(animalModel.rng, 1:100, 2)..., 1)
            age = 1
            status = :S
            βᵣ = animalModel.βᵣ
            βₛ = animalModel.βₛ
            days_treated = 0
            inf_days = 0
            days_exposed = 0
            days_carrier = 0
            treatment = :U
            bactopop = 0.0
            since_tx = 0
            submodel = initialisePopulation(
                nbact = 100,
                total_status = status,
                timestep = animalModel.timestep,
                days_treated = 0,
                age = age,
                days_exposed = 0
            )
            stage = :C
            dim = 0
            days_dry = 0
            trade_status = false
            agenttype = :Born
            lactation = 0
            pregstat = :E
            dic = 0
            heat = false
            sex = rand(animalModel.rng) > 0.5 ? :F : :M
            calving_season = AnimalAgent.calving_season
            if isempty(pos, animalModel)
                add_agent!(pos, animalModel, vel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, heat, sex, calving_season)
                println("$calving_season Calf born!")
                position_counter += 1
            end
    end
end