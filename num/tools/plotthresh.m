function plotthresh( subject )

% PLOTTHRESH  Plot thresholds for all sessions
% 
% plotthresh( subject )

% 16-Feb-2016 -- created (RFM)

% make default behaviour to plot thresholds for all subjects

% get thresholds
dirname = sprintf('data/%s',subject);
d = dir( fullfile( dirname, sprintf('num_%s*.mat', subject ) ) );
for i = 1:numel(d)
    load( fullfile( dirname, d(i).name ), 'p' );
    thresh(i) = mean(p.thresh);
end

% plot thresholds
plot( thresh, 'ro-' );
axis([ 0 numel(thresh)+1 0 1.1*max(thresh) ]);
xlabel 'session number'
ylabel '75% threshold'
graphfont helvetica 18 bold

end
