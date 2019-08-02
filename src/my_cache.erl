-module(my_cache).
-export([create/1, insert/4, lookup/2, delete_obsolete/1]).
-include("my_cache.hrl").
-include_lib("stdlib/include/ms_transform.hrl").


create(TableName) -> ets:new(TableName, [set, public, named_table, {keypos, #inscache.key}]).

insert(TableName, Key, Value, Time) ->
   Lifetime = calendar:datetime_to_gregorian_seconds(calendar:local_time())+ Time,
   ets:insert(TableName, #inscache{key=Key, value=Value, time=Lifetime}).


lookup(TableName, Key) ->
  Nowtime=calendar:datetime_to_gregorian_seconds(calendar:local_time()),
  [{_, _, Value, Lifetime}]=ets:lookup(TableName, Key),
    if
	Nowtime < Lifetime -> {ok, Value};
	Nowtime >= Lifetime -> undefined
    end.

delete_obsolete(TableName) ->
Nowtime=calendar:datetime_to_gregorian_seconds(calendar:local_time()),
MS=ets:fun2ms(fun(#inscache{key =Key, value=Value, time=Lifetime}) when Nowtime >= Lifetime -> true end),
ets:select_delete(TableName, MS).