% function [block_prob, wait_time, queue_size, busy_operator_1, 
%           busy_operator_2, busy_operator_3] 
%
%           = call_centre(arr_rate, serv_time, buffer_cap, 
%                         total_operator, sim_time)
%
% simulates a call centre with the structure in the diagram below. Buffer is 
% first-in-first-out. Scheduler forwards calls to each group of operators 
% randomly if there are available (not busy) operators in more than two groups.
% Calls arrive according to a Poisson process and their service times are
% indendent and exponentially distributed.
%
%
%                                       +-> group 1 of operators ->
%  call       -------+     +---------+  |                             call
% arrival ==>  buffer| ==> |scheduler|==+-> group 2 of operators -> departure
%             -------+     +---------+  |                          
%                                       +-> group 3 of operators ->
%
%
% << INPUT PARAMETERS >>
% arr_rate           : mean arrival rate
% serv_time          : mean service time
% buffer_cap         : buffer capacity (maximum number of waiting calls)
% total_operator(i)  : total number of operators working in group i (i = 1,2,3)
% sim_time           : simulation time
%
% << OUTPUT PARAMETERS >>
% block_prob         : call blocking probability
% wait_time(i)       : waiting time of the i-th call getting through the buffer
% queue_size         : time history of queue size (the number of waiting calls
%                      in buffer). Format: queue size equals to queue_size(1,i)
%                      when time is queue_size(2,i). The time history can be
%                      plotted by "stairs(queue_size(2,:), queue_size(1,:))".
% busy_operator_j    : time history of the number of busy operators in group j 
% (j = 1,2,3)          Format: same as parameter queue_size.
%  
%
% << EXAMPLE >>
%
% >> call_centre(5, 20, 10, [20 30 40], 1e2); % run simulation
% >> load call_centre.mat; show_call_centre;  % plot simulation outputs
%
% << NOTES >>
% 1. This program saves all variables into file <call_centre.mat>
% 2. The program outputs can be plotted by running <show_call_centre.m>
%    (see the above example).


function [block_prob, wait_time, queue_size, busy_operator_1, sys_size] ...
          = call_centre(arr_rate, serv_time, buffer_cap, ...
                        total_operator, sim_time)

start_time = cputime; % start_time records the start time of this program
                      % (used later in calculating the time spent by the program)

                      
%%%%%%%%%%%%%%%
% Inialisation 
%

current_time = 0; % current time in simulation loop
block_arr    = 0; % the number of blocked calls
total_arr    = 0; % the total number of calls

arr_time_in_buffer  = [inf]; % vector specifying the arrival times of calls 
                             % waiting in buffer. Its 2nd element denotes the 
                             % arrival time of most recent call in buffer.
                             % Its last element is the arrival time of eldest 
                             % call in buffer.
                             %
                             % Example 1 :: arr_time_in_buffer = [inf 5 1]
                             % means that the buffer is containing two calls
                             % arriving at time 1 and 5.
                             %
                             % Example 2 :: arr_time_in_buffer = [inf]
                             % means that the buffer is now empty.
                             %
                             % Example 3 :: if length(arr_time_in_buffer) is
                             % greater than buffer_cap, then the buffer is full.

                             
dep_time_in_group_1 = [inf]; % dep_time_in_group_j is the vector that specifies
%dep_time_in_group_2 = [inf]; % the sorted (in descending order) departure times
%dep_time_in_group_3 = [inf]; % of calls being served in group j (j = 1,2,3).
                             % 
                             % Example 1 :: dep_time_in_group_1 = [inf 5 1]
                             % means that group 1 is serving two calls that
                             % will depart from the group (after call completion) 
                             % at time 1 and 5.
                             %
                             % Example 2 :: dep_time_in_group_1 = [inf]
                             % means that group 1 is serving no calls and all
                             % its operators are not busy.
                             %
                             % Example 3 :: if length(dep_time_in_group_1) is
                             % greater than total_operator(1), then all the
                             % operators in group 1 are busy.

wait_time       = [];
queue_size      = [length(arr_time_in_buffer) - 1; current_time];
busy_operator_1 = [length(dep_time_in_group_1) - 1; current_time]; 
%busy_operator_2 = [length(dep_time_in_group_2) - 1; current_time]; 
%busy_operator_3 = [length(dep_time_in_group_3) - 1; current_time]; 

sys_size        = [(length(arr_time_in_buffer) - 1)+(length(dep_time_in_group_1) - 1);current_time];

%%%%%%%%%%%%%%%%%%
% Simulation Loop
%

% find the time of next call arrival %
next_arr_time = current_time + random('exp', 1/arr_rate);

% define temporary variable for displaying simulation progress %
loop_time = 0;

% begin simulation loop and check for stopping criteria %
while (current_time <= sim_time)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Display simulation progress
    %

    previous_loop_time = loop_time;
    loop_time = ceil(cputime - start_time);

    if loop_time > previous_loop_time
        
        disp(['simulation progress ', num2str(round(current_time/sim_time*100)), ...
              '% after ', num2str(loop_time),' seconds']);
        
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find next event (as specified by event_type) and its time
    %
    
    temp = [dep_time_in_group_1(end), next_arr_time];%dep_time_in_group_2(end), ...
           % dep_time_in_group_3(end), ;
    
    [current_time, event_type] = min(temp);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Next event is call departure from the group specified by event_type
    %

    if event_type == 1, if arr_time_in_buffer(end) == inf 
            
        %%% Buffer is empty                                             %%%
        %%% Delete the record of departing call from group "event_type" %%%

        %switch event_type
            
        %case 1
        dep_time_in_group_1 = dep_time_in_group_1(1: length(dep_time_in_group_1) - 1);
        busy_operator_1 = [busy_operator_1, [length(dep_time_in_group_1) - 1; current_time]];
        
        %case 2
        %dep_time_in_group_2 = dep_time_in_group_2(1: length(dep_time_in_group_2) - 1);
        %busy_operator_2 = [busy_operator_2, [length(dep_time_in_group_2) - 1; current_time]];
        
        %case 3
        %dep_time_in_group_3 = dep_time_in_group_3(1: length(dep_time_in_group_3) - 1);
        %busy_operator_3 = [busy_operator_3, [length(dep_time_in_group_3) - 1; current_time]];
        
        %end
    
    else
            
        %%% Buffer is not empty                                  %%%
        %%% Move the eldest call in buffer to group "event_type" %%%
            
        wait_time = [wait_time, current_time - arr_time_in_buffer(end)];
            
        arr_time_in_buffer = arr_time_in_buffer(1: length(arr_time_in_buffer) - 1);
        queue_size = [queue_size, [length(arr_time_in_buffer) - 1; current_time]];
            
        new_dep_time = current_time + random('exp', serv_time);

        %switch event_type
            
        %case 1
        dep_time_in_group_1 = sort([dep_time_in_group_1(1:end-1), new_dep_time], 'descend');
        busy_operator_1 = [busy_operator_1, [length(dep_time_in_group_1) - 1; current_time]];
        
        %case 2
        %dep_time_in_group_2 = sort([dep_time_in_group_2(1:end-1), new_dep_time], 'descend');
        %busy_operator_2 = [busy_operator_2, [length(dep_time_in_group_2) - 1; current_time]];
        
        %case 3
        %dep_time_in_group_3 = sort([dep_time_in_group_3(1:end-1), new_dep_time], 'descend');
        %busy_operator_3 = [busy_operator_3, [length(dep_time_in_group_3) - 1; current_time]];
        
        %end
            
    end; end        


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Next event is call arrival
    %

    if event_type == 2

    next_arr_time = next_arr_time + random('exp', 1/arr_rate);

    if length(arr_time_in_buffer) > buffer_cap
            
        %%% Buffer is full    %%%
        %%% Block the arrival %%%

        total_arr = total_arr + 1;
        block_arr = block_arr  + 1;
           
    else
            
        if length(dep_time_in_group_1) > total_operator %&& ...
           %length(dep_time_in_group_2) > total_operator(2) && ...
           %length(dep_time_in_group_3) > total_operator(3)

        %%% Buffer is not full and all operators are busy %%%
        %%% Add the call in buffer                        %%%

        total_arr = total_arr + 1;

        arr_time_in_buffer    = [current_time, arr_time_in_buffer];
        arr_time_in_buffer(2) = arr_time_in_buffer(1);
        arr_time_in_buffer(1) = inf;

        queue_size = [queue_size, [length(arr_time_in_buffer) - 1; current_time]];
        
        else
        
        %%% Buffer is not full and not all operators are busy %%%
        %%% Forward call to an operator                       %%%

        total_arr = total_arr + 1;
        wait_time = [wait_time, 0];
        
        % Find the group of operators to which call will be forwarded : to_group %
        
        %temp = [length(dep_time_in_group_1) <= total_operator(1), ...
        %        2*(length(dep_time_in_group_2) <= total_operator(2)), ...
        %        3*(length(dep_time_in_group_3) <= total_operator(3))];

        %to_group = 0; 
        
        %while to_group == 0 
        %    to_group = temp(min(3, ceil(3*rand))); 
        %end

        % Forward call to an operator in to_group %
        
        new_dep_time = current_time + random('exp', serv_time);

        %switch to_group
            
        %case 1
        dep_time_in_group_1 = sort([dep_time_in_group_1, new_dep_time], 'descend');
        busy_operator_1 = [busy_operator_1, [length(dep_time_in_group_1) - 1; current_time]];
            
        %case 2
        %dep_time_in_group_2 = sort([dep_time_in_group_2, new_dep_time], 'descend');
        %busy_operator_2 = [busy_operator_2, [length(dep_time_in_group_2) - 1; current_time]];
            
        %case 3
        %dep_time_in_group_3 = sort([dep_time_in_group_3, new_dep_time], 'descend');
        %busy_operator_3 = [busy_operator_3, [length(dep_time_in_group_3) - 1; current_time]];
            
        %end
        
    end; end; end

    sys_size = [sys_size,[(length(arr_time_in_buffer) - 1)+(length(dep_time_in_group_1) - 1);current_time]];


end %%% END OF WHILE LOOP %%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate blocking probability
%

block_prob = block_arr / total_arr;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save program outputs in data file
%

spent_seconds = cputime - start_time;
temp = whos; spent_bytes = sum([temp.bytes]);

save call_centre.mat;


% Written by Dr Chaodit Aswakul (14 August 2002)
