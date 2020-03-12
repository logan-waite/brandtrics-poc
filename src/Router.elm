module Router exposing (EditBrandRoute(..), Route(..), urlToRoute)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, parse, s)


type EditBrandRoute
    = Logos
    | Colors
    | Fonts


type Route
    = Top
    | EditBrand EditBrandRoute


urlToRoute : Url -> Maybe Route
urlToRoute url =
    parse parser url


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Top Parser.top
        , Parser.map (EditBrand Logos) (s "edit")
        , Parser.map (EditBrand Logos) (s "edit" </> s "logos")
        , Parser.map (EditBrand Colors) (s "edit" </> s "colors")

        -- , Parser.map EditFonts (s "edit" </> s "fonts")
        ]
