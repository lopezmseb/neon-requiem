extends EnemyState

func toDeferOnEnter():
	$"../../CollisionShape2D".disabled = true
	$"../../HealthBar".visible = false


func Enter():
	call_deferred("toDeferOnEnter")
	animate.play("Death")
	$"../../Death".play()
	await animate.animation_finished
	$"../../Death".stop()
	get_owner().queue_free()
