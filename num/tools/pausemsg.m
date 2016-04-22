function pausemsg( w, rect, p, txt1, txt2 )

if nargin<5
    txt2 = ' ';
end

% print pause message
Screen('TextSize', w, 48);
txtRect1 = CenterRect( Screen('TextBounds', w, txt1), rect );
txtRect2 = CenterRect( Screen('TextBounds', w, txt2), rect );
h = max( txtRect1(4)-txtRect1(2), txtRect2(4)-txtRect2(2) );
txtRect1([ 2 4 ]) = txtRect1([ 2 4 ]) - 0.9*h;
txtRect2([ 2 4 ]) = txtRect2([ 2 4 ]) + 0.9*h;
Screen('FillRect', w, p.bgrgb);
Screen('DrawText',w,txt1,txtRect1(1),txtRect1(2),p.fgrgb,p.bgrgb);
Screen('DrawText',w,txt2,txtRect2(1),txtRect2(2),p.fgrgb,p.bgrgb);
Screen('Flip', w);

% wait for keypress
while 1
    [~,~,kcode] = KbCheck;
    kname = KbName(kcode);
    if ischar(kname) && strcmp(kname,'space')
        break
    end
end

% clear screen
Screen('FillRect', w, p.bgrgb);
fixpt(w,p);
Screen('Flip', w);

end
