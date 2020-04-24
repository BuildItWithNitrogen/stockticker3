-module(st_common).
-include_lib("nitrogen_core/include/wf.hrl").
-export([favorites/0, menu/0]).

menu() ->
    Items = menu_items(),
    menu_list_comp(Items).

menu_list_comp(Items) ->
    #list{class=['navbar-nav', 'mr-auto'],body=[
        [draw_item(Item) || Item <- Items]
    ]}.

draw_item({Label, Url}) ->
    #listitem{class='nav-item', body=[
        #link{class='nav-link', text=Label, url=Url}
    ]}.

menu_map(Items) ->
    #list{class=['navbar-nav', 'mr-auto'],body=[
        lists:map(fun({Label, Url}) ->
            #listitem{class='nav-item', body=[
                #link{class='nav-link', text=Label, url=Url}
            ]}
        end, Items)
    ]}.

menu_bind(Items) ->
    Map = {menu_link@text, menu_link@url},
    #list{class=[nav,'navbar-nav'],body=[
        #bind{data=Items, map=Map, body=[
            #listitem{class='nav-item', body=[
                #link{class='nav-link', id=menu_link}
            ]}
        ]}
    ]}.

menu_items() ->
    [
     {"Home", "/"},
     {"Favorite Stocks", "/favorites"}
    ].

favorites() ->
    wf:session_default(favorites, []).


