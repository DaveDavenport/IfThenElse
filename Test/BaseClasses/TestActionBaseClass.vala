using GLib;

class TestActionBaseDummy: IfThenElse.Base, IfThenElse.BaseAction
{
}
class TestActionBaseClass
{
    private TestSuite ts = null;
    private TestActionBaseDummy bc = null;

    public TestActionBaseClass()
    {
        ts = new TestSuite("ActionBase");

        ts.add(new TestCase("test activate null",setup, activate_pass_null,teardown));
        ts.add(new TestCase("test deactivate null",setup, deactivate_pass_null,teardown));
        ts.add(new TestCase("test activate",setup, activate,teardown));
        ts.add(new TestCase("test deactivate",setup, deactivate,teardown));

        TestSuite.get_root().add_suite(ts);
    }

    ~TestActionBaseClass()
    {

    }

	void activate_pass_null()
	{
        if(Test.trap_fork(0, TestTrapFlags.SILENCE_STDOUT|TestTrapFlags.SILENCE_STDERR))
        {
            bc.Activate(null);
            Posix.exit(0);
        }
        Test.trap_assert_failed();
	}
	void deactivate_pass_null()
	{
        if(Test.trap_fork(0, TestTrapFlags.SILENCE_STDOUT|TestTrapFlags.SILENCE_STDERR))
        {
            bc.Deactivate(null);
            Posix.exit(0);
        }
        Test.trap_assert_failed();
	}

	void activate()
	{
        if(Test.trap_fork(0, TestTrapFlags.SILENCE_STDOUT|TestTrapFlags.SILENCE_STDERR))
        {
            bc.Activate(bc);
            Posix.exit(0);
        }
        Test.trap_assert_stderr("*Activate action has not been implemented*");
	}
	void deactivate()
	{
        if(Test.trap_fork(0, TestTrapFlags.SILENCE_STDOUT|TestTrapFlags.SILENCE_STDERR))
        {
            bc.Deactivate(bc);
            Posix.exit(0);
        }
        Test.trap_assert_stderr("*Deactivate action has not been implemented*");
	}

    void setup()
    {
        bc = new TestActionBaseDummy();
    }


    void teardown()
    {
        bc = null;
    }
}


