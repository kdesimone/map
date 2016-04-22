function dspace = calcdspace( dvar1, dvar2, response )

% CALCDSPACE  Calculate a proxy decision space
% 
%     usage:  dspace = calcdspace( dvar1, dvar2, response )
% 
%     input arguments
%         'dvar1' is an n x 1 matrix of proxy decision variables for stimulus interval 1
%         'dvar2' is an n x 1 matrix of proxy decision variables for stimulus interval 2
%         'response' is an n x 1 matrix of 1's and 2's that encode the observer's responses:  1 = judged white disk first, 2 = judged black disk first
% 
%     return argument
%         'dspace' is a struct with the following fields
%             'dspace.dlist1' is an 1 x n list of evenly spaced values of proxy decision variable 1
%             'dspace.dlist2' is an 1 x n list of evenly spaced values of proxy decision variable 2
%             'dspace.pmat'   is an n x n matrix; element (i,j) is the proportion of trials on which the observer gave response 2 when 'dvar1' was in a small bin centred on dspace.dlist(i), and 'dvar2' was in a small bin centred on dspace.dlist(j)
%             'dspace.kmat'   is an n x n matrix; element (i,j) is the number     of trials on which the observer gave response 2 when 'dvar1' was in a small bin centred on dspace.dlist(i), and 'dvar2' was in a small bin centred on dspace.dlist(j)
%             'dspace.nmat'   is an n x n matrix; element (i,j) is the number     of trials on which 'dvar1' was in a small bin centred on dspace.dlist(i), and 'dvar2' was in a small bin centred on dspace.dlist(j)

% set number of bins into which we divide the proxy decision variables
nbin = 25;

% find range of proxy decision variables

qmin1 = quantile( dvar1, 0.01 );        % find quantile 0.01
qmax1 = quantile( dvar1, 0.99 );        % find quantile 0.99
qmean1 = (qmin1+qmax1)/2;               % find the middle of the range of proxy decision variables
qmin1 = qmean1 + 1.25*(qmin1-qmean1);   % choose lowest value of proxy decision variable to consider
qmax1 = qmean1 + 1.25*(qmax1-qmean1);   % choose highest value of proxy decision variable to consider

qmin2 = quantile( dvar2, 0.01 );        % find quantile 0.01
qmax2 = quantile( dvar2, 0.99 );        % find quantile 0.99
qmean2 = (qmin2+qmax2)/2;               % find the middle of the range of proxy decision variables
qmin2 = qmean2 + 1.25*(qmin2-qmean2);   % choose lowest value of proxy decision variable to consider
qmax2 = qmean2 + 1.25*(qmax2-qmean2);   % choose highest value of proxy decision variable to consider

% make bin boundaries and centres

step1 = (qmax1-qmin1)/nbin;            % choose step size between bins
dbins1 = qmin1:step1:qmax1;            % bin boundaries
dlist1 = dbins1(1:end-1)+(step1/2);    % bin centres

step2 = (qmax2-qmin2)/nbin;            % choose step size between bins
dbins2 = qmin2:step2:qmax2;            % bin boundaries
dlist2 = dbins2(1:end-1)+(step2/2);    % bin centres

% initialize matrices
kmat = NaN(nbin);                   % number of trials in each bin where observer gave response 2
nmat = NaN(nbin);                   % number of trials in each bin

% find response counts and trial counts in each bin
for i = 1:numel(dbins1)-1
    for j = 1:numel(dbins2)-1
        k = (dvar1>=dbins1(i)) & (dvar1<dbins1(i+1)) & (dvar2>=dbins2(j)) & (dvar2<dbins2(j+1));
        kmat(i,j) = sum(response(k)==2);  % count trials where observer gave response 2
        nmat(i,j) = sum(k);               % count trials
    end
end

% proportion of trials in each bin where observer gave response 2
pmat = kmat./nmat;

% assemble return argument
dspace.dlist1 = dlist1;   % bin centres
dspace.dlist2 = dlist2;   % bin centres
dspace.pmat = pmat;     % proportion of trials where observer gave response 2
dspace.kmat = kmat;     % number of trials where observer gave response 2
dspace.nmat = nmat;     % number of trials

return
