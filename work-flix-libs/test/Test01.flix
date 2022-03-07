
namespace Test01 {

    use AssetLib/Base/Osgb36.NGR.{NGR};

    @test
    def testOsgb63Parse01(): Bool = 
        AssetLib/Base/Osgb36.parse("SE1411540074") == Some(NGR("SE1411540074"))

}
