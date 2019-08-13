
The gui interface was developed using guide in MATLAB.

RUNNING THE PROGRAM
- The application can be started by running the Demo.m script in MATLAB.
- Alternatively, the application can be initialised by running the executable ___.
- The Demo.fig file saves the gui structure, however, it is not required to run the program.

GUI ORGANISATION
- The original image is displayed in the top left corner. The processed image is displayed in the top right corner.
For multiple image operations, A second image can be loaded in the bottom left corner. Finally, in the bottom left corner,
the histogram of the current image can be displayed.
The program can load any image type format (including RAW).
The processed image can be saved using "Save image" button.

- The gui was divided into several panels that implemented the processing functionality
required throughout the different labs.
The following panels were created:

1) The General Panel
- ROI: This allows one to select a region-of-interest in the original image. Then, all the processing is selected in this ROI.
- Salt-pepper: Allows to add salt-and-pepper noise to the current image.
- Image selection: When 2 images are loaded, user can select which one to apply the processing operations.
- Reset: Reset the gui by going back to original state.
- Undo: Undo processing performed.

2) Processing Panel
- This panel implements the functions for re-scaling/shifting (lab2) and point processing and bit-plane slicing (lab4).
- Factor: this user input parameter is used for the following functions: shift (shift value); rescaling (scaling factor); power law (gamma); bit-plane slicing (bit-plane #)
- Apply: apply the operation to the current image.

3) Multiple Image Panel
- This panel implements the functionality for arithmetic and boolean operations between two images (lab3).

4) Filtering Panel
- This includes the linear and order-statistics filtering operations (lab 6 and 7).
- User can select type of filtering and size of the kernel.
- Please see functions in the code for more details (everything is commented).

5) Histogram Panel
- This handles the histogram computation of the image and automatic histogram equalisation (lab 5). When a colour image is used, the 3 R,G and B histograms are shown.

6) Thresholding Panel
- This panel implements manual, automatic and adaptive thresholding methods (lab 8).
- When manual method is selected, user can input value in "Enter 'a' or threshold"
- For automatic thresholding, the threshold found is displayed.
- For adaptive thresholding, the 'a' and 'b' parameters can be introduced by the user. These control the variance and mean, respectively.
The user can also select the type of mean: neighbourhood mean (local) or global (whole image).

AUXILIARY FUNCTIONS
Some functions were developed that are used in the main Demo.m script. All auxiliary functions are located in aux_fun folder and script's name start by IP_<fun>.m
- IP_Normalise.m: Normalises the image from 0-255.
- IP_getFilt.m: Gets kernel selected by user.
- IP_LinearFiltering.m: Apply linear filtering operation to the image.
- IP_StatFiltering.m: Apply high-order filtering operation to the image.
- IP_AdaptThr.m: Get mean and variance images to apply adaptive thresholding.

EXAMPLE IMAGES
- Example images are provided in the images folder.


Goncalo Figueira
12/03/19
ec18438@qmul.ac.uk
