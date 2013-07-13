namespace Fix
{
	[CCode (cname = "struct flock", cheader_filename = "fcntl.h")]
	public struct Flock {
		public int l_type;
		public int l_whence;
		public Posix.off_t l_start;
		public Posix.off_t l_len;
		public Posix.pid_t l_pid;
	}
}
