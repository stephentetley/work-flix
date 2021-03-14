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

use GetOpt.{ArgDescr, OptionDescr};
use GetOpt.ArgDescr.{NoArg, ReqArg, OptArg};

/// --args "--dbpath=%dbpath% --sitemap=%sitemap% --typemap=%typemap% --workingloadmap=%workingloadmap%"

type alias InputPaths = 
    { dbpath: System.FilePath
    , sitemap: System.FilePath
    , typemap: System.FilePath
    , workingloadmap: System.FilePath    
    }

def defaultInputPaths(): InputPaths = 
    { dbpath = System/FilePath.new("")
    , sitemap = System/FilePath.new("")
    , typemap = System/FilePath.new("")
    , workingloadmap = System/FilePath.new("")
    }    

type alias UpdateOptions = InputPaths -> InputPaths    


def makeCmdLineOptions(): List[OptionDescr[UpdateOptions]] = 
       {optionIds = Nil,    optionNames = "dbpath" :: Nil,          argDescriptor = ReqArg(setDbpath, "FILE"),          explanation = "path to SQLite database"}
    :: {optionIds = Nil,    optionNames = "sitemap" :: Nil,         argDescriptor = ReqArg(setSitemap, "FILE"),         explanation = "path to AI2 to S4 site mapping"}
    :: {optionIds = Nil,    optionNames = "typemap" :: Nil,         argDescriptor = ReqArg(setTypemap, "FILE"),         explanation = "path to lifting type mapping"}
    :: {optionIds = Nil,    optionNames = "workingloadmap" :: Nil,  argDescriptor = ReqArg(setWorkingloadmap, "FILE"),  explanation = "path to working load mapping"}
    :: Nil

def setDbpath(s: String): Option[UpdateOptions] = Some(opts -> {dbpath = System/FilePath.new(s) | opts})
def setSitemap(s: String): Option[UpdateOptions] = Some(opts -> {sitemap = System/FilePath.new(s) | opts})
def setTypemap(s: String): Option[UpdateOptions] = Some(opts -> {typemap = System/FilePath.new(s) | opts})
def setWorkingloadmap(s: String): Option[UpdateOptions] = Some(opts -> {workingloadmap = System/FilePath.new(s) | opts})


def main(args: Array[String]): Int32 & Impure =  
    use GetOpt.ArgOrder.{Permute};
    use GetOpt.{getOpt, usageInfo};
    use BasicDb/DbMonad.{runSQLite};
    use NewLiftingItems/SetupDb.{MappingTablePaths, setupStaticTables};
    Console.printLine("Running...");
    let options1 = makeCmdLineOptions();
    let header = "Usage: <make-report> [OPTION...]";
    let args2 = GetOpt.preprocess({quoteOpen = "'", quoteClose = "'", stripQuoteMarks = true}, args);
    match getOpt(Permute, options1, args2) {
        case Failure(errs)  => {Console.printLine("Errors: ${errs}");  Console.printLine(usageInfo(header, options1)); 1}
        case Success(updates) => {
            let r1 = List.foldLeft((ac, f) -> f(ac), defaultInputPaths(), updates.options);
            let mappingTablePaths: MappingTablePaths = 
                { siteMappingPath           = r1.sitemap
                , typeMappingPath           = r1.typemap
                , workingLoadMappingPath    = r1.workingloadmap
                };
            match runSQLite(setupStaticTables(mappingTablePaths), r1.dbpath) { 
                case Ok() => {Console.printLine("Good - database created ${r1.dbpath}"); 0}
                case Err(msg) => {Console.printLine("Error: ${msg}"); 1}
            }
        }
    }


namespace NewLiftingItems/SetupDb {

    use BasicDb.DbMonad;
 
    type alias MappingTablePaths = 
        { siteMappingPath: System.FilePath
        , typeMappingPath: System.FilePath
        , workingLoadMappingPath: System.FilePath
        }

    pub def setupStaticTables(mappingTables: MappingTablePaths):  DbMonad[Unit] = 
        use BasicDb/DbMonad.{flatMap, return};
        let* _  = AssetLib/Facts/SiteMapping.storeSiteMapping("lookup_site", mappingTables.siteMappingPath);
        let* _  = NewLiftingItems/SetupDb/Facts/TypeMapping.storeTypeMapping("lookup_lifting_type", mappingTables.typeMappingPath);
        let* _  = NewLiftingItems/SetupDb/Facts/WorkingLoadMapping.storeWorkingLoadMapping("lookup_working_load", mappingTables.workingLoadMappingPath);
        return()


}
