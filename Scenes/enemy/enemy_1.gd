extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d_attack: CollisionShape2D = $Area2Dattack/CollisionShape2D_attack
@onready var game_manager: Node = %Game_manager
@onready var wall_ray_right: RayCast2D = $RayCast2D2
@onready var wall_ray_left: RayCast2D = $RayCast2D
@onready var collision_shape_2_drange: CollisionShape2D = $Area2Drange/CollisionShape2Drange
@onready var area_2_drange: Area2D = $Area2Drange

const JUMP_VELOCITY = -400.0

@export var patrol_speed: float = 60.0
@export var min_patrol_distance: float = 80.0
@export var max_patrol_distance: float = 200.0

@export var max_health: int = 2 # Počet životů enemy

var direction = 1
var is_attacking = false
var is_dead = false # Pojistka, aby mrtvý enemy nic nedělal
var current_health: int
var target_x: float
var player_in_range = false
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
	is_attacking = true # Zamkneme pohyb a změnu animací
	print("attack")
	animated_sprite_2d.play("Attack")
	collision_shape_2d_attack.set_deferred("disabled", false)
	await get_tree().create_timer(0.8).timeout
	collision_shape_2d_attack.set_deferred("disabled", true)
	
	is_attacking = false # Odemkneme po skončení útoku
	if not is_dead:
		animated_sprite_2d.play("Idle")


# Funkce, kterou zavoláš, když enemy dostane ránu (např. od hráče)
func take_damage(amount: int):
	if is_dead: return
	
	current_health -= amount
	print("Enemy dostal hit! Zbývající HP: ", current_health)
	
	if current_health <= 0:
		die()
	else:
		# Přehrání Hurt animace a krátké zablokování pohybu
		is_attacking = true
		#animated_sprite_2d.play("Hurt")
		await get_tree().create_timer(0.4).timeout
		is_attacking = false


func die():
	is_dead = true
	is_attacking = true
	collision_shape_2d_attack.set_deferred("disabled", true)
	
	print("Enemy zemřel!")
	animated_sprite_2d.play("Death")
	
	# Vypneme kolize, aby hráč mohl projít skrz mrtvého enemy
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	# Počkáme, než skončí animace smrti, a pak enemy odstraníme ze scény
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
		
		
		var reached_target := (
			(direction > 0 and global_position.x >= target_x) or
			(direction < 0 and global_position.x <= target_x)
		)
		
		# Otočka u zdi přes RayCast2D (levý/pravý)
		var hit_wall := (direction > 0 and wall_ray_right.is_colliding()) or \
			(direction < 0 and wall_ray_left.is_colliding())
		
		if is_on_wall():
			print("WALL")
			print("DIR:", direction)
			print("RIGHT:", wall_ray_right.is_colliding())
			print("LEFT:", wall_ray_left.is_colliding())
			direction *= -1
			var dist := randf_range(min_patrol_distance, max_patrol_distance)
			target_x = global_position.x + dist * direction

		elif reached_target:
			_pick_new_target()
		
		velocity.x = patrol_speed * direction
		if direction == 0:
			animated_sprite_2d.play("Idle")
		else:
			animated_sprite_2d.play("run")
		
		animated_sprite_2d.flip_h = direction < 0
	else:
		velocity.x = 0 # při útoku/hitu stojí
			
	if player_in_range and !is_attacking:
		attack()
	
	
	move_and_slide()


func _on_area_2_drange_body_entered(body: Node2D) -> void:
	if is_dead or not body.is_in_group("player"):
		return
	player_in_range = true
	# Spustíme útok pouze pokud už nějaký neprobíhá
	if not is_attacking:
		print("vlezl do zony")
		attack()


func _on_area_2_dattack_body_entered(body: Node2D) -> void:
	if not is_dead and body.is_in_group("player"):
		game_manager.hit()


func _on_area_2_drange_body_exited(body: Node2D) -> void:
	if is_dead or not body.is_in_group("player"):
		return
	player_in_range = false
