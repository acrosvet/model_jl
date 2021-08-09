"""
cell senescence
"""
function senesce!(BacterialAgent, bacterialModel)

    if rand(bacterialModel.rng) < bacterialModel.senesence
        kill_agent!(BacterialAgent, bacterialModel)
    else
        return
end
