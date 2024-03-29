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
 

use GetOpt.{OptionDescr};
use GetOpt.ArgDescr.{ReqArg, NoArg};
use GetOpt.ArgOrder.{RequireOrder};


def main(): Unit & Impure = 
    println("Running S4Loader... ${Time/LocalTime.now()}");
    println("Args:");
    match S4Loader.main1() { 
        case Ok() => ()
        case Err(msg) => println(msg)
    }


namespace S4Loader {

    pub def main1(): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let args = Environment.getArgs();
        let* opts = getCmdLineOpts(args);
        match opts.cmd { 
            case "help"         => showHelp()
            case "initpdt"      => pdtInit()
            case "pdtuxl"       => pdtUxl(opts.worklist)
            case "flocuxl"      => flocUxl(opts.worklist)
            case "pdtsummary"   => S4Loader/App/PdtFilesSummary.pdtFilesSummary()
            case "pdtlint"      => S4Loader/App/PdtLint.pdtLint()
            case _              => showHelp()
        };
        Ok()

    type alias S4LoaderOptions = 
        { cmd :: String
        , worklist :: Option[String]
        }

    def defaultOptions(): S4LoaderOptions = 
        { cmd = "help"
        , worklist = None
        }

    def options(): List[OptionDescr[S4LoaderOptions -> S4LoaderOptions]] =
        let validate = s -> if (String.isEmpty(s)) None else Some(s);
           {optionNames = "help" :: Nil,        optionIds = Nil,    argDescriptor = NoArg(opts -> {cmd = "help" | opts}),       explanation = "show help"}
        :: {optionNames = "initpdt" :: Nil,     optionIds = Nil,    argDescriptor = NoArg(opts -> {cmd = "initpdt" | opts}),    explanation = "init for PDTs"}
        :: {optionNames = "pdtuxl" :: Nil,      optionIds = Nil,    argDescriptor = NoArg(opts -> {cmd = "pdtuxl" | opts}),     explanation = "gen uxl from PDTs  (needs --worklist)"}
        :: {optionNames = "flocuxl" :: Nil,     optionIds = Nil,    argDescriptor = NoArg(opts -> {cmd = "flocuxl" | opts}),     explanation = "gen uxl for Flocs only (needs --worklist)"}        
        :: {optionNames = "pdtsummary" :: Nil,  optionIds = Nil,    argDescriptor = NoArg(opts -> {cmd = "pdtsummary" | opts}),     explanation = "summarize PDTs"}
        :: {optionNames = "pdtlint" :: Nil,     optionIds = Nil,    argDescriptor = NoArg(opts -> {cmd = "pdtlint" | opts}),     explanation = "run Lint on PDTs"}
        :: {optionNames = "worklist" :: Nil,    optionIds = Nil,    argDescriptor = ReqArg(s -> Some(opts -> { worklist = validate(s) | opts}), "<file>"),   explanation = "worklist"}
        :: Nil

    def optionsHeader(): String = "Usage:"

    def getCmdLineOpts(args: List[String]): Result[S4LoaderOptions, String] =
        let args1 = GetOpt.preprocess({quoteOpen = "'", quoteClose = "'", stripQuoteMarks = false}, args);
        let options = options();
        let header = optionsHeader();
        match GetOpt.getOpt(RequireOrder, options, args1) {
            case Success(opts)   => List.foldLeft((r, f) -> f(r), defaultOptions(), opts.options) |> Ok
            case Failure(errs)   => String.unlines("Errors: ${errs}" :: GetOpt.usageInfo(header, options) :: Nil) |> Err
        }

    def showHelp(): Result[Unit, String] & Impure = 
        GetOpt.usageInfo(optionsHeader(), options()) |> println;
        Ok()

    def pdtInit(): Result[Unit, String] & Impure = 
        use Result.flatMap;
        let* _      = S4Loader/App/Config.makeS4LoaderDir();
        let* _      = S4Loader/App/PdtInit.makePdtDb();
        let* _      = S4Loader/App/PdtInit.makeLoaderDb();
        Ok()
        
    def pdtUxl(worklist: Option[String]): Result[Unit, String] & Impure = 
        use Result.flatMap;
        match worklist {
            case None       => Err("Must supply 'worklist' as a cmd line argument")
            case Some(name) => S4Loader/App/GenPdtUxl.runGenPdtUxl(name)
        }

    def flocUxl(worklist: Option[String]): Result[Unit, String] & Impure = 
        use Result.flatMap;
        match worklist {
            case None       => Err("Must supply 'worklist' as a cmd line argument")
            case Some(name) => S4Loader/App/GenFlocUxl.runGenFlocUxl(name)
        }



}