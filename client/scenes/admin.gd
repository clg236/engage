extends Control

onready var hand_raise_container = $"MarginContainer/Panel/admin view/VBoxContainer/hand container"
onready var connected_clients_label = $"MarginContainer/Panel/admin view/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/connected clients"
var hand_raise_button = preload("res://scenes/hand raise.tscn")
var hands_raised = []

func _ready():
	Network.connect("hand_raised",self,"hand_raised")
	Network.connect("hand_lowered",self,"hand_lowered")
	Network.connect("new_player", self, "new_player_joined")

func hand_raised(data):
	print('we recieved a hand raise from %s' % data)
	# add it to the container
	var h = hand_raise_button.instance()
	hand_raise_container.add_child(h)
	h.text = data.name
	h.hand_id = data.id
	hands_raised.append(h)
	

func hand_lowered(data):
	for hand in hands_raised:
		if hand.hand_id == data.id:
			hands_raised.erase(hand)
			hand.queue_free()

func new_player_joined(_data):
	connected_clients_label.text = str(Network.clients.size())
