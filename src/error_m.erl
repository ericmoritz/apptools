%%% @author Eric Moritz <eric@themoritzfamily.com>
%%% @copyright (C) 2013, Eric Moritz
%%% @doc
%%% A simple error "monad" for a sequence of operations that return {ok | error, any()}
%%% @end
%%% Created : 10 Jun 2013 by Eric Moritz <eric@themoritzfamily.com>

-module(error_m).

-export([
	 do/2,
	 do/3
	]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-type value() :: any().
-type error() :: any().
-type state() :: any().
-type ok_or_error() :: {ok, value()} | {error, error()}.
-type callback() :: fun((value()) -> ok_or_error()).
-type stateful_callback() :: fun((value(), state()) -> {ok_or_error(), state()}).

%%--------------------------------------------------------------------
%% @doc
%% A stateless do
%% @end
%%--------------------------------------------------------------------
-spec do(ok_or_error(), [callback()]) -> ok_or_error().
do(E={error, _}, _) ->
    E;
do(Ret, []) ->
    Ret;
do({ok, V}, [Op|Rest]) ->
    do(Op(V), Rest).


%%--------------------------------------------------------------------
%% @doc
%% A stateful version of the do function
%% @end
%%--------------------------------------------------------------------
-spec do(ok_or_error(), state(), [stateful_callback()]) -> {ok_or_error(), state()}.
do(E={error, _}, State, _) ->
    {E, State};
do(Ret, State, []) ->
    {Ret, State};
do({ok, V}, State, [Op|Rest]) ->
    {Ret, State} = Op(V, State),
    do(Ret, State, Rest).

-ifdef(TEST).
do_test() ->
    Inc = fun(V) -> {ok, V+1} end,

    % successful
    {ok, 3} = do(
		{ok, 0},
		[
		 Inc,
		 Inc,
		 Inc
		]),
    
    % Short-circuit
    {error, just_cuz} = do(
		      {ok, 0},
		      [
		       Inc,
		       fun(_) ->
			       {error, just_cuz}
		       end,
		       Inc
		       ]).

-endif.
