function [handle,privateExporter]=r40_owner(m,pub,l0,g,seed,cfg,ownerID)
% 处理各网络的本地定价和方案恢复。
P=r40_lp('raw',m);P=r40_lp('append',P,m.L,-l0,[],0,-g,pub);store={};calls=0;
handle=@dispatch;privateExporter=@recover;
 function out=dispatch(action,arg)
  if nargin<2,arg=struct;end
  switch action
   case 'initial'
    if ~isempty(seed)&&r40_lp('localcheck',m,seed,pub,l0,g)<=cfg.feasTol
     out=add(seed);return;
    end
    T=P;T.c(:)=0;T.c(1:m.n)=m.L'*pub.p0(:);
    rr=r40_lp('solve',T,cfg,sprintf('owner%d_initial',ownerID));
    assert(strcmp(rr.status,'OPTIMAL'),'R40:OwnerInitial','Local initialization %s.',rr.status);
    out=add(rr.x(1:m.n));
   case 'price'
    assert(isequal(sort(fieldnames(arg)),sort({'lambda';'price';'remainingSeconds'})));
    assert(numel(arg.lambda)==pub.K&&numel(arg.price)==pub.S);
    T=P;T.c(:)=0;T.c(1:m.n)=m.Q'*arg.lambda(:)+m.L'*arg.price(:);
    c=cfg;c.remainingSeconds=arg.remainingSeconds;calls=calls+1;
    rr=r40_lp('solve',T,c,sprintf('owner%d_price_%05d',ownerID,calls));
    if ~strcmp(rr.status,'OPTIMAL'),error('R40:PricingIncomplete','%s',rr.status);end
    out=add(rr.x(1:m.n));out.value=rr.dualValue;out.primalValue=rr.fval;out.seconds=rr.seconds;
   case 'recover'
    w=recover(arg);r=r40_lp('localcheck',m,w,pub,l0,g);
    out=struct('status','OK','q',m.Q*w,'ell',m.L*w,'residual',r);
   otherwise,error('R40:Protocol','Unknown owner message.');
  end
 end
 function c=add(w)
  w=w(:);assert(r40_lp('localcheck',m,w,pub,l0,g)<=cfg.feasTol,'Invalid local column.');
  store{end+1}=w;c=struct('id',numel(store),'q',m.Q*w,'ell',m.L*w);
 end
 function w=recover(req)
  assert(numel(req.ids)==numel(req.weights)&&abs(sum(req.weights)-1)<=cfg.feasTol);
  assert(all(req.weights>=-cfg.feasTol));w=zeros(m.n,1);
  for j=1:numel(req.ids),w=w+req.weights(j)*store{req.ids(j)};end
 end
end
