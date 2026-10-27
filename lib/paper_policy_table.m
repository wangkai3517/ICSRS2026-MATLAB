function T=paper_policy_table(R,basePath)
% 生成表 II，导出 CSV 和 LaTeX。
names={'Baseline','SP','SYS','IR0','IRpos'};
labels={'Baseline','SP','Basic DRO','IR$_0$','IR$_+$'};
Om=sum(R.pub.omega);n=numel(names);V=zeros(n,4);
for i=1:n
 p=R.policies.(names{i});
 V(i,:)=[100*(1-p.nominal/Om),100*(1-p.risk/Om),100*p.GP,100*p.GW];
end
V=round(V*1000)/1000;V(V==0)=0;
T=array2table(V,'VariableNames',{'Rref_percent','Rwc_percent','GP_pp','GW_pp'});
T.Policy={'Baseline';'SP';'Basic DRO';'IR0';'IR+'};T=movevars(T,'Policy','Before',1);
if nargin<2,return;end
writetable(T,[basePath '.csv']);
f=fopen([basePath '.tex'],'w','n','UTF-8');assert(f>=0);c=onCleanup(@()fclose(f));
fprintf(f,'%s\n','\begin{tabular}{lrrrr}\toprule');
fprintf(f,'%s\n','Policy&$R_{\rm ref}$ (\%)&$R_{\rm wc}$ (\%)&$100G_P$&$100G_W$\\\midrule');
for i=1:n
 fprintf(f,'%s&%s&%s&%s&%s\\\\\n',labels{i},paper_tex_num(V(i,1)),paper_tex_num(V(i,2)),...
  paper_tex_num(V(i,3)),paper_tex_num(V(i,4)));
end
fprintf(f,'%s\n','\bottomrule\end{tabular}');
fprintf(f,'%s\n','\par\smallskip\parbox{.97\columnwidth}{\scriptsize Note: $R_{\rm ref}$ and $R_{\rm wc}$ are percentages; $100G_P$ and $100G_W$ are in percentage points.}');
end
