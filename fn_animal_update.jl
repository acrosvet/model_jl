function update_agent!(AnimalAgent)
    AnimalAgent.age += 1 # Increment age by 1 day
    
    if AnimalAgent.treatment == :T 
        AnimalAgent.days_treated += 1
    elseif AnimalAgent.treatment == :PT
        AnimalAgent.since_tx += 1
    end

    # Change stage over time ------------------------
    if AnimalAgent.age < 60
        AnimalAgent.stage = :C
    elseif AnimalAgent.age ≥ 60 && AnimalAgent.age ≤ 13*30
        AnimalAgent.stage = :W
    elseif AnimalAgent.age > 13*30 && AnimalAgent.age ≤ 24*30
        AnimalAgent.stage = :H
    elseif AnimalAgent.age > 24*30 
        AnimalAgent.stage = :L
    end



    # Add in bacterial data output
    resistant(x) = count(i == :R for i in x)
    sensitive(x) = count(i == :IS for i in x)
    susceptible(x) = count(i == :S for i in x)
    adata = [
    (:status, resistant),
    (:status, sensitive),
    (:status, susceptible)
    ]

    bacterialModel = AnimalAgent.submodel
    bacterialModel.properties[:total_status] = AnimalAgent.status
    bacterialModel.properties[:days_treated] = AnimalAgent.days_treated
    bacterialModel.properties[:age] = AnimalAgent.age

    bactostep, _ = run!(bacterialModel, bact_agent_step!; adata)

    sense = bactostep[:, dataname((:status, sensitive))][2]
    res = bactostep[:, dataname((:status, resistant))][2]
    sus = bactostep[:, dataname((:status, susceptible))][2]
    prop_res = res/(sense + res)

    AnimalAgent.bactopop = prop_res

end
