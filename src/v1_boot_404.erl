-module(v1_boot_404).
-export([init/3, rest_init/2, rest_terminate/2, known_methods/2,
         service_available/2, allowed_methods/2, is_authorized/2,
         forbidden/2, content_types_provided/2, content_types_accepted/2,
         resource_exists/2]).
-export([to_json/2, to_html/2]).
-export([handle_post/2]).
-export([delete_resource/2, delete_completed/2]).

-include("common.hrl").

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% General Callbacks %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
init(_Transport, _Req, []) ->
	{upgrade, protocol, cowboy_rest}.

rest_init(Req, Opts) ->
    {ok, Req, Opts}.

rest_terminate(_, _) ->
    ok.

service_available(Req, Opts) ->
    {not application:get_env(app, lockdown, false), Req, Opts}.

known_methods(Req, State) ->
    {[<<"PUT">>, <<"POST">>,<<"DELETE">>,<<"GET">>], Req, State}.

allowed_methods(Req, State) ->
    {[<<"PUT">>, <<"POST">>,<<"DELETE">>,<<"GET">>], Req, State}.

content_types_provided(Req, State) ->
    {[
      {{<<"application">>, <<"json">>, '*'}, to_json},
      {{<<"text">>, <<"html">>, '*'}, to_html}
     ],Req, State}.

content_types_accepted(Req, State) ->
    {[
      {{<<"application">>, <<"json">>, '*' }, handle_post}
     ],
     Req, State}.

is_authorized(Req, State) ->
    {true, Req, State}.

forbidden(Req, State) ->
    %% Assume the users have access to everything (default value)
    {false, Req, State}.

resource_exists(Req, State)  ->
    {true, Req, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GET and HEAD callbacks %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
to_json(Req, State) ->
    Response = [
        { <<"result_code">> , 200 },
        { <<"result_msg">> , <<>> },
        { <<"result_data">> , [{<<"echo">>,<<"hello world!">>}] }
    ],
    Ret = jsx:encode(Response),
    {Ret, Req, State}.

to_html(Req, State) ->
    {[], Req, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PUT/POST Callbacks %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handle_post(Req, State) ->
    {false, Req, State}.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DELETE Method callbacks %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delete_resource(Req,State) ->
    {true, Req, State}.

delete_completed(Req, State) ->
    {true, Req, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================