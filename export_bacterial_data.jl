
 function export_bacto_data!(bacterialModel)
    bacterial_data = DataFrame(
        animal_id = bacterialModel.animalno,
        step = bacterialModel.step,
        sensitive = bacterialModel.num_sensitive,
        resistant = bacterialModel.num_resistant,
        susceptible = bacterialModel.num_susceptible,
        resistant_proportion = bacterialModel.resistant_pop,
        sensitive_proportion = bacterialModel.sensitive_pop,
        total_status = bacterialModel.total_status,
        days_exposed = bacterialModel.days_exposed)
    bacto_output = open("./export/bacterial_model_run.csv","a")
    CSV.write(bacto_output, bacterial_data, delim = ",", append = true, header = false)
    close(bacto_output)
    end
