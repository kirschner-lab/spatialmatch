// Merge all channels except for fib, myofib, and tnf.

// Configuration parameters.
img_type = 0; // 0 = GranSim, 1 = MIBI-TOF.
home = getInfo("user.home");
dir_inputs = newArray(
	"~/modelruns/2024-07-19-A-gr-50k/img",
	"~/immunology/GR-ABM-ODE/simulation/scripts/calibration/mibi/imgs");
dir_input = replace(dir_inputs[img_type], "~", home);
dir_outputs = newArray(
	"~/modelruns/2024-07-19-A-gr-50k/img_stacks",
	"~/modelruns/2024-07-19-A-gr-50k/img_stacks_mibi");
dir_output = replace(dir_outputs[img_type], "~", home);
calibrations = newArray(0.02, 0.001);
calibration = calibrations[img_type];
n_channels = 9;

setBatchMode(true);

// Sort the image files using a results table.
files_input_all = getFileList(dir_input);
if (files_input_all.length == 0) {
	exit("Error: No input files found in " + dir_input);
}
n_images = files_input_all.length / n_channels;
files_input_unsorted = newArray(n_images * n_channels);
j = 0;
for (i = 0; i < files_input_all.length; i++) {
	file = files_input_all[i];
	files_input_unsorted[j] = file;
	file_split = split(replace(file, ".tif", ""), "_");
	setResult("idx", j, j);
	setResult("exp", j, parseInt(substring(file_split[0], 3)));
	setResult("t", j, parseInt(substring(file_split[1], 4)));
	setResult("ch", j, parseInt(file_split[2]));
	ch_name = file_split[3];
	setResult("ch_name", j, ch_name);
	if (matches(ch_name, "^fib|myofib|ifng|tnf$")) {
		setResult("keep", j, false);
	} else {
		setResult("keep", j, true);
	}
	j++;
}
Table.sort("ch");
Table.sort("t");
Table.sort("exp");

// Load, process, and save the images.
k = 0;
for (i = 0; i < nResults; i += n_channels) {
	offset = getResult("idx", i);
	path_output =
		dir_output +
		File.separator +
		"exp" + getResult("exp", i) + "_" +
		"time" + getResult("t", i) + ".tif";
	// Read in the input images.
	close("*");
	for (j = 0; j < n_channels; j++) {
		keep = getResult("keep", i + j);
		if (keep) {
			path_input =
				dir_input +
				File.separator +
				files_input_unsorted[offset + j];
			if (! File.exists(path_input)) {
				error("File does not exist: " + path_input);
			}
			open(path_input);
			// Merge T-cell channels using maximum value.
			if (getResultString("ch_name", i + j) == "t") {
				if (isOpen("t")) {
					im = getTitle();
					imageCalculator("Max", "t", im);
					close(im);
				} else {
					rename("t");
				}
			}
		}
	}
	// Combine images into a stack to apply subsequent operations to all
	// images.
	run("Images to Stack", "use");
	// Set calibration to later add a scale bar.
	Stack.setXUnit("mm");
	run("Properties...", "channels=1 slices=" +
	    nSlices +
	    " frames=1" +
	    " pixel_width=" + calibration +
	    " pixel_height=" + calibration +
	    " voxel_depth=" + calibration);
	// Convert sequential object labeling to a binary mask.
	run("Manual Threshold...", "min=0 max=0");
	setThreshold(-1000000000000000000000000000000.0000, 0.000);
	run("Analyze Particles...", "  show=Masks stack");
	// Invert the mask.
	run("XOR...", "value=11111111 stack");
	// Colorize image.
	run("Stack to Hyperstack...", "order=xyczt(default) channels=" +
	    nSlices +
	    " slices=1 frames=1 display=Color");
	run("Blue"); // mac
	setSlice(nSlices);
	run("Grays"); // caseum
	Property.set("CompositeProjection", "Sum");
	Stack.setDisplayMode("composite");
	// Resize MIBI-TOF images to match GranSim.
	if (img_type == 1) {
		run("Canvas Size...", "width=6000 height=6000 position=Center zero");
		run("Options...", "iterations=9 count=1 black do=Dilate");
		run("Size...", "width=300 height=300 depth=3 constrain interpolation=Bilinear");
	}
	// Save to disk.
	save(path_output);
	print("Wrote " + path_output);
	k++;
}
close("*");

setBatchMode(false);
