extends CharacterBody2D

var mov_vector: Vector2
var speed: float = 40
var facing: int = 1
var state:int = 0
enum DIRECTIONS {LEFT,RIGHT}
enum STATES {IDLE,WALK}
var is_in_dialog:bool = false
var flashlight_battery:int
var game_over:bool = false
var game_won:bool = false
var hunted:bool = false

var mouse_pos: Vector2
@onready var light_rotator = $LightRotator
@onready var sprite_2d = $Sprite2D
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var timer = $Timer
@onready var flashlight_light:PointLight2D = $LightRotator/PointLight2D
@onready var footstep_player = $FootstepPlayer
@onready var light_flicker_controller:AnimationPlayer = $LightFlickerController
@onready var hunted_timer = $HuntedTimer
@onready var chase_sequence_player = $ChaseSequencePlayer


@export var out_of_battery_timeline:DialogicTimeline
@export var hunted_timeline:DialogicTimeline


func _ready():
	Dialogic.VAR.flashlight_battery = Dialogic.VAR.max_battery_percent
	Dialogic.VAR.clues_found = 0
	
	facing=DIRECTIONS.RIGHT
	Dialogic.timeline_ended.connect(_on_dialog_ended)
	randomize()

func _process(delta):
	if Dialogic.VAR.fled == true:
		$CollisionShape2D.disabled=true
		hide()
	footstep_player.pitch_scale=randf_range(0.9,1.1)
	game_over = Dialogic.VAR.game_over
	game_won = Dialogic.VAR.game_won
	
	if Dialogic.VAR.hunted:
		if not hunted:
			Dialogic.VAR.flashlight_battery = Dialogic.VAR.max_battery_percent
			chase_sequence_player.play()
			hunted_timer.start()
			hunted = true
	if not game_over and not game_won:
		flashlight_battery = Dialogic.VAR.flashlight_battery
		
		if not is_in_dialog:
			mouse_pos.y =  get_global_mouse_position().y
		if flashlight_battery > 0:
			flashlight_light.show()
		else:
			flashlight_light.hide()
			
		if mov_vector==Vector2.ZERO:
			state=STATES.IDLE
		else:
			state=STATES.WALK
		
		if light_rotator.rotation_degrees <-90:
			light_rotator.rotation_degrees += 360
			print(light_rotator.rotation_degrees)
		if mov_vector.x>0:
			facing=DIRECTIONS.RIGHT
		elif mov_vector.x<0:
			facing=DIRECTIONS.LEFT
			
			
		match facing:
			DIRECTIONS.RIGHT:
				mouse_pos.x=position.x+15
				light_rotator.position=light_rotator.position.lerp(Vector2(6,3),0.1)
				light_rotator.look_at(mouse_pos)
				light_rotator.rotation_degrees=clamp(fmod(light_rotator.rotation_degrees, 360), -60, 60)
				match state:
					STATES.IDLE:
						animation_player.play("idle_right")
					STATES.WALK:
						animation_player.play("walk_right")
			DIRECTIONS.LEFT:
				mouse_pos.x=position.x-15
				light_rotator.position=light_rotator.position.lerp(Vector2(-6,3),0.1)
				light_rotator.look_at(mouse_pos)
				light_rotator.rotation_degrees=clamp(fmod(light_rotator.rotation_degrees, 360), 120,240)
				match state:
					STATES.IDLE:
						animation_player.play("idle_left")
					STATES.WALK:
						animation_player.play("walk_left")
		if not hunted:			
			if flashlight_battery < 5:
				light_flicker_controller.play("Flicker")
			else:
				light_flicker_controller.play("Steady")
		else:
			light_flicker_controller.play("Flicker")

func _physics_process(delta):
	if not game_over and not game_won:
		if not is_in_dialog:
			mov_vector.x=Input.get_axis("left","right")
			mov_vector.y=Input.get_axis("up","down")
		else:
			mov_vector=Vector2.ZERO
		mov_vector=mov_vector.normalized()
		velocity = mov_vector*speed
		move_and_slide()

func _on_dialog_ended():
	is_in_dialog = false
	

	


func _on_timer_timeout():
	if not game_over and not game_won:
		if not is_in_dialog:
			if Dialogic.VAR.flashlight_battery > 0:
				Dialogic.VAR.flashlight_battery-=1
			else :
				is_in_dialog=true
				Dialogic.start_timeline(out_of_battery_timeline)
		


func _on_hunted_timer_timeout():
	if not game_over and not game_won:
		if not is_in_dialog:
			rotation_degrees=90
			$LightRotator.hide()
			is_in_dialog=true
			Dialogic.start_timeline(hunted_timeline)
