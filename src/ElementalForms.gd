extends Resource
class_name ElementalForms

enum Form { FIRE, WATER }

static func get_form_name(form: int) -> String:
	return Form.keys()[form]

static func get_form_color(form: int) -> Color:
	return Color(1, 0.6, 0.1) if form == Form.FIRE else Color(0.1, 0.8, 1) 