
#Function, extract infected animals and susceptible animals at each timestep
infected_sensitive(x) = count(i == :IS for i in x)
susceptible(x) = count(i == :S for i in x)
infected_resistant(x) = count(i == :IR for i in x)
recoveries_r(x) = count(i == :RR for i in x)
recoveries_s(x) = count(i == :RS for i in x)
treatments(x) = count(i == :T for i in x)
post_treatment(x) = count(i == :PT for i in x)
finished(x) = count(i == :PT for i in x)
carrier_is(x) = count(i == :CS for i in x)
carrier_ir(x) = count(i == :CR for i in x)
adata = [(:status, infected_sensitive),
 (:status, susceptible),
 (:status, infected_resistant),
 (:status, recoveries_r),
 (:status, recoveries_s),
 (:status, carrier_is),
 (:status, carrier_ir),
 (:treatment, treatments),
 (:treatment, finished),
 (:treatment, post_treatment)]

simRun, _ = run!(calfSim, agent_step!, model_step!, 100*time_resolution; adata)

CSV.write("./run2_export.csv", simRun)

