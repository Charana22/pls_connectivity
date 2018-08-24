function [ cbar_map ] = create_colourbar( bootstrap_ratio_lv1, thresh_pos, thresh_neg )
%% create_colourbar - create colormap similar to PLS result. Script based off fmri_result_ui.m & fmri_plot_brainlv.m from PLS
%  Inputs -
%          bootstrap_ratio_lv1 - BSR values for a single LV
%          thresh_pos - positive BSR threshold
%          thresh_neg - negative BSR threshold
% 
%   Output -
%          cbar_map - Colormap values          
bg_values = [1 1 1];
bg_brain_values = [0.54 0.54 0.54];
bg_cmap = ones(100,1)*bg_brain_values;
cmap = zeros(151,3);
jetmap = jet(64);
cmap(1:100,:) = bg_cmap;			% the brain regions
cmap(101:125,:) = jetmap([1:25],:);		% the negative blv values
cmap(126:150,:) = jetmap([36:60],:);		% the positive blv values
cmap(end,:) = bg_values;


min_blv=min(bootstrap_ratio_lv1);
max_blv=max(bootstrap_ratio_lv1);

cbar_size = 100;
cbar_map = ones(cbar_size,1) * bg_brain_values;
cbar_step = (max_blv - min_blv) / cbar_size;

%  prevent_num_lower_color_0
%
if 0 % (abs(min_blv) - thresh) < cbar_step & (abs(min_blv) - thresh) ~= 0
    cbar_size = ceil((max_blv - min_blv) / (abs(min_blv) - thresh));
    cbar_map = ones(cbar_size,1) * bg_brain_values;
    cbar_step = (max_blv - min_blv) / cbar_size;
end
if 0 % (abs(max_blv) - thresh) < cbar_step & (abs(max_blv) - thresh) ~= 0
    cbar_size = ceil((max_blv - min_blv) / (abs(max_blv) - thresh));
    cbar_map = ones(cbar_size,1) * bg_brain_values;
    cbar_step = (max_blv - min_blv) / cbar_size;
end

if cbar_step ~= 0
    %      num_lower_color = round((abs(min_blv) - thresh) / cbar_step);
    
    
    if max_blv > thresh_neg % -abs(thresh)
        num_lower_color = round((thresh_neg - min_blv) / cbar_step);
    else
        num_lower_color = round((max_blv - min_blv) / cbar_step);
    end
    
    
    if round(64 / 25 * num_lower_color) > 0
        jetmap = jet(round(64 / 25 * num_lower_color));
        cbar_map(1:num_lower_color,:) = jetmap(1:num_lower_color,:);
    end
    
    %      num_upper_color = round((max_blv - thresh) / cbar_step);
    
    
    if min_blv < thresh_pos % abs(thresh)
        num_upper_color = round((max_blv - thresh_pos) / cbar_step);
    else
        num_upper_color = round((max_blv - min_blv) / cbar_step);
    end
    
    
    if round(64 / 25 * num_upper_color) > 0
        jetmap = jet(round(64 / 25 * num_upper_color));
        first_jet_color = round((36 / 64) * size(jetmap,1));
        jet_range = [first_jet_color:first_jet_color+num_upper_color-1];
        cbar_map(end-num_upper_color+1:end,:) = jetmap(jet_range,:);
    end
end

end

