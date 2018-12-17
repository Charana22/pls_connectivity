function [ ] = displayPLSresults( result, conditions, lv, nRoi)
%% displayPLSresults - 
%   Inputs :
%       result - result.mat file from the PLS analysis
%       conditions - conditions - 1xN containing list of conditions
%       lv - which Latent Variable you want to view
%       nRoi - number of ROIs


%% Bar plots

load('rri_color_code');

numOfGroups=size(result.num_subj_lst,2);
num_conds=length(conditions);
method=result.method;
% display dominant contrast for lv 1
if method == 3 || method == 5
    numOfBehavVecs=size(result.stacked_behavdata,2);
    upperLim=result.boot_result.ulcorr-result.boot_result.orig_corr;
    lowerLim=result.boot_result.orig_corr-result.boot_result.llcorr;
    barResult=result.boot_result.orig_corr;
    for g=1:numOfGroups
        for k=1:num_conds
            bar_hdl = bar((g-1)*numOfBehavVecs*num_conds + [1:numOfBehavVecs] + numOfBehavVecs*(k-1), ...
                barResult((g-1)*numOfBehavVecs*num_conds + [1:numOfBehavVecs] + numOfBehavVecs*(k-1), ...
                lv)); hold on;
            set(bar_hdl,'facecolor',color_code(k,:));
        end
    end
    errorbar(1:size(barResult,2),barResult(:,lv), lowerLim(:,lv),upperLim(:,lv), 'k.'); hold off;
    y_label='Correlations';
    plot_title='Correlations Overview ';
else
    upperLim=result.boot_result.ulusc-result.boot_result.orig_usc;
    lowerLim=result.boot_result.orig_usc-result.boot_result.llusc;
    barResult=result.boot_result.orig_usc;
    
       
    for g=1:numOfGroups
        for k=1:num_conds
            bar_hdl = bar((g-1)*num_conds + k,barResult((g-1)*num_conds + k,lv)); hold on;
            set(bar_hdl,'facecolor',color_code(k,:));
            
        end
    end
    errorbar(1:size(barResult,2),barResult(:,lv), lowerLim(:,lv),upperLim(:,lv), 'k.'); hold off;
    y_label='Brain Scores';
    plot_title='Task PLS Brain Scores with CI ';
    
    
end



[l_hdl, o_hdl] = legend(conditions, 0);
legend_txt(o_hdl);
set(l_hdl,'color',[0.9 1 0.9]);
setappdata(gca,'LegendHdl2',[{l_hdl} {o_hdl}]);



xlabel('Groups');
ylabel(y_label);
set(gca,'XTick',([1:numOfGroups] - 1)*num_conds + 0.5)
set(gca,'XTickLabel',1:numOfGroups);
title([plot_title, 'of LV: ', num2str(lv)]);


% bar(barResult(:,lv));
% set(gca,'XTick',1:size(barResult,2))
% set(gca,'XTickLabel',newcond);
% hold on;
% errorbar(1:size(barResult,2),barResult(:,lv), lowerLim(:,lv),upperLim(:,lv), 'b.');
% hold off;
% title(['LV' num2str(lv)]);

%% Display bootstrap connectivity values


bootstrap_ratio_lv1=result.boot_result.compare_u(:,lv);

b= triu(ones(nRoi),1);
b(b==1)=bootstrap_ratio_lv1;
test=b'+b;

% Threshold BSR
pctl=prctile(bootstrap_ratio_lv1,95)
%pctl=2.5
m=0;sig=1;
pVal=(1+erf((abs(pctl)-m)/(sqrt(2)*sig)))/2;
pVal=(1-pVal)*2
negBSR=bootstrap_ratio_lv1(bootstrap_ratio_lv1<0);
pctl_neg=prctile(negBSR,95)
posBSR=bootstrap_ratio_lv1(bootstrap_ratio_lv1>0);
pctl_pos=prctile(posBSR,95)
threshBSR=zeros(size(test));
for i = 1:nRoi
    for j=1:nRoi
        if test(i,j) < 0 && test(i,j) < -(abs(pctl))
            threshBSR(i,j)=test(i,j);
            
        elseif test(i,j) > 0 && test(i,j) > abs(pctl)
            threshBSR(i,j)=test(i,j);
            
        end
    end
end

cbar=create_colourbar(bootstrap_ratio_lv1, abs(pctl), -abs(pctl));
cbar_raw=create_colourbar(bootstrap_ratio_lv1, 0, 0);
figure;imagesc(test); colormap(cbar_raw); colorbar
figure; imagesc(threshBSR);
title(['BSR thresholded at ' num2str(abs(pctl)) ' (p-value = ' num2str(pVal) ')'])
colormap(cbar)
colorbar
end

