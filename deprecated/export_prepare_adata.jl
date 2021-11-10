
stage_c(x) = count(i == :C for i in x)
stage_w(x) = count(i == :W for i in x)
stage_h(x) = count(i == :H for i in x)
stage_l(x) = count(i == :L for i in x)
infected_sensitive(x) = count(i == :IS for i in x)
susceptible(x) = count(i == :S for i in x)
infected_resistant(x) = count(i == :IR for i in x)
recoveries_r(x) = count(i == :recovered for i in x)
recoveries_s(x) = count(i == :RS for i in x)
treatments(x) = count(i == :T for i in x)
post_treatment(x) = count(i == :PT for i in x)
finished(x) = count(i == :PT for i in x)
carrier_is(x) = count(i == :CS for i in x)
carrier_ir(x) = count(i == :CR for i in x)

adata = [
    (:stage, stage_c)
    (:stage, stage_w)
    (:stage, stage_h)
    (:stage, stage_l)
    (:status, infected_sensitive)
    (:status, susceptible)
    (:status, infected_resistant)
    (:status, recoveries_r)
    (:status, recoveries_s)
    (:status, carrier_is)
    (:status, carrier_ir)
    (:treatment, treatments)
    (:treatment, finished)
]

#= infected_sensitive(x) = count(i == :IS for i in x)
susceptible(x) = count(i == :S for i in x)
infected_resistant(x) = count(i == :IR for i in x)
recoveries_r(x) = count(i == :RR for i in x)
recoveries_s(x) = count(i == :RS for i in x)
treatments(x) = count(i == :T for i in x)
post_treatment(x) = count(i == :PT for i in x)
finished(x) = count(i == :PT for i in x)
carrier_is(x) = count(i == :CS for i in x)
carrier_ir(x) = count(i == :CR for i in x)
status_p(x) = count(i == :P for i in x)
stage(x) = count(i == :W for i in x)
 =#
#= adata = [(:status, infected_sensitive),
 (:status, susceptible),
 (:status, infected_resistant),
 (:status, recoveries_r),
 (:status, recoveries_s),
 (:status, carrier_is),
 (:status, carrier_ir),
 (:treatment, treatments),
 (:treatment, finished),
 (:treatment, post_treatment),
 (:stage, stage)]
 =#
