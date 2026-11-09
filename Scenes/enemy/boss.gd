extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d_attack: CollisionShape2D = $Area2Dattack/CollisionShape2D_attack
@onready var game_manager: Node = %Game_manager
@onready var animated_sprite_2_deffect: AnimatedSprite2D = $AnimatedSprite2Deffect

const SPEED = 2
const JUMP_VELOCITY = -400.0
var direction = 1
var is_attacking = false
var is_dead = false # Pojistka, aby mrtvý boss nic nedělal

@export var max_health: int = 3 # Počet životů bose
var current_health: int

@onready var base_position: float = global_position.x


func _ready() -> void:
	current_health = max_health
	collision_shape_2d_attack.disabled = true
	animated_sprite_2d.play("Idle")


func attack():
	if is_dead: return
	is_attacking = true
	print("Boss útočí!")
	
	animated_sprite_2d.play("Attack")
	await get_tree().create_timer(0.2).timeout
	animated_sprite_2_deffect.play("Effect")
	collision_shape_2d_attack.set_deferred("disabled", false)
	await get_tree().create_timer(3).timeout
	collision_shape_2d_attack.set_deferred("disabled", true)
	animated_sprite_2_deffect.play("Not")
	
	is_attacking = false
	if not is_dead:
		animated_sprite_2d.play("Idle")


# Funkce, kterou zavoláš, když boss dostane ránu (např. od hráče)
func take_damage(amount: int):
	if is_dead: return
	
	current_health -= amount
	print("Boss dostal hit! Zbývající HP: ", current_health)
	
	if current_health <= 0:
		die()
	else:
		# Přehrání Hurt animace a krátké zablokování pohybu
		is_attacking = true
		animated_sprite_2d.play("Hurt")
		await get_tree().create_timer(0.4).timeout # Doba trvání hurt animace
		is_attacking = false


func die():
	is_dead = true
	is_attacking = true
	collision_shape_2d_attack.set_deferred("disabled", true)
	
	print("Boss zemřel!")
	animated_sprite_2d.play("Death")
	
	# Počkáme, než skončí animace smrti, a pak bose odstraníme ze scény
	await animated_sprite_2d.animation_finished
	queue_free()


func _physics_process(delta: float) -> void:
	if is_dead: return
	
	# Přidání gravitace
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Pokud zrovna neútočí ani nedostává hit, tak chodí
	if not is_attacking:
		if direction == 0:
			animated_sprite_2d.play("Idle")
		else:
			animated_sprite_2d.play("Run")
		
		position.x += SPEED * direction
		
		if global_position.x >= (base_position + 100):
			direction *= -1
		if global_position.x <= (base_position - 100):
			direction *= -1
			
		if direction > 0:
			animated_sprite_2d.flip_h = false
		if direction < 0:
			animated_sprite_2d.flip_h = true
			
	move_and_slide()


func _on_area_2_drange_body_entered(body: Node2D) -> void:
	if is_dead or not body.is_in_group("player"):
		return
		
	if not is_attacking:
		var random_delay = randf_range(0.2, 0.8)
		await get_tree().create_timer(random_delay).timeout
		
		if not is_attacking and not is_dead and is_instance_valid(body):
			attack()


func _on_area_2_dattack_body_entered(body: Node2D) -> void:
	if not is_dead and body.is_in_group("player"):
		game_manager.hit()
