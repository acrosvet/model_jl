function bact_agent_step!(BacterialAgent, bacterialModel)
     infection!(BacterialAgent, bacterialModel)
     bact_transfer_r!(BacterialAgent, bacterialModel)
     bact_transfer_s!(BacterialAgent, bacterialModel)
     bact_plasmid_transfer!(BacterialAgent, bacterialModel)
     bact_treatment_response!(BacterialAgent, bacterialModel)
     export_bacto_position!(BacterialAgent, bacterialModel)
     treatment!(BacterialAgent, bacterialModel)
end
