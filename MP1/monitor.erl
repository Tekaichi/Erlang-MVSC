-module(monitor).

-export([init/1,monitor_init/1]).

-import(buffer,[start/1]).


init(Size) ->
    
   spawn(?MODULE,monitor_init,[Size]).
   


monitor_init(Size) -> 
	
	io:format("Starting Bounded Buffer...~n"),
    %Starts buffer with size Size.
	buffer:start(Size),

    %Makes this processa a monitor
	monitor(process, bounded_buffer),
	io:format("Started Monitoring Bounded Buffer...~n"),

	receive
    {'DOWN', _Ref, process, Pid, Why} ->
        io:format("~p Bounded Buffer died because ~p~n",[Pid,Why]),
        % Restart buffer.
        monitor_init(Size)
    end.
