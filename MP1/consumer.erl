-module(consumer).

-export([start/1,consumer_init/1]).

%Start function.
%Spawns the consume that will consume Number values.
start(Number) ->
    
    spawn(?MODULE,consumer_init,[Number]).


consumer_init(Number)->
    io:format("Consumer was initialised!~n"),
    loop(Number).

%Main loop of the consumer.
%Consumes until the bounded buffer sends a value. (If it is not empty)
%After the bounded buffer accepts the value, the producer moves to the next iteration.
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
    
    

    