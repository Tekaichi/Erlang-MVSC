-module(node).
%Here we define each node.

%Starts with an id, and the ref to the right node.
%Needs ref to the supervisor to announce that a leader has been found. (?)

%Define a method for each state (?)


start(Id,Supervisor) -> %spawn something
  spawn(?MODULE,init,[Id,Supervisor]).
.

init(Id,Supervisor) -> %STEP B1
    set_next(Id,Supervisor).



active(Id,Supervisor,Next,Max,Phase)->
    Next !{Max,Phase,counter} % Check this counter thing.
    
    %receive... is on the active state so should only get messages of type M1? There is a simplification here so that we dont need to send the message type. SEE PAPER
    .
waiting(Id,Supervisor,Next,Max,Phase)->
    {}.
passive(Id,Supervisor,Next,Max,Phase)->
    {}.

set_next(Id,Supervisor) ->
    receive{node,Next}->
        active(Id,Supervisor,Next,Id,0) 
    end
    .



