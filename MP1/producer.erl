-module(producer).

-export([start/1,producer_init/1]).

%Start function.
%Spawns the producer that will produce Number values.
start(Number) ->
    
    spawn(?MODULE,producer_init,[Number]).


producer_init(Number)->
    io:format("Producer was initialised!~n"),
    loop(Number).


%Main loop of the producer.
%Produces the same value until the bounded buffer accepts its. (If it is not full)
%After the bounded buffer accepts the value, the producer moves one iteration.
loop(Number)-> 
    
    if Number > 0 ->
    bounded_buffer ! {produce,Number,self()},
        receive 
            {reply,Value} -> io:format("Produced ~p~n",[Value]),loop(Number-1);
            Msg -> io:format("Could not produce. Got: ~p~n",[Msg]),loop(Number) 
        end;
    true -> io:format("Done producing")
    end.
    
    

    