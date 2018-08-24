function [  ] = saveOutputFiles( result,lv,nRoi,outFileName )
%% saveOutputFiles - writes the raw BSR values as a nRoi x nRoi matrix into a txt file (with suffix _rawBSR)
%   Inputs :
%       result - result.mat file from the PLS analysis
%       lv - which Latent Variable you want to save
%       nRoi - number of ROIs
%       outFileName - prefix of the output txt file

bootstrap_ratio_lv1=result.boot_result.compare_u(:,lv);
b= triu(ones(nRoi),1);
b(b==1)=bootstrap_ratio_lv1;
test=b'+b;
[~,outFileName,~]=fileparts(outFileName);
dlmwrite(strcat(pwd,'/', outFileName, '_rawBSR_LV',num2str(lv),'.txt'), test, '\t');


end

