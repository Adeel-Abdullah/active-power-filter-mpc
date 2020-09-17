
function [u1,u2,u3] = inv_clarke(Alpha,Beta,Zero)
u1 = (Alpha + (0 .* Beta) + Zero);
u2 = (((-1/2) .* Alpha) + ((sqrt(3)/2) .* Beta) + ((1) .* Zero));
u3 = (((-1/2) .* Alpha) - ((sqrt(3)/2) .* Beta) + ((1) .* Zero));
end
