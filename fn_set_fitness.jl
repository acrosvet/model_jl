using Distributions
using Plots

Beta(1,2)

x = rand(Distributions.Beta(1,20), 100000)

histogram(x, normalize = true, legend = false, title = "PDF - Fitness for E and S bacteria")

savefig("susceptible_plot.png")

x = rand(Distributions.Beta(4,20), 100000)

histogram(x, normalize = true, legend = false, title = "PDF - Fitness for R bacteria")

savefig("resistant_plot.png")
