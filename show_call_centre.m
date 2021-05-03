% show_call_centre.m
%
% plot all the results from program call_centre.m. The data file of call_centre.m 
% must first be loaded into Matlab workspace before running this program.

arr_rate = 2/3;
serv_time = 1.5;
buffer_cap = Inf;
total_operator = 1;
sim_time = 180;

[block_prob, wait_time, queue_size, busy_operator_1, sys_size] = call_centre(arr_rate,serv_time,buffer_cap,total_operator,sim_time);

figure;

subplot(3,2,1);
stairs(queue_size(2,:), queue_size(1,:));
axis([0, sim_time, 0, buffer_cap]);
xlabel('Time'); ylabel('Size');
title('Queue')

subplot(3,2,3); 
stairs(busy_operator_1(2,:), busy_operator_1(1,:), 'r-'); hold on;
%stairs(busy_operator_2(2,:), busy_operator_2(1,:), 'g--'); hold on;
%stairs(busy_operator_3(2,:), busy_operator_3(1,:), 'b:'); hold on;
axis([0, sim_time, 0, max(total_operator)+1]);
xlabel('Time'); ylabel('Busy Operators');
title('Server');
%legend('group 1');

subplot(3,2,5);
stairs(sys_size(2,:), sys_size(1,:), 'g-');
axis([0, sim_time, 0, max(sys_size(1,:))]);
xlabel('Time'); ylabel('Customer');
title('Total customer in system');

subplot(3,2,2)
h = histogram(sys_size(1,:),'Normalization','probability'); 
h.BinLimits = [1,ceil(max(sys_size(1,:)))+1];
h.BinWidth = 0.5;
h.FaceColor = 'r';
%bar(temp2, temp1/length(sys_size(1,:)), 0.2);
xlabel(['Mean = ', num2str(mean(sys_size(1,:))), ', SD = ', num2str(std(sys_size(1,:)))]); 
ylabel('P[x]');
title('P[x customer in system]');

subplot(3,2,4); 
h2 = histogram(wait_time,'Normalization','probability');
h2.FaceColor = 'g';
h2.BinWidth = 1;
%[temp1, temp2] = hist(wait_time); 
%bar(temp2, temp1/length(wait_time), 0.2);
xlabel(['Mean = ', num2str(mean(wait_time)), ', SD = ', num2str(std(wait_time))]); 
ylabel('P[x]');
title('P[waiting time x]');

sgtitle(['Arrival Rate (\lambda) = ', num2str(arr_rate), ...
       ', Service Time (^{1}/_{\mu}) = ', num2str(serv_time), ...
       ', Buffer Capacity (K) = ', num2str(buffer_cap), ...
       ', Total Operators (c) = ', num2str(total_operator), ...
       ', Blocking Probability (B) = ', num2str(block_prob)])

% Written by Dr C Aswakul (14 August 2002)

