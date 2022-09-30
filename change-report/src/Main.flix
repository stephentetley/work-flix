/*
 * Copyright 2022 Stephen Tetley
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


def main(): Int32 \ IO = 
    let args = Environment.getArgs();
    match Main1.main1(args) { 
        case Ok()     => {println("done"); 0}
        case Err(msg) => {println("Error: ${msg}"); 1}
    }

namespace Main1 {

    use Basis/System.Path;

    use GetOpt.{OptionDescr};
    use GetOpt.ArgDescr.{ReqArg, NoArg};
    use GetOpt.ArgOrder.{RequireOrder};

    pub def main1(args: List[String]): Result[Unit, String] \ IO = 
        use Result.flatMap;
        let* opts = getCmdLineOpts(args);
        discard match opts.cmd { 
            case "help"         => showHelp()
            case "initdb"       => opts.sourceFile |> Option.toOk("no sourceFile") |> Result.flatMap(initDb)
            case _              => showHelp()
        };
        Ok()

    type alias ChangeReportOpts = 
        { cmd = String
        , sourceFile = Option[Path]
        }

    def defaultOptions(): ChangeReportOpts = 
        { cmd = "help"
        , sourceFile = None
        }

    def options(): List[OptionDescr[ChangeReportOpts -> ChangeReportOpts]] =
        let validate = s -> if (String.isEmpty(s)) None else Basis/System/Path.newPath(s) |> Result.toOption;
           {optionNames = "help" :: Nil,        optionIds = Nil,    argDescriptor = NoArg(opts -> {cmd = "help" | opts}),       explanation = "show help"}
        :: {optionNames = "initdb" :: Nil,     optionIds = Nil,    argDescriptor = NoArg(opts -> {cmd = "initdb" | opts}),    explanation = "init db"}
        :: {optionNames = "source" :: Nil,    optionIds = Nil,    argDescriptor = ReqArg(s -> Some(opts -> { sourceFile = validate(s) | opts}), "<file>"),   explanation = "source"}
        :: Nil

    def optionsHeader(): String = "Usage:"

    def getCmdLineOpts(args: List[String]): Result[ChangeReportOpts, String] =
        let args1 = GetOpt.preprocess({quoteOpen = "'", quoteClose = "'", stripQuoteMarks = false}, args);
        let options = options();
        let header = optionsHeader();
        match GetOpt.getOpt(RequireOrder, options, args1) {
            case Success(opts)   => List.foldLeft((r, f) -> f(r), defaultOptions(), opts.options) |> Ok
            case Failure(errs)   => String.unlines("Errors: ${errs}" :: GetOpt.usageInfo(header, options) :: Nil) |> Err
        }


    def showHelp(): Result[Unit, String] \ IO = 
        GetOpt.usageInfo("Usage:", options()) |> println;
        Ok()


    pub def initDb(inpath: Path): Result[Unit, String] \ IO = 
        use Result.flatMap;
        use AssetS/ChangeReport/Relations.{Change, SimpleRow, SourceRow};
        let outpath     = Basis/System/Path.putExtension(inpath, "sqlite");
        let* _          = AssetS/ChangeReport/InitDb.createCRDatabase(outpath);
        let* rows       = AssetS/ChangeReport/Reader.readChangeReport(inpath);
        List.foreach(println, List.take(5, rows));
        let db          = AssetS/ChangeReport/MakeRelations.makeRowRelations(rows);
        let sources     = query db select (x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13) from SourceRow(x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13);
        let* _          = AssetS/ChangeReport/StoreChanges.storeSourceRows(sources, outpath);
        let solns       = (solve db project SimpleRow) <+> AssetS/ChangeReport/DecodeChanges.decodeChanges();
        let changes     = query solns select (x1, x2, x3, x4, x5) from Change(x1, x2, x3, x4, x5);
        let* _          = AssetS/ChangeReport/StoreChanges.storeChanges(changes, outpath);
        Ok()


}
