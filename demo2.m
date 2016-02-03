% demo2.m  Like demo1.m, but with three staircases

clear; clc;

% set some parameters
nfix = 40;           % number of elements in fixed stimulus
afix = pi*4^2;       % area of fixed stimulus (deg^2)
ninit = 4;           % initialization; number of elements by which the 
                     % other stimulus differs from the fixed stimulus,
                     % at the beginning of the experiment
arange = 2;          % factor by which we will randomly tweak the area of
                     % the other stimulus up or down

% initialize three staircases
src{1} = tsource( 'init', nfix, 0.5*afix, ninit, arange );
src{2} = tsource( 'init', nfix,     afix, ninit, arange );
src{3} = tsource( 'init', nfix, 2.0*afix, ninit, arange );

% run some trials
for t = 1:100

    % choose a staircase (1, 2, or 3)
    k = ceil(3*rand);

    % get stimulus parameters for a trial
    [ src{k}, stim1, stim2 ] = tsource( 'get', src{k} );
    
    % present the stimulus
    % ...
    
    % see whether the observer gave a correct response
    % - here I'm using a made-up decision rule where the observer gives
    %   the correct response if the two numerosities differ by more than 10
    d = abs( stim2.n - stim1.n );
    correct = ( d > 10 );
    
    % report the result to the staircases
    src{k} = tsource( 'put', src{k}, correct );
    
end
