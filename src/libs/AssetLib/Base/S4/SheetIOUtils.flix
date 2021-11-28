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


namespace AssetLib/Base/S4/SheetIOUtils {


    use SheetIO.RowSetter;
    use SheetIO.NamedRowEvaluator;


    pub def putS4DateAt!(ix: Int32, dt: Time.LocalDate): RowSetter[Unit] = 
        use SheetIO/RowSetter.{flatMap, point, putStringAt!, liftOption};
        let* fmt    = liftOption(Time/Format/DateFormatter.ofPattern("dd.MM.yyyy"), "putS4DateAt! date format error");
        let ans     = Time/LocalDate.format(fmt, dt);
        let* _      = putStringAt!(ix, ans);
        point()


    pub def putS4BoolAt!(ix: Int32, x: Bool): RowSetter[Unit] = 
        use SheetIO/RowSetter.{putStringAt!, putBlankAt!};
        if (x) putStringAt!(ix, "X") else putBlankAt!(ix)



    pub def putPaddedInt32At!(ix: Int32, w: Int32, ch: Char, x: Int32): RowSetter[Unit] = 
        use SheetIO/RowSetter.{putStringAt!};
        let s = String.padLeft(w, ch, Int32.toString(x));
        putStringAt!(ix, s)
        
    pub def getS4LocalDateNamed(label: String): NamedRowEvaluator[Time.LocalDate] =
        use SheetIO/NamedRowEvaluator.{flatMap, point, liftOption, getStringNamed};
        let* fmt    = liftOption(Time/Format/DateFormatter.ofPattern("dd.MM.yyyy"), "getS4LocalDateNamed date format error");
        let* s1     = getStringNamed(label); 
        liftOption(Time/LocalDate.parse(fmt, s1), "getS4LocalDateNamed('${label}') - seen '${s1}'")

    /// Must allows blank (false)
    pub def getS4BoolNamed(label: String): NamedRowEvaluator[Bool] = 
        use SheetIO/NamedRowEvaluator.{flatMap, point, getStringNamedWithDefault};
        let* x = getStringNamedWithDefault(label, "");
        if (x == "X") point(true) else point(false)

}
