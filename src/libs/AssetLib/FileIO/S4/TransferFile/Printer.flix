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



namespace AssetLib/FileIO/S4/TransferFile/Printer {

    use Time.LocalDateTime;
    use Text/SimpleFormat.{Doc};
    use Text/SimpleFormat.{toString, besideSpace, beside, below, hcat, vcat, text, char, colon, punctuate, tab, line};
    use Text/SimpleFormat.{<>, <<>>, <!>};


    use AssetLib/FileIO/S4/TransferFile/Datatypes.{TransferFile, FileHeader, FileType, DataModel, EntityType, Headers, DataRow};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.FileType.{Download, Upload};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.DataModel.{U1};
    use AssetLib/FileIO/S4/TransferFile/Datatypes.EntityType.{FuncLoc, ClassFloc, ValuaFloc, Iflotx, Equi, ClassEqui, ValuaEqui, Eqmltxt};

    pub def writeTransferFile(x: TransferFile, path: System.FilePath): Result[Unit, String] & Impure = 
        use System/IO.WriteMode.{Create};
        let str = ppTransferFile(x).toString();
        System/IO.writeFileWith({path = path, charset = Text/Charset.utf_8(), mode = Create}, str) |> Result.mapErr(e -> "${e}")

    pub def printTransferFile(x: TransferFile): String & Impure =         
        ppTransferFile(x).toString()

    
    def ppTransferFile(x: TransferFile): Doc & Impure = 
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
        use Option.flatMap;
        let step = () -> {
            let* dfmt = Time/Format/DateTimeFormatter.ofPattern("yyyyMMdd");
            let* tfmt = Time/Format/DateTimeFormatter.ofPattern("HHmmss");
            let date = Time/LocalDateTime.format(dfmt, dt);
            let time = Time/LocalDateTime.format(tfmt, dt);
            Some(commentDoc(text("Date:") <<>> text(date) <<>> char('/') <<>> text("Time:") <<>> text(time)))
        };
        Option.getWithDefault(step(), comment("Date: ____ / Time: ____"))   


    def ppSelection (xs: List[String]): Doc = match List.map(comment, xs) {
        case Nil  => defines("Selection", "")
        case rows => defines("Selection", "") <!> vcat(rows)
    }
        

    def ppHeaders(arr: Headers): Doc & Impure = 
        let names = punctuate(tab(), List.map(x -> text(x), Array.toList(arr)));
        char('*') <> hcat(names)

    def ppDataRow(arr: DataRow): Doc & Impure = 
        hcat(List.map(x -> text(x) <> tab(), Array.toList(arr)))   

}