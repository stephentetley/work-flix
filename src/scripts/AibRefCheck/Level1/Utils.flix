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


namespace AibRefCheck/Level1/Utils {


    pub def sublists(n: Int32, xs: List[a]): List[List[a]] = 
        if (n < 1)
            Nil
        else 
            sublistsHelper(n, 0, xs, ks -> ks, ls -> ls)

    pub def sublistsHelper(n: Int32, i: Int32, xs: List[a], k1: List[a] -> List[a], k2: List[List[a]] -> List[List[a]]): List[List[a]] =
        match xs { 
            case Nil => match k1(Nil) { 
                case Nil => k2(Nil)
                case ks => k2(ks :: Nil)
            }
            case x1 :: rs => {
                if (i >= n) 
                    sublistsHelper(n, 1, rs, ks -> x1 :: ks, ls -> k2(k1(Nil) :: ls))
                else 
                    sublistsHelper(n, i + 1, rs, ks -> k1(x1 :: ks), k2)
            }
        }


}
