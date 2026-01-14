function getClientInfo() {
	return {
		"name": "Play with Smooth Page Scrolling",
		"author": "Silver1063",
		"versionNumber": 1,
		"minEditorVersion": 65537
	};
}

function setInterval(t, callback) {
	callback();
	SV.setTimeout(t, setInterval.bind(null, t, callback));
}

var playhead_position
var offset

function main() {
	var form = {
		"title": SV.T("Playhead Properties"),
		"widgets" : [
			{
				"name" : "slider1", 
				"type" : "Slider",
				"label" : "Playhead Position",
				"format" : "%1.2f",
				"minValue" : 0.00,
				"maxValue" : 1.00,
				"interval" : 0.01,
				"default" : 0.30
			},
		]
	}
	var result = SV.showCustomDialog(form);
	playhead_position = result.answers.slider1
	
	playback = SV.getPlayback()
	coordinatesystem = SV.getMainEditor().getNavigation()
	offset = (coordinatesystem.getTimeViewRange()[1] - coordinatesystem.getTimeViewRange()[0]) * playhead_position
	
	SV.getPlayback().play();
	setInterval(20, scroll)
}

function scroll() {
	playhead_pos = SV.getProject().getTimeAxis().getBlickFromSeconds(playback.getPlayhead())

	if(SV.getPlayback().getStatus() == 'playing'){
		coordinatesystem.setTimeLeft(playhead_pos - offset)
	}
	else {
		SV.finish()
	}
}