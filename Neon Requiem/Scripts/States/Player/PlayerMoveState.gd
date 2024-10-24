extends PlayerState

func Physics_Update(delta):
	if(Input.is_action_just_pressed("dash")):
		onNewState.emit(self, AvailableStates.Dash)
		
	var moveDirection = Input.get_vector("left","right","up","down");
	player.velocity = moveDirection * speed
		
	if(player.velocity):
		animatedSprite.play("Run")
		animatedSprite.flip_h = player.velocity.x <= 0
	else:
		animatedSprite.play("Idle")
	
	player.move_and_slide()
