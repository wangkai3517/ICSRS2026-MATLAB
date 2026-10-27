function varargout = r40_lp(action,varargin)
% 构造、求解线性规划并评价方案。
switch action
 case 'raw', varargout{1}=raw(varargin{1});
 case 'append', [varargout{1:nargout}]=append(varargin{:});
 case 'build', [varargout{1:nargout}]=build(varargin{:});
 case 'solve', varargout{1}=solveLP(varargin{:});
 case 'risk', [varargout{1:nargout}]=risk(varargin{:});
 case 'assess', varargout{1}=assess(varargin{:});
 case 'localcheck', varargout{1}=localcheck(varargin{:});
 otherwise, error('R40:Action','Unknown action %s.',action);
end
end

function P=raw(m)
P=struct('A',sparse(m.A),'b',double(m.b(:)),'E',sparse(m.E),'e',double(m.e(:)),...
 'lb',double(m.lb(:)),'ub',double(m.ub(:)),'c',zeros(m.n,1));
end

function [P,rows]=append(P,B,z0,target,targetCoef,rhs,pub)
S=double(pub.S);n=numel(P.c);na=2*S+2;B=sparse(B);B(:,end+1:n)=0;
assert(size(B,2)==n&&size(B,1)==S,'Risk mapping dimension mismatch.');
P.A=[P.A,sparse(size(P.A,1),na)];P.E=[P.E,sparse(size(P.E,1),na)];
P.c=[P.c;zeros(na,1)];P.lb=[P.lb;-Inf;zeros(na-1,1)];P.ub=[P.ub;Inf(na,1)];
inu=n+1;ia=n+1+(1:S);ib=n+1+S+(1:S);it=n+na;
B0=sparse(2*S+1,n+na);B0(1:S,1:n)=B;B0(1:S,inu)=-1;
B0(1:S,ia)=-speye(S);B0(1:S,ib)=speye(S);
B0(S+(1:S),ia)=speye(S);B0(S+(1:S),ib)=speye(S);B0(S+(1:S),it)=-1;
B0(end,inu)=1;B0(end,ia)=pub.p0(:)';B0(end,ib)=-pub.p0(:)';B0(end,it)=pub.rho;
if ~isempty(target),B0(end,target)=B0(end,target)+targetCoef;end
rows=size(P.A,1)+(1:S);P.A=[P.A;B0];P.b=[P.b;-z0(:);zeros(S,1);rhs];
end

function [P,off]=build(models,pub,L0,name,g,fixedX)
if nargin<6,fixedX=[];end
M=numel(models);off=[0,cumsum(cellfun(@(m)double(m.n),models))];N=off(end);
A=sparse(0,0);E=sparse(0,0);b=[];e=[];lb=[];ub=[];Q=sparse(pub.K,0);L=cell(1,M);
for m=1:M
 mo=models{m};A=blkdiag(A,mo.A);E=blkdiag(E,mo.E);b=[b;mo.b];e=[e;mo.e];
 lb=[lb;mo.lb];ub=[ub;mo.ub];Q=[Q,mo.Q];
 L{m}=sparse(pub.S,N);L{m}(:,off(m)+(1:mo.n))=mo.L;
 if ~isempty(fixedX)
  assert(isequal(size(fixedX),[double(mo.nx),M]),'Bad fixed-investment dimensions.');
  ix=off(m)+(1:mo.nx);lb(ix)=fixedX(:,m);ub(ix)=fixedX(:,m);
 end
end
P=struct('A',A,'b',b,'E',[E;Q],'e',[e;zeros(pub.K,1)],'lb',lb,'ub',ub,'c',zeros(N,1));
systemLoss=sparse(pub.S,N);for m=1:M,systemLoss=systemLoss+pub.omega(m)*L{m};end
if strcmp(name,'SP'),P.c=systemLoss'*pub.p0(:);return;end
P.A(:,N+1)=0;P.E(:,N+1)=0;P.lb(end+1,1)=0;P.ub(end+1,1)=Inf;P.c(end+1,1)=1;
if strcmp(name,'GMAX')
 P.lb(end)=-Inf;P.c(end)=-1;
 for m=1:M
  B=[L{m},ones(pub.S,1)];[P,~]=append(P,B,-L0(:,m),[],0,0,pub);
 end
else
 [P,~]=append(P,systemLoss,zeros(pub.S,1),N+1,-1,0,pub);
 if ismember(name,{'IR','IR0','IRpos'})
  for m=1:M,[P,~]=append(P,L{m},-L0(:,m),[],0,-g(m),pub);end
 end
end
end

function r=solveLP(P,cfg,tag)
assert(isfield(cfg,'execute')&&cfg.execute,'R40:NotAuthorized','Use the explicit run entry.');
backend=r40_backend(cfg);
timeLimit=cfg.lpSeconds;
if isfield(cfg,'remainingSeconds'),timeLimit=min(timeLimit,max(.05,cfg.remainingSeconds));end
auditPrimalTol=cfg.feasTol;auditDualTol=cfg.feasTol;
if startsWith(tag,'phase')&&contains(tag,'_rmp_')
 auditPrimalTol=max(auditPrimalTol,1e-6);auditDualTol=max(auditDualTol,1e-6);
end
passed=@(r) r.primalResidual<=auditPrimalTol&&r.dualResidual<=auditDualTol&&...
 r.dualityGap<=cfg.lpGapTol*(1+abs(r.fval));
r=attempt(P,cfg,tag,backend,timeLimit,false);
if ~strcmp(r.status,'OPTIMAL'),return;end
if strcmp(backend,'gurobi')&&~passed(r)
 fprintf('  LP %s: residuals %.2g / %.2g, re-solved with tolerance 1e-9\n',tag,r.primalResidual,r.dualResidual);
 first=r.seconds;r=attempt(P,cfg,tag,backend,timeLimit,true);r.seconds=r.seconds+first;
 if ~strcmp(r.status,'OPTIMAL'),return;end
end
assert(r.primalResidual<=auditPrimalTol&&r.dualResidual<=auditDualTol,'R40:KKT',...
 'LP %s residuals %.3g / %.3g.',tag,r.primalResidual,r.dualResidual);
assert(r.dualityGap<=cfg.lpGapTol*(1+abs(r.fval)),'R40:LPGap','Uncertified LP %s.',tag);
end

function r=attempt(P,cfg,tag,backend,timeLimit,strict)
r=struct('status','','seconds',0,'tag',tag,'backend',backend,'usable',false,'fval',NaN,...
 'dualValue',NaN,'primalResidual',NaN,'dualResidual',NaN,'dualityGap',NaN,'strict',strict);
x=[];mu=[];nu=[];rc=[];t=tic;
if strcmp(backend,'gurobi')
 model=struct('A',sparse([P.A;P.E]),'rhs',double([P.b(:);P.e(:)]),...
  'sense',[repmat('<',numel(P.b),1);repmat('=',numel(P.e),1)],'obj',double(P.c(:)),...
  'lb',double(P.lb(:)),'ub',double(P.ub(:)),'modelsense','min');
 params=struct('OutputFlag',0,'LogToConsole',0,'TimeLimit',timeLimit);
 if strict,params.FeasibilityTol=1e-9;params.OptimalityTol=1e-9;end
 if isfield(cfg,'writeLogs')&&cfg.writeLogs
  if ~exist(cfg.logDir,'dir'),mkdir(cfg.logDir);end
  params.OutputFlag=1;params.LogFile=fullfile(cfg.logDir,[regexprep(tag,'[^A-Za-z0-9_-]','_') '.log']);
 end
 rr=gurobi(model,params);r.status=rr.status;
 if isfield(rr,'x'),x=rr.x(:);end
 if strcmp(rr.status,'OPTIMAL')
  assert(isfield(rr,'pi')&&isfield(rr,'rc'),'R40:DualUnavailable','Optimal LP has no dual information.');
  mu=-rr.pi(1:numel(P.b));nu=-rr.pi(numel(P.b)+(1:numel(P.e)));rc=rr.rc(:);
 end
else
 opts=optimoptions('linprog','Algorithm','dual-simplex','Display','off',...
  'ConstraintTolerance',1e-9,'OptimalityTolerance',1e-9,'MaxTime',timeLimit);
 A=P.A;b=P.b;if size(A,1)==0,A=[];b=[];end
 E=P.E;e=P.e;if size(E,1)==0,E=[];e=[];end
 [xx,~,flag,~,lam]=linprog(double(P.c(:)),A,b,E,e,double(P.lb(:)),double(P.ub(:)),opts);
 r.status=flagstatus(flag);
 if ~isempty(xx),x=xx(:);end
 if strcmp(r.status,'OPTIMAL')
  mu=lam.ineqlin(:);nu=lam.eqlin(:);rc=lam.lower(:)-lam.upper(:);
  if isempty(mu),mu=zeros(numel(P.b),1);end
  if isempty(nu),nu=zeros(numel(P.e),1);end
 end
end
r.seconds=toc(t);
if isempty(x),return;end
r.usable=all(isfinite(x));r.x=x;r.fval=P.c(:)'*x;
pr=max([0;P.A*x-P.b;abs(P.E*x-P.e);P.lb-x;x-P.ub]);r.primalResidual=pr;
if ~strcmp(r.status,'OPTIMAL'),return;end
mu=mu(:);nu=nu(:);
ld=max(rc,0);ud=max(-rc,0);il=isfinite(P.lb(:));iu=isfinite(P.ub(:));
stat=P.c(:)+P.A'*mu+P.E'*nu-ld+ud;
dr=max([0;abs(stat(:));-mu(:);ld(~il);ud(~iu)]);
dv=-sum(P.b(:).*mu(:))-sum(P.e(:).*nu(:)) ...
   +sum(P.lb(il).*ld(il))-sum(P.ub(iu).*ud(iu));
r.mu=mu;r.nu=nu;r.dualValue=dv;r.dualResidual=dr;r.dualityGap=abs(r.fval-dv);
end

function s=flagstatus(flag)
switch flag
 case 1, s='OPTIMAL';
 case 0, s='TIME_LIMIT';
 case {-2,-5}, s='INFEASIBLE';
 case -3, s='UNBOUNDED';
 otherwise, s=sprintf('NUMERIC_%d',flag);
end
end

function [value,p]=risk(z,p0,rho)
z=double(z(:));p=double(p0(:));assert(numel(z)==numel(p)&&all(p>=0)&&abs(sum(p)-1)<1e-9);
assert(rho>=0&&rho<=2);[~,lo]=sortrows([z,(1:numel(z))'],[1 2]);hi=flipud(lo);i=1;j=1;budget=rho/2;
while budget>1e-14&&i<=numel(p)&&j<=numel(p)
 a=lo(i);h=hi(j);if z(h)<=z(a)+1e-15,break;end
 amount=min([budget,p(a),1-p(h)]);p(a)=p(a)-amount;p(h)=p(h)+amount;budget=budget-amount;
 if p(a)<1e-14,i=i+1;end;if 1-p(h)<1e-14,j=j+1;end
end
value=p'*z;
end

function a=assess(models,plans,pub,L0)
M=numel(models);loss=zeros(pub.S,M);q=zeros(pub.K,1);gain=zeros(M,1);res=0;x=zeros(models{1}.nx,M);
for m=1:M
 mo=models{m};w=plans{m}(:);assert(numel(w)==mo.n);loss(:,m)=mo.L*w;q=q+mo.Q*w;x(:,m)=w(1:mo.nx);
 res=max(res,max([0;mo.A*w-mo.b;abs(mo.E*w-mo.e);mo.lb-w;w-mo.ub]));
 gain(m)=-risk(loss(:,m)-L0(:,m),pub.p0,pub.rho);
end
[rv,p]=risk(loss*pub.omega(:),pub.p0,pub.rho);
a=struct('risk',rv,'nominal',pub.p0(:)'*loss*pub.omega(:),'GP',gain(1),'GW',gain(2),...
 'physical',res,'interface',norm(q,Inf),'loss',loss,'protection',x,'risk_probability',p);
end

function r=localcheck(m,w,pub,l0,g)
r=max([0;m.A*w-m.b;abs(m.E*w-m.e);m.lb-w;w-m.ub;risk(m.L*w-l0,pub.p0,pub.rho)+g]);
end
