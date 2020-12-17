-module(node).
-import(math,[pow/2]).

%Here we define each node.

%Starts with an id, and the ref to the right node.
%Needs ref to the supervisor to announce that a leader has been found. (?)

%Define a method for each state (?)


start(Id,Supervisor) -> %spawn something
  spawn(?MODULE,init,[Id,Supervisor]).


init(Id,Supervisor) -> %STEP B1
    set_next(Id,Supervisor).


%See if message type really needs to be on the message or if we can fully implement a type of state machine.

active(Id,Supervisor,Next,Max,Phase)->
    Next !{Max,Phase,pow(2,Phase)}, % Check this counter thing.
    receive {Max,Phase,Counter} ->
        if Id > Max -> 
            waiting(Id,Supervisor,Next,Id,Phase);
        true -> 
            Next ! {Max},
            passive(Id,Supervisor,Next,Max,Phase)
        end
    end.
    %receive... is on the active state so should only get messages of type M1? There is a simplification here so that we dont need to send the message type. SEE PAPER
    
waiting(Id,Supervisor,Next,Max,Phase)->
   receive {Max,Phase,Counter} ->
       passive(Id,Supervisor,Next,Max,Phase);
    {Max} ->
        active(Id,Supervisor,Next,Max,Phase + 1)
    end.
    
passive(Id,Supervisor,Next,Max,Phase)->
    receive {Max,Phase,Counter} ->
        if Id >= Max, Counter >= 1 ->
        {} %If counter > 1 send {i,phase,counter}
        end;
    {Max} ->
         if Id > Max ->
          {};
        true ->  {}
    end
    end.

set_next(Id,Supervisor) ->
    receive{node,Next}->
        active(Id,Supervisor,Next,Id,0)
    end.



