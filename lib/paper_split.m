function plans=paper_split(x,models,off)
% 将集中式解拆为各网络的方案。
plans=cell(1,numel(models));
for m=1:numel(models),plans{m}=x(off(m)+(1:models{m}.n));end
end
