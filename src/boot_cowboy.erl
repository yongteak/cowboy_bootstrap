-module(boot_cowboy).

-behaviour(gen_server).

-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-export([update_dispatch/0,respond/4]).

-define(SERVER, ?MODULE).

-record(state, {}).

-include("common.hrl").

%%%===================================================================
%%% API
%%%===================================================================


%%--------------------------------------------------------------------
%% @doc Starts the server.
%%
%% @spec start_link(Port::integer()) -> {ok, Pid}
%% where
%%  Pid = pid()
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    start_cowboy(),
    process_flag(trap_exit, true),
    {ok, #state{}}.

handle_call(_Msg, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% implementations
%%
% priv() ->
%   m_config:get(cowboy_doc_root,"../../priv/www").

dispatch() ->
  [
    {'_', [
      {"/", v1_boot_404, []},
      {"/v1/info", v1_info, [] },
      {"/[...]", cowboy_static, { dir, "priv/www" , [{mimetypes, cow_mimetypes, all}]}}
    ]}
  ].

%%%===================================================================
%%% Internal functions
%%%===================================================================
update_dispatch() ->
    cowboy:set_env(http, dispatch, cowboy_router:compile(dispatch())).

start_cowboy() ->
    Port = boot_util:env(port),
    SSL = false,
    % SSLPort = 443,
    % SPDYPort = 442,
    SSLPASSWORD = "",
    NumAcceptors = 100,
    Dispatch = cowboy_router:compile(dispatch()),

    Options = [{env,[{dispatch,Dispatch}]},
                {max_keepalive,0},
                {middlewares,[cowboy_router,boot_cowboy_middleware,cowboy_handler]}],

    ?INFO("Cowboy Options ~p",[lager:pr(Options, ?MODULE)]),

    cowboy:start_http(http, NumAcceptors,[{port, Port}],Options).

respond(Code, _, <<>>, Req) when Code >= 500 ->
  Req;

respond(Code, Headers, <<>>, Req) when is_integer(Code), Code >= 400 -> Req;

respond(Code, Headers, Body, Req) ->
  Req.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
