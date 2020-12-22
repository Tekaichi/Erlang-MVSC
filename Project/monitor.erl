-module(monitor).

-export([init/1,monitor_init/1,create_nodes/2]).

-import(buffer,[start/1]).


%Receives a list of ids and creates the ring in that order.
init(List) ->
    
   spawn(?MODULE,monitor_init,[List]).
   



create_nodes(List,Nodes) -> 
    case List of
        []-> Nodes;
        _ ->
    PID =node:start(hd(List),self()),
    monitor(process,PID),
    [PID | create_nodes(tl(List),Nodes)]
end.
    
%Recursively sets the neighbor up until Node N-1, returning Node N.
set_next(Nodes) ->
    Next = hd(tl(Nodes)),
    hd(Nodes) ! {node,Next},
    if  length(Nodes) ==2 ->
    Next;
    true -> 
    set_next(tl(Nodes))
end.

monitor_init(List) -> 
	
	io:format("Starting Ring...~n"),
    %Starts buffer with size Size

    %Starts nodes.
    Nodes = create_nodes(List,[]),

    Last = set_next(Nodes), 
    Last ! {node, hd(Nodes)}, %Sets 0 node as next of N node. 

	

    monitor_loop(List).



monitor_loop(List) -> 	
    receive
    {'DOWN', _Ref, process, Pid, Why} ->
        %io:format("~p died because ~p~n",[Pid,Why]),
        % Restart ring if why != leader, else shut down everything.
        case Why of
            {leader,Id} -> 
            io:format("Success. Found leader ~p of ~p ~n",[Id,List]),
            %Send to all processes that a leader was found?
            exit(kill);
            
            normal ->
                io:format("Shutted down. ~p~n",[Pid]);
            _-> 
                io:format("Something went wrong. Rebooting ~p~n",[List]),
                init(List),
                exit(kill)
        end
  
       
    end.