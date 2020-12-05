-module(consumer).

-export([start/2,consumer/2]).

start(Number,Buffer) ->
    
    spawn(?MODULE,consumer,[Number,Buffer]).


consumer(Number,Buffer)->
    io:format("Consumer was initialised!~n"),
    loop(Number,Buffer).


loop(Number,Buffer)-> 
    %If Number == 0, stop consuming.
    if Number > 0 ->
    Buffer ! {consume,self()},
        receive 
            {reply,Value} -> io:format("Consumed ~p~n",[Value]),loop(Number-1,Buffer);
            Msg -> io:format("Could not consume. Got: ~p~n",[Msg]),loop(Number,Buffer)
        end
    end.
    
    

    