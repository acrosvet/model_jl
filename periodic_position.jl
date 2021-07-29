# Constrain calves to smaller area twice daily
function periodic_position(calfModel)
    if calfModel.timestep*time_resolution % 12 == 0
        Tuple(2*rand(calfModel.rng, 2))
    else 
        Tuple(10*rand(calfModel.rng, 2))
    end
end
