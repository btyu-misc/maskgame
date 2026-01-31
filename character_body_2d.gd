extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0
var gravity_scale:float = 3000./1920.
var gravity:Vector2

func _ready():
	gravity.x = 0
	gravity.y = gravity_scale*(float)(DisplayServer.window_get_size().x)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	print(gravity)
	if not is_on_floor():
		velocity += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
