extends Control
@export var player:CharacterBody2D
@onready var battery_amount:TextureRect = $MarginContainer/BatteryHudContainer/Margin/BatteryAmount
@onready var battery_hud_container = $MarginContainer/BatteryHudContainer
@onready var game_over_container = $GameOverContainer
@onready var audio_stream_player:AudioStreamPlayer = $AudioStreamPlayer
@onready var gameover_animation_player = $GameOverContainer/AnimationPlayer
@onready var win_screen = $WinScreen
@onready var win_screen_animation_player = $WinScreen/AnimationPlayer

var game_over_music:AudioStream = preload("res://Assets/Audio/Music/LightsOutGameOverBraam.ogg")

var game_just_over:bool
var game_over:bool
var game_won:bool
var game_restartable:bool


func _ready():
	Dialogic.VAR.fled = false
	Dialogic.VAR.game_over = false
	Dialogic.VAR.game_won = false
	Dialogic.VAR.evac_state = false
	Dialogic.VAR.hunted = false
	
	game_over_container.hide()
	
	
func _process(delta):
	game_over = Dialogic.VAR.game_over
	game_won = Dialogic.VAR.game_won
	battery_amount.size.x=player.flashlight_battery
	if game_over:
		battery_hud_container.hide()
		game_over_container.show()
		
		if not game_just_over:
			gameover_animation_player.play("GameOver")
			audio_stream_player.stream=game_over_music
			audio_stream_player.play()
			game_just_over=true
			await get_tree().create_timer(1.5).timeout
			game_restartable=true
			
	if game_won:
		battery_hud_container.hide()
		win_screen.show()
		if not game_just_over:
			win_screen_animation_player.play("GameOver")
			audio_stream_player.stream=game_over_music
			audio_stream_player.play()
			game_just_over=true
			await get_tree().create_timer(1.5).timeout
			game_restartable=true
	
	if game_restartable:
		if Input.is_action_just_pressed("dialogic_default_action"):
			get_tree().reload_current_scene()
