function files=plot_fig5_dw_bounds(R,outDir)
% 绘制 IR+ 分解算法的上下界。
here=fileparts(mfilename('fullpath'));addpath(fullfile(here,'lib'));
if nargin<1||isempty(R),R='auto';end
if ischar(R)||isstring(R)
 R=paper_load_results('single',char(R));
 if ~hasHistory(R)
  fprintf('Program 1 results contain no IR+ decomposition; using the frozen run.\n');
  R=paper_load_results('single','frozen');
 end
end
if nargin<2,outDir=[];end
S=paper_style();
assert(hasHistory(R),'No IR+ decomposition history in these results; run main1_single_optimization with IRpos in runDW.');
h=R.dw.IRpos.history;h=h(h(:,1)==2,:);it=h(:,2);UB=h(:,3);LB=h(:,4);
fig=paper_figure(3.40,2.54);
ax=axes(fig,'Position',[0.165 0.18 0.80 0.78]);hold(ax,'on');
xl=[0,max(it)*1.04];yl=[0,max(UB)*1.03];yt=0:0.05:yl(2);
for v=yt,plot(ax,xl,[v v],'-','Color',S.grid,'LineWidth',0.5);end
hU=plot(ax,it,UB,'-','Color',S.blue,'LineWidth',1.35);
hL=plot(ax,it,LB,'--','Color',S.teal,'LineWidth',1.35);
xlim(ax,xl);ylim(ax,yl);
set(ax,'XTick',0:200:xl(2),'YTick',yt,'YTickLabel',cellstr(compose('%.2f',yt)));paper_axes(ax,S);
text(ax,0.97,0.95,'IR_+','Units','normalized','Color',S.blue,'FontSize',9,'FontName',S.font,...
 'HorizontalAlignment','right');
lg=legend(ax,[hU hL],{'Feasible upper bound','Valid lower bound'},'Location','southeast','Box','off',...
 'FontName',S.font,'FontSize',S.fsSmall,'TextColor',S.text);
lg.ItemTokenSize=[18,8];
xlabel(ax,'Resilience-optimization iteration','Color',S.text);
ylabel(ax,'Worst-case expected system loss','Color',S.text);
files=paper_export(fig,'fig5_dw_bounds',outDir);
end

function ok=hasHistory(R)
ok=isfield(R,'dw')&&isfield(R.dw,'IRpos')&&isfield(R.dw.IRpos,'history')&&~isempty(R.dw.IRpos.history);
end
