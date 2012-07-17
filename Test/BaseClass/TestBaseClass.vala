using GLib;
[CCode(cname="g_test_fail")]
extern void fail();

class TestBaseDummy: IfThenElse.Base
{
}
class TestBaseClass
{
    private TestSuite ts = null;
    private TestBaseDummy bc = null;

    public TestBaseClass()
    {
        ts = new TestSuite("BaseClass");

        var tc = new TestCase("test get name",setup, test_get_name, teardown);
        ts.add(tc);

        tc = new TestCase("test set name",setup, test_set_name, teardown);
        ts.add(tc);

        tc = new TestCase("test set name null",setup, test_set_name_null, teardown);
        ts.add(tc);

        tc = new TestCase("test set name empty",setup, test_set_name_null, teardown);
        ts.add(tc);

        tc = new TestCase("test get public name",setup, test_get_public_name,teardown);
        ts.add(tc);

        tc = new TestCase("test get public name no colon",setup, test_get_public_name_no_colon,teardown);
        ts.add(tc);

        tc = new TestCase("test get public name end colon",setup, test_get_public_name_end_colon,teardown);
        ts.add(tc);
        TestSuite.get_root().add_suite(ts);
    }

    ~TestBaseClass()
    {

    }

    void setup()
    {
        bc = new TestBaseDummy();
    }

    void test_get_name()
    {
        if(bc.name != "n/a") {
            Test.message("The default name of IfThenElse.Base did not match");
            fail();
            return;
        }
    }

    void test_set_name()
    {
        bc.name = "Test Name";
        if(bc.name != "Test Name") {
            Test.message("The setting name of IfThenElse.Base did not work.");
            fail();
            return;
        }
    }

    void test_set_name_null()
    {
        if(Test.trap_fork(0, TestTrapFlags.SILENCE_STDOUT|TestTrapFlags.SILENCE_STDERR))
        {
            bc.name = null;
            Posix.exit(0);
        }
        Test.trap_assert_failed();
    }

    void test_set_name_empty()
    {
        if(Test.trap_fork(0, TestTrapFlags.SILENCE_STDOUT|TestTrapFlags.SILENCE_STDERR))
        {
            bc.name = "";
            Posix.exit(0);
        }
        Test.trap_assert_failed();
    }
    void test_get_public_name()
    {
        bc.name = "Test:Case";
        if(bc.get_public_name() != "Case") {
            Test.message("Creating public name failed, got: %s instead of Case", bc.get_public_name());
            fail();
            return;
        }
    }

    void test_get_public_name_no_colon()
    {
        bc.name = "naar";

        if(bc.get_public_name() != "naar") {
            Test.message("Creating public name failed, got: %s instead of naar", bc.get_public_name());
            fail();
            return;
        }
    }
    void test_get_public_name_end_colon()
    {
        bc.name = "naar:";

        assert(bc.get_public_name() == "naar");
/*
            Test.message("Creating public name failed, got: %s instead of naar", bc.get_public_name());
            fail();
            return;
        }*/
    }

    void teardown()
    {
        bc = null;
    }
}


static int main ( string[] argv )
{
    Test.init(ref argv);

    var a = new TestBaseClass();
    Test.run();
    a = null;
    return 0;
}
