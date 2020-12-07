-module(monitor).

-export([init/0,monitor_init/0]).

-import(buffer,[start/1]).
%-import(compile,[c/1]).

init() ->
    
   spawn(?MODULE,monitor_init,[]).
   


monitor_init() -> 
	
	io:format("Starting Bounded Buffer...~n"),
	buffer:start(5),

	monitor(process, bounded_buffer),
	io:format("Started Monitoring Bounded Buffer...~n"),

	receive
    {'DOWN', _Ref, process, Pid, Why} ->
        io:format("Bounded Buffer died because ~p~n",[Why]),
        % add the restart logic
        monitor_init()
    end.
