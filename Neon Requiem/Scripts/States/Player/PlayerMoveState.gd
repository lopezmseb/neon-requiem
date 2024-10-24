extends PlayerState

func Physics_Update(delta):
	var moveDirection = Input.get_vector("left","right","up","down");
	player.velocity = moveDirection * speed
		
	if(player.velocity):
		animatedSprite.play("Run")
		animatedSprite.flip_h = player.velocity.x <= 0
	else:
		animatedSprite.play("Idle")
	player.move_and_slide()
