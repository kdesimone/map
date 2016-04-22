function phat = fitcirc( dspace, circ, gamma, linear )

% FITCIRC  Fit a circular decision curve to a decision space

% set default arguments
if nargin<2 || isempty(circ),  circ = 1;  end
if nargin<3 || isempty(gamma), gamma = 0; end
if nargin<4, linear = 0; end

% % scale linear coordinates so that they span an equal range
% if linear
%     range1 = dspace.dlist1(end) - dspace.dlist1(1);
%     range2 = dspace.dlist2(end) - dspace.dlist2(1);
%     k = range1/range2;
%     dspace.dlist2 = k*dspace.dlist2;
% end

% get coordinate matrices
[ d2, d1 ] = meshgrid( dspace.dlist2, dspace.dlist1 );

% find centre of gravity of sampled points
n = sum(dspace.nmat(:));
originx = sum(sum( d1.*dspace.nmat ))/n;
originy = sum(sum( d2.*dspace.nmat ))/n;
origin = [ originx originy ];

% get error function
if circ
    errfn = @( p ) -sum(sum( log( ...
        binopdf( dspace.kmat, dspace.nmat, circds( d1, d2, p(1), p(2), p(3), p(4), origin ) ) ...
        ) ));
else
    errfn = @( p ) -sum(sum( log( ...
        binopdf( dspace.kmat, dspace.nmat, circds( d1, d2, p(1), p(2), 0, p(3), origin ) ) ...
        ) ));
end

% get best fit
errmin = Inf;
for i = 1:20
    
    % get initial parameters
    thetai = 90*rand;
    dispi = -0.1 + 0.2*rand;
    ci = -0.1 + 0.2*rand;
%     if linear
%         sigmai = 10+10*rand;
%     else
        sigmai = 0.5+0.5*rand;
%     end
    % *** choose sigmai based on the actual range of the coordinates
    if circ
        pinit = [ thetai dispi ci sigmai ];
    else
        pinit = [ thetai dispi sigmai ];
    end
    
    % fit
    [ pstar, err ] = fminsearch( errfn, pinit );
    if err<errmin
        phat = pstar;
    end
    
end

% map theta to interval [ -180, 180 )
phat(1) = mod(phat(1)+180,360)-180;

% add curvature parameter if necessary
if ~circ
    phat = [ phat(1:2) 0 phat(3) ];
end

% add origin to fitted parameters
phat = [ phat origin ];

% % undo effect of coordinate rescaling
% if linear
%     theta2 = atan2d( k*sind(phat(1)), cosd(phat(1)) );
%     c = sqrt( cosd(phat(1))^2 + (k^2)*sind(phat(1))^2 );
%     phat = [ theta2 phat(2)/c phat(3)/c ];
% end

end
