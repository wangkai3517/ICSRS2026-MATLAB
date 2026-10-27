function files=plot_fig1_network(R,outDir)
% 绘制电水网络和 IR+ 保护配置。
here=fileparts(mfilename('fullpath'));addpath(fullfile(here,'lib'));
if nargin<1||isempty(R),R='auto';end
if ischar(R)||isstring(R),R=paper_load_results('single',char(R));end
if nargin<2,outDir=[];end
S=paper_style();
nets=R.data.networks;
X=R.policies.IRpos.protection;
fig=paper_figure(6.43,3.31);
names={'Power network','Water network'};tags={'a','b'};pre={'P','W'};cols={S.blue,S.teal};
pos={[0.010 0.215 0.375 0.635],[0.615 0.215 0.375 0.635]};
ylims=[-0.10 1.12];

for m=1:2
 ax=axes(fig,'Position',pos{m});hold(ax,'on');
 net=nets(m);xy=paper_grid_coords(double(net.coords));col=cols{m};
 xn=min(max(X(1:20,m),0),1);xe=min(max(X(21:end,m),0),1);E=double(net.edges);
 [~,ord]=sort(xe);
 for k=ord(:)'
  t=xe(k);c=(1-t)*S.light+t*col;
  paper_arrow(ax,xy(E(k,1),:),xy(E(k,2),:),c,0.55+1.5*t,0.042);
 end
 cn=double(net.coupling_nodes(:));
 plot(ax,xy(cn,1),xy(cn,2),'o','MarkerSize',11,'MarkerEdgeColor',S.orange,...
  'MarkerFaceColor','none','LineWidth',1.1);
 src=double(net.sources(:));dem=find(net.demand(:)>0);
 for i=1:20
  fc=(1-xn(i))*[1 1 1]+xn(i)*col;
  if ismember(i,src),mk='s';elseif ismember(i,dem),mk='^';else,mk='o';end
  plot(ax,xy(i,1),xy(i,2),mk,'MarkerSize',6,'MarkerFaceColor',fc,'MarkerEdgeColor',S.axis,'LineWidth',0.6);
  text(ax,xy(i,1)-0.03,xy(i,2)+0.075,sprintf('%s%d',pre{m},i),'FontName',S.font,'FontSize',6.5,...
   'Color',S.text,'HorizontalAlignment','center');
 end
 axis(ax,'equal');xlim(ax,[-0.09 1.09]);ylim(ax,ylims);axis(ax,'off');
 text(ax,-0.09,1.22,['\bf' tags{m} '  ' names{m}],'FontName',S.font,'FontSize',S.fsTitle,'Color',S.text);
 cax=axes(fig,'Position',[pos{m}(1)+0.075 0.105 pos{m}(3)-0.15 0.028]);
 cmap=[linspace(1,col(1),256)',linspace(1,col(2),256)',linspace(1,col(3),256)'];
 imagesc(cax,[0 100],[0 1],linspace(0,100,256));colormap(cax,cmap);
 set(cax,'YTick',[],'XTick',[0 50 100],'TickDir','out','FontName',S.font,'FontSize',6.5,...
  'XColor',S.axis,'YColor',S.axis,'LineWidth',0.5,'Box','on');
 xlabel(cax,'Protection level (%)','FontSize',6.5,'Color',S.text);
end

axM=axes(fig,'Position',[0.395 0.215 0.21 0.635]);hold(axM,'on');
xlim(axM,[0 1]);ylim(axM,ylims);axis(axM,'off');
text(axM,0.5,0.98,{'Pump power-supply','interfaces'},'HorizontalAlignment','center',...
 'FontName',S.font,'FontSize',7.5,'FontWeight','bold','Color',S.orange);
cp=R.data.coupling;ys=linspace(0.74,0.30,numel(cp));
for k=1:numel(cp)
 y=ys(k);
 text(axM,0.08,y,sprintf('P%d',cp(k).power_node),'FontName',S.font,'FontSize',7,'Color',S.text,...
  'HorizontalAlignment','center');
 text(axM,0.92,y,sprintf('W%d',cp(k).water_node),'FontName',S.font,'FontSize',7,'Color',S.text,...
  'HorizontalAlignment','center');
 plot(axM,[0.20 0.76],[y y],'--','Color',S.orange,'LineWidth',1.0);
 patch(axM,[0.80 0.75 0.75],[y y+0.022 y-0.022],S.orange,'EdgeColor','none');
end

lax=axes(fig,'Position',[0 0.92 1 0.06],'Visible','off');hold(lax,'on');
h=gobjects(1,3);mks={'s','^','o'};
for k=1:3
 h(k)=plot(lax,NaN,NaN,mks{k},'MarkerSize',6,'MarkerFaceColor','w','MarkerEdgeColor',S.axis,'LineWidth',0.6);
end
lg=legend(lax,h,{'Source','Terminal demand','Transit'},'Orientation','horizontal','Box','off',...
 'FontName',S.font,'FontSize',7,'TextColor',S.text);
lg.ItemTokenSize=[12,12];lg.Position=[0.33 0.925 0.34 0.05];

files=paper_export(fig,'fig1_network',outDir);
end
