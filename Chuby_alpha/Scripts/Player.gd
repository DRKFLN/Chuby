extends KinematicBody2D

const JUMP_STRENGTH := -2
const INVULNERABLE_TIME := 0.5
const PUSH_DISTANCE := 35.0
const PUSH_SPEED := 250.0

signal hp_changed
signal points_changed

var speed := 200
var gravity := Vector2.DOWN * 1.5
var jump_velocity :=0.0
var jump := 0
var hp := 3
var invulnerable_time := 0.0
var push_point = null
var points := 0

onready var ray_cast_down := $RayCastDown
onready var animation_player := $AnimationPlayer

func _ready() -> void:
	call_deferred("change_hp", 0)
	call_deferred("change_points", points)
	
func _physics_process(delta: float):
	if push_point and global_position.distance_to(push_point) >= 5:
		if move_and_collide(global_position.direction_to(push_point) * PUSH_SPEED * delta):
			push_point = null
			return true
		return
	elif push_point:
		push_point = null
	var move_direction = gravity
	var x_input = Input.get_action_strength("left") - Input.get_action_strength("right")
	if Input.is_action_pressed("left"):
		move_direction.x = -1	
		$AnimatedSprite.flip_h = false
	elif Input.is_action_pressed("right"):
		move_direction.x = 1	
		$AnimatedSprite.flip_h = true
	if x_input != 0:
		$AnimatedSprite.playing = true
	if x_input == 0:
		$AnimatedSprite.playing = false
		$AnimatedSprite.set_frame(1)
	if Input.is_action_just_pressed("space") and jump < 1:
		jump += 1
		jump_velocity = JUMP_STRENGTH
		
	if is_on_floor():
		jump = 0
		
	if jump_velocity < 0.0:
		jump_velocity += gravity.y * delta * 4
		move_direction.y = jump_velocity
	
	if move_direction.y > 0 and ray_cast_down.is_colliding():
		var enemy = ray_cast_down.get_collider()
		hit_enemy(enemy)
	move_and_slide(move_direction * speed, Vector2.UP)
	if invulnerable_time >= 0:
		invulnerable_time -= delta
		animation_player.play("damage")
	else:
		animation_player.seek(0, true)
		animation_player.stop()
		
func hit_enemy(bbot: Node2D):
	if bbot.has_method("die"):
		bbot.die()
	jump_velocity = JUMP_STRENGTH/1.5
	
func take_damage(damage: int, attack_direction: Vector2):
	if invulnerable_time >= 0:
		return
	push_point = global_position + ((attack_direction + Vector2(0, -1)) * PUSH_DISTANCE)
	change_hp(-damage)
	move_and_slide(attack_direction * speed, Vector2.UP)
	invulnerable_time = INVULNERABLE_TIME
	
func change_hp(diff: int):
	hp += diff
	emit_signal("hp_changed", hp)
	if hp <= 0:
		dead()

func change_points(diff: int):
	points += diff
	emit_signal("points_changed", points)

func pick_up_item(pickable: Pickable):
	if pickable.is_picked_up:
		return
	if pickable is Coin:
		change_points(1)
#	if pickable is DeathArea:
#		dead()
	pickable.pick_up()

func dead():
	Main.start_new_game()
