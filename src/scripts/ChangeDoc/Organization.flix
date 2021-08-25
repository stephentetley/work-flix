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


namespace ChangeDoc/Organization {
    
    /// pub def groupBy(f: (a, a) -> Bool, a: Array[a]): Array[Array[a]] & Impure =

    /// Fix to Array or generalize to Foldable?

    pub def collectToMapList(f: a -> k & ef, g: a -> b & ef, arr: Array[a]): Map[k, List[b]] & Impure with Order[k] = 
        collectToMapWith(f, Nil, (x1, xs) -> {let v1 = g(x1); v1 :: xs}, arr)

    pub def collectToMapSet(f: a -> k & ef, g: a -> b & ef, arr: Array[a]): Map[k, Set[b]] & Impure with Order[k], Order[b] = 
        collectToMapWith(f, Set.empty(), (x1, s) -> {let v1 = g(x1); Set.insert(v1, s)}, arr)

    pub def collectToMapMap(f: a -> k & ef, g: a -> (k1, v1) & ef, arr: Array[a]): Map[k, Map[k1, v1]] & Impure with Order[k], Order[k1] = 
        collectToMapWith(f, Map.empty(), (x1, m) -> {let (k1, v1) = g(x1); Map.insert(k1, v1, m)}, arr)

    pub def collectToMapWith(f: a -> k & ef, zero: v, combine: (a, v) -> v & ef, arr: Array[a]): Map[k, v] & Impure with Order[k] = 
        let step = (x1, ac) -> {
            let k = f(x1) as & Impure;
            Map.insertWith((_, ac1) -> combine(x1, ac1) as & Impure, k, combine(x1, zero) as & Impure, ac)
        };        
        Array.foldRight(step, Map.empty(), arr)

    /// This is "just a `map` traversal" but it seems to merit a new combinator because we
    /// want to highlight that we are combining with the (finite) Map...
    pub def mapWithLookup(f: a -> k, g: (a, Option[v]) -> b & ef, 
                        m: Map[k, v], arr: Array[a]): Array[b] & Impure with Order[k] = 
        let step = x1 -> {
            let k = f(x1);
            let v = Map.get(k, m);
            g(x1, v) as & Impure
        };
        Array.map(step, arr)


    pub def mapWithLookupAndIndex(f: a -> k, g: (a, Option[v], Int) -> b & ef, 
                        m: Map[k, v], arr: Array[a]): Array[b] & Impure with Order[k] = 
        let step = (x1, ix) -> {
            let k = f(x1);
            let v = Map.get(k, m);
            g(x1, v, ix) as & Impure
        };
        Array.mapWithIndex(step, arr)

    /// Simpler version of mapWithLookup
    pub def updateWithLookup(f: a -> k, g: (a, v) -> a & ef, 
                        m: Map[k, v], arr: Array[a]): Array[a] & Impure with Order[k] = 
        let step = x1 -> {
            let k = f(x1);
            match Map.get(k, m) {
                case None => x1
                case Some(v1) => g(x1, v1) as & Impure
            }
        };
        Array.map(step, arr)



    pub def foldLeftWithLookup(f: a -> k, g: (b, a, Option[v]) -> b & ef, 
                                initial: b, m: Map[k, v], arr: Array[a]): b & Impure with Order[k] = 
        let step = (st, x1) -> {
            let k = f(x1);
            let v = Map.get(k, m);
            g(st, x1, v) as & Impure
        };
        Array.foldLeft(step, initial, arr)        

}