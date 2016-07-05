function numa( subject, simfn )

% NUMA  Numerosity decision space adaptation experiment
%
% numa( subject, simfn )

% 26-Jun-2016 -- created; adapted from num.m (RFM)

% set default arguments
if nargin<1, subject = 'test'; end
if nargin<2, simfn = []; end

% set brightness
unix(sprintf('/usr/local/bin/brightness %.4f',1));

% add tools folder
addpath(fullfile(pwd,'tools'));

% seed rng
rng(timeseed);

% see whether we're simulating
sim = isa(simfn,'function_handle');

% record subject and time
p.subject = subject;
p.time = fix(clock);

% flag that this is the adaptation experiment
p.adapt = 1;

% set parameters
p.bglumC = 50;               % background luminance (cd/m^2)
p.fglumC = 100;              % foreground luminance (cd/m^2)
p.viewing_distanceM = 0.92;  % viewing distance (m)

p.ntrials = 500;             % number of trials in a session

p.nbase = 40;                % number of elements in fixed stimulus
p.ninit = 9;                 % initial numerosity increment/decrement in staircase

p.dotcst = 0.90;             % dot Weber contrast
p.dotradiusD = 0.07;         % dot radius (deg)
p.pwhite = 1;                % proportion of white dots

p.rbase = 3;                 % radius of fixed stimulus (deg)
p.abase = pi*p.rbase^2;      % area of fixed stimulus (deg^2)
p.arange = 2;                % area range
p.dispsizeD = 14;            % full stimulus matrix size (deg)

p.prestimS = 0.5;            % pre-stimulus interval (seconds)
p.stimdurS = 0.5;            % stimulus duration (seconds)
p.isiS = 0.5;                % interstimulus interval (seconds)
p.feedback = 0;              % auditory feedback

p.ecc = 4;                   % dva, locations left and right of fixation

p.adapt_dur = 0.9;           % seconds, time the adaptor is on
p.adapt_radius = p.ecc;      % dva, size of the adapting dot array


% open psychtoolbox window
Screen('Preference', 'SkipSyncTests', 2 );
Screen('Preference', 'SuppressAllWarnings', 1 );
[w, rect] = Screen('OpenWindow', 0);
HideCursor;
ListenChar(2);

% initialize calibration routines
setconfig('init');

% record display parameters
p.screen_widthM = Screen('DisplaySize',w)/1000;
p.xpixels = rect(3);
p.ypixels = rect(4);
p.xc = p.xpixels/2;
p.yc = p.ypixels/2;
p.ppd = 1/atan2d( p.screen_widthM/p.xpixels, p.viewing_distanceM );
p.fps = sec2frame(1);

% set left and right locations
p.xc_L = p.xc - p.ecc * p.ppd;
p.xc_R = p.xc + p.ecc * p.ppd;

% convert to machine units
p.bgrgb = lum2rgb( p.bglumC );
p.fgrgb = lum2rgb( p.fglumC );
p.dispsizeP  = ceil( p.dispsizeD * p.ppd );
p.dotradiusP = p.dotradiusD * p.ppd;
hframe = frame2sec(1)/2;

% find stimulus position
drawRect = centrerect(rect,[ 0 0 p.dispsizeP p.dispsizeP ]);

% make adaptor dot frame
[ adapt_df, adapt_mdots ] = dotframe(400, p.dotradiusP, p.adapt_radius * p.ppd, p.dispsizeP, p.pwhite );
adapt_df = lum2rgb( p.bglumC*( 1 + p.dotcst*adapt_df ) );

% make adaptor texture
atx = Screen('MakeTexture', w, adapt_df);
arect = Screen('Rect', atx);
arect = CenterRectOnPointd(arect, p.xc_L, p.yc);

% initialize staircases
src{1} = tsource( 'init', p.nbase, p.abase, p.ninit, p.arange );  % adaptation
src{2} = tsource( 'init', p.nbase, p.abase, p.ninit, p.arange );  % control

% initialize trial-by-trial data
init = NaN(p.ntrials,1);
p.start     = init;
p.sourcek   = init;
p.n1        = init;
p.n2        = init;
p.n1star    = init;
p.n2star    = init;
p.radius1P  = init;
p.radius2P  = init;
p.stimorder = init;
p.hasmore   = init;
p.rngseed   = init;
p.valid     = init;
p.stimdur1  = init;
p.stimdur2  = init;
p.response  = init;
p.correct   = init;
p.rt        = init;

% choose trial source order (NaN's indicate repeated trials)
p.sourcek = repmat([ 1 2 ]',[ ceil((p.ntrials-50)/2) 1 ]);
p.sourcek = p.sourcek(randperm(p.ntrials-50));
p.sourcek = [ p.sourcek(1:150) ; NaN(50,1) ; p.sourcek(151:end) ];

% pause before beginning
if ~sim
    %    feedbeep(1);
    pausemsg( w, rect, p, 'press the spacebar to begin' );
    pause(1);
end

try
    
    % Main loop
    for t = 1:p.ntrials
        
        % pause for a break every 100 trials
        if t>1 && mod(t,100)==1 && ~sim
            pause(0.5);
            pausemsg( w, rect, p, 'feel free to take a break', 'press the spacebar to continue' );
            pause(1);
        end
        
        % record trial start time
        p.start(t) = GetSecs;
        
        % get stimulus parameters
        reptrial = isnan(p.sourcek(t));
        if reptrial
            % repeated trial
            tm = t - 50;
            p.n1(t)        = p.n1(tm);
            p.n2(t)        = p.n2(tm);
            p.radius1P(t)  = p.radius1P(tm);
            p.radius2P(t)  = p.radius2P(tm);
            p.stimorder(t) = p.stimorder(tm);
            p.rngseed(t)   = p.rngseed(tm);
        else
            
            % choose a trial source and get stimulus parameters
            [ src{p.sourcek(t)}, stim1, stim2 ] = tsource( 'get', src{p.sourcek(t)} );
            
            % record stimulus properties
            p.n1(t) = stim1.n;
            p.n2(t) = stim2.n;
            p.radius1P(t) = p.ppd * sqrt(stim1.area/pi);
            p.radius2P(t) = p.ppd * sqrt(stim2.area/pi);
            
            % choose a random stimulus order; 1 = stim1 then stim2; 2 = stim2 then stim1
            p.stimorder(t) = 1 + (rand<0.5);
            
            % get rng seed
            p.rngseed(t) = timeseed;
            
        end
        
        % seed rng's
        rng(p.rngseed(t));
        
        % make stimulus images
        [ stim1_df, mdots1 ] = dotframe(p.n1(t), p.dotradiusP, p.radius1P(t), p.dispsizeP, p.pwhite );
        [ stim2_df, mdots2 ] = dotframe(p.n2(t), p.dotradiusP, p.radius2P(t), p.dispsizeP, p.pwhite );
        
        % record actual number of dots
        p.n1star(t) = mdots1;
        p.n2star(t) = mdots2;
        p.valid(t) = (p.n1star(t)==p.n1(t)) & (p.n2star(t)==p.n2(t));
        
        % see which interval has more dots
        if p.stimorder(t)==1
            p.hasmore(t) = 1 + (p.n2star(t)>p.n1star(t));
        else
            p.hasmore(t) = 1 + (p.n1star(t)>p.n2star(t));
        end
        
        % show stimuli and get response
        if ~sim
            
            % convert to rgb
            stim1_df = lum2rgb( p.bglumC*( 1 + p.dotcst*stim1_df ) );
            stim2_df = lum2rgb( p.bglumC*( 1 + p.dotcst*stim2_df ) );
            
            % make textures
            tx(1) = Screen('MakeTexture', w, stim1_df);
            tx(2) = Screen('MakeTexture', w, stim2_df);
            
            % wait for the rest of the prestimulus interval
            while GetSecs - p.start(t) < p.prestimS - hframe
                pause(0.001);
            end
            
            % Adapt or Control?
            if p.sourcek(t) == 2
                % Draw adaptor
                Screen('FillRect', w, p.bgrgb);
                Screen('DrawTexture', w, atx, [], arect);
                fixpt(w,p);
                [~, adaptime] = Screen('Flip', w);
            else
                % Draw blank
                Screen('FillRect', w, p.bgrgb);
                fixpt(w,p);
                [~, adaptime] = Screen('Flip', w);
            end

            % Wait for adaptation period
            while GetSecs - adaptime < p.adapt_dur
                adapting=1;
            end
                        
            % Draw left stimulus
            Screen('FillRect', w, p.bgrgb);
            if p.stimorder(t)==1
                txrect = Screen('Rect',tx(1));
                left_rect = CenterRectOnPointd(txrect,p.xc_L,p.yc);
                Screen('DrawTexture', w, tx(1), [], left_rect);
            else
                txrect = Screen('Rect',tx(2));
                left_rect = CenterRectOnPointd(txrect,p.xc_L,p.yc);
                Screen('DrawTexture', w, tx(2), [], left_rect);
            end
                        
            % Fix and draw
            fixpt(w,p);
            [~,fliptime1] = Screen('Flip', w);
            
            % Wait for stimulus duration
            while GetSecs - fliptime1 < p.stimdurS - hframe
                pause(0.001);
            end
            
            % Clear stimulus 1
            Screen('FillRect', w, p.bgrgb);
            fixpt(w,p);
            [~,fliptime2] = Screen('Flip', w);
            p.stimdur1(t) = fliptime2-fliptime1;
            
            % Wait for the intertrial interval
            while GetSecs - fliptime2 < p.isiS - hframe
                pause(0.001);
            end
            
            % Draw stimulus 2
            Screen('FillRect', w, p.bgrgb);
            if p.stimorder(t)==1
                txrect = Screen('Rect',tx(2));
                right_rect = CenterRectOnPointd(txrect,p.xc_R,p.yc);
                Screen('DrawTexture', w, tx(2), [], right_rect);
            else
                txrect = Screen('Rect',tx(1));
                right_rect = CenterRectOnPointd(txrect,p.xc_R,p.yc);
                Screen('DrawTexture', w, tx(1), [], right_rect);
            end
            
            % Fix and draw
            fixpt(w,p);
            [~,fliptime3] = Screen('Flip', w);
            
            % And wait
            while GetSecs - fliptime3 < p.stimdurS - hframe
                pause(0.001);
            end
            
            % Clear stimulus 2
            Screen('FillRect', w, p.bgrgb);
            fixpt(w,p);
            [~,fliptime4] = Screen('Flip', w);
            p.stimdur2(t) = fliptime4-fliptime3;
            
            % close textures
            Screen('Close',tx(1));
            Screen('Close',tx(2));
                        
            % get response
            while 1
                [~,ktime,kcode] = KbCheck;
                kname = KbName(kcode);
                if ischar(kname)
                    switch kname
                        case { '1', 'q' },  p.response(t) = 1; break;
                        case { '2', 'w' },  p.response(t) = 2; break
                        case '0)', p.response(t) = NaN; break;
                    end
                end
            end
            
            keyboard
            
            % check for quit key
            if isnan(p.response(t))
                break
            end
            
            % see whether response was correct, and record reaction time
            p.correct(t) = ( p.response(t) == p.hasmore(t) );
            p.rt(t) = ktime - fliptime4;
            
            % give feedback
            if p.feedback
                feedbeep( p.correct(t) );
            end
            
        else
            
            % assemble stimulus information
            stim1.n = p.n1star(t);
            stim2.n = p.n2star(t);
            stim1.radiusP = p.radius1P(t);
            stim2.radiusP = p.radius2P(t);
            stim1.im = stim1_df;
            stim2.im = stim2_df;
            
            % tag reference stimulus
            stim1.ref = 1;
            stim2.ref = 0;
            
            % get a simulated response
            if p.stimorder(t)==1
                p.response(t) = simfn( stim1, stim2 );
            else
                p.response(t) = simfn( stim2, stim1 );
            end
            p.correct(t) = ( p.response(t) == p.hasmore(t) );
            
            % set unused values
            p.stimdur1(t) = 0;
            p.stimdur2(t) = 0;
            p.rt(t) = 0;
            
            % show progress
            Screen('FillRect',w,p.bgrgb);
            Screen('TextSize', w,24);
            Screen('DrawText',w,sprintf('%3.0f',t),10,10,p.fgrgb,p.bgrgb);
            Screen('Flip',w,0,1,2);
            
        end
        
        % report result to trial source
        if ~reptrial
            src{p.sourcek(t)} = tsource( 'put', src{p.sourcek(t)}, p.correct(t) );
        end
        
    end
    
catch e
    Screen('CloseAll');
    ShowCursor;
    ListenChar;
    rethrow(e);
end

% save data
dirname = sprintf('./data/%s',p.subject);
if ~exist(dirname,'dir')
    mkdir(dirname);
end
filename = fullfile( dirname, sprintf('num_%s_%s', p.subject, datestr(p.time,30)) );
save(filename, 'p');

% pause before ending
if ~sim && ~isnan(p.response(t))
    pause(1);
    nicebeep('2a',500,0.5,1);
    pausemsg( w, rect, p, 'session finished', 'press the spacebar to exit' );
end

% close psychtoolbox window
Screen('CloseAll');
ShowCursor;
ListenChar;

% calculate threshold
calcthresh( filename );

% plot thresholds for all sessions
if ~isnan(p.response(t))
    clf;
    plotthresh( subject );
    if ~sim
        pause(5);
    end
    close;
end

end
