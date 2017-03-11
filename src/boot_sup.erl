-module(boot_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, upgrade/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% @spec upgrade() -> ok
%% @doc Add processes if necessary.
upgrade() ->
    {ok, {_, Specs}} = init([]),

    Old = sets:from_list(
            [Name || {Name, _, _, _} <- supervisor:which_children(?MODULE)]),
    New = sets:from_list([Name || {Name, _, _, _, _, _} <- Specs]),
    Kill = sets:subtract(Old, New),

    sets:fold(fun (Id, ok) ->
                      supervisor:terminate_child(?MODULE, Id),
                      supervisor:delete_child(?MODULE, Id),
                      ok
              end, ok, Kill),

    [supervisor:start_child(?MODULE, Spec) || Spec <- Specs],
    ok.

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    
    {ok, _App} = application:get_application(?MODULE),

    %ReloadConf = ?CHILD(m_reload_conf,worker),
    %% GCM Pool Options
    % SizeArgs = m_config:get(gcm_pool,[{size, 10},{max_overflow, 100}]),
    % PoolArgs =  [
    %     {name, {local, gcm_pool}},
    %     {worker_module, gen_gcm_worker}
    % ] ++ SizeArgs,
    % WorkerArgs = [],
    % GCMPool = poolboy:child_spec(gen_gcm_worker, PoolArgs, WorkerArgs),
    WWW = ?CHILD(boot_cowboy,worker),
    Children = [WWW],%[ ReloadConf, Children0 ],
    {ok, { {one_for_one, 10, 10}, Children } }.

