function init_infected_is(farm_status, N)
    if farm_status == :S
        return Int(floor(n*(rand(0.0:0.01:0.05))))
    elseif farm_status == :R
        return Int(floor(N*(rand(0.0:0.01:0.05))))
    elseif farm_status == :IS
        return Int(floor(N*(rand(0.05:0.01:0.1))))
    end
end
