/**
 * Copyright 2011-2012  Martijn Koedam <qball@gmpclient.org>
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of 
 * the License.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 
using GLib;

namespace IfThenElse
{
	public class TimerTrigger : BaseTrigger
	{
		private uint handler = 0;
		
		public bool timer_callback()
		{
				this.fire();
				return true;
		}
		
		public TimerTrigger(uint timeout)
		{
				handler = GLib.Timeout.add_seconds(timeout, timer_callback);
		}
		~TimerTrigger()
		{
			if(handler > 0){
				GLib.Source.remove(handler);
				handler = 0;
			}
		}
	}
}
