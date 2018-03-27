var ac = new (window.AudioContext || window.webkitAudioContext)();

var reverb = Freeverb(ac);
reverb.roomSize = 0.2;
reverb.wet.value = 0.3;
reverb.dry.value = 0.55;
reverb.connect(ac.destination);

var lp = ac.createBiquadFilter();
lp.frequency = 2200;
lp.connect(reverb);

var synth = new Synth(6, ac);
synth.connect(lp);
synth.start();

function changeAudio(changes) {
  let now = ac.currentTime;
  for (let i = 0; i < changes.length; i++) {
    if (changes[i].type == "note") {
      synth.noteAt(now + changes[i].delay, changes[i].f);
    } else if (changes[i].type == "mute") {
      synth.muteAt(now + changes[i].delay);
    }
  }
}

var partials = [];
for (let key = 0; key < 88; key++) {
  let fundamental = 440 * Math.pow(2, (key - 48) / 12)
  for (let multiplier = 1; multiplier < 7; multiplier++) {
    let amplitude = 1 / multiplier;
    partials.push(
      { f: fundamental * multiplier,
        intensity: amplitude * amplitude,
        key: key
      }
    );
  }
}

partials.sort(
  function (a, b) {
    return a.f - b.f;
  }
);

var pairTerms = new Float64Array(new ArrayBuffer(8 * 88 * (88 - 1) / 2));

function triangleFlatten(i, j) {
  if (i > j) {
    return i * (i - 1) / 2 + j;
  } else {
    return j * (j - 1) / 2 + i;
  }
}

// critical bandwidth approximation taken from
// https://ccrma.stanford.edu/~jos/bbt/Equivalent_Rectangular_Bandwidth.html
function getBandwidth(frequency) {
  return 94 + 71 * Math.pow(0.001 * frequency, 1.5);
}

for (let i = 0; i < partials.length; i++) {
  let a = partials[i];
  for (let j = i - 1; j >= 0; j--) {
    let b = partials[j];
    if (a.key == b.key) {
      continue;
    }

    let farness = (a.f - b.f) / getBandwidth(0.5 * (a.f + b.f));
    let nearness = 1.2 - farness;
    if (nearness <= 0) {
      break;
    }

    let nearnessSquared = nearness * nearness;
    let d = 4.906 * farness * nearnessSquared * nearnessSquared;
    let dCubed = d * d * d;
    let intensity = a.intensity * b.intensity;
    pairTerms[triangleFlatten(a.key, b.key)] += intensity * dCubed * dCubed
  }
}

function getPairTerm(pitch1, pitch2) {
  return pairTerms[triangleFlatten(pitch1 - 21, pitch2 - 21)];
}

function getGuide(chord) {
  let rawDissonance = 0;
  for (let i = 0; i < chord.length; i++) {
    for (let j = 0; j < i; j++) {
      rawDissonance += getPairTerm(chord[i], chord[j]);
    }
  }

  let dissonance = Math.pow(rawDissonance, 1 / 6);

  let deltas = [];
  for (let pitch = 21; pitch < 109; pitch++) {
    let rawDelta = 0;
    let direction = 1;
    for (let i = 0; i < chord.length; i++) {
      if (chord[i] == pitch) {
        direction = -1;
      } else {
        rawDelta += getPairTerm(pitch, chord[i])
      }
    }

    let newRawDissonance = rawDissonance + rawDelta * direction;
    let newDissonance = Math.pow(newRawDissonance, 1 / 6);
    deltas.push(newDissonance - dissonance);
  }

  return {dissonance: dissonance, deltas: deltas};
}
