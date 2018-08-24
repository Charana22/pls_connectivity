function [ datamat ] = stackPLSdatamat( subjects, conditions, inpath, n,dirName,flag )
%% stackPLSdatamat( subjects, conditions, inpath, n, dirName ) - Stack datamat for PLS 
%  subjects - MxN cell containing list of groups of  subjects
%  conditions - 1xN containing list of conditions
%  inpath - string containg path to subject folders
%  n - number of ROIs (nodes)
%  dirName - directory name in the subjects Connectivity folder containg
%  the ROIs
%  flag - set this to 1 if you for Z values instead of R values to be
%  stacked up.

if nargin == 5
    flag =0;
end

if flag ~=1 && flag ~=0
    error('flag can only be either 1 or 0');
end


% subjects = {'103','106'};

ncond = numel(conditions);
% nsubj = numel(subjects);
ngroup =numel(subjects);

% order=[1	2	3	14	26	27	28	29	30	31	32	33	34	44	45	46	47	48	49	50	51	4	5	15	11	12	13	23	24	43	64	25	9	20	56	57	58	59	19	38	39	60	7	8	18	35	36	37	53	54	55	6	16	17	52	10	21	40	41	42	61	62	63	22];
% n = 3;                      % no. of nodes
mask = triu(ones(n),1)>0;   % upper triangle
k = sum(mask(:));           % no. of edges

datamat = cell(1,ngroup);                % one cell per group
%TODO: Fix the subject path part

for gg =1:ngroup
    nsubj=numel(subjects{gg});
    datamat{gg} = zeros(ncond*nsubj,k);  % (conditions x subjects) x edges
    
    for cc = 1:ncond
        for ss = 1:nsubj
           
            fname = fullfile(inpath, num2str(subjects{gg}{ss}), 'Nifti','Connectivity', dirName,['subj' num2str(subjects{gg}{ss}) '_' conditions{cc} '.mat']);
            
            load(fname);
            
            Z = 0.5*log((1+R)./(1-R));
            rowidx = (cc-1)*nsubj + ss;
            if flag == 0
                datamat{gg}(rowidx,:) = R(mask); % stack subjects-within-conditions
            else
                datamat{gg}(rowidx,:) = Z(mask); % stack Z map instead of R
            end
        end
    end
end

end

