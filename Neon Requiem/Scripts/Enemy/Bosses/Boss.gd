extends CharacterBody2D
@onready var color_component: ColorComponent = $ColorComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var level = 0

# Change the colour of the boss outline
func switchColors():
	if(color_component.color == COLORS.OFFENSIVE):
		var shaderMaterial = ShaderMaterial.new()
		shaderMaterial.shader = COLORS.DEFENSIVE_SHADER
		shaderMaterial.set_shader_parameter("colourBlindMode", int(GlobalVariables.colourBlind))
		animated_sprite_2d.material = shaderMaterial
		color_component.color = COLORS.DEFENSIVE
	else:
		var shaderMaterial = ShaderMaterial.new()
		shaderMaterial.shader = COLORS.OFFENSIVE_SHADER
		shaderMaterial.set_shader_parameter("colourBlindMode", int(GlobalVariables.colourBlind))
		animated_sprite_2d.material = shaderMaterial
		color_component.color = COLORS.OFFENSIVE


func _ready():
	GlobalSignals.onColorChange.connect(switchColors)
	ScaleBoss()

# Scale the boss health in proportion to the amount of players
func ScaleBoss():
	var playerCount = get_tree().root.find_children("*", "Player", true, false).size()
	$HealthComponent/HealthAdditiveUpgrade.level = clampf(floor(level/6)  + playerCount, 0, 999)

func _physics_process(delta):
	pass

# Stop the timer before it gets deleted
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		for i in find_children("*", "Timer"):
			var timer = i as Timer
			timer.stop()

# Display damage numbers
func onHealthDamage(attack):
	var number = Label.new()
	var startingPosition: Control = $HealthBar
	number.position = startingPosition.position  - Vector2(startingPosition.position.x/2 -10 ,15)
	number.text = str(UIHelpers.formatFloat(attack))
	number.z_index = 50
	number.label_settings = LabelSettings.new()
	
	var color = "#FFF"
	
	number.label_settings.font = load("res://Assets/Theme/Better VCR 9.0.1.ttf")
	number.label_settings.font_color = color
	number.label_settings.font_size = 10
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 5
	

	add_child(number)
	
	await get_tree().create_timer(0.10).timeout
	number.pivot_offset = Vector2(number.size/2)
	
	var tween = create_tween()

	tween.tween_property(number, "position:y", number.position.y - 10, 0.15).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(number, "position:y", number.position.y, 0.15).set_ease(Tween.EASE_IN).set_delay(0.15)
	tween.tween_property(number, "scale", Vector2.ZERO, 0.15).set_ease(Tween.EASE_IN).set_delay(0.2)
	
	await tween.finished
	
	number.queue_free()
