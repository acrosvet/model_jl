tpm = initialiseSeasonal(100)

x = []
y = []
z = []

for i in 1:length(tpm.agents)
    push!(x, tpm[i].pos[1])
    push!(y, tpm[i].pos[2])
    push!(z, tpm[i].pos[3])
end

df = DataFrame(x = x, y = y, z = z)

CSV.write("./export/initial_positions.csv", df)
output = open("./export/seasonal_model_run.csv","w")
    CSV.write(output, header, delim = ",", append = true, header = true)
close(output)
