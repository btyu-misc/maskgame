extends Area2D

var collected:bool = false
@export var mask:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if collected:
		$Sprite2D.self_modulate.a -= .02


func _on_body_entered(body: Node2D) -> void:
	if mask == "wing": $"../CharacterBody2D".wing_mask = true
	elif mask == "heavy": $"../CharacterBody2D".heavy_mask = true
	elif mask == "dash": $"../CharacterBody2D".dash_mask = true
	#visible = false
	collected = true
