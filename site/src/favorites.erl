-module(favorites).
-include_lib("nitrogen_core/include/wf.hrl").
-compile(export_all).

main() ->
    #template{file="site/templates/bare.html"}.

title() -> "Favorites".

body_left() ->
    Favorites = st_common:favorites(),
    wf:join(Favorites, #br{}).
