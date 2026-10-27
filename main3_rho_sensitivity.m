% 分析模糊集半径的影响，生成表 III。

clear; clc;
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root,'lib'));

rhos = [0 0.15 0.20 0.30 0.40 0.50 0.70 1.00];

C   = paper_case(root);
cfg = paper_config(root,'rho_sensitivity');
r40_selftest(cfg);
Om  = sum(C.pub.omega);
n   = numel(rhos);
Z = struct('rho',rhos(:),'gmax',NaN(n,1),'riskDRO',NaN(n,1),'GP',NaN(n,1),'GW',NaN(n,1), ...
    'riskIRpos',NaN(n,1),'statusIRpos',{cell(n,1)},'gpos',C.gpos,'Omega',Om,'solver',r40_backend(cfg));

for i = 1:n
    pub = C.pub; pub.rho = rhos(i);
    tag = sprintf('rho%03d',round(100*rhos(i)));
    [P,~] = r40_lp('build',C.models,pub,C.L0,'GMAX',[0;0],[]);
    rr = r40_lp('solve',P,cfg,[tag '_GMAX']);
    assert(strcmp(rr.status,'OPTIMAL'),'rho=%.2f GMAX: %s.',rhos(i),rr.status);
    Z.gmax(i) = max(-rr.fval,0);
    [P,off] = r40_lp('build',C.models,pub,C.L0,'SYS',[0;0],[]);
    rr = r40_lp('solve',P,cfg,[tag '_SYS']);
    assert(strcmp(rr.status,'OPTIMAL'),'rho=%.2f basic DRO: %s.',rhos(i),rr.status);
    a = r40_lp('assess',C.models,paper_split(rr.x,C.models,off),pub,C.L0);
    Z.riskDRO(i) = a.risk; Z.GP(i) = a.GP; Z.GW(i) = a.GW;
    if abs(rhos(i)-0.30) < 1e-12, paper_check_reference(C,'SYS',rr.fval); end
    [P,off] = r40_lp('build',C.models,pub,C.L0,'IRpos',[C.gpos;C.gpos],[]);
    rr = r40_lp('solve',P,cfg,[tag '_IRpos']);
    Z.statusIRpos{i} = rr.status;
    if strcmp(rr.status,'OPTIMAL')
        a = r40_lp('assess',C.models,paper_split(rr.x,C.models,off),pub,C.L0);
        Z.riskIRpos(i) = a.risk;
        if abs(rhos(i)-0.30) < 1e-12, paper_check_reference(C,'IRpos',rr.fval); end
    end
    fprintf('rho = %.2f done (IR+ %s)\n',rhos(i),rr.status);
end

cost = 100*(Z.riskIRpos-Z.riskDRO)/Om;
T = table(Z.rho,100*Z.GP,100*Z.GW,cost,100*Z.gmax,100*(1-Z.riskDRO/Om),100*(1-Z.riskIRpos/Om),Z.statusIRpos, ...
    'VariableNames',{'rho','GP_pp','GW_pp','IRpos_cost_pp','gmax_pp','Rwc_DRO_percent','Rwc_IRpos_percent','IRpos_status'});
save(fullfile(cfg.outDir,'RHO_SENSITIVITY.mat'),'Z','T','-v7');
writetable(T,fullfile(cfg.outDir,'table3_rho.csv'));
f = fopen(fullfile(cfg.outDir,'table3_rho.tex'),'w','n','UTF-8'); assert(f>=0);
fprintf(f,'%s\n','\begin{tabular}{lrrrr}\toprule');
fprintf(f,'%s\n','$\rho$&$100G_P$&$100G_W$&Cost of IR$_+$&$100\gamma_{\max}$\\\midrule');
for i = 1:n
    if strcmp(Z.statusIRpos{i},'OPTIMAL'), c = paper_tex_num(max(cost(i),0)); else, c = 'infeasible'; end
    fprintf(f,'%.2f&%s&%s&%s&%s\\\\\n',Z.rho(i),paper_tex_num(100*Z.GP(i)),paper_tex_num(100*Z.GW(i)),c,paper_tex_num(100*Z.gmax(i)));
end
fprintf(f,'%s\n','\bottomrule\end{tabular}');
fclose(f);
fprintf('\nTable III\n'); disp(T);
fprintf('Program 3 finished. Results: %s\n',cfg.outDir);
