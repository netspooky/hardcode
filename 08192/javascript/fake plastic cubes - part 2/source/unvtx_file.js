function UnVTXFile(data) { /* data must be a Uint8Array */
	var self = {};

	var channelLength = data.length / 14;
	var lastChannel13 = null;
	var frameNum = 0;

	self.applyCommandsForFrame = function(chip) {
		if (frameNum >= channelLength) return false;
		for (var i = 0; i < 13; i++) {
			chip.setRegister(i, data[4 + i*channelLength + frameNum]);
		}
		var chan13 = data[4 + 13*channelLength + frameNum];
		if (chan13 != lastChannel13) {
			chip.setRegister(13, chan13);
			lastChannel13 = chan13;
		}
		frameNum++;
		return true;
	};

	return self;
}
