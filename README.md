# FirstDecision
To get Matlab pictures:
	
	plotting3.m contains all code for matlab pictures.
	Different pictures have different function calls; find the desired picture in the functions and uncomment the function call at the top.

	Should automatically call the processing function chef.m to turn raw data into processed data for use in pictures. Make sure to specify the appropriate folderName location for the type of data (I organized by threshold distribution type and social update rule)

To get Python pictures: 
	** need to add the code for these. Once added, the process should be significantly simpler than the process for the matlab pictures. 

To generate raw data files:
	** Future intentions: Make this process less complicated
	Need: MoIMulti.m, callUniform.m, saveRaw.m, and at least one of oneRunPan.m or oneRunSelf.m, 
	1) Modify variables inside callUniform.m to use the appropriate threshold distributions. One can specify distribution, boundaries, clique sizes, and number of 'batches' (sets of trials). More detailed instructions can be found inside callUniform.m.
	 Your end goal is to have batches 1 through as many as desired. It is important that the batch numbers start at 1 and go in order, since the later processing function stops when a batch number goes missing, and batches after a missing number will not be used.
	2) Inside the central parfor loop in saveRaw.m, specify which social updating case is to be used: either run oneRunPan for the omnisicient case, or oneRunSelf for the self-referential one
	3) call callUniform()

Slightly more detailed version of what each .m file does

MoIMulti: R = MoIMulti(z,l,h,time)
	MoI refers to Method of Images; Multi refers to the movable interval boundaries.
	Returns the log likelihood ratio that an undecided agent with threshold (z) has private evidence in the interval ((l),(h)) at time (time), given that the 'correct' decision is the one at the upper (positive) threshold.

callUniform: callUniform()
	The name is a bit of a misnomer. Used to generate raw data batches.
	There are several variables inside the function whose values need to change depending on which case one wants to generate data for. More information on these can be found inside the function itself. 
	When changing these, be sure to also check inside saveRaw.m and make sure that it is calling the appropriate social updating case- either oneRunPan for the omnisicent case or oneRunSelf for the self-referential one (should be in the parfor loop in the middle.)

chef.m: chef(folderName,zMin,zMax,n,social)

	(folderName) should be the distribution location (ex: Uniform, selfUniform, selfHomo, etc) and the threshold bound location (ex: zMin_0_1_zMax_1), so altogether, ex: Uniform/zMin_0_1_zMax_1.
	(zMin) and (zMax) should match the location given in folderName.
	(n) is clique size
	(social) is a flag indicating which information needs to be processed. Processing extra social information takes more time; more detailed instructions about how to use this flag are given in the beginning of the function. 

oneRunPan.m ** don't need to call
	Runs one trial of the omnisicient social case.
	Used when generating the raw data files in saveRaw.m
	('Pan' comes from when the omnisicient case was being called the 'Panopticon' case)

oneRunSelf.m ** don't need to call
	Runs one trial of the self-referential social case.
	Used when generating the raw data files in saveRaw.m

plotting3.m: plotting3()
	Contains functions for various matlab figures.
	Each function call should generate a certain type of figure.
	Which data gets used can be changed by modifying (folderName) variable within the figure function. (folderName) should be the distribution location (ex: Uniform, selfUniform, Tent, etc.)

saveRaw.m: ** don't need to call
	Called by callUniform.m to generate a batch of trials.
	When using, be sure that the central parfor loop is calling the appropriate version of social updating, either oneRunPan or oneRunSelf for omnisicient or self-referential social updating, respectively.
