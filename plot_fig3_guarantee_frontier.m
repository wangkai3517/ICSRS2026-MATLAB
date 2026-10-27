function files=plot_fig3_guarantee_frontier(F,outDir)
% 绘制共同保障下限与系统韧性的关系。
here=fileparts(mfilename('fullpath'));addpath(fullfile(here,'lib'));
if nargin<1||isempty(F),F='auto';end
if ischar(F)||isstring(F),F=paper_load_results('frontier',char(F));end
if nargin<2,outDir=[];end
S=paper_style();Om=F.Omega;
[g,ord]=sort(F.g(:));risk=F.risk(:);risk=risk(ord);
x=100*g;y=100*(1-risk/Om);sysR=100*(1-F.sysRisk/Om);
isPos=abs(g-F.gpos)<1e-12;
fig=paper_figure(3.42,2.47);
ax=axes(fig,'Position',[0.165 0.185 0.80 0.775]);hold(ax,'on');
yl=[floor((min(y)-0.03)*20)/20,ceil((max([y;sysR])+0.05)*20)/20];
xl=[-0.05,max(x)+0.12];
for v=ceil(yl(1)*10)/10:0.1:yl(2),plot(ax,xl,[v v],'-','Color',S.grid,'LineWidth',0.5);end
plot(ax,xl,[sysR sysR],'--','Color',S.dash,'LineWidth',0.85);
text(ax,xl(2)-0.02,sysR+0.025,'DRO','Color',S.muted,'FontSize',S.fsSmall,'FontName',S.font,...
 'HorizontalAlignment','right');
plot(ax,x,y,'-','Color',S.teal,'LineWidth',1.2);
plot(ax,x(~isPos),y(~isPos),'o','MarkerSize',4.5,'MarkerFaceColor','w','MarkerEdgeColor',S.teal,'LineWidth',1.0);
if any(isPos)
 xp=x(isPos);yp=y(isPos);
 plot(ax,[xp xp+0.20],[yp yp-0.06],'-','Color',S.orange,'LineWidth',0.6);
 plot(ax,xp,yp,'d','MarkerSize',6,'MarkerFaceColor',S.orange,'MarkerEdgeColor',S.orange);
 text(ax,xp+0.22,yp-0.07,'IR_+','Color',S.orange,'FontSize',S.fsSmall,'FontName',S.font);
end
xt=0:0.2:max(x)+0.05;yt=ceil(yl(1)*10)/10:0.1:yl(2)+1e-9;
xlim(ax,xl);ylim(ax,yl);
set(ax,'XTick',xt,'XTickLabel',cellstr(compose('%.1f',xt)),'YTick',yt,'YTickLabel',cellstr(compose('%.1f',yt)));
paper_axes(ax,S);
xlabel(ax,'Common resilience-improvement floor (pp)','Color',S.text);
ylabel(ax,'Worst-case expected resilience (%)','Color',S.text);
files=paper_export(fig,'fig3_guarantee_frontier',outDir);
end
