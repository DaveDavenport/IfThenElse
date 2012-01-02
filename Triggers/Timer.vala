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
		private int _timeout = 5;
		public int timeout {
			get{
				return _timeout;
			}
			set{
				_timeout = value;
				if(handler > 0) {
					GLib.Source.remove(handler);
					handler = GLib.Timeout.add_seconds(_timeout, timer_callback);
				}
			}
		}
		public bool timer_callback()
		{
				stdout.printf("Timer file\n");
				this.fire();
				return true;
		}
		
		public TimerTrigger(uint timeout)
		{
				
		}
		~TimerTrigger()
		{
			if(handler > 0){
				GLib.Source.remove(handler);
				handler = 0;
			}
		}
		
		public override void enable_trigger()
		{
			timer_callback();
			if(handler == 0) {
				handler = GLib.Timeout.add_seconds(timeout, timer_callback);
			}
		}
		public override void disable_trigger()
		{
			if(handler > 0) {
				GLib.Source.remove(handler);
			}
			handler = 0;
		}
		
		public override void output_dot(FileStream fp)
		{
			fp.printf("%s [label=\"%s\\nTimeout Trigger: %.2f seconds\", shape=oval]\n", 
						this.name,
						this.name,
						this.timeout);
			fp.printf("%s -> %s\n", this.name, action.name);
			this.action.output_dot(fp);
		}
	}
}
