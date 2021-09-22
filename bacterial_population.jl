function bacterial_population!(bacterialModel)
    
    number_susceptible = [a.status == :S for a in allagents(bacterialModel)]
    number_susceptible = sum(number_susceptible)
    bacterialModel.num_susceptible = number_susceptible

    number_sensitive = [a.status == :IS for a in allagents(bacterialModel)]
    number_sensitive = sum(number_sensitive)
    bacterialModel.num_sensitive = number_sensitive

    number_resistant = [a.status == :R for a in allagents(bacterialModel)]
    number_resistant = sum(number_resistant)
    bacterialModel.num_resistant = number_resistant

    resistant_prop = number_resistant/(number_resistant + number_sensitive + number_susceptible)
    sensitive_prop = number_sensitive/(number_resistant + number_sensitive + number_susceptible)

    bacterialModel.resistant_pop = resistant_prop
    bacterialModel.sensitive_pop = sensitive_prop
    

 end
