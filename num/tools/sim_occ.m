function r = sim_occ(stim1, stim2)

% point images
e1 = single(bwulterode(logical(stim1.im)));
e2 = single(bwulterode(logical(stim2.im)));

% coordinates
[xx,yy] = meshgrid(0:0.01:1,0:0.01:1);

% params
x = 0.5;
y = 0.5;
sigma = 0.2;

% filter
G = exp(-((xx-x).^2/2/sigma^2 + (yy-y).^2/2/sigma^2));

% convolution
c1 = conv2(e1,G);
c2 = conv2(e2,G);

% clip
c1(c1>1) = 1;
c2(c2>1) = 1;

% issue response
if sum(c1(:)) > sum(c2(:))
    r = 1;
else
    r = 2;
end

