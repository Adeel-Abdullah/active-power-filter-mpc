%test case 1
Vs = -3.195e2 + 5.1101e2i;
ik_ref = 37.1297 + 5.5988i;
ik = 44.3915 + 7.5527i;

% test case 2
% Vs = -0 - 0.2328i;
% ik_ref = -2.1530 -26.31i;
% ik = 0 + 0.0058i;

for j = 1:10000000
   
    [v,g,i]=sgd_opt(ik_ref,ik,Vs,800);
    
end

for j = 1:10000000
   
    [x,g] = fcs_opt(ik_ref,ik,Vs);
    
end