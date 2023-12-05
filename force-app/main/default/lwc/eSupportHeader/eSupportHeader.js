import { LightningElement, track, wire } from 'lwc';
import ESUPPORT_RESOURCE from '@salesforce/resourceUrl/eSupportRrc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
import NAME_FIELD from '@salesforce/schema/User.Name';
import CommunityURL from '@salesforce/label/c.eSupport_Community_URL';            //Amarender -> I2RT-1020: eSupport: Solutions Page
import isGuestUser from '@salesforce/user/isGuest';
import eSupportLoginURL from '@salesforce/label/c.eSupport_Login_URL';          
import profileUrl from '@salesforce/label/c.profileUrl';          
import eSupportLogoutUrl from '@salesforce/label/c.eSupportLogoutUrl';  

export default class ESupportHeader extends LightningElement {
    appLogo = ESUPPORT_RESOURCE + '/eSupportLogo.png';
    userProfile = ESUPPORT_RESOURCE + '/user_profile.svg';
    download = ESUPPORT_RESOURCE + '/down_arrow.svg';
    @track cssSearchClass = "es-navbar-search-form-wrapper";
    @track cssNavListClass = "collapse navbar-collapse";
    @track cssHamburgerClass = "navbar-toggler-icon hamburgermenu";
    @track stickyClass = "container es-app-header";
    searchIconClicked;
    closeIconClicked;
    hamburgerIconClicked;
    firstName;
    profileUrl;
    @track searchField;
    @track userName;
    @track communityName;
    @track navBarData;
    @track showSpinner = true;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.userName = data.fields.Name.value;
            this.firstName = this.userName.split(" ")[0];
            console.log("FIrstName"+this.firstName);
            console.log("USERID  "+USER_ID);
        }
    }

    connectedCallback(){
        if(isGuestUser){
            let refferURL = window.location.href;
            let loginLink = eSupportLoginURL + "?RelayState=" + encodeURIComponent(refferURL);
            window.location.assign(loginLink);
        }else{
            document.addEventListener('readystatechange', event => {
                console.log('readyState >> '+event.target.readyState);
                if (event.target.readyState === 'loading') {
                    //this.showSpinner = true;
                    document.body.setAttribute('style', 'overflow: hidden;');
                }
                else if (event.target.readyState === 'complete') {
                    //this.showSpinner = false;
                    document.body.removeAttribute('style', 'overflow: hidden;');
                }
                
                /*if (event.target.readyState === 'complete') {
                    this.showSpinner = false;
                    document.body.removeAttribute('style', 'overflow: hidden;');
                }
                else{
                    this.showSpinner = true;
                    document.body.setAttribute('style', 'overflow: hidden;');
                }*/
            });
            if (document.location.pathname.indexOf("global-search") > -1)
            {
                //this.showSpinner = false;
                document.body.removeAttribute('style', 'overflow: hidden;');
            }
            this.profileUrl = profileUrl;

            this.navBarData = [
                {
                    id: 1,
                    navBarItem: 'Support',
                    link: '#',
                    multiLevel: true,
                    level2: [
                        {
                            image: true,
                            title: 'Manage Cases',
                            link: CommunityURL + 'caselist',
                            description: 'You can view open cases and add case updates.',
                            target: ''
                        },
                        {
                            image: true,
                            title: 'Manage Support Account',
                            link: CommunityURL + 'supportaccountdetails',
                            description: 'You can view Support Account details and related contacts.',
                            target: ''
                        },
                        {
                            image: true,
                            title: 'Customer Portfolio Report',
                            link: CommunityURL + 'communitydashboard',
                            description: 'You can view Dashboards and related reports here.',
                            target: ''
                        }
                    ]
                },
                {
                    id: 2,
                    navBarItem: 'Self Service',
                    link: '#',
                    multiLevel: true,
                    level2: [
                        {
                            image: false,
                            title: 'Informatica Network',
                            link: 'https://network.informatica.com/welcome',
                            description: 'Engage, collaborate, and empower with a personalized touch on our Support Portal.',
                            target: '_blank'
                        },
                        {
                            image: false,
                            title: 'Knowledge Base',
                            link: 'https://search.informatica.com/KBHome',
                            description: 'Search for articles on known technical issues, Whitepapers, FAQs, HOW TOs, videos and much more.',
                            target: '_blank'
                        },
                        {
                            image: false,
                            title: 'Documentation Portal',
                            link: 'https://docs.informatica.com/search.html#sort=relevancy',
                            description: 'Access all Informatica product documentation from the Web.',
                            target: '_blank'
                        }
                    ]
                },
                {
                    id: 3,
                    navBarItem: 'Success',
                    link: '#',
                    multiLevel: true,
                    level2: [
                        {
                            image: false,
                            title: 'Product Learning Paths',
                            link: 'https://success.informatica.com/learning-path.html',
                            description: 'Featuring Cloud, Enterprise Data Catalog, Big Data Management, and Axon Data Governance learning opportunities in a browser near you.',
                            target: '_blank'
                        },
                        {
                            image: false,
                            title: 'Tech Tuesday Webinars',
                            link: 'https://success.informatica.com/explore/tt-webinars.html',
                            description: 'Webinar workshop series about how to leverage and implement Informatica Products and Solutions',
                            target: '_blank'
                        },
                        {
                            image: false,
                            title: 'Trainings',
                            link: 'https://www.informatica.com/services-and-training/informatica-university.html',
                            description: 'Role-based training programs ensure your organization gets the most out of its investment in Informatica products.',
                            target: '_blank'
                        }
                    ]
                }
            ];
        }
        //this.showSpinner = false;
    }

    renderedCallback() {
        this.showSpinner = false;
        try {
            window.onscroll = () => {
                let stickysection = this.template.querySelector('.navbar-bg');
                let sticky2 = stickysection.offsetTop;
                if (window.pageYOffset > sticky2 & stickysection != null) {
                    stickysection.classList.add("infa-h-sticky");
                } else {
                    stickysection.classList.remove("infa-h-sticky");
                }
            }
        } catch (error) {
            console.log('error =>', error);
        }
    }

    handleSearchInput(event) {
        this.searchText = event.target.value;
    }

    handleSearchToggleClick() {
        this.searchIconClicked = !this.searchIconClicked;
        this.cssSearchClass = this.searchIconClicked ? "es-navbar-search-form-wrapper es-block" : "es-navbar-search-form-wrapper es-hide";
    }

    eSupportSearch(component) {
        console.log("Event1 Triggered");
        if (component.which == 13){
            /** START-- adobe analytics */
            try {
                util.trackGlobalSearch();
            }
            catch(ex) {
                console.log(ex.message);
            }
            /** END-- adobe analytics*/
            window.location.assign("global-search/" + this.searchText);
        }
    }
    handleCloseToggleClick() {
        this.closeIconClicked = !this.closeIconClicked;
        this.cssSearchClass = this.closeIconClicked ? "es-navbar-search-form-wrapper es-hide" : "es-navbar-search-form-wrapper es-block";
        this.searchIconClicked = !this.searchIconClicked;
        this.closeIconClicked = !this.closeIconClicked;
    }

    handleHamburgerClick() {
        this.handleHamburgerClick = !this.handleHamburgerClick;
        this.cssNavListClass = this.handleHamburgerClick ? "collapse navbar-collapse es-hide" : "collapse navbar-collapse es-block";
        this.cssHamburgerClass = this.handleHamburgerClick ? "navbar-toggler-icon hamburgermenu" : "navbar-toggler-icon es-navbar-close-icon";
    }

    get getSearchIcon() {
        return 'background-image: url(' + ESUPPORT_RESOURCE +'/searchIcon.svg)';
    }
    get getDotsImage() {
        return 'background-image: url(' + ESUPPORT_RESOURCE +'/header-dots.png)';
    }
    
    openDashboard(){
        window.open(CommunityURL, '_self');
    }

    doLogout(){
        window.location.replace(eSupportLogoutUrl);
    }
}