/obj/effect/forcefield/wizard/heretic
	name = "labyrinth pages"
	desc = "A field of papers flying in the air, repulsing heathens with impossible force."
	icon_state = "lintel"
	initial_duration = 8 SECONDS

/obj/effect/forcefield/wizard/heretic/Bumped(mob/living/bumpee)
	. = ..()
	if(!istype(bumpee) || IS_HERETIC_OR_MONSTER(bumpee))
		return
	var/throwtarget = get_edge_target_turf(loc, get_dir(loc, get_step_away(bumpee, loc)))
	bumpee.safe_throw_at(throwtarget, 10, 1, force = MOVE_FORCE_EXTREMELY_STRONG)
	visible_message(span_danger("[src] repulses [bumpee] in a storm of paper!"))

///A heretic item that spawns a barrier at the clicked turf, 3 uses
/obj/item/heretic_labyrinth_handbook
	name = "labyrinth handbook"
	desc = "Книга содержит в себе законы и правила Запертого Лабиринта, написанные неизвестным веществом. Ее страницы корчатся и напрягаются, пытаясь вырваться и убежать."
	icon = 'icons/obj/service/library.dmi'
	icon_state = "heretichandbook"
	force = 10
	damtype = BURN
	worn_icon_state = "book"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("bashes", "curses")
	attack_verb_simple = list("bash", "curse")
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound = 'sound/items/handling/book_pickup.ogg'
	///what type of barrier do we spawn when used
	var/barrier_type = /obj/effect/forcefield/wizard/heretic
	///how many uses do we have left
	var/uses = 3

/obj/item/heretic_labyrinth_handbook/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user))
		return
	. += span_hypnophrase("Материализует барьер, который пропускает только вас. Действует 8 секунд.")
	. += span_hypnophrase("Осталось использований: <b>[uses]</b>.")

/obj/item/heretic_labyrinth_handbook/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(HAS_TRAIT(interacting_with, TRAIT_COMBAT_MODE_SKIP_INTERACTION))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/heretic_labyrinth_handbook/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!IS_HERETIC(user))
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			to_chat(human_user, span_userdanger("Ваш разум начинает гореть, когда вы заглядываете в эту книгу, словно весь ваш мозг окутало пламя!"))
			human_user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 30, 190)
			human_user.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
			human_user.dropItemToGround(src)
		return ITEM_INTERACT_BLOCKING

	var/turf/turf_target = get_turf(interacting_with)
	if(locate(barrier_type) in turf_target)
		user.balloon_alert(user, "нет места!")
		return ITEM_INTERACT_BLOCKING
	turf_target.visible_message(span_warning("Бумажный шторм материализуется!"))
	new /obj/effect/temp_visual/paper_scatter(turf_target)
	playsound(turf_target, 'sound/effects/magic/smoke.ogg', 30)
	new barrier_type(turf_target, user)
	uses--
	if(uses <= 0)
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] распадается на части, оставляя за собой пепел и пыль!"))
		qdel(src)
	return ITEM_INTERACT_SUCCESS
