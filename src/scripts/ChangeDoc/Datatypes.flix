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

    type alias ItemId = String
    type alias ClassName = String
    type alias AttributeName = String
    type alias CharId = String
    type alias IntCounter = Int32
    type alias AddressNumber = Int32


    type alias ChangeDoc = List[ChangeRow]

    pub enum ChangeRow {
        case ChangeRow(ChangeKey, Instruction)
    }

    
    pub enum ChangeKey {
        case NameKey(EntityType, ItemId)             
        case ClassKey(EntityType, ItemId, ClassName)
        case AttrKey(EntityType, ItemId, AttributeName)
        case ValuaKey(EntityType, ItemId, CharId, IntCounter)
        case AddrAttrKey(EntityType, ItemId, AttributeName, AddressNumber)
    }

    instance ToString[ChangeKey] {
        pub def toString(x: ChangeKey): String = match x {
            case NameKey(x1, x2)                => "NameKey(${x1}, ${x2})"
            case ClassKey(x1, x2, x3)           => "ClassKey(${x1}, ${x2}, ${x3})"
            case AttrKey(x1, x2, x3)            => "AttrKey(${x1}, ${x2}, ${x3})"
            case ValuaKey(x1, x2, x3, x4)       => "ValuaKey(${x1}, ${x2}, ${x3}, ${x4})"
            case AddrAttrKey(x1, x2, x3, x4)    => "AddrAttrKey(${x1}, ${x2}, ${x3}, ${x4})"
        }
    }

    instance Eq[ChangeKey] {
        pub def eq(x: ChangeKey, y: ChangeKey): Bool = match (x, y) {
            case (NameKey(x1, x2), NameKey(y1, y2))             => x1 == y1 and x2 == y2
            case (ClassKey(x1, x2, x3), ClassKey(y1, y2, y3))   => x1 == y1 and x2 == y2 and x3 == y3
            case (AttrKey(x1, x2, x3), AttrKey(y1, y2, y3))     => x1 == y1 and x2 == y2 and x3 == y3
            case (ValuaKey(x1, x2, x3, x4), ValuaKey(y1, y2, y3, y4))       => x1 == y1 and x2 == y2 and x3 == y3 and x4 == y4
            case (AddrAttrKey(x1, x2, x3, x4), AddrAttrKey(y1, y2, y3, y4)) => x1 == y1 and x2 == y2 and x3 == y3 and x4 == y4
            case _ => false
        }
    }

    instance Order[ChangeKey] {
        pub def compare(x: ChangeKey, y: ChangeKey): Comparison = 
            use Order.thenCompare;
            match (x, y) {
                case (NameKey(x1, x2), NameKey(y1, y2))         => (x1 <=> y1) `thenCompare` lazy (x2 <=> y2)
                case (NameKey(_, _), ClassKey(_, _, _))         => LessThan
                case (NameKey(_, _), AttrKey(_, _, _))          => LessThan
                case (NameKey(_, _), ValuaKey(_, _, _, _))      => LessThan                
                case (NameKey(_, _), AddrAttrKey(_, _, _, _))   => LessThan            
                

                case (ClassKey(_, _, _), NameKey(_, _))             => GreaterThan
                case (ClassKey(x1, x2, x3), ClassKey(y1, y2, y3))   => 
                    (x1 <=> y1) `thenCompare` lazy (x2 <=> y2) `thenCompare` lazy (x3 <=> y3)

                case (ClassKey(_, _, _), AttrKey(_, _, _))          => LessThan
                case (ClassKey(_, _, _), ValuaKey(_, _, _, _))      => LessThan
                case (ClassKey(_, _, _), AddrAttrKey(_, _, _, _))   => LessThan


                case (AttrKey(_, _, _), NameKey(_, _))              => GreaterThan
                case (AttrKey(_, _, _), ClassKey(_, _, _))          => GreaterThan
                case (AttrKey(x1, x2, x3), AttrKey(y1, y2, y3))     => 
                    (x1 <=> y1) `thenCompare` lazy (x2 <=> y2) `thenCompare` lazy (x3 <=> y3)

                case (AttrKey(_, _, _), ValuaKey(_, _, _, _))       => LessThan
                case (AttrKey(_, _, _), AddrAttrKey(_, _, _, _))    => LessThan
            

                case (ValuaKey(_, _, _, _), NameKey(_, _))             => GreaterThan
                case (ValuaKey(_, _, _, _), ClassKey(_, _, _))         => GreaterThan
                case (ValuaKey(_, _, _, _), AttrKey(_, _, _))          => GreaterThan
                case (ValuaKey(x1, x2, x3, x4), ValuaKey(y1, y2, y3, y4))   => 
                    (x1 <=> y1) `thenCompare` lazy (x2 <=> y2) `thenCompare` lazy (x3 <=> y3) `thenCompare` lazy (x4 <=> y4)

                case (ValuaKey(_, _, _, _), AddrAttrKey(_, _, _, _))    => LessThan
                

                case (AddrAttrKey(_, _, _, _), NameKey(_, _))               => GreaterThan
                case (AddrAttrKey(_, _, _, _), ClassKey(_, _, _))           => GreaterThan
                case (AddrAttrKey(_, _, _, _), AttrKey(_, _, _))            => GreaterThan
                case (AddrAttrKey(_, _, _, _), ValuaKey(_, _, _, _))        => GreaterThan
                case (AddrAttrKey(x1, x2, x3, x4), AddrAttrKey(y1, y2, y3, y4)) =>
                    (x1 <=> y1) `thenCompare` lazy (x2 <=> y2) `thenCompare` lazy (x3 <=> y3) `thenCompare` lazy (x4 <=> y4)

                
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


    instance Hash[EntityType] {
        pub def hash(x: EntityType): Int32 = Hash.hash(ToString.toString(x))
    }

    instance Boxable[EntityType] {
        pub def box(x: EntityType): Boxed = {
            let value = x as ##java.lang.Object;
            let compare = (o1, o2) -> Order.compare(o1 as EntityType, o2 as EntityType);
            let toString = o -> ToString.toString(o as EntityType);
            BoxedObject(value, compare, toString)
        }
        pub def unbox(x: Boxed): EntityType = match x {
            case BoxedObject(v, _, _) => v as EntityType
            case _                    => ?bug
        }
    }

    pub enum Origin {
        case Direct
        case HSuperior
        case RRef
    }

    instance ToString[Origin] {
        pub def toString(x: Origin): String = match x {
            case Direct     => "Equi"
            case HSuperior  => "Floc"
            case RRef       => "RRef"
        }
    }


    instance Eq[Origin] {
        pub def eq(x: Origin, y: Origin): Bool = match (x, y) {
            case (Direct, Direct)       => true
            case (HSuperior, HSuperior) => true
            case (RRef, RRef)           => true
            case (_, _)                 => false
        }
    }

    instance Order[Origin] {
        pub def compare(x: Origin, y: Origin): Comparison = match (x, y) {
            case (Direct, Direct)       => EqualTo
            case (Direct, HSuperior)    => LessThan
            case (Direct, RRef)         => LessThan

            case (HSuperior, Direct)    => GreaterThan
            case (HSuperior, HSuperior) => EqualTo
            case (HSuperior, RRef)      => LessThan

            case (RRef, Direct)         => GreaterThan
            case (RRef, HSuperior)      => GreaterThan
            case (RRef, RRef)           => EqualTo
        }
    }


    instance Hash[Origin] {
        pub def hash(x: Origin): Int32 = Hash.hash(ToString.toString(x))
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
