namespace IfThenElse
{
	public class BaseTrigger
	{
		public BaseAction action {get;set;default = null;}
		
		public BaseTrigger()
		{
		}
		
		public void fire()
		{
			if(action != null) {
				action.Activate();
			}
		}
	
	}
}
