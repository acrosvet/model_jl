function bact_agent_step!(BacterialAgent, bacterialModel)

    #Random.seed!(hash(bacterialModel))

     bact_recovery!(BacterialAgent, bacterialModel)#Recovery after infection
     infection!(BacterialAgent, bacterialModel)#When exposed, populate with pathogenic bacteria
     invasion!(BacterialAgent, bacterialModel)#When exposed, competition between non-pathogenic and pathogenic bacteria ensues
     bact_treatment_response!(BacterialAgent, bacterialModel)#Set response to treatment
     populate_empty!(BacterialAgent, bacterialModel) # Populate empty spaces left by treatment
     fitness!(BacterialAgent, bacterialModel)#Fitness competitions between adjacent bacteria
     bact_plasmid_transfer!(BacterialAgent, bacterialModel)#Plasmid transfer between adjacent bacteria
    # export_bacto_position!(BacterialAgent, bacterialModel)


end
   