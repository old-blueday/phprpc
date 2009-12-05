%% ******************************************************** %%
%%                                                          %%
%% The implementation of PHPRPC Protocol 3.0                %%
%%                                                          %%
%% php.erl                                                  %%
%%                                                          %%
%% Release 3.0                                              %%
%% Copyright by Team-PHPRPC                                 %%
%%                                                          %%
%% WebSite:  http://www.phprpc.org/                         %%
%%           http://www.phprpc.net/                         %%
%%           http://www.phprpc.com/                         %%
%%           http://sourceforge.net/projects/php-rpc/       %%
%%                                                          %%
%% Authors:  Chen fei <cf850118@163.com>                    %%
%%                                                          %%
%% This file may be distributed and/or modified under the   %%
%% terms of the GNU Lesser General Public License (LGPL)    %%
%% version 3.0 as published by the Free Software Foundation %%
%% and appearing in the included file LICENSE.              %%
%%                                                          %%
%% ******************************************************** %%

%% PHP serialize/unserialize library.
%%
%% Copyright: Chen fei <cf850118@163.com>
%% Version: 3.0
%% LastModified: Sep 29, 2009
%% This library is free.  You can redistribute it and/or modify it.
%%
 
-module(php).
-vsn(3.0).

-export([serialize/1, unserialize/1]).

-define(MAXINT, 2147483647).
-define(MININT, -2147483648).

%%
%% serialize
%%

-spec(serialize/1 :: (any()) -> string()).

serialize(Value) ->
	{Result, _Container} = serialize(Value, [null]), Result.

-spec(serialize/2 :: (any(), list()) -> string()).	
	
%% serialize null	
serialize(null, Container) ->
	{"N;", [null|Container]};

%% serialize boolean
serialize(Value, Container) when is_boolean(Value) ->
	{[$b, $:, if Value -> $1; true -> $0 end, $;], [null|Container]};

%% serialize integer
serialize(Value, Container) when is_integer(Value) ->
	Result = case Value of
				_Integer when Value > ?MININT, Value < ?MAXINT ->
					"i:" ++ integer_to_list(Value) ++ ";";
				_LongInteger								   ->
					"d:" ++ integer_to_list(Value) ++ ";"
			 end,
	{Result, [null|Container]};

%% serialize float	 
serialize(Value, Container)	when is_float(Value) ->
	{"d:" ++ mochinum:digits(Value) ++ ";", [null|Container]}; % used mochinum module	 

%% serialize atom as string
serialize(Value, Container) when is_atom(Value) ->
	serialize(list_to_binary(atom_to_list(Value)), Container);
	
%% serialize binary as string	
serialize(Value, Container) when is_binary(Value) ->
	case find_member(lists:reverse(Container), Value) of
		-1	  ->
			VLen = byte_size(Value),
			String = binary_to_list(Value),
			{"s:" ++ integer_to_list(VLen) ++ ":\"" ++ String ++ "\";", [Value|Container]};
		Index ->
			{"r:" ++ integer_to_list(Index) ++ ";", [null|Container]}
	end;

%% serialize list as array
serialize(Value, Container) when is_list(Value) ->
	case Value of
		[{_,_}|_] ->
			{Result, Accu2} = lists:foldl(
				fun({Key, Elem}, {Ret, Accu}) ->
                    {KR, _} = serialize(Key, []),
                    {ER, Accu1} = serialize(Elem, Accu),
                    {Ret ++ KR ++ ER, Accu1}
                end, {[], [null|Container]}, Value),
			VLen = length(Value),
			{"a:" ++ integer_to_list(VLen) ++ ":{" ++ Result ++ "}", Accu2};
		_Other 	  ->
			serialize(map_index(fun(X, I) -> {I, X} end, Value), Container)
	end.

%%
%% unserialize
%%

unserialize(S) when is_list(S) ->
	{Result, _Container} = unserialize(S, []), Result.

%% unserialize null	
unserialize([$N, $;], C) ->
	{null, C ++ [null]};

%% unserialize boolean	
unserialize([$b, $:, $1, $;], C) ->
	{true, C ++ [true]};
unserialize([$b, $:, $0, $;], C) ->
	{false, C ++ [false]};

%% unserialize integer	
unserialize([$i, $: | Rest], C) ->
	{Value, _} = string:to_integer(Rest),
	{Value, C ++ [Value]};

%% unserialize float
unserialize([$d, $: | Rest], C) ->
	{Value, _} = case string:to_float(Rest) of
					 {error, no_float} -> string:to_integer(Rest);
                     {N, R} -> {N, R}
				 end,
	{Value, C ++ [Value]};

%% unserialize string as binary	
unserialize([$s, $: | Rest], C) ->
    {Len, [$: | String]} = string:to_integer(Rest),
    Value = list_to_binary(string:sub_string(String, 2, Len+1)),
    {Value, C ++ [Value]};
	
%% unserialize array as tuple list.
unserialize([$a, $: | Rest], C) ->
    {NumEntries, [$:, ${ | Rest1]} = string:to_integer(Rest),
    ok.

%%
%% Helpers
%%	
		
-spec(find_member/2 :: (list(), any()) -> integer()).

%% find the first index of the value in a list
find_member(L, X) -> find_member(L, X, 0).
	
find_member([X|_], X, I) -> I;
find_member([_|Y], X, I) -> find_member(Y, X, I+1);
find_member([], _X, _I)	 -> -1.

%-spec map_index(fun((D, I) -> R), [D]) -> [R].

%% map with index
map_index(F, L) -> map_index(F, L, 0).

map_index(F, [H|T], I) ->
    [F(H, I)|map_index(F, T, I+1)];
map_index(F, [], _I) when is_function(F, 2) -> [].	