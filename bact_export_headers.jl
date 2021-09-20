bacto_header = DataFrame(
    step = 0,
    sensitive = 0,
    resistant = 0,
    susceptible = 0,
    resistant_proportion = 0
)


bacto_output = open("./export/bacterial_model_run.csv","w")
            CSV.write(bacto_output, bacto_header, delim = ",", append = true, header = true)
         close(bacto_output)

bactoMod = initialisePopulation(nbact = 10000, total_status = :IR, timestep = 1.0, age = 0, days_treated = 0, days_exposed = 0)

bacterial_posheader = DataFrame(
    step = 0,
    id = 0,
    bactostatus = 0,
    x = 0,
    y =0)
bacto_posoutput = open("./export/bacterial_positions.csv","a")
CSV.write(bacto_posoutput, bacterial_posheader, delim = ",", append = true, header = false)
close(bacto_posoutput)