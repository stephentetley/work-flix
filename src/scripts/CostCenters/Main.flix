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


namespace CostCenters/Main {

    use CostCenters/EmitFunclocTransferFile.CCUpdateRow;

    pub def main1(src: System.FilePath, destDir: System.FilePath, groupSize: Int32, fileNameBase: String): Result[Unit, String] & Impure = 
        use Result.{flatMap};
        let* xs     = CostCenters/ReadDataSheet.readCostCentersFile(src);
        let _       = Console.printLine("List length xs: ${List.length(xs)}");
        let gss     = groupsOf(groupSize, xs);
        let output1 = (gs1, n) -> outputBatch("tetleys", destDir, fileNameBase, n + 1, gs1);
        let _       = foreachWithIndex(output1, gss);
        Ok()


    def outputBatch(user: String, outputDir: System.FilePath, fileNameBase: String, n: Int32, xs: List[CCUpdateRow]): Unit & Impure = 
        let suffix  = String.padLeft(3, '0', ToString.toString(n)); 
        let name    = "${fileNameBase}_${suffix}.txt";
        let path    = System/FilePath.append(outputDir, System/FilePath.new(name));
        match CostCenters/EmitFunclocTransferFile.outputFunclocFile(user, xs, path) { 
            case Err(msg) => Console.printLine("Error: ${msg}")
            case Ok => ()
        }

    pub def splitAt(n: Int32, xs: List[a]): (List[a], List[a]) = 
        let k = (ys, zs) -> (ys, zs);
        splitAtHelper(n, xs, k)

    def splitAtHelper(n: Int32, xs: List[a], k: List[a] -> List[a] -> (List[a], List[a])): (List[a], List[a]) = 
        if (n < 0)
            k(Nil, xs)
        else match xs { 
            case x :: rs => if (n == 1) k(x :: Nil, rs) else splitAtHelper(n - 1, rs, (ys, zs) -> k(x :: ys, zs))
            case Nil => k(Nil, Nil)
        }
        

    pub def groupsOf(n: Int32, xs: List[a]): List[List[a]] = groupsOfHelper(n, xs, ks -> ks)

    def groupsOfHelper(n: Int32, xs: List[a], k: List[List[a]] -> List[List[a]]): List[List[a]] = 
        match splitAt(n, xs) {
            case (Nil,Nil) => k(Nil)
            case (ys, Nil) => k(ys :: Nil)
            case (ys, zs) => groupsOfHelper(n, zs, kss -> k(ys :: kss))
        }

    pub def foreachWithIndex(f: (a, Int32) ~> Unit, xs: List[a]): Unit & Impure = 
        foreachWithIndexHelper(f, 0, xs)

    def foreachWithIndexHelper(f: (a, Int32) ~> Unit, n: Int32, xs: List[a]): Unit & Impure = match xs {
        case Nil => ()
        case x :: rs => f(x, n); foreachWithIndexHelper(f, n + 1, rs)
    }

}
