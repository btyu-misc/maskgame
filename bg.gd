extends TileMap

@export var para:float = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = lerp(position,$"../CharacterBody2D/Camera2D".global_position/para, .5)
	#print(position)
