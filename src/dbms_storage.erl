%%%----------------------------------------------------------------------
%%% File    : dbms_storage.erl
%%% Author  : Alexander Tsvyashchenko <xmpp@endl.ch>
%%% Purpose : ejabberd unified RDBMS and Mnesia storage support
%%% Created : 30 Sep 2009 by Alexander Tsvyashchenko <xmpp@endl.ch>
%%%
%%% mod_archive2, Copyright (C) 2009 Alexander Tsvyashchenko
%%%
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License as
%%% published by the Free Software Foundation; either version 2 of the
%%% License, or (at your option) any later version.
%%%
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%%% General Public License for more details.
%%%
%%% You should have received a copy of the GNU General Public License
%%% along with this program; if not, write to the Free Software
%%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
%%% 02111-1307 USA
%%%
%%%----------------------------------------------------------------------

-module(dbms_storage).
-author('xmpp@endl.ch').

-include("dbms_storage.hrl").

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
         sql_query/1,
         transaction/2]).

-define(SUPERVISOR, ejabberd_sup).
-define(BACKEND_KEY, dbms_storage_backend).
-define(MODULE_MNESIA, dbms_storage_mnesia).
-define(MODULE_ODBC, dbms_storage_odbc).
% Give SQL server up to one minute to do our query -
% this much time might be required for collection expirations
% queries, as these are quite complex, plus that's default
% value in ejabberd ODBC layer anyway.
-define(DBMS_TIMEOUT, 60000).

%%--------------------------------------------------------------------
%% gen_server callbacks
%%--------------------------------------------------------------------

init([Host, Opts]) ->
    RDBMS = proplists:get_value(rdbms, Opts, mnesia),
    Name =
        case RDBMS of
            mnesia -> ?MODULE_MNESIA;
            _ -> ?MODULE_ODBC
        end,
    Schema = [Table#table{rdbms = RDBMS} ||
              Table <- proplists:get_value(schema, Opts, [])],
    {ok, #storage_backend{name = Name,
                          host = Host,
                          rdbms = RDBMS,
                          schema = Schema}}.

handle_call({transaction, F}, _From, State) ->
    CombiF =
        fun() ->
            put(?BACKEND_KEY, State),
            Result = F(),
            % The value will not be erased if exception is thrown, but
            % we do not really care.
            erase(?BACKEND_KEY),
            Result
        end,
    {reply, forward_query({transaction, CombiF}, State), State};

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
    Proc = mod_archive2_utils:get_module_proc(Host, ?MODULE),
    Spec = {Proc, {?MODULE, start_link, [Host, Opts]},
            transient, 1000, worker, [?MODULE]},
    supervisor:start_child(?SUPERVISOR, Spec).

stop(Host) ->
    Proc = mod_archive2_utils:get_module_proc(Host, ?MODULE),
    supervisor:terminate_child(?SUPERVISOR, Proc),
    supervisor:delete_child(?SUPERVISOR, Proc).

%%--------------------------------------------------------------------
%% API
%%--------------------------------------------------------------------

start_link(Host, Opts) ->
    Proc = mod_archive2_utils:get_module_proc(Host, ?MODULE),
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
%% if Records contained exactly one record.
insert([]) ->
    undefined;

insert(Records) ->
    forward_query({insert, Records}).

%% Runs given SQL query - does not work for Mnesia, of course ;-)
sql_query(Query) ->
    forward_query({sql_query, Query}).

%% Runs transaction.
transaction(Host, F) ->
    gen_server:call(mod_archive2_utils:get_module_proc(Host, ?MODULE), {transaction, F}, ?DBMS_TIMEOUT).

%%--------------------------------------------------------------------
%% Helper functions
%%--------------------------------------------------------------------

forward_query(Query) ->
    State = get(?BACKEND_KEY),
    forward_query(Query, State).

forward_query(Query, State) ->
    case State#storage_backend.name of
        ?MODULE_MNESIA ->
            dbms_storage_mnesia:handle_query(Query, State);
        ?MODULE_ODBC ->
            dbms_storage_odbc:handle_query(Query, State)
    end.
