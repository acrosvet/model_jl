function bact_model_step!(bacterialModel)
    bacterial_population!(bacterialModel)
    bacterialModel.age += 1
    bacterialModel.step += 1 
    export_bacto_data!(bacterialModel)
end 