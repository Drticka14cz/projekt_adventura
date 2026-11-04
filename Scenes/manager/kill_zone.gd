extends Area2D
@onready var game_manager: Node = get_tree().get_first_node_in_group("game_manager")
@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	print("hit snad")
	game_manager.hit()
	timer.start()
	

func _on_timer_timeout() -> void: 
	game_manager.hit()
	timer.start()
