extends Area2D

@export var timeline:DialogicTimeline
@export var fail_timeline:DialogicTimeline
@export var clue:Node2D
var dialog_completed:bool = false
@export var has_clue:bool = false
@export var is_evac_zone:bool = false


func _ready():
	Dialogic.timeline_ended.connect(_on_dialog_ended)
	
func _on_body_entered(body):
	if self.dialog_completed==false:
		if body.is_in_group("Player"):
			body.is_in_dialog=true
			if is_evac_zone:
				if Dialogic.VAR.evac_state==true:
					body.chase_sequence_player.stop()
					Dialogic.start_timeline(timeline)
				else:
					Dialogic.start_timeline(fail_timeline)
			else:
				Dialogic.start_timeline(timeline)

func _on_dialog_ended():
	pass

func _on_body_exited(body):
	if body.is_in_group("Player"):
		if not is_evac_zone:
			self.dialog_completed=true
			if has_clue:
				clue.collect()
