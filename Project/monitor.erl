-module(monitor).

-export([init/0,monitor_init/0]).

-import(buffer,[start/1]).


%Starts the monitor.
init() ->
    
   spawn(?MODULE,monitor_init,[]).
   



monitor_init() -> 
	
	io:format("Starting Ring...~n"),
    %Starts buffer with size Size

    %Starts nodes.

    A = node:start(4,self()),
    monitor(process,A),
    B = node:start(12,self()),
    monitor(process,B),

    C = node:start(24,self()),
    monitor(process,C),

    D = node:start(-3,self()),
    monitor(process,D),

    E = node:start(23,self()),
    monitor(process,E),

    A ! {node,B}, B ! {node,C}, C ! {node,D}, D ! {node,E}, E ! {node,A},





    %Makes this processa a monitor

	io:format("Started Monitoring Node Ring..~n"),
    monitor_loop().



monitor_loop() -> 	
    receive
    {'DOWN', _Ref, process, Pid, Why} ->
        io:format("~p died because ~p~n",[Pid,Why]),
        % Restart buffer.
       monitor_loop
      
    end.