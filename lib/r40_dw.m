function out=r40_dw(owners,pub,cfg,baselineFeasible)
% 执行 D–W 主问题协调和列生成。
total=tic;M=numel(owners);cols=cell(1,M);history=[];last=struct;lastEvidence=struct;status='ITERATION_LIMIT';
for m=1:M,cols{m}=owners{m}('initial',struct);end
phases=2;if ~baselineFeasible,phases=[1 2];end
for phase=phases
 best=0;done=false;
 for it=1:cfg.maxIterations
  if toc(total)>=cfg.dwSeconds,status='TIME_LIMIT';break;end
  [P,off,rows]=master(cols,pub,phase);c=cfg;c.remainingSeconds=cfg.dwSeconds-toc(total);
  sr=r40_lp('solve',P,c,sprintf('phase%d_rmp_%05d',phase,it));
  if ~strcmp(sr.status,'OPTIMAL'),status=['RMP_' sr.status];break;end
  strictPrimal=sr.primalResidual<=cfg.feasTol;
  strictDual=sr.dualResidual<=cfg.feasTol&&sr.dualityGap<=cfg.lpGapTol*(1+abs(sr.fval));
  if phase==1&&sr.fval<=cfg.feasTol&&strictPrimal
   history(end+1,:)=[phase,it,sr.fval,best,max(0,sr.fval-best),toc(total),off(end),NaN,NaN,sr.seconds,0,0];
   done=true;break;
  end
  if phase==1
   lam=pub.scale(:).*(sr.mu(1:pub.K)-sr.mu(pub.K+(1:pub.K)));p=zeros(pub.S,1);
  else
   lam=sr.nu(M+(1:pub.K));p=sr.mu(rows);
   assert(min(p)>=-cfg.feasTol&&abs(sum(p)-1)<=cfg.feasTol&&sum(abs(p-pub.p0(:)))<=pub.rho+cfg.feasTol,...
    'R40:RiskDual','RMP multiplier is not in the declared probability set.');
  end
  cand=cell(1,M);rc=zeros(M,1);priceSecs=0;pricingDone=true;
  for m=1:M
   try
    req=struct('lambda',lam,'price',pub.omega(m)*p,'remainingSeconds',cfg.dwSeconds-toc(total));
    cand{m}=owners{m}('price',req);rc(m)=cand{m}.value+sr.nu(m);priceSecs=priceSecs+cand{m}.seconds;
    dotvalue=lam'*cand{m}.q+pub.omega(m)*p'*cand{m}.ell;
    assert(abs(dotvalue-cand{m}.primalValue)<=cfg.lpGapTol*(1+abs(dotvalue)));
   catch err
    if strcmp(err.identifier,'R40:PricingIncomplete'),status='PRICING_INCOMPLETE';pricingDone=false;break;else,rethrow(err);end
   end
  end
  if ~pricingDone,break;end
  lb=sr.dualValue+sum(min(rc,0));
  if strictDual,best=max(best,lb);end
  assert(best<=sr.fval+cfg.feasTol,'Invalid DW lower bound.');
  history(end+1,:)=[phase,it,sr.fval,best,max(0,sr.fval-best),toc(total),off(end),rc(:)',sr.seconds,priceSecs,1];
  if phase==2
   ids=cell(1,M);weights=ids;
   for m=1:M,ids{m}=[cols{m}.id]';weights{m}=sr.x(off(m)+(1:numel(cols{m})));end
   if strictPrimal
    last=struct('ids',{ids},'weights',{weights},'UB',sr.fval,'LB',best,'gap',max(0,sr.fval-best));
    lastEvidence=struct('P',P,'solve',sr,'candidates',{cand},'lambda',lam,'probability',p,'rc',rc,'phase',phase,'iteration',it);
   end
  end
  if mod(it,25)==0||it==1
   fprintf('phase %d, iter %d, UB %.9g, LB %.9g, gap %.3g\n',phase,it,sr.fval,best,max(0,sr.fval-best));
   writehistory(history,cfg);
  end
  if phase==1&&best>cfg.feasTol,status='INTERFACE_INFEASIBLE';break;end
  if phase==2&&strictPrimal&&sr.fval-best<=cfg.dwGapTol,status='OPTIMAL';done=true;break;end
  added=0;
  for m=1:M
   if rc(m)<-cfg.priceTol
    keep=struct('id',cand{m}.id,'q',cand{m}.q,'ell',cand{m}.ell);
    cols{m}(end+1)=keep;added=added+1;
   end
  end
  if added==0,status='UNRESOLVED_STALL';break;end
 end
 if ~done,break;end
end
out=last;out.status=status;out.seconds=toc(total);out.history=history;out.verified=false;
if isfield(last,'ids')
 q=zeros(pub.K,1);ell=zeros(pub.S,1);res=0;
 for m=1:M
  a=owners{m}('recover',struct('ids',last.ids{m},'weights',last.weights{m}));
  q=q+a.q;ell=ell+pub.omega(m)*a.ell;res=max(res,a.residual);
 end
 out.recoveredRisk=r40_lp('risk',ell,pub.p0,pub.rho);out.interfaceResidual=norm(q,Inf);
 out.verified=res<=cfg.feasTol&&out.interfaceResidual<=cfg.feasTol&&abs(out.recoveredRisk-out.UB)<=cfg.feasTol;
 assert(out.verified,'R40:Recovery','Recovered plan failed the original constraints.');
end
writehistory(history,cfg);save(fullfile(cfg.caseDir,'DW_COORDINATOR_RESULT.mat'),'out','-v7');
if isfield(lastEvidence,'P'),save(fullfile(cfg.caseDir,'LAST_COMPLETE_RMP_EVIDENCE.mat'),'lastEvidence','-v7');end
end
function writehistory(h,cfg)
n={'phase','iteration','UB','LB','gap','seconds','columns','rcP','rcW','rmp_seconds','pricing_seconds','pricing_complete'};
if ~isempty(h),writetable(array2table(h,'VariableNames',n),fullfile(cfg.caseDir,'DW_HISTORY.csv'));end
end
function [P,off,rows]=master(cols,pub,phase)
M=numel(cols);cnt=cellfun(@numel,cols);off=[0,cumsum(cnt)];N=off(end);K=pub.K;S=pub.S;
extra=1;ne=M+K;if phase==1,extra=K;ne=M;end
P=struct('A',sparse(0,N+extra),'b',zeros(0,1),'E',sparse(ne,N+extra),...
 'e',[ones(M,1);zeros(ne-M,1)],'lb',zeros(N+extra,1),'ub',Inf(N+extra,1),'c',zeros(N+extra,1));
Q=zeros(K,N);L=zeros(S,N);rows=[];
for m=1:M
 ix=off(m)+(1:cnt(m));P.E(m,ix)=1;
 for j=1:cnt(m),Q(:,ix(j))=cols{m}(j).q;L(:,ix(j))=pub.omega(m)*cols{m}(j).ell;end
end
if phase==1
 D=spdiags(pub.scale(:),0,K,K);P.A=[D*Q,-speye(K);-D*Q,-speye(K)];P.b=zeros(2*K,1);P.c(N+1:end)=1;
else
 P.E(M+1:end,1:N)=Q;P.c(N+1)=1;[P,rows]=r40_lp('append',P,L,zeros(S,1),N+1,-1,0,pub);
end
end
