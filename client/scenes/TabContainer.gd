extends TabContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("tab_selected", self, "tab_selected")

func tab_selected(tab):
	var selected = get_child(tab).name
	print(selected)
	match selected:
		'NORMAL':
			Network.send_data({
				'command':'state changed',
				'state' : 'normal',
				}
			)
		'DISCUSS':
			Network.send_data({
				'command':'state changed',
				'state' : 'discuss',
				}
			)
		'POLL':
			Network.send_data({
				'command':'state changed',
				'state' : 'poll',
				}
			)
		'QUIZ':
			Network.send_data({
				'command':'state changed',
				'state' : 'quiz',
				}
			)
			
	
