-module(producer).

-export([start/2,producer/2]).

start(Number,Buffer) ->
    
    spawn(?MODULE,producer,[Number,Buffer]).


producer(Number,Buffer)->
    io:format("Producer was initialised!~n"),
    loop(Number,Buffer).


loop(Number,Buffer)-> 
    %If Number == 0, stop consuming.
    if Number > 0 ->
    Buffer ! {produce,Number,self()},
        receive 
            {reply,Value} -> io:format("Produced ~p~n",[Value]),loop(Number-1,Buffer);
            Msg -> io:format("Could not produce. Got: ~p~n",[Msg]),loop(Number,Buffer)
        end
    end.
    
    

    