extends EnemyState

func _on_health_component_health_depleted(owner):
	onNewState.emit(self, AvailableStates.Death)


func _on_static_enemy_on_damage(allowAnimation: bool) -> void:
	return
