# Fn - Bact (agent step) ----------------------------------

function bact_agent_step!(BacterialAgent, bacterialModel)
    #fitness!(BacterialAgent, bacterialModel)
    bact_update_agent!(BacterialAgent, bacterialModel) #Apply the update_agent function
    bact_plasmid_transfer!(BacterialAgent, bacterialModel)
    bact_treatment_response!(BacterialAgent, bacterialModel)

end
