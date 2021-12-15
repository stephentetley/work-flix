/*
 * Copyright 2020 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


namespace AssetLib/Base/Osgb36 {


    
    /// Two letters and 10 digits
    pub opaque type NGR = String

    instance ToString[NGR] {
        pub def toString(x: NGR): String = 
            let NGR(x1) = x;
            x1
    }

    instance FromString[NGR] {
        pub def fromString(s: String): Option[NGR] = parse(s)
    }

    instance Eq[NGR] {
        pub def eq(x: NGR, y: NGR): Bool = 
            let NGR(x1) = x;
            let NGR(y1) = y;
            x1 == y1
    }

    instance Hash[NGR] {
        pub def hash(x: NGR): Int32 = 
            let NGR(x1) = x;
            Hash.hash(x1)
    }


    pub def parse(s: String): Option[NGR] = 
        use Option.flatMap;
        let s1 = String.trim(s);
        let* patt = Text/Regex/Pattern.compile("\\p{Alpha}{2}[0-9]{10}") |> Result.toOption;
        if (Text/Regex.matches(s1, patt))
            Some(NGR(s1))
        else 
            None

    

    pub type alias EastingNorthing = {easting :: Int32, northing :: Int32}



    pub def toNGR (x: EastingNorthing): Option[NGR] =
        use Option.flatMap;
        let* major = findMajor(x.easting, x.northing);
        let* minor = findMinor(x.easting, x.northing) as & Pure;
        let smallE = Int32.toString(x.easting `Mod.mod` 100000);
        let smallN = Int32.toString(x.northing `Mod.mod` 100000);
        let s = Char.toString(major) + Char.toString(minor) + String.padLeft(5, '0', smallE) + String.padLeft(5, '0', smallN);
        Some(NGR(s))

    def findMajor(easting: Int32, northing: Int32): Option[Char] =
        match (easting,northing) {
            case (e,n) if e >= 0 and e < 500_000            and n >= 0 and n < 500_000           => Some('S')
            case (e,n) if e >= 500_000 and e < 1_000_000    and n >= 0 and n < 500_000           => Some('T')
            case (e,n) if e >= 0 and e < 500_000            and n >= 500_000 and n < 1_000_000   => Some('N')
            case (e,n) if e >= 500_000 and e < 1_000_000    and n >= 500_000 and n < 1_000_000   => Some('O')
            case (e,n) if e >= 0 and e < 500_000            and n >= 1_000_000 and n < 1_500_000 => Some('H')
            case (e,n) if e >= 500_000 and e < 1_000_000    and n >= 1_000_000 and n < 1_500_000 => Some('J')
            case (_,_) => None
        }


    def findMinor (easting: Int32, northing: Int32): Option[Char] & Impure =
        let arr2D = minorGrid();
        let modE = easting `Mod.mod` 500000;
        let modN = northing `Mod.mod` 500000;
        let divE = modE / 100000;
        let divN = modN / 100000;
        if (divE >= 0 and divE < 5 and divN >= 0 and divN < 5) {
            let row1 = arr2D[divE];
            let c = row1[divN];
            Some(c)
        } else
            None

    def minorGrid() : Array[Array[Char]] & Impure = 
        [ [ 'V', 'Q', 'L', 'F', 'A' ]
        , [ 'W', 'R', 'M', 'G', 'B' ]
        , [ 'X', 'S', 'N', 'H', 'C' ]
        , [ 'Y', 'T', 'O', 'J', 'D' ]
        , [ 'Z', 'U', 'P', 'K', 'E' ]
        ]


    def decodeMajor(c: Char): Option[(Int32, Int32)] = 
        match Char.toUpperCase(c) {
            case 'S'    => Some((0,          0))
            case 'T'    => Some((500_000,    0))
            case 'N'    => Some((0,          500_000))
            case 'O'    => Some((500_000,    500_000))
            case 'H'    => Some((0,          1_000_000))
            case _      => None
        }

    def decodeMinor (c: Char): Option[(Int32, Int32)] = 
        match Char.toUpperCase(c) {
            case 'A'    => Some((0,          400_000))
            case 'B'    => Some((100_000,    400_000))
            case 'C'    => Some((200_000,    400_000))
            case 'D'    => Some((300_000,    400_000))
            case 'E'    => Some((400_000,    400_000))
            case 'F'    => Some((0,          300_000))
            case 'G'    => Some((100_000,    300_000))
            case 'H'    => Some((200_000,    300_000))
            case 'J'    => Some((300_000,    300_000))
            case 'K'    => Some((400_000,    300_000))
            case 'L'    => Some((0,          200_000))
            case 'M'    => Some((100_000,    200_000))
            case 'N'    => Some((200_000,    200_000))
            case 'O'    => Some((300_000,    200_000))
            case 'P'    => Some((400_000,    200_000))
            case 'Q'    => Some((0,          100_000))
            case 'R'    => Some((100_000,    100_000))
            case 'S'    => Some((200_000,    100_000))
            case 'T'    => Some((300_000,    100_000))
            case 'U'    => Some((400_000,    100_000))
            case 'V'    => Some((0,          0))
            case 'W'    => Some((100_000,    0))
            case 'X'    => Some((200_000,    0))
            case 'Y'    => Some((300_000,    0))
            case 'Z'    => Some((400_000,    0))
            case _      => None
        }

    pub def toEastingNorthing(x: NGR): Option[EastingNorthing] = 
        use Option.flatMap;
        use FromString.fromString;
        let NGR(s) = x;
        let major = String.charAt(0, s);
        let minor = String.charAt(1, s);
        let* e1 = String.slice(2, 7, s) |> fromString;
        let* n1 = String.slice(7, 12, s) |> fromString;
        let* (eM, nM) = decodeAlpha(major, minor);
        Some({ easting = eM + e1, northing = nM + n1 })


    def decodeAlpha(s: Char, t: Char): Option[(Int32, Int32)] =  
        use Option.flatMap;
        let* (eM, nM) = decodeMajor(s);
        let* (em, nm) = decodeMinor(t);
        Some((eM + em, nM + nm))

    /// This is for Datalog hence failure is signalled by `-1` rather than an Option type.
    pub def eastingfromOsgb36(s: String): Int32 = 
        use Option.{flatMap};
        let step = () -> {
            let* ngr    = parse(s);
            let* en     = toEastingNorthing(ngr);
            Some(en.easting)
        };
        Option.getWithDefault(-1, step())

    /// This is for Datalog hence failure is signalled by `-1` rather than an Option type.
    pub def northingfromOsgb36(s: String): Int32 = 
        use Option.{flatMap};
        let step = () -> {
            let* ngr    = parse(s);
            let* en     = toEastingNorthing(ngr);
            Some(en.northing)
        };
        Option.getWithDefault(-1, step())


}
