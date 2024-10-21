extends EnemyState

func Physics_Update(delta):
	# Note: This approach is kinda buggy. Refactor into something better later
	var playerDirection = player.global_position - enemy.global_position

	if(playerDirection.length() > 100):
		onNewState.emit(self, AvailableStates.Idle)
	elif(playerDirection.length() > 50):
		enemy.velocity = playerDirection.normalized() * speed
	else:
		enemy.velocity = Vector2.ZERO
