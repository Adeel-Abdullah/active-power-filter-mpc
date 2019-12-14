newData1 = load('-mat', "matlab");

% Create new variables in the base workspace from those fields.
vars = fieldnames(newData1);
for i = 1:length(vars)
    assignin('base', vars{i}, newData1.(vars{i}));
end
clear('i');
clear('vars');
clear('newData1');
clear('tout');