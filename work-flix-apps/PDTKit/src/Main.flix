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
 
/// TODO make this a proper `main` with GetOpt or JSON params etc.


def main(args: Array[String]): Int32 & Impure = 
    println("Running PDT Kit... ${Time/LocalTime.now()}");
    if (Array.length(args) >= 1) 
        match args[0] { 
            case "lint"      => PDTKit/RunLint.runLint(Array.dropLeft(1, args))
            case "aggregate" => PDTKit/RunAggregate.runAggregate(Array.dropLeft(1, args))
            case _           => {showHelp(); Ok(0)}
        } |> Result.getWithDefault(1)
    else
        showHelp();
    0



def showHelp(): Int32 & Impure = 
    println("opts: lint ...");
    println("opts: aggregate ...");
    0
