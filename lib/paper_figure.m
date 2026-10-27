function fig=paper_figure(w,h)
% 创建指定尺寸的图窗。
vis='on';if batchStartupOptionUsed,vis='off';end
fig=figure('Visible',vis,'Color','w','Units','inches','Position',[0.5 0.5 w h]);
if strcmp(vis,'on'),movegui(fig,'center');end
end
