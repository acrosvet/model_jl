

 function export_bacto_position!(BacterialAgent, bacterialModel)
    bacterial_posdata = DataFrame(
        step = bacterialModel.step,
        id = BacterialAgent.id,
        bactostatus = BacterialAgent.status,
        x = BacterialAgent.pos[1],
        y = BacterialAgent.pos[2])
    bacto_posoutput = open("./export/bacterial_positions.csv","a")
    CSV.write(bacto_posoutput, bacterial_posdata, delim = ",", append = true, header = false)
    close(bacto_posoutput)
    end
