function bact_agent_step!(BacterialAgent, bacterialModel)

    Random.seed!(hash(bacterialModel))

     bact_recovery!(BacterialAgent, bacterialModel)
     infection!(BacterialAgent, bacterialModel)
     invasion!(BacterialAgent, bacterialModel)
     bact_treatment_response!(BacterialAgent, bacterialModel)
     populate_empty!(BacterialAgent, bacterialModel) 
     fitness!(BacterialAgent, bacterialModel)
     bact_plasmid_transfer!(BacterialAgent, bacterialModel)
    # export_bacto_position!(BacterialAgent, bacterialModel)


end
  