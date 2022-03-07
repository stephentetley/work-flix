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

namespace PDTKit/RunAggregate {

    use GetOpt.{OptionDescr};
    use GetOpt.ArgDescr.{ReqArg};
    use GetOpt.ArgOrder.{RequireOrder};


    use RelLib/Lattice/Attributes.{Attributes};
    use PDTKit/Aggregate/Schema.{AggregateRow, Tab};

    type alias AggregateOptions = 
        { src :: System.FilePath
        , out :: System.FilePath
        }

    def defaultOptions(): AggregateOptions = 
        { src = System/FilePath.new("<BAD: no input>")
        , out = System/FilePath.new("<BAD: no output>")
        }

    def options(): List[OptionDescr[AggregateOptions -> AggregateOptions]] =
       {optionNames = "src" :: Nil,     optionIds = Nil,    argDescriptor = ReqArg(s -> Some(opts -> { src = System/FilePath.new(s) | opts}), "<file>"),   explanation = "source file"}
    :: {optionNames = "out" :: Nil,     optionIds = Nil,    argDescriptor = ReqArg(s -> Some(opts -> { out = System/FilePath.new(s) | opts}), "<file>"),   explanation = "output file"}
    :: Nil


 
    pub def runAggregate(args: Array[String]): Result[Int32, String] & Impure = 
        use Result.flatMap;
        let args1 = GetOpt.preprocess({quoteOpen = "'", quoteClose = "'", stripQuoteMarks = false}, args);
        let options = options();
        let header = "Usage: aggregate --src=<file> --out=<file>";
        match GetOpt.getOpt(RequireOrder, options, args1) {
            case Success(opts)   => {let opts1 = List.foldLeft((r, f) -> f(r), defaultOptions(), opts.options); run1(opts1)}
            case Failure(errs)   => {println("Errors: ${errs}");  println(GetOpt.usageInfo(header, options)); Ok(1)}
        }

    /// let src     = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-dsear-pdt.sqlite");
    /// let dst     = System/FilePath.new("G:/work/assets/capital_schemes/sca05/sca05-dsear-pdt-summary.xlsx");
        
    def run1(aopts: AggregateOptions): Result[Int32, String] & Impure =
        use Result.flatMap;
        let* r1     = PDTKit/Aggregate/Loader.readAll(aopts.src);
        let relns   = r1 <+> PDTKit/Aggregate/Rules.makeAggregates();
        let* _      = PDTKit/Aggregate/ExcelOutput.outputExcel(relns, aopts.out);
        Ok(0)

}
