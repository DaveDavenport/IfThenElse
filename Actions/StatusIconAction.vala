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
	public class StatusIconAction : BaseAction, Base
	{
		private Gtk.StatusIcon status_icon = new Gtk.StatusIcon();
		public string icon_name {
			set {
				status_icon.icon_name = value;
			}
		}
		public string stock {
			set {
				status_icon.stock = value;
			}
		}

		construct{
			stdout.printf("Deactivate\n");
			status_icon.visible = false;
		}
		public StatusIconAction ()
		{
		}
		
		public void Activate()
		{
			stdout.printf("Activate\n");
			status_icon.visible = true;
		}
		public void Deactivate()
		{
			stdout.printf("Deactivate\n");
			status_icon.visible = false;
		}
	}
}


