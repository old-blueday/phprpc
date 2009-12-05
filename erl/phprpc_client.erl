-module(phprpc_client).
-vsn(3.0).

-export([start/0, start/1, stop/0,
         use_service/1, invoke/1, invoke/2]).

-define(MAXINT, 2147483647).
-define(MININT, -2147483648).

-spec(start/0 :: () -> 'ok').	
-spec(start/1 :: (string()) -> 'ok').
-spec(stop/0 :: () -> 'ok').
-spec(use_service/1 :: (string()) -> 'ok').
-spec(invoke/1 :: (string()) -> 'ok').		
	
start() ->
    start("http://localhost:8080").
	
start(URL) ->
    ets:new(?MODULE, [set, public, named_table, {keypos, 1}]),
	{{Year, Month, Day}, {Hour, Minute, Second}} = erlang:localtime(),
	RandomNo = random:uniform(?MAXINT),
	ClientID = lists:concat(["erl", RandomNo, Year, Month, Day, Hour, Minute, Second]),
    ets:insert(?MODULE, {cid, ClientID}),	
    use_service(URL),	
    inets:start().
	
stop() ->
	inets:stop().

use_service(URL) ->
	[{cid, ClientID}] = ets:lookup(?MODULE, cid),
	ets:insert(?MODULE, {url, case string:chr(URL, $?) of
								 0  -> lists:concat([URL, "?phprpc_id=", ClientID]);
								 [] -> lists:concat([URL, "&phprpc_id=", ClientID])
							  end}).

invoke(FuncName) ->
    invoke(FuncName, []).

invoke(FuncName, Args) ->
    [{url, URL}] = ets:lookup(?MODULE, url),
	ContentType = "application/x-www-form-urlencoded; charset=utf8",
	Function = "phprpc_func=" ++ FuncName,
	Encrypt = "&phprpc_encrypt=0",
	ByRef = "&phprpc_ref=false",
	RequestBody = lists:concat([Function, if Args =:= [] -> []; true -> "&phprpc_args=" ++ base64:encode_to_string(php:serialize(Args)) end, Encrypt, ByRef]),
	io:format("~s~n",[RequestBody]),
    case http:request(post, {URL, [], ContentType, RequestBody}, [], []) of
		{ok, {{_, 200, _}, _, Body}} -> string:tokens(Body, "\r\n");
		{error, Reason} -> Reason
    end.	
	
