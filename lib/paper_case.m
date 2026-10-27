function C=paper_case(root)
% 读取并校验 RED40 算例。
if nargin<1,root=paper_root();end
input=fullfile(root,'inputs','MODEL_RED40.mat');s=load(input);
models=s.models;if ~iscell(models),models=num2cell(models);end
C=struct('root',root,'models',{models},'pub',s.pub,'L0',s.L0,'data',s.data,...
 'baseline',{s.plans},'gpos',0.0031334077181093775);
assert(C.pub.S==40&&C.pub.K==120&&numel(models)==2,'R40:WrongCase','RED40 case required.');
expected=jsondecode(fileread(fullfile(root,'inputs','FROZEN_IDENTITY.json')));
assert(strcmpi(sha256(input),expected.model_sha256),'R40:Identity','MODEL_RED40.mat has changed.');
ids=double(s.data.scenario_generation.representative_raw_ids(:));
assert(isequal(ids,expected.representative_ids(:)),'R40:Identity','Scenario order changed.');
assert(abs(sum(C.pub.p0)-1)<1e-10&&C.pub.rho==.3,'R40:Identity','Unexpected reference probabilities or radius.');
end

function h=sha256(file)
f=fopen(file,'rb');assert(f>=0);c=onCleanup(@()fclose(f));b=fread(f,Inf,'*uint8');
md=java.security.MessageDigest.getInstance('SHA-256');md.update(b);
h=lower(reshape(dec2hex(typecast(md.digest(),'uint8'),2)',1,[]));
end
