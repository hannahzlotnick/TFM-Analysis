
// Part 2: Create stacks using the tif images generated in the previous Part (Part 1)

// Get experiment name
choices = newArray("Syn_","Syn IL1B_","Syn HUVEC_","Syn HUVEC IL1B_","HUVEC_","HUVEC IL1B_");
Dialog.create("Experiment Type Selection");
Dialog.addChoice("Select the type of experiment: ", choices);
Dialog.show();
experiment = Dialog.getChoice();

// Select the folder containing images
inputDir = getDirectory("Choose a Directory with Images");
Series = getFileList(inputDir);
total_series = Series.length/5;
num = 30; // must change this based on how many images you have


for (m = 0; m < num; m++) {
	run("Close All");
	plusone = m + 1;
	counter_to_string = "" + plusone;
	// Write the filenames of the image files seen in the folder
	AfterBeads_image = "AfterBeads_" + experiment + counter_to_string + ".tif";
	BeforeBeads_image = "BeforeBeads_" + experiment + counter_to_string + ".tif";
	
	// Find the filepaths
	AfterBeads_imagePath = inputDir + AfterBeads_image;
	BeforeBeads_imagePath = inputDir + BeforeBeads_image;
	
	// Open the images
	open(AfterBeads_imagePath);
	selectImage(AfterBeads_image);
	image1 = getImageID();
	open(BeforeBeads_imagePath);
	selectImage(BeforeBeads_image);
	image2 = getImageID();
	
	// Create the stack with the open images images
    run("Images to Stack", "use");
    run("Linear Stack Alignment with SIFT", "initial_gaussian_blur=1.60 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=4 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 maximal_alignment_error=25 inlier_ratio=0.05 expected_transformation=Rigid interpolate");
	saveAs("Tiff", inputDir + "AlignedStack_" + experiment + counter_to_string);
	run("8-bit");
	run("iterative PIV(Advanced)...", "  piv1=128 sw1=256 vs1=64 piv2=64 sw2=128 vs2=32 piv3=48 sw3=128 vs3=16 correlation=0.60 batch postprocessing=DMT postprocessing_0=3 postprocessing_1=1 path=[" + inputDir + "]");

}

run("Close All");

list = getFileList(inputDir);
total_files = list.length;
counter = 1;
for (i = 0; i < total_files; i++) {
    filename = list[i];
    if (endsWith(filename, "PIV3_DMT_disp.txt")) {
        // Generate a new output file name
        inputFileName = filename;
        print(inputFileName);
        
        startPos = indexOf(inputFileName, experiment) + 4; // This number will change depending on the experiment
        
        // Syn +4
        // Syn IL1B +9
        // Syn HUVEC +10
        // Syn HUVEC IL1B +15
        // HUVEC +6
        // HUVEC IL1B +11
        
        endPos = indexOf(inputFileName, ".tif");
        number = substring(filename, startPos, endPos);
        print(number);
        outputFileName = "PIV_Stack" + number + ".txt";

        // Copy the identified file to a new name/location
        File.copy(inputDir + inputFileName, inputDir + outputFileName);

        
        
        run("FTTC ", "pixel=0.2167 poisson=0.45 young's=5000 regularization=0.000000001 plot plot=1024 plot=1024 select=[" + inputDir + outputFileName + "]");
        
        run("Close All");
        
        // Increment the counter 
        counter = counter + 1;
        //}
    }
}

        // Properly include the newly named file in the FTTC analysis
        //run("FTTC ", "pixel=0.2167 poisson=0.45 young's=5000 regularization=0.000000001 plot plot=1000 plot=1000 select=[" + inputDir + outputFileName + "]");
//    	paramFile = inputDir + "FTTCparameters_" + outputFileName;
//        if (File.exists(paramFile)) {
//            File.delete(paramFile);
        //run("Close All");
 