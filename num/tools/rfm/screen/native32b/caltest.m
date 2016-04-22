% CALTEST.M  Test calibration (native32b, mogl)

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
% glmSetFont(22,1,30);
glmText('aim photometer.  press any key to continue.');
glmSwapBuffers;
glmGetChar('wait');
feedbeep(1);

% make list of luminances
lumlist = linspace(rgb2lum(0),rgb2lum(255),10);
lumlist = lumlist(randperm(numel(lumlist)));

% show and measure
photOpen;
mlumlist=[];
for lum=lumlist
    
    % draw patch
    glClear;
    g = lum2rgb(lum);
    glColor3ub(g,g,g);
    glRectdv(drawRect(1:2),drawRect(3:4));
    glmSwapBuffers;
    pause(0.5);
    
    % read luminance
    mlumlist(end+1)=photLum;
    feedbeep(1);
    
end

% shut down
glmClose;
photClose;

% plot actual vs. expected luminances
plot(lumlist,mlumlist,'ro'); hold on;
mx = 1.1*max(max(lumlist),max(mlumlist));
plot([ 0 mx ],[ 0 mx ],'r:'); hold off;
axis([ 0 mx 0 mx ]);
xlabel 'requested luminance'
ylabel 'measured luminance'
