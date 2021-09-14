# Seasonal  ------------------------------------
init_pos = initialiseSeasonal(100)

x = []
y = []
z = []


for i in 1:length(tpm.agents)
    push!(x, init_pos[i].pos[1])
    push!(y, init_pos[i].pos[2])
    push!(z, init_pos[i].pos[3])
end

df = DataFrame(x = x, y = y, z = z)

CSV.write("./export/seasonal_initial_positions.csv", df)

# Split ------------------------------------
init_pos = initialiseSplit(100)

x = []
y = []
z = []


for i in 1:length(tpm.agents)
    push!(x, init_pos[i].pos[1])
    push!(y, init_pos[i].pos[2])
    push!(z, init_pos[i].pos[3])
end

df = DataFrame(x = x, y = y, z = z)

CSV.write("./export/split_initial_positions.csv", df)

# Seasonal  ------------------------------------
init_pos = initialiseBatch(100)

x = []
y = []
z = []


for i in 1:length(tpm.agents)
    push!(x, init_pos[i].pos[1])
    push!(y, init_pos[i].pos[2])
    push!(z, init_pos[i].pos[3])
end

df = DataFrame(x = x, y = y, z = z)

CSV.write("./export/seasonal_initial_positions.csv", df)

