/*
 * Name			:	globalCustomPlatformEvents
 * Author		:	Monserrat Pedroza
 * Created Date	: 	7/1/2022
 * Description	:	This LWC contains Custom Platform Events functions.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description					Tag
 **********************************************************************************************************
 Monserrat Pedroza		7/1/2022		N/A				Initial version.			N/A
 */

//Core imports.
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

//Apex Controllers.
import getObjectAPIName from "@salesforce/apex/GlobalCustomPlatformEventsController.getObjectAPIName";
import getWatchFields from "@salesforce/apex/GlobalCustomPlatformEventsController.getWatchFields";

//Utilities.
import { objUtilities } from 'c/globalUtilities';

//Messaging.
import { publish, subscribe, unsubscribe, createMessageContext, releaseMessageContext } from 'lightning/messageService';
import MESSAGING_CHANNEL from "@salesforce/messageChannel/CustomPlatformEvents__c";

/*
 Method Name : subscribeToRecord
 Description : This method subscribes to the custom platform events of the given record.
 Parameters	 : Object, called from subscribeToRecord, objConfiguration Subscription configuration.
 Return Type : Configuration object.
 */
const subscribeToRecord = (objConfiguration) => {

	//If we received minimum data.
	if(objUtilities.isNotNull(objConfiguration) && objUtilities.isNotBlank(objConfiguration.idRecord) && objUtilities.isNotBlank(objConfiguration.strRecordName)) {

		//We set the configuration variables.
		objConfiguration.idSubscriber = ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c => (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16));
		objConfiguration.objContext = createMessageContext();
	
		//We set the listener, if needed.
		objConfiguration.objListener = subscribe(objConfiguration.objContext, MESSAGING_CHANNEL, (objData) => {
			try {
		
				//If we received full data and the indication to refresh, we do it.
				if(objUtilities.isNotNull(objData) && objUtilities.isNotNull(objData.boolShouldRefresh) && objUtilities.isNotBlank(objData.idRecord) && objUtilities.isNotBlank(objData.idSubscriber) && 
						objData.boolShouldRefresh && objData.idRecord === objConfiguration.idRecord && objData.idSubscriber === objConfiguration.idSubscriber) {
					
					//We send the alert to the given method.
					if(objUtilities.isNotNull(objConfiguration.objParent) && objUtilities.isNotBlank(objConfiguration.strMethodName)) {
						objConfiguration.objParent[objConfiguration.strMethodName]();
					} else {

						//Or we just use the standard method.
						getRecordNotifyChange([{
							recordId: objData.idRecord
						}]);
					}
				}
			} catch(objException) {
				console.error(objException);
			}
		});
	
		//Now we send the subscription message.
		getObjectAPIName({
			idRecord: objConfiguration.idRecord
		}).then(strObjectAPIName => {
	
			//Now we get the fields.
			getWatchFields({
				strRecordName: objConfiguration.strRecordName
			}).then(lstFields => {
	
				//We start the subscription.
				publish(objConfiguration.objContext, MESSAGING_CHANNEL, {
					boolSubscribe: true,
					idRecord: objConfiguration.idRecord,
					idSubscriber: objConfiguration.idSubscriber,
					strObjectAPIName: strObjectAPIName,
					lstFields: lstFields
				});
			});
		}).catch((objError) => {
			console.log(objError);
		});
	}

	//We return the configuration properties.
	return objConfiguration;
}

/*
 Method Name : unsubscribeFromRecord
 Description : This method unsubscribes from the custom platform events of the given record.
 Parameters	 : Object, called from unsubscribeFromRecord, objConfiguration Configuration.
 Return Type : None
 */
const unsubscribeFromRecord = (objConfiguration) => {

	//If we received data.
	if(objUtilities.isNotNull(objConfiguration)) {

		//First, we unsubscribe from the Messaging Channel.
		if(objUtilities.isNotNull(objConfiguration.objListener)) {
			unsubscribe(objConfiguration.objListener);
		}
	
		//Now we send the unsubscription message.
		if(objUtilities.isNotNull(objConfiguration.objContext)) {
			publish(objConfiguration.objContext, MESSAGING_CHANNEL, {
				boolSubscribe: false,
				idRecord: objConfiguration.idRecord,
				idSubscriber: objConfiguration.idSubscriber
			});
	
			//Now we release the context.
			releaseMessageContext(objConfiguration.objContext);
		}
	}

	//Finally, we nullify the configuration.
	objConfiguration = null;
}

//Class body.
const objEvents = {
	subscribeToRecord: subscribeToRecord,
	unsubscribeFromRecord: unsubscribeFromRecord
}
export { objEvents };