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
	~midiLow = 27;
	~midiHigh = 110;
	~address = NetAddr.new("127.0.0.1", 12345);
// valores para HSB em escala de 0 a 100
	/*
	~hue = [ 0, 8.33, 16.66, 24.99, 33.32, 41.65, 49.98, 58.31, 66.64, 74.97, 83.3, 91.63];
	~saturation = 100;
	~bright = [30, 40, 50, 60, 70, 80, 90]; // for each octave
*/
	~hue = [ 0, 21.25, 42.5, 63.75, 85, 106.25, 127.5, 148.75, 170, 191.25, 212.5, 233.75];
	~saturation = 100;
	~bright = [255*0.3, 255*0.4, 255*0.5, 255*0.6, 255*0.7, 255*0.8, 255*0.9]; // for each octave

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
		~bus = 0;
		~size = rrand(4,20);
	~myChord = Array.fill(~size, {rrand(~midiLow,~midiHigh)}).sort;
	~tension = HarmonicTension(~myChord);
	~rough = ~tension.roughness;
		~stepChange = [-1, 1].choose;
		//~stepChange = 1;
		postf("stepChange: % \n", ~stepChange);
		~address.sendMsg("/setup/size", ~size);
		~sendColors.value;

};

~createSynths = {
		~bus = 0;
		~bus = Array.fill(~size, { Bus.control(s, 1) });
		~synths = Array.fill(~size, { arg i; Synth(\drone, [\freq, ~myChord[i].midicps, \gate, 0, \rel, ~lagTime, \lagTime, ~lagTime-1, \controlOut, ~bus[i]])});
};

~updateAllFreqs = {
		~size.do({ arg i;
			~synths[i].set(\freq, ~myChord[i].midicps);
		});
	};

~updateChordPlaying = { arg position;
	~synths[position].set(\freq, ~myChord[position].midicps);
		~updateColor.value(position);
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

~sendColors = {
		~myChord.do({
			arg midinote, item;
			var octave, note;

			octave = ((midinote - ~midiLow)/12).asInteger;
			note = midinote - (12*octave) - 27;

			~address.sendMsg("/colors", item, ~hue[note], ~saturation, ~bright[octave]);
	//postf("midi: % pitch: % oitava: % H: % B: %\n", midinote, nota, oitava, ~hue[nota], ~bright[oitava]);
});

};


~updateColor = { arg position;

		var midinote, octave, note;

		midinote = ~myChord[position];
		octave = ((midinote - ~midiLow)/12).asInteger;
		note = midinote - (12*octave) - 27;

		~address.sendMsg("/updateNote", [midinote, ~hue[note], ~saturation, ~bright[octave]]);

	};

~sendPanPosition = {
		~size.do({ arg item;

			~address.sendMsg("/position", [item, ~bus[item].getSynchronous]);
		});
	};

~freeSynths = {
		~synths.do({ arg i;
			i.set(\gate, 0);
		});
	};

~startPlaying = {
		~freeSynths.value;
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

			~sendPanPosition.value;

			if ( (~stepChange < 0) && (~rough < 1.3 ),
				{
					~freeSynths.value;
					~lagTime-1.wait;
					~createChord.value;
					~createSynths.value;
					~updateAllFreqs.value;},{});
			if (~rough < 0.56, {
				~freeSynths.value;
				~lagTime-1.wait;
				~createChord.value;
				~createSynths.value;
				~updateAllFreqs.value;
			},{});

	});
}).play;




});

)
