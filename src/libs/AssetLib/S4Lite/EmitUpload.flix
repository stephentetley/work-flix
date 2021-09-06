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
    
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/FileIO/S4/TransferFile/Datatypes.{ClassFlocRow, ValuaFlocRow, ClassEquiRow, ValuaEquiRow};
    use AssetLib/S4Lite/Datatypes.{SLFlocCharacteristic, SLEquiCharacteristic};
    use AssetLib/S4Lite/Datatypes.SLDatatype.{Character, Date, NumericInt, NumericFloat};

    /// FLOC

    /// WARNING
    /// Cannot upload new characteristics onto a Floc in the staging tables.
    /// S4 reports nonsensical errors.
    /// To generate Flocs we either have to use all UXL or approve and activate
    /// minimal flocs (then File Upload further characteristics).


    pub def outputFlocUploads(userName: String,
                                input: Chain[SLFlocCharacteristic],
                                nameRoot: String,
                                outdir: System.FilePath): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let input1          = Chain.toList(input);
        let classFlocPath   = System/FilePath.append(outdir, System/FilePath.new("${nameRoot}-upload1-classfloc.txt"));
        let _               = Console.printLine("Writing '${classFlocPath}'");
        let classFlocRows   = makeClassFlocRows(input1);
        let* _              = AssetLib/FileIO/S4/TransferFile/Builtins.writeClassFlocFile(userName, classFlocRows, classFlocPath);
        let valuaFlocPath   = System/FilePath.append(outdir, System/FilePath.new("${nameRoot}-upload2-valuafloc.txt"));
        let _               = Console.printLine("Writing '${valuaFlocPath}'");
        let valuaFlocRows   = makeValuaFlocRows(input1);
        let* _              = AssetLib/FileIO/S4/TransferFile/Builtins.writeValuaFlocFile(userName, valuaFlocRows, valuaFlocPath);
        Ok()

    def makeClassFlocRows(xs: List[SLFlocCharacteristic]): List[ClassFlocRow] = 
        let equ = (x, y) -> x.className == y.className and x.funcloc == y.funcloc;
        let cmp = (x, y) -> match Order.compare(x.funcloc, y.funcloc) { 
            case EqualTo => Order.compare(x.className, y.className)
            case ans => ans
        };
        xs 
            |> List.map(toClassFlocRow)
            |> List.distinctWith(equ)
            |> List.sortWith(cmp)


    def toClassFlocRow(x: SLFlocCharacteristic): ClassFlocRow = 
        { funcloc               = x.funcloc
        , className             = x.className
        , classType             = "003"
        , internalClassNumber   = ""
        , status                = Some(1)
        }


    def makeValuaFlocRows(xs: List[SLFlocCharacteristic]): List[ValuaFlocRow] = 
        let cmp = (x, y) -> match Order.compare(x.funcloc, y.funcloc) { 
            case EqualTo => Order.compare(x.charId, y.charId)
            case ans => ans
        };
        xs 
            |> List.map(toValuaFlocRow)
            |> List.sortWith(cmp)
        
    def toValuaFlocRow(x: SLFlocCharacteristic): ValuaFlocRow = 
        match x.valueType { 
            case Character => characterValuaFlocRow(x)
            case Date => characterValuaFlocRow(x)
            case _ => numericValuaFlocRow(x)
        }

    def characterValuaFlocRow(x: SLFlocCharacteristic): ValuaFlocRow = 
        { funcloc           = x.funcloc
        , classType         = "003"
        , charId            = x.charName
        , charValue         = x.charValue
        , code              = Some(1)
        , valueDescription  = x.charValue
        , instanceCounter   = x.intCounterValue - 1
        , intCounterValue   = x.intCounterValue
        , valueFrom         = "0"
        , valueTo           = "0"
        }

    def numericValuaFlocRow(x: SLFlocCharacteristic): ValuaFlocRow = 
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

    pub def renumberSLEquiCharacteristics(sourceKeyMap: Map[String, String], 
                                            s4ChangeRequstEquitab: XlsxSource, 
                                            xs: Chain[SLEquiCharacteristic]): Result[Chain[SLEquiCharacteristic], String] & Impure = 
        AssetLib/S4Lite/Internal/Phase2Renumber.renumber(sourceKeyMap, s4ChangeRequstEquitab, Chain.toList(xs)) 
            |> Result.map(Chain.fromList)

    pub def allClassFilter(): ClassEquiRow -> Bool = _row -> true

    pub def namedClassFilter(names: List[String]): ClassEquiRow -> Bool = row -> 
        List.memberOf(row.className, names)

    pub def outputEquiUploads(userName: String,
                                input: Chain[SLEquiCharacteristic],
                                nameRoot: String,
                                classFilter: ClassEquiRow -> Bool,
                                outdir: System.FilePath): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let input1          = Chain.toList(input);
        let classEquiPath   = System/FilePath.append(outdir, System/FilePath.new("${nameRoot}-upload1-classequi.txt"));
        let _               = Console.printLine("Writing '${classEquiPath}'");
        let classEquiRows   = makeClassEquiRows(input1) |> List.filter(classFilter);
        let* _              = AssetLib/FileIO/S4/TransferFile/Builtins.writeClassEquiFile(userName, classEquiRows, classEquiPath);        
        let valuaEquiPath   = System/FilePath.append(outdir, System/FilePath.new("${nameRoot}-upload2-valuaequi.txt"));
        let _               = Console.printLine("Writing '${valuaEquiPath}'");
        let valuaEquiRows   = makeValuaEquiRows(input1);
        let* _              = AssetLib/FileIO/S4/TransferFile/Builtins.writeValuaEquiFile(userName, valuaEquiRows, valuaEquiPath);
        Ok()

    pub def outputClassEquis(userName: String,
                                input: Chain[SLEquiCharacteristic],
                                outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let input1          = Chain.toList(input);
        let classEquiRows   = makeClassEquiRows(input1);
        let* _              = AssetLib/FileIO/S4/TransferFile/Builtins.writeClassEquiFile(userName, classEquiRows, outpath);
        Ok()


    pub def outputValuaEquis(userName: String,
                                input: Chain[SLEquiCharacteristic],
                                outpath: System.FilePath): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let input1          = Chain.toList(input);
        let valuaEquiRows   = makeValuaEquiRows(input1);
        let* _              = AssetLib/FileIO/S4/TransferFile/Builtins.writeValuaEquiFile(userName, valuaEquiRows, outpath);
        Ok()



    def makeClassEquiRows(xs: List[SLEquiCharacteristic]): List[ClassEquiRow] = 
        let equ = (x, y) -> x.className == y.className and x.equi == y.equi;
        let cmp = (x, y) -> match Order.compare(x.equi, y.equi) { 
            case EqualTo => Order.compare(x.className, y.className)
            case ans => ans
        };
        xs 
            |> List.map(toClassEquiRow)
            |> List.distinctWith(equ)
            |> List.sortWith(cmp)


    def toClassEquiRow(x: SLEquiCharacteristic): ClassEquiRow = 
        { equi                  = x.equiId
        , className             = x.className
        , classType             = "002"
        , internalClassNumber   = ""
        , status                = Some(1)
        }


    def makeValuaEquiRows(xs: List[SLEquiCharacteristic]): List[ValuaEquiRow] = 
        let cmp = (x, y) -> match Order.compare(x.equi, y.equi) { 
            case EqualTo => Order.compare(x.charId, y.charId)
            case ans => ans
        };
        xs 
            |> List.map(toValuaEquiRow)
            |> List.sortWith(cmp)
        
    def toValuaEquiRow(x: SLEquiCharacteristic): ValuaEquiRow = 
        match x.valueType { 
            case Character => characterValuaEquiRow(x)
            case Date => characterValuaEquiRow(x)
            case _ => numericValuaEquiRow(x)
        }

    def characterValuaEquiRow(x: SLEquiCharacteristic): ValuaEquiRow = 
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

    def numericValuaEquiRow(x: SLEquiCharacteristic): ValuaEquiRow = 
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
