function psymet( subject, sourcek )

% PSYMET  Show a psychometric function
% 
% psymet( subject, sourcek )

% 19-Feb-2016 -- created; adapted from dspace.m (RFM)

% set default arguments
if nargin<1, subject = 'sim'; end
if nargin<2, sourcek = []; end

% add tools folder
addpath(fullfile(pwd,'tools'));

% plot all three conditions
if isempty(sourcek)
    for k = 1:3
        figure;
        psymet(subject,k);
        drawnow;
    end
    return
end

% load data
n1 = []; n2 = []; resp = [];
f = dir(sprintf('./data/%s/num_%s*.mat',subject,subject));
if isempty(f)
    error('no data for subject %s\n',subject);
end
for i = 1:numel(f)
    load(sprintf('./data/%s/%s',subject,f(i).name),'p');
    k = p.sourcek==sourcek;
    n1 = [ n1 ; p.n1(k) ];
    n2 = [ n2 ; p.n2(k) ];
    resp = [ resp ; ( ((p.stimorder(k)==1)&(p.response(k)==2))|((p.stimorder(k)==2)&(p.response(k)==1))) ];
end

% plot psychometric function
emp = emppsymet( [ n2 resp ] );
emp = emp(~isnan(emp(:,1)),:);
phat = fitpsymet( emp, 'norm', [ mean(n2(~isnan(n2))) 4 ], 0.01, 0.01 );
plotpsymet( emp, 'norm', phat, [], 0.50, 0.01, 0.01 );
fprintf('75%% threshold = %.2f\n',norminv(0.75)*phat(2));

end
