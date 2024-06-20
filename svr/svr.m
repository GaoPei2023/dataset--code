%%清空环境变量
warning off %关闭报警信息
close all  %关闭开启的图窗
clear      %清空变量
clc        %清空命令行

%%导入数据
% res=xlsread('F:\yolo\TEST4.xlsx');
res1=xlsread('F:\KITTI\data_tracking_label_2\training\train.xlsx');
% res=xlsread('F:\yolo\test.xlsx');
% res=xlsread('F:\trackvicon\svr.xlsx');
res=xlsread('F:\KITTI\data_tracking_label_2\training\15.xlsx');

Tau=res(6:46,9);    %%%数据选取：09（a）：“42:106”， 09(b)：“419:605”,"500:553"
                       %%%%20:"118:151"
                       %13：“2：64”
                       %18:"2-40"
                       %19:"2:52"
                       %15:"6:46"

P_train=res1(1:1992,3:4);       
T_train=res1(1:1992,1)*100;
M=size(P_train,1);
%1:309训练集
%w，h，w/h:13,14:16
%视觉线索：9,10:11
 
P_test=res(6:46,7:8);  %%%1241:2108%%%
T_test=res(6:46,6)*100;  %%%Tau*1000,
N=size(P_test,1);
%310:383为测试数据集，与训练集相同尺寸的小车
%384:456为测试数据集，比训练集的小车尺寸更大
%457:507为测试数据集，比训练集的小车尺寸更小

% % 数据的归一化
% p_train=mapminmax(P_train',0,1);   %mapminmax([],ymin.ymax):y = (ymax-ymin)*(x-xmin)/(xmax-xmin) + ymin;
% p_test=mapminmax(P_test',0,1);   %ps_input为映射条件
% 
% t_train=mapminmax(T_train',0,1);
% t_test=mapminmax(T_test',0,1);
% 
% %转置以适应模型
%  P_train=p_train'*1000;P_test=p_test'*1000;
%  T_test=t_train'*100;T_test=t_test'*100;

%%创建模型
%寻找最优化参数——交叉验证法
% [c,g] = meshgrid(-10:0.2:10,-10:0.2:10);
% [m,n] = size(c);
% cg = zeros(m,n);
% eps = 10^(-4);
% v = 5;
% bestc = 1;
% bestg = 0.1;
% bestacc = 0;
% for i=1:m
%     for j=1:n
%         cmd=['-v',num2str(v),'-t 2','-c',num2str(2^c(i,j)),'-g',num2str(2^g(i,j))];
%         cg(i,j)=svmtrain(T_train,P_train,cmd);
%         if cg(i,j)>bestacc
%             bestacc=cg(i,j);
%             bestc=2^c(i,j);
%             bestg=2^g(i,j);
%         end
%         if abs(cg(i,j)-bestacc)<=eps&&bestc>2^c(i,j)
%             bestacc=cg(i,j);
%             bestc=2^c(i,j);
%             bestg=2^g(i,j);
%         end
%     end
% end
% c=0.1;     %惩罚因子
% g=0.1111;     %径向基核函数参数
cmd=['-t 1','-c',num2str(0.000976),'-g',num2str(0.000976),'-s 4 -p 0.1 -r 2 '];
% -t 1 为多项式核函数， -t 2  为径向基核函数，视觉线索best=0.000976
model=svmtrain(T_train,P_train,cmd);

%%仿真预测1
[t_sim1,error_1,preb1]=svmpredict(T_train,P_train,model);
[t_sim2,error_2,preb2]=svmpredict(T_test,P_test,model);

% %%数据反归一化
% T_sim1=mapminmax('reverse',t_sim1,ps_output);
% T_sim2=mapminmax('reverse',t_sim2,ps_output);
% 
% %%均方根误差
error1=sqrt(sum((t_sim1-T_train).^2)./N);
error2=sqrt(sum((t_sim2-T_test).^2)./N);
%%绘图
figure
plot(1:M,T_train/1000,'r-*',1:M,t_sim1/1000,'b-o','LineWidth',1)
% legend('Ground Truth','Predicted')
legend('Ground Truth','Predicted','Location','SouthOutside','Orientation','Horizontal')
xlabel('帧数')
ylabel('时间(s)')
string={'训练集预测结果对比';['RMSE=' num2str(error1/100)]};
title(string)
xlim([1,M])
grid

figure
% plot(1:N,T_test/100,'r-*',1:N,t_sim2/100,'b-o','LineWidth',1) 
plot(1:N,T_test/100,'r-*',1:N,t_sim2/100,'b-o',1:N,Tau,'g-x','LineWidth',1)   %%%%%1:N,Tau*100,'g-x',
legend('真实值','预测值','Tau','Location','SouthOutside','Orientation','Horizontal','FontName', '宋体', 'FontSize', 10)

xlabel('帧数', 'FontName', '宋体', 'FontSize', 10)
ylabel('时间(s)', 'FontName', '宋体', 'FontSize', 10)

string={['RMSE=' num2str(error2/100)]};
title(string,'FontName', 'Times New Roman', 'FontSize', 10)
xlim([1,N])
ylim([1,13])
grid


%%画图
% box on
% zp = BaseZoom();
% zp.run;
% 
% %%相关指标计算
% %R2
% R1=1-norm(T_train-T_sim1')^2/norm(T_train-mean(T_train))^2;
% R2=1-norm(T_test-T_sim2')^2/norm(T_test-mean(T_test))^2;
% 
% disp(['训练集数据的R1为：',num2str(R1)])
% disp(['训练集数据的R2为：',num2str(R2)])
% 
% %MAE
% mae1=sum(abs(T_sim1'-T_train))./M;
% mae2=sum(abs(T_sim2'-T_test))./N;
% 
% disp(['训练集数据的MAE为：',num2str(mae1)])
% disp(['训练集数据的MAE为：',num2str(mae2)])
% 
% %MBE
% mbe1=sum(T_sim1'-T_train)./M;
% mbe2=sum(T_sim2'-T_test)./N;
% 
% disp(['训练集数据的MBE为：',num2str(mbe1)])
% disp(['训练集数据的MBAE为：',num2str(mbe2)])


