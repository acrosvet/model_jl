
"""
Function: transmit_resistant
Transmission of resistant bacteria
a1,a2. Position argumetns in continuous space
"""
function transmit_resistant!(a1,a2)
    count(a.status == :IR for a in (a1, a2)) ≠ 1 && return
        infected, healthy = a1.status == :IR ? (a1, a2) : (a2, a1)
#If a random number is below the transmssion parameter, infect, provided that the contacted animal is susceptible.
        if (rand(calfModel.rng) < infected.βᵣ) && healthy.status == :S
            healthy.status = :IR
        else
            healthy.status = healthy.status
        end

end