extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("HEAL")
	if body.has_method("heal"):
			body.heal(100) # Udělíme bose 1 poškození
			animated_sprite_2d.play("Heal")
			await get_tree().create_timer(1.5).timeout
			animated_sprite_2d.play("Idle")
