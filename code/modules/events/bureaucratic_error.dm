/datum/round_event_control/bureaucratic_error
	name = "Bureaucratic Error"
	typepath = /datum/round_event/bureaucratic_error
	max_occurrences = 1
	weight = 5
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "Randomly opens and closes job slots, along with changing the overflow role."

/datum/round_event/bureaucratic_error
	announce_when = 1

/datum/round_event/bureaucratic_error/announce(fake)
	priority_announce("Недавняя бюрократическая ошибка в отделе органических ресурсов может привести к нехватке кадров в одних отделах и избытку в других.", "Предупреждение о бюрократической ошибке.")

/datum/round_event/bureaucratic_error/start()
	var/list/jobs = SSjob.get_valid_overflow_jobs()
	if(prob(33)) // Only allows latejoining as a single role.
		var/datum/job/overflow = pick_n_take(jobs)
		overflow.spawn_positions = -1
		overflow.total_positions = -1 // Ensures infinite slots as this role. Assistant will still be open for those that cant play it.
		for(var/job in jobs)
			var/datum/job/current = job
			// BANDASTATION EDIT START - STORYTELLER
			//current.total_positions = 0
			current.total_positions = max(current.total_positions + rand(-2,4), 1)
			// BANDASTATION EDIT END - STORYTELLER
		return
	// Adds/removes a random amount of job slots from all jobs.
	for(var/datum/job/current as anything in jobs)
		current.total_positions = max(current.total_positions + rand(-2,4), 1) // BANDASTATION EDIT - STORYTELLER
