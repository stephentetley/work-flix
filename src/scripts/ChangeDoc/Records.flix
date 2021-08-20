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


namespace ChangeDoc/Records {
    
    /// use ChangeDoc/Datatypes.{EntityType, ChangeKey, ValueState, Origin};
    /// use ChangeDoc/Datatypes.ChangeKey.{NameKey, ClassKey, 
    ///     AttrKey, ValuaKey, AddrAttrKey};
    use ChangeDoc/Datatypes.EntityType.{Equi, Floc};
    /// use ChangeDoc/Datatypes.Origin.{Direct, HSuperior, RRef};
    /// use ChangeDoc/Datatypes.ValueState.{CreateLocal, DeleteLocal, 
    ///     UpdateGlobal, DeleteGlobal};

    use ChangeDoc/Interpreter.{State};
    use ChangeDoc.BuildMonad;

    /// Note can pair origin with value to reduce number of fields...
    type alias Funcloc = 
        { internalId: String
        , functionalLocation: String
        , maintenancePlant: String
        , objectType: String
        }

    pub def buildFuncloc(flocId: String, funcloc: String): BuildMonad[Funcloc] = 
        use ChangeDoc/BuildMonad.{getAttrString};
        use ChangeDoc/BuildMonad.{<&>, <*>};
        ((x1, x2)  -> 
            { internalId = flocId
            , functionalLocation = funcloc
            , maintenancePlant = x1
            , objectType = x2
            })
            <&> getAttrString(Floc, flocId, "Maintenance Plant")
            <*> getAttrString(Floc, flocId, "Object Type")




}
