function fixpt(w,p)

% cross fixation point
hlen = 3;
Screen('FillRect',w,p.fgrgb,[ p.xpixels/2      p.ypixels/2-hlen p.xpixels/2+1      p.ypixels/2+hlen+1 ]);
Screen('FillRect',w,p.fgrgb,[ p.xpixels/2-hlen p.ypixels/2      p.xpixels/2+hlen+1 p.ypixels/2+1      ]);

% dot fixation point
% hlen = 1;
% Screen('FillRect',w,p.fgrgb,[ p.xpixels/2-hlen p.ypixels/2-hlen p.xpixels/2+hlen p.ypixels/2+hlen ]);

end
