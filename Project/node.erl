-module(node).
-import(math,[pow/2]).

-export([start/2,init/2]).
%Here we define each node.

%Starts with an id, and the ref to the right node.
%Needs ref to the supervisor to announce that a leader has been found. (?)

%Define a method for each state (?)


leader(Id,Next)->
    Next ! {leader,Id},
    exit({leader,Id}).

start(Id,Supervisor) -> %spawn something
  spawn(?MODULE,init,[Id,Supervisor]).


init(Id,Supervisor) -> %STEP B1
    %io:format("Spawned ~p with ~p ~n.",[Id,self()]),
    set_next(Id,Supervisor).


%See if message type really needs to be on the message or if we can fully implement a type of state machine.

active(Id,Supervisor,Next,Max,Phase)->
    %io:format("~p ~p is active. ~n",[self(),Id]),
    Next !{Max,Phase,pow(2,Phase)},
    %io:format("~p {M1} -> ~p~n",[self(),Next]),
    receive {I,_P,_C} ->
    
        if I > Max -> 
            waiting(Id,Supervisor,Next,I,Phase);
        true -> 
            Next ! {Max},
            %io:format("~p {M2} -> ~p~n",[self(),Next]),
            passive(Id,Supervisor,Next,Max,Phase)
        end;
        
    Msg -> 
        %io:format("Active ~p ~p Could not consume. Got: ~p~n",[Id,self(),Msg])
        Msg

    end.
    %receive... is on the active state so should only get messages of type M1? There is a simplification here so that we dont need to send the message type. SEE PAPER
    
waiting(Id,Supervisor,Next,Max,Phase)->
   %io:format("~p ~p is waiting. ~n",[self(),Id]),
   case 
       is_process_alive(Next) of 
           true ->
    receive {I,P,C} ->
        if I == Id -> 
            leader(Id,Next);
        true ->
            self() ! {I,P,C},
            passive(Id,Supervisor,Next,Max,Phase)
            end;
        {M} ->
            %This m should be equal to max
            if Id == M ->     
                leader(Id,Next);
            
            M == Max ->  
                
                active(Id,Supervisor,Next,Max,Phase + 1);
            true ->
                %io:format("ERROR: Waiting ~p != ~p ~n",[M,Max]),
                exit(error)

            end;
        Msg -> 
            %io:format("Waiting ~p ~p Could not consume. Got: ~p~n",[Id,self(),Msg])
            Msg
        end;
    false -> 
        io:format("~p says ~p is leader.~n",[Id,Max])
    end.
    
passive(Id,Supervisor,Next,Max,Phase)->
    %io:format("~p ~p is passive. ~n",[self(),Id]),
    case 
    is_process_alive(Next) of 
        true ->
        receive
        {I,P,C} ->
            if I == Id -> 
                leader(Id,Next);

            true ->
                if (I >= Max) and (C >= 1) ->
            %If counter > 1 send {i,phase,counter}
                    if C > 1 ->
                        Next !{I,P,C-1},
                        %io:format("~p {M1} -> ~p~n",[self(),Next]),

                        passive(Id,Supervisor,Next,Max,Phase);
                    
                    true -> %When C == 1
                        Next ! {I,P,0},
                        %io:format("~p {M1} -> ~p~n",[self(),Next]),
                        waiting(Id,Supervisor,Next,I,P)
                    end;
                true ->
                    Next! {I,P,0},
                    %io:format("~p {M1} -> ~p~n",[self(),Next]),
                    passive(Id,Supervisor,Next,Max,Phase)
            
                end
        
            end;
        {M} ->
        
            if 
                M  < Max ->
                %io:format("~p skipping.~n",[self()]),
                passive(Id,Supervisor,Next,Max,Phase);
                
                Id == M ->
                    leader(Id,Next);

            true -> 
                %io:format("~p {M2} -> ~p~n",[self(),Next]),
                Next !{M},
                passive(Id,Supervisor,Next,Max,Phase)
            end;

        Msg -> 
            %io:format("Passive ~p ~p Could not consume. Got: ~p~n",[Id,self(),Msg])
            Msg
    
        end;
    false -> 
        io:format("~p says ~p is leader.~n",[Id,Max])
end.
    
%Sets neighbour.
set_next(Id,Supervisor) ->
    receive{node,Next}->
        %io:format("~p -> ~p~n",[self(),Next]),
        active(Id,Supervisor,Next,Id,0)      
    end.




