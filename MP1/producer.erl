-module(producer).

-export([start/1,producer_init/1]).

start(Number) ->
    
    spawn(?MODULE,producer_init,[Number]).


producer_init(Number)->
    io:format("Producer was initialised!~n"),
    loop(Number).


loop(Number)-> 
    %If Number == 0, stop consuming.
    if Number > 0 ->
    bounded_buffer ! {produce,Number,self()},
        receive 
            {reply,Value} -> io:format("Produced ~p~n",[Value]),loop(Number-1);
            Msg -> io:format("Could not produce. Got: ~p~n",[Msg]),loop(Number) 
        end;
    true -> io:format("Done producing")
    end.
    
    

    