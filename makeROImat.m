function [ ] = makeROImat( inputFilename, outputDir, outputFilename,checkImg )
%% makeRoiMat(inputFilename, outputDir, outputFilename) - Charana Rajagopal
% Creates MAT files for each roi for each coordinate from list of coordinates in
% inputFilename. The ROI files are a "3D cross" of voxels centered around each
% coordinate 
% Input arguments:
%       inputFilename - A txt file containing coordinates of ROI in MNI
%       space with 4x4x4 mm voxel sizes
%       outputDir - full path to dir to which the ROI MAT files are written. (If
%       the dir doesn't exist, it will create one)
%       outputFilename - prefix of output filenames 
%       checkImg - Optional Input. Set to 1 if you want to save the ROIs as
%       .img files. (Default 0)

%%SET path_to_marsbar
path_to_marsbar='/path/to/marsbar/';
addpath(genpath(path_to_marsbar))

% Check for optional input
if nargin == 3
    checkImg = 0;
end

% Check value of checkImg
if checkImg ~= 1 && checkImg ~= 0
    error('checkImg can only be either 1 or 0');
end

%Load the input text file
vals = spm_load(inputFilename);

% TODO: Add labels (maybe)
%vals = spm_load('45y39m46o_M-CPLS_AllTasks_EncRet_NonOverlappingPeakROIs.txt');

if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
if  checkImg == 1
    imgDir=strcat(outputDir, '/roi_img_files');
    if ~exist(imgDir, 'dir')
        mkdir(imgDir);
    end
end

% baseimg='/data/rajsri/wEPI_1.nii';
% myspace=mars_space(baseimg);
radius = 4;
rois = {};
for pt_no = 1:size(vals,1)
    params = struct('centre', vals(pt_no, :), 'radius', radius);

    roi = maroi_sphere(params);

    rois{end+1} = roi;
    saveroi(roi, sprintf(strcat(outputDir,'/',outputFilename,'_%03d_roi.mat'), pt_no));

    sp=maroi('classdata','myspace');
    
%     if checkImg == 1
%         mars_rois2img(roi,sprintf(strcat(imgDir,'/',outputFilename,'_%03d_roi.img'), pt_no),myspace,'i');
%     end
end
end

