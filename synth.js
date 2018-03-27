function Synth(voiceCount, audioContext) {
  this.audioContext = audioContext;
  this.voices = [];
  for (let i = 0; i < voiceCount; i++) {
    this.voices.push(new Voice(this.audioContext));
  }
}

Synth.prototype.connect = function(dst) {
  for (let i = 0; i < this.voices.length; i++) {
    this.voices[i].connect(dst);
  }
}

Synth.prototype.start = function() {
  for (let i = 0; i < this.voices.length; i++) {
    this.voices[i].start();
  }
}

Synth.prototype.noteAt = function(t, f) {
  let attack = 0;
  let peak = 0.5;
  let decay = 2.5;

  for (let i = 0; i < this.voices.length; i++) {
    if (this.voices[i].getFrequencyAt(t) == f) {
      this.voices[i].noteAt(t, f, attack, peak, decay, true);
      return;
    }
  }

  let minGain = Infinity;
  let quietestVoice = null;
  let peakTime = t + attack;
  for (let i = 0; i < this.voices.length; i++) {
    let gain = this.voices[i].getGainAt(peakTime);
    if (gain < minGain) {
      minGain = gain;
      quietestVoice = this.voices[i];
      if (gain <= 0) {
        break;
      }
    }
  }

  quietestVoice.noteAt(t, f, attack, peak, decay);
}

Synth.prototype.muteAt = function(t) {
  for (let i = 0; i < this.voices.length; i++) {
    this.voices[i].muteAt(t);
  }
}
