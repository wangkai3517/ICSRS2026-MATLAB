function paper_arrow(ax,p,q,c,lw,head,gap,style)
% 绘制网络中的有向链路。
if nargin<7,gap=0.042;end
if nargin<8,style='-';end
d=q-p;L=norm(d);if L<1e-9,return;end
u=d/L;n=[-u(2),u(1)];s=p+gap*u;t=q-gap*u;base=t-head*u;
plot(ax,[s(1),base(1)],[s(2),base(2)],style,'Color',c,'LineWidth',lw);
w=0.42*head+0.004*lw;
patch(ax,[t(1),base(1)+w*n(1),base(1)-w*n(1)],[t(2),base(2)+w*n(2),base(2)-w*n(2)],c,'EdgeColor','none');
end
