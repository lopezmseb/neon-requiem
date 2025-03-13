extends EnemyState

func Enter():
	$"../../CollisionShape2D".disabled = true
	$"../../HealthBar".visible = false
	animate.play("Death")
	await animate.animation_finished
	get_owner().queue_free()
