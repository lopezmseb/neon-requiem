extends CharacterBody2D

@export var speed: float = 100;
@onready var animatedSprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	pass

func _physics_process(delta):

