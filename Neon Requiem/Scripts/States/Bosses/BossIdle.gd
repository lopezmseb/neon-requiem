extends BossState

func Enter():
	animate.play("Idle")

func Update(delta: float):
	animate.play("Idle")


func _on_area_2d_body_entered(body):
	if(body is Player):
		enemy.visible = true
		onNewState.emit(self, AvailableStates.Attack)
