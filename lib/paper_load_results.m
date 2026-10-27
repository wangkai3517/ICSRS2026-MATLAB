function [R,src]=paper_load_results(kind,source)
% 读取运行结果或冻结结果供绘图使用。
if nargin<2||isempty(source),source='auto';end
assert(any(strcmpi(source,{'auto','frozen'})),'Data source must be ''auto'' or ''frozen''.');
root=paper_root();frozen=fullfile(root,'results','frozen','FINAL_RESULTS.mat');
useFrozen=strcmpi(source,'frozen');
switch kind
 case 'single'
  f=fullfile(root,'results','single_run','SINGLE_RUN_RESULTS.mat');
  if ~useFrozen&&exist(f,'file')==2,s=load(f,'R');src=f;else,s=load(frozen,'R');src=frozen;end
  R=s.R;
 case 'frontier'
  f=fullfile(root,'results','frontier','FRONTIER_RESULTS.mat');
  if ~useFrozen&&exist(f,'file')==2
   s=load(f,'F');R=s.F;src=f;
  else
   s=load(frozen,'R');Z=s.R;fr=Z.frontier;src=frozen;
   R=struct('g',[fr.g]','risk',[fr.risk]','GP',[fr.GP]','GW',[fr.GW]','gmax',Z.gmax,...
    'gpos',Z.gpos,'sysRisk',Z.policies.SYS.risk,'Omega',sum(Z.pub.omega));
  end
 otherwise
  error('Unknown result kind %s.',kind);
end
fprintf('Plot data: %s\n',src);
end
