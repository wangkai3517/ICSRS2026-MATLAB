function b=r40_backend(cfg)
% 选择 Gurobi 或 linprog 求解器。
persistent cached
if nargin>=1&&isfield(cfg,'solver')&&~strcmpi(cfg.solver,'auto'),b=lower(cfg.solver);return;end
if ~isempty(cached),b=cached;return;end
b='linprog';
if exist('gurobi','file')~=0
 try
  n=2500;model=struct('A',sparse(ones(1,n)),'rhs',1,'sense','<','obj',-ones(n,1),...
   'lb',zeros(n,1),'ub',ones(n,1),'modelsense','min');
  r=gurobi(model,struct('OutputFlag',0));
  if strcmp(r.status,'OPTIMAL'),b='gurobi';end
 catch
 end
end
cached=b;
fprintf('LP solver: %s\n',b);
end
