function s = timeseed

% TIMESEED  Get a random number generator seed from GetSecs
% 
% s = timeseed

% 09-Feb-2016 -- created (RFM)

s = GetSecs;
s = round(1e9*(s-floor(s)));

end
