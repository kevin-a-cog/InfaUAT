/**
 * An apex page controller that gets url parameter for vf page updateAddressIcrt
 */
public class addressICRTControllerExtension {
    public String AddressType{get;set;}
    public String objectName{get;set;}
    Public String GuideName{get;set;}
    public Id objectId{get;set;}
    public addressICRTControllerExtension() {
        this.AddressType = System.currentPagereference().getParameters().get('addresstype');
        this.objectName = System.currentPagereference().getParameters().get('objectname');
        this.objectId = Id.valueOf(System.currentPagereference().getParameters().get('objectid'));
        if(this.objectName == 'SBQQ__Quote__c'){
            switch on AddressType {
                when 'billing' {
                    this.GuideName = 'BillToAddressCleanse';
                }
                when 'shipping' {
                    this.GuideName = 'ShipToAddressCleanse';
                }
                when 'soldto' {
                    this.GuideName = 'SoldToAddressCleanse';
                }
                when 'enduser' {
                    this.GuideName = 'EndToAddressCleanse';
                }
                when else {
                    this.GuideName = '';
                }
        	}
        } else if(this.objectName == 'Order'){
            switch on AddressType {
                when 'billing' {
                    this.GuideName = 'BillToAddressCleanseOrder';
                }
                when 'shipping' {
                    this.GuideName = 'ShipToAddressCleanseOrder';
                }
                when 'soldto' {
                    this.GuideName = 'SoldToAddressCleanseOrder';
                }
                when 'enduser' {
                    this.GuideName = 'EndToAddressCleanseOrder';
                }
                when else {
                    this.GuideName = '';
                }
        	}
        }
        
    }
}