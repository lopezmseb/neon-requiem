extends BossState

func Enter():
	animate.play("Death")
	await animate.animation_finished
	get_owner().queue_free()
