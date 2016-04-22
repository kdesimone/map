% CALNATIVE32B.M

% open window and photometer
[winID,winRect]=screen(0,'OpenWindow',128,[],32);
drawRect=centrerect(winRect,[ 0 0 400 400 ]);
ovalRect=centrerect(winRect,[ 0 0 200 200 ]);

% % pause for measurement of pixel size
% screen(winID,'FillRect',0,drawRect);
% getchar;

% make list of greylevels
glist=[ 0:40:255 255 ];
glist=glist(randperm(numel(glist)));

% draw patch and circle so user can aim photmeter
screen(winID,'FillRect',200,drawRect);
screen(winID,'FrameOval',0,ovalRect);

% read luminances
photopen;
lum=[];
for g=glist
    screen(winID,'FillRect',g,drawRect);
    screen(winID,'FrameOval',0,ovalRect);
    pause(0.5);
    lum(end+1)=photlum;
    %lum(end+1)=112*power((g-10)/(255-10),2.5)+10;
end

% shut down
screen('CloseAll');
photclose;

% fit gamma function
gammafn = @( g, p ) (p(1)*power((g-p(2))/(255-p(2)),p(3))).*(g>p(2)) + p(4);
errfn = @( p ) sum( ( gammafn(glist,p) - lum ).^2 );
phat = fminsearch(errfn,[ 100 0 1 0 ]);
phat = roundplace(phat,0.001);

% show fit
clf;
plot(glist,lum,'ro'); hold on;
fplot(@(x)gammafn(x,phat),[ 0 255 ]); hold off;
axis([ -1 256 0 1.1*max(lum) ]);
fprintf(1,'%6.2f %6.2f %6.2f %6.2f\n',phat);

% % save fit
% tag=[ datestr(now,30) 'mac' getenv('P_STATION') ];
% fname=sprintf('H:\\COURSES\\RFM\\Data\\cal_%s.mat',tag);
% save(fname,'glist','lum','phat');

% make monitor structure
m.name=[ 'acw203_' getenv('P_STATION') ];
m.mode='native32b';
m.caldate=datestr(now);
m.screennum=0;
m.screensize=winRect(3:4);
m.pixelsize=0.000295;
m.framerate=60;
m.gamma=phat;

% save monitor structure
putvartofile('..\Data\environ.txt',m,1);
