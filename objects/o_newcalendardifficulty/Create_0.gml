declarecustombutton()

	if global.calendarcurrentweek > 4 {
		file_delete(directory + "NewCalendarEasy.sav")
		file_delete(directory + "NewCalendarNormal.sav")
		file_delete(directory + "NewCalendarHard.sav")
	}
text = ""
day = 1
week = 1
width = 3
xscale = 0.5
yscale = 0.5
difficulty = 1