function init_infected_r(farm_status, N)
    if farm_status == :S
        return 0
    elseif farm_status == :R
        return Int(floor(N*(rand(0.05:0.05:0.15))))
    elseif farm_status == :IS
        return 0
    end
end