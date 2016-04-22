% CAL.M  Calibrate (native32b, mogl)

clear; clc;

% open window and photometer
[screenxy,fps]=glmOpen(1);

% calculate patch position
patchsizeP=400;
drawRect=centrerect([ 0 0 screenxy ],patchsizeP*[ 0 0 1 1 ]);
winMid=floor(screenxy/2);

% clear buffers
glClearColor(0.5,0.5,0.5,1.0);
glClear; glmSwapBuffers;
glClear; glmSwapBuffers;

% pause for measurement of patch size
glColor3ub(180,180,180);
glRectdv(drawRect(1:2),drawRect(3:4));
glColor3ub(0,0,0);
glBegin(GL.LINES); glVertex2d(drawRect(1),winMid(2)); glVertex2d(drawRect(3),winMid(2)); glEnd;
glBegin(GL.LINES); glVertex2d(winMid(1),drawRect(2)); glVertex2d(winMid(1),drawRect(4)); glEnd;
glWindowPos2d(50,50);
glmSetFont(22,1,30);
glmText('measure patch size and aim photometer.  press any key to continue.');
glmSwapBuffers;
glmGetChar('wait');
feedbeep(1);

% make list of greylevels
glist=[ 0:40:255 255 ];
glist=glist(randperm(numel(glist)));

% read luminances
photOpen;
lum=[];
for g=glist
    
    % draw patch
    glClear;
    glColor3ub(g,g,g);
    glRectdv(drawRect(1:2),drawRect(3:4));
    glmSwapBuffers;
    pause(0.5);
    
    % read luminance
    lum(end+1)=photLum;
    feedbeep(1);
    
end

% shut down
glmClose;
photClose;

% get patch size
patchsizeMM=input('enter the patch size in millimeters (<return> to skip):  ');
if isempty(patchsizeMM);
    pixelsize=NaN;
else
    pixelsize=(patchsizeMM/1000)/patchsizeP;
end

% fit gamma function
gammafn = @( g, p ) (p(1)*power((g-p(2))/(255-p(2)),p(3))).*(g>p(2)) + p(4);
errfn = @( p ) sum( ( gammafn(glist,p) - lum ).^2 ) + 1e6*any(p<0);
errmin = Inf;
phat = [];
for i = 1:20
    [ phati, erri ] = fminsearch(errfn,[ (max(lum)-min(lum))*(1+0.1*randn) 30*rand 2*(1+0.1*randn) min(lum)*(1+0.1*randn) ]);
    if erri<errmin
        errmin = erri;
        phat = phati;
    end
end
phat = roundplace(phat,0.001);

% show fit
clf;
plot(glist,lum,'ro'); hold on;
fplot(@(x)gammafn(x,phat),[ 0 255 ]); hold off;
axis([ -1 256 0 1.1*max(lum) ]);
fprintf(1,'fitted parameters:  k = %.2f, g0 = %.2f, gamma = %.2f, delta = %.2f\n',phat);

% make monitor structure
m.name='mlab02builtin';
m.mode='native32b';
m.caldate=datestr(now);
m.screennum=0;
m.screensize=screenxy;
m.pixelsize=pixelsize;
m.framerate=fps;
m.gamma=phat;

% save monitor structure
fname='~/Desktop/environ.txt';
putvartofile(fname,m,1);
fprintf('calibration results written to %s\n',fname);

% warn about unusual parameter values
if isnan(m.pixelsize)
    warning('pixel size recorded as NaN');
end
if m.framerate==0
    warning('screen rate recorded as 0 Hz');
end
