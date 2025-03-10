extends AudioStreamPlayer

@onready var beat_notifier = $"../BeatNotifier"

signal onBeat

func _ready():
	beat_notifier.beats(2).connect(func(count):
		COLORS.enemyShader = COLORS.OFFENSIVE_SHADER if COLORS.enemyShader == COLORS.DEFENSIVE_SHADER else COLORS.DEFENSIVE_SHADER
	)
		
	play()
