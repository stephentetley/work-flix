/*
 * Copyright 2021 Stephen Tetley
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


namespace AssetScripts/NonOp/Utils {

    use AssetLib/S4Lite/EmitUxl.{UxlOutputArgs};

    pub def updateArgs(i: Int32, args: UxlOutputArgs): UxlOutputArgs = 
        let newName = String.replace("##", ToString.toString(i), args.changeRequestName);
        let newPath = mapBaseName(args.outpath, s -> String.replace("##", ToString.toString(i), s));
        { changeRequestName = newName
        , outpath = newPath
        , uxlTemplate = args.uxlTemplate
        }

    /// For System.FilePath...
    def mapBaseName(path: System.FilePath, fn: String -> String): System.FilePath = 
        match System/FilePath.getBaseName(path) {
            case Some(name1) => System/FilePath.putBaseName(path, fn(name1))
            case None => path
        }

    /// Sometimes pgdesc may be aninvalid and `getEquipName` wont work.
    /// In this case take whatever is after the rightmost "/"
    pub def getShortName(pgdesc: String, pdesc: String, commonName: String): String = 
        match getEquipName(pgdesc, pdesc, commonName) { 
            case "" => snd(String.breakOnRight("/", commonName))
            case s1 => s1
        }
            |> shorten

    def getEquipName(pgdesc: String, pdesc: String, commonName: String): String = 
        match (pgdesc, pdesc) {
            case ("NULL", "NULL") => commonName
            case ("NULL", _) => snd(String.breakOnRight("${pdesc}/", commonName))
            case (_, "NULL") => snd(String.breakOnRight("${pgdesc}/", commonName))
            case (_, _) => snd(String.breakOnRight("${pgdesc}/${pdesc}/", commonName))
        } 

    def shorten(s: String): String = 
        s |> AssetLib/Base/Utils.properCaseName |> String.takeLeft(40)



    pub def sublists(n: Int32, xs: List[a]): List[List[a]] = 
        if (n < 1)
            Nil
        else 
            sublistsHelper(n, 0, xs, ks -> ks, ls -> ls)

    pub def sublistsHelper(n: Int32, i: Int32, xs: List[a], k1: List[a] -> List[a], k2: List[List[a]] -> List[List[a]]): List[List[a]] =
        match xs { 
            case Nil => match k1(Nil) { 
                case Nil => k2(Nil)
                case ks => k2(ks :: Nil)
            }
            case x1 :: rs => {
                if (i >= n) 
                    sublistsHelper(n, 1, rs, ks -> x1 :: ks, ls -> k2(k1(Nil) :: ls))
                else 
                    sublistsHelper(n, i + 1, rs, ks -> k1(x1 :: ks), k2)
            }
        }

    pub def divide(n: Int32, xs: List[a]): List[List[a]] = 
        let len = List.length(xs);
        let sz = Float64.ceil(Int32.toFloat64(len) / Int32.toFloat64(n));
        match Float64.tryToInt32(sz) {
            case Some(sz1) => sublists(sz1, xs)
            case None => Nil
        }
        


}
