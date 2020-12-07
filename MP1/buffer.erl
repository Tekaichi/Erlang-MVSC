-module(buffer).
-export([start/1,bounded_buffer/1]).

start(Size) ->
    register(bounded_buffer, spawn(?MODULE,bounded_buffer,[Size])).


%LIFO buffer.
%Buffer starting point.
bounded_buffer(Size)->
    io:format("Buffer was initialised, with size ~p!~n",[Size]),
    loop(Size,[]).

loop(Size,Values)-> 
    
    %Blocks until it receives something from the message queue
    receive {produce,Value,Client}
      %If this process receives this pattern and the Value is a number, tries to add it to the list if not full.
      %Sends back to the producer {reply,Value} if success
      %Sends back to the producer full if the value could not be added because buffer was full.
      when is_number(Value) ->  
        if length(Values) < Size ->
            io:format("Added ~p~n",[Value]), Client ! {reply,Value},loop(Size,[Value | Values]);
        true ->
            io:format("Buffer is full!~n"),Client ! full, loop(Size,Values)
        end;

      %If this process receives this pattern, it tries to remove the tail value of the list and return it to the consumer.
      %Sends back to the consumer {reply,Value} if success
      %Sends back to the producer empty if the value could not be retrieved because the buffer was empty.
      {consume,Client} -> 
          if length(Values) == 0 ->
                io:format("Buffer is empty!~n"), Client! empty, loop(Size,Values);
        true ->
          REV = lists:reverse(Values),
          REMOVED = hd(REV),
          io:format("Removed ~p~n",[REMOVED]),Client !  {reply,REMOVED} , loop(Size,lists:reverse(tl(REV)))
        end;
        
      %Prints the elements in the buffer.
      read -> io:format("All Elements ~p~n",[Values]),loop(Size,Values);
    
      %Unknown message, discards it.
      Msg -> io:format("Message discarded: ~p~n", [Msg]), loop(Size,Values)

    end.


