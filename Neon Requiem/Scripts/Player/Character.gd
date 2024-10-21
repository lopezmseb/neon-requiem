extends CharacterBody2D

@export var speed: float = 100;
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	pass

func _physics_process(delta):
	getMovement(delta)
	
func getMovement(delta): 
	if(Input.is_action_pressed("up")):
		velocity.y = -speed;
	elif(Input.is_action_pressed("down")):
		velocity.y = speed;
	else:
		velocity.y = 0;
	
	if(Input.is_action_pressed("right")):
		velocity.x= speed;
	elif(Input.is_action_pressed("left")):
		velocity.x = -speed;
	else:
		velocity.x = 0;

	move_and_slide()
		
