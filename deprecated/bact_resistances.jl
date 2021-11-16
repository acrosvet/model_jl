function bact_resistances!(bacterialModel)
    num_resistant = [a.status == :R for a in allagents(bacterialModel)]
    bacterialModel.num_resistant = sum(num_resistant)

    num_susceptible = [a.status == :S for a in allagents(bacterialModel)]
    bacterialModel.num_susceptible = sum(num_susceptible)


end