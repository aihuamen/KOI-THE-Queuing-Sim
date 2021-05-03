% function random implemented in octave
%
% written by: dr C Aswakul 99 Dec 2013)

function [random_num] = random (rand_type, dist_param)

if strcmp(rand_type, 'exp')
  random_num = exprnd(dist_param);
end

if strcmp(rand_type,'Poisson')
  random_num = poissrnd(dist_param);
end

