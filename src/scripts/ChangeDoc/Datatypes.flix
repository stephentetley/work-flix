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


namespace ChangeDoc/Datatypes {

    type alias EquiId = String
    type alias FlocId = String
    type alias ClassName = String
    type alias AttributeName = String
    type alias CharId = String
    type alias IntCounter = Int32
    type alias AddressNumber = Int32


    type alias ChangeDoc = List[ChangeRow]

    pub enum ChangeRow {
        case ChangeRow(ChangeKey, Instruction)
    }

    /// TODO we chould halve the number of datatypes if we use `EntityType`...
    pub enum ChangeKey {
        case EquiNameKey(EquiId)             /// String1 is equiId
        case FlocNameKey(FlocId)
        case EquiClassKey(EquiId, ClassName)
        case FlocClassKey(FlocId, ClassName)
        case EquiAttrKey(EquiId, AttributeName)
        case FlocAttrKey(FlocId, AttributeName)
        case EquiCharDescrKey(EquiId, CharId, IntCounter)
        case FlocCharDescrKey(FlocId, CharId, IntCounter)
        case ZEquiaddrAttrKey(EquiId, AttributeName, AddressNumber)
        case ZFuncloadAttrKey(FlocId, AttributeName, AddressNumber)
    }

    instance ToString[ChangeKey] {
        pub def toString(x: ChangeKey): String = match x {
            case EquiNameKey(x1)                => "EquiNameKey(${x1})"
            case FlocNameKey(x1)                => "FlocNameKey(${x1})"
            case EquiClassKey(x1, x2)           => "EquiClassKey(${x1}, ${x2})"
            case FlocClassKey(x1, x2)           => "FlocClassKey(${x1}, ${x2})"
            case EquiAttrKey(x1, x2)            => "EquiAttrKey(${x1}, ${x2})"
            case FlocAttrKey(x1, x2)            => "FlocAttrKey(${x1}, ${x2})"
            case EquiCharDescrKey(x1, x2, x3)   => "EquiCharDescrKey(${x1}, ${x2}, ${x3})"
            case FlocCharDescrKey(x1, x2, x3)   => "FlocCharDescrKey(${x1}, ${x2}, ${x3})"
            case ZEquiaddrAttrKey(x1, x2, x3)   => "ZEquiaddrAttrKey(${x1}, ${x2}, ${x3})"
            case ZFuncloadAttrKey(x1, x2, x3)   => "ZFuncloadAttrKey(${x1}, ${x2}, ${x3})"
        }
    }

    instance Eq[ChangeKey] {
        pub def eq(x: ChangeKey, y: ChangeKey): Bool = match (x, y) {
            case (EquiNameKey(x1), EquiNameKey(y1))             => x1 == y1
            case (FlocNameKey(x1), FlocNameKey(y1))             => x1 == y1
            case (EquiClassKey(x1, x2), EquiClassKey(y1, y2))   => x1 == y1 and x2 == y2
            case (FlocClassKey(x1, x2), FlocClassKey(y1, y2))   => x1 == y1 and x2 == y2
            case (EquiAttrKey(x1, x2), EquiAttrKey(y1, y2))     => x1 == y1 and x2 == y2
            case (FlocAttrKey(x1, x2), FlocAttrKey(y1, y2))     => x1 == y1 and x2 == y2
            case (EquiCharDescrKey(x1, x2, x3), EquiCharDescrKey(y1, y2, y3))   => x1 == y1 and x2 == y2 and x3 == y3
            case (FlocCharDescrKey(x1, x2, x3), FlocCharDescrKey(y1, y2, y3))   => x1 == y1 and x2 == y2 and x3 == y3
            case (ZEquiaddrAttrKey(x1, x2, x3), ZEquiaddrAttrKey(y1, y2, y3))   => x1 == y1 and x2 == y2 and x3 == y3
            case (ZFuncloadAttrKey(x1, x2, x3), ZFuncloadAttrKey(y1, y2, y3))   => x1 == y1 and x2 == y2 and x3 == y3
            case _ => false
        }
    }

    instance Order[ChangeKey] {
        pub def compare(x: ChangeKey, y: ChangeKey): Comparison = 
            use Order.thenCompare;
            match (x, y) {

                case (EquiNameKey(x1), EquiNameKey(y1))             => x1 <=> y1
                case (EquiNameKey(_), FlocNameKey(_))               => LessThan
                case (EquiNameKey(_), EquiClassKey(_, _))           => LessThan
                case (EquiNameKey(_), FlocClassKey(_, _))           => LessThan
                case (EquiNameKey(_), EquiAttrKey(_, _))            => LessThan
                case (EquiNameKey(_), FlocAttrKey(_, _))            => LessThan
                case (EquiNameKey(_), EquiCharDescrKey(_, _, _))    => LessThan
                case (EquiNameKey(_), FlocCharDescrKey(_, _, _))    => LessThan
                case (EquiNameKey(_), ZEquiaddrAttrKey(_, _, _))    => LessThan
                case (EquiNameKey(_), ZFuncloadAttrKey(_, _, _))    => LessThan
                
                case (FlocNameKey(_), EquiNameKey(_))               => GreaterThan
                case (FlocNameKey(x1), FlocNameKey(y1))             => x1 <=> y1
                case (FlocNameKey(_), EquiClassKey(_, _))           => LessThan
                case (FlocNameKey(_), FlocClassKey(_, _))           => LessThan
                case (FlocNameKey(_), EquiAttrKey(_, _))            => LessThan
                case (FlocNameKey(_), FlocAttrKey(_, _))            => LessThan
                case (FlocNameKey(_), EquiCharDescrKey(_, _, _))    => LessThan
                case (FlocNameKey(_), FlocCharDescrKey(_, _, _))    => LessThan
                case (FlocNameKey(_), ZEquiaddrAttrKey(_, _, _))    => LessThan
                case (FlocNameKey(_), ZFuncloadAttrKey(_, _, _))    => LessThan

                case (EquiClassKey(_, _), EquiNameKey(_))               => GreaterThan
                case (EquiClassKey(_, _), FlocNameKey(_))               => GreaterThan
                case (EquiClassKey(x1, x2), EquiClassKey(y1, y2))       => (x1 <=> y1) `thenCompare` lazy (x2 <=> y2)
                case (EquiClassKey(_, _), FlocClassKey(_, _))           => LessThan
                case (EquiClassKey(_, _), EquiAttrKey(_, _))            => LessThan
                case (EquiClassKey(_, _), FlocAttrKey(_, _))            => LessThan
                case (EquiClassKey(_, _), EquiCharDescrKey(_, _, _))    => LessThan
                case (EquiClassKey(_, _), FlocCharDescrKey(_, _, _))    => LessThan
                case (EquiClassKey(_, _), ZEquiaddrAttrKey(_, _, _))    => LessThan
                case (EquiClassKey(_, _), ZFuncloadAttrKey(_, _, _))    => LessThan

                case (FlocClassKey(_, _), EquiNameKey(_))               => GreaterThan
                case (FlocClassKey(_, _), FlocNameKey(_))               => GreaterThan
                case (FlocClassKey(_, _), EquiClassKey(_, _))           => GreaterThan
                case (FlocClassKey(x1, x2), FlocClassKey(y1, y2))       => (x1 <=> y1) `thenCompare` lazy (x2 <=> y2)
                case (FlocClassKey(_, _), EquiAttrKey(_, _))            => LessThan
                case (FlocClassKey(_, _), FlocAttrKey(_, _))            => LessThan
                case (FlocClassKey(_, _), EquiCharDescrKey(_, _, _))    => LessThan
                case (FlocClassKey(_, _), FlocCharDescrKey(_, _, _))    => LessThan
                case (FlocClassKey(_, _), ZEquiaddrAttrKey(_, _, _))    => LessThan
                case (FlocClassKey(_, _), ZFuncloadAttrKey(_, _, _))    => LessThan

                case (EquiAttrKey(_, _), EquiNameKey(_))                => GreaterThan
                case (EquiAttrKey(_, _), FlocNameKey(_))                => GreaterThan
                case (EquiAttrKey(_, _), EquiClassKey(_, _))            => GreaterThan
                case (EquiAttrKey(_, _), FlocClassKey(_, _))            => GreaterThan
                case (EquiAttrKey(x1, x2), EquiAttrKey(y1, y2))     => (x1 <=> y1) `thenCompare` lazy (x2 <=> y2)
                case (EquiAttrKey(_, _), FlocAttrKey(_, _))             => LessThan
                case (EquiAttrKey(_, _), EquiCharDescrKey(_, _, _))     => LessThan
                case (EquiAttrKey(_, _), FlocCharDescrKey(_, _, _))     => LessThan
                case (EquiAttrKey(_, _), ZEquiaddrAttrKey(_, _, _))     => LessThan
                case (EquiAttrKey(_, _), ZFuncloadAttrKey(_, _, _))     => LessThan

                case (FlocAttrKey(_, _), EquiNameKey(_))                => GreaterThan
                case (FlocAttrKey(_, _), FlocNameKey(_))                => GreaterThan
                case (FlocAttrKey(_, _), EquiClassKey(_, _))            => GreaterThan
                case (FlocAttrKey(_, _), FlocClassKey(_, _))            => GreaterThan
                case (FlocAttrKey(_, _), EquiAttrKey(_, _))             => GreaterThan
                case (FlocAttrKey(x1, x2), FlocAttrKey(y1, y2))         => (x1 <=> y1) `thenCompare` lazy (x2 <=> y2)
                case (FlocAttrKey(_, _), EquiCharDescrKey(_, _, _))     => LessThan
                case (FlocAttrKey(_, _), FlocCharDescrKey(_, _, _))     => LessThan
                case (FlocAttrKey(_, _), ZEquiaddrAttrKey(_, _, _))     => LessThan
                case (FlocAttrKey(_, _), ZFuncloadAttrKey(_, _, _))     => LessThan

                case (EquiCharDescrKey(_, _, _), EquiNameKey(_))                => GreaterThan
                case (EquiCharDescrKey(_, _, _), FlocNameKey(_))                => GreaterThan
                case (EquiCharDescrKey(_, _, _), EquiClassKey(_, _))            => GreaterThan
                case (EquiCharDescrKey(_, _, _), FlocClassKey(_, _))            => GreaterThan
                case (EquiCharDescrKey(_, _, _), EquiAttrKey(_, _))             => GreaterThan
                case (EquiCharDescrKey(_, _, _), FlocAttrKey(_, _))             => GreaterThan
                case (EquiCharDescrKey(x1, x2, x3), EquiCharDescrKey(y1, y2, y3))   => 
                    (x1 <=> y1) `thenCompare` lazy (x2 <=> y2) `thenCompare` lazy (x3 <=> y3)

                case (EquiCharDescrKey(_, _, _), FlocCharDescrKey(_, _, _))     => LessThan
                case (EquiCharDescrKey(_, _, _), ZEquiaddrAttrKey(_, _, _))     => LessThan
                case (EquiCharDescrKey(_, _, _), ZFuncloadAttrKey(_, _, _))     => LessThan


                case (FlocCharDescrKey(_, _, _), EquiNameKey(_))                => GreaterThan
                case (FlocCharDescrKey(_, _, _), FlocNameKey(_))                => GreaterThan
                case (FlocCharDescrKey(_, _, _), EquiClassKey(_, _))            => GreaterThan
                case (FlocCharDescrKey(_, _, _), FlocClassKey(_, _))            => GreaterThan
                case (FlocCharDescrKey(_, _, _), EquiAttrKey(_, _))             => GreaterThan
                case (FlocCharDescrKey(_, _, _), FlocAttrKey(_, _))             => GreaterThan
                case (FlocCharDescrKey(_, _, _), EquiCharDescrKey(_, _, _))     => GreaterThan
                case (FlocCharDescrKey(x1, x2, x3), FlocCharDescrKey(y1, y2, y3))   => 
                    (x1 <=> y1) `thenCompare` lazy (x2 <=> y2) `thenCompare` lazy (x3 <=> y3)

                case (FlocCharDescrKey(_, _, _), ZEquiaddrAttrKey(_, _, _))     => LessThan
                case (FlocCharDescrKey(_, _, _), ZFuncloadAttrKey(_, _, _))     => LessThan

                case (ZEquiaddrAttrKey(_, _, _), EquiNameKey(_))                => GreaterThan
                case (ZEquiaddrAttrKey(_, _, _), FlocNameKey(_))                => GreaterThan
                case (ZEquiaddrAttrKey(_, _, _), EquiClassKey(_, _))            => GreaterThan
                case (ZEquiaddrAttrKey(_, _, _), FlocClassKey(_, _))            => GreaterThan
                case (ZEquiaddrAttrKey(_, _, _), EquiAttrKey(_, _))             => GreaterThan
                case (ZEquiaddrAttrKey(_, _, _), FlocAttrKey(_, _))             => GreaterThan
                case (ZEquiaddrAttrKey(_, _, _), EquiCharDescrKey(_, _, _))     => GreaterThan
                case (ZEquiaddrAttrKey(_, _, _), FlocCharDescrKey(_, _, _))     => GreaterThan
                case (ZEquiaddrAttrKey(x1, x2, x3), ZEquiaddrAttrKey(y1, y2, y3))   =>
                    (x1 <=> y1) `thenCompare` lazy (x2 <=> y2) `thenCompare` lazy (x3 <=> y3)

                case (ZEquiaddrAttrKey(_, _, _), ZFuncloadAttrKey(_, _, _))     => LessThan


                case (ZFuncloadAttrKey(_, _, _), EquiNameKey(_))                => GreaterThan
                case (ZFuncloadAttrKey(_, _, _), FlocNameKey(_))                => GreaterThan
                case (ZFuncloadAttrKey(_, _, _), EquiClassKey(_, _))            => GreaterThan
                case (ZFuncloadAttrKey(_, _, _), FlocClassKey(_, _))            => GreaterThan
                case (ZFuncloadAttrKey(_, _, _), EquiAttrKey(_, _))             => GreaterThan
                case (ZFuncloadAttrKey(_, _, _), FlocAttrKey(_, _))             => GreaterThan
                case (ZFuncloadAttrKey(_, _, _), EquiCharDescrKey(_, _, _))     => GreaterThan
                case (ZFuncloadAttrKey(_, _, _), FlocCharDescrKey(_, _, _))     => GreaterThan
                case (ZFuncloadAttrKey(_, _, _), ZEquiaddrAttrKey(_, _, _))     => GreaterThan
                case (ZFuncloadAttrKey(x1, x2, x3), ZFuncloadAttrKey(y1, y2, y3))   => 
                    (x1 <=> y1) `thenCompare` lazy (x2 <=> y2) `thenCompare` lazy (x3 <=> y3)

            }
    }



    pub enum Instruction { 
        case New(String)
        case Change(String)
        case Delete
    }

    instance ToString[Instruction] {
        pub def toString(x: Instruction): String = match x {
            case New(s)     => "New(${s})"
            case Change(s)  => "Change(${s})"
            case Delete     => "Delete"
        }
    }

    pub enum ValueState {
        case CreateLocal(String)
        case DeleteLocal
        case UpdateGlobal(String)
        case DeleteGlobal
    }

    instance ToString[ValueState] {
        pub def toString(x: ValueState): String = match x {
            case CreateLocal(s)     => "CreateLocal(${s})"
            case UpdateGlobal(s)    => "UpdateGlobal(${s})"
            case DeleteGlobal       => "DeleteGlobal"
            case DeleteLocal        => "DeleteLocal"
        }
    }


    pub enum EntityType {
        case Equi
        case Floc
    }

    instance ToString[EntityType] {
        pub def toString(x: EntityType): String = match x {
            case Equi   => "Equi"
            case Floc   => "Floc"
        }
    }

    instance Eq[EntityType] {
        pub def eq(x: EntityType, y: EntityType): Bool = match (x, y) {
            case (Equi, Equi)   => true
            case (Floc, Floc)   => true
            case (_, _)         => false
        }
    }

    instance Order[EntityType] {
        pub def compare(x: EntityType, y: EntityType): Comparison = match (x, y) {
            case (Equi, Equi)   => EqualTo
            case (Equi, Floc)   => LessThan
            case (Floc, Floc)   => EqualTo 
            case (Floc, Equi)   => GreaterThan
        }
    }
    
    pub enum CharValue {
        case S4String(String)
        case S4Date(Time.LocalDate)
        case S4Int(Int32)
        case S4Float(Float64)
    }

    instance ToString[CharValue] {
        pub def toString(x: CharValue): String = match x {
            case S4String(x1)    => "S4String('${x1}')"
            case S4Date(x1)     => "S4Date(${x1})"
            case S4Int(x1)       => "S4Int(${x1})"
            case S4Float(x1)     => "S4Float(${x1})"
        }
    }

    instance Eq[CharValue] {
        pub def eq(x: CharValue, y: CharValue): Bool = match (x, y) {
            case (S4String(x1), S4String(y1))   => x1 == y1
            case (S4Date(x1), S4Date(y1))       => x1 == y1
            case (S4Int(x1), S4Int(y1))         => x1 == y1
            case (S4Float(x1), S4Float(y1))     => x1 == y1     /// Shock: ffloat equality!
            case _ => false
        }
    }

}
