using GLib;

class TestActionBaseDummy: IfThenElse.Base, IfThenElse.BaseAction
{
}

// Dummy class, so we can test if things get activated correctly.
class TestActionBaseState : IfThenElse.Base, IfThenElse.BaseAction
{
    public bool state = false;
    public void Activate(IfThenElse.Base parent)
    {
        state = true;
    }
    public void Deactivate(IfThenElse.Base parent)
    {
        state = false;
    }
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

        ts = new TestSuite("TestAction");
        ts.add(new TestCase("test activate",setup, tc_activate,teardown));
        ts.add(new TestCase("test deactivate",setup, tc_deactivate,teardown));
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

	void tc_activate()
    {
        var t = new TestActionBaseState();
        t.Activate(bc);
        if(t.state != true) {
            fail();
        }
        Test.trap_has_passed();

        t = null;
    }
	void tc_deactivate()
	{
        var t = new TestActionBaseState();
        t.Deactivate(bc);
        if(t.state != false) {
            fail();
        }
        t = null;
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


