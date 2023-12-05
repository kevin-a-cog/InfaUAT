/*
 * Name			:	GlobalZoomResponseWrapperClass
 * Author		:	Monserrat Pedroza
 * Created Date	: 	7/9/2021
 * Description	:	Response wrapper class for Zoom Integration.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		7/9/2021		N/A				Initial version.			N/A
 */
public with sharing class GlobalZoomResponseWrapperClass {

	//Authorization variables.
	@AuraEnabled
	public Integer expires_in {get; set;}
	@AuraEnabled
    public String access_token {get; set;}
	@AuraEnabled
	public String token_type {get; set;}
	@AuraEnabled
	public String refresh_token {get; set;}
	@AuraEnabled
	public String scope {get; set;}

	//Meeting variables.
	@AuraEnabled
	public Long id {get; set;}
	@AuraEnabled
	public String password {get; set;}
	@AuraEnabled
	public String h323_password {get; set;}
	@AuraEnabled
	public String join_url {get; set;}
	@AuraEnabled
	public String strDialNumbers {
		get {
			String strResult = '';
			String strNumber;
			List<String> lstNumbers;
			Map<String, List<String>> mapNumbers = new Map<String, List<String>>();
			if(settings != null && settings.global_dial_in_numbers != null && !settings.global_dial_in_numbers.isEmpty()) {

				//First we group by country.
				for(DialNumberWrapperClass objDialNumber : settings.global_dial_in_numbers) {
					if(mapNumbers.get(objDialNumber.country_name) == null) {
						mapNumbers.put(objDialNumber.country_name, new List<String>());
					}
					lstNumbers = mapNumbers.get(objDialNumber.country_name);
					strNumber = objDialNumber.strNumber;
					if(String.isNotBlank(objDialNumber.type) && objDialNumber.type == 'tollfree') {
						strNumber += ' (Toll Free)';
					}
					lstNumbers.add(strNumber);
					mapNumbers.put(objDialNumber.country_name, lstNumbers);
					
					//Now we set the one-tap numbers.
					if(objPrimaryPhone == null) {
						objPrimaryPhone = objDialNumber;
					} else if(objSecondaryPhone == null) {
						objSecondaryPhone = objDialNumber;
					}
				}

				//Now we create the string.
				for(String strCountry : mapNumbers.keySet()) {
					strResult += strCountry + ': ' + String.join(mapNumbers.get(strCountry), ' or ') + '<br />';
				}

				
			}
			return strResult;
		}
	}
	@AuraEnabled
	public DialNumberWrapperClass objPrimaryPhone {get; set;}
	@AuraEnabled
	public DialNumberWrapperClass objSecondaryPhone {get; set;}
	@AuraEnabled
	public SettingsWrapperClass settings {get; set;}

	/*
	 Method Name : SettingsWrapperClass
	 Description : Settings wrapper class.
	 Parameters	 : None
	 Return Type : None
	 */
	public class SettingsWrapperClass {

		//Public variables.
		@AuraEnabled
		public List<DialNumberWrapperClass> global_dial_in_numbers {get; set;}
	}

	/*
	 Method Name : DialNumberWrapperClass
	 Description : Dial Number wrapper class.
	 Parameters	 : None
	 Return Type : None
	 */
	public class DialNumberWrapperClass {

		//Public variables.
		@AuraEnabled
		public String country_name {get; set;}
		@AuraEnabled
		public String strNumber {get; set;}
		@AuraEnabled
		public String type {get; set;}
		@AuraEnabled
		public String strNumberNoSpaces {
			get {
				String strResult = '';
				if(String.isNotBlank(strNumber)) {
					strResult = strNumber.replace(' ', '');
				}
				return strResult;
			}
		}
	}
}