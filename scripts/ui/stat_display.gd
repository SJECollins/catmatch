extends Control

@onready var day_display = $RowStatDisplay/DayText
@onready var stat_display = $RowStatDisplay/StatText

var day := 1

func _update_day():
	day += 1
	day_display.text = "Day " + str(day)

func _update_stats(num, met_wants, total_wants):
	stat_display.text = num + " (" + met_wants + "/" + total_wants + ")"

func _ready() -> void:
	$"../".end_day.connect(_update_day)
