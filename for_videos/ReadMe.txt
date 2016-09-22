So, this contains all the current code to 1) track from the high res, 2) align and impute the data based on the potentially shitty livetrack tracking, and 3) calibrate and smooth for the regressors.

Order:

trackFromVideo(subject_num,run,whetherOrNotYouWantAVideoOuput) -Video output option slows things down and uses getFrame; needs oversite at start to segment the space you care about in the image, and has two threshold to determine pupil and glint at the top

compareReports(subject_num,run) - aligns the data to the old tracking, and imputes the Ts

calibrateAndSmooth(subject_num,run,calibration_matrix) - apply calibration matrix, smooth data a bit afterward, and output the regressors we need; Requires the choice of calibration matrix 