extends CharacterBody2D

@export var walk_speed: float = 100.0
@export var dash_speed: float = 400.0
@export var dash_duration_seconds: float = 0.3
@export var dash_cooldown_seconds: float = 2.0
@export var jump_up_velocity: float = -400.0

@onready var player_node = get_tree().get_root().get_node("bg/player")

var gravity_force = ProjectSettings.get_setting("physics/2d/default_gravity")
var starting_position: Vector2

const STATE_CHASING = 0
const STATE_DASHING = 1
const STATE_JUMPING = 2

var current_state = STATE_CHASING

var dash_cooldown_timer = 0.0
var dash_duration_timer = 0.0

func _ready():
	starting_position = global_position

func _physics_process(delta_time):
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta_time
	if dash_duration_timer > 0:
		dash_duration_timer -= delta_time

	if current_state == STATE_CHASING:
		if not is_on_floor():
			velocity.y += gravity_force * delta_time

		if not player_node:
			return

		var direction_to_player = player_node.global_position - global_position
		direction_to_player = direction_to_player.normalized()
		velocity.x = direction_to_player.x * walk_speed

		if dash_cooldown_timer <= 0 and global_position.distance_to(player_node.global_position) < 300:
			current_state = STATE_DASHING
			dash_duration_timer = dash_duration_seconds
			dash_cooldown_timer = dash_cooldown_seconds
			velocity = direction_to_player * dash_speed

	elif current_state == STATE_DASHING:
		velocity = velocity.normalized() * dash_speed

		if dash_duration_timer <= 0:
			current_state = STATE_CHASING

	elif current_state == STATE_JUMPING:
		velocity.y = jump_up_velocity
		current_state = STATE_CHASING

	move_and_slide()

func _on_hitbox_body_entered(body):
	if body.name == "player":
		body.global_position = body.start_position
		body.velocity = Vector2.ZERO

		global_position = starting_position
		velocity = Vector2.ZERO



