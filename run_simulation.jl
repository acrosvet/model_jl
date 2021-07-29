
#Function, extract infected animals and susceptible animals at each timestep
infected_sensitive(x) = count(i == :IS for i in x)
susceptible(x) = count(i == :S for i in x)
infected_resistant(x) = count(i == :IR for i in x)
recoveries(x) = count(i == :R for i in x)
treatments(x) = count(i == :T for i in x)
finished(x) = count(i == :PT for i in x)
adata = [(:status, infected_sensitive), (:status, susceptible), (:status, infected_resistant), (:status, recoveries), (:treatment, treatments), (:treatment, finished)]

simRun, _ = run!(calfSim, agent_step!, model_step!, 100*time_resolution; adata)

CSV.write("./run2_export.csv", simRun)

