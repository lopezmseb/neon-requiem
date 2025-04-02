extends BossState

func Enter():
	animate.play("Death")
	$"../../Death".play()
	await animate.animation_finished
	$"../../Death".stop()
	get_owner().queue_free()
