function bact_agent_step!(BacterialAgent, bacterialModel)
     bact_treatment_response!(BacterialAgent, bacterialModel)
     populate_empty!(BacterialAgent, bacterialModel) 
     fitness!(BacterialAgent, bacterialModel)
     #infection!(BacterialAgent, bacterialModel)
     bact_plasmid_transfer!(BacterialAgent, bacterialModel)
     export_bacto_position!(BacterialAgent, bacterialModel)
     #treatment!(BacterialAgent, bacterialModel)


end
