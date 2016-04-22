function plotdspacec( dspace, param, points )

% PLOTDSPACEC  Plot proxy decision space with circular decision curve
%
%     usage:  plotdspacec( dspace, param )
%
%     input arguments
%         'dspace' is a struct that describes the proxy decision space; it is the return argument from calcdspace.m
%         'param' is a 1 x 5 matrix of GDD function parameters; it is the return argument from fitgdd.m

% set default arguments
if nargin<2, param = []; end
if nargin<3, points = 0; end

% don't plot cells with too few trials
% dspace.pmat(dspace.nmat<10) = NaN;

% trim response matrix (remove elements with no trials)
mi = min(isnan(dspace.pmat),[],1);
mj = min(isnan(dspace.pmat),[],2);
i1 = min( find(mi==0,1,'first'), find(mj==0,1,'first') );
i2 = max( find(mi==0,1,'last'),  find(mj==0,1,'last')  );
dspace.dlist1 = dspace.dlist1(i1:i2);
dspace.dlist2 = dspace.dlist2(i1:i2);
dspace.pmat = dspace.pmat(i1:i2,i1:i2);
dspace.kmat = dspace.kmat(i1:i2,i1:i2);
dspace.nmat = dspace.nmat(i1:i2,i1:i2);

% make formatted plot of response matrix
if points
    clf;
    cmap = colormap('jet');
    for i = 1:numel(dspace.dlist1)
        for j = 1:numel(dspace.dlist2)
            if ~isnan(dspace.pmat(i,j))
                h = plot( dspace.dlist1(i), dspace.dlist2(j), 's', 'MarkerSize', 18 );
                c = cmap( round( 1 + (size(cmap,1)-1)*dspace.pmat(i,j) ),: );
                set(h,'Color',c,'MarkerFaceColor',c);
                hold on;
            end
        end
    end
else
    imagesc( dspace.dlist1, dspace.dlist2, dspace.pmat', [ 0 1 ]); hold on;
    colormap jet
    nancolor([ 1 1 1 ]);
end
set(gca,'FontName','helvetica','FontWeight','bold','FontSize',24);
xlabel 'log(area)'
ylabel 'log(density)'
axis xy equal
set(gca,'XLim',dspace.dlist1([ 1 end ]),'YLim',dspace.dlist2([ 1 end ]));

if ~isempty(param)
    
    % get axis limits
    xlim = get(gca,'XLim');
    ylim = get(gca,'YLim');
    hold on;
    
    % decode parameters
    theta = param(1);
    disp = param(2);
    c = param(3);
    origin = param([ 5 6 ]);
    
    % get distance from decision curve
    a = origin + disp*[ cosd(45) sind(45) ];
    if abs(c)<1e-6
        
        % plot decision line:  [ x y ]*[ cos(theta) sin(theta) ]' = delta
        delta = a(:)'*[ cosd(theta) ; sind(theta) ];
        if abs(sind(theta))>0.001
            h = plot(xlim,(delta-xlim*cosd(theta))/sind(theta),'r-');
        else
            % special case:  vertical line
            h = plot([ delta delta ]*sign(cosd(theta)),ylim,'r-');
        end
        
    else
        
        % circular curve
        
        r = 1/abs(c);
        b = a + sign(c)*r*[ cosd(theta+180) sind(theta+180) ];
        
        phi = linspace(0,360,1000);
        x = b(1) + r*cosd( phi );
        y = b(2) + r*sind( phi );
        
        h = plot( x, y, 'r-' );
        
    end
    
    % adjust appearance
    set(h,'LineWidth',3);
    axis([ xlim ylim ]);
    hold off;
    
    
end

end


function nancolor( rgb )

% NANCOLOR  Set color of NaN elements in current image
%
%     usage:  nancolor( rgb )
%
%     input argument
%         'rgb' is a 1 x 3 matrix that specifies the color of NaN elements

% set default color
if nargin<1, rgb = [ 1 1 1 ]; end

% get image data
h = get(gca,'Children');
h = findobj(h,'Type','image');
im = get(h,'CData');

% get colormap
map = colormap;
n = size(map,1);

% set first row of colormap
map(1,:) = rgb;
colormap(map);

% get data range and step size
mn = min(im(:));
mx = max(im(:));
step = (mx-mn)/(n-2);

% set color range
set(gca,'CLim',[ mn-step mx ]);

end
