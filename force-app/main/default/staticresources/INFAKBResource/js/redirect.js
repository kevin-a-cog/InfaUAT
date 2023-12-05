
let pagePath = window.location.pathname.toLowerCase();
if (pagePath.endsWith('/s') ||
    pagePath.endsWith('/s/')) {
    if (pagePath.endsWith('/s/')) {
        window.location = window.location.pathname + 'global-search/%20';
    }
    else if (pagePath.endsWith('/s')) {
        window.location = window.location.pathname + '/global-search/%20';
    }
    else {
        window.location = 'https://search.informatica.com';
    }
}