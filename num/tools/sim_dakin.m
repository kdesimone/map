function r = sim_dakin( stim1, stim2 )

% SIM_DAKIN  Simulated numerosity observer who uses Dakin et al.'s model
% 
% r = sim_dakin( stim1, stim2 )

% 19-Feb-2016 -- created (RFM)

% set parameters
sigmalowP  = 16;   % low frequency filter
sigmahighP =  2;   % high frequency filter
noiseflag = 1;     % flag whether to add noise to decision variable

% find decision variable
df1 = dakfilt( stim1.im, sigmalowP, sigmahighP );
df2 = dakfilt( stim2.im, sigmalowP, sigmahighP );
[ ~, n12 ] = dakcomp( df1, df2, noiseflag );

% make response
r = 1 + (n12<1);

end


function df = dakfilt( im, sigmalowP, sigmahighP )

% DAKFILT  Dakin et al.'s density and numerosity filters
% 
% df = dakfilt( im, sigmalowP, sigmahighP )

% 29-Sep-2015 -- created (RFM)

% get image size (we assume im is square)
dim = size(im,1);

% make laplacians of gaussians
persistent lglow lghigh
if isempty(lglow) || lglow.sigmaP~=sigmalowP || lglow.dim~=dim
    lglow.sigmaP = sigmalowP;
    lglow.dim = dim;
    lglow.im = lapgauss( sigmalowP,  dim );
end
if isempty(lghigh) || lghigh.sigmaP~=sigmahighP || lghigh.dim~=dim
    lghigh.sigmaP = sigmahighP;
    lghigh.dim = dim;
    lghigh.im = lapgauss( sigmahighP,  dim );
end

% full-wave rectified filter responses to full-wave rectified images
% - why does this formula work for circular convolution?
im = abs( fftshift( im ) );
imlow  = abs( ifft2( fft2( im ) .* fft2( lglow.im  ) ) );
imhigh = abs( ifft2( fft2( im ) .* fft2( lghigh.im ) ) );

% summed responses
df.rlow  = sum(imlow(:));
df.rhigh = sum(imhigh(:));

% % show filtered images
% subplot(1,2,1); imagesc( imlow  ); axis image;
% subplot(1,2,2); imagesc( imhigh ); axis image;
% colormap gray; drawnow;

end

function im = lapgauss( sigmaP, dim )

% LAPGAUSS  Laplacian of Gaussian
%
% im = lapgauss( sigmaP, dim )

% make coordinate matrices
midn = floor(dim/2)+1;
xy = (1:dim) - midn;
[x,y] = meshgrid( xy, -xy );

% make laplacian of gaussian
im = - (1/(pi*sigmaP^4)) * ( 1 - (x.^2+y.^2)/(2*sigmaP^2) ) .* ...
       exp( -(x.^2+y.^2)/(2*sigmaP^2) );

end

function [ d12, n12 ] = dakcomp( df1, df2, noiseflag )

% DAKCOMP  Dakin et al.'s density and numerosity comparisons
%
% [ d12, n12 ] = dakcomp( df1, df2, noiseflag )

% 29-Sep-2015 -- created (RFM)

% set default arguments
if nargin<3
    noiseflag = 1;
end

% noise standard deviations; values from Dakin et al. (2011)
if noiseflag
    gamma_sigma = 0.1;
    gamma_s = 1.9;
else
    gamma_sigma = 0;
    gamma_s = 0;
end

% response ratios
n = 2.^normrnd(0,gamma_sigma,[ 1 2 ]);
c1 = n(1) * df1.rhigh/df1.rlow;
c2 = n(2) * df2.rhigh/df2.rlow;

% density comparison
d12 = c1/c2;

% numerosity comparison
n1 = 2^normrnd(0,gamma_sigma);
n2 = 2^normrnd(0,gamma_s);
n12 = ( ( n1*(df1.rlow/df2.rlow) )^n2 ) * d12;

end
