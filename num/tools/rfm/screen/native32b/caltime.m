% caltime.m  See how a monitor's luminance changes over time

clear; clc;

% open window and photometer
screennum=2;
[screenxy,fps]=glmOpen(screennum);

% calculate patch position
patchsizeP=400;
drawRect=centrerect([ 0 0 screenxy ],patchsizeP*[ 0 0 1 1 ]);
winMid=floor(screenxy/2);

% clear buffers
glClearColor(0.5,0.5,0.5,1.0);
glClear; glmSwapBuffers;
glClear; glmSwapBuffers;

% aim photometer
glColor3ub(180,180,180);
glRectdv(drawRect(1:2),drawRect(3:4));
glColor3ub(0,0,0);
glBegin(GL.LINES); glVertex2d(drawRect(1),winMid(2)); glVertex2d(drawRect(3),winMid(2)); glEnd;
glBegin(GL.LINES); glVertex2d(winMid(1),drawRect(2)); glVertex2d(winMid(1),drawRect(4)); glEnd;
glWindowPos2d(50,50);
glmSetFont(22,1,30);
glmText('aim photometer.  press any key to continue.');
glmSwapBuffers;
glmGetChar('wait');

% clear screen
glClear;
glmSwapBuffers;

% open photometer
photOpen;

% loop until user quits
tic;
timelist = [];
lumlist = [];
i = 0;
while 1
    
    % get a measurement
    i = i + 1;
    lumlist(i) = photLum;
    timelist(i) = toc;
    feedbeep(1);
    
    % pause
    while toc < 30*i
        pause(1);
        
        % check for quit key
        k = glmGetChar('nowait');
        if k=='q', break; end
        
    end
    
    % check for quit key
    if k=='q', break; end
    
end

% close window and photometer
glmClose;
photClose;

% show time course
plot(timelist/60,lumlist,'ro');
set(gca,'XLim',[ 0 1.05*timelist(end)/60 ]);
set(gca,'YLim',[ 0 1.05*max(lumlist) ]);
xlabel 'time (minutes)'
ylabel 'luminance'
