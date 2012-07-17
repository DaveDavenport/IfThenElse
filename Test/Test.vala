using GLib;

[CCode(cname="g_test_fail")]
extern void fail();

static int main ( string[] argv )
{
    Test.init(ref argv);

    var a = new TestBaseClass();
    var b = new TestActionBaseClass();
    Test.run();
    a = null;
    b = null;
    return 0;
}
