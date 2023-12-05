try {

    console.log("CoveoNewGenIPX.js static resource 1");
    "use strict";
    console.log("CoveoNewGenIPX.js static resource 2");

    const CoveoIPX = {
        initialize: (token) => {
            const addCoveoThemeLink = () => {
                const coveoThemeLink = document.createElement('link');
                coveoThemeLink.rel = "stylesheet";
                coveoThemeLink.href = "https://static.cloud.coveo.com/atomic/v2.30/themes/coveo.css";
                document.head.appendChild(coveoThemeLink);
            };
        
            const addAtomic = () => {
                const script = document.createElement('script');
                script.type = "module";
                script.src = "https://static.cloud.coveo.com/atomic/v2.30/atomic.esm.js";
                document.head.appendChild(script);
            };
    addAtomic();
    addCoveoThemeLink();
    const ATOMIC_SEARCH_INTERFACE = 'atomic-search-interface';
	const ATOMIC_RECS_INTERFACE = 'atomic-recs-interface';
	const IPX_CONTAINER_TAG = 'coveo-ipx';

    const setContext = async (engine, config) => {
        
        const action = loadContextActions(engine).setContext({
            IPX: true,
            referrer: window.location.href,
            IPX_ID: config.interfaceId,
            IPX_Name: config.interfaceName
          });
          return engine.dispatch(action);
    };

    const initializeAtomicInterface = async (currentInterface, isRecommendations, config, apiKey) => {
        const commonConfig = {
          accessToken: apiKey,
          organizationId: config.organization,
          organizationEndpoints: await currentInterface.getOrganizationEndpoints(config.organization, config.environment),
          analytics: {
            originContext: 'nextgenipx',
            originLevel3: window.location.href,
          },
        };
        const searchHubSetting = { searchHub: config.searchHub };
        isRecommendations
          ? await currentInterface.initialize({ commonConfig, searchHubSetting })
          : await currentInterface.initialize({ ...commonConfig, ...{ search: searchHubSetting } });
        return setContext(currentInterface.engine, config);
      };

      const loadRecommendations = (interfaceId) => {
        const recsInterface = document
          .querySelector(`#coveo-ipx-${interfaceId}`)
          .shadowRoot.getElementById(`ipx-recs-${interfaceId}`);
        recsInterface.getRecommendations();
        if (this.onclick) {
          this.onclick = null;
        }
      };

      const initializeIPX = async (ipxContainerShadowRoot, config, apiKey) => {
        await customElements.whenDefined(ATOMIC_SEARCH_INTERFACE);
        const searchInterface = ipxContainerShadowRoot.getElementById('ipx-search-${config.interfaceId}');
        await initializeAtomicInterface(searchInterface, false, config, apiKey);
      
        searchInterface.i18n.addResourceBundle('en', 'caption-filetype', {
          '.html': 'html',
        });
      
        await customElements.whenDefined(ATOMIC_RECS_INTERFACE);
        const recsInterface = ipxContainerShadowRoot.getElementById('ipx-recs-${config.interfaceId}');
        await initializeAtomicInterface(recsInterface, true, config, apiKey);
      
        const ipxButton = searchInterface.querySelector('atomic-ipx-button')?.shadowRoot?.querySelector('button');
        if (ipxButton) {
          ipxButton.setAttribute('onclick', "(${loadRecommendations.toString()})('${config.interfaceId}')");
        } else {
          loadRecommendations(config.interfaceId);
        }
      };

      const insertIPXInTargetElement = (targetElement, usesTargetSelector, interfaceId, atomicBody) => {
        const ipxContainer = document.createElement(IPX_CONTAINER_TAG);
        ipxContainer.setAttribute('id', '${IPX_CONTAINER_TAG}-${interfaceId}');
        usesTargetSelector && ipxContainer.setAttribute('style', 'display: block; height: inherit; width: inherit;');
      
        const shadowRoot = ipxContainer.attachShadow({ mode: 'open' });
        shadowRoot.innerHTML = atomicBody;
      
        targetElement.appendChild(ipxContainer);
        return shadowRoot;
      };

      const watchForTargetElementDeletion = (apiKey, config) => {
        const deletionObserver = new MutationObserver(() => {
          if (!document.querySelector(config.targetSelector)) {
            deletionObserver.disconnect();
            loadIPX(apiKey, config);
          }
        });
        deletionObserver.observe(document.body, { childList: true, subtree: true });
      };

      const targetHostElement = (targetSelector) =>
  new Promise((resolve) => {
    let targetElement = document.querySelector(targetSelector);
    if (targetElement) {
      return resolve(targetElement);
    }
    const hostObserver = new MutationObserver(() => {
      targetElement = document.querySelector(targetSelector);
      if (!targetElement) {
        return;
      }
      hostObserver.disconnect();
      resolve(targetElement);
    });
    hostObserver.observe(document.body, { childList: true, subtree: true });
  });

  const retrieveTarget = (usesTargetSelector, targetSelector) =>
  usesTargetSelector ? targetHostElement(targetSelector) : Promise.resolve(document.body);

const loadIPX = (apiKey, config) => {
  const { usesTargetSelector, targetSelector, interfaceId, atomicBody } = config;
  return retrieveTarget(usesTargetSelector, targetSelector).then((target) => {
    const ipxShadowRoot = insertIPXInTargetElement(target, usesTargetSelector, interfaceId, atomicBody);
    usesTargetSelector && watchForTargetElementDeletion(apiKey, config);
    return initializeIPX(ipxShadowRoot, config, apiKey);
  });
};

const waitForPageInitialization = () =>
new Promise((resolve) => {
  if (document.body) {
    return resolve();
  }
  const bodyObserver = new MutationObserver(() => {
    bodyObserver.disconnect();
    resolve();
  });
  bodyObserver.observe(document.documentElement, { childList: true });
});

const initialize = (apiKey, config) => {
    return waitForPageInitialization().then(() => loadIPX(apiKey, config));
  };

  return initialize(token, {
    usesTargetSelector: false,
    targetSelector: '',
    interfaceId: '2308db1b-8a1d-441e-8036-da3052fed1ff',
    searchHub: 'ECPlanHub',
    organization: 'informaticasandbox',
    platformUrl: '',
    interfaceName: 'ECPlanHub',
    environment: '',
    atomicBody: `<style>
:root, :host {
--atomic-primary: #1372ec;
--atomic-primary-light: #1ba2ff;
--atomic-primary-dark: #0d4fa5;
--atomic-ring-primary: #1372ec80;
--atomic-background: #ffffff;
--atomic-on-background: #282829;
--atomic-neutral: #e5e8e8;
--atomic-neutral-light: #f3f6f6;
--atomic-neutral-dark: #4e4f4f;
--atomic-visited: #752e9c;
--atomic-ipx-button: #1372ec;
--atomic-ipx-button-light: #1ba2ff;
--atomic-ipx-button-label: #ffffff;
--atomic-font-family: -apple-system, BlinkMacSystemFont, avenir next, avenir, segoe ui, helvetica neue, helvetica, Ubuntu, roboto, noto, arial, sans-serif;
}

.search-section {
width: 100%;
display: flex;
flex-wrap: wrap;
grid-gap: 0.5rem;
background: var(--atomic-neutral-light);
box-sizing: border-box;
min-width: 0;
}

.search-box {
flex-grow: 1;
padding-bottom: 0.875rem;
}

.query-summary {
padding-bottom: 1rem;
}

atomic-did-you-mean, atomic-notifications, atomic-smart-snippet, atomic-smart-snippet-suggestions {
padding-bottom: 1rem;
}

atomic-smart-snippet::part(source-url), atomic-smart-snippet-suggestions::part(source-url) {
word-wrap: break-word;
}

.pagination-more-results {
padding-top: 0.875rem;
}

.footer-slot {
display: flex;
justify-content: space-between;
align-items: center;
}

.footer-link {
color: var(--atomic-primary);
text-decoration: none;
}

.footer-link:hover {
text-decoration: underline;
}

.footer-icon {
aspect-ratio: auto;
height: 1.25rem;
align-items: center;
display: flex;
}

div::part(header) {
min-width: 0;
}

atomic-recs-list::part(label) {
font-size: var(--atomic-text-xl);
padding-top: 0.75rem;
padding-bottom: 0.25rem;
color: var(--atomic-on-background);
}

atomic-recs-list::part(outline) {
padding: 0.4rem;
border: none;
}

atomic-recs-list::part(result-list) {
gap: 0.5rem;
}

atomic-recs-list::part(result-list-grid-clickable) {
inset: unset;
}

atomic-ipx-tabs {
width: 100%;
}

#ipx-search-2308db1b-8a1d-441e-8036-da3052fed1ff:not(.atomic-search-interface-search-executed)
> :is(atomic-ipx-modal, atomic-ipx-embedded)
> div[slot='body']
> atomic-layout-section
> :is(atomic-result-list, atomic-query-summary) {
display: none;
}

#ipx-search-2308db1b-8a1d-441e-8036-da3052fed1ff:is(.atomic-search-interface-search-executed, .atomic-search-interface-error)
> :is(atomic-ipx-modal, atomic-ipx-embedded)
> div[slot='body']
> atomic-recs-interface#ipx-recs-2308db1b-8a1d-441e-8036-da3052fed1ff
> atomic-recs-list {
display: none;
}

#ipx-search-2308db1b-8a1d-441e-8036-da3052fed1ff:not(.atomic-ipx-modal-opened)
> atomic-ipx-modal,
#ipx-search-2308db1b-8a1d-441e-8036-da3052fed1ff:not(.atomic-modal-opened)
> atomic-ipx-modal
> div[slot='header']
> atomic-ipx-refine-modal {
display: none;
}

#ipx-search-2308db1b-8a1d-441e-8036-da3052fed1ff:not(.atomic-search-interface-search-executed)
> :is(atomic-ipx-modal, atomic-ipx-embedded)
> div[slot='header']
> atomic-layout-section
> atomic-ipx-refine-toggle {
display: none;
}

#ipx-search-2308db1b-8a1d-441e-8036-da3052fed1ff:is(.atomic-search-interface-search-executed)
> :is(atomic-ipx-modal, atomic-ipx-embedded)
> div[slot='header']
> atomic-layout-section
> atomic-ipx-refine-toggle {
display: block;
}

body:not(.atomic-ipx-modal-opened) div.builder_preview atomic-ipx-modal,
body:not(.atomic-modal-opened) div.builder_preview atomic-ipx-refine-modal {
display: none;
}

atomic-ipx-button::part(ipx-button) {
background-color: var(--atomic-ipx-button);
text-overflow: ellipsis;
max-width: var(--atomic-ipx-width, 31.25rem);
}

atomic-ipx-button::part(ipx-button):hover {
background-color: var(--atomic-ipx-button-light);
}
atomic-ipx-button::part(button-text) {
color: var(--atomic-ipx-button-label);
}

atomic-ipx-button::part(button-icon) {
padding-bottom: 1.15rem;
}

/* Delete this when SVCINT-2287 is done--> */
atomic-ipx-button::part(ripple) {
background-color: var(--atomic-ipx-button)!important;
}

div.builder_preview atomic-ipx-button[is-modal-open]::part(ipx-open-icon) {
opacity: 0;
transition: 0.25s ease-in-out;
}

atomic-ipx-modal {
z-index: 1000;
}

atomic-ipx-button::part(ipx-button) {
z-index: 1000;
}

atomic-recs-list::part(result-list-grid-clickable-container outline):hover {
border: none;
box-shadow: none;
}

atomic-recs-list::part(result-list-grid-clickable-container outline)::after {
margin: 0.2rem 0;
display: block;
content: ' ';
height: 1px;
background-color: var(--atomic-neutral);
}

#ipx-search-2308db1b-8a1d-441e-8036-da3052fed1ff.atomic-search-interface-error atomic-recs-error {
display: none;
}



</style>
<atomic-search-interface id="ipx-search-2308db1b-8a1d-441e-8036-da3052fed1ff" fields-to-include='["engagementinternalcategory","engagementinternaltype","engagementinternalstage","engagementinternalproducts","engagementinternalfocusarea","engagementinternalusecasetags","documenttype","source"]' reflect-state-in-url='false'>
<atomic-ipx-modal is-open="false" no-focus-trap="false">
<div slot="header">
<atomic-layout-section class="search-section" section="search">
<atomic-search-box class="search-box"></atomic-search-box>
<atomic-ipx-refine-toggle></atomic-ipx-refine-toggle>
</atomic-layout-section>

</div>

<div slot="body">
<atomic-layout-section section="status">
<atomic-breadbox></atomic-breadbox>
<atomic-query-summary class="query-summary"></atomic-query-summary>
<atomic-did-you-mean></atomic-did-you-mean>
<atomic-notifications></atomic-notifications>
</atomic-layout-section>

<atomic-layout-section section="results">
<atomic-result-list image-size="none">
<atomic-result-template
>
<template>
    <style>
.field {
    display: inline-flex;
    align-items: center;
}

.field-label {
    font-weight: bold;
    margin-right: 0.25rem;
}

.thumbnail {
    display: none;
    width: 100%;
    height: 100%;
}

.icon {
    display: none;
}

.result-root.image-small .thumbnail,
.result-root.image-large .thumbnail {
    display: inline-block;
}

.result-root.image-icon .icon {
    display: inline-block;
}

.result-root.image-small atomic-result-section-visual,
.result-root.image-large atomic-result-section-visual {
    border-radius: var(--atomic-border-radius-xl);
}

.badge-documenttype::part(result-badge-element) {
        background-color: #e4e3e3;
    }

    .badge-documenttype::part(result-badge-label) {
            color: #000000;
        }
    </style>
<atomic-result-section-badges>
<atomic-result-badge class="badge-documenttype" field="documenttype"></atomic-result-badge>
</atomic-result-section-badges>
<atomic-result-section-title>
<atomic-result-link>
    <a slot="attributes" target="self"></a>
</atomic-result-link>
</atomic-result-section-title>
<atomic-result-section-title-metadata></atomic-result-section-title-metadata>
<atomic-result-section-excerpt>
<atomic-result-text field="excerpt"></atomic-result-text>
</atomic-result-section-excerpt>
<atomic-result-section-bottom-metadata>
<atomic-result-fields-list>
    <atomic-field-condition class="field" if-defined="source">
            <span class="field-label"><atomic-text value="Source"></atomic-text>:</span>
            <atomic-result-text field="source"></atomic-result-text>
            </atomic-field-condition>
    </atomic-result-fields-list>
</atomic-result-section-bottom-metadata>

</template>
</atomic-result-template>

</atomic-result-list>
<atomic-no-results></atomic-no-results>
<atomic-query-error></atomic-query-error>
</atomic-layout-section>
<atomic-layout-section section="pagination">
<atomic-load-more-results class="pagination-more-results"></atomic-load-more-results>
</atomic-layout-section>


<atomic-recs-interface id="ipx-recs-2308db1b-8a1d-441e-8036-da3052fed1ff" fields-to-include='["engagementinternalcategory","engagementinternaltype","engagementinternalstage","engagementinternalproducts","engagementinternalfocusarea","engagementinternalusecasetags","documenttype","source"]' analytics="true" >
<atomic-recs-list image-size="none" label="Recommended" number-of-recommendations="5">
<atomic-recs-result-template
    >
    <template>
        <style>
.field {
    display: inline-flex;
    align-items: center;
}

.field-label {
    font-weight: bold;
    margin-right: 0.25rem;
}

.thumbnail {
    display: none;
    width: 100%;
    height: 100%;
}

.icon {
    display: none;
}

.result-root.image-small .thumbnail,
.result-root.image-large .thumbnail {
    display: inline-block;
}

.result-root.image-icon .icon {
    display: inline-block;
}

.result-root.image-small atomic-result-section-visual,
.result-root.image-large atomic-result-section-visual {
    border-radius: var(--atomic-border-radius-xl);
}

.badge-documenttype::part(result-badge-element) {
        background-color: #e4e3e3;
    }

    .badge-documenttype::part(result-badge-label) {
            color: #000000;
        }
    </style>
<atomic-result-section-badges>
<atomic-result-badge class="badge-documenttype" field="documenttype"></atomic-result-badge>
</atomic-result-section-badges>
<atomic-result-section-title>
<atomic-result-link>
    <a slot="attributes" target="self"></a>
</atomic-result-link>
</atomic-result-section-title>
<atomic-result-section-title-metadata></atomic-result-section-title-metadata>
<atomic-result-section-excerpt>
<atomic-result-text field="excerpt"></atomic-result-text>
</atomic-result-section-excerpt>
<atomic-result-section-bottom-metadata>
<atomic-result-fields-list>
    <atomic-field-condition class="field" if-defined="source">
            <span class="field-label"><atomic-text value="Source"></atomic-text>:</span>
            <atomic-result-text field="source"></atomic-result-text>
            </atomic-field-condition>
    </atomic-result-fields-list>
</atomic-result-section-bottom-metadata>

    </template>
  </atomic-recs-result-template>
</atomic-recs-list>
<atomic-recs-error></atomic-recs-error>
</atomic-recs-interface>

</div>


<atomic-layout-section section="facets">
<atomic-facet field="engagementinternalcategory" label="Category" display-values-as="checkbox"></atomic-facet><atomic-facet field="engagementinternaltype" label="Type" display-values-as="checkbox"></atomic-facet><atomic-facet field="engagementinternalstage" label="Stage" display-values-as="checkbox"></atomic-facet><atomic-facet field="engagementinternalproducts" label="Products" display-values-as="checkbox"></atomic-facet><atomic-facet field="engagementinternalfocusarea" label="Focus Area" display-values-as="checkbox"></atomic-facet><atomic-facet field="engagementinternalusecasetags" label="Use Case" display-values-as="checkbox"></atomic-facet>
</atomic-layout-section>

</atomic-ipx-modal>

    <atomic-ipx-button label="" is-modal-open="false" exportparts="ipx-button"></atomic-ipx-button>

</atomic-search-interface>`,
});

    },
    };
    console.log("CoveoNewGenIPX.js static resource 4");
} catch(err) {
    console.log('Error in CoveoNewGenIPX');
}