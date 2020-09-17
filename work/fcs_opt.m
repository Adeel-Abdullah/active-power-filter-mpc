function [Vx,g_opt] = fcs_opt(I_ref,I_meas,Vs_est)
Ts = 25e-6;
L = 1e-3;
Vdc = 1300;
R = 1;

% Voltage vectors
v0 = 0;
v1 = 2/3*Vdc;
v2 = 1/3*Vdc + 1j*sqrt(3)/3*Vdc;
v3 = -1/3*Vdc + 1j*sqrt(3)/3*Vdc;
v4 = -2/3*Vdc;
v5 = -1/3*Vdc - 1j*sqrt(3)/3*Vdc;
v6 = 1/3*Vdc - 1j*sqrt(3)/3*Vdc;
v7 = 0;
v = [v0 v1 v2 v3 v4 v5 v6 v7];

g_opt = 1e10;
x_opt = 1;

% % Read current reference inputs at sampling instant k
ik_ref = I_ref;
% % Read current measurements at sampling instant k
ik = I_meas;

for i = 1:8
    % i-th voltage vector for current prediction
    v_o1 = v(i);
    % Current prediction at instant k+1
    %ik1 = (1 - R*Ts/L)*ik + Ts/L*(v_o1 - e);
    
    % Current prediction at instant k+1
    ik1 = Ts/L*v_o1 - Ts/L*Vs_est + (1-R*Ts/L)*ik;
    % Cost function
    g = real(ik_ref - ik1)^2 + imag(ik_ref - ik1)^2;

%     g = abs(real(ik_ref - ik1)) + abs(imag(ik_ref - ik1));
    % Selection of the optimal value
    if (g<g_opt)
        g_opt = g;
        x_opt = i;
    end
end
Vx = v(x_opt);