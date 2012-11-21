function p=gkdeb(x,p)
% GKDEB  Gaussian Kernel Density Estimation with Bounded Support
% 
% Usage:
% p = gkdeb(d) returns an estmate of pdf of the given random data d in p,
%             where p.f and p.F are the pdf and cdf vectors estimated at
%             p.x locations, respectively and p.h is the bandwidth used for
%             the estimation. 
% p = gkdeb(d,p) specifies optional parameters for the estimation:
%             p.h - bandwidth
%             p.x - locations to make estimation
%             p.uB - upper bound
%             p.lB - lower bound.
%
% Without output, gkdeb(d) and gkdeb(d,p) will disply the pdf and cdf
% (cumulative distribution function) plot.  
%
% See also: hist, histc, ksdensity, ecdf, cdfplot, ecdfhist

% Example 1: Normal distribution
%{
gkdeb(randn(1e4,1));
%}
% Example 2: Uniform distribution
%{
clear p
p.uB=1;
p.lB=0;
gkdeb(rand(1e3,1),p);
%}
% Example 3: Exponential distribution
%{
clear p
p.lB=0;
gkdeb(-log(1-rand(1,1000)),p);
%}
% Example 4: Rayleigh distribution
%{
clear p
p.lB=0;
gkdeb(sqrt(randn(1,1000).^2 + randn(1,1000).^2),p);
%}

% V2.3 by Yi Cao at Cranfield University on 13th April 2008
%

% Check input and output
error(nargchk(1,2,nargin));
error(nargoutchk(0,1,nargout));

n=length(x);
% Default parameters
if nargin<2
    N=100;
    h=median(abs(x-median(x)))/0.6745*(4/3/n)^0.2;
    xmax=max(x);
    xmin=min(x);
    xmax=xmax+3*h;
    xmin=xmin-3*h;
    %xmax = 1;
    %xmin = -1;
    dx=(xmax-xmin)/(N-1);
    p.x=xmin+(0:N-1)*dx;
    p.f=zeros(1,N);
    p.h=h;
    dxdz=ones(size(x));
    z=p.x;
else
    [p,x,dxdz,z]=checkp(x,p);
    N=numel(p.x);
    h=p.h;
end

% Gaussian kernel function
kerf=@(z)exp(-z.*z/2);
nh=n*h*sqrt(2*pi);

for k=1:N
    p.f(k)=sum(kerf((p.x(k)-x)/h).*dxdz);
end
p.x=z;
p.f=p.f/nh;
dx=[0 diff(p.x)];
p.F=cumsum(p.f.*dx);

% Plot
if ~nargout
    subplot(211)
    plot(p.x,p.f,'linewidth',2)
    grid
%     set(gca,'ylim',[0 max(p.f)*1.1])
    ylabel('f(x)')
    title('Estimated Probability Density Function');
    subplot(212)
    plot(p.x,p.F,'linewidth',2)
    ylabel('F(x)')
    title('Cumulative Distribution Function')
    xlabel('x')
    grid
    meanx = sum(p.x.*p.f.*dx);
    varx = sum((p.x-meanx).^2.*p.f.*dx);
    text(min(p.x),0.6,sprintf('mean(x) = %g\n var(x) = %g\n',meanx,varx)) 
end

function [p,x,dxdz,z]=checkp(x,p)
%check structure p
if ~isstruct(p)
    error('p is not a structure.');
end
n=numel(x);
if ~isfield(p,'uB')
    p.uB=Inf;
end
if ~isfield(p,'lB')
    p.lB=-Inf;
end
if p.lB>-Inf || p.uB<Inf
    [p,x,dxdz,z]=bounded(x,p);
end
if ~isfield(p,'h')
    p.h=median(abs(x-median(x)))/0.6745*(4/3/n)^0.2;
end
error(varchk(eps, inf, p.h, 'Bandwidth, p.h is not positive.'));
if ~isfield(p,'x')
    N=100;
    xmax=max(x);
    xmin=min(x);
    xmax=xmax+3*h;
    xmin=xmin-3*h;
    dx=(xmax-xmin)/(N-1);
    p.x=xmin+(0:N-1)*dx;
    dxdz=ones(size(x));
    z=p.x;
    return
end
p.f=zeros(size(p.x));


function [p,x,dxdz,z]=bounded(x,p)
if p.lB==-Inf
    dxdz=1./(p.uB-x);
    y=@(t)-log(p.uB-t);
    zf=@(t)(p.uB-exp(-t));
elseif p.uB==Inf
    dxdz=1./(x-p.lB);
    y=@(t)log(t-p.lB);
    zf=@(t)exp(t)+p.lB;
else
    dxdz=(p.uB-p.lB)./(x-p.lB)./(p.uB-x);
    y=@(t)log((t-p.lB)./(p.uB-t));
    zf=@(t)(exp(t)*p.uB+p.lB)./(exp(t)+1);
end
x=y(x);
n=numel(x);
if ~isfield(p,'h')
    p.h=median(abs(x-median(x)))/0.6745*(4/3/n)^0.2;
end
h=p.h;
if ~isfield(p,'x')
    N=100;
    xmax=max(x);
    xmin=min(x);
    xmax=xmax+3*h;
    xmin=xmin-3*h;
    p.x=xmin+(0:N-1)*(xmax-xmin)/(N-1);
    z=zf(p.x);
else
    z=p.x;
    p.x=y(p.x);
end

function msg=varchk(low,high,n,msg)
% check if variable n is not between low and high, returns msg, otherwise
% empty matrix
if n>=low && n<=high
    msg=[];
end

