// Get experiment name
choices = newArray("Syn","Syn IL1B","Syn HUVEC","Syn HUVEC IL1B","HUVEC","HUVEC IL1B");
Dialog.create("Experiment Type Selection");
Dialog.addChoice("Select the type of experiment: ", choices);
Dialog.show();
experiment = Dialog.getChoice();

// Prompt the user to select the first file, This is the BEFORE file
filePath1 = File.openDialog("Select the first hyperstack file (before)");

// Get the directory and filename from the selected file path
inputDir1 = File.getParent(filePath1);
fileName1 = File.getName(filePath1);
//fileName1 = fileName1.replace(fileName1, experiment + "_Before");

// Prompt the user to select the second file
filePath2 = File.openDialog("Select the second hyperstack file (after)");

// Get the directory and filename from the selected file path
inputDir2 = File.getParent(filePath2);
fileName2 = File.getName(filePath2);
//fileName2 = fileName2.replace(fileName2, experiment + "_After");

// Create a new output folder based on the file names
outputDir = inputDir1 + "/" + experiment + "_All/";
File.makeDirectory(outputDir);

// Prompt the user to input the number of series (stacks)
numSeries = getNumber("Enter the number of series (stacks) in the file:",0);

// Loop through each series
for (var s = 1; s <= numSeries; s++) {
    // Open each series individually using Bio-Formats, specifying the series index
    // Create a filename for each series with the file name and series number
    // Save the current series as a TIFF file in the new output directory
    // Close the series after saving to free memory
    run("Bio-Formats Importer", "open=[" + filePath1 + "] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_" + s);
	filename1 = fileName1.replace(fileName1, "Before") + "_" + (s) + ".tif";
	saveAs("Tiff", outputDir + filename1);
	close();
	
	run("Bio-Formats Importer", "open=[" + filePath2 + "] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_" + s);
    filename2 = fileName2.replace(fileName2, "After") + "_" + (s) + ".tif";
    saveAs("Tiff", outputDir + filename2);
    close();
}

