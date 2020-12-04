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


namespace AssetLib/S4/FileIO/IH08Table/XlsxReader {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.SheetReader;

    use AssetLib/S4/FileIO/IH08Table/Datatypes.{IH08Row};

    pub def readIH08File(path: System.FilePath): Result[List[IH08Row], System.Error] & Impure =    
        SheetIO/SheetReader.runXlsx(readIH08Sheet(), path)

    pub def readIH08Sheet(): SheetReader[List[IH08Row]] = 
        use SheetIO/SheetReader.{flatMap, return, getSheetNamed, allNamedRows};      
        let* s1     = getSheetNamed("Sheet1");
        let* xs     = allNamedRows(s1, evalIH08Row());
        return(xs)


    def evalIH08Row(): NamedRowEvaluator[IH08Row] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, optional, getStringNamed, getInt32Named, getInt64Named};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15) -> 
                { equiId            = x1
                , description       = x2
                , planningPlant     = x3
                , functionalLoc     = x4
                , techIdentNo       = x5
                , superordEquip     = x6
                , position          = x7
                , manufPartNo       = x8
                , manufacturer      = x9
                , manufSerialNo     = x10
                , modelNumber       = x11
                , userStatus        = x12
                , objectType        = x13
                , street            = x14
                , inventoryNo       = x15
                })
            <&> logged(yy -> "EquiId: ${yy}", getStringNamed("Equipment"))
            <*> getStringNamed("Description")
            <*> logged(yy -> "Planning Plant: ${Int32.toString(yy)}", getInt32Named("Planning Plant"))
        	<*> getStringNamed("Functional Loc.")
            <*> getStringNamed("TechIdentNo.")
            <*> logged(yy -> "Superord.Equip.: ${yy}", getStringNamed("Superord.Equip."))
            <*> getInt32Named("Position")
            <*> getCouldBeNumericalNamed("ManufPartNo.")
            <*> getStringNamed("Manufacturer")
            <*> getCouldBeNumericalNamed("ManufSerialNo.")
            <*> getStringNamed("Model number")
            <*> getStringNamed("User status")
            <*> getStringNamed("Object Type")
            <*> logged(yy -> "Street: ${yy}", getStringNamed("Street"))
            <*> optional(getInt64Named("Inventory no."))

    def getCouldBeNumericalNamed(label: String): NamedRowEvaluator[String] = 
        use SheetIO/NamedRowEvaluator.{map, alt, getStringNamedWithDefault, getInt64Named};
        alt(getStringNamedWithDefault(label, ""), map(Int64.toString, getInt64Named(label)))


    def logged(message: a -> String, eval1: NamedRowEvaluator[a]): NamedRowEvaluator[a] =
        use SheetIO/NamedRowEvaluator.{flatMap, return, liftAction};
        let* ans    = eval1;
        let* _      = liftAction(_ -> Console.printLine(message(ans)));
        return(ans)

}