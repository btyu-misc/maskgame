extends Camera2D


@export var randomStrength:float = 20.0
@export var shakeFade:float = 5.0

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func apply_shake():
	shake_strength = randomStrength
	
func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength,shake_strength)+60, rng.randf_range(-shake_strength,shake_strength)-15)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade*delta)
		offset = randomOffset()
	if $"..".selecting:
		zoom = lerp(zoom, Vector2(1.25, 1.25), 0.2)
	if !$"..".selecting:
		zoom = lerp(zoom, Vector2(1, 1), 0.2)

func _on_berdly_disable_special_camera() -> void:
	pass # Replace with function body.


func _on_berdly_heavy_shake() -> void:
	apply_shake()
	print("camera shake")


func _on_berdly_special_camera(x: Variant, y: Variant) -> void:
	pass # Replace with function body.
