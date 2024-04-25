extends Node2D

func _ready():
	$AnimationPlayer.play("Default")
	show()
	
func collect():
	$AnimationPlayer.play("Collect")
	await get_tree().create_timer(0.5).timeout
	hide()
