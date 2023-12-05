import { LightningElement, track, api } from 'lwc';

const IS_ACTIVE = 'active';

export default class Pager extends LightningElement {
    @api pagedata = [];
    @api title = '';
    @track currentPageIndex = 1;
    @track maxNumberOfPages = 0;
    MAX_PAGES_TO_SHOW = 5;
    _pageRange = [];
    @api
    get currentlyShown() {
        const currentPage = this.MAX_PAGES_TO_SHOW * this.currentPageIndex;
        const pageStartRange =
            currentPage >= this.pagedata.length
                ? this.pagedata.length 
                : currentPage;
        console.log(currentPage,this.pagedata.length)
        return this.pagedata.slice(0, pageStartRange);
        
    }
    renderedCallback() {
        this.maxNumberOfPages = !!this.pagedata
            ? this.pagedata.length / this.MAX_PAGES_TO_SHOW
            : 0;
        this.currentShownPages =
            this.maxNumberOfPages <= this.MAX_PAGES_TO_SHOW
                ? this.maxNumberOfPages
                : this.MAX_PAGES_TO_SHOW;
        this.dispatchEvent(new CustomEvent('pagerchanged'));
    }
    
    handleNext() {
        this.currentPageIndex =
            this.currentPageIndex < this.maxNumberOfPages
                ? this.currentPageIndex + 1
                : this.maxNumberOfPages;
        console.log("currentPageIndex"+this.currentPageIndex);
        this.dispatchEvent(new CustomEvent('pagerchanged'));
    }
}