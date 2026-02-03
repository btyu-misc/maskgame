extends Node2D

var timer:int = -1
var indica:int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Input.is_action_just_pressed("continue") and timer == -1):
		print(timer)
		timer = 60
	if (timer > 0):
		$CanvasLayer/Sprite2D3.visible = true
		timer -= 1
	$CanvasLayer/Sprite2D3.self_modulate.a = (60.-timer)/60.
	
	if (timer == 0):
		get_tree().change_scene_to_file("res://world.tscn")
	indica = (indica + 1)%12
	if indica == 0:
		if $CanvasLayer/Sprite2D2.visible: $CanvasLayer/Sprite2D2.visible = false
		else: $CanvasLayer/Sprite2D2.visible = true
