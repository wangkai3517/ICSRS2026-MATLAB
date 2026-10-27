function S=paper_style()
% 设置绘图字体、配色和字号。
hex=@(h) sscanf(h(2:end),'%2x%2x%2x',[1 3])/255;
S.font='Times New Roman';
S.blue=hex('#2b5e86');
S.teal=hex('#268b7b');
S.orange=hex('#bd8435');
S.text=hex('#223542');
S.axis=hex('#394651');
S.muted=hex('#7e8c98');
S.dash=hex('#6c7883');
S.light=hex('#cad3da');
S.connector=hex('#ccd6de');
S.grid=hex('#e6ebef');
S.neg=hex('#9aa8b3');
S.fs=7.5;S.fsSmall=6.6;S.fsTitle=8;
end
