/*
Trigger:        PanoptaUserResponseWrapper
@Author:        Venky K
@Created Date:  18 April 2021
@Description:   Get User Details Response Wrapper for Panopta


************************************************************************************************************************************
ModifiedBy        Date         JIRA NO     Requested By        Description                                  Tag
************************************************************************************************************************************
*/

public class PanoptaUserResponseWrapper{
    
	public cls_meta meta;
	public List<userlist> user_list;
    
	public class cls_meta {
		public Integer limit_x;	// limit is replaced with limit_x. If this is needed in future, replace limit with limit__c
		public cls_next next;
		public Integer offset;	
		public cls_previous previous;
		public Integer total_count;	
	}
    
	public class cls_next {
	}
    
	public class cls_previous {
	}
    
	public class userlist {
		public boolean allow_non_sso_login;
		public String avatar_url;	
		public cls_contact_info[] contact_info;
		public String created;	
		public cls_default_dashboard default_dashboard;
		public String display_name;	
		public boolean is_external_user;
		public String[] roles;
		public String server_group_access;	
		public cls_tags[] tags;
		public String timezone;	
		public String url;	
		public String username;	
	}
	Public class cls_contact_info {
		public String detail;	
		public cls_extra_data extra_data;
		public String info;	
		public String label;	
		public String name;	
		public String type;	
		public String url;	
	}
	class cls_extra_data {
	}
	class cls_default_dashboard {
	}
	
	class cls_tags {
	}
	public static PanoptaUserResponseWrapper parse(String json){
		return (PanoptaUserResponseWrapper) System.JSON.deserialize(json, PanoptaUserResponseWrapper.class);
	}

    /* Sample response below 
	static testMethod void testParse() {
		String json=		'{'+
		'  "meta": {'+
		'    "limit": 1,'+
		'    "next": null,'+
		'    "offset": 0,'+
		'    "previous": null,'+
		'    "total_count": 1'+
		'  },'+
		'  "user_list": ['+
		'    {'+
		'      "allow_non_sso_login": false,'+
		'      "avatar_url": "https://secure.gravatar.com/avatar/dc20da8ef8306cb9f374457bea9de844.jpg?d=mm",'+
		'      "contact_info": ['+
		'        {'+
		'          "detail": "vkotapati@informatica.com",'+
		'          "extra_data": null,'+
		'          "info": "vkotapati@informatica.com",'+
		'          "label": "Venkatesh Kotapati Email",'+
		'          "name": "Venkatesh Kotapati",'+
		'          "type": "https://api2.panopta.com/v2/contact_type/61",'+
		'          "url": "https://api2.panopta.com/v2/contact/334742/contact_info/386642"'+
		'        }'+
		'      ],'+
		'      "created": "Fri, 19 Feb 2021 04:19:34 -0000",'+
		'      "default_dashboard": null,'+
		'      "display_name": "Venkatesh Kotapati",'+
		'      "is_external_user": true,'+
		'      "roles": ['+
		'        "https://api2.panopta.com/v2/role/7",'+
		'        "https://api2.panopta.com/v2/role/352",'+
		'        "https://api2.panopta.com/v2/role/210",'+
		'        "https://api2.panopta.com/v2/role/279",'+
		'        "https://api2.panopta.com/v2/role/281",'+
		'        "https://api2.panopta.com/v2/role/207"'+
		'      ],'+
		'      "server_group_access": "all",'+
		'      "tags": [],'+
		'      "timezone": "https://api2.panopta.com/v2/timezone/America/Chicago",'+
		'      "url": "https://api2.panopta.com/v2/user/196228",'+
		'      "username": "115763"'+
		'    }'+
		'  ]'+
		'}';
		fromJSON obj = parse(json);
		System.assert(obj != null);
	}*/
}