/*
Change History
****************************************************************************************************
ModifiedBy      Date        Jira No.    Tag     Description
****************************************************************************************************
Isha Bansal     30/06/2023  I2RT-8234   T01    Replaced standard recordEditForm 
                                               with c-global-lookup for reference data type  
*/
import { LightningElement, api, track } from 'lwc';



export default class InputFieldDynamic extends LightningElement {

    lookupFieldLoaded = false;

    @api item;
    @track title;
    @track subtitle;
    @track defaultvalue;
    @track booleanOptions=[
        {label:'true',value:'true'},
        {label:'false',value:'false'}
    ];

    get showSpinner(){
        return  false;// T01 this.item.fieldType === 'REFERENCE'&& !this.lookupFieldLoaded; 
    }

    get showPicklist(){
        return this.item.fieldType ==='PICKLIST' || this.item.fieldType==='MULTIPICKLIST';
    }
get placeholder(){
    if( this.item.fieldType === 'REFERENCE' ){
       
        return 'Search '+this.item.lookupRefObjectName +'s...';
    }
}
    get showBoolean(){
        return this.item.fieldType === 'BOOLEAN';
    }

    get showLookup(){
        
        if( this.item.fieldType === 'REFERENCE' ){ //T01  
            var lookupFields=this.item.lookupFields?this.item.lookupFields:'';            
            if (!lookupFields || lookupFields.length === 0) {                
                this.title='Name';//default field is 'name'
                this.subtitle=''; console.log("The lookupFieldsing is null or empty.");
            } else if (!lookupFields.includes(',')) {
                this.title=this.item.lookupFields?this.item.lookupFields:'';  //T01  No commas found in the lookupFieldsing                
                this.subtitle='';
            } else { //comma present
                const fieldArr = lookupFields.split(',');
                if(fieldArr.length<2){
                    //The array does not have at least two elements. has just one element but with comma.
                    this.title=this.item.lookupFields?this.item.lookupFields:'';  //T01  No commas found in the lookupFieldsing                
                    this.subtitle='';
                }else{
                    const[title,subtitle]=fieldArr;                    
                    this.title=title;  //T01     
                    this.subtitle=subtitle; //T01 
                }
            }       
        }       
       return this.item.fieldType === 'REFERENCE';
    }


    get showText(){
        var nonTextTypes = ['PICKLIST', 'MULTIPICKLIST', 'REFERENCE', 'BOOLEAN'];
        return !nonTextTypes.includes(this.item.fieldType);
    }

    renderedCallback(){
        console.log('inputFieldDynamic, renderedCallback...')
        
    }

    handleLoad(event){
        this.lookupFieldLoaded = true;
    }

    sendValues(itemValue){
        this.dispatchEvent(new CustomEvent("valuechange", {
            detail: itemValue
        }));
    }
   handlecustomLookupChange(event){//T01
        var lookupValue = event.detail; 
        this.sendValues(lookupValue);
        //below is to handle when user changes the field type of existing row.
        this.template.querySelectorAll('lightning-input').forEach(text => {   
            if(text.name ==='textValue' && (text.accessKey).toString() === fkey.toString()){
                text.value = lookupValue ;
                console.log('value >> '+ text.value);
            }
        }); 
    }
   
    handlePicklistValueChange (event){
        var selectedPicklistVal = [];
        selectedPicklistVal = event.detail;
        console.log('selectedPicklistVal >> '+ selectedPicklistVal);

        var fkey = event.target.accessKey;
        console.log('fkey >> '+ fkey);
        
        var tempStr = '';
        selectedPicklistVal.forEach(pValue => {
            tempStr += pValue+',';
        });
        tempStr = tempStr.substring(0, tempStr.length - 1); //Remove the last Comma
        this.sendValues(tempStr);
        console.log('this.item >> '+ JSON.stringify(this.item));
    }
    
    handleBooleanValueChange (event){
        console.log('event.detail >>> '+ JSON.stringify(event.detail));
        var selectedBoolean = event.target.value;
        console.log('selectedBoolean >>> '+ selectedBoolean);

        var fkey = event.target.accessKey;
        console.log('fkey >> '+ fkey);
        
        this.sendValues(selectedBoolean);
        console.log('this.item >> '+ JSON.stringify(this.item));
    }

    handleValueChange(event){
        var fkey = event.target.accessKey; 

        var value = ''
        if(event.target.value !== undefined){
            value = event.target.value;
        }
        this.sendValues(value);
        console.log('this.item >>> '+ JSON.stringify(this.item));    
    }
    
}