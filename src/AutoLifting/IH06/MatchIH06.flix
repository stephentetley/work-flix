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



namespace AssetLib/AutoLifting/IH06Tree/MatchIH06 {

    use BasicDb.DbMonad;
    use BasicDb.PreparedStatementSetter;
    use BasicDb.RowEvaluator;

    use SheetIO.RowSetter;
    use SheetIO.SheetWriter;

    use AssetLib/Aib/FileIO/AideChangeSummary/Datatypes.{AibExportRow};
    use AssetLib/S4/FileIO/IH06Tree/Raw/Datatypes.{IH06Row};
    use AssetLib/S4/FileIO/IH06Tree/Raw/Datatypes.IH06Row.{FlocRow, EquiRow};

    type alias ResultRow = 
        { pliReference: String
        , aibItemName: String
        , ywRefs: String
        , s4EquiIds: String
        , s4EquiNames: String
        }


    type alias S4Row = 
        { equiId: String
        , ywRef: String
        , equiName: String
        }

    pub def makeIH06MatchesReport(x: { aideFile: System.FilePath
                                     , ih06File: System.FilePath
                                     , xlsxOutPath: System.FilePath}): Result[Unit, System.Error] & Impure = 
        let tempFile    = System/FilePath.replaceFileName(x.xlsxOutPath, "temp.sqlite");
        let _           = Console.printLine(System/FilePath.toString(tempFile));
        BasicDb/DbMonad.runSQLite(makeReport(x), tempFile)

    def makeReport(x: { aideFile: System.FilePath
                      , ih06File: System.FilePath
                      , xlsxOutPath: System.FilePath}): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult, liftAction, liftResult, filterMapM};
        use AssetLib/Aib/FileIO/AideChangeSummary/XlsxReader.{readFile => readAideFile};
        use SheetIO/SheetWriter.{runXlsx};
        let* _              = setupIH06Db(x.ih06File);        
        let* aideRows       = liftActionResult(_ -> readAideFile(x.aideFile));
        let* namePattern    = liftResult(_ -> Text/Regex/Pattern.compile("LIFTING EQUIPMENT/(?<name>.*)/EQUIPMENT: "));
        let* xs             = filterMapM(getAideOptionRow(namePattern), aideRows);
        let* _              = liftAction(_ -> Console.printLine("Writing ${System/FilePath.toString(x.xlsxOutPath)} ${Int32.toString(List.length(xs))} rows..."));
        let* _              = liftActionResult(_ -> runXlsx(outputXlsx(xs), x.xlsxOutPath));
        return()


    def getAideOptionRow(patt: Text/Regex.Pattern, row: AibExportRow): DbMonad[Option[ResultRow]] = 
        use BasicDb/DbMonad.{flatMap, return, map};
        if (String.startsWith(row.reference, "PLI")) {
            let* ans =  deriveRow1(patt, row.reference, row.assetName);
            return(Some(ans))
        } else
            return(None)
        

    def deriveRow1(patt: Text/Regex.Pattern, pliNumber: String, commonName: String): DbMonad[ResultRow] = 
        use BasicDb/DbMonad.{flatMap, return, liftAction};
        let* name = liftAction(_ -> getName(patt, commonName));
        if (String.isEmpty(name))
            return({ pliReference   = pliNumber
                   , aibItemName    = commonName
                   , ywRefs         = ""
                   , s4EquiIds      = ""
                   , s4EquiNames    = ""
                   })
        else {
            let ywref = getPrefix(name);
            let* s4row = getS4Matches(ywref);
            return({ pliReference   = pliNumber
                   , aibItemName    = name
                   , ywRefs         = s4row.ywRef
                   , s4EquiIds      = s4row.equiId
                   , s4EquiNames    = s4row.equiName
                   })
        }


    def getName(patt: Text/Regex.Pattern, s: String): String & Impure = 
        Result.getWithDefault(Text/Regex.evalContains(s, patt, Text/Regex/MatchEvaluator.getCaptureNamed("name")), "")


    



    def getPrefix(s: String): String = match String.words(s) {
        case Nil => ""
        case s1 :: _ => s1
    }


    def getS4Matches(ywRef: String): DbMonad[S4Row] =
        use BasicDb/DbMonad.{flatMap, return, prepareStatement, psExecuteQuery, allRows, rsClose};
        let* pstmt  = prepareStatement("SELECT equi_id, yw_ref, equi_name FROM s4equi WHERE yw_ref = ?");
        let* rs     = psExecuteQuery(pstmt, setQueryStmt!(ywRef));
        let* ans    = allRows(rs, evalResult());
        let* _      = rsClose(rs);
        return(mergeRows(ans))

    def mergeRows(xs: List[S4Row]): S4Row = 
        let merge = (x1,x2) -> 
            { equiId    = x1.equiId + "; " + x2.equiId
            , ywRef     = x1.ywRef + "; " + x2.ywRef
            , equiName  = x1.equiName + "; " + x2.equiName
            };
        match xs {
            case Nil => { equiId = "", ywRef = "", equiName = "" }
            case x1 :: rs => List.foldLeft(merge, x1, rs)
        }

    def setQueryStmt!(ywRef: String): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!};
        let* _ = putStringAt!(0,  ywRef);
        return()

    def evalResult(): RowEvaluator[S4Row] = 
        use BasicDb/RowEvaluator.{flatMap, return, getStringNamed};
        use BasicDb/RowEvaluator.{<&>, <*>};
        ((x1, x2, x3) -> 
                { equiId        = x1
                , ywRef         = x2
                , equiName      = x3
                })
            <&> getStringNamed("equi_id")
            <*> getStringNamed("yw_ref")
            <*> getStringNamed("equi_name")


    def setupIH06Db(srcFile: System.FilePath): DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return, liftActionResult};
        use AssetLib/S4/FileIO/IH06Tree/Raw/Parser.{parseFileWithBOM => parseIH06File};
        let* ih06   = liftActionResult(_ -> parseIH06File(srcFile, Text/Charset.utf_8()));
        let xs      = List.filterMap(extractS4Row, ih06.rows);
        let* _      = buildS4EquiTable(xs);
        return()
        
    def extractS4Row(x: IH06Row): Option[S4Row] = match x {
        case FlocRow(_) => None
        case EquiRow(r1) => 
            Some({ equiId = r1.equiId, ywRef = getPrefix(r1.description), equiName = r1.description})
    }



    def buildS4EquiTable(srcRows: List[S4Row]): DbMonad[Unit] =
        use BasicDb/DbMonad.{flatMap, return, execute, prepareStatement, setAutoCommit, mapX, psExecuteUpdate, commit};
        let* _      = execute("DROP TABLE IF EXISTS s4equi;");
        let* _      = execute("CREATE TABLE IF NOT EXISTS s4equi (equi_id TEXT PRIMARY KEY NOT NULL, yw_ref TEXT, equi_name TEXT);");
        let* pstmt  = prepareStatement("INSERT INTO s4equi(equi_id, yw_ref, equi_name) VALUES(?, ?, ?)");
        let* _      = setAutoCommit(false);
        let* _      = mapX(r1 -> psExecuteUpdate(pstmt, setInsertStmt!(r1)), srcRows);
        let* _      = commit();
        return()

    def setInsertStmt!(x: S4Row): PreparedStatementSetter[Unit] = 
        use BasicDb/PreparedStatementSetter.{flatMap, return, putStringAt!, putInt32At!};
        let* _ = putStringAt!(0,  x.equiId);
        let* _ = putStringAt!(1,  x.ywRef);
        let* _ = putStringAt!(2,  x.equiName);
        return()

    // Report output to Xlsx file...

    def outputXlsx(rows: List[ResultRow]): SheetWriter[Unit] = 
        use SheetIO/SheetWriter.{flatMap, return, liftAction, createSheet, allRowsWithHeaders};
        let* sheet1     = createSheet("Output");
        let* headers    = liftAction(_ -> getXlsxHeaders());
        let* _          = allRowsWithHeaders(sheet1, headers, rows, setXlsxRow!);
        return()


    def getXlsxHeaders(): Array[String] & Impure = 
        ["PLI Reference", "AIB Item Name", "YW Refs", "S4 Equi Ids", "S4 Equi Names"]


    def setXlsxRow!(x: ResultRow): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, return, putStringAt!};
        let* _      = putStringAt!(0, x.pliReference);
        let* _      = putStringAt!(1, x.aibItemName);
        let* _      = putStringAt!(2, x.ywRefs);
        let* _      = putStringAt!(3, x.s4EquiIds);
        let* _      = putStringAt!(4, x.s4EquiNames);
        return()

}
