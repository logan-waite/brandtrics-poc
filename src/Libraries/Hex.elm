module Libraries.Hex exposing (toDecimal)

import Set exposing (Set)


type alias Hex =
    String


validHexValues : Set Char
validHexValues =
    Set.fromList [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' ]


isAllowedHexValue : Hex -> Bool
isAllowedHexValue hex =
    let
        hexSet =
            String.toList hex
                |> Set.fromList
    in
    Set.diff hexSet validHexValues
        |> Set.isEmpty



-- fromDecimal : Int -> Hex
-- fromDecimal int =
--     Debug.todo "implement fromDecimal"


toDecimal : Hex -> Result String Int
toDecimal hex =
    let
        upperCaseHex =
            String.toUpper hex
    in
    if String.isEmpty upperCaseHex then
        Err "Empty strings are not valid hex values"

    else if not (isAllowedHexValue upperCaseHex) then
        Err "Value contains an invalid hex character"

    else
        Ok (hexToDecimal (String.reverse upperCaseHex))


hexToDecimal : Hex -> Int
hexToDecimal hex =
    String.toList hex
        |> List.map stringToValue
        |> List.indexedMap getPositionalValue
        |> List.sum


getPositionalValue : Int -> Int -> Int
getPositionalValue position value =
    value * 16 ^ position


stringToValue : Char -> Int
stringToValue val =
    case val of
        '0' ->
            0

        '1' ->
            1

        '2' ->
            2

        '3' ->
            3

        '4' ->
            4

        '5' ->
            5

        '6' ->
            6

        '7' ->
            7

        '8' ->
            8

        '9' ->
            9

        'A' ->
            10

        'B' ->
            11

        'C' ->
            12

        'D' ->
            13

        'E' ->
            14

        'F' ->
            15

        _ ->
            0
