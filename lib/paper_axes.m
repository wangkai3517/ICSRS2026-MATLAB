function paper_axes(ax,S)
% 设置坐标轴样式。
set(ax,'FontName',S.font,'FontSize',S.fs,'XColor',S.axis,'YColor',S.axis,'LineWidth',0.6,...
 'TickDir','out','TickLength',[0.012 0.012],'Box','off','Layer','top','Color','none');
end
