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

use System.Error.{IllegalArgumentException, Generic};

namespace AssetLib/Common/Osgb36 {


    /// Two letters and 10 digits
    pub opaque type NGR = String

    pub def parse(s: String): Result[NGR, System.Error] = 
        use Result.flatMap;
        let s1 = String.trim(s);
        let* patt = Regex/Pattern.compile("\p{Alpha}{2}[0-9]{10}");
        if (Regex.isMatch(patt, s1))
            Ok(NGR(s1))
        else 
            Err(IllegalArgumentException)

    
    pub def toString(x: NGR): String = 
        let NGR(s) = x;
        s

    type alias EastingNorthing = { easting: Int32, northing: Int32 }


   
    def decodeMajor(c: Char): Result[(Int32, Int32), System.Error] = 
        match Char.toUpperCase(c) {
            case 'S'    => Ok((0,          0))
            case 'T'    => Ok((500_000,    0))
            case 'N'    => Ok((0,          500_000))
            case 'O'    => Ok((500_000,    500_000))
            case 'H'    => Ok((0,          1_000_000))
            case _      => Err(IllegalArgumentException)
        }

    def decodeMinor (c: Char): Result[(Int32, Int32), System.Error] = 
        match Char.toUpperCase(c) {
            case 'A'    => Ok((0,          400_000))
            case 'B'    => Ok((100_000,    400_000))
            case 'C'    => Ok((200_000,    400_000))
            case 'D'    => Ok((300_000,    400_000))
            case 'E'    => Ok((400_000,    400_000))
            case 'F'    => Ok((0,          300_000))
            case 'G'    => Ok((100_000,    300_000))
            case 'H'    => Ok((200_000,    300_000))
            case 'J'    => Ok((300_000,    300_000))
            case 'K'    => Ok((400_000,    300_000))
            case 'L'    => Ok((0,          200_000))
            case 'M'    => Ok((100_000,    200_000))
            case 'N'    => Ok((200_000,    200_000))
            case 'O'    => Ok((300_000,    200_000))
            case 'P'    => Ok((400_000,    200_000))
            case 'Q'    => Ok((0,          100_000))
            case 'R'    => Ok((100_000,    100_000))
            case 'S'    => Ok((200_000,    100_000))
            case 'T'    => Ok((300_000,    100_000))
            case 'U'    => Ok((400_000,    100_000))
            case 'V'    => Ok((0,          0))
            case 'W'    => Ok((100_000,    0))
            case 'X'    => Ok((200_000,    0))
            case 'Y'    => Ok((300_000,    0))
            case 'Z'    => Ok((400_000,    0))
            case _      => Err(IllegalArgumentException)
        }

    def decodeAlpha(s: Char, t: Char): Result[(Int32, Int32), System.Error] =  
        use Result.flatMap;
        let* (eM, nM) = decodeMajor(s);
        let* (em, nm) = decodeMinor(t);
        Ok((eM + em, nM + nm))


    pub def toEastingNorthing(x: NGR): Result[EastingNorthing, System.Error] = 
        use Result.flatMap;
        let NGR(s) = x;
        let major = String.charAt(0, s);
        let minor = String.charAt(1, s);
        let* e1 = String.slice(s, 2, 7) |> Int32.fromString |> Result.mapErr(Generic);
        let* n1 = String.slice(s, 7, 12) |> Int32.fromString |> Result.mapErr(Generic);
        let* (eM, nM) = decodeAlpha(major, minor);
        Ok({ easting = eM + e1, northing = nM + n1 })

    def findMajor(easting: Int32, northing: Int32): Result[Char, System.Error] =
        match (easting,northing) {
            case (e,n) if e >= 0 && e < 500_000          && n >= 0 && n < 500_000           => Ok('S')
            case (e,n) if e >= 500_000 && e < 1_000_000  && n >= 0 && n < 500_000           => Ok('T')
            case (e,n) if e >= 0 && e < 500_000          && n >= 500_000 && n < 1_000_000   => Ok('N')
            case (e,n) if e >= 500_000 && e < 1_000_000  && n >= 500_000 && n < 1_000_000   => Ok('O')
            case (e,n) if e >= 0 && e < 500_000          && n >= 1_000_000 && n < 1_500_000 => Ok('H')
            case (e,n) if e >= 500_000 && e < 1_000_000  && n >= 1_000_000 && n < 1_500_000 => Ok('J')
            case (_,_) => Err(IllegalArgumentException)
        }

    def minorGrid() : Array[Array[Char]] & Impure = 
        [ [ 'V', 'Q', 'L', 'F', 'A' ]
        , [ 'W', 'R', 'M', 'G', 'B' ]
        , [ 'X', 'S', 'N', 'H', 'C' ]
        , [ 'Y', 'T', 'O', 'J', 'D' ]
        , [ 'Z', 'U', 'P', 'K', 'E' ]
        ]

    def findMinor (easting: Int32, northing: Int32): Result[Char, System.Error] & Impure =
        let arr2D = minorGrid();
        let modE = easting % 500000;
        let modN = northing % 500000;
        let divE = modE / 100000;
        let divN = modN / 100000;
        if (divE >= 0 && divE < 5 && divN >= 0 && divN < 5) {
            let row1 = arr2D[divE];
            let c = row1[divN];
            Ok(c)
        } else
            Err(IllegalArgumentException)



    pub def toNGR (x: EastingNorthing): Result[NGR, System.Error] =  
        use Result.flatMap;
        let* major = findMajor(x.easting, x.northing);
        let* minor = findMinor(x.easting, x.northing) as & Pure;
        let smallE = Int32.toString(x.easting % 100000);
        let smallN = Int32.toString(x.northing % 100000);
        let s = Char.toString(major) + Char.toString(minor) + String.padLeft(5, '0', smallE) + String.padLeft(5, '0', smallN);
        Ok(NGR(s))
    


}