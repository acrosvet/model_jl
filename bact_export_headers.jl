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


bacterial_posheader = DataFrame(
    step = 0,
    id = 0,
    bactostatus = 0,
    x = 0,
    y =0)

bacto_posoutput = open("./export/bacterial_positions.csv","w")
CSV.write(bacto_posoutput, bacterial_posheader, delim = ",", append = true, header = true)
close(bacto_posoutput)