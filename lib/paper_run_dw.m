function d=paper_run_dw(C,cfg,name,g,centralRisk)
% 运行 D–W 分解并恢复、检查方案。
c=cfg;c.caseDir=fullfile(cfg.outDir,['DW_' name]);c.logDir=fullfile(c.caseDir,'logs');
if ~exist(c.caseDir,'dir'),mkdir(c.caseDir);end
owners=cell(1,2);exporters=cell(1,2);
for m=1:2
 seed=[];if g==0,seed=C.baseline{m};end
 [owners{m},exporters{m}]=r40_owner(C.models{m},C.pub,C.L0(:,m),g,seed,c,m);
end
fprintf('DW %s started.\n',name);
d=r40_dw(owners,C.pub,c,g==0);
if isfield(d,'ids')
 plans=cell(1,2);
 for m=1:2,plans{m}=exporters{m}(struct('ids',d.ids{m},'weights',d.weights{m}));end
 d.audit=r40_lp('assess',C.models,plans,C.pub,C.L0);
 d.centralObjective=centralRisk;d.centralError=d.audit.risk-centralRisk;
 save(fullfile(c.caseDir,'RECOVERED_PLANS.mat'),'plans','d','-v7');
end
h=d.history;n1=0;n2=0;
if ~isempty(h),n1=sum(h(:,1)==1);n2=sum(h(:,1)==2);end
if isfield(d,'gap')
 fprintf('DW %s: %s, %d feasibility + %d resilience iterations, %.1f s, gap %.2e, |recovered - central| = %.1e\n',...
  name,d.status,n1,n2,d.seconds,d.gap,abs(d.centralError));
else
 warning('R40:DW','DW %s ended with status %s after %d + %d iterations.',name,d.status,n1,n2);
end
end
