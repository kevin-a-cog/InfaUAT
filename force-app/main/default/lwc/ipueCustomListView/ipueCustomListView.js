import { LightningElement, track,api } from 'lwc';
import getDynamicTableDataList from '@salesforce/apex/IPUE_CustomListViewCntlr.getWrapperOfSObjectFieldColumnActionValues';
import communityBasePath from '@salesforce/community/basePath';

export default class IpueCustomListView extends LightningElement {
    @api listViewName;
    @api recordId;
    @api showRefresh;
    @track DataTableResponseWrappper;
    @track finalSObjectDataList=[];
    tableHeaderTextColor;
    tableHeaderBackgroundColor;
    basePath='';
    query;
    queryLimit;
    
    //offSetCount to send to apex to get the subsequent result. 0 in offSetCount signifies for the initial load of records on component load.
    offSetCount = 0;
    isFullyLoaded;
    loadMoreStatus;
    targetDatatable; // capture the loadmore event to fetch data and stop infinite loading
    //get data as soon as component loads.
    connectedCallback(){
        var baseCommunityPath=communityBasePath;
        if(baseCommunityPath){
            var pathArray=baseCommunityPath.split('/');
            if(pathArray[1]!='s'){
                this.basePath='/'+pathArray[1];
            }
        }
        this.getRecords(false);
    }
    //apply custom css styles.
    applyCssStyles(){
        var backColor = '#FF7D00' ;
        var textColor = 'white';
        document.styleSheets[0].insertRule(`.CustomCSS .slds-th__action{
            background:`+ this.tableHeaderBackgroundColor+`;color : `+this.tableHeaderTextColor+`;pointer-events: none;}`);
              
        document.styleSheets[0].insertRule(`.CustomCSS .slds-cell-fixed{
                color :`+ this.tableHeaderTextColor+`;}`);
        
    }
    //calls when component renders successfully
    renderedCallback(){
        this.applyCssStyles();
    }

    //fetch records from the server side based on metadata configuration.
    getRecords(loadMore){
        getDynamicTableDataList({metaDataName :this.listViewName,isLoadMore : loadMore, query : this.query,recordId:this.recordId})
            .then(result => {
            var data;
            var dataList=[];
            if(loadMore){
                data=this.DataTableResponseWrappper;
                dataList=result.dataList;
                if(dataList){
                    this.isFullyLoaded=true;
                }
            }else{
                data=result.DataTableWrapper;
                this.query=result.Query;
                dataList=data.lstDataTableData;
                this.queryLimit=data.queryLimit;
                this.tableHeaderTextColor=data.tableHeaderTextColor;
                this.tableHeaderBackgroundColor=data.tableHeaderBackgroundColor;
            }
            
            if(data) 
            {
                let sObjectRelatedFieldListValues = [];
                var hyperLinks={};
                
                for(let key in data.lstDataTableColumns){

                        if(data.lstDataTableColumns[key].type=='url' && data.lstDataTableColumns[key].typeAttributes 
                        && data.lstDataTableColumns[key].typeAttributes.label && data.lstDataTableColumns[key].typeAttributes.label.fieldName){

                            hyperLinks[ data.lstDataTableColumns[key].typeAttributes.label.fieldName]=data.lstDataTableColumns[key].fieldName;
                        
                        }
                }

                for (let row of dataList) 
                {
                        const finalSobjectRow = {}
                        let rowIndexes = Object.keys(row); 
                        rowIndexes.forEach((rowIndex) => 
                        {
                            const relatedFieldValue = row[rowIndex];
                            if(relatedFieldValue.constructor === Object)
                            {
                                var finKey=this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex,hyperLinks);                       
                            }
                            
                            else
                            {
                                if(hyperLinks[rowIndex]){
                                    
                                    finalSobjectRow[hyperLinks[rowIndex]]=this.basePath+'/'+row['Id'];
                                }
                                finalSobjectRow[rowIndex] = relatedFieldValue;
                            }
                            
                            
                        });
                
                        sObjectRelatedFieldListValues.push(finalSobjectRow);
                }
                if(!loadMore){
                    this.DataTableResponseWrappper = data;
                }
                console.log('data',this.DataTableResponseWrappper);
                this.finalSObjectDataList =[...this.finalSObjectDataList, ...sObjectRelatedFieldListValues]; 

                //Disable a spinner to signal that data has been loaded
                if (this.targetDatatable) this.targetDatatable.isLoading = false;
            }
            })
            .catch(error => {
                console.log('error',error);
            });

    }
    //helper method for showing parent object fields and show its as hyperlink.
   _flattenTransformation = (fieldValue, finalSobjectRow, fieldName,hyperLinks) => 
    {        
        let rowIndexes = Object.keys(fieldValue);
        let finalKey='';
        rowIndexes.forEach((key) => 
        {
            finalKey = fieldName + '.'+ key;
            if(hyperLinks[finalKey]){
                finalSobjectRow[hyperLinks[finalKey]]=this.basePath+'/'+fieldValue['Id'];
            }
            finalSobjectRow[finalKey] = fieldValue[key];
        })
        return finalKey;
    }

    // Event to handle onloadmore on lightning datatable markup
    handleLoadMore(event) {
        event.preventDefault();
        
        if(!this.isFullyLoaded){
            // increase the offset count by query limit on every loadmore event
            this.offSetCount = this.offSetCount + this.queryLimit;
            //checking if offset reached above its limit of 2000 then we wil stop load more.
            if( this.offSetCount>2000){
                this.isFullyLoaded=true;
                return;
            }
            this.query+=' OFFSET '+this.offSetCount;
            //Display a spinner to signal that data is being loaded
            event.target.isLoading = true;
            //Set the onloadmore event taraget to make it visible to imperative call response to apex.
            this.targetDatatable = event.target;
            this.getRecords(true);
        }

    }

    //refresh the data on UI.
    refreshData(){
        this.offSetCount=0;
        this.query='';
        this.finalSObjectDataList=[];
        this.isFullyLoaded=false;
        this.getRecords(false);
    }


    
}