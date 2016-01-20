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
p.screen_width = 50; % cm
p.xpixels = rect(3);
p.ypixels = rect(4);
p.xc = p.xpixels/2;
p.yc = p.ypixels/2;
p.ppd = pi*p.xpixels/atan(p.screen_width/p.viewing_distance/2.0)/360.0;
p.white = [255 255 255];
p.black = [0 0 0];
p.bg = (p.white + p.black) / 2;

% numerosity parameters
p.range = 0.30; % max +/- difference between intervals
p.ndots = 50; % int
p.density = 8 * p.ppd; % degrees, radius of disk
p.area = 0.05 * p.ppd; % degrees, radius of each dot
p.min_density = p.density - log(p.density * p.range);
p.max_density = p.density + log(p.density * p.range);
p.min_area = p.area - log(p.area * p.range);
p.max_area = p.area + log(p.area * p.range);
p.dispsize = ceil(p.max_density * 2); % degrees

% the reference interval
p.d = dotframe(p.ndots, p.area, p.density, p.dispsize);
p.d_rgba = repmat(p.d * p.white(1), [1 1 4]);
p.d_tex = Screen('MakeTexture', w, p.d_rgba);

% rect of display
[dx,dy] = size(p.d(:,:,1));
p.d_rect = [p.xc - dx/2, p.yc - dy/2, p.xc + dx/2, p.yc + dy/2];

% trials parameters
p.ntrials = 300*34;
p.cointoss = rand(p.ntrials,1); % cointoss to determine interval order
time.iti = [0.05,0.1]; % intertrial interval, seconds
time.iii = 0.05; % interinterval interval,
time.stim_time = 0.05;
p.interval_order = NaN(p.ntrials,2);
p.densities = NaN(p.ntrials,1);
p.areas = NaN(p.ntrials,1);

% behavioral
r.response = NaN(p.ntrials,1);
r.rtime = NaN(p.ntrials,1);
key(1) = KbName('a'); % s = less numerous
key(2) = KbName('s'); % d = more numerous

% define fixation point
dfp = @(w,c,s,xc,yc) Screen(w, 'FillRect', c, repmat([xc; yc],[2 3]) + [-1 -1 1 1]' * s);
fixation_point = @(n) dfp(w,[p.white' p.black' p.white'],[3 2 1], p.xc, p.yc);

% splash screen
Screen('FillRect', w, p.bg);
Screen('TextSize', w, 24);
txt = 'Please wait, generating stimuli....';
normBoundsRect = Screen('TextBounds', w, txt);
txtloc = [p.xc - normBoundsRect(3)/2, p.yc + normBoundsRect(4)/2];
Screen('DrawText', w, txt, txtloc(1), txtloc(2), p.white);
Screen('Flip', w);
Priority(MaxPriority(w));

% build textures
textures = zeros(2, p.ntrials);
for trial = 1:p.ntrials
    
    % random density & area
    density = p.min_density + (p.max_density-p.min_density).*rand(1,1);
    area = p.min_area + (p.max_area-p.min_area).*rand(1,1);
    
    % test dot array
    test_d = dotframe(p.ndots, area, density, p.dispsize);
    test_d = repmat(test_d * p.white(1), [1 1 4]);
    
    % reference dot array
    ref_d = dotframe(p.ndots, p.area, p.density, p.dispsize);
    ref_d = repmat(ref_d * p.white(1), [1 1 4]);
    
    % interval order
    itex_1 = 2-(p.cointoss(trial)>0.5);
    itex_2 = 3-itex_1;
    
    % make textures
    %textures(itex_1,trial) = Screen('MakeTexture', w, ref_d);
    %textures(itex_2,trial) = Screen('MakeTexture', w, test_d);
    
    % record trial info
    p.densities(trial) = density;
    p.areas(trial) = area;
    p.interval_order(trial,:) = [itex_1,itex_2];
    
end

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
    for trial = 1:p.ntrials
        
        % inter-trial break
        time.iti_start = GetSecs;
        iti = time.iti(1) + (time.iti(2)-time.iti(1)).*rand(1,1);
        while GetSecs - time.iti_start < iti
            do=0;
        end
        
        % new trial
        time.trial_start = GetSecs;
        
        % textures
        t(1) = textures(1,trial);
        t(2) = textures(2,trial);
        
        % Draw interval 1
        Screen('FillRect', w, p.bg, rect);
        Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, [1 1 1 1]);
        Screen('DrawTexture', w, t(itex_1), [], p.d_rect);
        fixation_point();
        [vbl, interval_1_onset] = Screen('Flip', w);
        
        % And wait
        while GetSecs - interval_1_onset < time.stim_time
            do=0;
        end
        
        % Clear interval 1
        Screen('FillRect', w, p.bg, rect);
        fixation_point();
        [vbl, interval_1_offset] = Screen('Flip', w);
        
        % Wait for some time
        while GetSecs - interval_1_offset < time.iii
            do=0;
        end
        
        % Draw interval 2
        Screen('FillRect', w, p.bg, rect);
        Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, [1 1 1 1]);
        Screen('DrawTexture', w, t(itex_2), [], p.d_rect);
        fixation_point();
        [vbl, interval_2_onset] = Screen('Flip', w);
        
        % And wait
        while GetSecs - interval_2_onset < time.stim_time
            do=0;
        end
        
        % Clear the stimulus
        Screen('FillRect', w, p.bg, rect);
        fixation_point();
        [vbl, interval_2_offset] = Screen('Flip', w);
        
        % Behavioral
        keydown = zeros(1,2);
        while(~xor(keydown(1), keydown(2)))  % wait for one (but not both) response keys to be pressed
            [keyisdown, secs, keycode] = KbCheck;
            for ik = 1:2
                keydown(ik) = keycode(key(ik));
            end
            
            WaitSecs(0.001);    % wait for 1 ms to avoid overloading CPU
        end
        
        % record response
        if keydown(1)
            p.response(trial) = 1;
        else
            p.response(trial) = 2;
        end
        
        % reaction time
        p.rtime(trial) = secs - interval_2_offset;
        
        % wait for depress
        while(keyisdown)
            [keyisdown, secs, keycode] = KbCheck;
            WaitSecs(0.001);
        end
        
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


