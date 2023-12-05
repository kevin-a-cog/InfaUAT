/*
 * Name			    :	HelpPagination
 * Author		    :	Chetan Shetty
 * Created Date	    :   25-10-2023
 * Description	    :	Common Re-Usable component created for pagination (I2RT-9228)
 
 Change History
 *******************************************************************************************************************************
 Modified By		            Date			     Jira No.		       Description			   Tag
 *******************************************************************************************************************************
 Prashanth Bhat             26-10-2023     I2RT-9228         Pagination          Initial Version
 */
import { LightningElement, api,wire,track } from 'lwc';
import getmetadatarecords from '@salesforce/apex/helpChangeRequestController.getmetadatarecords';
import CommunityURL from '@salesforce/label/c.IN_CommunityName';

export default class HelpPagination extends LightningElement {
    @api currentPage;
    @api totalPages;
    displayRange = 5;
    pagenumbers = [];
    @track searchResultUrl; 
    isChangeRequest = false; 

    @wire(getmetadatarecords)
    getMetadataRecord(result) {
        if (result.data) {
            this.searchResultUrl = result.data.SearchResultURL__c;
        } else if (result.error) {
            console.error('error ---> ', result.error);
        }
    }

    connectedCallback() {
        this.paginationButtons();
        var currentURL = window.location.href;
        if (currentURL.includes('change-request')) {
          this.isChangeRequest = true;
        }
    }

    //Method to access and modify DOM elements
    renderedCallback(){
        this.hideNextPrevButtons();
    }

    // Method to handle the page buttons for pagination
    paginationButtons() {
        let startPage;
        const halfRange = Math.floor(this.displayRange / 2);
        startPage = Math.max(1, this.currentPage - halfRange);
        let endPage = Math.min(this.totalPages, startPage + this.displayRange - 1);
        if (endPage <= this.displayRange) {
            startPage = 1;
        }

        // Ensure that the display range has a fixed size of 5 buttons
        if(this.totalPages > this.displayRange) {
          while (endPage - startPage + 1 < this.displayRange) {
            if (startPage > 1) {
                startPage--;
            } else {
                endPage++;
            }
          }
        }

        let pages = [];
        for (let pageNumber = startPage; pageNumber <= endPage; pageNumber++) {
            pages.push({
                number: pageNumber,
                isActive: this.currentPage == pageNumber ? 'in-pager-list-item active' : 'in-pager-list-item',
            });
        }
        this.pagenumbers = pages;
    }

    //Method to hide next/prev button based on current page
     hideNextPrevButtons() {
         const prevButton = this.template.querySelector(".in-pager-previous");
         const nextButton = this.template.querySelector(".in-pager-next");
         prevButton.style.display = this.currentPage == 1 ? "none" : "inline-block";
         if(!this.isChangeRequest){
            nextButton.style.display = this.currentPage == this.totalPages ? "none" : "inline-block";  
         }            
     }

     redirectToCRSearch(){
           window.open(CommunityURL + this.searchResultUrl, '_blank'); 
     }

     //Method to handle the pagination onclick of previous arrow
     previousPage(){
        if (this.currentPage > 1) {
            this.currentPage--;
            const customEvent = new CustomEvent('sendcurrentpage', 
            { 
              detail: this.currentPage 
            });
            this.dispatchEvent(customEvent);
            this.paginationButtons();
        }
     }

     //Method to handle the pagination onclick of next arrow
     nextPage(){
        if(this.isChangeRequest && this.currentPage == this.totalPages){
            this.redirectToCRSearch();
        }
        else if (this.currentPage < this.totalPages) {
            this.currentPage++;
            const customEvent = new CustomEvent('sendcurrentpage',  
              { 
                detail: this.currentPage 
              });
            this.dispatchEvent(customEvent);
            this.paginationButtons();
         }
     }

     //Method to handle the pagination onclick of specific pages
     onPageRequest(event){                                         
        this.currentPage = event.target.getAttribute('data-id');
        this.paginationButtons();
        const customEvent = new CustomEvent('sendcurrentpage', 
           { 
            detail: this.currentPage 
           });
        this.dispatchEvent(customEvent);
     }
     
     //Method declared public to be called from parent to pass the latest totalpages value for any dynamic changes
     @api
     syncTotalPageOnChange(totalPages){    
           this.currentPage = 1;           
           this.totalPages  = totalPages;
           this.paginationButtons();
     }
}