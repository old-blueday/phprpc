%% ******************************************************** %%
%%                                                          %%
%% The implementation of PHPRPC Protocol 3.0                %%
%%                                                          %%
%% xxtea.erl                                                %%
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

%% XXTEA encryption arithmetic library.
%%
%% Copyright: Chen fei <cf850118@163.com>
%% Version: 3.0
%% LastModified: Dec 7, 2009
%% This library is free.  You can redistribute it and/or modify it.
%%
 
-module(xxtea).
-vsn(3.0).

-export([encrypt/2, decrypt/2]).

-define(DELTA, 16#9E3779B9).

%%
%% encrypt
%%

-spec(encrypt/2 :: (string(), string()) -> string()).
-spec(encrypt_list/2 :: (list(), list()) -> list()).
-spec(encrypt_loop1/5 :: (list(), list(), integer(), integer(), integer()) -> list()).
-spec(encrypt_loop2/8 :: (list(), list(), list(), integer(), integer(), integer(), integer(), integer()) -> list()).

encrypt(Data, Key) when is_list(Data) and is_list(Key) ->
	uint32_list_to_string(encrypt_list(string_to_uint32_list(Data, true), string_to_uint32_list(Key, false)), false). 

encrypt_list(Data, _Key) when length(Data) < 2 ->
	Data;
encrypt_list(Data, Key) when length(Key) < 4 ->
	encrypt_list(Data, lists:append(Key, lists:duplicate(4 - length(Key), 0)));
encrypt_list(Data, Key) ->
	N = length(Data) - 1,
    Q = floor(6 + 52 div (N + 1)),
    encrypt_loop1(Data, Key, lists:last(Data), 0, Q).
	
encrypt_loop1(Data, _Key, _Z, _Sum, 0) ->
    Data;
encrypt_loop1(Data, Key, Z, Sum, Q) ->
    Sum2 = uint32(Sum + ?DELTA),
    E = (Sum2 bsr 2) band 3,
    encrypt_loop2(Data, Key, [], Z, Sum2, E, 0, Q - 1).

encrypt_loop2([X], Key, List, Z, Sum, E, P, Q) ->
    Z2 = uint32(X + mx(lists:last(List), Z, Key, P, E, Sum)),
    encrypt_loop1(lists:reverse([Z2|List]), Key, Z2, Sum, Q);
encrypt_loop2([X,Y|_] = Data, Key, List, Z, Sum, E, P, Q) ->
    Z2 = uint32(X + mx(Y, Z, Key, P, E, Sum)),
    encrypt_loop2(tl(Data), Key, [Z2|List], Z2, Sum, E, P + 1, Q).
	
%%
%% decrypt
%%	

-spec(decrypt/2 :: (string(), string()) -> string()).
-spec(decrypt_list/2 :: (list(), list()) -> list()).
-spec(decrypt_loop1/5 :: (list(), list(), integer(), integer(), integer()) -> list()).
-spec(decrypt_loop2/8 :: (list(), list(), list(), integer(), integer(), integer(), integer(), integer()) -> list()).
	
decrypt(Data, Key) ->
	uint32_list_to_string(decrypt_list(string_to_uint32_list(Data, false), string_to_uint32_list(Key, false)), true).

decrypt_list(Data, Key) when length(Key) < 4 ->
    decrypt_list(Data, lists:append(Key, lists:duplicate(4 - length(Key), 0)));
decrypt_list(Data, Key) ->
    N = length(Data) - 1,
    Q = floor(6 + 52 div (N + 1)),
    decrypt_loop1(Data, Key, uint32(Q * ?DELTA), hd(Data), N).

decrypt_loop1(Data, _Key, 0, _Y, _N) ->
    Data;
decrypt_loop1(Data, Key, Sum, Y, N) ->
    decrypt_loop2(lists:reverse(Data), Key, [], Y, Sum, (Sum bsr 2) band 3, N, N).
	
decrypt_loop2([X], Key, List, Y, Sum, E, P, N) ->
    Y2 = uint32(X - mx(Y, lists:last(List), Key, P, E, Sum)),
    decrypt_loop1([Y2|List], Key, uint32(Sum - ?DELTA), Y2, N);
decrypt_loop2([X,Z|_] = Data, Key, List, Y, Sum, E, P, N) ->
    Y2 = uint32(X - mx(Y, Z, Key, P, E, Sum)),
    decrypt_loop2(tl(Data), Key, [Y2|List], Y2, Sum, E, P - 1, N).
	
%%
%% mx
%%

-spec(mx/6 :: (integer(), integer(), list(), integer(), integer(), integer()) -> integer()).

mx(Y, Z, Key, P, E, Sum) ->
    uint32((((Z bsr 5) band 16#07FFFFFF) bxor (Y bsl 2)) + (((Y bsr 3) band 16#1FFFFFFF) bxor (Z bsl 4))) bxor
	uint32((Sum bxor Y) + lists:nth((P band 3 bxor E) + 1, Key) bxor Z).	
	
%%
%% Helpers
%%

-spec(string_to_uint32_list/2 :: (string(), bool()) -> list()).
-spec(string_to_uint32_list/3 :: (string(), integer(), integer()) -> list()).

%% Convert string to uint32 list.
string_to_uint32_list(Data, IncLen) ->
	L = string_to_uint32_list(Data, 0, 0),
	if IncLen -> lists:append(L, [length(Data)]); true -> L end.
	
string_to_uint32_list([H|T], Acc, I) ->
	V = Acc bor (H bsl ((I band 3) bsl 3)),
	J = I + 1,
	case J rem 4 of
		0 ->
			[V|string_to_uint32_list(T, 0, J)];
		_ ->
			string_to_uint32_list(T, V, J)
	end;
string_to_uint32_list([], 0, _I) -> [];
string_to_uint32_list([], Acc, _I) -> [Acc].

-spec(uint32_list_to_string/2 :: (list(), bool()) -> string()).
-spec(uint32_list_to_string/3 :: (list(), integer(), integer()) -> string()).

%% Convert uint32 list to string.
uint32_list_to_string(Data, IncLen) ->
	N = length(Data) bsl 2,
	if IncLen ->
		M = lists:last(Data),
		if M < N -> uint32_list_to_string(Data, 0, M); true -> [] end;
	true ->
		uint32_list_to_string(Data, 0, N)
	end.
	
uint32_list_to_string(_, Max, Max) -> [];
uint32_list_to_string([H|T] = Data, I, Max) ->
	V = char(H bsr ((I band 3) bsl 3)),
	J = I + 1,
	case J rem 4 of
		0 ->
			[V|uint32_list_to_string(T, J, Max)];
		_ ->
			[V|uint32_list_to_string(Data, J, Max)]
	end.

-spec(char/1 :: (integer()) -> integer()).
-spec(uint32/1 :: (integer()) -> integer()).
-spec(floor/1 :: (integer()) -> integer()).
	
char(Num) ->
	Num band 16#FF.
	
uint32(Num) -> 
    Num band 16#FFFFFFFF.
    
floor(X) ->
    T = trunc(X),
    case (X - T) of
        Neg when Neg < 0 -> T - 1;
        Pos when Pos > 0 -> T;
        _ -> T
    end.