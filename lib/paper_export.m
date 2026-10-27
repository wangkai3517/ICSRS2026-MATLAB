function files=paper_export(fig,name,outDir,keepOpen)
% 导出 PDF 和 PNG 图片。
if nargin<3||isempty(outDir),outDir=fullfile(paper_root(),'figures');end
if nargin<4,keepOpen=strcmp(fig.Visible,'on');end
if ~exist(outDir,'dir'),mkdir(outDir);end
files={fullfile(outDir,[name '.pdf']),fullfile(outDir,[name '.png'])};
exportgraphics(fig,files{1},'ContentType','vector','BackgroundColor','white');
exportgraphics(fig,files{2},'Resolution',300,'BackgroundColor','white');
fprintf('Saved %s\n',files{1});
if ~keepOpen,close(fig);end
end
