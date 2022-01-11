function animal_transmission!(animal, animalModel)
      animal.status == 0 && return
      animal.status == 3 && return
      animal.status == 4 && return      #animal.days_recovered > 5 && return
      pos = animal.pos
      animal.neighbours = get_neighbours_animal(pos)

      animal.status == 1 && rand(animalModel.rng) > animalModel.pop_p && return
      animal.status == 2 && rand(animalModel.rng) > animalModel.pop_r && return
      animal.status == 5 && rand(animalModel.rng) > animalModel.pop_p && return
      animal.status == 6 && rand(animalModel.rng) > animalModel.pop_r && return
      animal.status == 7 && rand(animalModel.rng) > animalModel.pop_p && return
      animal.status == 8 && rand(animalModel.rng) > animalModel.pop_r && return


      #The animal can now go on to infect its neighbours
      #transmitter = @task  begin Threads.@spawn 
        for i in 1:length(animal.neighbours) 
            competing_neighbour = nothing
            for x in 1:length(animalModel.animals)
                if animalModel.animals[x].pos == animal.pos
                    competing_neighbour = animalModel.animals[x]
                    break
                end
            end

          #  println(competing_neighbour)
    
        competing_neighbour === nothing && return
          if competing_neighbour.status == 0 || competing_neighbour.status == 7 || competing_neighbour.status == 8
              rand(animalModel.rng) < 0.5 && continue
              if rand(animalModel.rng) < competing_neighbour.susceptibility
                animal.status % 2 == 0 ? competing_neighbour.status = 4 : competing_neighbour.status = 3
                competing_neighbour.days_exposed = 1
                competing_neighbour.bacteriaSubmodel.days_exposed = 1
              end
          end
      #end
    end

    #fetch(transmitter)

    end


