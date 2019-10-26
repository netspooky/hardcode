/*
 * hacked from closure_webkitaudio.js
 */

/**
 * @constructor
 */
var AudioNode = function() {};
AudioNode.prototype.onaudioprocess;
AudioNode.prototype.connect;
AudioNode.prototype.disconnect;


/**
 * @constructor
 */
var event = function() {};
event.prototype.outputBuffer;
event.prototype.getChannelData = function() {};

/**
 * @constructor
 */
var AudioContext = function() {};


/** @type {AudioDestinationNode} */
AudioContext.prototype.destination;


/** @type {number} */
AudioContext.prototype.sampleRate;


/** @type {number} */
AudioContext.prototype.currentTime;


/** @type {AudioListener} */
AudioContext.prototype.listener;


/**
 * webkitAudioContext.prototype.createBuffer() has 2 syntax:
 *   * Regular method:
 *     createBuffer = function(numberOfChannels, length, sampleRate) {};
 *
 *   * ArrayBuffer method:
 *     createBuffer = function(buffer, mixToMono) {};
 *
 * @param {number|ArrayBuffer} a
 * @param {number|boolean} b
 * @param {number=} sampleRate
 */
AudioContext.prototype.createBuffer = function(a, b, sampleRate) {};


/**
 * @param {ArrayBuffer} audioData
 * @param {Function} successCallback
 * @param {Function=} errorCallback
 * @throws {DOMException}
 */
AudioContext.prototype.decodeAudioData = function(audioData, successCallback,
    errorCallback) {};


/**
 * @return {AudioBufferSourceNode}
 */
AudioContext.prototype.createBufferSource = function() {};


/**
 * @param {number} bufferSize
 * @param {number} numberOfInputs
 * @param {number} numberOfOuputs
 * @return {JavaScriptAudioNode}
 */
AudioContext.prototype.createScriptProcessor = function(bufferSize, numberOfInputs, numberOfOuputs) {};


/**
 * @return {RealtimeAnalyserNode}
 */
AudioContext.prototype.createAnalyser = function() {};


/**
 * @return {AudioGainNode}
 */
AudioContext.prototype.createGainNode = function() {};


/**
 * @param {number=} maxDelayTime
 * @return {DelayNode}
 */
AudioContext.prototype.createDelayNode = function(maxDelayTime) {};


/**
 * @return {BiquadFilterNode}
 */
AudioContext.prototype.createBiquadFilter = function() {};


/**
 * @return {webkitAudioPannerNode}
 */
AudioContext.prototype.createPanner = function() {};


/**
 * @return {ConvolverNode}
 */
AudioContext.prototype.createConvolver = function() {};


/**
 * @return {AudioChannelSplitter}
 */
AudioContext.prototype.createChannelSplitter = function() {};


/**
 * @return {AudioChannelMerger}
 */
AudioContext.prototype.createChannelMerger = function() {};


/**
 * @return {DynamicsCompressorNode}
 */
AudioContext.prototype.createDynamicsCompressor = function() {};



/**
 * @constructor
 * @extends {AudioNode}
 */
var AudioPannerNode = function() {};


/** @type {number} */
AudioPannerNode.EQUALPOWER = 0;


/** @type {number} */
AudioPannerNode.HRTF = 1;


/** @type {number} */
AudioPannerNode.SOUNDFIELD = 2;


/** @type {number} */
AudioPannerNode.LINEAR_DISTANCE = 0;


/** @type {number} */
AudioPannerNode.INVERSE_DISTANCE = 1;


/** @type {number} */
AudioPannerNode.EXPONENTIAL_DISTANCE = 2;


/** @type {number} */
AudioPannerNode.prototype.panningModel;


/**
 * @param {number} x
 * @param {number} y
 * @param {number} z
 */
AudioPannerNode.prototype.setPosition = function(x, y, z) {};


/**
 * @param {number} x
 * @param {number} y
 * @param {number} z
 */
AudioPannerNode.prototype.setOrientation = function(x, y, z) {};


/**
 * @param {number} x
 * @param {number} y
 * @param {number} z
 */
AudioPannerNode.prototype.setVelocity = function(x, y, z) {};


/** @type {number} */
AudioPannerNode.prototype.distanceModel;


/** @type {number} */
AudioPannerNode.prototype.refDistance;


/** @type {number} */
AudioPannerNode.prototype.maxDistance;


/** @type {number} */
AudioPannerNode.prototype.rolloffFactor;


/** @type {number} */
AudioPannerNode.prototype.coneInnerAngle;


/** @type {number} */
AudioPannerNode.prototype.coneOuterAngle;


/** @type {number} */
AudioPannerNode.prototype.coneOuterGain;


/** @type {AudioGain} */
AudioPannerNode.prototype.coneGain;


/** @type {AudioGain} */
AudioPannerNode.prototype.distanceGain;