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

namespace Skeleton/XlsxReader {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use Skeleton/Datatypes.{AibInputRow, FlocInputRow};


    /// AIB Annotated Export
    pub def readAnnotatedAibExport(path: System.FilePath): Result[List[AibInputRow], String] & Impure =    
        SheetIO/SheetReader.runXlsx(readAibInputRows(), path)

    pub def readAibInputRows(): SheetReader[List[AibInputRow]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};      
        let* s1     = getSheetNamed("Sheet1");
        let* xs     = allNamedRows(s1, evalAibInputRow());
        return(xs)


    def evalAibInputRow(): NamedRowEvaluator[AibInputRow] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed, getLocalDateNamed, map}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13) -> 
                { reference             = x1
                , commonName            = x2
                , s4Floc                = x3
                , s4EquiType            = x4
                , s4EquiClass            = x5
                , superiorEquipment     = x6
                , installedFrom         = x7
                , manufacturer          = x8
                , model                 = x9
                , specificModelFrame    = x10
                , serialNumber          = x11
                , locRef                = x12
                , assetStatus           = x13
                })
            <&> getContentNamed("Reference")
            <*> getContentNamed("Common Name")
            <*> map(Skeleton/S4Floc.new, getContentNamed("S4 Floc"))
            <*> getContentNamed("Equipment Type")
            <*> getContentNamed("Equipment Class")
            <*> getContentNamed("Superior Equipment")
            <*> getLocalDateNamed("Installed From")
            <*> getContentNamed("Manufacturer")
            <*> getContentNamed("Model")
            <*> getContentNamed("Specific Model/Frame")
            <*> getContentNamed("Serial No")
            <*> getContentNamed("Loc.Ref.")
            <*> getContentNamed("AssetStatus")
        
    /// S4 Floc hierarchy
    pub def readFlocHierarchy(path: System.FilePath): Result[List[FlocInputRow], String] & Impure =    
        SheetIO/SheetReader.runXlsx(readFlocInputRows(), path)

    pub def readFlocInputRows(): SheetReader[List[FlocInputRow]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};      
        let* s1     = getSheetNamed("Floc");
        let* xs     = allNamedRows(s1, evalFlocInputRow());
        return(xs)


    def evalFlocInputRow(): NamedRowEvaluator[FlocInputRow] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, getContentNamed, map}; 
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5) -> 
                { s4Floc        = x1
                , structure     = x2
                , description   = x3
                , objectType    = x4
                , systemClass   = x5
                })
            <&> map(Skeleton/S4Floc.new, getContentNamed("S4 Floc"))
            <*> getContentNamed("Structure")
            <*> getContentNamed("Description")
            <*> getContentNamed("Object Type")
            <*> getContentNamed("System Class")
        


}