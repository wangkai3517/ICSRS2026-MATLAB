function s=paper_tex_num(v,digits)
% 格式化 LaTeX 表格中的数字。
if nargin<2,digits=3;end
v=round(v*10^digits)/10^digits;if v==0,v=0;end
s=sprintf(['%.' num2str(digits) 'f'],abs(v));
if v<0,s=['$-$' s];end
end
