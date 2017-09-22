//---------------------------------------------------------------------
//
//    This script contains the functions to:
// 1) calculate the probability distributions of note classes of a single voice of midi file
//    i.e it creates a class for each pitch and counts the number of ocurrences
// 2) the relative entropy (distance or Kullback-Leibler divergence) of a set of files
//    respect to a define apriori entropy.
//
//---------------------------------------------------------------------
//------------------------------------------------------------------------------//
//   This script uses the "ImportMidiFile" class which should be located at
//   the Extensions folder
//
//   To confirm that the midi format is read correctly declare
//   (using the appropiate file route) the following lines:
(
m = SimpleMIDIFile.read("/pad/to/file/Bach_1080_xiv_unfin_A.mid");
m.noteEvents.collect({ |i| i.postln });
);
//    They should post what something similar to what is shown below:
/*
[ 0, 0, noteOn, 0, 72, 73 ]
[ 0, 479, noteOn, 0, 72, 0 ]
[ 0, 480, noteOn, 0, 69, 69 ]
[ 0, 959, noteOn, 0, 69, 0 ]
*/
// => typeMidi != 0 !!!!!!!!!!!!!!
//    If so use # n, d, t = ImportMidiFile(file, 1);
//    otherwise use # n, d, t = ImportMidiFile(file, 0);
//-----------------------------------------------------------------------------
//
//    The distribution function calculates
//    the discrete probability distribution function for the midi file
//
//-----------------------------------------------------------------------------
(
~distribution = {
	arg file;
	var notes;
	var classes;
	var count_classes;
	var note, class;
	var index;
	var acumulatedNotesPerClass = [0,0,0,0,0,0,0,0,0,0,0,0];
	var acumulatedNotesPerClassNormalized;
	# n, d, t = ImportMidiFile(file, 1);
	notes = n;
	classes = [];
	count_classes = [];
	notes.size.do{arg i;
		//'value of i : '.post; i.postln;
		note = notes[i].unbubble(0,2);//.postln;

		if(classes.indexOfEqual(note).isNil)
		{
			classes = classes.add(note);
			count_classes = count_classes.add(1);

		}{
			count_classes[classes.indexOfEqual(note)] = count_classes[classes.indexOfEqual(note)] + 1
		}
	};

	classes.do{arg x,i;
		index = (x%12);//.postln;
		acumulatedNotesPerClass[index] = acumulatedNotesPerClass[index] + count_classes[i];
		//i.post; c.postln;
	};
	'Current file:'.post;file.postln;
	'Probability distribution: '.post; acumulatedNotesPerClass.postln;
	acumulatedNotesPerClassNormalized = acumulatedNotesPerClass/sum(acumulatedNotesPerClass);
	'Normalized probability distribution'.post;acumulatedNotesPerClassNormalized.postln;
});
//-------------------------------------------------------------------------------
//               Function to calculate the Relative entropy between two files
//-------------------------------------------------------------------------------
(~relativeEntropy = {arg distribution, aprioriDistribution;
	var relativeH;
	var temporal;
	relativeH =  distribution * ( log(distribution/aprioriDistribution) );
	relativeH.do{arg x;
		if( (x.asString != "-nan") && (x.asString!= "nan")){temporal = temporal.add(x)}
	};
	relativeH = sum(temporal);
	//'Relative Entropy of p|q = '.post;relativeH.postln;
});

// Function that calculates the relative entropies of a set of files respect to a defined
// apripri entropy

(~relativeEntropies = {
	arg files, apriori;
	var aprioriDistribution;
	var distributionNotes, relativeEntropy;
	var entropies = [];
	aprioriDistribution = ~distribution.value(apriori);
	files.do{
		arg x;
		distributionNotes = ~distribution.value(x);
		relativeEntropy = ~relativeEntropy.value(distributionNotes,aprioriDistribution);
		entropies = entropies.add(relativeEntropy);
	};
	'Relative Entropies : '.post; entropies.postln;
});

//  USAGE:
//  declare ~distribution, ~relativeEntropy and ~relativeEntropies function

//   Examples files from part A ( Alto voice of midi files )
//   declare the set of files
~files = [
	"/pad/to/file/Bach_1080_xiv_Korsyn_only_A.mid",
	"/pad/to/file/Bach_1080_xiv_Moroney_only_A.mid"
];

// ~relativeEntropies.value(set of files,/path/to/aprioriEntropy)
~relativeEntropies.value(~files,"/pad/to/file/Bach_1080_xiv_unfin_A.mid")

