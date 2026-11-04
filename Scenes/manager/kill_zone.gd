extends Area2D
@onready var Game_manager: Node =%Game_manager
@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	Game_manager.hit()
	timer.start()
	

func _on_timer_timeout() -> void:c
	Game_manager.hit()
	timer.start()
