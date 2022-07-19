extends Control

onready var status_label = $MarginContainer/Panel/CenterContainer/VBoxContainer/status
onready var login_button = $"MarginContainer/Panel/CenterContainer/VBoxContainer/login button"
onready var eth_address = $MarginContainer/Panel/CenterContainer/VBoxContainer/address
onready var name_label = $MarginContainer/Panel/CenterContainer/VBoxContainer/name

func _ready():
	Network.connect("connection_changed", self, 'connection_updated')
	status_label.text = Network.status
	login_button.connect("pressed", self, 'login')
	login_button.disabled = true
	eth_address.connect("text_entered", self, 'address_entered')
	eth_address.connect("text_changed", self, 'address_changed')

func login():
	Network._connect(eth_address.text, name_label.text)

func address_entered(text):
	print('address changed')

func address_changed(text):
	login_button.disabled = false
	
func connection_updated():
	status_label.text = Network.status
	if Network.status == 'LOGGED IN':
		match Network.role:
			'admin':
				get_tree().change_scene("res://scenes/admin home.tscn")
			'student':
				get_tree().change_scene("res://scenes/student home.tscn")

			
