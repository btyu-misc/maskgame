extends CharacterBody2D


var SPEED:int = 90
const JUMP_VELOCITY = -190.0
var gravity_scale:float = 800./1920.
var gravity:Vector2

@export var wing_mask:bool = true
@export var heavy_mask:bool = false
@export var dash_mask:bool = false


#jumping
var jump_timer:int = 0
var jump_const:int = 5
var jumping:bool = false

#wall jumping
var last_dir:int
var wall_just_jumped:bool
var air_lerp_const:float = .03
var wall_timer:int = 0
var wall_cool_down:int = 0

var last_vel_dir:int

var airborne:int = 0
var airborne_const:int = 120

enum Masks {
	NONE,
	WING,
	HEAVY,
	DASH
}

var cur_mask

#winged mask
var flutter_timer:int = 120
var can_flap:bool = true

#heavy mask
var is_heavy:bool = false
var heavy_equipped:bool = false
var heavy_windup:int = 45

#dash mask
var can_dash:bool = true
var dash_timer:int = 0

var selecting:bool = false

var death_timer:int = 40

func _ready():
	gravity.x = 0
	gravity.y = gravity_scale*(float)(DisplayServer.window_get_size().x)
	cur_mask = Masks.NONE

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#print(last_vel_dir)
	#print(is_on_wall())
	
	#print(air_lerp_const)
	
	if last_vel_dir < 0: 
		$Sprite2D/Body.set_frame(1)
		$Sprite2D/None.set_frame(1)
		$Sprite2D/Wing.set_frame(1)
		$Sprite2D/Dash.set_frame(1)
		$Sprite2D/Heavy.position = Vector2(-1, -4)
	elif last_vel_dir > 0: 
		$Sprite2D/Body.set_frame(0)
		$Sprite2D/None.set_frame(0)
		$Sprite2D/Wing.set_frame(0)
		$Sprite2D/Dash.set_frame(0)
		$Sprite2D/Heavy.position = Vector2(0, -4)
	
	#wall jump helper
	if wall_cool_down == 0:
		if (velocity.x > 0.01): last_vel_dir = 1
		elif (velocity.x < -0.01): last_vel_dir = -1
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor():
		move()
	else:
		move_air()	
		
	#print(flutter_timer)
	#airborne logic
	if not is_on_floor():
		velocity += gravity * delta
		airborne += 1
		if velocity.y > 0:
			if jumping: jumping = false
			airborne += 1
			
		if jumping and Input.is_action_just_released("jump"): velocity.y = 0
		if Input.is_action_just_pressed("jump") and can_flap and cur_mask == Masks.WING: 
			velocity.y = JUMP_VELOCITY
			can_flap = false
			$Sprite2D.scale = Vector2(1.5,.5)
			print("flap")
		#mid-air mask actions
		#print(velocity.y)
		if Input.is_action_pressed("action"):
			if cur_mask == Masks.WING and flutter_timer > 0:
				if velocity.y > 40: velocity.y = move_toward(velocity.y, 40, 15)
				else: velocity.y = clamp(velocity.y, -2000, 40)
				flutter_timer -= 1
				
			elif cur_mask == Masks.HEAVY:
				if (heavy_windup > 0): 
					heavy_windup -= 1
					$Sprite2D.scale.x = move_toward($Sprite2D.scale.x, 1., 0.1)
					$Sprite2D.scale.y = move_toward($Sprite2D.scale.y, 1., 0.1)
					velocity.y = 0
					velocity.x = 0
				else:
					velocity.y = move_toward(velocity.y, 800, 100)
					velocity.x = move_toward(velocity.x, 0, 10)
		else:
			#cancel animation if necessary
			heavy_windup = 45
		if Input.is_action_just_pressed("action") and cur_mask == Masks.DASH and can_dash:
			dash_timer = 8
			can_dash = false
		if dash_timer > 0:
			velocity.y = 0
			velocity.x = move_toward(velocity.x, last_vel_dir*500, 200)
			$Sprite2D.scale.x = move_toward($Sprite2D.scale.x, 1.8, 0.3)
			$Sprite2D.scale.y = move_toward($Sprite2D.scale.y, .5, 0.3)
			dash_timer -= 1
	else:
		if (airborne > 0): 
			#squish when hitting the ground
			$Sprite2D.scale = Vector2(1 + .6, 1 - .6)
		airborne = 0
		flutter_timer = 120
		can_flap = true
		can_dash = true
		if heavy_windup == 0:
			heavy_shake.emit()
			print("emitted heavy shake")
		heavy_windup = 45
		
		#sprint
		if Input.is_action_pressed("action") and cur_mask == Masks.DASH:
			SPEED = 150
		else:
			SPEED = 90
	
	#buffer so jumping feels more responsive
	if Input.is_action_just_pressed("jump"):
		jump_timer = jump_const
		
	
	#jump functionality
	if jump_timer > 0 and is_on_floor(): 
		jump()
		jump_timer = 0
	
	#wall_jump functionality
	if is_on_wall():
		wall_cool_down = 5
	else:
		wall_cool_down = clamp(wall_cool_down - 1, 0, 5)
	if jump_timer > 0 and wall_cool_down > 0 and !is_on_floor():
		#if (Input.get_axis("move_left", "move_right") == 0): last_dir = 0
		if cur_mask == Masks.NONE: wall_jump()
	if wall_just_jumped:
		wall_just_jumped = false
	air_lerp_const = lerp(air_lerp_const, 0.3, 0.012)
	wall_timer = clamp(wall_timer - 1, 0, 7)
	if wall_timer != 0 and !Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right") and (!Input.is_action_pressed("jump") or wall_timer > 6):
		print("wall normal jump")
		air_lerp_const = lerp(air_lerp_const, 0.3, 0.1)
	
	
	#squash and stretch code
	if jumping:
		$Sprite2D.scale = lerp($Sprite2D.scale, Vector2(.80, 1.20), 0.4)
	elif !is_on_floor(): 
		$Sprite2D.scale = lerp($Sprite2D.scale, Vector2(.80, 1.20), 0.2)
	if is_on_floor():
		$Sprite2D.scale = lerp($Sprite2D.scale, Vector2(1., 1.), 0.2)
	
	#print(Input.is_action_pressed("choose_mask"))
	if Input.is_action_just_pressed("choose_mask") or selecting:
		selecting = true
		Engine.time_scale = move_toward(Engine.time_scale, 0.05, 0.15)
		if Input.is_action_just_pressed("no_mask"):
			cur_mask = Masks.NONE
			$Sprite2D/None.visible = true
			$Sprite2D/Wing.visible = false
			$Sprite2D/Heavy.visible = false
			$Sprite2D/Dash.visible = false
			selecting = false
		elif wing_mask and Input.is_action_just_pressed("wing_mask"):
			cur_mask = Masks.WING
			$Sprite2D/None.visible = false
			$Sprite2D/Wing.visible = true
			$Sprite2D/Heavy.visible = false
			$Sprite2D/Dash.visible = false
			selecting = false
		elif heavy_mask and Input.is_action_just_pressed("heavy_mask"):
			cur_mask = Masks.HEAVY
			$Sprite2D/None.visible = false
			$Sprite2D/Wing.visible = false
			$Sprite2D/Heavy.visible = true
			$Sprite2D/Dash.visible = false
			selecting = false
		elif dash_mask and Input.is_action_just_pressed("dash_mask"):
			cur_mask = Masks.DASH
			$Sprite2D/None.visible = false
			$Sprite2D/Wing.visible = false
			$Sprite2D/Heavy.visible = false
			$Sprite2D/Dash.visible = true
			selecting = false
		elif Input.is_action_just_released("choose_mask"):
			selecting = false
	if selecting == false:
		Engine.time_scale = clamp(move_toward(Engine.time_scale, 1, 0.05), 0, 60)
		Engine.physics_ticks_per_second = clamp(move_toward(Engine.physics_ticks_per_second, 60, 3), 0, 60)

	move_and_slide()
	if jump_timer > 0: 
		jump_timer -= 1
	
func jump():
	# Handle jump.
	velocity.y = JUMP_VELOCITY
	#velocity.x += 0.05*last_dir
	jumping = true
	#if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		#velocity.y = 0
		
		
func wall_jump():
	if last_vel_dir < 0: 
		print("right wall jump")
		velocity.y = JUMP_VELOCITY*1.
		velocity.x = 150
	elif last_vel_dir > 0: 
		print("left wall jump")
		velocity.y = JUMP_VELOCITY*1.
		velocity.x = -150
	$Sprite2D.scale = Vector2(1.5, .5)
	wall_just_jumped = true
	air_lerp_const = 0.01
	wall_timer = 7

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

signal heavy_shake()
