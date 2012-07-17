using GLib;


static int main ( string[] argv )
{
    Test.init(ref argv);

    var a = new TestBaseClass();
    Test.run();
    a = null;
    return 0;
}
