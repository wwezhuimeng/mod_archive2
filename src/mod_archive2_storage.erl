%%%----------------------------------------------------------------------
%%% File    : mod_archive2_storage.erl
%%% Author  : Alexander Tsvyashchenko <ejabberd@ndl.kiev.ua>
%%% Purpose : Unified RDBMS and Mnesia Storage Support
%%% Created : 27 Sep 2009 by Alexander Tsvyashchenko <ejabberd@ndl.kiev.ua>
%%% Version : 2.0.0
%%% Id      : $Id$
%%%----------------------------------------------------------------------

-module(mod_archive2_storage).
-author('ejabberd@ndl.kiev.ua').

-include("mod_archive2_storage.hrl").

-behaviour(gen_server).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% gen_mod callbacks
-export([start/2, stop/1]).

%% API
-export([start_link/2,
         delete/1,
         read/1, select/1, select/2,
         insert/1, update/1, update/2,
         transaction/2]).

-define(SUPERVISOR, ejabberd_sup).
-define(BACKEND_KEY, mod_archive2_backend).
-define(MODULE_MNESIA, mod_archive2_mnesia).
-define(MODULE_ODBC, mod_archive2_odbc).

%%--------------------------------------------------------------------
%% gen_server callbacks
%%--------------------------------------------------------------------

init([Host, Opts]) ->
    put_backend(Host, Opts),
    {ok, []}.

handle_call({transaction, F}, _From, State) ->
    {reply, forward_query({transaction, F}), State};

handle_call(stop, _From, State) ->
    {stop, normal, ok, State};

handle_call(_Req, _From, State) ->
    {reply, {error, badarg}, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%--------------------------------------------------------------------
%% gen_mod callbacks
%%--------------------------------------------------------------------

start(Host, Opts) ->
    Proc = gen_mod:get_module_proc(Host, ?MODULE),
    Spec = {Proc, {?MODULE, start_link, [Host, Opts]},
            transient, 1000, worker, [?MODULE]},
    supervisor:start_child(?SUPERVISOR, Spec).

stop(Host) ->
    Proc = gen_mod:get_module_proc(Host, ?MODULE),
    supervisor:terminate_child(?SUPERVISOR, Proc),
    supervisor:delete_child(?SUPERVISOR, Proc).

%%--------------------------------------------------------------------
%% API
%%--------------------------------------------------------------------

start_link(Host, Opts) ->
    Proc = gen_mod:get_module_proc(Host, ?MODULE),
    gen_server:start_link({local, Proc}, ?MODULE, [Host, Opts], []).

%% Depending on argument type:
%%  - Deletes the specified record: key is mandatory, all other fields are unused.
%%  - Deletes all records matching MS.
delete(Arg) ->
    forward_query({delete, Arg}).

%% Retrieves the specified record: key is mandatory, all other fields are unused.
read(R) ->
    forward_query({read, R}).

%% Retrieves all records matching MS.
select(MS) ->
    forward_query({select, MS, []}).

%% Retrieves all records matching MS and using Opts.
select(MS, Opts) ->
    forward_query({select, MS, Opts}).

%% Updates the specified record, which is assumed to exist: key is mandatory,
%% all other fields not set to "undefined" are used.
update(R) ->
    forward_query({update, R}).

%% Updates all records matching MS, all fields not set to "undefined" are used
%% (except key).
update(R, MS) ->
    forward_query({update, R, MS}).

%% Inserts all records in the list to their respective tables, records are
%% assumed to not exist, keys are auto-generated, all other fields not set to
%% "undefined" are used. Returns last inserted ID, but it is meaningful only
%% if Records contained single record.
insert(Records) ->
    forward_query({insert, Records}).

%%
%% TODO: DO WE NEED IT?
%%
%% Updates or inserts all records in their respective tables depending on
%% whether they exist or not, keys are auto-generated, all other fields not set
%% to "undefined" are used. Returns last inserted ID, but it is meaningful only
%% if Records contained single record.
%% write(Host, Records) ->
%%    ?FORWARD(Host, {write, Records}).

%% Runs transaction.
transaction(Host, F) ->
    gen_server:call(gen_mod:get_module_proc(Host, ?MODULE), {transaction, F}).

%%--------------------------------------------------------------------
%% Helper functions
%%--------------------------------------------------------------------

forward_query(Query) ->
    Info = get(?BACKEND_KEY),
    case Info#backend.name of
        ?MODULE_MNESIA ->
            mod_archive2_mnesia:handle_query(Query, Info);
        ?MODULE_ODBC ->
            mod_archive2_odbc:handle_query(Query, Info)
    end.

put_backend(Host, Opts) ->
    RDBMS = proplists:get_value(rdbms, Opts, mnesia),
    Backend =
        case RDBMS of
            mnesia -> ?MODULE_MNESIA;
            _ -> ?MODULE_ODBC
        end,
    Schema = [Table#table{rdbms = RDBMS} ||
              Table <- proplists:get_value(schema, Opts, [])],
    put(?BACKEND_KEY,
        #backend{
            name = Backend,
            host = Host,
            rdbms = RDBMS,
            schema = Schema}),
    Backend.