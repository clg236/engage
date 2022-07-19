extends Control

onready var raise_hand_button = $"MarginContainer/Panel/student view/VBoxContainer/CenterContainer/raise hand button"
onready var comment_box = $"MarginContainer/Panel/student view/VBoxContainer/comment box/comment"
onready var submit_button = $"MarginContainer/Panel/student view/VBoxContainer/comment box/submit button"
onready var attention_box = $"MarginContainer/Panel/attention"

func _ready():
	raise_hand_button.connect("toggled", self, 'raise_hand')
	submit_button.connect("pressed", self, "submit_comment")
	Network.connect("called_upon", self, "called_upon")
	Network.connect("hand_lowered", self, "hand_lowered")

func raise_hand(pressed):
	if pressed:
		raise_hand_button.text = 'LOWER HAND'
		print('%s has raised their hands' % Network.myID)
		Network.send_data({
			'command' : 'hand',
			'id' : Network.myID,
			'raised' : true
		})
	else:
		raise_hand_button.text = 'RAISE HAND'
		print('%s has lowered their hands' % Network.myID)
		Network.send_data({
			'command' : 'hand',
			'id' : Network.myID,
			'raised' : false
		})

func hand_lowered(data):
	if data.id == Network.myID:
		print('my hand lowered', data)
		raise_hand_button.pressed = false
	
func submit_comment():
	if comment_box.text != '':
		Network.send_data({
			'command' : 'comment',
			'id' : Network.myID,
			'data' : comment_box.text
		})
		comment_box.text = ''

func called_upon(data):
	if data:
		attention_box.visible = true
	else:
		attention_box.visible = false
		raise_hand_button.pressed = false

