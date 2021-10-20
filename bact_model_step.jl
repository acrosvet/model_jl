function bact_model_step!(bacterialModel)

    

    stress!(bacterialModel)
    bact_carrier!(bacterialModel)
    #infected_transition!(bacterialModel)
    #bacterialModel.age += 1
    #bacterialModel.step += 1 
    bacterial_population!(bacterialModel)
    #export_bacto_data!(bacterialModel)

# println("Stepped")
end 
