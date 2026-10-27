% 求解各方案及 D–W 分解，生成表 II 和图 1、2、4、5。

clear; clc;
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root,'lib'));

runDW = {'IR0','IRpos'};

C   = paper_case(root);
cfg = paper_config(root,'single_run');
r40_selftest(cfg);

R = struct('data',C.data,'pub',C.pub,'gpos',C.gpos,'L0',C.L0, ...
    'solver',r40_backend(cfg),'policies',struct,'dw',struct, ...
    'matlabVersion',version,'generatedAt',datestr(now,31));

fprintf('\n[1] Centralized policies\n');
R.policies.Baseline = r40_lp('assess',C.models,C.baseline,C.pub,C.L0);
names = {'SP','SYS','IR0','IRpos'};
for k = 1:numel(names)
    name = names{k};
    g = [0;0]; if strcmp(name,'IRpos'), g(:) = C.gpos; end
    [P,off] = r40_lp('build',C.models,C.pub,C.L0,name,g,[]);
    rr = r40_lp('solve',P,cfg,['central_' name]);
    assert(strcmp(rr.status,'OPTIMAL'),'%s: solver status %s.',name,rr.status);
    a = r40_lp('assess',C.models,paper_split(rr.x,C.models,off),C.pub,C.L0);
    assert(max(a.physical,a.interface) <= cfg.feasTol,'%s: returned plan is infeasible.',name);
    a.status = rr.status; a.seconds = rr.seconds;
    a.lpSize = [size(P.A,1)+size(P.E,1), numel(P.c)];
    fprintf('  %-6s LP %d x %d solved in %.2f s\n',name,a.lpSize(1),a.lpSize(2),rr.seconds);
    paper_check_reference(C,name,rr.fval);
    R.policies.(name) = a;
end

fprintf('\n[2] Dantzig-Wolfe decomposition\n');
for k = 1:numel(runDW)
    name = runDW{k};
    g = 0; if strcmp(name,'IRpos'), g = C.gpos; end
    R.dw.(name) = paper_run_dw(C,cfg,name,g,R.policies.(name).risk);
    save(fullfile(cfg.outDir,'SINGLE_RUN_RESULTS.mat'),'R','-v7');
end

save(fullfile(cfg.outDir,'SINGLE_RUN_RESULTS.mat'),'R','-v7');
T = paper_policy_table(R,fullfile(cfg.outDir,'table2_policies'));
fprintf('\n[3] Table II: R_ref, R_wc in %%; 100G_P, 100G_W in percentage points\n');
disp(T);

fprintf('[4] Figures\n');
plot_fig1_network(R);
plot_fig2_policy_risk(R);
plot_fig4_protection_changes(R);
if isfield(R.dw,'IRpos'), plot_fig5_dw_bounds(R); end
fprintf('\nProgram 1 finished. Results: %s\n',cfg.outDir);
