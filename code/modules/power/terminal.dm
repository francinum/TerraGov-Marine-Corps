// the underfloor wiring terminal for the APC
// autogenerated when an APC is placed
// all conduit connects go to this object instead of the APC
// using this solves the problem of having the APC in a wall yet also inside an area

/obj/machinery/power/terminal
	name = "terminal"
	icon_state = "term"
	desc = "It's an underfloor wiring terminal for power equipment."
	level = 1
	anchored = TRUE
	layer = WIRE_TERMINAL_LAYER
	resistance_flags = UNACIDABLE
	var/obj/machinery/power/master = null


// Needed so terminals are not removed from machines list.
// Powernet rebuilds need this to work properly.
/obj/machinery/power/terminal/process()
	return TRUE

/obj/machinery/power/terminal/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	if(level == 1)
		hide(T.intact_tile)

/obj/machinery/power/terminal/Destroy()
	if(master)
		master.disconnect_terminal()
		master = null
	return ..()

/obj/machinery/power/terminal/hide(i)
	if(i)
		invisibility = INVISIBILITY_MAXIMUM
		icon_state = "term-f"
	else
		invisibility = 0
		icon_state = "term"


/obj/machinery/power/proc/can_terminal_dismantle()
	. = FALSE


/obj/machinery/power/apc/can_terminal_dismantle()
	. = FALSE
	if(opened)
		. = TRUE


/obj/machinery/power/terminal/deconstruct(mob/living/user)
	var/turf/T = get_turf(src)
	if(T.intact_tile)
		to_chat(user, "<span class='warning'>You must first expose the power terminal!</span>")
		return FALSE

	if(master && !master.can_terminal_dismantle())
		return FALSE

	user.visible_message("<span class='notice'>[user] starts removing [master]'s wiring and terminal.</span>",
		"<span class='notice'>You start removing [master]'s wiring and terminal.</span>")

	playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
	if(!do_after(user, 50, TRUE, src, BUSY_ICON_BUILD))
		return FALSE

	if(master && !master.can_terminal_dismantle())
		return FALSE

	if(prob(50) && electrocute_mob(user, powernet, src, 1, TRUE))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		return FALSE

	new /obj/item/stack/cable_coil(get_turf(src), 10)
	user.visible_message("<span class='notice'>[user] removes [src]'s wiring and terminal.</span>",
			"<span class='notice'>You remove [src]'s wiring and terminal.</span>")
	qdel(src)

	. = TRUE
