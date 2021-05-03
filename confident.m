x = 0:0.01:0.9;

arr_rate = 1/3;
serv_time = 2;
buffer_cap = 999;
total_operator = 1;
sim_time = 180;

batch = 20;
count = 10;

erlang = arr_rate*serv_time;
real = mean_cus(erlang);

y1 = mean_cus(x);
y2 = y1*serv_time;

%[sys_size_total, wait_time_total] = call_yeet_2(arr_rate, serv_time, buffer_cap,...
%   total_operator, sim_time, batch, count);

CI95 = tinv([0.025 0.975], count-1);
CI95_2 = tinv([0.025, 0.975], batch-1);

% Customer CI
mean_each = mean(sys_size_total);

mean_total = mean(mean_each);
sem = std(mean_each)/sqrt(batch);

yCI95 = CI95_2*sem;
err = yCI95+mean_total;

% Alt cust CI
ySEM = std(sys_size_total)/sqrt(count);
yCI95_yee = bsxfun(@times, ySEM, CI95(:));

% Waiting Time CI
mean_each_2 = mean(wait_time_total);

mean_total_2 = mean(mean_each_2);
sem_2 = std(mean_each_2)/sqrt(batch);

yCI95_2 = CI95_2*sem_2;
err2 = yCI95_2+mean_total_2;

%Alt time CI
ySEM2 = std(wait_time_total)/sqrt(count);
yCI95_yee2 = bsxfun(@times, ySEM2, CI95(:));

mmm = max(sys_size_total)-mean_each;
nnn = -min(sys_size_total)+mean_each;

mmmm = max(wait_time_total)-mean_each_2;
nnnn = -min(wait_time_total)+mean_each_2;

figure;

subplot(2,2,1);
plot(x,y1); hold on;
e = errorbar(erlang,mean_total,yCI95(2),yCI95(1), 'o');
e.LineWidth = 2;
e.CapSize = 10;
s = scatter(erlang, mean_each, batch*ones(1,batch), 'x');
xlabel('Utilization (\rho)');
ylabel('Customers (q)');
title('Mean no. of customers in M/M/1 system');

subplot(2,2,2);
ee = errorbar(1:batch, mean_each, yCI95_yee(2,:), yCI95_yee(2,:), 'o'); hold on;
ee.LineWidth = 2;
ee.CapSize = 10;
plot(0:batch+5, mean_cus(erlang)*ones(1,batch+6));
scatter(1:batch, sys_size_total, (batch+5)*ones(1, batch), 'x');
xlabel('Batch no.');
ylabel('Customers');

subplot(2,2,3);
plot(x,y2); hold on;
e2 = errorbar(erlang,mean_total_2,yCI95_2(2),yCI95_2(1), 'o');
e2.LineWidth = 2;
e2.CapSize = 10;
s2 = scatter(erlang, mean_each_2, batch*ones(1,batch), 'x');
xlabel('Utilization (\rho)');
ylabel('Waiting Time ( t_w )');
title('Mean waiting time in M/M/1 system');

subplot(2,2,4);
ee2 = errorbar(1:batch, mean_each_2, yCI95_yee2(2,:), yCI95_yee2(2,:), 'o'); hold on;
ee2.LineWidth = 2;
ee2.CapSize = 10;
plot(0:batch+5, serv_time*mean_cus(erlang)*ones(1,batch+6));
scatter(1:batch, wait_time_total, (batch+5)*ones(1, batch), 'x');
xlabel('Batch no.');
ylabel('Waiting time');


function [res] = mean_cus(x)
    r = [];
    for i=1: length(x)
        r = [r, x(i)/(1-x(i))];
    end
    res = r;
end

