function r = sim_num( stim1, stim2, sigma, criterion )

% SIM_NUM  Simulated numerosity observer who uses a noisy estimate of
%          true numerosity
% 
% r = sim_num( stim1, stim2, sigma, criterion )

% 19-Feb-2016 -- created (RFM)

% set default arguments
if nargin<3, sigma = 6; end
if nargin<4, criterion = 0; end

% find decision variable
dvar = stim2.n - stim1.n + sigma*randn;

% make response
r = 1 + (dvar>criterion);

end
