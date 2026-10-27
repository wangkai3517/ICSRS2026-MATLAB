function files=plot_fig4_protection_changes(R,outDir,nTop)
% 绘制 IR+ 相对基本 DRO 的保护水平变化。
here=fileparts(mfilename('fullpath'));addpath(fullfile(here,'lib'));
if nargin<1||isempty(R),R='auto';end
if ischar(R)||isstring(R),R=paper_load_results('single',char(R));end
if nargin<2,outDir=[];end
if nargin<3,nTop=12;end
S=paper_style();nets=R.data.networks;pre={'P','W'};
D=100*(R.policies.IRpos.protection-R.policies.SYS.protection);
nA=size(D,1);labels=cell(nA,2);
for m=1:2
 for a=1:nA
  if a<=20
   labels{a,m}=sprintf('%s%d',pre{m},a);
  else
   e=double(nets(m).edges(a-20,:));
   labels{a,m}=sprintf('%s%d%s%s%d',pre{m},e(1),char(8211),pre{m},e(2));
  end
 end
end
v=D(:);lab=labels(:);[~,ord]=sort(abs(v),'descend');k=ord(1:nTop);v=v(k);lab=lab(k);
y=(nTop:-1:1)';
fig=paper_figure(3.43,3.16);
ax=axes(fig,'Position',[0.20 0.155 0.75 0.81]);hold(ax,'on');
xl=[min([v;0])-7,max([v;0])+6];yl=[0.4 nTop+0.6];
for t=ceil(xl(1)/10)*10:10:xl(2),plot(ax,[t t],yl,'-','Color',S.grid,'LineWidth',0.5);end
for i=1:nTop
 if v(i)>0,c=S.teal;else,c=S.neg;end
 patch(ax,[0 v(i) v(i) 0],y(i)+[-1 -1 1 1]*0.33,c,'EdgeColor','none');
 if v(i)>0
  text(ax,v(i)+0.6,y(i),sprintf('+%.1f',v(i)),'FontSize',S.fsSmall,'FontName',S.font,'Color',S.text,...
   'HorizontalAlignment','left','VerticalAlignment','middle');
 else
  text(ax,v(i)-0.6,y(i),[char(8722) sprintf('%.1f',-v(i))],'FontSize',S.fsSmall,'FontName',S.font,...
   'Color',S.text,'HorizontalAlignment','right','VerticalAlignment','middle');
 end
end
plot(ax,[0 0],yl,'-','Color',S.axis,'LineWidth',0.6);
xt=ceil(xl(1)/10)*10:10:xl(2);
set(ax,'XTick',xt,'XTickLabel',arrayfun(@signedInt,xt,'UniformOutput',false),...
 'YTick',1:nTop,'YTickLabel',lab(nTop:-1:1));
xlim(ax,xl);ylim(ax,yl);paper_axes(ax,S);
xlabel(ax,'Change in protection level (pp)','Color',S.text);
files=paper_export(fig,'fig4_protection_changes',outDir);
end

function s=signedInt(v)
if v<0,s=[char(8722) sprintf('%d',-v)];else,s=sprintf('%d',v);end
end
