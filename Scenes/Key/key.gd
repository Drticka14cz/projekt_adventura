extends Area2D

@onready var game_manager: Node = %Game_manager
@onready var sfx_coin: AudioStreamPlayer2D = $sfx_coin
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D



func _on_body_entered(_body: Node2D) -> void:
	print("Coin")
	sfx_coin.play()
	animated_sprite_2d.play("nothing")
	await sfx_coin.finished
	game_manager.add_key()
	queue_free() #pak nahradit za animationplayer kvuli zvukum, queue free zatim facha
