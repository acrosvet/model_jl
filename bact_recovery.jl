function bact_recovery!(BacterialAgent, bacterialModel)
    num_resistant = [a.status == :R for a in allagents(bacterialModel)]
    num_resistant = sum(num_resistant)
    if bacterialModel.days_recovered > 0
        if BacterialAgent.status == :R || BacterialAgent.status == :IS
            if rand(bacterialModel.rng) < ℯ^(-bacterialModel.days_recovered/5)
                if num_resistant> 5
                    kill_agent!(BacterialAgent, bacterialModel)
                end
            end
        end
    end

end