extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: Node = %Game_manager
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var allkeys
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print("bossdoor")
	animated_sprite_2d.play("default")
	allkeys = game_manager.all_keys()
	print("klice", allkeys)
	if allkeys:
		collision_shape_2d.disabled = true
		animated_sprite_2d.play("nic")
	pass
