function [v_o1,g_opt,i] = sgd_opt(I_ref,I_meas,Vs_est, alpha)


Ts = 25e-6;
L = 1e-3;
K = Ts/L;
R = 1;

% Voltage vectors v0 = 0; v1 = 2/3*Vdc; v2 = 1/3*Vdc + 1j*sqrt(3)/3*Vdc; v3
% = -1/3*Vdc + 1j*sqrt(3)/3*Vdc; v4 = -2/3*Vdc; v5 = -1/3*Vdc -
% 1j*sqrt(3)/3*Vdc; v6 = 1/3*Vdc - 1j*sqrt(3)/3*Vdc; v7 = 0; v = [v0 v1 v2
% v3 v4 v5 v6 v7];

% Read current reference inputs at sampling instant k
ik_ref = I_ref;
% Read current measurements at sampling instant k
ik = I_meas;

epsilon = 1e-5;
i=0;
g_opt = 1e10;
v_o1 = 0;
e=1e5;

ik1 = K*v_o1 - K*Vs_est + (1-R*K)*ik;
% initial cost
g = (ik_ref - ik1)^2;
grad_g = -2*K*(ik_ref - (K*v_o1 - K*Vs_est + (1-R*K)*ik));

while e > epsilon
    
    grad_g = -2*K*(ik_ref - (K*v_o1 - K*Vs_est + (1-R*K)*ik));
    v_o1 = v_o1 - alpha * grad_g;
    
    ik1 = K*v_o1 - K*Vs_est + (1-R*K)*ik;
%     g = (ik_ref - ik1)^2;
    g_opt = (ik_ref - ik1)^2;  
    
    e = g - g_opt;
    i = i+1;
    g = g_opt;
end
g = (ik_ref - ik1)^2;