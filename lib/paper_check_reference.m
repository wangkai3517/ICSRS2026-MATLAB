function ok=paper_check_reference(C,name,fval)
% 将目标值与冻结结果比对。
f=fullfile(C.root,'inputs',['RED40_' name '_reduced.mat']);ok=true;
if exist(f,'file')~=2,return;end
s=load(f,'result');ref=s.result.objective;err=abs(fval-ref);
ok=err<=1e-6*(1+abs(ref));
if ok
 fprintf('  %-6s objective %.12f  matches frozen run (diff %.1e)\n',name,fval,err);
else
 warning('R40:Reference','%s objective %.12f differs from frozen %.12f.',name,fval,ref);
end
end
