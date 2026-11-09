extends Area2D
@onready var game_manager: Node = %Game_manager
@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	print("hit snad")
	#timer.start()
	game_manager.hit()
	

func _on_timer_timeout() -> void: 
	print("timeout")
	timer.stop()
