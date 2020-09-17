clear;

load('test_data_log.mat');
d = struct;

for i = 1:logsout.numElements
%    d(logsout{i}.Name) = logsout{i}.Values.Data;
    d = setfield(d,logsout{i}.Name,logsout{i}.Values.Data);
end

d = setfield(d,'Time',logsout{i}.Values.Time);

for i = 1:length(d.Time)
    Vs = d.Vs(i,1) + d.Vs(i,2)*1j;
    ik_ref = d.Ir(i,1) + d.Ir(i,2)*1j;
    ik = d.Im(i,1) + d.Im(i,2)*1j;
    [v(i,1),g(i,1),c(i,1)] = sgd_opt(ik_ref,ik,Vs,800);
end

for i = 1:length(d.Time)
    Vs = d.Vs(i,1) + d.Vs(i,2)*1j;
    ik_ref = d.Ir(i,1) + d.Ir(i,2)*1j;
    ik = d.Im(i,1) + d.Im(i,2)*1j;
    [v(i,2),g(i,2)] = fcs_opt(ik_ref,ik,Vs);
end

%  e = v(:,1) - v(:,2);
% e = e .* conj(e);