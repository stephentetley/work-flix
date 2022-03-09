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
    println("Running S4Loader... ${Time/LocalTime.now()}");
    println("Args:");
    Array.foreach(println, args);
    match Environment.getCurrentWorkingDirectory() { 
        case Some(cwd) => "Current Working Directory: ${cwd}"
        case None      => "**Fail - no S4LOADER_HOME**"
    } |> println;
    match Environment.getVar("S4LOADER_HOME") { 
        case Some(cwd) => "S4LOADER_HOME: ${cwd}"
        case None      => "**Fail - no S4LOADER_HOME**"
    } |> println;    
    S4Loader/RunPdtInit.makeS4LoaderDir() |> println;
    S4Loader/RunGenPdtUxl.getAppPath() |> println;
    S4Loader/RunGenPdtUxl.getConfigPath() |> println;
    S4Loader/RunGenPdtUxl.runGenPdtUxl(args)


