extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d_attack: CollisionShape2D = $Area2Dattack/CollisionShape2D_attack
@onready var game_manager: Node = %Game_manager

const SPEED = 2
const JUMP_VELOCITY = -400.0
var direction = 1
var is_attacking = false # Přidáno: sleduje, zda nepřítel právě útočí
@onready var base_position: float = global_position.x


func _ready() -> void:
	collision_shape_2d_attack.disabled = true
	animated_sprite_2d.play("Idle")

func attack():
	is_attacking = true # Zamkneme pohyb a změnu animací
	print("attack")
	animated_sprite_2d.play("Attack")
	collision_shape_2d_attack.set_deferred("disabled", false)
	await get_tree().create_timer(0.8).timeout
	collision_shape_2d_attack.set_deferred("disabled", true)
	is_attacking = false # Odemkneme po skončení útoku
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Pokud zrovna útočí, nepohybujeme se a neměníme animace na běh
	if not is_attacking:
		if direction == 0:
			animated_sprite_2d.play("Idle")
		else:
			animated_sprite_2d.play("run")
		
		position.x += SPEED * direction
		
		if global_position.x >= (base_position + 100):
			direction *= -1
			print("vice")
		if global_position.x <= (base_position - 100):
			print("mene")
			direction *= -1
			
		if direction > 0:
			animated_sprite_2d.flip_h = false
		if direction < 0:
			animated_sprite_2d.flip_h = true
			
	move_and_slide()


func _on_area_2_drange_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
		
	# Spustíme útok pouze pokud už nějaký neprobíhá
	if not is_attacking:
		print("attack animace")
		print("vlezl do zony")
		attack()


func _on_area_2_dattack_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		game_manager.hit()
