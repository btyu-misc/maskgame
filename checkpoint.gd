extends Area2D

var frame_num:int
var play:bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if play:
		#print(frame_num)
		$Sprite2D.set_frame(frame_num/4)
		frame_num = clamp(frame_num + 1, 0, 16)

func _on_body_entered(body: Node2D) -> void:
	print("playing anim")
	$"../../CharacterBody2D".last_checkpoint = global_position
	play = true
