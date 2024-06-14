timer -= 1

if timer <= 0 {
	if gameChanged = 0 {
	y += 5
	} else {
	y -= 5
	if y < 638 {
	timer = timerRotation
	y = 638
	gameChanged = 0
	}
	}
}

if y > 768 {
if gameChanged = 0 {
game += 1
if game > maxGames {
	game = 0
}}
gameChanged = 1	
}
/*
