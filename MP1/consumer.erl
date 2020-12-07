-module(consumer).

-export([start/1,consumer/1]).

start(Number) ->
    
    spawn(?MODULE,consumer,[Number]).


consumer(Number)->
    io:format("Consumer was initialised!~n"),
    loop(Number).


loop(Number)-> 
    %If Number == 0, stop consuming.
    if Number > 0 ->
    bounded_buffer ! {consume,self()},
        receive 
            {reply,Value} -> io:format("Consumed ~p~n",[Value]),loop(Number-1);
            Msg -> io:format("Could not consume. Got: ~p~n",[Msg]),loop(Number)
        end;
    true -> io:format("Done consuming")
    end.
    
    

    