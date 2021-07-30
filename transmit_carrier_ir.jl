"""
Function: transmit_carrier_is
Transmission of sensitive bacteria from carrier animals
a1,a2. Position argumetns in continuous space
"""
function transmit_carrier_ir!(a1,a2)
    # Both calves cannot be infected, if they are, return from the function. It also can't be 0
    count(a.status == :CR for a in (a1, a2)) ≠ 1 && return
    # Else define a tuple of infected, healthy, depending on whether a1 or a2 is infected. infected will always be the first tuple position.
    infected, healthy = a1.status == :CR ? (a1, a2) : (a2, a1)

    #IF a random number is greater than βₛ, then we return out of the function
    
    if (rand(calfModel.rng) < rand(calfModel.rng)*infected.βᵣ) && (healthy.status == :S || healthy.status == :RS || healthy.status == :RR)
            healthy.status = :IR
            healthy.inf_days_ir = 0
        # Else we set the status of the healthy animal to its existing status
    else
        healthy.status = healthy.status
    end
end
