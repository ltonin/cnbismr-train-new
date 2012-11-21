function RotMat = unbias_findRot(w)

N = length(w);
R = zeros(N);

R(1,:) = w;
R(2,1) = -w(2)/w(1);
R(2,2) = 1;

for dim = 3:N
    A = zeros(dim-1);
    A(1,:) = w(1:dim-1);
    for j=2:dim-1
        A(j,:) = [R(j,1:j-1) 1 zeros(1,dim-j-1)];
    end
    b = [-w(dim) zeros(1,dim-2)]';
    R(dim,1:dim-1) = inv(A)*b;
    R(dim,dim) = 1;
end

RotMat = zeros(size(R));
for i=1:size(R,1)
    RotMat(i,:) = R(i,:)/norm(R(i,:));
end
RotMat = inv(RotMat');
