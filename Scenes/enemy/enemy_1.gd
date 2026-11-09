extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d_attack: CollisionShape2D = $Area2Dattack/CollisionShape2D_attack
@onready var game_manager: Node = %Game_manager

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var direction = 0


func _ready() -> void:
	collision_shape_2d_attack.disabled = true
	animated_sprite_2d.play("Idle")

func attack():
	print("attack")
	collision_shape_2d_attack.set_deferred("disabled", false)
	await get_tree().create_timer(0.8).timeout
	collision_shape_2d_attack.set_deferred("disabled", true)
	animated_sprite_2d.play("Idle")
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	#if direction == 0:
			#animated_sprite_2d.play("Idle")
	#else:
		#animated_sprite_2d.play("run")
	move_and_slide()


func _on_area_2_drange_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		print("mrdka")
		return
	animated_sprite_2d.play("Attack")
	print("attack animace")
	print("vlezl do zony")
	attack()
	


func _on_area_2_dattack_body_entered(body: Node2D) -> void:
	game_manager.hit()
