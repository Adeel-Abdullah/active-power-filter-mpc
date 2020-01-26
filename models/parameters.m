newData1 = load('-mat', "matlab");

% Create new variables in the base workspace from those fields.
vars = fieldnames(newData1);
for i = 1:length(vars)
    assignin('base', vars{i}, newData1.(vars{i}));
end
clear('Ts');

global Ts L v R states

Ts = 2e-6;
L = AF.activefilter.Laf;
% Vdc = AF.activefilter.voltage*3;
Vdc = 1200;
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
% Switching states
states = [0 0 0;1 0 0;1 1 0;0 1 0;0 1 1;0 0 1;1 0 1;1 1 1];

clear('i');
clear('vars');
clear('newData1');
clear('tout');