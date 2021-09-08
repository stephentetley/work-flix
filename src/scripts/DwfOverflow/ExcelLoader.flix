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
    use DwfOverflow/Relations.{WorkListItem, AibSite};


    /// WorkList


    type alias WorkListRow1 = 
        { reference: String
        , commonName: String
        , assetType: String
        }

    pub def readWorkList[r](sheetName: String, src: System.FilePath): Result[#{WorkListItem | r}, String] & Impure =
        let make1 = x1 -> #{ WorkListItem(x1.reference, x1.commonName, x1.assetType, siteName(x1.commonName)). };
        let makeAll = RelLib/Relation.foldMap(make1);
        Result.map(xs -> solve makeAll(xs), SheetIO/SheetReader.runXlsx(readWorkListSheet(sheetName), src))
        

    def readWorkListSheet(sheetName: String) : SheetReader[List[WorkListRow1]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom}; 
        let* s1     = getSheetNamed(sheetName); 
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

    /// All sites list
    type alias AibSite1 = 
        { commonName: String 
        , constructionYear: Int32
        , ngr: String
        }
    /// pub rel AibSite(siteName: String, installedFrom: Time.LocalDate, ngr: String)
    pub def readAibSites[r](src: System.FilePath): Result[#{AibSite | r}, String] & Impure =
        let make1 = x1 ->  #{ AibSite(x1.commonName, x1.constructionYear, x1.ngr). };
        Result.map(xs -> solve RelLib/Relation.foldMap(make1, xs), SheetIO/SheetReader.runXlsx(readAibSiteSheet(), src))
        

    def readAibSiteSheet() : SheetReader[List[AibSite1]] =
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, namedRowsFrom}; 
        let* s1     = getSheetNamed("Sheet1"); 
        let* xs     = namedRowsFrom(s1, 0, 1, evalSiteListRow());
        return(xs)


    def evalSiteListRow(): NamedRowEvaluator[AibSite1] = 
        use SheetIO/NamedRowEvaluator.{flatMap, return, optionWithDefault, getContentNamed, getInt32Named};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3) -> 
            { commonName        = x1
            , constructionYear  = x2
            , ngr               = x3
            })
            <&> getContentNamed("Common Name")
            <*> optionWithDefault(getInt32Named("Year Of Construction"), 1970)
            <*> getContentNamed("Loc.Ref.")

}