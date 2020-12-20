-module(node).
-import(math,[pow/2]).

-export([start/2,init/2]).
%Here we define each node.

%Starts with an id, and the ref to the right node.
%Needs ref to the supervisor to announce that a leader has been found. (?)

%Define a method for each state (?)


start(Id,Supervisor) -> %spawn something
  spawn(?MODULE,init,[Id,Supervisor]).


init(Id,Supervisor) -> %STEP B1
    io:format("Set ~p~n as next.",[Id]),
    set_next(Id,Supervisor).


%See if message type really needs to be on the message or if we can fully implement a type of state machine.

active(Id,Supervisor,Next,Max,Phase)->
    io:format("~p is active ~n",[self()]),
    Next !{Max,Phase,pow(2,Phase)}, % Check this counter thing.
    io:format("~p sent M1 ~p ~p ~p to ~p ~n",[self(),Max,Phase,pow(2,Phase),Next]),
    receive {I,_P,C} ->
       if I == Id -> 
           io:format("~p is the leader. ~n",[Id]);
        true ->
            if I > Max -> 
                waiting(Id,Supervisor,Next,I,C);
            true -> 
                Next ! {Max},
                passive(Id,Supervisor,Next,Max,C)
            end
        end;
    Msg -> io:format("Active ~p ~p Could not consume. Got: ~p~n",
    [Id,self(),Msg]), active(Id,Supervisor,Next,Max,Phase)

    end.
    %receive... is on the active state so should only get messages of type M1? There is a simplification here so that we dont need to send the message type. SEE PAPER
    
waiting(Id,Supervisor,Next,Max,Phase)->
   io:format("~p is waiting ~n",[self()]),
   receive {I,_P,_C} ->
       if I == Id -> 
           io:format("~p ~p is the leader. ~n",[Id,self()]);
       true ->
           passive(Id,Supervisor,Next,Max,Phase)
        end;
    {M} ->
        %This m should be equal to max
        if Id == M ->     
            io:format("~p ~p is the leader. ~n",[Id,self()]);
        true ->
        active(Id,Supervisor,Next,Max,Phase + 1)    

        end;
    Msg -> 
        io:format("Waiting ~p ~p Could not consume. Got: ~p~n",[Id,self(),Msg])
    end.
    
passive(Id,Supervisor,Next,Max,Phase)->
    io:format("~p is passive ~n",[self()]),
    receive
     {I,P,C} ->
        if I == Id -> 
            io:format("~p is the leader. ~n",[Id]);

        true ->
            if (I >= Max) and (C >= 1) ->
         %If counter > 1 send {i,phase,counter}
                if C > 1 ->
            	    Next !{I,P,C-1};
                true -> %When C == 1
                    Next ! {I,P,0},
                    waiting(Id,Supervisor,Next,Max,P)
                 end;
            true ->
                 Next! {I,P,0}
           
            end
    
        end;
    {M} ->
        io:format("~p M2 ~p ~n",[self(),M]),
        if 
            M > Max ->
                Next !{M};
            Id == M ->
                io:format("~p is the leader. ~n",[Id]);

        true ->  pass
        end;

    Msg -> 
        io:format("Passive ~p ~p Could not consume. Got: ~p~n",[Id,self(),Msg])
   
   
    end,
    passive(Id,Supervisor,Next,Max,Phase).

set_next(Id,Supervisor) ->
    receive{node,Next}->
        active(Id,Supervisor,Next,Id,0)
    end.



