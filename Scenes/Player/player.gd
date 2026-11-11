extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var normal_colision: CollisionShape2D = $Normal_colision
@onready var game_manager: Node = %Game_manager

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_crouching := false
# Uložíme si původní shape, abychom ho mohli vrátit
var is_attacking = false
var original_shape: CapsuleShape2D
func _ready() -> void:
	original_shape = normal_colision.shape.duplicate() as CapsuleShape2D

func zmensit_hitbox() -> void:
	var shape = normal_colision.shape as CapsuleShape2D
	# CapsuleShape2D má radius a height, ne size!
	var new_shape := shape.duplicate() as CapsuleShape2D
	new_shape.height /= 2
	new_shape.radius /= 2
	normal_colision.shape = new_shape
	normal_colision.position.y += 4
	
func zvetsit_hitbox() -> void:
	normal_colision.shape = original_shape
	normal_colision.position.y -= 4
	velocity.y = JUMP_VELOCITY/4


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	#Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_crouching:
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("Crouch"):
		is_crouching = !is_crouching
		if is_crouching:
			zmensit_hitbox()
		else:
			zvetsit_hitbox()
	if Input.is_action_just_pressed("Attack"):
		if not is_attacking:
			is_attacking = true
			animated_sprite_2d.play("melee_attack")
			print("Utok")
			await get_tree().create_timer(1).timeout
			print("konec utoku")
			is_attacking = false
		
		
	
	#Input směru
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	#vrací číslo -1, 0, 1
	
	#flip animace
	if direction > 0:
		animated_sprite_2d.flip_h = false
	if direction < 0:
		animated_sprite_2d.flip_h = true
	if is_on_floor(): #Podmínka pro animace
		if is_attacking:
			animated_sprite_2d.play("melee_attack")
		else:
			if direction == 0 and not is_crouching:
				animated_sprite_2d.play("Idle")
			else:
				if is_crouching:
					animated_sprite_2d.play("Crouch")
				else:
					animated_sprite_2d.play("Run")
			
	else:
		animated_sprite_2d.play("Jump")
			
	move_and_slide()
	
	
func heal(hp):
	print("heal", hp)
	game_manager.heal()

func _on_area_2_dattack_body_entered(body: Node2D) -> void:
	# Zkontrolujeme, zda zasažený objekt má funkci take_damage (což boss má
	if is_attacking:
		if body.has_method("take_damage"):
			body.take_damage(1) # Udělíme bose 1 poškození
			print("Hráč zasáhl cíl!")
	else:
		print("MRD")
