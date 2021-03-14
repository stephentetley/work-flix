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

namespace UploadCheck/Base/RowCheck {

    use DataCheck.Check;
    use DataCheck.Check.{Pass, Fail};

    use BasicDb.DbMonad;

    type alias UxlRowFail = { sheetName: String, rowIndex: Int32, failMessage: String }

    type alias UxlRowCheck = Check[UxlRowFail]

    pub opaque type RowChecker[row] = row -> Int32 -> DbMonad[UxlRowCheck]



    pub def liftPureChecker(chk: (row, Int32) -> UxlRowCheck): RowChecker[row] =
        use BasicDb/DbMonad.{return};
        RowChecker((row, ix) -> {let ans = chk(row, ix); return(ans)})

    pub def execRowChecker(chk: RowChecker[row], row: row, ix: Int32): DbMonad[UxlRowCheck] = 
        let RowChecker(f) = chk;
        f(row, ix)

    pub def offsetIndex(offset: Int32, chk: RowChecker[row]): RowChecker[row] = 
        RowChecker((row, ix) -> 
            execRowChecker(chk, row, ix + offset)
        )

    ///
    /// Infix combinator for `check2`.
    ///
    pub def <&&>(chk1: RowChecker[row], chk2: RowChecker[row]): RowChecker[row] = check2(chk1, chk2)


    pub def check2(chk1: RowChecker[row], chk2: RowChecker[row]): RowChecker[row] = 
        use DataCheck/Check.{append};
        RowChecker((row, ix) -> 
            BasicDb/DbMonad.lift2(append, execRowChecker(chk1, row, ix), execRowChecker(chk2, row, ix))
        )

    pub def check3(chk1: RowChecker[row], chk2: RowChecker[row], chk3: RowChecker[row]): RowChecker[row] = 
        chk1 <&&> check2(chk2, chk3)

    pub def check4(chk1: RowChecker[row], chk2: RowChecker[row], chk3: RowChecker[row], chk4: RowChecker[row]): RowChecker[row] = 
        chk1 <&&> check3(chk2, chk3, chk4)

}


