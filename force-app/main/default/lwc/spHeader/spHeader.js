import { LightningElement, track } from 'lwc';
import sp_resource from '@salesforce/resourceUrl/spResourceFiles';

export default class spHeader extends LightningElement {
    appLogo = sp_resource + '/spResource/images/logo_informatica.svg';
    download = sp_resource + '/spResource/icons/down_arrow.svg';
    @track cssSearchClass = "infa-navbar-search-form-wrapper";
    @track cssNavListClass = "collapse navbar-collapse";
    @track cssHamburgerClass = "navbar-toggler-icon hamburgermenu";
    @track stickyClass = "container infa-sticky-header";
    @track showSpinner = true;
    @track navBarData;
    searchIconClicked;
    closeIconClicked;
    hamburgerIconClicked;

    connectedCallback(){
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
                        link: 'https://network.informatica.com/welcome',
                        description: 'You can view open cases and add case updates.',
                        target: ''
                    },
                    {
                        image: true,
                        title: 'Manage Support Account',
                        link: 'https://network.informatica.com/welcome',
                        description: 'You can view Support Account details and related contacts.',
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

    // renderedCallback(){
    //     console.log('Header Rendered');
    //     this.showSpinner = false;
    //     try {
    //         window.onscroll = () => {
    //             let stickysection = this.template.querySelector('.navbar-bg');
    //             let sticky2 = stickysection.offsetTop;
    //             if (window.pageYOffset > sticky2 & stickysection != null) {
    //                 stickysection.classList.add("infa-h-sticky");
    //             } else {
    //                 stickysection.classList.remove("infa-h-sticky");
    //             }
    //         }
    //     } catch (error) {
    //         console.log('error =>', error);
    //     }
    // }
    get getSearchIcon() {
        return 'background-image: url(' + sp_resource +'/spResource/icons/search.svg)';
    }
    get getDotsImage() {
        return 'background-image: url(' + sp_resource +'/spResource/images/header_menu_dots.png)';
    }
    handleSearchInput(event){
        this.searchText = event.target.value;
    }

    handleSearchToggleClick(){
        this.searchIconClicked = !this.searchIconClicked;
        this.cssSearchClass = this.searchIconClicked ? "infa-navbar-search-form-wrapper infa-block" : "infa-navbar-search-form-wrapper infa-hide";
    }

    handleCloseToggleClick(){
        this.closeIconClicked = !this.closeIconClicked;
        this.cssSearchClass = this.closeIconClicked ? "infa-navbar-search-form-wrapper infa-hide" : "infa-navbar-search-form-wrapper infa-block";
        this.searchIconClicked = !this.searchIconClicked;
        this.closeIconClicked = !this.closeIconClicked;
    }

    handleHamburgerClick(){
        this.handleHamburgerClick = !this.handleHamburgerClick;
        this.cssNavListClass = this.handleHamburgerClick ? "collapse navbar-collapse infa-hide" : "collapse navbar-collapse infa-block";
        this.cssHamburgerClass = this.handleHamburgerClick ? "navbar-toggler-icon hamburgermenu" : "navbar-toggler-icon infa-navbar-close-icon";
    }
    
    openDashboard(){
        window.open("www.google.com", '_self');
    }

    doLogout(){
        window.location.replace("www.google.com");
    }
}