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


namespace AssetLib/GenS4/Rules/Characteristics/Electrical {

    use Compatibility.{XlsxSource};

    use AssetLib/S4Lite/Datatypes.{SLEquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.{EquiCharacteristic};
    use AssetLib/S4Lite/S4LiteRelations.CharValue.{S4String, S4Float, S4Int};
    use AssetLib/GenS4/Base/CommonRelations.{EquiWorkItem3, 
        CurrentInA, InsulationClass, IPRating, SpeedRPM, Power, VoltageIn};
    use AssetLib/GenS4.{GenMonad};
    use AssetLib/GenS4/WorkLists.{EquiWorkItem};
    use AssetLib/GenS4/Rules/Characteristics/Utils.{recognizedVoltageUnits, voltageUnits, 
        S4InsulationClass, s4InsulationClassRules};
    
    pub def genElectricalCharacteristics(workitems: #{EquiWorkItem3 | r1}, facts: #{|r2}): GenMonad[Unit] = 
        use AssetLib/GenS4/GenMonad.{flatMap, point};
        let* _ = genActu(workitems, facts as ActuSchema[r2]);
        let* _ = genConp(workitems, facts as ConpSchema[r2]);
        let* _ = genDist(workitems, facts as DistSchema[r2]);
        let* _ = genEmtr(workitems, facts as EmtrSchema[r2]);
        let* _ = genHeat(workitems, facts as HeatSchema[r2]);
        let* _ = genPode(workitems, facts as PodeSchema[r2]);
        let* _ = genSlip(workitems, facts as SlipSchema[r2]);
        let* _ = genSole(workitems, facts as SoleSchema[r2]);
        let* _ = genStar(workitems, facts as StarSchema[r2]);
        point()


    /// # ACTU


    pub type alias ActuSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, CurrentInA, InsulationClass, IPRating, Power, VoltageIn, S4InsulationClass, 
            EquiCharacteristic | r1}

    pub def genActu(workitems: #{EquiWorkItem3 | r1}, facts: ActuSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as ActuSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> actuCharacteristics())
        


    pub def actuCharacteristics(): ActuSchema[r1] = #{
        EquiCharacteristic(equiId, s4Class, "IP_RATING", S4String(rating)) :- 
            EquiWorkItem3(equiId, "ACTU", s4Class),
            IPRating(equiId, rating).

        EquiCharacteristic(equiId, s4Class, "INSULATION_CLASS_DEG_C", S4String(s4InsClass)) :-
            EquiWorkItem3(equiId, "ACTU", s4Class),
            InsulationClass(equiId, insClass),
            S4InsulationClass(insClass, s4InsClass).

        EquiCharacteristic(equiId, s4Class, "ACTU_RATED_CURRENT_A", S4Float(current)) :-
            EquiWorkItem3(equiId, "ACTU", s4Class),
            CurrentInA(equiId, current).

        EquiCharacteristic(equiId, s4Class, "ACTU_RATED_POWER_KW", S4Float(power)) :-
            EquiWorkItem3(equiId, "ACTU", s4Class),
            Power(equiId, power, "KILOWATTS").

        EquiCharacteristic(equiId, s4Class, "ACTU_RATED_VOLTAGE", S4Int(voltage)) :-
            EquiWorkItem3(equiId, "ACTU", s4Class),
            VoltageIn(equiId, voltage, units),
            if recognizedVoltageUnits(units).

        EquiCharacteristic(equiId, s4Class, "ACTU_RATED_VOLTAGE_UNITS", S4String(voltageUnits(units))) :-
            EquiWorkItem3(equiId, "ACTU", s4Class),
            VoltageIn(equiId, _, units),
            if recognizedVoltageUnits(units).

    } <+> s4InsulationClassRules() 

    /// # CONP

    pub type alias ConpSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, CurrentInA, VoltageIn, EquiCharacteristic | r1}


    pub def genConp(workitems: #{EquiWorkItem3 | r1}, facts: ConpSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as ConpSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> conpCharacteristics())

    pub def conpCharacteristics(): ConpSchema[r1] =  #{
        
        EquiCharacteristic(equiId, s4Class, "CONP_RATED_CURRENT_A", S4Float(current)) :-
            EquiWorkItem3(equiId, "CONP", s4Class),
            CurrentInA(equiId, current).

        EquiCharacteristic(equiId, s4Class, "CONP_RATED_VOLTAGE", S4Int(voltage)) :-
            EquiWorkItem3(equiId, "CONP", s4Class),
            VoltageIn(equiId, voltage, units),
            if recognizedVoltageUnits(units).

        EquiCharacteristic(equiId, s4Class, "CONP_RATED_VOLTAGE_UNITS", S4String(voltageUnits(units))) :-
            EquiWorkItem3(equiId, "CONP", s4Class),
            VoltageIn(equiId, _, units),
            if recognizedVoltageUnits(units).
    }

    /// # DIST

    pub type alias DistSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, IPRating, EquiCharacteristic | r1}


    pub def genDist(workitems: #{EquiWorkItem3 | r1}, facts: DistSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as DistSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> distCharacteristics())

    pub def distCharacteristics(): DistSchema[r1] =  #{
        
        EquiCharacteristic(equiId, s4Class, "IP_RATING", S4String(rating)) :- 
            EquiWorkItem3(equiId, "DIST", s4Class),
            IPRating(equiId, rating).

    }

    ///  # EMTR

    pub type alias EmtrSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, CurrentInA, InsulationClass, IPRating, SpeedRPM, Power, VoltageIn, S4InsulationClass,
            EquiCharacteristic | r1}


    pub def genEmtr(workitems: #{EquiWorkItem3 | r1}, facts: EmtrSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as EmtrSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> emtrCharacteristics())
        


    /// IP_RATING should be generated on per type (per class?)
    pub def emtrCharacteristics(): EmtrSchema[r1] = #{
            
        EquiCharacteristic(equiId, s4Class, "IP_RATING", S4String(rating)) :- 
            EquiWorkItem3(equiId, "EMTR", s4Class),
            IPRating(equiId, rating).

        /// TODO - check working...
        EquiCharacteristic(equiId, s4Class, "INSULATION_CLASS_DEG_C", S4String(s4InsClass)) :-
            EquiWorkItem3(equiId, "EMTR", s4Class),
            InsulationClass(equiId, insClass),
            S4InsulationClass(insClass, s4InsClass).

        EquiCharacteristic(equiId, s4Class, "EMTR_RATED_CURRENT_A", S4Float(current)) :-
            EquiWorkItem3(equiId, "EMTR", s4Class),
            CurrentInA(equiId, current).

        EquiCharacteristic(equiId, s4Class, "EMTR_RATED_POWER_KW", S4Float(power)) :-
            EquiWorkItem3(equiId, "EMTR", s4Class),
            Power(equiId, power, "KILOWATTS").

        EquiCharacteristic(equiId, s4Class, "EMTR_RATED_SPEED_RPM", S4Int(speed)) :- 
            EquiWorkItem3(equiId, "EMTR", s4Class),
            SpeedRPM(equiId, speed).

        /// Units are just VAC or VDC - no conversion
        EquiCharacteristic(equiId, s4Class, "EMTR_RATED_VOLTAGE", S4Int(voltage)) :-
            EquiWorkItem3(equiId, "EMTR", s4Class),
            VoltageIn(equiId, voltage, units),
            if recognizedVoltageUnits(units).

        EquiCharacteristic(equiId, s4Class, "EMTR_RATED_VOLTAGE_UNITS", S4String(voltageUnits(units))) :-
            EquiWorkItem3(equiId, "EMTR", s4Class),
            VoltageIn(equiId, _, units),
            if recognizedVoltageUnits(units).

        }

    /// # HEAT

    pub type alias HeatSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, Power, EquiCharacteristic | r1}


    pub def genHeat(workitems: #{EquiWorkItem3 | r1}, facts: HeatSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as HeatSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> heatCharacteristics())

    pub def heatCharacteristics(): HeatSchema[r1] =  #{
        
        EquiCharacteristic(equiId, s4Class, "HEAT_RATED_POWER_KW", S4Float(power)) :-
            EquiWorkItem3(equiId, "HEAT", s4Class),
            Power(equiId, power, "KILOWATTS").

    }

    /// # MCCE
    /// TODO

    /// # PODE

    pub type alias PodeSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, IPRating, EquiCharacteristic | r1}

    pub def genPode(workitems: #{EquiWorkItem3 | r1}, facts: PodeSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as PodeSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> podeCharacteristics())

    pub def podeCharacteristics(): PodeSchema[r1] = #{
    
        EquiCharacteristic(equiId, s4Class, "IP_RATING", S4String(rating)) :- 
            EquiWorkItem3(equiId, "PODE", s4Class),
            IPRating(equiId, rating).

    }

    ///  # SLIP

    pub type alias SlipSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, Power, VoltageIn, EquiCharacteristic | r1}


    pub def genSlip(workitems: #{EquiWorkItem3 | r1}, facts: SlipSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as SlipSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> slipCharacteristics())
        


    /// IP_RATING should be generated on per type (per class?)
    pub def slipCharacteristics(): SlipSchema[r1] = #{
            

        EquiCharacteristic(equiId, s4Class, "SLIP_RATED_POWER_KW", S4Float(power)) :-
            EquiWorkItem3(equiId, "SLIP", s4Class),
            Power(equiId, power, "KILOWATTS").

        /// Units are just VAC or VDC - no conversion
        EquiCharacteristic(equiId, s4Class, "SLIP_RATED_VOLTAGE", S4Int(voltage)) :-
            EquiWorkItem3(equiId, "SLIP", s4Class),
            VoltageIn(equiId, voltage, units),
            if recognizedVoltageUnits(units).

        EquiCharacteristic(equiId, s4Class, "SLIP_RATED_VOLTAGE_UNITS", S4String(voltageUnits(units))) :-
            EquiWorkItem3(equiId, "SLIP", s4Class),
            VoltageIn(equiId, _, units),
            if recognizedVoltageUnits(units).

        }

    /// # SOLE

    pub type alias SoleSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, IPRating, InsulationClass, CurrentInA, Power, S4InsulationClass, EquiCharacteristic | r1}

    pub def genSole(workitems: #{EquiWorkItem3 | r1}, facts: SoleSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as SoleSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> soleCharacteristics())

    pub def soleCharacteristics(): SoleSchema[r1] = #{
    
        EquiCharacteristic(equiId, s4Class, "IP_RATING", S4String(rating)) :- 
            EquiWorkItem3(equiId, "SOLE", s4Class),
            IPRating(equiId, rating).

        EquiCharacteristic(equiId, s4Class, "INSULATION_CLASS_DEG_C", S4String(s4InsClass)) :-
            EquiWorkItem3(equiId, "SOLE", s4Class),
            InsulationClass(equiId, insClass),
            S4InsulationClass(insClass, s4InsClass).

        EquiCharacteristic(equiId, s4Class, "SOLE_RATED_CURRENT_A", S4Float(current)) :-
            EquiWorkItem3(equiId, "SOLE", s4Class),
            CurrentInA(equiId, current).

        EquiCharacteristic(equiId, s4Class, "SOLE_RATED_POWER_KW", S4Float(power)) :-
            EquiWorkItem3(equiId, "SOLE", s4Class),
            Power(equiId, power, "KILOWATTS").
    
    } <+> s4InsulationClassRules()



    /// # STAR

    pub type alias StarSchema[r1: SchemaRow] = 
        #{EquiWorkItem3, CurrentInA, IPRating, SpeedRPM, Power, VoltageIn, EquiCharacteristic | r1}

    pub def genStar(workitems: #{EquiWorkItem3 | r1}, facts: StarSchema[r2]): GenMonad[Unit] =
        let workitems1 = workitems as StarSchema[r2];
        AssetLib/GenS4/GenMonad.tellEquiCharacteristics(workitems1 <+> facts <+> starCharacteristics())


    /// TODO - check "STAR_INPUT_CURRENT_A" / "STAR_INPUT_VOLTAGE" ... (STARVF ...)

    pub def starCharacteristics(): StarSchema[r1] = #{
    
        EquiCharacteristic(equiId, s4Class, "IP_RATING", S4String(rating)) :-
            EquiWorkItem3(equiId, "STAR", s4Class),
            IPRating(equiId, rating).

        EquiCharacteristic(equiId, s4Class, starCurrentA(s4Class), S4Float(current)) :-
            EquiWorkItem3(equiId, "STAR", s4Class),
            CurrentInA(equiId, current).
        

        EquiCharacteristic(equiId, s4Class, "STAR_RATED_POWER_KW", S4Float(power)) :-
            EquiWorkItem3(equiId, "STAR", s4Class),
            Power(equiId, power, "KILOWATTS").

        EquiCharacteristic(equiId, s4Class, starVoltage(s4Class), S4Int(voltage)) :-
            EquiWorkItem3(equiId, "STAR", s4Class),
            VoltageIn(equiId, voltage, units),
            if recognizedVoltageUnits(units).


        EquiCharacteristic(equiId, s4Class, starVoltageUnits(s4Class), S4String(voltageUnits(units))) :-
            EquiWorkItem3(equiId, "STAR", s4Class),
            VoltageIn(equiId, _, units),
            if recognizedVoltageUnits(units).

    }

    def starCurrentA(x: String): String = match x { 
        case "STARVF"   => "STAR_INPUT_CURRENT_A"
        case _          => "STAR_RATED_CURRENT_A"
    }

    /// We might like this as Datalog but having a "default case" is too much effort
    def starVoltage(x: String): String = match x { 
        case "STARVF"   => "STAR_INPUT_VOLTAGE"
        case _          => "STAR_RATED_VOLTAGE"
    }

    /// We might like this as Datalog but having a "default case" is too much effort
    def starVoltageUnits(x: String): String = match x { 
        case "STARVF"   => "STAR_INPUT_VOLTAGE_UNITS"
        case _          => "STAR_RATED_VOLTAGE_UNITS"
    }

}
