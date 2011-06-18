%% Usage :
%%
%%   c(actor).
%%   Pid = spawn(fun actor:myActor/0).
%%   Pid ! {mult, 4}.
%%
-module(actor).
-export([myActor/0]).

myActor() ->
   receive  
   {mult, X} ->
      io:format(standard_io, "~w * ~w = ~w~n", [X, X, X*X]),
      myActor();
   {add, X} ->
      io:format(standard_io, "~w + ~w = ~w~n", [X, X, X+X]),
      myActor();
   Other ->
      io:format(standard_io, "Don't know what to do with message : ~w~n", [Other]),
      myActor()
end.
