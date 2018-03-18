var partials = [];
for (var key = 0; key < 88; key++) {
  var fundamental = 440 * Math.pow(2, (key - 48) / 12)
  for (var multiplier = 1; multiplier < 7; multiplier++) {
    var amplitude = 1 / multiplier;
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

for (var i = 0; i < partials.length; i++) {
  var a = partials[i];
  for (var j = i - 1; j >= 0; j--) {
    var b = partials[j];
    if (a.key == b.key) {
      continue;
    }

    var farness = (a.f - b.f) / getBandwidth(0.5 * (a.f + b.f));
    var nearness = 1.2 - farness;
    if (nearness <= 0) {
      break;
    }

    var nearnessSquared = nearness * nearness;
    var d = 4.906 * farness * nearnessSquared * nearnessSquared;
    var dCubed = d * d * d;
    var intensity = a.intensity * b.intensity;
    pairTerms[triangleFlatten(a.key, b.key)] += intensity * dCubed * dCubed
  }
}

function getPairTerm(pitch1, pitch2) {
  return pairTerms[triangleFlatten(pitch1 - 21, pitch2 - 21)];
}

function getDissonance(chord) {
  var dissonance = 0;
  for (var i = 0; i < chord.length; i++) {
    for (var j = 0; j < i; j++) {
      dissonance += getPairTerm(chord[i], chord[j])
    }
  }

  return Math.pow(dissonance, 1 / 6);
}
