/*

HarmonicTension


a = HarmonicTension([array of midi notes]);
a.nHarmonics = 6; // setup of how many harmonics are in Harmonic Serie
                    // of each note. Default is 10.
a.multiply = true; // choose if the overall roughness will be attenuated by
                    // amplitude of each pair of harmonics. Default is: false.
a.roughness            // calculate overal roughness.
*/


(
s.waitForBoot({

	~lagTime = 5;
	~midiLow = 24;
	~midiHigh = 107;

	SynthDef.new(\drone,
	{

		arg freq = 100, amp = 0.1,
		atk = 1, sus = 1, rel = 3, gate = 1,
		rq = 0.001, lowCenter = (-5), highCenter = 5, density = 3,
		spread = 0.5, lagTime = 5,
		controlOut = 0;
		var sig, temp = 0, env, pan;

		pan = LFNoise1.kr(density);
	    Out.kr(controlOut, pan);

		env = EnvGen.kr(Env.asr(atk, sus, rel), gate, doneAction: 2);

		sig = Saw.ar(freq.lag(lagTime));

		2.do({ arg i;
			temp = temp + BPF.ar(sig, LFNoise2.kr(density).range(lowCenter,highCenter)+freq*(i+1), rq);
				//temp = FreeVerb.ar(temp, {rrand(0,0.5)}, {rrand(0.5,0.7)}, {rrand(0.5,0.9)});
		});

		sig = Splay.ar(temp, spread, amp, pan);
		Out.ar(0, sig);
}).add;

s.sync;

~createChord = {
		~size = rrand(4,20);
	~myChord = Array.fill(~size, {rrand(~midiLow,~midiHigh)}).sort;
	~tension = HarmonicTension(~myChord);
	~rough = ~tension.roughness;
		~stepChange = [-1, 1].choose;
		//~stepChange = 1;
		postf("setpChange: % \n", ~stepChange);

};

~createSynths = {
		~synths = Array.fill(~size, { arg i; Synth(\drone, [\freq, ~myChord[i].midicps, \gate, 0, \lagTime, ~lagTime-1, \controlOut, i])});
};

~updateAllFreqs = {
		~size.do({ arg i;
			~synths[i].set(\freq, ~myChord[i].midicps);
		});
	};

~updateChordPlaying = { arg position;
	~synths[position].set(\freq, ~myChord[position].midicps);
};

~makeChange = {
	var position, newChord, tension, newRough, tempNote;

	newChord = ~myChord;
	position = rrand(0, ~myChord.size -1);
	//stepChange = [-1,1].choose;
		//stepChange = 1;
		tempNote = newChord[position] + ~stepChange;
		if (tempNote <  ~midiLow , { tempNote = ~midiLow},{});
		if (tempNote > ~midiHigh , { tempNote = ~midiHigh},{});

	newChord[position] = tempNote;

	tension = HarmonicTension(newChord);
	newRough = tension.roughness;

	if (newRough > ~rough  , { ~makeChange.value } ,
	{ ~myChord = newChord;
	  ~rough = newRough;
				~updateChordPlaying.value(position);
	});
};

~startPlaying = {
	~size.do({ arg i;
		~synths[i].set(\gate, 1);
	});
};

		~createChord.value;
		~createSynths.value;
	    ~updateAllFreqs.value;
		~startPlaying.value;


	~myPiece = Routine.new({


	inf.do({
			postf("actual: % \n", ~myChord);
			postf("rough: % \n", ~rough);
	~makeChange.value;
			postf("new: % \n", ~myChord);
			postf("rough: % \n", ~rough);
	~lagTime.wait;

			if (~rough < 0.56, {
				~createChord.value;
				~updateAllFreqs.value;
			},{});

	});
}).play;




});

)


/* Colors                H     S      B
vermelho    405          0
            480
laranja     480
            510
amarelo     510
            530
verde       530
            600
ciano       600
            620
azul        620
            680
violeta     680
            790

*/

Qualquer MIDI % 12 acho o pitch class

~hue = [ 0, 8.33, 16.66, 24.99, 33.32, 41.65, 49.98, 58.31, 66.64, 74.97, 83.3, 91.63];
~saturation = 100;
~bright = [30, 40, 50, 60, 70, 80, 90]; // for each octave



~midinotes = (27,28..110);
~midiLow = 27;
~midinotes.do({ arg midinote;

	var oitava, nota;

	oitava = ((midinote - ~midiLow)/12).asInteger;
	nota = midinote - (12*oitava) - 27;

	postf("midi: % pitch: % oitava: % H: % B: %\n", midinote, nota, oitava, ~hue[nota], ~bright[oitava]);
});


