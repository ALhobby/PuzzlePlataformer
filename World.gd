extends Node2D

onready var button_manager : Node2D = $ButtonManager
onready var appearing_platform_manager : Node2D = $AppearingPlatformManager

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in button_manager.get_children():
		button.connect("button_pressed", self, "make_platform_solid")
		button.connect("button_unpressed", self, "make_platform_ghost")
	for platform in appearing_platform_manager.get_children():
		var appearing_platform_sprite = platform.get_node("Sprite")
		var appearing_platform_collisionShape = platform.get_node("CollisionShape2D")
		appearing_platform_sprite.modulate = Color(1,1,1,0.2)
		appearing_platform_collisionShape.set_disabled(true)



func make_platform_solid(button_id):
	var platform = appearing_platform_manager.get_node("AppearingPlatform"+str(button_id))
	var appearing_platform_sprite = platform.get_node("Sprite")
	var appearing_platform_collisionShape = platform.get_node("CollisionShape2D")
	appearing_platform_sprite.modulate = Color(1,1,1,1)
	appearing_platform_collisionShape.call_deferred("set_disabled", false)


func make_platform_ghost(button_id):
	var platform = appearing_platform_manager.get_node("AppearingPlatform"+str(button_id))
	var appearing_platform_sprite = platform.get_node("Sprite")
	var appearing_platform_collisionShape = platform.get_node("CollisionShape2D")
	appearing_platform_sprite.modulate = Color(1,1,1,0.2)
	appearing_platform_collisionShape.call_deferred("set_disabled", true)
