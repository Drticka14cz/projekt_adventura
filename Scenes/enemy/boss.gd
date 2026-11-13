extends CharacterBody2D

@onready var sfx_boss: AudioStreamPlayer2D = $sfx_boss

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d_attack: CollisionShape2D = $Area2Dattack/CollisionShape2D_attack
@onready var game_manager: Node = %Game_manager
@onready var animated_sprite_2_deffect: AnimatedSprite2D = $AnimatedSprite2Deffect
@onready var wall_ray_right: RayCast2D = $RayCast2D # RayCast2D směrovaný dopředu (např. target_position = (40, 0))
@onready var wall_ray_left: RayCast2D = $RayCast2D2
@onready var label: Label = $Label
const JUMP_VELOCITY = -400.0

@export var min_patrol_distance: float = 80.0
@export var max_patrol_distance: float = 800.0
@export var patrol_speed: float = 60.0

@export var max_health: int = 5 # Počet životů bose

var player_in_range = false
var direction = 1
var is_attacking = false
var is_dead = false # Pojistka, aby mrtvý boss nic nedělal
var current_health: int
var target_x: float

@onready var base_position: float = global_position.x


func _ready() -> void:
	current_health = max_health
	collision_shape_2d_attack.disabled = true
	animated_sprite_2d.play("Idle")
	_pick_new_target()


# Náhodná vzdálenost a náhodný směr, spočítá se JEDNOU, ne každý frame
func _pick_new_target() -> void:
	var dist := randf_range(min_patrol_distance, max_patrol_distance)
	direction = 1 if randi() % 2 == 0 else -1
	target_x = base_position + dist * direction
	


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
	sfx_boss.play()
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
	sfx_boss.play()
	print("Boss zemřel!")
	label.text = "Vyhrál jsi"
	animated_sprite_2d.play("Death")
	
	# Počkáme, než skončí animace smrti, a pak bose odstraníme ze scény
	await get_tree().create_timer(2.1).timeout
	queue_free()


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Přidání gravitace
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Pokud zrovna neútočí ani nedostává hit, tak chodí
	if not is_attacking:
		# Pohyb přes velocity, aby fungoval move_and_slide a kolize
		velocity.x = patrol_speed * direction
		
		var reached_target := (
			(direction > 0 and global_position.x >= target_x) or
			(direction < 0 and global_position.x <= target_x)
		)
		
		# Otočka u zdi přes RayCast2D
		var hit_wall := (direction > 0 and wall_ray_right.is_colliding()) or (direction < 0 and wall_ray_left.is_colliding())
		
		
		if reached_target or hit_wall or is_on_wall():
			_pick_new_target()
		
		if direction == 0:
			animated_sprite_2d.play("Idle")
		else:
			animated_sprite_2d.play("Run")
		
		animated_sprite_2d.flip_h = direction < 0
	else:
		velocity.x = 0 # při útoku/hitu stojí
	
	if player_in_range and not is_attacking:
		is_attacking = true
		var random_delay = randf_range(0.3, 1.5)
		await get_tree().create_timer(random_delay).timeout
		attack()
	move_and_slide()


func _on_area_2_drange_body_entered(body: Node2D) -> void:
	if is_dead or not body.is_in_group("player"):
		return
	
	player_in_range = true
	if not is_attacking:
		is_attacking = true
		var random_delay = randf_range(0.3, 1.5)
		await get_tree().create_timer(random_delay).timeout
		
		if not is_dead and is_instance_valid(body):
			attack()


func _on_area_2_dattack_body_entered(body: Node2D) -> void:
	if not is_dead and body.is_in_group("player"):
		game_manager.hit()



func _on_area_2_drange_body_exited(body: Node2D) -> void:
	if is_dead or not body.is_in_group("player"):
		return
	player_in_range = false
