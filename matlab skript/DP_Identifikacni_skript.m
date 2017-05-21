% ************************************************************************
% -= Script for identifying dynamic parameters of industrial manipulators =-
%  
% author: Andrej Suslov
% date: 22.5.2017
% created as part of a diploma thesis
% ************************************************************************

close all;
clear all;
clc;

%%
%--- general robot infromation

n_axes = 6;     %number of axes
n_var = 5;          %nubmer of captured variables (velocity,acceleration,torque,current,position)
t_sampling = 4;   %sampling period in ms

tran_rate = [0.008; 0.008; 0.0115; 0.013433; 0.02368; 0.041463];  % transmission rate for axes 1-n_axes
value_scaling = [1000; 1000; 1000; 1000000; 1000000];           % scaling factors for variables 1-n_var

torque_constant = [1.33; 1.33; 0.69; 0.67; 0.67; 0.67];     % torque constants for axes 1-n_axes
bemf_constant = [84.5; 84.5; 44; 45; 45; 45];               % Bemf constants for axes 1-n_axes

L = [14.7; 14.7; 6.7; 18.5; 18.5; 18.5]*1e-03;      % inductances of windings of motors of axes 1-n_axes [H]
R = [1.44; 1.44; 1.2; 5.2; 5.2; 5.2];          % resistances of windings of motors of axes 1-n_axes [ohm]

% modified DH parameters of robot [m]
a2 = .18;
a3 = .60;
a4 = .12;
b4 = .62;
b6 = 0.115;

% gravitational acceleration [m/s^-1]
g = 9.81;

% conversion constants for 3-phased motors
torq_conv = 2/(3*sqrt(2));
volt_conv = (sqrt(2)*60)/(1000*2*pi*sqrt(3));

%%
%--- read robot trajectory

str = repmat('',n_axes,1);
data_array=repmat([],n_var,n_axes);

path = ('C:/Users/Andrej/Desktop/trace/suslov_dp_03_05000_NextGenDrive');

for i=1:n_axes
    fid=fopen([path '#' num2str(i) '.r64']);
    data_raw=fread(fid,'double');   %Raw data extraction
    n_data=length(data_raw);
    
    for j=1:n_var
        if (j~=3 && j~=4)
            data_array(:,j,i)=deg2rad((data_raw(j:n_var:n_data)/value_scaling(j))*tran_rate(i));
        else
          if (j==3)
            data_array(:,j,i)=(data_raw(j:n_var:n_data)/value_scaling(j))/tran_rate(i);
          else
            data_array(:,j,i)=(data_raw(j:n_var:n_data)/value_scaling(j));
          end
        end    
        
    end
     
    current_tf(i)=tf(1,[L(i) R(i)]);
        
end

data_array(:,5,3) = data_array(:,5,3) - pi/2;

fclose(fid);

clear fid data_raw n_data str

%%
%--- generate time and data array

t = 0:1:size(data_array)-1;
t = t*t_sampling/1000;

tx = t;
dx = data_array;


%%
%--- plot trajectories
close all
clc

for i=1:n_axes
    % smooth acceleration
   dx(:,[2],i) = medfilt1(dx(:,[2],i),10);
end

axis = 1;
figure
hold on
plot(tx,dx(:,[2],axis))
plot(tx,dx(:,[3],axis))
plot(tx,dx(:,[1],axis))
plot(tx,dx(:,[5],axis))
plot(tx,dx(:,[4],axis))
legend('acceleration [rad/s^2]','torque [Nm]','velocity [rad/s]','position [rad]','current [A]');
grid on

axis = 2; 
figure
hold on
plot(tx,dx(:,[2],axis))
plot(tx,dx(:,[3],axis))
plot(tx,dx(:,[1],axis))
plot(tx,dx(:,[5],axis))
plot(tx,dx(:,[4],axis))
legend('acceleration [rad/s^2]','torque [Nm]','velocity [rad/s]','position [rad]','current [A]');
grid on

axis = 3; 
figure
hold on
plot(tx,dx(:,[2],axis))
plot(tx,dx(:,[3],axis))
plot(tx,dx(:,[1],axis))
plot(tx,dx(:,[5],axis))
plot(tx,dx(:,[4],axis))
legend('acceleration [rad/s^2]','torque [Nm]','velocity [rad/s]','position [rad]','current [A]');
grid on

axis = 4;
figure
hold on
plot(tx,dx(:,[2],axis))
plot(tx,dx(:,[3],axis))
plot(tx,dx(:,[1],axis))
plot(tx,dx(:,[5],axis))
plot(tx,dx(:,[4],axis))
legend('acceleration [rad/s^2]','torque [Nm]','velocity [rad/s]','position [rad]','current [A]');
grid on

axis = 5; 
figure
hold on
plot(tx,dx(:,[2],axis))
plot(tx,dx(:,[3],axis))
plot(tx,dx(:,[1],axis))
plot(tx,dx(:,[5],axis))
plot(tx,dx(:,[4],axis))
legend('acceleration [rad/s^2]','torque [Nm]','velocity [rad/s]','position [rad]','current [A]');
grid on

axis = 6; 
figure
hold on
plot(tx,dx(:,[2],axis))
plot(tx,dx(:,[3],axis))
plot(tx,dx(:,[1],axis))
plot(tx,dx(:,[5],axis))
plot(tx,dx(:,[4],axis))
legend('acceleration [rad/s^2]','torque [Nm]','velocity [rad/s]','position [rad]','current [A]');
grid on


%%
%--- create matrix P of dynamic parameters 

syms I1x I1y I1z
syms I2x I2y I2z
syms I3x I3y I3z
syms I4x I4y I4z
syms I5x I5y I5z
syms I6x I6y I6z
syms d1x d1y d1z
syms d2x d2y d2z
syms d3x d3y d3z
syms d4x d4y d4z
syms d5x d5y d5z
syms d6x d6y d6z
syms m1 m2 m3 m4 m5 m6
syms g
syms a1 a2 a3 a4 a5 a6
syms b1 b2 b3 b4 b5 b6
syms th1 th2 th3 th4 th5 th6
syms dth1 dth2 dth3 dth4 dth5 dth6
syms ddth1 ddth2 ddth3 ddth4 ddth5 ddth6
syms fv1 fv2 fv3 fv4 fv5 fv6
syms fc1 fc2 fc3 fc4 fc5 fc6

P = [I1x;I1y;I1z;...
     I2x;I2y;I2z;...
     I3x;I3y;I3z;...
     I4x;I4y;I4z;...
     I5x;I5y;I5z;...
     I6x;I6y;I6z;...
     m1;d1x;d1y;d1z;...
     m2;d2x;d2y;d2z;...
     m3;d3x;d3y;d3z;...
     m4;d4x;d4y;d4z;...
     m5;d5x;d5y;d5z;...
     m6;d6x;d6y;d6z;...
     fv1;fc1;...
     fv2;fc2;...
     fv3;fc3;...
     fv4;fc4;...
     fv5;fc5;...
     fv6;fc6];

P_length = length(P);
 
%%
%--- read and generate equations of motion

% read generated equations from ReDySim
equation_of_motion;

% create matrix + add friction
Torques = [torque_1 + fv1*dth1 + fc1*sign(dth1);
           torque_2 + fv2*dth2 + fc2*sign(dth2);
           torque_3 + fv3*dth3 + fc3*sign(dth3);
           torque_4 + fv4*dth4 + fc4*sign(dth4);
           torque_5 + fv5*dth5 + fc5*sign(dth5);
           torque_6 + fv6*dth6 + fc6*sign(dth6)];

clear torque_1 torque_2 torque_3 torque_4 torque_5 torque_6

%%
%--- generate symbolic matrix Hi

clear H Hi
mi = 0;

for i=1:n_axes
    for j=1:P_length
        
        P_test = zeros(P_length,1);
        P_test(j) = 1;
        symbolic_matrix;
       
        if(j==19 || j == 23 || j==27 || j==31 || j==35 || j==39)
            mi = subs(Torques(i));
        end
       
        if(j > 19 && j < 23 )
            P_test(19) = 1;
            symbolic_matrix;
            di = subs(Torques(i));
            dimi = di - mi;
            Hi(i,j) = subs(dimi)/(P(j)*P(19));
        elseif(j > 23 && j < 27 )
            P_test(23) = 1;
            symbolic_matrix;
            di = subs(Torques(i));
            dimi = di - mi;
            Hi(i,j) = subs(dimi)/(P(j)*P(23));
        elseif(j > 27 && j < 31 )
            P_test(27) = 1;
            symbolic_matrix;
            di = subs(Torques(i));
            dimi = di - mi;
            Hi(i,j) = subs(dimi)/(P(j)*P(27));
        elseif(j > 31 && j < 35 )
            P_test(31) = 1;
            symbolic_matrix;
            di = subs(Torques(i));
            dimi = di - mi;
            Hi(i,j) = subs(dimi)/(P(j)*P(31));
        elseif(j > 35 && j < 39 )
            P_test(35) = 1;
            symbolic_matrix;
            di = subs(Torques(i));
            dimi = di - mi;
            Hi(i,j) = subs(dimi)/(P(j)*P(35));
        elseif(j > 39 && j < 43 )
            P_test(39) = 1;
            symbolic_matrix;
            di = subs(Torques(i));
            dimi = di - mi;
            Hi(i,j) = subs(dimi)/(P(j)*P(39));
        else
            Hi(i,j) = subs(Torques(i))/P(j);
        end
    end
    [i j]
end

% modify matrix P
P(20:22)=P(20:22)*P(19);
P(24:26)=P(24:26)*P(23);
P(28:30)=P(28:30)*P(27);
P(32:34)=P(32:34)*P(31);
P(36:38)=P(36:38)*P(35);
P(40:42)=P(40:42)*P(39);


%%
%--- create matrix H by substitution of values for different time

clc
clear H T

iden_data = dx;
i_d_length = length(iden_data);

H = zeros(6*i_d_length,54);
T = zeros(6*i_d_length,1);

step = 1;

for i=1 : step : i_d_length

% positions
th1 = iden_data(i,5,1);
th2 = iden_data(i,5,2);
th3 = iden_data(i,5,3);
th4 = iden_data(i,5,4);
th5 = iden_data(i,5,5);
th6 = iden_data(i,5,6);

% velocities
dth1 = iden_data(i,1,1);
dth2 = iden_data(i,1,2);
dth3 = iden_data(i,1,3);
dth4 = iden_data(i,1,4);
dth5 = iden_data(i,1,5);
dth6 = iden_data(i,1,6);

% accelerations
ddth1 = iden_data(i,2,1);
ddth2 = iden_data(i,2,2);
ddth3 = iden_data(i,2,3);
ddth4 = iden_data(i,2,4);
ddth5 = iden_data(i,2,5);
ddth6 = iden_data(i,2,6);

% torques
T1 = iden_data(i,3,1)*torq_conv;
T2 = iden_data(i,3,2)*torq_conv;
T3 = iden_data(i,3,3)*torq_conv;
T4 = iden_data(i,3,4)*torq_conv;
T5 = iden_data(i,3,5)*torq_conv;
T6 = iden_data(i,3,6)*torq_conv;

Hi_code;

H(6*i-5:6*i,:)=[Hi_x(1,:);
                Hi_x(2,:);
                Hi_x(3,:);
                Hi_x(4,:);
                Hi_x(5,:);
                Hi_x(6,:)];
                
T(6*i-5:6*i)=[T1;...
              T2;...
              T3;...
              T4;...
              T5;...
              T6];
i
end


%%
%--- compute matrix P using least square method
clc

%optional lower bound and upper bound constraints

%lower bounds

lb =[0;0;0;...                  %I1x, I1y, I1z
     0;0;0;...                  %I2x, I2y, I2z
     0;0;0;...                  %I3x, I3y, I3z
     0;0;0;...                  %I4x, I4y, I4z
     0;0;0;...                  %I5x, I5y, I5z
     0;0;0;...                  %I6x, I6y, I6z
     0;0;0;0;...                %m1, m1*dx1, m1*dy1, m1*dz1
     19.3 ;-Inf;-Inf;-Inf;...   %m2, m2*dx2, m2*dy2, m2*dz2 
     26.47;-Inf;-Inf;-Inf;...   %m3, m3*dx3, m3*dy3, m3*dz3 
     7.41 ;-Inf;-Inf;-Inf;...   %m4, m4*dx4, m4*dy4, m4*dz4 
     2.53 ;-Inf;-Inf;-Inf;...   %m5, m5*dx5, m5*dy5, m5*dz5 
     0.6  ;   0;   0;-Inf;...   %m6, m6*dx6, m6*dy6, m6*dz6 
     -Inf;-Inf;...              %fv1, fc1
     -Inf;-Inf;...              %fv2, fc2
     -Inf;-Inf;...              %fv3, fc3
     -Inf;-Inf;...              %fv4, fc4
     -Inf;-Inf;...              %fv5, fc5
     -Inf;-Inf];                %fv6, fc6

%upper bounds
ub =[Inf;Inf;Inf;...            %I1x, I1y, I1z
     Inf;Inf;Inf;...            %I2x, I2y, I2z
     Inf;Inf;Inf;...            %I3x, I3y, I3z
     Inf;Inf;Inf;...            %I4x, I4y, I4z
     Inf;Inf;Inf;...            %I5x, I5y, I5z
     Inf;Inf;Inf;...            %I6x, I6y, I6z
     0;0;0;0;...                %m1, m1*dx1, m1*dy1, m1*dz1
     19.3 ;Inf;Inf;Inf;...      %m2, m2*dx2, m1*dy2, m2*dz2
     26.47;Inf;Inf;Inf;...      %m3, m3*dx3, m1*dy3, m3*dz3
     7.41 ;Inf;Inf;Inf;...      %m4, m4*dx4, m1*dy4, m4*dz4
     2.53 ;Inf;Inf;Inf;...      %m5, m5*dx5, m1*dy5, m5*dz5
     0.6  ;  0;  0;Inf;...      %m6, m6*dx6, m1*dy6, m6*dz6
     Inf;Inf;...                %fv1, fc1
     Inf;Inf;...                %fv2, fc2
     Inf;Inf;...                %fv3, fc3
     Inf;Inf;...                %fv4, fc4
     Inf;Inf;...                %fv5, fc5
     Inf;Inf];                  %fv6, fc6

 
options = optimoptions('lsqlin','Algorithm','interior-point','Display','iter'); 
Pc = lsqlin(H,T,[],[],[],[],lb,ub,[],options);

P_par = Pc;


%%
%--- simulate identified data
close all
clc

clear T_test
clear T

iden_data = dx;
i_d_length = length(iden_data);

step = 1;

for i=1 : step : i_d_length
    
th1 = iden_data(i,5,1);
th2 = iden_data(i,5,2);
th3 = iden_data(i,5,3);
th4 = iden_data(i,5,4);
th5 = iden_data(i,5,5);
th6 = iden_data(i,5,6);

dth1 = iden_data(i,1,1);
dth2 = iden_data(i,1,2);
dth3 = iden_data(i,1,3);
dth4 = iden_data(i,1,4);
dth5 = iden_data(i,1,5);
dth6 = iden_data(i,1,6);

ddth1 = iden_data(i,2,1);
ddth2 = iden_data(i,2,2);
ddth3 = iden_data(i,2,3);
ddth4 = iden_data(i,2,4);
ddth5 = iden_data(i,2,5);
ddth6 = iden_data(i,2,6);

T1 = iden_data(i,3,1);
T2 = iden_data(i,3,2);
T3 = iden_data(i,3,3);
T4 = iden_data(i,3,4);
T5 = iden_data(i,3,5);
T6 = iden_data(i,3,6);

T(:,i)=[T1;T2;T3;T4;T5;T6];

Hi_code;

T_test(:,i) = Hi_x*Pc;

i
end

%%
%--- plot simulated data and compare with measured one
close all
clc

figure
hold on
plot(tx(1:step:end),torq_conv*dx(1:step:end,3,1),'g','LineWidth',2)
plot(tx(1:step:end),T_test(1,1:step:end),'-','LineWidth',2)
%plot(tx(1:step:end),T_test_3d(1,1:step:end),'-c','LineWidth',2)
%plot(tx(1:step:end),T_test_eq(1,1:step:end),'-r','LineWidth',2)
grid on
legend('Zmìøený','Odvozený - z 3D modelu (s tøením)','Odvozený - z 3D modelu (bez tøení)','Odvozený - z rovnic')
title('Osa 1')
xlabel('Èas [s]');
ylabel('Toèivý moment [Nm]');

figure
hold on
plot(tx(1:step:end),torq_conv*dx(1:step:end,3,2),'g','LineWidth',2)
plot(tx(1:step:end),T_test(2,1:step:end),'-','LineWidth',2)
%plot(tx(1:step:end),T_test_3d(2,1:step:end),'-c','LineWidth',2)
%plot(tx(1:step:end),T_test_eq(2,1:step:end),'-r','LineWidth',2)
grid on
legend('Zmìøený','Odvozený - z 3D modelu (s tøením)','Odvozený - z 3D modelu (bez tøení)','Odvozený - z rovnic')
title('Osa 2')
xlabel('Èas [s]');
ylabel('Toèivý moment [Nm]');

figure
hold on
plot(tx(1:step:end),torq_conv*dx(1:step:end,3,3),'g','LineWidth',2)
plot(tx(1:step:end),T_test(3,1:step:end),'-','LineWidth',2)
%plot(tx(1:step:end),T_test_3d(3,1:step:end),'-c','LineWidth',2)
%plot(tx(1:step:end),T_test_eq(3,1:step:end)+45,'-r','LineWidth',2)
grid on
legend('Zmìøený','Odvozený - z 3D modelu (s tøením)','Odvozený - z 3D modelu (bez tøení)','Odvozený - z rovnic')
title('Osa 3')
xlabel('Èas [s]');
ylabel('Toèivý moment [Nm]');

figure
hold on
plot(tx(1:step:end),torq_conv*dx(1:step:end,3,4),'g','LineWidth',2)
plot(tx(1:step:end),T_test(4,1:step:end),'-','LineWidth',2)
%plot(tx(1:step:end),T_test_3d(4,1:step:end),'-c','LineWidth',2)
%plot(tx(1:step:end),T_test_eq(4,1:step:end),'-r','LineWidth',2)
grid on
legend('Zmìøený','Odvozený - z 3D modelu (s tøením)','Odvozený - z 3D modelu (bez tøení)','Odvozený - z rovnic')
title('Osa 4')
xlabel('Èas [s]');
ylabel('Toèivý moment [Nm]');

figure
hold on
plot(tx(1:step:end),torq_conv*dx(1:step:end,3,5),'g','LineWidth',2)
plot(tx(1:step:end),T_test(5,1:step:end),'-','LineWidth',2)
%plot(tx(1:step:end),T_test_3d(5,1:step:end),'-c','LineWidth',2)
%plot(tx(1:step:end),T_test_eq(5,1:step:end),'-r','LineWidth',2)
grid on
legend('Zmìøený','Odvozený - z 3D modelu (s tøením)','Odvozený - z 3D modelu (bez tøení)','Odvozený - z rovnic')
title('Osa 5')
xlabel('Èas [s]');
ylabel('Toèivý moment [Nm]');

figure
hold on
plot(tx(1:step:end),torq_conv*dx(1:step:end,3,6),'g','LineWidth',2)
plot(tx(1:step:end),T_test(6,1:step:end),'-','LineWidth',2)
%plot(tx(1:step:end),T_test_3d(6,1:step:end),'-c','LineWidth',2)
%plot(tx(1:step:end),T_test_eq(6,1:step:end),'-r','LineWidth',2)
grid on
legend('Zmìøený','Odvozený - z 3D modelu (s tøením)','Odvozený - z 3D modelu (bez tøení)','Odvozený - z rovnic')
title('Osa 6')
xlabel('Èas [s]');
ylabel('Toèivý moment [Nm]');

%%
%%--
close all


figure
hold on
step=1;
plot(tx(1:step:end),abs(torq_conv*dx(1:step:end,3,1)-T_test_eq(1,1:step:end)'),'c','LineWidth',2)
plot(tx(1:step:end),abs(torq_conv*dx(1:step:end,3,1)-T_test(1,1:step:end)'),'g','LineWidth',2)
step=15;
plot(tx(1:step:end),mean(abs(torq_conv*dx(1:step:end,3,1)-T_test_eq(1,1:step:end)'))*ones(length(tx(1:step:end)),1),'--b','LineWidth',2)
plot(tx(1:step:end),mean(abs(torq_conv*dx(1:step:end,3,1)-T_test(1,1:step:end)'))*ones(length(tx(1:step:end)),1),'--r','LineWidth',2)
grid on
legend('Okamžitá - z rovnic','Okamžitá - z 3D se tøením','Prùmìrná - z rovnic','Prùmìrná - z 3D se tøením')
title('Osa 1')
xlabel('Èas [s]');
ylabel('Absolutní odchylka toèivého momentu [Nm]');

figure
hold on
step=1;
plot(tx(1:step:end),abs(torq_conv*dx(1:step:end,3,2)-T_test_eq(2,1:step:end)'),'c','LineWidth',2)
plot(tx(1:step:end),abs(torq_conv*dx(1:step:end,3,2)-T_test(2,1:step:end)'),'g','LineWidth',2)
step=15;
plot(tx(1:step:end),mean(abs(torq_conv*dx(1:step:end,3,2)-T_test_eq(2,1:step:end)'))*ones(length(tx(1:step:1800)),1),'--b','LineWidth',2)
plot(tx(1:step:end),mean(abs(torq_conv*dx(1:step:end,3,2)-T_test(2,1:step:end)'))*ones(length(tx(1:step:1800)),1),'--r','LineWidth',2)
grid on
legend('Okamžitá - z rovnic','Okamžitá - z 3D se tøením','Prùmìrná - z rovnic','Prùmìrná - z 3D se tøením')
title('Osa 2')
xlabel('Èas [s]');
ylabel('Absolutní odchylka toèivého momentu [Nm]');

figure
hold on
step=1;
plot(tx(1:step:end),abs(torq_conv*dx(1:step:end,3,3)-T_test_eq(3,1:step:end)'),'c','LineWidth',2)
plot(tx(1:step:end),abs(torq_conv*dx(1:step:end,3,3)-T_test(3,1:step:end)'),'g','LineWidth',2)
step=15;
plot(tx(1:step:end),mean(abs(torq_conv*dx(1:step:end,3,3)-T_test_eq(3,1:step:end)'))*ones(length(tx(1:step:end)),1),'--b','LineWidth',2)
plot(tx(1:step:end),mean(abs(torq_conv*dx(1:step:end,3,3)-T_test(3,1:step:end)'))*ones(length(tx(1:step:end)),1),'--r','LineWidth',2)
grid on
legend('Okamžitá - z rovnic','Okamžitá - z 3D se tøením','Prùmìrná - z rovnic','Prùmìrná - z 3D se tøením')
title('Osa 3')
xlabel('Èas [s]');
ylabel('Absolutní odchylka toèivého momentu [Nm]');

figure
hold on
step=1;
plot(tx(1:step:end),abs(torq_conv*dx(1:step:end,3,4)-T_test_eq(4,1:step:end)'),'c','LineWidth',2)
plot(tx(1:step:end),abs(torq_conv*dx(1:step:end,3,4)-T_test(4,1:step:end)'),'g','LineWidth',2)
step=15;
plot(tx(1:step:end),mean(abs(torq_conv*dx(1:step:end,3,4)-T_test_eq(4,1:step:end)'))*ones(length(tx(1:step:end)),1),'--b','LineWidth',2)
plot(tx(1:step:end),mean(abs(torq_conv*dx(1:step:end,3,4)-T_test(4,1:step:end)'))*ones(length(tx(1:step:end)),1),'--r','LineWidth',2)
grid on
legend('Okamžitá - z rovnic','Okamžitá - z 3D se tøením','Prùmìrná - z rovnic','Prùmìrná - z 3D se tøením')
title('Osa 4')
xlabel('Èas [s]');
ylabel('Absolutní odchylka toèivého momentu [Nm]');

figure
hold on
step=1;
plot(tx(1:step:end),abs(torq_conv*dx(1:step:end,3,5)-T_test_eq(5,1:step:end)'),'c','LineWidth',2)
plot(tx(1:step:end),abs(torq_conv*dx(1:step:end,3,5)-T_test(5,1:step:end)'),'g','LineWidth',2)
step=15;
plot(tx(1:step:end),mean(abs(torq_conv*dx(1:step:end,3,5)-T_test_eq(5,1:step:end)'))*ones(length(tx(1:step:end)),1),'--b','LineWidth',2)
plot(tx(1:step:end),mean(abs(torq_conv*dx(1:step:end,3,5)-T_test(5,1:step:end)'))*ones(length(tx(1:step:end)),1),'--r','LineWidth',2)
grid on
legend('Okamžitá - z rovnic','Okamžitá - z 3D se tøením','Prùmìrná - z rovnic','Prùmìrná - z 3D se tøením')
title('Osa 5')
xlabel('Èas [s]');
ylabel('Absolutní odchylka toèivého momentu [Nm]');

figure
hold on
step=1;
plot(tx(1:step:end),abs(torq_conv*dx(1:step:end,3,6)-T_test_eq(6,1:step:end)'),'c','LineWidth',2)
plot(tx(1:step:end),abs(torq_conv*dx(1:step:end,3,6)-T_test(6,1:step:end)'),'g','LineWidth',2)
step=15;
plot(tx(1:step:end),mean(abs(torq_conv*dx(1:step:end,3,6)-T_test_eq(6,1:step:end)'))*ones(length(tx(1:step:end)),1),'--b','LineWidth',2)
plot(tx(1:step:end),mean(abs(torq_conv*dx(1:step:end,3,6)-T_test(6,1:step:end)'))*ones(length(tx(1:step:end)),1),'--r','LineWidth',2)
grid on
legend('Okamžitá - z rovnic','Okamžitá - z 3D se tøením','Prùmìrná - z rovnic','Prùmìrná - z 3D se tøením')
title('Osa 6')
xlabel('Èas [s]');
ylabel('Absolutní odchylka toèivého momentu [Nm]');


%%
%--- read measured power

close all;
clc

%--- power from model

currents = [T_test(1,1:step:end)/torq_conv*tran_rate(1)/torque_constant(1);...
            T_test(2,1:step:end)/torq_conv*tran_rate(2)/torque_constant(2);...
            T_test(3,1:step:end)/torq_conv*tran_rate(3)/torque_constant(3);...
            T_test(4,1:step:end)/torq_conv*tran_rate(4)/torque_constant(4);...
            T_test(5,1:step:end)/torq_conv*tran_rate(5)/torque_constant(5);...
            T_test(6,1:step:end)/torq_conv*tran_rate(6)/torque_constant(6)];
        
currents_meas = [dx(:,4,1)';...
                 dx(:,4,2)';...
                 dx(:,4,3)';...
                 dx(:,4,4)';...
                 dx(:,4,5)';...
                 dx(:,4,6)'];
             
current = [abs(dx(:,4,1))'+...
           abs(dx(:,4,2))'+...
           abs(dx(:,4,3))'+...
           abs(dx(:,4,4))'+...
           abs(dx(:,4,5))'+...
           abs(dx(:,4,6))'];
        
diff_currents = [diff(currents(1,:)/0.004);...
                 diff(currents(2,:)/0.004);...
                 diff(currents(3,:)/0.004);...
                 diff(currents(4,:)/0.004);...
                 diff(currents(5,:)/0.004);...
                 diff(currents(6,:)/0.004)];

diff_currents_meas = [diff(currents_meas(1,:)/0.004);...
                      diff(currents_meas(2,:)/0.004);...
                      diff(currents_meas(3,:)/0.004);...
                      diff(currents_meas(4,:)/0.004);...
                      diff(currents_meas(5,:)/0.004);...
                      diff(currents_meas(6,:)/0.004)];

voltages = [L(1)*diff_currents(1,:) + R(1)*currents(1,1:end-1);...
            L(2)*diff_currents(2,:) + R(2)*currents(2,1:end-1);...
            L(3)*diff_currents(3,:) + R(3)*currents(3,1:end-1);...
            L(4)*diff_currents(4,:) + R(4)*currents(4,1:end-1);...
            L(5)*diff_currents(5,:) + R(5)*currents(5,1:end-1);...
            L(6)*diff_currents(6,:) + R(6)*currents(6,1:end-1)];
        
voltages_meas = [L(1)*diff_currents_meas(1,:) + R(1)*currents_meas(1,1:end-1);...
                 L(2)*diff_currents_meas(2,:) + R(2)*currents_meas(2,1:end-1);...
                 L(3)*diff_currents_meas(3,:) + R(3)*currents_meas(3,1:end-1);...
                 L(4)*diff_currents_meas(4,:) + R(4)*currents_meas(4,1:end-1);...
                 L(5)*diff_currents_meas(5,:) + R(5)*currents_meas(5,1:end-1);...
                 L(6)*diff_currents_meas(6,:) + R(6)*currents_meas(6,1:end-1)];
      
powers = [currents(1,1:end-1).*voltages(1,:);...
          currents(2,1:end-1).*voltages(2,:);...
          currents(3,1:end-1).*voltages(3,:);...
          currents(4,1:end-1).*voltages(4,:);...
          currents(5,1:end-1).*voltages(5,:);...
          currents(6,1:end-1).*voltages(6,:)];
      
powers_meas = [currents_meas(1,1:end-1).*voltages_meas(1,:);...
               currents_meas(2,1:end-1).*voltages_meas(2,:);...
               currents_meas(3,1:end-1).*voltages_meas(3,:);...
               currents_meas(4,1:end-1).*voltages_meas(4,:);...
               currents_meas(5,1:end-1).*voltages_meas(5,:);...
               currents_meas(6,1:end-1).*voltages_meas(6,:)];
      
power = [powers(1,:)+...
         powers(2,:)+...
         powers(3,:)+...
         powers(4,:)+...
         powers(5,:)+...
         powers(6,:)];
     
power_meas = [powers_meas(1,:)+...
              powers_meas(2,:)+...
              powers_meas(3,:)+...
              powers_meas(4,:)+...
              powers_meas(5,:)+...
              powers_meas(6,:)];
     
figure
hold on
grid on
plot(tx(1:step:end-1),abs(power(:)),'LineWidth',2)
plot(tx(1:step:end-1),abs(power_meas(:)),'LineWidth',2)
legend('Z modelu','Z mìøení proudu')
title('Vypoèítaný celkový výkon robota')
xlabel('Èas [s]');
ylabel('Výkon [W]');

mean(abs(power(1:end)-power_meas(1:end)))
mean(abs(power(1:end)-power_meas(1:end)))/mean(abs(power_meas(1:end)))

%--- measurement from PLC

avg_sample = zeros(1,size(kuka_measurement_L,1)-1);
kukamereni = kuka_measurement_L;


for i=1:1:size(kukamereni)-1

avg_sample(i)=kukamereni(i+1,1)-kukamereni(i,1);
if(avg_sample(i)<0)
    avg_sample(i)=avg_sample(i)+60;
end

end

mean_sample_time = mean(avg_sample)
sample_time_cov = cov(avg_sample)

for i=1:1:size(kukamereni)-1

    if(kukamereni(i,1)>kukamereni(i+1,1))
        kukamereni(i+1,1)=kukamereni(i+1,1)+60;
    end
 
end

kukamereni(:,1) = kukamereni(:,1) - kukamereni(1,1);

figure
grid on
plot(1:length(kukamereni)-1,avg_sample)
legend('sampling time');

figure
plot(kukamereni(:,1),kukamereni(:,2))
hold on
grid on
plot(kukamereni(:,1),kukamereni(:,3))
plot(kukamereni(:,1),kukamereni(:,4))
legend('faze 1','faze 2','faze 3');

figure
plot(kukamereni(105:195,1)-kukamereni(105,1),kukamereni(105:195,2)+kukamereni(105:195,3)+kukamereni(105:195,3),'LineWidth',2)
grid on
xlabel('Èas (s)')
ylabel('Výkon [W]')
title('Skuteèný zmìøený výkon robotu');

%--- comparison

clear kukamereni_x
kukamereni_x(:,:)=kukamereni(105:177,:);

pow_x = abs(power(:));
pow_meas_x = abs(power_meas(:));

y1 = resample(pow_x,72,length(pow_x)-1);
y2 = resample(pow_meas_x,72,length(pow_meas_x)-1);

figure
grid on
hold on
plot(kukamereni_x(:,1)-kukamereni_x(1,1),kukamereni_x(:,2)+kukamereni_x(:,3)+kukamereni_x(:,4),'LineWidth',2)
plot(kukamereni_x(:,1)-kukamereni_x(1,1),abs(y1),'LineWidth',2)
xlabel('Èas (s)')
ylabel('Výkon [W]')
title('Srovnání zmìøeného a vypoèítaného výkonu');
legend('Mìøení','Model');

%%
%-- Monte Carlo

close all
clc

clear I_MC I_MC_meas

samples = 150;
range = 0.2;


MC = zeros(length(Pc),length(samples),2);
iden_data = dx(:,:,:);
i_d_length = length(iden_data);

step = 25;

for j=1:length(Pc)
    for k=1:samples
        
        rnd1 = rand;
        rnd2 = rand;
        if rnd1>0.5
           rnd2 = -rnd2;
        end

        Pc(j)=Pc(j)+Pc(j)*range*rnd2;

        for i=1 : step : i_d_length
      
            th1 = iden_data(i,5,1);
            th2 = iden_data(i,5,2);
            th3 = iden_data(i,5,3);
            th4 = iden_data(i,5,4);
            th5 = iden_data(i,5,5);
            th6 = iden_data(i,5,6);
            
            dth1 = iden_data(i,1,1);
            dth2 = iden_data(i,1,2);
            dth3 = iden_data(i,1,3);
            dth4 = iden_data(i,1,4);
            dth5 = iden_data(i,1,5);
            dth6 = iden_data(i,1,6);
            
            ddth1 = iden_data(i,2,1);
            ddth2 = iden_data(i,2,2);
            ddth3 = iden_data(i,2,3);
            ddth4 = iden_data(i,2,4);
            ddth5 = iden_data(i,2,5);
            ddth6 = iden_data(i,2,6);

            Hi_code;

            I_MC(:,i) = [Hi_x(1,:)*Pc/torq_conv*tran_rate(1)/torque_constant(1);...
                         Hi_x(2,:)*Pc/torq_conv*tran_rate(2)/torque_constant(2);...
                         Hi_x(3,:)*Pc/torq_conv*tran_rate(3)/torque_constant(3);...
                         Hi_x(4,:)*Pc/torq_conv*tran_rate(4)/torque_constant(4);...
                         Hi_x(5,:)*Pc/torq_conv*tran_rate(5)/torque_constant(5);...
                         Hi_x(6,:)*Pc/torq_conv*tran_rate(6)/torque_constant(6)];
            I_MC_meas(:,i) = [iden_data(i,4,1)';...
                              iden_data(i,4,2)';...
                              iden_data(i,4,3)';...
                              iden_data(i,4,4)';...
                              iden_data(i,4,5)';...
                              iden_data(i,4,6)'];
                    
        end

        diff_I_MC = [diff(I_MC(1,:)/0.004);...
                     diff(I_MC(2,:)/0.004);...
                     diff(I_MC(3,:)/0.004);...
                     diff(I_MC(4,:)/0.004);...
                     diff(I_MC(5,:)/0.004);...
                     diff(I_MC(6,:)/0.004)];
        diff_I_MC_meas = [diff(I_MC_meas(1,:)/0.004);...
                          diff(I_MC_meas(2,:)/0.004);...
                          diff(I_MC_meas(3,:)/0.004);...
                          diff(I_MC_meas(4,:)/0.004);...
                          diff(I_MC_meas(5,:)/0.004);...
                          diff(I_MC_meas(6,:)/0.004)];
        V_MC = [L(1)*diff_I_MC(1,:) + R(1)*I_MC(1,1:end-1);...
                L(2)*diff_I_MC(2,:) + R(2)*I_MC(2,1:end-1);...
                L(3)*diff_I_MC(3,:) + R(3)*I_MC(3,1:end-1);...
                L(4)*diff_I_MC(4,:) + R(4)*I_MC(4,1:end-1);...
                L(5)*diff_I_MC(5,:) + R(5)*I_MC(5,1:end-1);...
                L(6)*diff_I_MC(6,:) + R(6)*I_MC(6,1:end-1)];
        
        V_MC_meas = [L(1)*diff_I_MC_meas(1,:) + R(1)*I_MC_meas(1,1:end-1);...
                     L(2)*diff_I_MC_meas(2,:) + R(2)*I_MC_meas(2,1:end-1);...
                     L(3)*diff_I_MC_meas(3,:) + R(3)*I_MC_meas(3,1:end-1);...
                     L(4)*diff_I_MC_meas(4,:) + R(4)*I_MC_meas(4,1:end-1);...
                     L(5)*diff_I_MC_meas(5,:) + R(5)*I_MC_meas(5,1:end-1);...
                     L(6)*diff_I_MC_meas(6,:) + R(6)*I_MC_meas(6,1:end-1)];
      
        Ps_MC = [I_MC(1,1:end-1).*V_MC(1,:);...
                 I_MC(2,1:end-1).*V_MC(2,:);...
                 I_MC(3,1:end-1).*V_MC(3,:);...
                 I_MC(4,1:end-1).*V_MC(4,:);...
                 I_MC(5,1:end-1).*V_MC(5,:);...
                 I_MC(6,1:end-1).*V_MC(6,:)];
      
        Ps_MC_meas = [I_MC_meas(1,1:end-1).*V_MC_meas(1,:);...
                      I_MC_meas(2,1:end-1).*V_MC_meas(2,:);...
                      I_MC_meas(3,1:end-1).*V_MC_meas(3,:);...
                      I_MC_meas(4,1:end-1).*V_MC_meas(4,:);...
                      I_MC_meas(5,1:end-1).*V_MC_meas(5,:);...
                      I_MC_meas(6,1:end-1).*V_MC_meas(6,:)];
        
        P_MC = [Ps_MC(1,:)+...
                Ps_MC(2,:)+...
                Ps_MC(3,:)+...
                Ps_MC(4,:)+...
                Ps_MC(5,:)+...
                Ps_MC(6,:)];
     
        P_MC_meas = [Ps_MC_meas(1,:)+...
                     Ps_MC_meas(2,:)+...
                     Ps_MC_meas(3,:)+...
                     Ps_MC_meas(4,:)+...
                     Ps_MC_meas(5,:)+...
                     Ps_MC_meas(6,:)];
       
        odch = mean(abs(P_MC(1,1:step:end)-P_MC_meas(1,1:step:end)));
        MC(j,k,:)=[rnd2*range odch]; 
        Pc = Pc_x;
   
        clear I_MC I_MC_meas
        [j k]
    end
end

%%
MC_max = zeros(length(Pc),1);

for i=1:length(Pc)
    
MC_max(i) = max(MC(i,:,2));

end

close all

figure
plot(MC(43,:,1),(MC(43,:,2))/mean(abs(P_MC_meas(1,1:step:end)))*100,'*','Linewidth',3)
grid on
title('Vliv odchylky koeficientu viskózního tøení osy 1')
xlabel('Odchylka parametru - násobek f_{v} osy 1')
ylabel('Relativní odchylka [%]')

figure
plot(MC(45,:,1),(MC(45,:,2))/mean(abs(P_MC_meas(1,1:step:end)))*100,'*','Linewidth',3)
grid on
title('Vliv odchylky koeficientu viskózního tøení osy 2')
xlabel('Odchylka parametru - násobek f_{v} osy 2')
ylabel('Relativní odchylka [%]')

figure
plot(MC(27,:,1),(MC(27,:,2))/mean(abs(P_MC_meas(1,1:step:end)))*100,'*','Linewidth',3)
grid on
title('Vliv odchylky hmotnosti ramena osy 3')
xlabel('Odchylka parametru - násobek m osy 3')
ylabel('Relativní odchylka [%]')

figure
plot(MC(31,:,1),(MC(31,:,2))/mean(abs(P_MC_meas(1,1:step:end)))*100,'*','Linewidth',3)
grid on
title('Vliv odchylky hmotnosti ramena osy 4')
xlabel('Odchylka parametru - násobek m osy 4')
ylabel('Relativní odchylka [%]')

