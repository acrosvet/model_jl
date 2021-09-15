function export_animal_interactions!(AnimalAgent, animalModel, interacting_id, interacting_stage, num_contacts)
    contact_data = DataFrame(
        agent = animalModel.step,
        Day = animalModel.date,
        agent_id = AnimalAgent.id,
        agent_stage = AnimalAgent.stage,
        contact_id = interacting_id,
        contact_stage = interacting_stage,
        number_contacted = num_contacts
    )
    contact_output = open("./export/seasonal_contacts.csv","a")
    CSV.write(contact_output, contact_data, delim = ",", append = true, header = false)
    close(contact_output)
    end