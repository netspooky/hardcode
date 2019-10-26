/*
 * Copyright 2012 The Closure Compiler Authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @fileoverview Definitions for the Web Audio API with webkit prefix.
 *   Not all classes are currently implemented.
 * @see http://www.w3.org/TR/webaudio/
 *
 * @externs
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
var webkitAudioContext = function() {};


/** @type {AudioDestinationNode} */
webkitAudioContext.prototype.destination;


/** @type {number} */
webkitAudioContext.prototype.sampleRate;


/** @type {number} */
webkitAudioContext.prototype.currentTime;


/** @type {AudioListener} */
webkitAudioContext.prototype.listener;


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
webkitAudioContext.prototype.createBuffer = function(a, b, sampleRate) {};


/**
 * @param {ArrayBuffer} audioData
 * @param {Function} successCallback
 * @param {Function=} errorCallback
 * @throws {DOMException}
 */
webkitAudioContext.prototype.decodeAudioData = function(audioData, successCallback,
    errorCallback) {};


/**
 * @return {AudioBufferSourceNode}
 */
webkitAudioContext.prototype.createBufferSource = function() {};


/**
 * @param {number} bufferSize
 * @param {number} numberOfInputs
 * @param {number} numberOfOuputs
 * @return {JavaScriptAudioNode}
 */
webkitAudioContext.prototype.createJavaScriptNode = function(bufferSize,
    numberOfInputs, numberOfOuputs) {};


/**
 * @return {RealtimeAnalyserNode}
 */
webkitAudioContext.prototype.createAnalyser = function() {};


/**
 * @return {AudioGainNode}
 */
webkitAudioContext.prototype.createGainNode = function() {};


/**
 * @param {number=} maxDelayTime
 * @return {DelayNode}
 */
webkitAudioContext.prototype.createDelayNode = function(maxDelayTime) {};


/**
 * @return {BiquadFilterNode}
 */
webkitAudioContext.prototype.createBiquadFilter = function() {};


/**
 * @return {webkitAudioPannerNode}
 */
webkitAudioContext.prototype.createPanner = function() {};


/**
 * @return {ConvolverNode}
 */
webkitAudioContext.prototype.createConvolver = function() {};


/**
 * @return {AudioChannelSplitter}
 */
webkitAudioContext.prototype.createChannelSplitter = function() {};


/**
 * @return {AudioChannelMerger}
 */
webkitAudioContext.prototype.createChannelMerger = function() {};


/**
 * @return {DynamicsCompressorNode}
 */
webkitAudioContext.prototype.createDynamicsCompressor = function() {};



/**
 * @constructor
 * @extends {AudioNode}
 */
var webkitAudioPannerNode = function() {};


/** @type {number} */
webkitAudioPannerNode.EQUALPOWER = 0;


/** @type {number} */
webkitAudioPannerNode.HRTF = 1;


/** @type {number} */
webkitAudioPannerNode.SOUNDFIELD = 2;


/** @type {number} */
webkitAudioPannerNode.LINEAR_DISTANCE = 0;


/** @type {number} */
webkitAudioPannerNode.INVERSE_DISTANCE = 1;


/** @type {number} */
webkitAudioPannerNode.EXPONENTIAL_DISTANCE = 2;


/** @type {number} */
webkitAudioPannerNode.prototype.panningModel;


/**
 * @param {number} x
 * @param {number} y
 * @param {number} z
 */
webkitAudioPannerNode.prototype.setPosition = function(x, y, z) {};


/**
 * @param {number} x
 * @param {number} y
 * @param {number} z
 */
webkitAudioPannerNode.prototype.setOrientation = function(x, y, z) {};


/**
 * @param {number} x
 * @param {number} y
 * @param {number} z
 */
webkitAudioPannerNode.prototype.setVelocity = function(x, y, z) {};


/** @type {number} */
webkitAudioPannerNode.prototype.distanceModel;


/** @type {number} */
webkitAudioPannerNode.prototype.refDistance;


/** @type {number} */
webkitAudioPannerNode.prototype.maxDistance;


/** @type {number} */
webkitAudioPannerNode.prototype.rolloffFactor;


/** @type {number} */
webkitAudioPannerNode.prototype.coneInnerAngle;


/** @type {number} */
webkitAudioPannerNode.prototype.coneOuterAngle;


/** @type {number} */
webkitAudioPannerNode.prototype.coneOuterGain;


/** @type {AudioGain} */
webkitAudioPannerNode.prototype.coneGain;


/** @type {AudioGain} */
webkitAudioPannerNode.prototype.distanceGain;