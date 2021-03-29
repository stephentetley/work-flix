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


namespace CostCenters/ReadDataSheet {

    use SheetIO.SheetReader;
    use SheetIO.NamedRowEvaluator;

    use CostCenters/EmitFunclocTransferFile.CCUpdateRow;
    use CostCenters/EmitFunclocTransferFile.Origin;
    use CostCenters/EmitFunclocTransferFile.Origin.{Direct, Hierarchy};


    pub def readCostCentersFile(xlsxPath: System.FilePath): Result[List[CCUpdateRow], String] & Impure =
       SheetIO/SheetReader.runXlsx(readCostCenters(), xlsxPath)


    pub def readCostCenters(): SheetReader[List[CCUpdateRow]] =
        use SheetIO/SheetReader.{flatMap, return, namedRowsFrom};
        let* sheet1 = SheetIO/SheetReader.getSheetNamed("Sheet1");
        let* xs     = SheetIO/SheetReader.namedRowsFrom(sheet1, 0, 1, evalCostCenteRow());
        return(xs)

    def evalCostCenteRow(): NamedRowEvaluator[CCUpdateRow] = 
        use SheetIO/NamedRowEvaluator.{<&>, <*>, getContentNamed};
        ((x1, x2, x3, x4, x5) -> 
            { funcloc           = x1
            , costCenter        = x2
            , costCenterOrigin  = x3
            , description       = x4
            , statusOfObject    = x5
            })
            <&> getContentNamed("CFIN Mapping")
            <*> getContentNamed("Desired CC For AfterLoad")
            <*> getOriginNamed("CCtr orig After Load")
            <*> getContentNamed("Description")
            <*> getContentNamed("User status")

    def getOriginNamed(label: String): NamedRowEvaluator[Origin] =
        use SheetIO/NamedRowEvaluator.{getContentNamed, map}; 
        let fn = x -> if (x == "H") Hierarchy else Direct;
        map(fn, getContentNamed(label))

}
