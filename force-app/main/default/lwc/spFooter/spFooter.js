import { LightningElement } from 'lwc';
import sp_resource from '@salesforce/resourceUrl/spResourceFiles';

export default class SpFooter extends LightningElement {
    appLogo = sp_resource + '/spResource/images/logo_informatica.svg';
    footerData = [
    {
        id: 1,
        footerItem: 'Terms of Use', 
        link: 'https://www.informatica.com/terms-of-use.html'
    },
    {
        id: 2,
        footerItem: 'Trademarks', 
        link: 'https://www.informatica.com/trademarks.html'
    },
    {
        id: 3,
        footerItem: 'Privacy Policy', 
        link: 'https://www.informatica.com/privacy-policy.html'
    },
    {
        id: 4,
        footerItem: 'Do not sell my personal information', 
        link: 'https://www.informatica.com/privacy-policy/personal-information.html'
    }];

    socialLinks = [
        {
            id: 1,
            link: "http://twitter.com/Informatica",
            src: "https://www.informatica.com/content/dam/informatica-com/en/images/gl01/footer-social-twitter.svg",
            alt: "footer-social-twitter.svg"
        },
        {
            id: 2,
            link: "https://www.facebook.com/InformaticaLLC",
            src: "https://www.informatica.com/content/dam/informatica-com/en/images/gl01/footer-social-facebook.svg",
            alt: "footer-social-facebook.svg"
        },
        {
            id: 3,
            link: "https://www.linkedin.com/company/informatica/",
            src: "https://www.informatica.com/content/dam/informatica-com/en/images/gl01/footer-social-linkedin.svg",
            alt: "footer-social-linkedin.svg"
        },
        {
            id: 4,
            link: "https://www.youtube.com/channel/UCvXtdT5kAsavz662XL7umvg",
            src: "https://www.informatica.com/content/dam/informatica-com/en/images/gl01/footer-social-youtube.svg",
            alt: "footer-social-youtube.svg"
        },
        {
            id: 5,
            link: "https://www.instagram.com/informaticacorp/",
            src: "https://www.informatica.com/content/dam/informatica-com/en/images/gl01/footer-social-instagram.svg",
            alt: "footer-social-instagram.svg"
        }
    ];


    renderedCallback(){
        this.template.querySelector('.infa-footer-year').innerHTML = new Date().getFullYear();
    }
}