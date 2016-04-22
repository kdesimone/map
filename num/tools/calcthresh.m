function thresh = calcthresh( fname, plotit )

% CALCTHRESH  Calculate a numerosity threshold
% 
% thresh = calcthresh( fname )

% 16-Feb-2016 -- created (RFM)

% set default arguments
if nargin<2, plotit = 0; end

% load data
load( fname, 'p' );

% make fit function
fitfn = @( x, mu, sigma ) 0.01 + 0.98*normcdf( x, mu, sigma );

% find thresholds in three conditions
for k = 1:3
    
    f = p.sourcek==k;
    chosealt = p.stimorder(f) ~= p.response(f);
    stimdiff = p.n2(f)-p.n1(f);
    errfn = @( p ) -sum(log( binopdf( chosealt, 1, fitfn( stimdiff, p(1), p(2) ) ) ));
    phat = fminsearch( errfn, [ 4 2 ] );
    thresh(k) = norminv(0.75)*phat(2);
    
    if plotit
        
        empfn = emppsymet( [ stimdiff chosealt ] );
        theta = fitpsymet( empfn, 'norm', [ 4 2 ], 0, 0.01 );
        figure(k);
        plotpsymet( empfn, 'norm', theta, [], 0.50, 0, 0.01 );
        
    end
    
end

% save thresholds
p.thresh = thresh;
save( fname, 'p' );

end
