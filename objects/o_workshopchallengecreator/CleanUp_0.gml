// Remember the draft so reopening the creator (or coming back from playing it)
// picks up where the player left off.
global.workshopchallenge_draft_title = title
global.workshopchallenge_draft_level_ids = draft_ids

with (o_workshopchallengecreatorbg) instance_destroy()
with (o_workshoplevelselectbutton) instance_destroy()
window_set_cursor(cr_default)
