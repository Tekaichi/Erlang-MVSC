-module(buffer).

-export([start/1,bounded_buffer/1]).

start(Size) ->
    spawn(?MODULE,bounded_buffer,[Size]).


%Right now is a LIFO buffer.
bounded_buffer(Size)->
    io:format("Buffer was initialised!~n"),
    loop(Size,[]).

loop(Size,Values)-> 
    receive {produce,Value}
      when is_number(Value) ->  
        if length(Values) < Size ->
            io:format("Added ~p~n",[Value]), loop(Size,[Value | Values]);
        true ->
            io:format("Buffer is full!~n"),loop(Size,[Values])
        end;

      {consume,Client}   -> io:format("Removed ~p~n",[hd(Values)]),Client ! hd(Values) , loop(Size,tl(Values));
    
      read -> io:format("All Elements ~p~n",[Values]),loop(Size,Values);
    
      Msg -> io:format("Message discarded: ~p~n", [Msg]), loop(Size,Values)

    end.


