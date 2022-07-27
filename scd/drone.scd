(
s.quit;
s.options.numOutputBusChannels = 8;
~out = 0;
s.waitForBoot({

	SynthDef.new(\drone,
		{

			arg freq = 100, amp = 0.1,
			atk = 1, sus = 1, rel = 3, gate = 1,
			rq = 0.001, lowCenter = (-5), highCenter = 5, density = 3,

			spread = 0.5, lagTime = 5,
			controlOut = 0;
			var sig, temp = 0, env, pan;

			pan = LFNoise2.kr(density);
			SendReply.kr(Impulse.kr(density*5), '/panPosition', [controlOut, pan]);

			env = EnvGen.kr(Env.asr(atk, sus, rel), gate, doneAction: 2);

			sig = Saw.ar(freq.lag(lagTime));

			2.do({ arg i;
				temp = temp + BPF.ar(sig, LFNoise2.kr(density).range(lowCenter,highCenter)+freq*(i+1), rq);
				//temp = FreeVerb.ar(temp, {rrand(0,0.5)}, {rrand(0.5,0.7)}, {rrand(0.5,0.9)});
			});

			sig = Splay.ar(temp, spread, amp, pan);
			Out.ar(~out, sig);
	}).add;

	s.sync;



	~address = NetAddr.new("127.0.0.1", 12345);
	~hue = [ 0, 21.25, 42.5, 63.75, 85, 106.25, 127.5, 148.75, 170, 191.25, 212.5, 233.75]+20;
	~saturation = 100;
	~bright = [255*0.5, 255*0.4, 255*0.5, 255*0.6, 255*0.7, 255*0.8, 255*0.9]; // for each octave

	~midiLow = 27;
	~midiHigh = 110;
	~lagTime = 3;
	~harmonics = 6;
	~minSize = 5;
	~maxSize = 20;

	~createChord = {
		~size = rrand(~minSize,~maxSize);
		~myChord = Array.fill(~size, {rrand(~midiLow,~midiHigh)});
		~tension = HarmonicTension(~myChord);
		~tension.nHarmonics = ~harmonics;
		~rough = ~tension.roughness;
		~stepChange = [-1,1].choose;
		postf("step: % \n", ~stepChange);
		~booleanLoop = true;
		~searching = false;

		// send size chord to openFrameworks
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




	~changeNote = {
		var position, tempNote, tension, rough;
		//"entrei".postln;
		~newChord = ~myChord;
		position = rrand(0, ~newChord.size-1);
		tempNote = ~newChord[position] + ~stepChange;
		if (tempNote < ~midiLow, { tempNote = ~midiLow},{});
		if (tempNote > ~midiHigh, { tempNote = ~midiHight},{});

		~newChord[position] = tempNote;

		tension = HarmonicTension(~newChord);
		tension.nHarmonics = ~harmonics;
		rough = tension.roughness;


		[position,rough];

	};

	~makeChange = {

		//"MC-Bool".post; ~booleanLoop.postln;
		{~booleanLoop}.while({
			var return, position, tempRough;
			~searching = true;
			return = ~changeNote.value;
			position = return[0];
			tempRough = return[1];
			postf("rough: % - % CN\n", tempRough, ~newChord);
			if ( tempRough < ~rough
				,{
					~searching = false;
					~booleanLoop = false;
					~myChord = ~newChord;
					~rough = tempRough;
					~updateChordPlaying.value(position);
			},{});

		});
		~booleanLoop = true;
	};

		~freeSynths = {
		~synths.do({ arg i;

			i.set(\gate, 0);
		});
		~bus.do({ arg bus;
			bus.free;
		});

	};

	~startPlaying = {
		~freeSynths.value;
		~size.do({ arg i;
			~synths[i].set(\gate, 1);
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

		~address.sendMsg("/updateNote", position, ~hue[note], ~saturation, ~bright[octave]);

	};


	// main code


	~createChord.value;
	~createSynths.value;
	~updateAllFreqs.value;
	~startPlaying.value;


	~run = Routine.new({
		inf.do({
			if (~rough < 0.6 , {
				~freeSynths.value;
				~lagTime-1.wait;
				~createChord.value;
				~createSynths.value;
				~updateAllFreqs.value;},{});
			postf("rough: % - % MAIN\n", ~rough, ~myChord);



			if (~searching == false, {
				~makeChange.value;},{});
			~lagTime.wait;
		});
	}).play;

	 ~sendPanPosition = OSCFunc({ | msg |
		//postf("bus: % val: % \n", msg[3], msg[4]);
		~address.sendMsg("/positions", msg[3], msg[4]);


	}, '/panPosition');

~resetAll = {
		~freeSynths.value;
	~createChord.value;
	~createSynths.value;
	~updateAllFreqs.value;
	~startPlaying.value;

	~run.reset;
	};

});

)

~resetAll