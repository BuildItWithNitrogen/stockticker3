-module(index).
-include_lib("nitrogen_core/include/wf.hrl").
-compile(export_all).

main() ->
    #template{file="site/templates/bare.html"}.


title() ->
    "Home".

body_left() ->
    wf:comet_global(fun notify/0, stock_notify),
    [
     #label{text="Stock Symbol"},
     #textbox{id=symbol, class='form-control'},
     #br{},
     #button{
        text="Show Quotes",
        postback=get_quotes,
        class=[btn,'btn-success']
       }
    ].


body_right() ->
    [
        #panel{id=quotes},
        #panel{id=favorite_holder},
        #flash{}
    ].

notify() ->
    receive
        {favorite, Symbol} ->
            wf:flash(wf:f("A user has favorited the symbol ~s", [Symbol]))
    end,
    wf:flush(),
    ?MODULE:notify().


add_favorite(Symbol) ->
    wf:send_global(stock_notify, {favorite, Symbol}),
    Favorites = wf:session_default(favorites, []),
    NewFavorites = [Symbol | Favorites],
    wf:session(favorites, NewFavorites).

event({favorite, Symbol}) ->
    add_favorite(Symbol);
event(get_quotes) ->
    OldPid = wf:state(stock_pid),
    maybe_kill(OldPid),
    Symbol = wf:q(symbol),
    {ok, Pid} = wf:comet(fun() ->
        get_and_insert_quote(Symbol)
    end),
    wf:state(stock_pid, Pid),
    wf:update(favorite_holder, favorite_button(Symbol)).

favorite_button(Symbol) ->
    #button{
       class=[btn, 'btn-info'],
       text=["Favorite ", Symbol],
       postback={favorite, Symbol}
      }.

maybe_kill(undefined) -> ok;
maybe_kill(Pid) -> erlang:exit(Pid, kill).

get_and_insert_quote(Symbol) ->
    Quote = stock:lookup(Symbol),
    QuoteTime = qdate:to_string("g:i:sa"),
    Body = #panel{text=[
        Symbol,
        " (",
        QuoteTime,
        "): ",
        Quote
    ]},
    wf:insert_top(quotes, Body),
    wf:flush(),
    timer:sleep(10000),
    get_and_insert_quote(Symbol).


