extends CharacterBody2D
@export var animated_sprite_2d: AnimatedSprite2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var direction = 0



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	#if direction == 0:
			#animated_sprite_2d.play("Idle")
	#else:
		#animated_sprite_2d.play("run")
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("hit od enemyho? prayge...")
