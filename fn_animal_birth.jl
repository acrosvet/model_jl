
function birth!(AnimalAgent, animalModel)
position_counter = 0

    while position_counter == 0
            # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
            if animalModel.current_calves == 0
                range = 10
            else
                range = Int(floor(3*√animalModel.current_calves))
            end 
            pos = (rand(animalModel.rng, 1:range, 2)..., 1)
            while !isempty(pos, animalModel)
                pos = (rand(animalModel.rng, 1:range, 2)..., 1)
            end
            age = 1
            status = AnimalAgent.status
            βᵣ = animalModel.βᵣ
            βₛ = animalModel.βₛ
            days_treated = 0
            inf_days = AnimalAgent.status == :IR || AnimalAgent.status == :IS ? 1 : 0
            days_exposed = AnimalAgent.status == :ES || AnimalAgent.status == :ER ? 1 : 0
            days_carrier = AnimalAgent.status == :CS || AnimalAgent.status == :CR ? 1 : 0
            treatment = :U
            bactopop_r = AnimalAgent.bactopop_r
            bactopop_is = AnimalAgent.bactopop_is
            since_tx = 0
            stage = :C
            dim = 0
            days_dry = 0
            trade_status = false
            agenttype = :Born
            lactation = 0
            pregstat = :E
            dic = 0
            stress = false
            sex = rand(animalModel.rng) > 0.5 ? :F : :M
            calving_season = AnimalAgent.calving_season
            days_recovered = 0
            submodel = AnimalAgent.submodel
                add_agent!(pos, animalModel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop_r, bactopop_is, submodel, stage, dim, days_dry, trade_status, agenttype, lactation, pregstat, dic, stress, sex, calving_season, days_recovered)
                #println("$calving_season Calf born!")
                position_counter += 1

    end
end