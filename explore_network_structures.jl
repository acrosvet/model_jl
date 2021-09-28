# Network structure
using LightGraphs

net = static_scale_free(100, 100, 10)

using GraphPlot

gplot(net)
