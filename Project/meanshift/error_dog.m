load dogtruth_rectspace.txt
correct = dogtruth_rectspace;
[m,n]=size(correct);
c = zeros(m,2);
c(:,1) = correct(:,1) + correct(:,3)/2;
c(:,2) = correct(:,2) + correct(:,4)/2;

s = zeros(m,2);

load tic_x_dog.mat
load tic_y_dog.mat
s(:,1)= tic_x_dog(2:m+1,1);
s(:,2)= tic_y_dog(2:m+1,1);

error=zeros(1,m);
error = sqrt  (   (c(:,1)-s(:,1)).^2 + (c(:,2)- s(:,2)).^2   ) ;
i=1:m;
plot(i,error);
axis([0,127,0,60]);
