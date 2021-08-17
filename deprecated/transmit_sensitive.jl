"""
Function: transmit_sensitive
Transmission of sensitive bacteria
a1,a2. Position argumetns in continuous space
"""
function transmit_sensitive!(a1,a2)
    # Both calves cannot be infected, if they are, return from the function. It also can't be 0
    count(a.status == :IS for a in (a1, a2)) ≠ 1 && return
    # Else define a tuple of infected, healthy, depending on whether a1 or a2 is infected. infected will always be the first tuple position.
    infected, healthy = a1.status == :IS ? (a1, a2) : (a2, a1)

    #IF a random number is greater than βₛ, then we return out of the function
    
    if (rand(calfModel.rng) < infected.βₛ) && healthy.status == :S
        healthy.status = :IS
        # Else we set the status of the healthy animal to IS
    else
        healthy.status = healthy.status
    end
end
