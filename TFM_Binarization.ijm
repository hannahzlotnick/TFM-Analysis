// Get experiment name
choices = newArray("Syn_","Syn IL1B_","Syn HUVEC_","Syn HUVEC IL1B_","HUVEC_","HUVEC IL1B_");
Dialog.create("Experiment Type Selection");
Dialog.addChoice("Select the type of experiment: ", choices);
Dialog.show();
experiment = Dialog.getChoice();

// Select the folder containing images
inputDir = getDirectory("Choose a Directory with Images");

// Get a list of files in the directory
list = getFileList(inputDir);
total_files = list.length; 
half_files = list.length/2;

// Part 1: Loop through all files to format the Before and After images, these should all be in the 
// same folder after splitting and saving the multipoint files
// Also, create lists of the files names for the Before and After images

for (i = 0; i < total_files; i++) {
    filename = list[i];
    counter_to_string = "" + i;
// Process Before image, create .tif for beads and .jpg for cell
    if (startsWith(filename, "Before")) {
        // Open the image
        open(inputDir + filename); // Open the image in the directory
        run("Split Channels"); // Split channels 
        
        for (j = 1; j <= 2; j++) { // If there are more than 2 channels, change the 2 to 3, etc.
    		
    		// Get the title of the image
    		imageTitle = getTitle();
        	
   			if (startsWith(imageTitle, "C1-")) {
   				//lastChar = substring(imageTitle, imageTitle.length - 5, imageTitle.length - 4);
   				lastChar = imageTitle.replace("^.*_(\\d+)\\.tif$", "$1");
    			saveAs("Tiff", inputDir + "BeforeBeads_" + experiment + lastChar);
    			close();
    		}
    		if (startsWith(imageTitle, "C2-")) {
    			//lastChar = substring(imageTitle, imageTitle.length - 5, imageTitle.length - 4);
    			lastChar = imageTitle.replace("^.*_(\\d+)\\.tif$", "$1");
    			setThreshold(19, 255);  // Set your desired threshold values (adjust as needed)
    			run("Make Binary");  // Convert to binary image
    			run("Invert");  // Invert the binary image (0s become 255s and 255s become 0s)
    			saveAs("jpg", inputDir + "Binary_Cell_" + experiment + lastChar);
    			close();
    		}
        }
    }

// Process After image, create .tif for beads, ignore the cell image (cell is dead)
	if (startsWith(filename, "After")) {
		// Open the image
        open(inputDir + filename); // Open the image in the directory
        run("Split Channels"); // Split channels 

		for (k = 1; k <= 2; k++) { // If there are more than 2 channels, change the 2 to 3, etc.
    		
    		// Get the title of the image
    		imageTitle = getTitle();
  
    		if (startsWith(imageTitle, "C1-")) {
    			lastChar = imageTitle.replace("^.*_(\\d+)\\.tif$", "$1");
    			//lastChar = substring(imageTitle, imageTitle.length - 5, imageTitle.length - 4);
    			saveAs("Tiff", inputDir + "AfterBeads_" + experiment + lastChar);
    			close();
    		}
    		if (startsWith(imageTitle, "C2-")) {
    			close();
    		} 	
    	}
	}
// Else, continue to the next image set
	else {
		continue;
	}  	
}


