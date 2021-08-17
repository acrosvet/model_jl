function carrierState!(CalfAgent, calfModel)
 
    # Some calves enter a carrier state
    if (CalfAgent.status == :RR || CalfAgent.status == :RS) && CalfAgent.treatment == :PT
        if rand(calfModel.rng) < calfModel.res_carrier
            CalfAgent.status = :CR
        end
    end

    if CalfAgent.status == :RS
        if rand(calfModel.rng) < calfModel.sens_carrier
            CalfAgent.status = :CS
        end
    end
end
