function r40_selftest(cfg)
% 检查求解器对偶符号和风险计算。
c=cfg;c.lpSeconds=10;
P=struct('A',sparse(1),'b',1,'E',sparse(0,1),'e',zeros(0,1),'lb',0,'ub',Inf,'c',-1);
r=r40_lp('solve',P,c,'selftest_inequality');
assert(strcmp(r.status,'OPTIMAL')&&abs(r.x-1)<1e-7&&abs(r.mu-1)<1e-7,'Inequality dual sign test failed.');
P=struct('A',sparse(0,1),'b',zeros(0,1),'E',sparse(1),'e',2,'lb',-Inf,'ub',Inf,'c',1);
r=r40_lp('solve',P,c,'selftest_equality');
assert(strcmp(r.status,'OPTIMAL')&&abs(r.x-2)<1e-7&&abs(r.nu+1)<1e-7,'Equality dual sign test failed.');
pub=struct('S',3,'p0',[.5;.3;.2],'rho',.3);z=[.1;.4;.9];
P=struct('A',sparse(0,1),'b',zeros(0,1),'E',sparse(0,1),'e',zeros(0,1),'lb',0,'ub',Inf,'c',1);
P=r40_lp('append',P,sparse(3,1),z,1,-1,0,pub);r=r40_lp('solve',P,c,'selftest_risk_dual');
[v,p]=r40_lp('risk',z,pub.p0,pub.rho);
assert(abs(v-r.fval)<1e-7&&abs(sum(p)-1)<1e-12&&abs(v-.47)<1e-12,'L1 support-function test failed.');
fprintf('Solver self-test passed.\n');
end
