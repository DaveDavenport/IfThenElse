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
#if ENABLE_GTK_TOOLS
	public class StatusIconAction : BaseAction, Base
	{
		private Gtk.StatusIcon status_icon = null;

		/**
		 * Set icon from icon_name on status_icon.
		 */
		private string? _icon_name = null;
		public string icon_name {
			set {
				_icon_name = value;
				if(status_icon != null) {
					status_icon.set_from_icon_name(value);
				}
			}
		}

		/**
		 * Set icon from stock on status_icon.
		 */
		private string? _stock = null;
		public string stock {
			set {
				_stock = value;
				if(status_icon != null) {
					status_icon.set_from_stock(value);
				}
			}
		}
		/**
		 * Set icon from file on status_icon.
		 */
		private string? _file = null;
		public string file {
			set {
				_file = value;
				if(status_icon != null) {
					status_icon.set_from_file(value);
				}
			}
		}


		~StatusIconAction()
		{
			stdout.printf("Destroy StatusIconAction\n");
			status_icon = null;
		}

		public StatusIconAction ()
		{
		}
		

		public void Activate()
		{
			if(status_icon == null)
			{
				stdout.printf("StatusIcon: Activate\n");
				
				// Update the icon.
				if(_icon_name != null) {
					stdout.printf("Set icon name: '%s'\n", _icon_name);
					status_icon = new Gtk.StatusIcon.from_icon_name(_icon_name);
				}
				else if(_stock != null) {
					stdout.printf("Set stock: %s\n", _stock);
					status_icon = new Gtk.StatusIcon.from_stock(_stock);
				}
				else if (_file != null) {
					status_icon = new Gtk.StatusIcon.from_file(_file);
				}else {
					status_icon = new Gtk.StatusIcon();
				}
			}
		}

		public void Deactivate()
		{
			stdout.printf("StatusIcon: Deactivate\n");
			status_icon = null;
		}
	}
// ENABLE_GTK_TOOLS
#endif 
}


