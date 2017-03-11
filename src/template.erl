%% https://gist.github.com/ferd/8fc1e9b6019aefcf2ac0
-module(template).
-export([init/3, rest_init/2, rest_terminate/2, known_methods/2,
         service_available/2, allowed_methods/2, is_authorized/2,
         forbidden/2, content_types_provided/2, content_types_accepted/2,
         resource_exists/2]).
-export([to_json/2, to_html/2]).
-export([handle_post/2]).
-export([delete_resource/2, delete_completed/2]).

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
    {[{{<<"text">>, <<"html">>, '*'}, to_html},
      {{<<"application">>, <<"json">>, '*'}, to_json}],
     Req, State}.

content_types_accepted(Req, State) ->
    {[
      {{<<"application">>, <<"json">>, '*' }, handle_post}
     ],
     Req, State}.

is_authorized(Req, State) ->
    case cowboy_req:parse_header(<<"authorization">>, Req) of
        {ok, {<<"basic">>, {User, _Pass}}, Req2} ->
            {true, Req2, State#{user => User}};
        _ ->
            {{false, <<"Basic realm=\"app\"">>}, Req, State}
    end.

forbidden(Req, State) ->
    %% Assume the users have access to everything (default value)
    {false, Req, State}.

resource_exists(Req, State)  ->
    {true, Req, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GET and HEAD callbacks %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
to_json(Req, State) ->
    {[], Req, State}.

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