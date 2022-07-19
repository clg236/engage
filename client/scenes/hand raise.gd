extends Button

var hand_name
var hand_id

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("toggled", self, 'hand_raised_button_toggled')

func hand_raised_button_toggled(toggled):
	if toggled:
		print('sending hand id', hand_id)
		Network.send_data(
			{
				'command' : 'call upon',
				'data' : hand_id
			}
		)
	else:
		Network.send_data(
			{
				'command' : 'dismiss',
				'data' : hand_id
			}
		)
		# remove it from our view
		queue_free()
