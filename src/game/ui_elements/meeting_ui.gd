extends ColorRect

onready var voteOptions: VBoxContainer = $MainBox/VoteSide/VoteOptions
onready var timer: Timer = $VoteTimeOut
onready var timeLabel: Label = $TimeLeft
onready var chatbox: MarginContainer = $MainBox/ChatBox
var characterVote: String = "res://game/ui_elements/character_vote.tscn"

var votableCharacters: Dictionary = {}

func _process(delta) -> void:
	if timer.is_stopped():
		return
	var timeLeft: float = timer.time_left
	var mins: int = floor(timeLeft / 60)
	var secs: int = floor(timeLeft - mins * 60)
	var secstring: String = str(secs)
	if secs < 10:
		secstring = "0" + secstring
	var timestring: String = str(mins) + ":" + secstring
	timeLabel.text = timestring

func _focus() -> void:
	var voteRes: VoteMechanicsTemplate = TransitionHandler.gameScene.getVoteResource()
	if voteRes.getVoteTime() > 0:
		timer.start(voteRes.getVoteTime())
	else:
		timer.stop()
		timeLabel.text = "No time limit"
	removeOptions()
	chatbox.clearMessages()
	for characterId in voteRes.voteOptions():
		addCharacter(characterId)

func removeOptions() -> void:
	for childNode in votableCharacters.values():
		childNode.queue_free()
	votableCharacters = {}

func addCharacter(characterId: int) -> void:
	var newVoteItem: HBoxContainer = ResourceLoader.load(characterVote).instance()
	var characterRes: CharacterResource = Characters.getCharacterResource(characterId)
	votableCharacters[characterId] = newVoteItem
	newVoteItem.setId(characterId)
	newVoteItem.setName(characterRes.getCharacterName())
	newVoteItem.setAppearance(characterRes.getOutfit(), characterRes.getColors())
	newVoteItem.connect("voteCast", self, "receiveVote")
	voteOptions.add_child(newVoteItem)

func receiveVote(votedFor: int) -> void:
	for id in votableCharacters:
		if id == votedFor:
			votableCharacters[id].changeTextColor(Color.yellow)
		else:
			votableCharacters[id].changeTextColor(Color.gray)
	TransitionHandler.gameScene.voteCast(votedFor)

func _on_VoteTimeOut_timeout():
	TransitionHandler.gameScene.voteTimeOut()
