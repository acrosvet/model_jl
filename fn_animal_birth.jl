
function birth!(animalModel)

    function initial_velocity(status, movement)
        if status == :S
            sincos(2π*rand(animalModel.rng)) .*movement
        elseif status == :IS
            sincos(2π*rand(animalModel.rng)) .*(movement/2)
        elseif status == :IR
            sincos(2π*rand(animalModel.rng)) .*(movement/2.5)
        elseif status == :M
            (0.0,0.0)
        end
    end

    if (animalModel.calday ≥ 182 && animalModel.calday ≤ 272) && (rand(animalModel.rng) < 0.5)


            # Position, initially random, a tuple defined by the random parms of the model and with dimension of 2
            pos = Tuple(10*rand(animalModel.rng, 2))
            age = 0
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
            vel = initial_velocity(status, animalModel.movement)
            stage = :C
            dim = 0
            days_dry = 0
            trade_status = false
            add_agent!(pos, animalModel, vel, age, status, βₛ, βᵣ, inf_days, days_exposed, days_carrier, treatment, days_treated, since_tx, bactopop, submodel, stage, dim, days_dry, trade_status)
            #add_agent!(pos, animalModel, vel, age, status, βₛ, βᵣ, inf_days_is, inf_days_ir, treatment, days_treated, since_tx, bactopop, submodel, stage, dim, days_dry, trade_status)    
        end

end