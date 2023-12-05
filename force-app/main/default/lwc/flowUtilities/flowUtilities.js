/*
 * Name			:	FlowUtilities
 * Author		:	Vignesh Divakaran
 * Created Date	: 	7/26/2023
 * Description	:	This LWC contains utility objects to be used in screen flow.

 Change History
 **********************************************************************************************************
 Modified By			Date			Jira No.		Description										Tag
 **********************************************************************************************************
 Vignesh Divakaran		7/26/2023		I2RT-8640		Initial version.								N/A
 */

import {
    FlowNavigationBackEvent,
    FlowNavigationNextEvent,
    FlowNavigationFinishEvent,
    FlowAttributeChangeEvent
} from 'lightning/flowSupport';

//Flow navigation controls
const screenFlow = {
    back: (objParent) => objParent.dispatchEvent(new FlowNavigationBackEvent()),
    next: (objParent) => objParent.dispatchEvent(new FlowNavigationNextEvent()),
    close: (objParent) => objParent.dispatchEvent(new FlowNavigationFinishEvent()),
    refreshProperty: (strPropertyName, value, objParent) => objParent.dispatchEvent(new FlowAttributeChangeEvent(strPropertyName, value))
}

export { screenFlow };