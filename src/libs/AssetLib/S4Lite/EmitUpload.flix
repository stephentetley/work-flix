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

namespace AssetLib/S4Lite/EmitUpload {
    
    use AssetLib/FileIO/S4/TransferFile/Datatypes.{ClassFlocRow, ValuaFlocRow, ClassEquiRow, ValuaEquiRow};
    use AssetLib/S4Lite/Datatypes.{FlocCharacteristic, EquiCharacteristic};
    use AssetLib/S4Lite/Datatypes.S4DataType.{Character, Date, NumericInt, NumericFloat};

    /// FLOC

    pub def outputFlocUploads(userName: String,
                                input: List[FlocCharacteristic],
                                nameRoot: String,
                                outdir: System.FilePath): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let classFlocPath   = System/FilePath.append(outdir, System/FilePath.new("${nameRoot}-upload1-classfloc.txt"));
        let _               = Console.printLine("Writing '${classFlocPath}'");
        let classFlocRows   = makeClassFlocRows(input);
        let* _              = AssetLib/FileIO/S4/TransferFile/UploadWriter.writeClassFlocFile(userName, classFlocRows, classFlocPath);
        let valuaFlocPath   = System/FilePath.append(outdir, System/FilePath.new("${nameRoot}-upload2-valuafloc.txt"));
        let _               = Console.printLine("Writing '${valuaFlocPath}'");
        let valuaFlocRows   = makeValuaFlocRows(input);
        let* _              = AssetLib/FileIO/S4/TransferFile/UploadWriter.writeValuaFlocFile(userName, valuaFlocRows, valuaFlocPath);
        Ok()

    def makeClassFlocRows(xs: List[FlocCharacteristic]): List[ClassFlocRow] = 
        let equ = (x, y) -> x.className == y.className and x.funcloc == y.funcloc;
        let cmp = (x, y) -> match Order.compare(x.funcloc, y.funcloc) { 
            case EqualTo => Order.compare(x.className, y.className) |> Comparison.toInt
            case ord => Comparison.toInt(ord)
        };
        xs 
            |> List.map(toClassFlocRow)
            |> List.distinctWith(equ)
            |> List.sortWith(cmp)


    def toClassFlocRow(x: FlocCharacteristic): ClassFlocRow = 
        { funcloc               = x.funcloc
        , className             = x.className
        , classType             = "002"
        , internalClassNumber   = ""
        , status                = Some(1)
        }


    def makeValuaFlocRows(xs: List[FlocCharacteristic]): List[ValuaFlocRow] = 
        let cmp = (x, y) -> match Order.compare(x.funcloc, y.funcloc) { 
            case EqualTo => Order.compare(x.charId, y.charId) |> Comparison.toInt
            case ord => Comparison.toInt(ord)
        };
        xs 
            |> List.map(toValuaFlocRow)
            |> List.sortWith(cmp)
        
    def toValuaFlocRow(x: FlocCharacteristic): ValuaFlocRow = 
        match x.valueType { 
            case Character => characterValuaFlocRow(x)
            case Date => characterValuaFlocRow(x)
            case _ => numericValuaFlocRow(x)
        }

    def characterValuaFlocRow(x: FlocCharacteristic): ValuaFlocRow = 
        { funcloc           = x.funcloc
        , classType         = "002"
        , charId            = x.charName
        , charValue         = x.charValue
        , code              = Some(1)
        , valueDescription  = x.charValue
        , instanceCounter   = x.intCounterValue - 1
        , intCounterValue   = x.intCounterValue
        , valueFrom         = "0"
        , valueTo           = "0"
        }

    def numericValuaFlocRow(x: FlocCharacteristic): ValuaFlocRow = 
        { funcloc           = x.funcloc
        , classType         = "002"
        , charId            = x.charName
        , charValue         = ""
        , code              = Some(1)
        , valueDescription  = x.charValue
        , instanceCounter   = x.intCounterValue - 1
        , intCounterValue   = x.intCounterValue
        , valueFrom         = x.charValue
        , valueTo           = "0"
        }


    /// EQUI

    pub def outputEquiUploads(userName: String,
                                input: List[EquiCharacteristic],
                                nameRoot: String,
                                outdir: System.FilePath): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let classEquiPath   = System/FilePath.append(outdir, System/FilePath.new("${nameRoot}-upload1-classequi.txt"));
        let _               = Console.printLine("Writing '${classEquiPath}'");
        let classEquiRows   = makeClassEquiRows(input);
        let* _              = AssetLib/FileIO/S4/TransferFile/UploadWriter.writeClassEquiFile(userName, classEquiRows, classEquiPath);        
        let valuaEquiPath   = System/FilePath.append(outdir, System/FilePath.new("${nameRoot}-upload2-valuaequi.txt"));
        let _               = Console.printLine("Writing '${valuaEquiPath}'");
        let valuaEquiRows   = makeValuaEquiRows(input);
        let* _              = AssetLib/FileIO/S4/TransferFile/UploadWriter.writeValuaEquiFile(userName, valuaEquiRows, valuaEquiPath);
        Ok()

    def makeClassEquiRows(xs: List[EquiCharacteristic]): List[ClassEquiRow] = 
        let equ = (x, y) -> x.className == y.className and x.equi == y.equi;
        let cmp = (x, y) -> match Order.compare(x.equi, y.equi) { 
            case EqualTo => Order.compare(x.className, y.className) |> Comparison.toInt
            case ord => Comparison.toInt(ord)
        };
        xs 
            |> List.map(toClassEquiRow)
            |> List.distinctWith(equ)
            |> List.sortWith(cmp)


    def toClassEquiRow(x: EquiCharacteristic): ClassEquiRow = 
        { equi                  = x.equiId
        , className             = x.className
        , classType             = "002"
        , internalClassNumber   = ""
        , status                = Some(1)
        }


    def makeValuaEquiRows(xs: List[EquiCharacteristic]): List[ValuaEquiRow] = 
        let cmp = (x, y) -> match Order.compare(x.equi, y.equi) { 
            case EqualTo => Order.compare(x.charId, y.charId) |> Comparison.toInt
            case ord => Comparison.toInt(ord)
        };
        xs 
            |> List.map(toValuaEquiRow)
            |> List.sortWith(cmp)
        
    def toValuaEquiRow(x: EquiCharacteristic): ValuaEquiRow = 
        match x.valueType { 
            case Character => characterValuaEquiRow(x)
            case Date => characterValuaEquiRow(x)
            case _ => numericValuaEquiRow(x)
        }

    def characterValuaEquiRow(x: EquiCharacteristic): ValuaEquiRow = 
        { equi              = x.equiId
        , classType         = "002"
        , charId            = x.charName
        , charValue         = x.charValue
        , code              = Some(1)
        , valueDescription  = x.charValue
        , instanceCounter   = x.intCounterValue - 1
        , intCounterValue   = x.intCounterValue
        , valueFrom         = "0"
        , valueTo           = "0"
        }

    def numericValuaEquiRow(x: EquiCharacteristic): ValuaEquiRow = 
        { equi              = x.equiId
        , classType         = "002"
        , charId            = x.charName
        , charValue         = ""
        , code              = Some(1)
        , valueDescription  = x.charValue
        , instanceCounter   = x.intCounterValue - 1
        , intCounterValue   = x.intCounterValue
        , valueFrom         = x.charValue
        , valueTo           = "0"
        }

}
