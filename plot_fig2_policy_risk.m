function files=plot_fig2_policy_risk(R,outDir)
% 绘制各方案的系统韧性和两网改善。
here=fileparts(mfilename('fullpath'));addpath(fullfile(here,'lib'));
if nargin<1||isempty(R),R='auto';end
if ischar(R)||isstring(R),R=paper_load_results('single',char(R));end
if nargin<2,outDir=[];end
S=paper_style();
names={'Baseline','SP','SYS','IR0','IRpos'};lab={'Baseline','SP','DRO','IR_0','IR_+'};
n=numel(names);Om=sum(R.pub.omega);Rref=zeros(1,n);Rwc=Rref;GP=Rref;GW=Rref;
for i=1:n
 p=R.policies.(names{i});
 Rref(i)=100*(1-p.nominal/Om);Rwc(i)=100*(1-p.risk/Om);GP(i)=100*p.GP;GW(i)=100*p.GW;
end
GP(abs(GP)<5e-4)=0;GW(abs(GW)<5e-4)=0;
y=n:-1:1;yl=[0.45 n+0.55];
fig=paper_figure(6.75,3.40);

axA=axes(fig,'Position',[0.075 0.315 0.39 0.565]);hold(axA,'on');
xg=75:5:95;
for v=xg,plot(axA,[v v],yl,'-','Color',S.grid,'LineWidth',0.5);end
for i=1:n,plot(axA,[Rwc(i) Rref(i)],[y(i) y(i)],'-','Color',S.connector,'LineWidth',2.7);end
hW=plot(axA,Rwc,y,'o','MarkerSize',5.5,'MarkerFaceColor',S.blue,'MarkerEdgeColor',S.blue);
hR=plot(axA,Rref,y,'o','MarkerSize',5.5,'MarkerFaceColor','w','MarkerEdgeColor',S.muted,'LineWidth',1.0);
for i=1:n
 text(axA,Rwc(i),y(i)-0.32,sprintf('%.3f',Rwc(i)),'Color',S.blue,'FontSize',S.fsSmall,...
  'FontName',S.font,'HorizontalAlignment','center');
 text(axA,Rref(i),y(i)+0.32,sprintf('%.3f',Rref(i)),'Color',S.muted,'FontSize',S.fsSmall,...
  'FontName',S.font,'HorizontalAlignment','center');
end
xlim(axA,[73 97]);ylim(axA,yl);
set(axA,'XTick',xg,'YTick',1:n,'YTickLabel',lab(n:-1:1));paper_axes(axA,S);
xlabel(axA,'System resilience (%)','Color',S.text);
text(axA,0,1.07,'\bfa  Two probabilistic evaluations of each policy','Units','normalized',...
 'FontName',S.font,'FontSize',S.fsTitle,'Color',S.text);
lgA=legend(axA,[hW hR],{'Worst-case expected resilience','Reference expected resilience'},...
 'Box','off','FontName',S.font,'FontSize',S.fsSmall,'TextColor',S.text);
lgA.ItemTokenSize=[12,12];lgA.Position=[0.12 0.025 0.30 0.10];

axB=axes(fig,'Position',[0.585 0.315 0.395 0.565]);hold(axB,'on');
xg=-2:1:2;
for v=xg,plot(axB,[v v],yl,'-','Color',S.grid,'LineWidth',0.5);end
plot(axB,[0 0],yl,'--','Color',S.dash,'LineWidth',0.8);
hh=0.30;d=0.17;hP=gobjects(1);hQ=gobjects(1);
for i=1:n
 hP=patch(axB,[0 GP(i) GP(i) 0],y(i)+d+[-1 -1 1 1]*hh/2,S.blue,'EdgeColor','none');
 hQ=patch(axB,[0 GW(i) GW(i) 0],y(i)-d+[-1 -1 1 1]*hh/2,S.teal,'EdgeColor','none');
 valueLabel(axB,GP(i),y(i)+d,S.blue,S);valueLabel(axB,GW(i),y(i)-d,S.teal,S);
end
xlim(axB,[-2.45 2.45]);ylim(axB,yl);
set(axB,'XTick',xg,'XTickLabel',arrayfun(@signedInt,xg,'UniformOutput',false),...
 'YTick',1:n,'YTickLabel',lab(n:-1:1));
paper_axes(axB,S);
xlabel(axB,'Minimum expected resilience improvement (pp)','Color',S.text);
text(axB,0,1.07,'\bfb  System optimality does not ensure network-wise gains','Units','normalized',...
 'FontName',S.font,'FontSize',S.fsTitle,'Color',S.text);
lgB=legend(axB,[hP hQ],{'Power network','Water network'},'Orientation','horizontal','Box','off',...
 'FontName',S.font,'FontSize',S.fsSmall,'TextColor',S.text);
lgB.ItemTokenSize=[16,8];lgB.Position=[0.66 0.05 0.25 0.05];

files=paper_export(fig,'fig2_policy_risk',outDir);
end

function valueLabel(ax,v,y,c,S)
if v>=0
 text(ax,v+0.06,y,sprintf('%.3f',v),'Color',c,'FontSize',S.fsSmall,'FontName',S.font,...
  'HorizontalAlignment','left','VerticalAlignment','middle');
else
 text(ax,v-0.06,y,[char(8722) sprintf('%.3f',-v)],'Color',c,'FontSize',S.fsSmall,'FontName',S.font,...
  'HorizontalAlignment','right','VerticalAlignment','middle');
end
end

function s=signedInt(v)
if v<0,s=[char(8722) sprintf('%d',-v)];else,s=sprintf('%d',v);end
end
