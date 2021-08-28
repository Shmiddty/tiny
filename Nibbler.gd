extends KinematicBody2D

var UP = Vector2(0, -1)
var h = 4.0
var w = 4.0
var g = h * 2
var cf = 0.18
var sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = get_node("Sprite")

var friction = Vector2(cf, 0)
var jump = Vector2(0, -h * 24)
var gravity = Vector2(0, g)
var acceleration = Vector2(0, 0)
var run = Vector2(w, 0)
var glide = Vector2(w/2, 0)
var maxA = Vector2(w, g * 12)
var maxV = Vector2(w * 12, h * 24)
var velocity = Vector2(0, 0)
var prevVelocity
var floored
var floating = 0
var jumps = 0
var maxJumps = 1

func vClamp(vec, minV, maxV):
	return Vector2(clamp(vec.x, minV.x, maxV.x), clamp(vec.y, minV.y, maxV.y))

func vLerp(initial, target, step):
	return Vector2(lerp(initial.x, target.x, step), lerp(initial.y, target.y, step))

# I could just lerp the velocity, and not worry about acceleration, I suppose.
func _physics_process(delta):
	prevVelocity = velocity

	if is_on_floor():
		floored = true
		floating = 0
		jumps = maxJumps
	elif floating > 2:
		floored = false
	else:
		floating += 1
	
	if Input.is_action_pressed("player_left"):
		acceleration = vLerp(acceleration, -run if floored else -glide, .04 if velocity.x <= 0 else .8)
		sprite.scale.x = -1
	elif Input.is_action_pressed("player_right"):
		acceleration = vLerp(acceleration, run if floored else glide, .04 if velocity.x >= 0 else .8)
		sprite.scale.x = 1
	else:
		acceleration = Vector2(0, 0)
		velocity.x = lerp(velocity.x, 0, cf if floored else cf / 4)
		
	if jumps > 0 && Input.is_action_just_pressed("player_jump"):
		jumps -= 1
		velocity.y = jump.y
	
	velocity += acceleration
	velocity += gravity
	velocity = vClamp(velocity, -maxV, maxV)
	
	velocity = move_and_slide(velocity, UP)
	
	if velocity.x == 0:
		acceleration.x = 0
	
	print(acceleration)
	print(velocity)
	
	# make the sprite go faster when at full speed
	sprite.speed_scale = abs(velocity.x) / maxV.x * 3
	
	# snap the velocity to zero when at smol values
	if abs(velocity.x) < .25:
		velocity.x = 0
	
	# Change sprite animation based on speed
	var dMx = abs(velocity.x) - abs(prevVelocity.x)
	if dMx < 0:
		if floored:
			sprite.play("skid")
		else:
			sprite.play("glide")
	elif abs(velocity.x) > 0:
		sprite.play("walk", true)
	else: 
		sprite.animation = "stop"
		
	
