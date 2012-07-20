using GLib;

class TestMultiActionDummy: IfThenElse.MultiAction
{
}
class TestMultiActionClass
{
    private TestSuite ts = null;
    private TestMultiActionDummy bc = null;

    public TestMultiActionClass()
    {
        ts = new TestSuite("MultiAction");

        ts.add(new TestCase("Add multiple actions",setup, add_multiple_actions,teardown));
        ts.add(new TestCase("Add multiple same actions",setup, add_multiple_same_actions,teardown));

        ts.add(new TestCase("Test multiple activates",setup, test_multiple_activate,teardown));
        ts.add(new TestCase("Test multiple deactivates",setup, test_multiple_deactivate,teardown));
        TestSuite.get_root().add_suite(ts);
    }

    ~TestMultiActionClass()
    {

    }

	void add_multiple_actions()
	{
        TestMultiActionDummy a = new TestMultiActionDummy();
        TestMultiActionDummy b = new TestMultiActionDummy();
        if(Test.trap_fork(0, TestTrapFlags.SILENCE_STDOUT|TestTrapFlags.SILENCE_STDERR))
        {
            bc.action = a;
            bc.action = b;
            Posix.exit(0);
        }
        Test.trap_has_passed();
        a= null;
        b = null;
	}

	void add_multiple_same_actions()
	{
        TestMultiActionDummy a = new TestMultiActionDummy();
        if(Test.trap_fork(0, TestTrapFlags.SILENCE_STDOUT|TestTrapFlags.SILENCE_STDERR))
        {
            bc.action = a;
            bc.action = a;
            Posix.exit(0);
        }
        Test.trap_assert_failed();
        Test.trap_assert_stderr("*You cannot add the same action multiple times.*");
        a= null;
	}

    void test_multiple_activate()
    {
        var t = new TestActionBaseState();
        bc.action = t;
        var t2 = new TestActionBaseState();
        bc.action = t2;

        bc.Activate(bc);
        if(t.state != true) fail();
        if(t2.state != true) fail();

        t = null;
        t2 = null;
    }
    void test_multiple_deactivate()
    {
        var t = new TestActionBaseState();
        bc.action = t;
        var t2 = new TestActionBaseState();
        bc.action = t2;

        bc.Activate(bc);
        bc.Deactivate(bc);
        if(t.state != false) fail();
        if(t2.state != false) fail();

        t = null;
        t2 = null;
    }

    void setup()
    {
        bc = new TestMultiActionDummy();
    }


    void teardown()
    {
        bc = null;
    }
}


