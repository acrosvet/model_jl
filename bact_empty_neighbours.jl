function populate_empty!(BacterialAgent, bacterialModel)

    # Fill in empty positions with bacteria

   # if has_empty_positions(bacterialModel) == true

    agent_x = BacterialAgent.pos[1]
    agent_y = BacterialAgent.pos[2]

    adjacent_positions = []

    pos_1 = (agent_x + 1, agent_y)
    push!(adjacent_positions, pos_1)
    pos_2 = (agent_x - 1, agent_y)
    push!(adjacent_positions, pos_2)
    pos_3 = (agent_x, agent_y +1)
    push!(adjacent_positions, pos_3)
    pos_4 = (agent_x, agent_y - 1)
    push!(adjacent_positions, pos_4)
    pos_5 = (agent_x -1, agent_y +1)
    push!(adjacent_positions, pos_5)
    pos_6 = (agent_x - 1, agent_y - 1)
    push!(adjacent_positions, pos_6)
    pos_7 = (agent_x +1, agent_y + 1)
    push!(adjacent_positions, pos_7)
    pos_8 = (agent_x + 1, agent_y - 1)
    push!(adjacent_positions, pos_8)


    for i in 1:length(adjacent_positions)
        if (adjacent_positions[i][1] <= bacterialModel.dim && adjacent_positions[i][1] > 0) && (adjacent_positions[i][2] <= bacterialModel.dim && adjacent_positions[i][2] > 0)
            if isempty(adjacent_positions[i], bacterialModel)
                strain = BacterialAgent.strain
                pos = adjacent_positions[i]
                strain_status = BacterialAgent.strain_status
                fitness = BacterialAgent.fitness
                status = BacterialAgent.status
                if rand(bacterialModel.rng) > 0.5
                    add_agent!(pos, bacterialModel,status, strain, strain_status, fitness)
                end
            end
        end
    end

#= else
    return
end =#

end