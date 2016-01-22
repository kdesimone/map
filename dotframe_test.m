
% display parameters
p.viewing_distance = 50; % cm
p.screen_width = 30; % cm
p.xpixels = 1280;
p.ypixels = 800;
p.xc = p.xpixels/2;
p.yc = p.ypixels/2;
p.ppd = pi*p.xpixels/atan(p.screen_width/p.viewing_distance/2.0)/360.0;
p.white = [255 255 255];
p.black = [0 0 0];
p.bg = (p.white + p.black) / 2;

p.range = 0.30; % max +/- difference between intervals
p.ndots = 50; % int
p.density = 8 * p.ppd; % degrees, radius of disk
p.area = 0.30 * p.ppd; % degrees, radius of each dot
p.min_density = p.density - log(p.density * p.range);
p.max_density = p.density + log(p.density * p.range);
p.min_area = p.area - log(p.area * p.range);
p.max_area = p.area + log(p.area * p.range);
p.dispsize = ceil(p.max_density * 2); % degrees

p.ntrials = 300*34;
p.densities = NaN(p.ntrials,1);
p.areas = NaN(p.ntrials,1);


for trial = 1:p.ntrials
    
    % random density & area
    density = p.min_density + (p.max_density-p.min_density).*rand(1,1);
    area = p.min_area + (p.max_area-p.min_area).*rand(1,1);
    
    % test dot array
    test_d = dotframe(p.ndots, area, density, p.dispsize+2);
    
    % reference dot array
    ref_d = dotframe(p.ndots, p.area, p.density, p.dispsize+2);
    
    p.densities(trial) = density;
    p.areas(trial) = area;
    
end

