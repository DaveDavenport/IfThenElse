namespace IfThenElse
{
	public class Chain : BaseAction, Base
	{
		private BaseTrigger trigger_stmtm = null;
		private BaseCheck   if_stmt 	  = null;
		private BaseAction  else_stmt 	  = null;
		private BaseAction  then_stmt 	  = null;
		// Hold the previous state of the Check.
		private bool prev_state = false;
	
	
		public Chain (BaseTrigger? trigger,
					  BaseCheck if_s,
					  BaseAction then_s,
					  BaseAction else_s)
		{
			trigger_stmtm = trigger;
			if_stmt = if_s;
			else_stmt = else_s;
			then_stmt = then_s;
			if(trigger != null) {
				trigger.action = this;
			}
		}
		
		/**
		 * Handle activation. In this case, we call the check,
		 * see if it changed.
		 */
		public void Activate()
		{
			bool state = if_stmt.check();
			if(state != prev_state)
			{
				if(state)
				{
					// Then statement.
					then_stmt.Activate();
					else_stmt.Deactivate();
				}else{
					// Else Statement.
					else_stmt.Activate();
					then_stmt.Deactivate();
				}
				prev_state = state;
			}
		}
		
		/**
		 *  Not used here 
		 */
		public void Deactivate()
		{
			// Deactivate both.
			then_stmt.Deactivate();
			else_stmt.Deactivate();
		}
	}
}
	
