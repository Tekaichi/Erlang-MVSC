-module(supervisor).
-behaviour(gen_server).

-export([start_link/0]).
-export([allocate/0, free/1]).
%-export([init/1, handle_call/3, handle_cast/2]).

%-tbh this generic server doesnt help gives us that much of an advantage vs implementing something in our own, but wtv, lets just use this to prove we listened to the classes.
%We can also use the gen_server on the nodes implementation I guess (?) 
start_link() ->
    gen_server:start_link({local, nodes}, nodes, []).

allocate() ->
    gen_server:call(nodes, {allocate,self()}).

free(Ch) ->
    gen_server:cast(nodes, {free}).

init(_Args) ->
    Nodes = {get_nodes(), []}, 
    {ok, Nodes}.

handle_call({allocate, Pid}, _From, Nodes) -> {}.
 %TODO

handle_cast({deallocate}, Nodes) ->
    %Shut down nodes ? 
    {}.
    
get_nodes() -> [c1, c2, c3, c4, c5]. %Setup nodes.
