% CALTEST_PTB.M  Test calibration (native32b, psychtoolbox)

clear; clc;

% initialize calibration routines
setconfig('init');

% open psychtoolbox window
screennum = 0;
Screen('Preference', 'SkipSyncTests', 2 );
Screen('Preference', 'SuppressAllWarnings', 1 );
[w, rect] = Screen('OpenWindow', screennum);
HideCursor;

% calculate patch position
patchsizeP = 400;
drawRect = CenterRect(patchsizeP*[ 0 0 1 1 ],rect);
winMid = floor(rect(3:4)/2);

% aim photometer
bggrey = 128;
fggrey = 180;
Screen('FillRect',w,bggrey);
Screen('FillRect',w,fggrey,drawRect);
Screen('FillRect',w,0,[ drawRect(1) winMid(2) drawRect(3) winMid(2)+1 ]);
Screen('FillRect',w,0,[ winMid(1) drawRect(2) winMid(1)+1 drawRect(4) ]);
Screen('Flip',w);
KbWait;
feedbeep(1);

% make list of luminances
lumlist = linspace(rgb2lum(0),rgb2lum(255),10);
lumlist = lumlist(randperm(numel(lumlist)));

% show and measure
photOpen;
mlumlist=[];
for lum=lumlist
    
    % draw patch
    g = lum2rgb(lum);
    Screen('FillRect',w,bggrey);
    Screen('FillRect',w,g,drawRect);
    Screen('Flip',w);
    pause(0.5);
    
    % read luminance
    mlumlist(end+1)=photLum;
    feedbeep(1);
    
end

% shut down
Screen('CloseAll');
photClose;

% plot actual vs. expected luminances
plot(lumlist,mlumlist,'ro'); hold on;
mx = 1.1*max(max(lumlist),max(mlumlist));
plot([ 0 mx ],[ 0 mx ],'r:'); hold off;
axis([ 0 mx 0 mx ]);
xlabel 'requested luminance'
ylabel 'measured luminance'
