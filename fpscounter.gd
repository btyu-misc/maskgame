extends CanvasLayer

var player 

var timer:int = -1
var indica:int = 0
var done:bool = false

func _ready()->void:
	player = $"../CharacterBody2D"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Label.text = str(Engine.get_frames_per_second()) 
	if player.cur_mask == player.Masks.NONE:
		toggle_vis(false, false, false, false)
	elif player.cur_mask == player.Masks.WING:
		toggle_vis(true, false, false, true)
	elif player.cur_mask == player.Masks.HEAVY:
		toggle_vis(false, true, false, false)
	elif player.cur_mask == player.Masks.DASH:
		toggle_vis(false, false, true, true)
	if player.cur_mask == player.Masks.WING:
		if player.can_flap:
			$Uses/Use.visible = true
		else:
			$Uses/Use.visible = false
	if player.cur_mask == player.Masks.DASH:
		if player.can_dash:
			$Uses/Use.visible = true
		else:
			$Uses/Use.visible = false
	if player.selecting:
		print("select is true")
		$Select_Mask.visible = true
		$Select_Mask.self_modulate.a += 0.2
	else:
		$Select_Mask.visible = false
		$Select_Mask.self_modulate.a = 0.
	if Input.is_action_just_pressed("choose_mask"): $Select_Mask.position = Vector2(190., 109.)
	$Select_Mask.position = lerp($Select_Mask.position, Vector2(208., 109.), 0.2)
	#print($"../CharacterBody2D".can_flap)
	
	if (done and timer == -1):
		print(timer)
		timer = 60
	if (timer > 0):
		$White.visible = true
		timer -= 1
	$White.self_modulate.a = (60.-timer)/60.
	
	if (timer == 0):
		get_tree().change_scene_to_file("res://credits.tscn")

func toggle_vis(a, b, c, d):
		$Uses.visible = d
		$Dash.visible = c
		$Heavy.visible = b
		$Wing.visible = a
	


	


func _on_door_body_entered(body: Node2D) -> void:
	done = true
