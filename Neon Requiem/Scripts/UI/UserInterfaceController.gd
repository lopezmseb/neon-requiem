extends CanvasLayer

@export var level: int = 1

func _process(delta):
	if(level):
		$Level.text = "Floor: {level}".format({"level": level})

func setPlayer(player):
	$PlayerHealthBar.player = player
	$CooldownTimers.player = player
