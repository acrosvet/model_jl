using Pkg
Pkg.add("DifferentialEquations")

# Define a function that will provide outputs to the system of differential equations described by 
# Davies et al (https://doi.org/10.1038/s41559-018-0786-x)

function ode_within!(du, u, p, t)

    