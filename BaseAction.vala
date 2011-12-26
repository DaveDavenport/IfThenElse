namespace IfThenElse
{
	public interface BaseAction : Base
	{
		public virtual void Activate()
		{
			GLib.error("Activate action has not been implemented");
		}
		public virtual void Deactivate()
		{
			GLib.warning("Deactivate action has not been implemented");
		}
	}
}
