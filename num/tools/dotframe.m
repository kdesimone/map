function [ im, mdots ] = dotframe( ndots, dotradiusP, radiusP, dispsizeP, pwhite )

% DOTFRAME  Make an image of many dots
%
% [ im, mdots ] = dotframe( ndots, dotradiusP, radiusP, dispsizeP, pwhite )
% 
%   ndots is the number of dots
%   dotradiusP is the radius of each dot in pixels
%   radiusP is the radius of the circle in which the dots are located, in pixels
%   framesizeP is the size of the whole image matrix
% 
%   im is the image
%   mdots is the actual number of dots in the generated image; may be less
%     than ndots if radiusP is too small or ndots is too large, since the
%     routine makes sure no two dots overlap

% 19-Mar-2008 -- created (RFM)
% 29-Sep-2015 -- dot image size reduced; preallocated dotij (RFM)

% set default arguments
if nargin<5, pwhite = 1; end

% check that stimulus will fit in image matrix
if (2*radiusP+3)>dispsizeP
    error('radiusP = %.2f will not fit in dispsizeP = %.2f\n',radiusP,dispsizeP);
end

% initialize image
im = zeros(dispsizeP);
midn = floor(dispsizeP/2)+1;

% make dot
deltaP = ceil(dotradiusP);
dot = circ2daa(dotradiusP,1,2*deltaP+1);
% imwrite(dot,'dot.tif');

% add dots
tryi = 0;              % number of attempts to find a new dot position
mdots = 0;             % number of dots placed
dotij = NaN(ndots,2);  % centres of dots placed
while 1

    % get a new dot position, uniformly sampled from within a circle
    % of radius dotradiusP
    theta = 360*rand;
    r = (radiusP-dotradiusP)*sqrt(rand);
    di = round(-sind(theta)*r);
    dj = round( cosd(theta)*r);

    % find distance to existing dots
    if mdots>0
        mindist = min(sqrt(sum((dotij-repmat([ di dj ],[ ndots 1 ])).^2,2)));
    else
        mindist = Inf;
    end

    % if not too close to existing dots, add dot to image
    if mindist>3*dotradiusP
        % *** 4
        
        % choose white or black dot
        if rand<pwhite
            thisdot = dot;
        else
            thisdot = -dot;
        end
        
        % add dot to image
        im(midn+di-deltaP:midn+di+deltaP,midn+dj-deltaP:midn+dj+deltaP) = im(midn+di-deltaP:midn+di+deltaP,midn+dj-deltaP:midn+dj+deltaP) + thisdot;
        
        % record dot
        mdots = mdots+1;
        dotij(mdots,:) = [ di dj ];
        
        % if done, then quit
        if mdots==ndots
            break
        end
        
    end

    % quit after too many tries
    tryi = tryi+1;
    if tryi>=10*ndots
        warning('unable to create required number of dots:  ndots=%.0f, dotradiusP=%.0f, radiusP=%.0f, dispsizeP=%.0f; created %.0f dots after %.0f tries',ndots,dotradiusP,radiusP,dispsizeP,mdots,tryi);
        break
    end

end

% % show radius
% xylist = (1:dispsizeP) - (floor(dispsizeP/2)+1);
% [x,y] = meshgrid( xylist, -xylist );
% r = sqrt( x.^2 + y.^2 );
% im( abs(r-radiusP)<0.5 ) = 1;
% 
% % show border
% im(:,[ 1 end ]) = 1;
% im([ 1 end ],:) = 1;

return


function mat = circ2daa( radiusP, ramplen, n, centreij )

% CIRCD2DAA  Make an anti-aliased circle matrix
%
% mat = circ2daa( radiusP, ramplen, n, centreij )

% 18-Oct-99 -- created;  adapted from kanind.m (RFM)

% set default parameters
if nargin<4, centreij = (floor(n/2)+1)*[ 1 1 ]; end

% initialize image and get coordinate matrices
mat=zeros(n);
r=matrt([ n n ],centreij);

% draw anti-aliased circle
mat(r<=(radiusP-(ramplen/2)))=1;
if ramplen>0
	f=find((r>(radiusP-(ramplen/2)))&(r<=(radiusP+(ramplen/2))));
	mat(f)=0.5-0.5*(1/(ramplen/2))*(r(f)-radiusP);
end

return


function [ r, t ] = matrt( dim, centreij )

% MATRT  Make polar coordinate matrices
%
% [ r, t ] = matrt( dim, centreij )

% 18-Oct-1999 -- created (RFM)

% set default arguments
if nargin<2, centreij = []; end

% make xy coordinate matrices
[x,y] = matxy(dim,centreij);

% convert to polar coordinates
r = sqrt(x.^2+y.^2);
if nargout>=2
	t = atan2(y,x);
end

return


function [ x, y ] = matxy( dim, centreij )

% MATXY  Make x-y coordinate matrices
%
% [ x, y ] = matxy( dim, centreij )

% 18-Oct-1999 -- created (RFM)

% set default arguments
if nargin<2, centreij = floor(dim/2)+1; end

% check dim argument
if numel(dim)==1, dim = [ dim dim ]; end

% make coordinate matrices
xv = (1:dim(2)) - centreij(2);
yv = (1:dim(1)) - centreij(1);
[x,y] = meshgrid(xv,-yv);

return
