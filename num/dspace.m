function dspace( subject, sourcek, circ, bootstrap )

% DSPACE  Calculate and plot decision space with a circular decision curve
%
% dspace( subject, sourcek, circ, bootstrap )

% 26-Feb-2016 -- created; adapted from dspace.m (RFM)

% set default arguments
if nargin<1, subject = '';  end
if nargin<2, sourcek = [];  end
if nargin<3, circ = 1;      end
if nargin<4, bootstrap = 0; end

% add tools folder
addpath(fullfile(pwd,'tools'));

% plot all subjects
if isempty(subject)
    figure; dspace('kdd');
    figure; dspace('kp');
    figure; dspace('mk');
    figure; dspace('nk');
    figure; dspace('rc');
    return
end

% plot all three conditions
if isempty(sourcek)
    clf;
    p = get(gcf,'Position');
    set(gcf,'Position',[ p(1:2) 1500 500 ]);
    for k = 1:3
        subplot(1,3,k);
        dspace(subject,k);
        drawnow;
    end
    return
end

% load data
stim1 = []; stim2 = []; resp = [];
f = dir(sprintf('./data/%s/num_%s*.mat',subject,subject));
for i = 1:numel(f)
    load(sprintf('./data/%s/%s',subject,f(i).name),'p');
    k = p.sourcek==sourcek;
    a1 = pi*p.radius1P.^2;
    a2 = pi*p.radius2P.^2;
    stim1 = [ stim1 ; [ a1(k) p.n1(k)./a1(k) p.n1(k) ] ];
    stim2 = [ stim2 ; [ a2(k) p.n2(k)./a2(k) p.n2(k) ] ];
    resp = [ resp ; 1 + ( ((p.stimorder(k)==1)&(p.response(k)==2))|((p.stimorder(k)==2)&(p.response(k)==1))) ];
end
afix = stim1(1,1);
dfix = stim1(1,2);

% find median stimulus level
nmedian = median(stim2(stim2(:,3)>40,3));
fprintf('subject %s %d\n    nmedian = %.0f\n',subject,sourcek,nmedian);

% find proportion correct
stim = 1 + (stim2(:,3)>stim1(:,3));
correct = (resp==stim);
pcorrect = mean(correct);
fprintf('    pcorrect = %.2f\n',pcorrect);

% fit decision curve
dsp = calcdspace( log(stim2(:,1)), log(stim2(:,2)), resp );
phat = fitcirc( dsp, circ );
m = -cotd(phat(1));
fprintf('    m = %.2f\n    c = %.2f\n',m,phat(3));

% plot decision space
plotdspace( dsp, phat );
title(sprintf('%s %d',upper(subject),sourcek));
xlim = get(gca,'XLim'); ylim = get(gca,'YLim');
hold on;
for k = 20:5:60
    plot(xlim,log(k)-xlim,'Color',[ 0.5 0.5 0.5 ]);
end
plot( log(afix), log(dfix), 'ko', 'MarkerSize', 15, 'MarkerFaceColor', 'w' );
hold off;
h(1) = text( xlim(1)+0.65*(xlim(2)-xlim(1)), ylim(1)+0.85*(ylim(2)-ylim(1)), sprintf('m = %.2f',m));
h(2) = text( xlim(1)+0.65*(xlim(2)-xlim(1)), ylim(1)+0.75*(ylim(2)-ylim(1)), sprintf('c = %.2f',phat(3)));
set(h,'FontSize',18,'FontWeight','bold');
drawnow;

% % bootstrap
% if bootstrap
%     
%     B = 100;
%     mstar = NaN(1,B);
%     for b = 1:B
%         
%         % resample data
%         n = size(stim2,1);
%         k = unidrnd( n, [ 1 n ] );
%         astar = log(stim2(k,1));
%         dstar = log(stim2(k,2));
%         rstar = resp(k);
%         
%         % fit normal cdf
%         dsp = calcdspace( astar, dstar, rstar );
%         pstar = fitnorm( dsp );
%         mstar(b) = -cotd(pstar(1));
%         fprintf('mstar(%d/%d) = %.2f\n',b,B,mstar(b));
%         
%     end
%     
%     % report and plot slope distribution
%     mint = quantile( mstar, [ 0.025, 0.975 ] );
%     fprintf('m = %.2f (%.2f, %.2f)\n',m,mint(1),mint(2));
%     hist(mstar,linspace(mint(1),mint(2),20));
%     
% end

end
