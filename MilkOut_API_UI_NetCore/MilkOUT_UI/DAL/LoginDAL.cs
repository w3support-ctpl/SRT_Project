using System.Net.Http.Headers;
using System.Net;
using MilkOUT_UI.Models;

namespace MilkOUT_UI.DAL
{
	public class LoginDAL
	{
		private IConfigurationRoot configuration = new ConfigurationBuilder()
			.SetBasePath(AppDomain.CurrentDomain.BaseDirectory)
			.AddJsonFile("appsettings.json")
			.Build();

		public string API_URL = "";
		public string Destination_Name = "";

		public LoginDAL()
		{

			API_URL = configuration.GetSection("APISetting").GetSection("API_URL").Value;
			Destination_Name = configuration.GetSection("APISetting").GetSection("Destination_Name").Value;
		}

		public ResAPICommonOutput Login(ReqLogin login)
		{
			ResAPICommonOutput resOut = new ResAPICommonOutput();
			login.destination_name = Destination_Name;
			try
			{
				using (var client = new HttpClient())
				{
					//Passing service base BaserURL
					client.BaseAddress = new Uri(API_URL);
					client.DefaultRequestHeaders.Clear();

					//Define request data format
					client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

					//HTTP POST
					var postTask = client.PostAsJsonAsync<ReqLogin>("/v1/api/admin/user/Login", login);
					postTask.Wait();

					var result = postTask.Result;
					if (result.IsSuccessStatusCode)
					{

						//Storing the response details recieved from web api
						var response = result.Content.ReadAsStringAsync().Result;
						resOut.ResponseCode = HttpStatusCode.OK;
						resOut.ResponseMessage = "";
						resOut.ResponseData = response;
						return resOut;
					}
					else
					{
						resOut.ResponseCode = HttpStatusCode.InternalServerError;
						resOut.ResponseMessage = "Something went wrong";
						resOut.ResponseData = "";
						return resOut;

					}


				}
			}
			catch (Exception ex)
			{

				resOut.ResponseCode = HttpStatusCode.InternalServerError;
				resOut.ResponseMessage = ex.Message;
				resOut.ResponseData = "";
				return resOut;

			}
		}

		public string GetUserMenu(List<UserMenu> res_Obj)
		{
			// Generate Menu HTML as per theme
			var Menu_List = res_Obj;
			var Menu_HTML = "";

			var Cur_Parent_Menu_Id = "0";
			for (var i = 0; i < Menu_List.Count; ++i)
			{
				if (Menu_List[i].parent_menu_id == Cur_Parent_Menu_Id)
				{
					// Add a new Node for ProductGroup
					var Menu_Id = Menu_List[i].menu_id;
					var Menu_Link = Menu_List[i].menu_link;
					var Menu_Name = Menu_List[i].menu_name;
					var Menu_Icon_Name = Menu_List[i].menu_icon_name;
					var Menu_Parent_List = Cur_Parent_Menu_Id;
					var Menu_Parent_Name_List = Menu_Name;

					// Get Submenu for this menu
					var SubMenu_HTML = "";
					var AngleRight_HTML = "";

					var Output_Str = AddMenuTreeNode(Menu_Id, Menu_List, Menu_Parent_List, Menu_Parent_Name_List);


					if (Output_Str != "")
					{
						SubMenu_HTML = "<ul class=\"slide-menu\">" + Output_Str + "</ul>";
					}

					// Generate html for current menu
					if (SubMenu_HTML != "")
					{
						Menu_Link = "#";    // If the current menu has sub menu then the link will be only #
						AngleRight_HTML = "<i class=\"angle fa fa-angle-right\"></i>";
					}

					


					var Cur_Menu_HTML = "";

					if (Menu_Id == "M501")
					{
						Cur_Menu_HTML = "<li id=\"mnu" + Menu_Id + "\">";

						Cur_Menu_HTML += "<a class=\"side-menu__item\" href=\"" + Menu_Link + "\"  title=\"" + Menu_Name + "\" >";
						Cur_Menu_HTML += "<i class=\"side-menu__icon fe " + Menu_Icon_Name + "\"></i>";
						Cur_Menu_HTML += "<span class=\"side-menu__label\">" + Menu_Name + "</span>";
						Cur_Menu_HTML += AngleRight_HTML;
						Cur_Menu_HTML += "</a>";
					}
					else
					{

						Cur_Menu_HTML = "<li id=\"mnu" + Menu_Id + "\" class=\"slide\">";

						Cur_Menu_HTML += "<a class=\"side-menu__item\" data-toggle=\"slide\" href=\"" + Menu_Link + "\"  title=\"" + Menu_Name + "\" >";
						Cur_Menu_HTML += "<i class=\"side-menu__icon fe " + Menu_Icon_Name + "\"></i>";
						Cur_Menu_HTML += "<span class=\"side-menu__label\">" + Menu_Name + "</span>";
						Cur_Menu_HTML += AngleRight_HTML;
						Cur_Menu_HTML += "</a>";
					}

					Cur_Menu_HTML += SubMenu_HTML;  // Add submenu HTML

					Menu_HTML += Cur_Menu_HTML;

					// Close Activity Type
					Menu_HTML += "</li>";
				}
			};


			var Final_Menu_HTML = "<ul class=\"side-menu mt-3\">" + Menu_HTML + "</ul>";
			return Final_Menu_HTML;
		}

		private string AddMenuTreeNode(string Parent_Menu_Id, List<UserMenu> Menu_List, string Parent_List, string Parent_Name_List)
		{
			var Menu_HTML = "";

			for (var i = 0; i < Menu_List.Count; i++)
			{

				if (Menu_List[i].parent_menu_id == Parent_Menu_Id)
				{
					// Add a new Node for ProductGroup
					var Menu_Id = Menu_List[i].menu_id;
					var Menu_Link = Menu_List[i].menu_link;
					var Menu_Name = Menu_List[i].menu_name;
					var Menu_Icon_Name = Menu_List[i].menu_icon_name;
					var Menu_Parent_List = Parent_List + "," + Parent_Menu_Id;
					var Menu_Parent_Name_List = Parent_Name_List + "%:%" + Menu_Name;

					var SubMenu_HTML = "";


					var Tree_Ret_HTML = AddMenuTreeNode(Menu_Id, Menu_List, Menu_Parent_List, Menu_Parent_Name_List);

					if (Tree_Ret_HTML != "")
					{
						SubMenu_HTML = "<ul>" + Tree_Ret_HTML + "</ul>";
					}

					// Generate html for current menu
					if (SubMenu_HTML != "")
					{
						Menu_Link = "#";    // If the current menu has sub menu then the link will be only #
					}

					var Cur_Menu_HTML = "<li id=\"mnu" + Menu_Id + "\" >";
					Cur_Menu_HTML += "<a href=\"" + Menu_Link + "\" title=\"" + Menu_Name + "\" class=\"slide-item\" >";
					if (Menu_Icon_Name != null && Menu_Icon_Name != "")
					{
						Cur_Menu_HTML += "<i class=\"fe " + Menu_Icon_Name + "\"></i>";
					}

					Cur_Menu_HTML += Menu_Name;
					Cur_Menu_HTML += "</a>";
					Cur_Menu_HTML += SubMenu_HTML;

					Menu_HTML += Cur_Menu_HTML;

					// Close menu
					Menu_HTML += "</li>";

				}
			};

			return (Menu_HTML);
		}
	}
}
