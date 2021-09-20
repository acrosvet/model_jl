function bact_agent_step!(BacterialAgent, bacterialModel)
    # uninfected!(BacterialAgent, bacterialModel)
     bact_transfer_r!(BacterialAgent, bacterialModel)
     bact_transfer_s!(BacterialAgent, bacterialModel)
     #fitness!(BacterialAgent, bacterialModel)
    # bact_update_agent!(BacterialAgent, bacterialModel) #Apply the update_agent function
     bact_plasmid_transfer!(BacterialAgent, bacterialModel)
     bact_treatment_response!(BacterialAgent, bacterialModel)
     export_bacto_position!(BacterialAgent, bacterialModel)
     treatment!(BacterialAgent, bacterialModel)


end
