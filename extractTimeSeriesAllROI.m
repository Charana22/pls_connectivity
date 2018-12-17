function [ tc,Onset,R,outMat ] = extractTimeSeriesAllROI(subject_id, dirPath, ouputDirPrefix, roiPath, checkRes )
%% extractTimeSeriesAllROI(subject_id,dirPath, dirPrefix, roiPath, checkRes ) - Charana Rajagopal
% This function computes the connectivity matrix for each subject and saves it in the subject's Nifti/Connectivity/<outputDirPrefix> folder. The saved output file is called subjXXX_Condition.mat (eg: subj102_EncSpatEasy.mat). It contains the following variables:
%           R - NxN connectivity matrix containing Pearson correlation
%           coefficients between each of the N ROIs
%           outMat - "blocked" time series containing the concatenated time
%           series for each task condition
%   Inputs:
%           subject_id - subjectID (folder name of subject)
%           dirPath - path to folder containing all subjects
%           dirPrefix - name of directory where the output files are saved (containing the connectivity mat R and the concatenated time series outMat).
%           roiPath - path to folder containg ROI mat files.
%           checkRes - Optional Input. 1 - Extract residuals. 0 - Extract task signal  (default: 1)
% Eg. to run this script:
%       extractTimeSeriesAllROI('102', '/data/laborajah2/users/CIHRImaging_Notasksremoved/Young/', 'MatFilesMCPLS','/data/laborajah2/users/Lizzy/functionalConnectivity_Lifespan/MCPLS_ROIfiles')



if nargin == 4
    checkRes =1;
end

if checkRes ~=1 && checkRes ~=0
    error('checkRes can only be either 1 or 0');
end
addpath(genpath('/data/rajsri/marsbar-0.44/'));

dirName=strcat(dirPath,subject_id,'/Nifti/Connectivity/',ouputDirPrefix);
% Create directory to store output files
if ~exist(dirName, 'dir')
    mkdir(dirName);
end

%Load SPM.mat
spm_name=fullfile(dirPath,subject_id,'design', 'SPM.mat');


%Load ROIs
% roi_names= importdata('/data/rajsri/connectivity_lizzy/45y39m46o_M-CPLS_AllTasks_EncRet_NonOverlappingPeakROIs_labels.txt');
%
% for i = 1:size(roi_names,1)
%     roi_files{i}=sprintf('/data/rajsri/connectivity_lizzy/roi_files/roi_%02d_roi.mat', i);
% end

D  = mardo(spm_name);
roi_files={};
%Output variable containing time series

listRois=dir(strcat(roiPath,'/*.mat'));
roiNames={listRois.name};
numRoi=numel(listRois);
for i=1:numRoi
    
    
    % Make marsbar ROI object
    R=maroi('load',strcat(roiPath,'/',roiNames{i}));
    roi_files{end+1}=R;
end
% Fetch data into marsbar data object
Y  = get_marsy(roi_files{:}, D, 'mean');



% Estimate design on ROI data
E = estimate(D, Y);
Res = residuals(E);


y = summary_data(Y);
res_tc=summary_data(Res);
fitted_new=y-res_tc;
if checkRes == 1
    tc= res_tc;
else
    tc = fitted_new;
end
size(tc);
%Load onset.mat
x=dir(strcat(dirPath,subject_id,'/Nifti/Connectivity/OnsetFiles/*.mat')); %Fix this for any path
onsetFiles={x.name};
for i = 1:numel(onsetFiles)
    outMat=[];
    loadedOnset=load(strcat(dirPath,subject_id,'/Nifti/Connectivity/OnsetFiles/', onsetFiles{i})); %Fix this for any path
    Onset=loadedOnset.Onset;
    if size(Onset,2)~=1
        error('Onset matrix must be a column vector i.e. size must be Nx1')
    end
    for j = 2:2:size(Onset,1)
        %         size(tc(Onset(j-1):Onset(j)));
        outMat = [outMat;tc(Onset(j-1):Onset(j), :)];
        
    end
    R=corrcoef(outMat);
    delim = '_'; replacewith = ''',''';
    Expression = ['{''' strrep(onsetFiles{i},delim,replacewith) '''}'];
    tokens=eval(Expression);
    % To save the connectivity matrices.
%     save(strcat(dirPath,subject_id,'/Nifti/Connectivity/',dirPrefix,'/subj',subject_id,'_',tokens{2}), 'R', 'outMat');
end



end

