/obj/item/device/light/sparkler
	name = "sparkler"
	desc = "Be careful not to start a fire!"
	icon = 'icons/obj/sparklers.dmi'
	icon_state = "sparkler-off"
	icon_on = "sparkler-on"
	icon_off = "sparkler-off"
	inhand_image_icon = 'icons/obj/sparklers.dmi'
	item_state = "sparkler-off"
	var/item_on = "sparkler-on"
	var/item_off = "sparkler-off"
	w_class = 1
	density = 0
	anchored = 0
	opacity = 0
	col_r = 0.7
	col_g = 0.3
	col_b = 0.3
	var/datum/effects/system/spark_spread/spark_system
	var/sparks = 7


	New()
		..()
		src.spark_system = unpool(/datum/effects/system/spark_spread)
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)

	attack_self(mob/user as mob)
		if (src.on)
			var/fluff = pick("snuff", "blow")
			user.visible_message("<b>[user]</b> [fluff]s out [src].",\
			"You [fluff] out [src].")
			src.put_out(user)

	attackby(obj/item/W as obj, mob/user as mob)
		if (!src.on && sparks)
			if (istype(W, /obj/item/weldingtool) && W:welding)
				src.light(user, "<span style=\"color:red\"><b>[user]</b> casually lights [src] with [W], what a badass.</span>")

			else if (istype(W, /obj/item/clothing/head/cakehat) && W:on)
				src.light(user, "<span style=\"color:red\">Did [user] just light \his [src] with [W]? Holy Shit.</span>")

			else if (istype(W, /obj/item/device/igniter))
				src.light(user, "<span style=\"color:red\"><b>[user]</b> fumbles around with [W]; sparks erupt from [src].</span>")

			else if (istype(W, /obj/item/device/light/zippo) && W:on)
				src.light(user, "<span style=\"color:red\">With a single flick of their wrist, [user] smoothly lights [src] with [W]. Damn they're cool.</span>")

			else if ((istype(W, /obj/item/match) || istype(W, /obj/item/device/light/candle)) && W:on)
				src.light(user, "<span style=\"color:red\"><b>[user] lights [src] with [W].</span>")

			else if (W.burning)
				src.light(user, "<span style=\"color:red\"><b>[user]</b> lights [src] with [W]. Goddamn.</span>")
		else
			return ..()

	process()
		if (src.on)
			var/turf/location = src.loc
			if (ismob(location))
				var/mob/M = location
				if (M.find_in_hand(src))
					location = M.loc
			var/turf/T = get_turf(src.loc)
			if (T)
				T.hotspot_expose(700,5)

			if(prob(66))
				src.gen_sparks()

	proc/gen_sparks()
		src.sparks--
		spark_system.set_up(1, 0, src)
		src.spark_system.start()
		if(!sparks)
			src.name = "burnt-out sparkler"
			src.put_out()
			src.icon_state = "sparkler-burnt"
			src.item_state = "sparkler-burnt"

		return

	proc/light(var/mob/user as mob, var/message as text)
		if (!src) return
		if (!src.on)
			src.on = 1
			src.damtype = "fire"
			src.force = 3
			src.icon_state = src.icon_on
			src.item_state = src.item_on
			light.enable()
			if (!(src in processing_items))
				processing_items.Add(src)
			if(user)
				user.update_inhands()
		return

	proc/put_out(var/mob/user as mob)
		if (!src) return
		if (src.on)
			src.on = 0
			src.damtype = "brute"
			src.force = 0
			src.icon_state = src.icon_off
			src.item_state = src.item_off
			light.disable()
			if (src in processing_items)
				processing_items.Remove(src)
			if(user)
				user.update_inhands()
		return

/obj/item/storage/sparkler_box
	name = "sparkler box"
	desc = "Have fun!"
	icon = 'icons/obj/sparklers.dmi'
	icon_state = "sparkler_box-close"
	max_wclass = 1
	slots = 5
	spawn_contents = list(/obj/item/device/light/sparkler,/obj/item/device/light/sparkler,/obj/item/device/light/sparkler,/obj/item/device/light/sparkler,/obj/item/device/light/sparkler)
	var/open = 0

	attack_hand(mob/user as mob)
		if (src.loc == user && (!does_not_open_in_pocket || src == user.l_hand || src == user.r_hand))
			if(src.open)
				..()
			else
				src.open = 1
				src.icon_state = "sparkler_box-open"
				playsound(src.loc, "sound/impact_sounds/Generic_Snap_1.ogg", 20, 1, -2)
				boutput(usr, "<span style='color:blue'>You snap open the child-protective safety tape on [src].</span>")
		else
			..()

	attack_self(mob/user as mob)
		if(src.open)
			..()
		else
			src.open = 1
			src.icon_state = "sparkler_box-open"
			playsound(src.loc, "sound/impact_sounds/Generic_Snap_1.ogg", 20, 1, -2)
			boutput(usr, "<span style='color:blue'>You snap open the child-protective safety tape on [src].</span>")