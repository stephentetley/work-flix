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

namespace DwfOverflow/Rules/ExcelLoader {

    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;
    use DwfOverflow/Relations.{WorkListItem};

    type alias WorkListRow1 = 
        { reference: String
        , commonName: String
        , assetType: String
        }

    pub def readWorkList[r](src: System.FilePath): Option[#{WorkListItem | r}] & Impure =
        let step = (ac, x) -> {
            let x1 = #{ WorkListItem(x.reference, x.commonName, x.assetType, siteName(x.commonName)). };
            x1 <+> ac
        };
        match  SheetIO/SheetReader.runXlsx(readWorkListSheet(), src) {
            case Ok(xs) => Some(solve List.foldLeft(step, #{}, xs))
            case Err(_) => None
        }
        

    def readWorkListSheet() : SheetReader[List[WorkListRow1]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom}; 
        let* s1     = getSheetNamed("Stephen"); 
        let* xs     = namedRowsFrom(s1, 0, 1, evalWorkListRow());
        return(xs)



    def evalWorkListRow(): NamedRowEvaluator[WorkListRow1] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) -> 
                { reference     = String.trim(x1)
                , commonName    = String.trim(x2)
                , assetType     = String.trim(x3)
                })
            <&> getContentNamed("Reference")
            <*> getContentNamed("CommonName")
            <*> getContentNamed("AssetType")


    pub def siteName(commonName: String): String = 
        match String.splitOn(commonName, "/") {
            case x :: y :: _ => "${x}/${y}"
            case _ => commonName
        }

}