extends CharacterBody2D


const SPEED:int = 90
const JUMP_VELOCITY = -190.0
var gravity_scale:float = 800./1920.
var gravity:Vector2


#jumping
var jump_timer:int = 0
var jump_const:int = 5
var jumping:bool = false

#wall jumping
var last_dir:int
var wall_just_jumped:bool
var air_lerp_const:float = .03

var airborne:int = 0
var airborne_const:int = 120

#winged mask
var flutter_timer:int = 120
var can_flap:bool = true

#heavy mask
var is_heavy:bool = false

#dash mask
var can_dash:bool = true

var death_timer:int = 40

func _ready():
	gravity.x = 0
	gravity.y = gravity_scale*(float)(DisplayServer.window_get_size().x)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"): last_dir = Input.get_axis("move_left", "move_right")
	
	#print(gravity)
	if not is_on_floor():
		velocity += gravity * delta
		airborne += 1
		if velocity.y > 0:
			if jumping: jumping = false
			airborne += 1
			
		if jumping and Input.is_action_just_released("jump"): velocity.y = 0
	else:
		if (airborne > 0): 
			#$Sprite2D.scale = Vector2(1 + (.5*airborne)/airborne_const, 1 - (.5*airborne)/airborne_const)
			$Sprite2D.scale = Vector2(1 + .5, 1 - .5)
		airborne = 0
	
	#buffer so jumping feels more responsive
	if Input.is_action_just_pressed("jump"):
		jump_timer = jump_const
		
	
	#jump functionality
	if jump_timer > 0 and is_on_floor(): 
		jump()
		jump_timer = 0
	
	#wall_jump functionality
	if Input.is_action_just_pressed("jump") and is_on_wall() and !is_on_floor():
		wall_jump()
	if wall_just_jumped:
		wall_just_jumped = false
	air_lerp_const = lerp(air_lerp_const, 0.3, 0.1)
		
	
	
	if jumping:
		$Sprite2D.scale = lerp($Sprite2D.scale, Vector2(.65, 1.35), 0.4)
	elif !is_on_floor(): 
		$Sprite2D.scale = lerp($Sprite2D.scale, Vector2(.65, 1.35), 0.2)
	if is_on_floor():
		$Sprite2D.scale = lerp($Sprite2D.scale, Vector2(1., 1.), 0.2)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor():
		move()
	else:
		move_air()
		
	if Input.is_action_pressed("choose_mask"):
		Engine.time_scale = move_toward(Engine.time_scale, 0.05, 0.05)
	else:
		Engine.time_scale = move_toward(Engine.time_scale, 1, 0.05)

	move_and_slide()
	if jump_timer > 0: 
		jump_timer -= 1
	
func jump():
	# Handle jump.
	velocity.y = JUMP_VELOCITY
	jumping = true
	#if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		#velocity.y = 0
		
		
func wall_jump():
	if last_dir < 0: 
		print("right wall jump")
		velocity.y = JUMP_VELOCITY*1.
		velocity.x = 200
	elif last_dir > 0: 
		print("left wall jump")
		velocity.y = JUMP_VELOCITY*1.3
		velocity.x = -200
	$Sprite2D.scale = Vector2(1.5, .5)
	wall_just_jumped = true
	air_lerp_const = 0.01

func move():
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = lerp(velocity.x, (direction * SPEED), .4)
	else:
		velocity.x = lerp((velocity.x), 0., .4)
		
func move_air():
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = lerp(velocity.x, (direction * SPEED), air_lerp_const)
	else:
		velocity.x = lerp((velocity.x), 0., air_lerp_const)
		
func death():
	special_camera.emit(position.x, position.y)

func respawn():
	disable_special_camera.emit()

signal special_camera(x, y)

signal disable_special_camera()
