% 计算共同保障前沿，生成图 3。

clear; clc;
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root,'lib'));

C   = paper_case(root);
cfg = paper_config(root,'frontier');
r40_selftest(cfg);
Om  = sum(C.pub.omega);

[P,~] = r40_lp('build',C.models,C.pub,C.L0,'SYS',[0;0],[]);
rr = r40_lp('solve',P,cfg,'frontier_SYS');
assert(strcmp(rr.status,'OPTIMAL'),'Basic DRO: solver status %s.',rr.status);
sysRisk = rr.fval;
paper_check_reference(C,'SYS',rr.fval);

[P,~] = r40_lp('build',C.models,C.pub,C.L0,'GMAX',[0;0],[]);
rr = r40_lp('solve',P,cfg,'frontier_GMAX');
assert(strcmp(rr.status,'OPTIMAL'),'GMAX: solver status %s.',rr.status);
gmax = -rr.fval;
fprintf('gamma_max = %.4f percentage points\n',100*gmax);

gs = unique([0, C.gpos, [.2 .4 .6 .8 .95]*gmax]);
n  = numel(gs);
F = struct('g',gs(:),'risk',NaN(n,1),'GP',NaN(n,1),'GW',NaN(n,1), ...
    'gmax',gmax,'gpos',C.gpos,'sysRisk',sysRisk,'Omega',Om,'solver',r40_backend(cfg));
for k = 1:n
    g = gs(k);
    [P,off] = r40_lp('build',C.models,C.pub,C.L0,'IR',[g;g],[]);
    rr = r40_lp('solve',P,cfg,sprintf('frontier_%02d',k));
    assert(strcmp(rr.status,'OPTIMAL'),'Floor %.4f pp: solver status %s.',100*g,rr.status);
    a = r40_lp('assess',C.models,paper_split(rr.x,C.models,off),C.pub,C.L0);
    assert(min(a.GP,a.GW) >= g-cfg.feasTol,'Floor %.4f pp is not met.',100*g);
    F.risk(k) = a.risk; F.GP(k) = a.GP; F.GW(k) = a.GW;
end

save(fullfile(cfg.outDir,'FRONTIER_RESULTS.mat'),'F','-v7');
T = table(100*F.g,100*(1-F.risk/Om),100*F.GP,100*F.GW, ...
    'VariableNames',{'floor_pp','Rwc_percent','GP_pp','GW_pp'});
writetable(T,fullfile(cfg.outDir,'frontier.csv'));
disp(T);
plot_fig3_guarantee_frontier(F);
fprintf('\nProgram 2 finished. Results: %s\n',cfg.outDir);
