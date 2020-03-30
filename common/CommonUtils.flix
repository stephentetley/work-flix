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


namespace Work/CommonUtils {



    /// 
    /// Get a year from a date string that includes "YYYY".
    ///
    /// The year "YYYY" must be the only four digit sequence in the input.
    ///
    pub def getYear(s: String): Result[Int32, String] = 
        getYearHelper(s) as & Pure

    /// 
    /// Helper function for `getYear`.
    ///
    def getYearHelper(s: String): Result[Int32, String] & Impure = 
        let patt = Regex.compile("(?<year>\d{4})");
        let m = Regex.matcher(patt, s);
        if (Regex.find(m)) {
            Regex.namedGroup(m, "year") |> Int32.fromString
        } else Err("read year")

    
    pub def siteFromCommonName(s: String): String & Impure = 
        let arr = String.split(s, "/");
        if (String.matches(s, ".*/SEWER MAINTENANCE/.*") && Array.length(arr) == 5) {
            let s1 = arr[2];
            let s2 = arr[3];
            s1 + "/" + s2
        } else if (Array.length(arr) > 2) {
            let s1 = arr[0];
            let s2 = arr[1];
            s1 + "/" + s2
        } else s

    pub def descriptionFromCommonName(s: String): String & Impure = 
        let arr = String.split(s, "/");
        if (String.matches(s, ".*/SEWER MAINTENANCE/.*") && Array.length(arr) == 5) {
            "LEVEL MONITORING POINT"
        } else if (Array.length(arr) > 2) {
            let ix = Array.length(arr) - 2;
            arr[ix]
        } else s

}