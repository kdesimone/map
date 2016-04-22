function p = circds( d1, d2, theta, disp, c, sigma, origin, gamma )

% CIRCDS  Decision space with circular decision curve
% 
% p = circds( d1, d2, origin, disp, theta, c, sigma, gamma )

% 26-Feb-2016 -- created (RFM)

% set default arguments
if nargin<8, gamma = 0; end

% get distance from decision curve
a = origin + disp*[ cosd(45) sind(45) ];
if abs(c)<1e-6
    % straight line
    d = cosd(theta)*(d1-a(1)) + sind(theta)*(d2-a(2));
else
    % circular curve
    r = 1/abs(c);
    b = a + sign(c)*r*[ cosd(theta+180) sind(theta+180) ];
    d = sign(c)*( sqrt( (d1-b(1)).^2 + (d2-b(2)).^2 ) - r );
end

% get decision space
p = max(min( normcdf( d, 0, sigma ), 1-gamma),gamma);

end
