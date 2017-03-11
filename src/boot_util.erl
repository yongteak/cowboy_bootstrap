-module(boot_util).

-export([]).
-compile(export_all).

env(Key) ->
   env(boot,Key).

env(Module,Key) ->
    case application:get_env(Module, Key) of
        {ok, Val} -> Val;
        undefined -> undefined
    end.

env(Module,Key,Default) ->
    case application:get_env(Module, Key) of
        {ok, Val} -> Val;
        undefined -> Default
    end.