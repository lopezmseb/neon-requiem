extends BossState

func Enter():
#	await get_tree().create_timer(4).timeout
	print("OnDeath")
	get_owner().queue_free()
