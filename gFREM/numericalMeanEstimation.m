function I=numericalMeanEstimation(x,f1,f2, offset, nphot)
% I=numericalMeanEstimation(x,f1,f2, offset, nphot)

if ~exist('offset','var')
    offset=0;
end
if ~exist('nphot','var')
    nphot=1;
end
l(:,1)=nphot*f1;
l(:,2)=nphot*f2;
l(:,3)=nphot*(f1+f2);
l(:,4)=zeros(length(f1),1);
lstrong=l+offset;
N=size(l,2);
dx=x(2)-x(1);

prec=10^-10; 
pcdf=poisscdf(0:50*max(lstrong(:)),max(lstrong(:)));
nmax = sum(pcdf<1-prec);

n=0:nmax;
ln=length(n);
lf=length(f1);
nmat = repmat(n',1,lf);

r=zeros(ln,lf,N);
Po=zeros(ln,lf,N);
dlsmat=zeros(ln,lf,N);
for jj=1:N
    lsmat = repmat(lstrong(:,jj)',ln,1);
    dlsmat(:,:,jj)= repmat(gradient(lstrong(:,jj),dx)',ln,1);
    r(:,:,jj)=(nmat-lsmat)./lsmat;
    Po(:,:,jj)=poissonpdfmulti(n,lstrong(:,jj));
end
% Po(:,:,4)=zeros(ln,lf);
rPo=Po.*r;
% [q,rPo]=gradient(Po);
% % % I(1,1)=sum(sum(dlsmat(:,:,1).^2.*(sum(rPo(:,:,[1,3,4]),3)).^2./sum(Po,3)));
% % % I(2,2)=sum(sum(dlsmat(:,:,2).^2.*(sum(rPo(:,:,[2,3,4]),3)).^2./sum(Po,3)));
% % % I(1,2)=sum(sum(dlsmat(:,:,1).*dlsmat(:,:,2).*sum(rPo(:,:,[1,3,4]),3).*sum
% (rPo(:,:,[2,3,4]),3)./sum(Po,3)));

% This one seems to work:
% % % I(1,1)=sum(sum(dlsmat(:,:,1).^2.*sum(rPo(:,:,[1,3]),3).^2./sum(Po,3)));
% % % I(2,2)=sum(sum(dlsmat(:,:,2).^2.*sum(rPo(:,:,[2,3]),3).^2./sum(Po,3)));
% % % I(1,2)=sum(sum(dlsmat(:,:,1).*dlsmat(:,:,2).*sum(rPo(:,:,[1,3]),3).*sum(rPo(:,:,[2,3]),3)./sum(Po,3)));
% % % I(2,1)=I(1,2);

% mask=sum(Po,3)>eps;
sPo=sum(Po(:,:,1:3),3);


It11=dlsmat(:,:,1).^2.*sum(rPo(:,:,[1,3]),3).^2;
It22=dlsmat(:,:,2).^2.*sum(rPo(:,:,[2,3]),3).^2;
It12=dlsmat(:,:,1).*dlsmat(:,:,2).*sum(rPo(:,:,[1,3]),3).*sum(rPo(:,:,[2,3]),3);

% Itmp=zeros(ln,lf);
% for ii=1:ln
%     for jj=1:lf
%         if mask(ii,jj)
%             Itmp(ii,jj)=It11(ii,jj)./(2*Po(ii,jj,1));            
%         end
%     end
% end

mask = It11>10^-8;
I(1,1)=1/4*dx*trapz(It11(mask)./sPo(mask));
mask = It22>10^-8;
I(2,2)=1/4*dx*trapz(It22(mask)./sPo(mask));
mask = It12>eps;
I(1,2)=1/4*dx*trapz(It12(mask)./sPo(mask));
I(2,1)=I(1,2);

% I(1,1)=1/4*dx*sum(It11(mask)./sPo(mask));
% I(2,2)=1/4*dx*sum(It22(mask)./sPo(mask));
% I(1,2)=1/4*dx*sum(It12(mask)./sPo(mask));
% I(2,1)=I(1,2);

% dPo = gradient(Po,dx);
% I(1,1)=sum(sum((sum(dPo(:,:,[1,3]),3).*dlsmat(:,:,1)).^2./sum(Po,3)));
% I(2,2)=sum(sum((sum(dPo(:,:,[2,3]),3).*dlsmat(:,:,2)).^2./sum(Po,3)));
% I(1,2)=sum(sum(sum(dPo(:,:,[1,3]),3).*dlsmat(:,:,1).*sum(dPo(:,:,[2,3]),3).*dlsmat(:,:,2)./sum(Po,3)));
% I(2,1)=I(1,2);