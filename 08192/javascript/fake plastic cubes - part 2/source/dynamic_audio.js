function openDynamicAudio(opts, onSuccess) {
	if (window.AudioContext) {
		openDynamicAudioUsingWebAudio(AudioContext, opts, onSuccess);
	} else if (window.webkitAudioContext) {
		openDynamicAudioUsingWebAudio(webkitAudioContext, opts, onSuccess);
	} else {
		openDynamicAudioUsingAudioData(opts, onSuccess);
	}
}

function openDynamicAudioUsingWebAudio(AudioContext, opts, onSuccess) {
	var BUFFER_SIZE = 16384; /* size of a buffer for a single channel of audio */

	var channels = opts.channels || 1;
	/* opts.rate is ignored; we use whatever we get back from AudioContext */

	var context = new AudioContext();
	var node = context.createJavaScriptNode(BUFFER_SIZE, 0, channels);
	node.connect(context.destination);
	window.stopGarbageCollectingThisDammit = node;

	var target = {
		'channels': channels,
		'rate': context.sampleRate,
		'done': function() {
			node.onaudioprocess = null;
			node.disconnect();
		}
	};

	node.onaudioprocess = function(event) {
		if (!target.fillBuffer) return;
		var buffers = [];
		for (var i = 0; i < target.channels; i++) {
			buffers[i] = event.outputBuffer.getChannelData(i);
		}
		target.fillBuffer(buffers, 0, event.outputBuffer.length);
	};

	onSuccess(target);
}

function openDynamicAudioUsingAudioData(opts, onSuccess) {
	var BUFFER_SIZE = 16384; /* size of a buffer for a single channel of audio */

	var channels = opts.channels || 1;
	var rate = opts.rate || 44100;

	var audio = new Audio();
	/* TODO: bail out if audio.mozSetup not defined */
	audio.mozSetup(opts.channels || 1, opts.rate || 44100);
	/* TODO: check what happens if channels/rate are set to something unsupported */

	/* create a static set of per-channel buffers for the fillBuffer function to write to */
	var channelBuffers = [];
	for (var i = 0; i < channels; i++) {
		channelBuffers[i] = new Float32Array(BUFFER_SIZE);
	}

	/* create a buffer for the interleaved data to be written to mozWriteAudio */
	var writeBufferLength = BUFFER_SIZE * channels;
	var writeBuffer = new Float32Array(writeBufferLength);
	var writeBufferEnd = 0; /* offset immediately following the last sample in the buffer */
	var writeBufferOffset = 0; /* offset immediately following the last sample written to output */

	var isDone = false;

	var target = {
		'channels': channels,
		'rate': rate,
		'done': function() {isDone = true;}
	};

	/* default fillBuffer function just fills buffer with zeroes */
	target.fillBuffer = function(buffers, offset, length) {
		for (var samplesLeft = length; samplesLeft; offset++, samplesLeft--) {
			for (var i = 0; i < target.channels; i++) {
				buffers[i][offset] = 0;
			}
		}
		return length; /* return the number of samples written */
	};

	var timer = setInterval(function() {
		if (writeBufferOffset == writeBufferEnd) {
			/* need to generate more data */
			if (isDone) {
				clearInterval(timer);
				/* FIXME: audio does not stop cleanly (there's a pop). Writing silence at this point doesn't seem to help... */
				//var silenceBuffer = new Float32Array(writeBufferLength);
				//audio.mozWriteAudio(silenceBuffer);
				return;
			} else {
				var samplesGenerated = target.fillBuffer(channelBuffers, 0, BUFFER_SIZE);

				/* write the generated data to writeBuffer, interleaving between channels */
				writeBufferEnd = 0;
				for (var i = 0; i < samplesGenerated; i++) {
					for (var chan = 0; chan < target.channels; chan++) {
						writeBuffer[writeBufferEnd] = channelBuffers[chan][i];
						writeBufferEnd++;
					}
				}
				writeBufferOffset = 0;
			}
		}
		var samplesWritten = audio.mozWriteAudio(writeBuffer.subarray(writeBufferOffset, writeBufferEnd));
		writeBufferOffset += samplesWritten;
	}, 100);

	onSuccess(target);
}
