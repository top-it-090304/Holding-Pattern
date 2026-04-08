extends Control

@onready var container = $CardsPack

var spacing: float = 120.0
var card_width: float = 0.0
var current_index: int = 0

var target_x: float = 0.0
var is_dragging: bool = false
var drag_start_x: float = 0.0
var drag_current_x: float = 0.0

var cards: Array = []

func _ready():
	await get_tree().process_frame
	
	cards = container.get_children()
	if cards.size() > 0:
		card_width = cards[0].size.x
		update_target_x()
		container.position.x = target_x

func _process(delta):
	if not container: return
	var drag_offset = (drag_current_x - drag_start_x) if is_dragging else 0.0
	container.position.x = lerp(container.position.x, target_x + drag_offset, 10.0 * delta)
	var menu_center_x = size.x / 2.0
	
	for card in cards:
		var card_center = container.position.x + card.position.x + (card.size.x / 2.0)
		var distance = abs(menu_center_x - card_center)
		var s = clamp(1.04 - (distance / 700.0), 0.9, 1.15)
		card.scale = card.scale.lerp(Vector2(s, s), 12.0 * delta)
		
		var a = clamp(1.0 - (distance / 600.0), 0.2, 1.0)
		card.modulate.a = lerp(card.modulate.a, a, 12.0 * delta)
		
		card.z_index = int(s * 10)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var local_mouse_x = get_local_mouse_position().x
			
			if event.pressed:
				is_dragging = true
				drag_start_x = local_mouse_x
				drag_current_x = local_mouse_x
			else:
				is_dragging = false
				var swipe_dist = drag_current_x - drag_start_x
				
				if abs(swipe_dist) > card_width * 0.15:
					current_index = clamp(current_index - sign(swipe_dist), 0, cards.size() - 1)
				
				drag_start_x = 0
				drag_current_x = 0
				update_target_x()

	elif event is InputEventMouseMotion and is_dragging:
		drag_current_x = get_local_mouse_position().x

func update_target_x():
	var menu_center_x = size.x / 2.0
	var offset_to_card = current_index * (card_width + spacing) + (card_width / 2.0)
	target_x = menu_center_x - offset_to_card
	
