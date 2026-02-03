extends Node2D

var timer:int = 120
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= 1
	if timer < 1: $CanvasLayer/Sprite2D2.visible = true
	
