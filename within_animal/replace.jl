"""
Population turnover
"""
function replace!(BacterialAgent, bacterialModel)

    if BacterialAgent.age >= BacterialAgent.max_life
        kill_agent!(BacterialAgent, bacterialModel)
    
        add_agent!(pos, bacterialModel, vel, bactostatus, treatment, strain, age. max_life)
end
end
