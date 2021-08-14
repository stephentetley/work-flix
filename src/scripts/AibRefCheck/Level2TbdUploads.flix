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


namespace AibRefCheck/Level2Uploads {

    use SheetIO.NamedRowEvaluator;
    use SheetIO.RowEvaluator;
    use SheetIO/Reader.{XlsxSource};

    use AssetLib/FileIO/S4/TransferFile/Datatypes.{ValuaFlocRow};
    
    pub rel InstReference(sainum: String)

    type alias Sources = 
        { aibAllSites: XlsxSource
        , downloadFile: System.FilePath
        }

    pub def readSources(src: Sources): Result[#{InstReference, ValuaFloc |r}, String] & Impure =
        use Result.{flatMap};
        let* sites      = readInstReference(src.aibAllSites);
        let* valuaflocs = readValuaFlocFile(src.downloadFile);
        Ok(sites <+> valuaflocs)



    /// TODO - this should be in TransferFile...
    pub rel ValuaFloc(funcloc: String,
                        classType: String,
                        charId: String,
                        charValue: String,
                        code: Option[Int32],
                        valueDescription: String,
                        instanceCounter: Int32,
                        intCounterValue: Int32,
                        valueFrom: String,
                        valueTo: String)


    pub rel Answer(funcloc: String,
                    classType: String,
                    charId: String,
                    ansValue: String,
                    code: Option[Int32],                        
                    instanceCounter: Int32,
                    intCounterValue: Int32)


    pub def genAnswers(db: #{ValuaFloc, InstReference, 
                            Answer |r}): #{Answer | r1} =                             
        let rules = #{
            Answer(funcloc, classtype, id, "TBD", code, instanceCounter, intCounterValue) :- 
                ValuaFloc(funcloc, classtype, id, charValue, code, _, instanceCounter, intCounterValue, _, _),
                InstReference(charValue), 
                if not flocToIgnore(funcloc).
        };    
    solve (db <+> rules) project Answer

    def flocToIgnore(s: String): Bool = 
        String.endsWith(s, "TWP") or String.endsWith(s, "WSP") or String.endsWith(s, "WTT") or String.endsWith(s, "WWT")
        

    pub def writeAnswers(solns: #{ Answer |r}, userName: String, path: System.FilePath): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let xs      = query solns select (t,u,v,w,x,y,z) from Answer(t,u,v,w,x,y,z) |> Array.toList;
        let rows    = xs |> List.map(makeValuaFlocRow) |> List.sortWith((x1, y1) -> Order.compare(x1.funcloc, y1.funcloc)); 
        AssetLib/FileIO/S4/TransferFile/Builtins.writeValuaFlocFile(userName, rows, path)


    def makeValuaFlocRow(tup: (String, String, String, String, Option[Int32], Int32, Int32)): ValuaFlocRow = 
        let (x1, x2, x3, x4, x5, x6, x7) = tup;
        { funcloc = x1
        , classType = x2
        , charId = x3
        , charValue = x4
        , code = x5
        , valueDescription = x4
        , instanceCounter = x6
        , intCounterValue = x7
        , valueFrom = ""
        , valueTo = ""
        }
        


    /// Loader...
        

    pub def readValuaFlocFile(src: System.FilePath): Result[#{ValuaFloc | r}, String] & Impure = 
        use Result.{flatMap};
        let* xs     = AssetLib/FileIO/S4/TransferFile/Builtins.readValuaFlocFile(src);
        let ans     = Relation.foldMap(makeValuaFloc, xs);
        Ok(ans)
            


    def makeValuaFloc(x: ValuaFlocRow): #{ValuaFloc | r} = #{ 
        ValuaFloc(x.funcloc, x.classType, x.charId, x.charValue, x.code, x.valueDescription,
                        x.instanceCounter, x.intCounterValue, x.valueFrom, x.valueTo).
    }

    /// Read from IH06 export of sites
    pub def readInstReference(src: XlsxSource): Result[#{InstReference | r}, String] & Impure =
        SheetIO/Reader.allNamedRelations(src, evalInstReference())


    def evalInstReference(): NamedRowEvaluator[#{InstReference | r}] =
        use SheetIO/NamedRowEvaluator.{getTrimmedContentNamed};
        use SheetIO/NamedRowEvaluator.{<&>, <*>};
        (x1 -> #{ InstReference(x1). })
            <&> getTrimmedContentNamed("InstReference")
    
    

}
