-module(counter).

-export([start/0, count_server/0]).


start() -> 
    spawn(?MODULE, count_server, []). 

count_server() -> 
    io:format("Counter was initialised!~n"),
    loop(0). 

loop(Sum) -> % local function, not accessible from outside the module
    receive{inc, Num} 
        when is_number(Num) -> loop(Sum + Num);  
            reset -> io:format("Counter was reset!~n"), loop(0);  
            read -> io:format("Current counter value is ~p~n", [Sum]), loop(Sum);    
            stop -> io:format("Final counter value is ~p~n", [Sum]);    
            Msg -> io:format("Message discarded: ~p~n", [Msg]), loop(Sum)
    end.