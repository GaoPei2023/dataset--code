data=xlsread('F:\data_code\svmc测试数据\data_constract.xlsx')
L=1;
t=0.04;
focal_length=0.028
L_picture=[];
D=[];
V=[5 10 15 20];
L_derivative=[];
frame=[100 50 33 25];
distance=[19.8 
    19.6
    19.2
    19.3];
%SCALE=[1 0.9 0.8 0.7 0.6  0.5 0.4 0.3 0.2 0.1 ]
SCALE=1
%v=1;
tall_frame=0
frame5=0
for j=1:4
    v=V(j)
    distance1=distance(j)
    frame1=frame(j)
    frame5=frame1+frame5
for i=1:frame1
    
    L_picture(i+tall_frame,1)=(focal_length*L)/(distance1-(i-1)*t*v);
    D(i+tall_frame,1)=distance1-(i-1)*t*v;
%     V(i+tall_frame,1)=v
end
if j==1
   for n=1:frame5-2
      L_derivative(n+1,1)=(L_picture(n+1,1)-L_picture(n,1))/t
   end
else
   for n=tall_frame:frame5-2
      L_derivative(n+2,1)=(L_picture(n+2,1)-L_picture(n+1,1))/t
   end
end
tall_frame=frame1+tall_frame
end

xlswrite('F:\data_code\svmc测试数据\data_constract2.xlsx',L_picture,strcat('A1:A',num2str(208)));

xlswrite('F:\data_code\svmc测试数据\data_constract2.xlsx',D,strcat('C1:C',num2str(208)));
xlswrite('F:\data_code\svmc测试数据\data_constract2.xlsx',L_derivative,strcat('B1:B',num2str(208)));