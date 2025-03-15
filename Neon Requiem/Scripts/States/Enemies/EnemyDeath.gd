extends EnemyState

func toDeferOnEnter():
	$"../../CollisionShape2D".disabled = true
	$"../../HealthBar".visible = false


func Enter():
	call_deferred("toDeferOnEnter")
	animate.play("Death")
	await animate.animation_finished
	get_owner().queue_free()
