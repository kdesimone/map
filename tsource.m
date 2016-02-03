function varargout = tsource( varargin )

% TSOURCE  Trial source with interleaved staircases
%
%   usage:                    src = tsource( 'init', nfix, afix, ninit, hrange )
%           [ src, stim1, stim2 ] = tsource( 'get', d )
%                             src = tsource( 'put', d, response )

if strcmp( varargin{1}, 'init' )
    
    % initialize parameters
    src.nfix   = varargin{2};
    src.afix   = varargin{3};
    src.ndelta = varargin{4}*[ 1 1 ];
    src.hrange = varargin{5};
    src.correct   = [ 0 0 ];
    src.incorrect = [ 0 0 ];
    src.wasabove  = [ 0 0 ];
    src.stairk = 1;
    
    % send return argument
    varargout = { src };
    
elseif strcmp( varargin{1}, 'get' )
    
    % get struct
    src = varargin{2};
    
    % get numerosity, area, and density for stimulus 1
    stim1.n = src.nfix;
    stim1.area = src.afix;
    stim1.density = stim1.n/stim1.area;
    
    % decide which staircase to consult
    src.stairk = 1 + (rand<0.5);
    
    % get numerosity for stimulus 2
    src.wasabove(src.stairk) = (rand<0.5);
    if src.wasabove(src.stairk)
        stim2.n = src.nfix + src.ndelta(src.stairk);
    else
        stim2.n = src.nfix - src.ndelta(src.stairk);
        stim2.n = max( stim2.n, 1 );
    end
    
    % get area and density for stimulus 2
    % *** check this
    % choose a random spot on line with numerosity d.nfix
    logA = log( src.afix ) + unifrnd(-1,1)*log( src.hrange );
    logD = log( src.nfix ) - logA;
    % shift at 45 degrees to a spot on line with numerosity stim2.n
    logA = logA + log( stim2.n/src.nfix )/2;
    logD = logD + log( stim2.n/src.nfix )/2;
    % convert from log to linear units
    stim2.area    = exp( logA );
    stim2.density = exp( logD );
    
    % send return arguments
    varargout = { src stim1 stim2 };
    
elseif strcmp( varargin{1}, 'put' )
    
    % get struct
    src = varargin{2};
    
    % see whether observer gave correct response
    correct = varargin{3};
    
    % increment counter
    if correct
        src.correct(src.stairk) = src.correct(src.stairk) + 1;
    else
        src.incorrect(src.stairk) = src.incorrect(src.stairk) + 1;
    end
    
    % adjust stimulus level
    lim2 = [ 2 3 ];
    if src.correct(src.stairk)>=lim2(src.stairk)
        src.ndelta(src.stairk) = max( src.ndelta(src.stairk) - 1, 1 );
        src.correct(src.stairk) = 0;
        src.incorrect(src.stairk) = 0;
    elseif src.incorrect(src.stairk)>=1
        src.ndelta(src.stairk) = src.ndelta(src.stairk) + 1;
        src.correct(src.stairk) = 0;
        src.incorrect(src.stairk) = 0;
    end
    
    % send return argument
    varargout = { src };
    
else
    error('invalid arguments');
end

end
