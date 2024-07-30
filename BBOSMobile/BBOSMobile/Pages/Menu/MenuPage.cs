using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Core;
using Custom = BBOSMobile.Forms.Custom;

namespace BBOSMobile.Forms.Pages.Menu
{

	public class MenuPage : ContentPage
	{
		readonly List<Custom.MenuItem> menuItems = new List<Custom.MenuItem>();

		public ListView Menu { get; set; }

		public MenuPage ()
		{
			
			menuItems.Add(new Custom.MenuItem { Title="Dashboard", Padding="" });
			menuItems.Add(new Custom.MenuItem { Title="Quick Find", Padding="     " });
			menuItems.Add(new Custom.MenuItem { Title="Company Search", Padding="     " });
            menuItems.Add(new Custom.MenuItem { Title = "Person Search", Padding = "     " });


            if ((App.RecentViewsSecurity.HasPrivilege) || (App.RecentViewsSecurity.Visible)) {
				menuItems.Add(new Custom.MenuItem { Title="Recent Views", Padding="     "});
			}
			if ((App.WatchdogListsPage.HasPrivilege) || (App.WatchdogListsPage.Visible)) {
				menuItems.Add(new Custom.MenuItem { Title="Watchdog Groups", Padding="     " });
			}


			menuItems.Add(new Custom.MenuItem { Title="Contact Us", Padding=""});
			menuItems.Add(new Custom.MenuItem { Title="User Account", Padding=""});
			menuItems.Add(new Custom.MenuItem { Title="About Us", Padding=""});
			//menuItems.Add(new Custom.MenuItem { Title="View Full Site", Padding=""});
			menuItems.Add (new Custom.MenuItem { Title = "Log Out", Padding="" });

			BackgroundColor = Color.FromHex("333333");

			var layout = new StackLayout { Spacing = 0, VerticalOptions = LayoutOptions.FillAndExpand };


//			var label = new ContentView {
//				Padding = new Thickness(10, 18, 0, 5),
//				Content = new Xamarin.Forms.Label {
//					TextColor = Color.FromHex("AAAAAA"),
//					Text = "Options", 
//				}
//			};

//			Device.OnPlatform (
//				iOS: () => ((Xamarin.Forms.Label)label.Content).Font = Font.SystemFontOfSize (NamedSize.Micro),
//				Android: () => ((Xamarin.Forms.Label)label.Content).Font = Font.SystemFontOfSize (NamedSize.Medium)
//			);

			//layout.Children.Add(label);

			var stackLayoutSpacer = new StackLayout ();
			stackLayoutSpacer.HeightRequest = 20;
			layout.Children.Add(stackLayoutSpacer);


			Menu = new ListView {
				ItemsSource = menuItems,
				VerticalOptions = LayoutOptions.FillAndExpand,
				BackgroundColor = Color.Transparent,
			};

			var cell = new DataTemplate(typeof(Custom.MenuCell));
			cell.SetBinding(TextCell.TextProperty, "Title");
			cell.SetBinding(TextCell.TextProperty, "Padding");

			cell.SetValue(VisualElement.BackgroundColorProperty, Color.Transparent);
			cell.SetValue (TextCell.TextColorProperty, Color.FromHex("AAAAAA"));


			Menu.ItemTemplate = cell;

			layout.Children.Add(Menu);

			Content = layout;
		}
	}
}


