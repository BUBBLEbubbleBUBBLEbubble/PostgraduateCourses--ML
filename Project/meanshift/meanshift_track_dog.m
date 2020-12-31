clc;
close all;
clear all;
%%%%%%%%%%%%%%%%%%����һ��Ŀ��ȫ�ɼ���ͼ��Ȧ������Ŀ��%%%%%%%%%%%%%%%%%%%%%%%
% I=imread(fullfile(pwd, 'Bird_img', '0001.jpg'));
I=imread(fullfile(pwd, 'Dog_img', '0001.jpg'));
% I=imread(fullfile(pwd, 'Panda_img', '0001.jpg'));
% figure(1);
% imshow(I);

% rect_init = [82 218 69 73]; %bird
rect_init = [74 86 56 48]; %dog

[temp,rect]=imcrop(I, rect_init);
% [temp,rect]=imcrop(I);
[a,b,c]=size(temp); 		%a:row,b:col

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����Ŀ��ͼ���Ȩֵ����%%%%%%%%%%%%%%%%%%%%%%%
y(1)=a/2;
y(2)=b/2;
tic_x=rect(1)+rect(3)/2;
tic_y=rect(2)+rect(4)/2;
m_wei=zeros(a,b);%Ȩֵ����
h=y(1)^2+y(2)^2 ;%����

for i=1:a
    for j=1:b
        dist=(i-y(1))^2+(j-y(2))^2;
        m_wei(i,j)=1-dist/h; %epanechnikov profile
    end
end
C=1/sum(sum(m_wei));%��һ��ϵ��


%����Ŀ��Ȩֱֵ��ͼqu
%hist1=C*wei_hist(temp,m_wei,a,b);%target model
hist1=zeros(1,4096);
for i=1:a
    for j=1:b
        %rgb��ɫ�ռ�����Ϊ16*16*16 bins
        q_r=fix(double(temp(i,j,1))/16);  %fixΪ����0ȡ������
        q_g=fix(double(temp(i,j,2))/16);
        q_b=fix(double(temp(i,j,3))/16);
        q_temp=q_r*256+q_g*16+q_b;            %����ÿ�����ص��ɫ����ɫ����ɫ������ռ����
        hist1(q_temp+1)= hist1(q_temp+1)+m_wei(i,j);    %����ֱ��ͼͳ����ÿ�����ص�ռ��Ȩ��
    end
end
hist1=hist1*C;
rect(3)=ceil(rect(3));
rect(4)=ceil(rect(4));

%%%%%%%%%%%%%%%%%%%%%%%%%��ȡ����ͼ��
% myfile=dir(fullfile(pwd, 'Bird_img\*.jpg'));
myfile=dir(fullfile(pwd, 'Dog_img\*.jpg'));
% myfile=dir(fullfile(pwd, 'Panda_img\*.jpg'));
lengthfile=length(myfile);


for l=1:lengthfile
%     Im=imread(fullfile(pwd, 'Bird_img', myfile(l).name));
    Im=imread(fullfile(pwd, 'Dog_img', myfile(l).name));
%     Im=imread(fullfile(pwd, 'Panda_img', myfile(l).name));
    num=0;
    Y=[2,2];
    
    
    %%%%%%%mean shift����
    while((Y(1)^2+Y(2)^2>0.5)&&num<20)   %��������
        num=num+1;
        temp1=imcrop(Im,rect);
        %�����ѡ����ֱ��ͼ
        %hist2=C*wei_hist(temp1,m_wei,a,b);%target candidates pu
        hist2=zeros(1,4096);
        for i=1:a
            for j=1:b
                q_r=fix(double(temp1(i,j,1))/16);
                q_g=fix(double(temp1(i,j,2))/16);
                q_b=fix(double(temp1(i,j,3))/16);
                q_temp1(i,j)=q_r*256+q_g*16+q_b;
                hist2(q_temp1(i,j)+1)= hist2(q_temp1(i,j)+1)+m_wei(i,j);
            end
        end
        hist2=hist2*C;
        figure(2);
        set(gcf,'position',[200,150,1000,600]);
        subplot(1,2,1);
        plot(hist2);
        hold on;
        
        w=zeros(1,4096);
        for i=1:4096
            if(hist2(i)~=0) %������
                w(i)=sqrt(hist1(i)/hist2(i));
            else
                w(i)=0;
            end
        end
        
        
        
        %������ʼ��
        sum_w=0;
        xw=[0,0];
        for i=1:a
            for j=1:b
                sum_w=sum_w+w(uint32(q_temp1(i,j))+1);
                xw=xw+w(uint32(q_temp1(i,j))+1)*[i-y(1)-0.5,j-y(2)-0.5];
            end
        end
        Y=xw/sum_w;
        %���ĵ�λ�ø���
        rect(1)=rect(1)+Y(2);
        rect(2)=rect(2)+Y(1);
    end
    
    
    %%%���ٹ켣����%%%
    tic_x=[tic_x;rect(1)+rect(3)/2];
    tic_y=[tic_y;rect(2)+rect(4)/2];
    
    v1=rect(1);
    v2=rect(2);
    v3=rect(3);
    v4=rect(4);
    %%%��ʾ���ٽ��%%%
    subplot(1,2,2);
    imshow(uint8(Im));
%     title('Ŀ����ٽ�������˶��켣��');
    title(['Target tracking results and their trajectories. No.' num2str(l)])
    
    hold on;
    plot([v1,v1+v3],[v2,v2],[v1,v1],[v2,v2+v4],[v1,v1+v3],[v2+v4,v2+v4],[v1+v3,v1+v3],[v2,v2+v4],'LineWidth',2,'Color','r');
    plot(tic_x,tic_y,'LineWidth',2,'Color','b');
    pause(0.001);
end
