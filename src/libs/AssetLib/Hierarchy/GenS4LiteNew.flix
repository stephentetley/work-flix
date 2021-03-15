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

namespace AssetLib/Hierarchy/GenS4LiteNew {

    use AssetLib/S4/Base.{Floc};
    use AssetLib/Hierarchy/Datatypes.{Site, 
        Function, ProcessGroup, Process, System, Subsystem, FlocProperties, 
        Equipment, EquipmentProperties, Attribute, Value};
    use AssetLib/Hierarchy/Datatypes.Equipment.{Equipment};
    use AssetLib/Hierarchy/Datatypes.Value.{Text, Integer, Decimal, Date};
    use AssetLib/S4Lite/CreateNew/Datatypes.{FlocDatum => S4FlocDatum, 
        FlocAttributes => S4FlocAttributes, 
        EquiDatum => S4EquiDatum,
        EquiAttributes => S4EquiAttributes, 
        LongText => S4LongText,
        Classification => S4Classification, 
        Value => S4Value};

    /// The hierarchy has been normalized first...
    
    pub def emitSite(x: Site): Result[(List[S4FlocDatum], List[S4EquiDatum]), String] = 
        use Result.{flatMap};
        let* floc           = Option.toOk(AssetLib/S4/Base/Floc.new(x.flocTag), "No Site tag");
        let* attrs          = genS4FlocAttributes(floc, x.properties, x.attributes);
        let classes         = genS4Classifications(x.attributes);
        let funcloc         = {functionalLocation = "${floc}", attributes = attrs, longText = noLongText(), classifications = classes};
        let* xss            = Result.traverse(emitFunction(floc), x.functions);
        let (kids, equis)   = unzipFlatten(xss);
        Ok((funcloc :: kids, equis))

    pub def emitFunction(superFloc: Floc, x: Function): Result[(List[S4FlocDatum], List[S4EquiDatum]), String] = 
        use Result.{flatMap};
        let floc            = AssetLib/S4/Base/Floc.snoc(superFloc, x.properties.objectType);
        let* attrs          = genS4FlocAttributes(floc, x.properties, x.attributes);
        let classes         = genS4Classifications(x.attributes);
        let funcloc         = {functionalLocation = "${floc}", attributes = attrs, longText = noLongText(), classifications = classes};
        let* xss            = Result.traverse(emitProcessGroup(floc), x.processGroups);
        let (kids, equis)   = unzipFlatten(xss);
        Ok((funcloc :: kids, equis))

    pub def emitProcessGroup(superFloc: Floc, x: ProcessGroup): Result[(List[S4FlocDatum], List[S4EquiDatum]), String] = 
        use Result.{flatMap};
        let floc            = AssetLib/S4/Base/Floc.snoc(superFloc, x.properties.objectType);
        let* attrs          = genS4FlocAttributes(floc, x.properties, x.attributes);
        let classes         = genS4Classifications(x.attributes);
        let funcloc         = {functionalLocation = "${floc}", attributes = attrs, longText = noLongText(), classifications = classes};
        let* xss            = Result.traverse(emitProcess(floc), x.processes);
        let (kids, equis)   = unzipFlatten(xss);
        Ok((funcloc :: kids, equis))

    pub def emitProcess(superFloc: Floc, x: Process): Result[(List[S4FlocDatum], List[S4EquiDatum]), String] = 
        use Result.{flatMap};
        let floc            = AssetLib/S4/Base/Floc.snoc(superFloc, x.properties.objectType);
        let* attrs          = genS4FlocAttributes(floc, x.properties, x.attributes);
        let classes         = genS4Classifications(x.attributes);
        let funcloc         = {functionalLocation = "${floc}", attributes = attrs, longText = noLongText(), classifications = classes};
        let* xss            = Result.traverse(emitSystem(floc), x.systems);
        let (kids, equis)   = unzipFlatten(xss);
        Ok((funcloc :: kids, equis))

    pub def emitSystem(superFloc: Floc, x: System): Result[(List[S4FlocDatum], List[S4EquiDatum]), String] = 
        use Result.{flatMap};
        let floc            = AssetLib/S4/Base/Floc.snoc(superFloc, indexedTag("SYS", x.flocIndex));
        let* attrs          = genS4FlocAttributes(floc, x.properties, x.attributes);
        let classes         = genS4Classifications(x.attributes);
        let funcloc         = {functionalLocation = "${floc}", attributes = attrs, longText = noLongText(), classifications = classes};
        let* xss            = Result.traverse(emitSubsystem(floc), x.subsystems);
        let (kids, equis1)  = unzipFlatten(xss);
        let* ess            = Result.traverse(genS4EquiDatum(floc, ""), x.equipment);
        let equis2          = Monoid.combineAll(ess);
        Ok((funcloc :: kids, equis1 ::: equis2))

    def unzipFlatten(xss: List[(List[a], List[b])]): (List[a], List[b]) = 
        let (yss, zss) = List.unzip(xss);
        (List.flatten(yss), List.flatten(zss))

    pub def emitSubsystem(superFloc: Floc, x: Subsystem): Result[(List[S4FlocDatum], List[S4EquiDatum]), String] = 
        use Result.{flatMap};
        let floc    = AssetLib/S4/Base/Floc.snoc(superFloc, indexedTag(x.flocTagPrefix, x.flocIndex));
        let* attrs  = genS4FlocAttributes(floc, x.properties, x.attributes);
        let classes = genS4Classifications(x.attributes);
        let funcloc = {functionalLocation = "${floc}", attributes = attrs, longText = noLongText(), classifications = classes};
        let* ess    = Result.traverse(genS4EquiDatum(floc, ""), x.equipment);
        let equis   = Monoid.combineAll(ess);
        Ok((funcloc :: Nil, equis))

    def indexedTag(prefix: String, ix: Int32): String = 
        prefix + String.padLeft(2, '0', "${ix}")

    def noLongText(): Option[S4LongText] = None


    pub def genS4FlocAttributes(floc: Floc, props: FlocProperties, attrs: List[Attribute]): Result[S4FlocAttributes, String] =
        ((x1, x2, x3, x4, x5) -> 
            { description           = props.name
            , category              = AssetLib/S4/Base/Floc.level(floc)
            , structureIndicator    = x1
            , objectType            = props.objectType
            , startupDate           = props.startupDate
            , maintPlant            = x2
            , companyCode           = x3
            , controllingArea       = x4
            , superiorFloc          = x5
            , equipmentInstall      = AssetLib/S4/Base/Floc.level(floc) >= 5
            , status                = props.status
            })
            <&> Ok(attributeTextValueWithDefault("ROOT", "structure_indicator", attrs, "YW-GS"))
            <*> Ok(attributeIntValueWithDefault("ROOT", "maint_plant", attrs, 2100))
            <*> Ok(attributeIntValueWithDefault("ROOT", "company_code", attrs, 2100))
            <*> Ok(attributeIntValueWithDefault("ROOT", "controlling_area", attrs, 1000))
            <*> Ok(Option.getWithDefault(Option.map(ToString.toString, AssetLib/S4/Base/Floc.parent(floc)), ""))
            

    pub def genS4EquiDatum(floc: Floc, superEquiId: String, x: Equipment): Result[List[S4EquiDatum], String] = 
        use Result.{flatMap};
        let Equipment(props, kids) = x;
        let* attrs  = genS4EquiAttributes(floc, superEquiId, props);
        let classes = genS4Classifications(props.attributes);
        let e1      = {equiId = props.identifier, attributes = attrs, longText = noLongText(), classifications = classes};
        let* ess    = Result.traverse(genS4EquiDatum(floc, props.identifier), kids);
        let es      = Monoid.combineAll(ess);
        Ok(e1 :: es)
        


    pub def genS4EquiAttributes(floc: Floc, superEquiId: String, x: EquipmentProperties): Result[S4EquiAttributes, String] =
        ((x1, x2, x3, x4, x5, x6, x7, x8, x9, x10) -> 
            { category              = x1
            , description           = x.name
            , objectType            = x.objectType  
            , startupDate           = x.startupDate
            , manufacturer          = x2
            , model                 = x3
            , partNumber            = x4
            , serialNumber          = x5
            , constructionYear      = Time/LocalDate.getYear(x.startupDate)
            , constructionMonth     = Time/LocalDate.getMonth(x.startupDate)
            , maintPlant            = x6
            , companyCode           = x7
            , controllingArea       = x8
            , planningPlant         = x9
            , functionalLocation    = ToString.toString(floc)
            , superOrdinateEqui     = superEquiId
            , techIdentNo           = x10
            , status                = x.status
            })
            <&> attributeTextValue("ROOT", "category", x.attributes)
            <*> attributeTextValue("ROOT", "manufacturer", x.attributes)
            <*> attributeTextValue("ROOT", "model", x.attributes)
            <*> attributeTextValue("ROOT", "part_number", x.attributes)
            <*> attributeTextValue("ROOT", "serial_number", x.attributes)
            <*> Ok(attributeIntValueWithDefault("ROOT", "maint_plant", x.attributes, 2100))
            <*> Ok(attributeIntValueWithDefault("ROOT", "company_code", x.attributes, 2100))
            <*> Ok(attributeIntValueWithDefault("ROOT", "controlling_area", x.attributes, 1000))
            <*> Ok(attributeIntValueWithDefault("ROOT", "planning_plant", x.attributes, 2100))
            <*> Ok(attributeTextValueWithDefault("ROOT", "tech_ident_no", x.attributes, ""))

    
    
    def attributeIntValue(category: String, attrName: String, attrs: List[Attribute]): Result[Int32, String] = 
        use AssetLib/S4Lite/CreateNew/Datatypes.Value.{Integer => S4Integer};
        match attributeValue(category, attrName, attrs) {
            case Ok(S4Integer(i)) => Ok(i)
            case Ok(_) => Err("Attribute ${category}:${attrName} is not an Integer")
            case Err(msg) => Err(msg)
        }

    def attributeIntValueWithDefault(category: String, attrName: String, attrs: List[Attribute], d: Int32): Int32 = 
        Result.getWithDefault(attributeIntValue(category, attrName, attrs), d)

    def attributeTextValue(category: String, attrName: String, attrs: List[Attribute]): Result[String, String] = 
        use AssetLib/S4Lite/CreateNew/Datatypes.Value.{Text => S4Text};
        match attributeValue(category, attrName, attrs) {
            case Ok(S4Text(s)) => Ok(s)
            case Ok(_) => Err("Attribute ${category}:${attrName} is not Text")
            case Err(msg) => Err(msg)
        }        
    
    def attributeTextValueWithDefault(category: String, attrName: String, attrs: List[Attribute], d: String): String = 
        Result.getWithDefault(attributeTextValue(category, attrName, attrs), d)

    def attributeValue(category: String, attrName: String, attrs: List[Attribute]): Result[S4Value, String] = 
        use AssetLib/Hierarchy/Datatypes.{getAttributeValue => fn};
        Result.map(genS4Value, Option.toOk(fn(category, attrName, attrs), "missing Attribute ${category}:${attrName}"))

    pub def attributeValueWithDefault(category: String, attrName: String, attrs: List[Attribute], dflt: Value): Result[S4Value, String] = 
        use AssetLib/Hierarchy/Datatypes.{getAttributeValue => fn};
        match fn(category, attrName, attrs) {
            case Some(v1) => Ok(genS4Value(v1))
            case None => Ok(genS4Value(dflt))
        }

    pub def genS4Classifications(xs: List[Attribute]): List[S4Classification] =
        List.filterMap(genS4Classification, xs)
    
    pub def genS4Classification(x: Attribute): Option[S4Classification] =
        if (x.classification == "ROOT") 
            None
        else {
            let v1 = genS4Value(x.value);
            Some({className = x.classification, charName = x.name, value = v1})
        }

    def genS4Value(x: Value): S4Value = 
        use AssetLib/S4Lite/CreateNew/Datatypes.Value.{Text => S4Text, Integer => S4Integer, Decimal => S4Decimal};
        match x {
            case Text(s)    => S4Text(s)
            case Integer(i) => S4Integer(i)
            case Decimal(d) => S4Decimal(d)
            case Date(dt)   => { 
                let fmt = Option.getWithDefault(Time/Format/DateFormatter.fromPattern("dd.MM.yyyy"), Time/Format/DateFormatter.basic_iso_date());
                S4Text(Time/LocalDate.format(dt, fmt))
            }
        }


    // Haskell's <$> i.e. fmap
    pub def <&>(f: a -> b, p2: Result[a, e]): Result[b, e] =
        Result.map(f, p2)

    // Haskell's <*> i.e. ap
    pub def <*>(mf: Result[a -> b, e], mx: Result[a, e]): Result[b, e] =
        Result.ap(mf, mx)


}