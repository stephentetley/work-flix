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

use Time.LocalDateTime;
use Text/SimpleFormat.{Doc};
use Text/SimpleFormat.{toString, besideSpace, beside, below, hcat, vcat, text, char, colon, punctuate, tab, line};
use Text/SimpleFormat.{<>, <<>>, <!>};


use AssetLib/S4/FileIO/ChangeFile/Datatypes.{FileType, DataModel, EntityType, Headers, Selection, DataRow, FileHeader, ChangeFile};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.FileType.{Download, Upload};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.DataModel.{U1};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.EntityType.{FuncLoc, ClassFloc, ValuaFloc, Iflotx, Equi, ClassEqui, ValuaEqui, Eqmltxt};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.Headers.{Headers};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.Selection.{Selection};
use AssetLib/S4/FileIO/ChangeFile/Datatypes.DataRow.{DataRow};


namespace AssetLib/S4/FileIO/ChangeFile/Printer {




    pub def writeChangeFile(x: ChangeFile, path: String): Result[Unit, System.Error] & Impure = 
        let path1 = System/FilePath.new(path);
        let str = ppChangeFile(x).toString();
        System/File.writeFile(path1, Text/Charset.utf_8(), str)

    pub def printChangeFile(x: ChangeFile): String & Impure = 
        ppChangeFile(x).toString()

    
    def ppChangeFile (x: ChangeFile): Doc & Impure = 
        vcat(
                ppFileHeader(x.fileHeader)
            :: ppSelection(x.selection)
            :: ppHeaders(x.headers)
            :: List.map(ppDataRow, x.dataRows)
        ) <> line()

    def ppFileHeader (x: FileHeader): Doc = 
        vcat(
                ppFileType(x.fileType)
            :: ppDataModel(x.dataModel)
            :: ppEntityType(x.entityType)
            :: ppVariant(x.variant)
            :: ppUser(x.user)
            :: ppDateTime(x.dateTime)
            :: Nil
        )

    def comment(s: String): Doc = char('*') <<>> text(s)

    def commentDoc(d: Doc): Doc = char('*') <<>> d

    def defines(name: String, value: String): Doc = 
        char('*') <<>> text(name) <> colon() <<>> text(value)
        
    def ppFileType(x: FileType): Doc = match x {
        case Download => comment("Download")
        case Upload => comment("Upload")
    }

    def ppDataModel(x: DataModel): Doc =  match x {
        case U1 => defines("Data Model", "U1")
    }

    def ppEntityType (x : EntityType): Doc =
        let name = match x {
            case FuncLoc    => "FUNCLOC"
            case ClassFloc  => "CLASSFLOC"
            case ValuaFloc  => "VALUAFLOC"
            case Iflotx     => "IFOLTX"
            case Equi       => "EQUI"
            case ClassEqui  => "CLASSEQUI" 
            case ValuaEqui  => "VALUAEQUI"
            case Eqmltxt    => "EQMLTXT"
        };
        defines("Entity Type", name)
    
    def ppVariant (name: String): Doc = defines("Variant", name)

    def ppUser (name : String): Doc = defines("User", name)

    def ppDateTime (dt : LocalDateTime) : Doc = 
        use Result.flatMap;
        let step = () -> {
            let* dfmt = Time/Format/DateTimeFormatter.fromPattern("yyyyMMdd");
            let* tfmt = Time/Format/DateTimeFormatter.fromPattern("HHmmss");
            let date = Time/LocalDateTime.format(dt, dfmt);
            let time = Time/LocalDateTime.format(dt, tfmt);
            Ok(commentDoc(text("Date:") <<>> text(date) <<>> char('/') <<>> text("Time:") <<>> text(time)))
        };
        Result.getWithDefault(step(), comment("Date: ____ / Time: ____"))   


    def ppSelection (x: Selection): Doc = 
        let Selection(xs) = x;
        match List.map(comment, xs) {
            case Nil  => defines("Selection", "")
            case rows => defines("Selection", "") <!> vcat(rows)
        }
        

    def ppHeaders(x: Headers): Doc & Impure = 
        let Headers(arr) = x;
        let names = punctuate(tab(), List.map(x -> text(x), Array.toList(arr)));
        char('*') <> hcat(names)

    def ppDataRow(x: DataRow): Doc & Impure = 
        let DataRow(arr) = x;
        hcat(List.map(x -> text(x) <> tab(), Array.toList(arr)))   

}