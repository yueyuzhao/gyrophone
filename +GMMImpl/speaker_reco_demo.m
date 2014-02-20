% speaker_reco_demo
% A simple speaker recognition demo program
%               -anil alexander 23rd Oct 2004 
% mods for Biometrics 2006 course (correct path, show ID matrix)
% Jonas Richiardi 

%define all the invariants
No_of_Gaussians=10;
%Reading in the data 
%Use wavread from matlab 
disp('-------------------------------------------------------------------');
disp('                    Speaker recognition Demo');
disp('A simple demonstration of speaker recognition using MFCCs and GMMS');
disp('Speech Processing and Biometrics Group -ITS, EPFL');
disp('-------------------------------------------------------------------');

%-----------reading in the training data----------------------------------
training_data1=wavread('..\..\data\speaker\01_train.wav');
training_data2=wavread('..\..\data\speaker\02_train.wav');
training_data3=wavread('..\..\data\speaker\03_train.wav');

%------------reading in the test data-----------------------------------
[testing_data1,Fs,nbits]=wavread('..\..\data\speaker\01_test.wav');
testing_data2=wavread('..\..\data\speaker\02_test.wav');
testing_data3=wavread('..\..\data\speaker\03_test.wav');

disp('Completed reading taining and testing data (Press any key to continue)');
pause;

%Fs=8000;   %or obtain this from wavread

%-------------feature extraction------------------------------------------
training_features1=melcepst(training_data1,Fs);
training_features2=melcepst(training_data2,Fs);
training_features3=melcepst(training_data3,Fs);

disp('Completed feature extraction for the training data (Press any key to continue)');
pause;


testing_features1=melcepst(testing_data1,Fs);
testing_features2=melcepst(testing_data2,Fs);
testing_features3=melcepst(testing_data3,Fs);

disp('Completed feature extraction for the testing data (Press any key to continue)');
pause;

%-------------training the input data using GMM-------------------------
%training input data, and creating the models required
disp('Training models with the input data (Press any key to continue)');

[mu_train1,sigma_train1,c_train1]=gmm_estimate(training_features1',No_of_Gaussians);
disp('Completed Training Speaker 1 model (Press any key to continue)');
pause;

[mu_train2,sigma_train2,c_train2]=gmm_estimate(training_features2',No_of_Gaussians);
disp('Completed Training Speaker 2 model (Press any key to continue)');
pause;

[mu_train3,sigma_train3,c_train3]=gmm_estimate(training_features3',No_of_Gaussians);
disp('Completed Training Speaker 3 model (Press any key to continue)');
pause;


disp('Completed Training ALL Models  (Press any key to continue)');

pause;
%-------------------------testing against the input data-------------- 

%against the first model
[lYM,lY]=lmultigauss(testing_features1', mu_train1,sigma_train1,c_train1);
A(1,1)=mean(lY);
[lYM,lY]=lmultigauss(testing_features2', mu_train1,sigma_train1,c_train1);
A(1,2)=mean(lY);
[lYM,lY]=lmultigauss(testing_features3', mu_train1,sigma_train1,c_train1);
A(1,3)=mean(lY);

%against the second model
[lYM,lY]=lmultigauss(testing_features1', mu_train2,sigma_train2,c_train2);
A(2,1)=mean(lY);
[lYM,lY]=lmultigauss(testing_features2', mu_train2,sigma_train2,c_train2);
A(2,2)=mean(lY);
[lYM,lY]=lmultigauss(testing_features3', mu_train2,sigma_train2,c_train2);
A(2,3)=mean(lY);

%against the third model
[lYM,lY]=lmultigauss(testing_features1', mu_train3,sigma_train3,c_train3);
A(3,1)=mean(lY);
[lYM,lY]=lmultigauss(testing_features2', mu_train3,sigma_train3,c_train3);
A(3,2)=mean(lY);
[lYM,lY]=lmultigauss(testing_features3', mu_train3,sigma_train3,c_train3);
A(3,3)=mean(lY);

disp('Results in tabular form of the comparisons');
disp('Note:');
disp('Each column i represents the test recording of Speaker i');
disp('Each row i represents the training recording of Speaker i');
disp('The diagonal elements (corresponding to same speaker comparisons');
disp('-------------------------------------------------------------------');
A
disp('-------------------------------------------------------------------');
% show as matrix for intuition
figure; imagesc(A); colorbar;