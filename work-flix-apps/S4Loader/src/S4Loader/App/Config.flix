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
 
/// Makes `PDT db` and `S4 Loader db`...

namespace S4Loader/App/Config {


    /// TODO - should System/FilePath.new unquote strings?
    /// On Windows, paths retreived from env-vars might be quoted...
    pub def getAppPath(): Result[System.FilePath, String] & Impure = 
        use Result.flatMap;
        let* var    = Environment.getVar("S4LOADER_HOME") |> flip(Option.toOk, "Env var `S4LOADER_HOME` not set");
        let path    = System/FilePath.new(var);
        let* exists = File.exists(path |> ToString.toString);
        if (exists) 
            Ok(path)
        else 
            Err("S4LOADER_PATH `${var}` is invalid")

    pub def getAppConfigPath(): Result[System.FilePath, String] & Impure = 
        getAppPath() |> Result.map(flip(System/FilePath.snoc, "config"))

    pub def getWorkingDirectory(): Result[System.FilePath, String] = 
        Environment.getCurrentWorkingDirectory() |> Option.map(System/FilePath.new) |> flip(Option.toOk, "Could not get Current-Working-Directory")

    pub def getS4LoaderDirectory(): Result[System.FilePath, String] = 
        getWorkingDirectory() |> Result.map(flip(System/FilePath.snoc, ".s4loader"))



    pub def makeS4LoaderDir(): Result[Bool, String] & Impure = 
        use Result.flatMap;
        let* path1  = Environment.getCurrentWorkingDirectory() |> Option.map(System/FilePath.new) |> flip(Option.toOk, "No CWD");
        let dest    = System/FilePath.snoc(path1, ".s4loader");
        let* exists = File.exists(ToString.toString(dest));
        if (not exists) 
            File.mkdir(ToString.toString(dest))
        else 
            Ok(false)

}
