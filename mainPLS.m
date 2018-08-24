%% Script to set options and run PLS analysis.
clc;
clear all;
close all;
currDir=pwd;

addpath(genpath('/path/to/scripts/'));

% Set up subjects in each group
allSubjectList={'s01','s02'};
group1_list={'s01'};
group2_list={'s02'}l

% subjectList={group1_list, group2_list }; % 2 separate groups
subjectList = {allSubjectList}; % Single group

%TODO: Add resting state as well
conditions = {'condA', 'condB'};
nsubj=cellfun('length',subjectList);
ncond=numel(conditions);

nRoi = 64; %no of ROis
behav_vector=spm_load('/path/to/behavVector.txt'); % For BPLS
contrast_vector=spm_load('/path/to/contrastFile.txt'); % For Non-Rotated PLS

matDirName='plsConnectivityMats'; % Folder inside each subject's folder containg the connectivity matrices.
flag=1; %set this to 1 to stack Z map (Fisher R-Z transformed)

% Call script to stack datamat
disp('Stacking datamats....');
datamat = stackPLSdatamat(subjectList, conditions,'/path/to/input/datamats/', nRoi, matDirName,flag); 

%% Options to set before running PLS analysis
% few options for the analysis, for more help see pls_analysis.m
% method: This option will decide which PLS method that the
% program will use:
%			1. Mean-Centering Task PLS
%			2. Non-Rotated Task PLS
%			3. Regular Behavior PLS
%			4. Regular Multiblock PLS
%			5. Non-Rotated Behavior PLS
%			6. Non-Rotated Multiblock PLS
%  num_boot - no. of bootstraps
%  num_perm - no of permutations

option.method = 1;
option.meancentering_type = 0;
option.num_boot = 500; % Number of bootstraps
option.num_perm = 500; % Number of permutations
% option.stacked_behavdata=behav_vector; % Set this for BPLS
% option.stacked_designdata=contrast_vector; % Set this for Non-Rotated PLS

outFileName='myOutputFile_FCresult'; % Filename for results.mat

% run pls
disp('Running PLS analysis...');
result = pls_analysis(datamat,nsubj,ncond,option);

%save result.mat to current working directory
disp('Saving result file...');
% save(strcat(currDir, '/', outFileName, '.mat'), 'result');

%% Looking at results

% Plot p-values
pval = result.perm_result.sprob
nLV=numel(pval);
figure;
bar(pval,'r');
hold on;
h = zeros(nLV,1);
for i=1:nLV
    h(i)=plot(NaN,NaN, '.r');
end
legend(h,strcat('LV', num2str([1:nLV]'), {' - '} ,num2str(pval)));
title(['Permuted values greater than observed, ', num2str(option.num_perm), ' permutation tests']);
hold off;

% Plot effect sizes (% crossblock covariance)
pcov = result.s.^2 / sum(result.s.^2)
figure;
bar(pcov);
hold on;
h = zeros(nLV,1);
for i=1:nLV
    h(i)=plot(NaN,NaN, '.');
end
legend(h,strcat('LV', num2str([1:nLV]'), {' - '} ,num2str(pcov*100), '%'));
title('Percent Crossblock covariance');
hold off;

% Display Results for each LV (displays task LVs and BSR gris plots)
disp('Displaying Figures...')
displayPLSresults(result,conditions,1,nRoi);

%save rawBSR matrix as a text file
disp('Saving raw BSR...')
% saveOutputFiles(result,1,nRoi,outFileName);

%TODO: Compute mean connectivity values. output txt file of mean R


