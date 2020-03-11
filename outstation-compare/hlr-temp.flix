
rel Name(x: String, y: String)
rel HLR(x: String, y: String)
rel Site(x: String)

@test
def hlr01[r](): #{ Name | r } = 
    let rules = #{ 

        // Fixed set of HLR rules
        HLR("X/CSO", "X/HLR").
        HLR("Y/NO 2 CSO", "Y/NO 2 HLR").

        Site("X/CSO").
        Site("Y/NO 2 CSO").
        Site("Z/CSO").

        Name(x, y):- HLR(x, y).
        Name(x, x):- Site(x), not HLR(x, _).
        
    };

    project Name (solve rules)


rel HlrSite(key: String)
rel Match(akey: String, bkey: String)


@test
def hlr02[r](): #{ Name | r } = 
    let sameButForHLR = (x,y) -> {
        let x1 = String.replaceAll("CSO", "HLR", x);
        x1 == y
    };
    let rules = #{ 

        // Fixed set of HLR rules
        HlrSite("X/HLR").
        HlrSite("Y/NO 2 HLR").

        Site("X/CSO").
        Site("Y/NO 2 CSO").
        Site("Z/CSO").

        Match(x, y):- Site(x), HlrSite(y), sameButForHLR(x,y).

        Name(x,y):- Match(x,y).
        Name(x,x):- Site(x), not Match(x, _).
        
    };

    project Name (solve rules)
    