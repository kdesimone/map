% Data collection for constructing CI for
% numerosity judgments

clear all; clc

% get subject, block, and time now
p.subject = num2str(input('Enter subject number: '));
p.block = num2str(input('Enter block number: '));
p.tim=fix(clock);

% debug mode
if isempty(p.subject)
    p.subject = 'test';
    p.block = 'test';
    p.tim = [2016 1 18 01 02 03];
    Screen('Preference', 'SkipSyncTests', 1);
end

% set the random seed generator based on this
p.seed = sum(p.subject + p.block + sum(p.tim));
rng(p.seed);

% splash
HideCursor;
[w, rect] = Screen('OpenWindow', 0);

% display parameters
p.viewing_distance = 50; % cm
p.screen_width = 30; % cm
p.xpixels = rect(3);
p.ypixels = rect(4);
p.xc = p.xpixels/2;
p.yc = p.ypixels/2;
p.ppd = pi*p.xpixels/atan(p.screen_width/p.viewing_distance/2.0)/360.0;
p.white = [255 255 255];
p.black = [0 0 0];
p.bg = (p.white + p.black) / 2;
texrect = NaN(2,4);

% set some parameters
ntrials = 10;
p.dispsize = 10 * p.ppd;
p.dotradius = 0.25 * p.ppd;
p.radius = 5 * p.ppd;
nfix = 40;           % number of elements in fixed stimulus
afix = pi*4^2;       % area of fixed stimulus (deg^2)
ninit = 4;           % initialization; number of elements by which the
% other stimulus differs from the fixed stimulus,
% at the beginning of the experiment
arange = 2;          % factor by which we will randomly tweak the area of
% the other stimulus up or down

% initialize staircases
src = tsource( 'init', nfix, afix, ninit, arange );

% initialize trial storage
p.sources = cell(ntrials,1);

% behavioral
key(1) = KbName('a'); % s = less numerous
key(2) = KbName('s'); % d = more numerous

% timing
time.iti(1) = 0.5; % shorest iti
time.iti(2) = 1.0; % longest iti
time.stim_duration = 0.250; % stimulus exposure in seconds
time.iii = 0.250; % interinterval interval

% define fixation point
dfp = @(w,c,s,xc,yc) Screen(w, 'FillRect', c, repmat([xc; yc],[2 3]) + [-1 -1 1 1]' * s);
fixation_point = @(n) dfp(w,[p.white' p.black' p.white'],[3 2 1], p.xc, p.yc);

% Instructions
Screen('FillRect', w, p.bg);
Screen('TextSize', w, 24);
txt = sprintf('Judge which of two dot arrays are more numerous.\nA = 1st array more numerous.\nS = 2nd array more numerous.\nPress any key to start!');
txt_rect = Screen('TextBounds', w, txt);
txtloc = [p.xc - txt_rect(3)/2, p.yc - txt_rect(4)/2];
DrawFormattedText(w, txt, p.xc, p.xc, p.white);
fixation_point();
Screen('Flip', w);
Priority(MaxPriority(w));

% Wait
KbWait(-1);

% Clean screen and begin
Screen('FillRect', w, p.bg, rect);
fixation_point();
Screen('Flip', w);

try
    % timing
    time.block_start = GetSecs;
    
    % Main loop
    for trial = 1:ntrials
        
        % inter-trial break
        time.iti_start = GetSecs;
        iti = time.iti(1) + (time.iti(2)-time.iti(1)).*rand(1,1);
        
        % new trial
        time.trial_start = GetSecs;
        
        % get the trial source
        [ src, stim1, stim2 ] = tsource( 'get', src );
        
        % construct dot arrays
        stim1_df = dotframe(stim1.n, p.dotradius, p.radius, p.dispsize);
        stim2_df = dotframe(stim2.n, p.dotradius, p.radius, p.dispsize);
        
        % construct RGBA arrays
        stim1_rgba = repmat(stim1_df * p.white(1), [1 1 4]);
        stim2_rgba = repmat(stim2_df * p.white(1), [1 1 4]);
        
        % make textures
        t(1) = Screen('MakeTexture', w, stim1_rgba);
        t(2) = Screen('MakeTexture', w, stim2_rgba);
        
        % define texture rects
        [dx,dy] = size(stim1_df(:,:,1));
        texrect(1,:) = [p.xc - dx/2, p.yc - dy/2, p.xc + dx/2, p.yc + dy/2];
        [dx,dy] = size(stim1_df(:,:,1));
        texrect(2,:) = [p.xc - dx/2, p.yc - dy/2, p.xc + dx/2, p.yc + dy/2];
        
        % Wait for the rest of the iti
        while GetSecs - time.iti_start < iti
            do=0;
        end
        
        % Draw interval 1
        Screen('FillRect', w, p.bg, rect);
        Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, [1 1 1 1]);
        Screen('DrawTexture', w, t(1), [], texrect(1,:));
        fixation_point();
        [vbl, interval_1_onset] = Screen('Flip', w);
        
        % Wait for stimulus duration
        while GetSecs - interval_1_onset < time.stim_duration
            do=0;
        end
        
        % Clear interval 1
        Screen('FillRect', w, p.bg, rect);
        fixation_point();
        [vbl, interval_1_offset] = Screen('Flip', w);
        
        % Wait for the intertrial interval
        while GetSecs - interval_1_offset < time.iii
            do=0;
        end
        
        % Draw interval 2
        Screen('FillRect', w, p.bg, rect);
        Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, [1 1 1 1]);
        Screen('DrawTexture', w, t(2), [], texrect(1,:));
        fixation_point();
        [vbl, interval_2_onset] = Screen('Flip', w);
        
        % And wait
        while GetSecs - interval_2_onset < time.stim_duration
            do=0;
        end
        
        % Clear the stimulus
        Screen('FillRect', w, p.bg, rect);
        fixation_point();
        [vbl, interval_2_offset] = Screen('Flip', w);
        
        % Behavioral
        kd = zeros(1,2);
        while(~xor(kd(1), kd(2)))  % wait for one (but not both) response keys to be pressed
            [keyisdown, secs, keycode] = KbCheck;
            for ik = 1:2
                kd(ik) = keycode(key(ik));
            end
            
            WaitSecs(0.001); % wait for 1 ms to avoid overloading CPU
        end
        
        % get performance
        if kd(1) && stim1.n > stim2.n || kd(2) && stim1.n < stim2.n
            
            correct = 1;
        else
            correct = 0;
        end
        
        % reaction time
        p.rtime(trial) = secs - interval_2_offset;
        
        % wait for depress
        while(keyisdown)
            [keyisdown, secs, keycode] = KbCheck;
            WaitSecs(0.001);
        end
        
        % evaluate trial
        src = tsource( 'put', src, correct );
        
        % record trial
        p.sources{trial} = src;

        
    end
    
    Screen('CloseAll');
    ShowCursor;
    ListenChar;
    
catch
    Screen('CloseAll');
    ShowCursor;
    rethrow(lasterror);
    ListenChar;
end

% Write data to file
if ~strcmp(p.subject, 'test')
    filename = sprintf('numerosity_2IFC-%s-%s-%s', p.subject, p.block, datestr(p.tim,30));
    save(filename, 'p');  % save data
end


