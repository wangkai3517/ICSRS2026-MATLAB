function xy=paper_grid_coords(coords)
% 将节点坐标对齐到网格。
xy=[round(coords(:,1)*4)/4,round(coords(:,2)*3)/3];
end
