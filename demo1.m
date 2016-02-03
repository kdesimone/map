% demo1.m  Illustrate how to use tsource.m to get stimulus levels

clear; clc;

% set some parameters
nfix = 40;           % number of elements in fixed stimulus
afix = pi*4^2;       % area of fixed stimulus (deg^2)
ninit = 4;           % initialization; number of elements by which the 
                     % other stimulus differs from the fixed stimulus,
                     % at the beginning of the experiment
arange = 2;          % factor by which we will randomly tweak the area of
                     % the other stimulus up or down

% initialize staircases
src = tsource( 'init', nfix, afix, ninit, arange );

% run some trials
for t = 1:1000
    
    % get stimulus parameters for a trial
    [ src, stim1, stim2 ] = tsource( 'get', src );
    % stim1 is the fixed stimulus
    % stim2 is the staircase stimulus
    
    % present the stimulus
    % ...
    
    % see whether the observer gave a correct response
    % - here I'm using a made-up decision rule where the observer gives
    %   the correct response if the two numerosities differ by more than 10
    d = abs( stim2.n - stim1.n );
    correct = ( d > 10 );
    
    % report the result to the staircases
    src = tsource( 'put', src, correct );
    
end
