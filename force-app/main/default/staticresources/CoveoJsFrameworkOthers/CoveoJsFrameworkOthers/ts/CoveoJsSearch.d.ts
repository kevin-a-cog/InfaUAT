/// <reference path="Externals.d.ts" />
declare module Coveo {
	function shim(): void;

}
declare module Coveo {
	function customEventPolyfill(): void;

}
declare module Coveo {
	var version: {
	    lib: string;
	    product: string;
	    supportedApiVersion: number;
	};

}
declare module Coveo {
	/**
	 * A JSON which contains type T.
	 *
	 * eg :
	 * ```
	 * IStringMap<boolean> -> {'foo' : true, 'bar' : false};
	 * IStringMap<number> -> {'foo' : 1 , 'bar' : 123}
	 * ```
	 *
	 */
	interface IStringMap<T> {
	    [paramName: string]: T;
	}

}
declare module Coveo {
	class Logger {
	    static TRACE: number;
	    static DEBUG: number;
	    static INFO: number;
	    static WARN: number;
	    static ERROR: number;
	    static NOTHING: number;
	    static level: number;
	    static executionTime: boolean;
	    constructor(owner: any);
	    trace(...stuff: any[]): void;
	    debug(...stuff: any[]): void;
	    info(...stuff: any[]): void;
	    warn(...stuff: any[]): void;
	    error(...stuff: any[]): void;
	    static enable(): void;
	    static disable(): void;
	}

}
declare module Coveo {
	/**
	 * A highlight structure, as returned by the index.
	 * This structure can be used to do the actual highlighting job.
	 */
	interface IHighlight {
	    /**
	     * The 0 based offset inside the string where the highlight should start.
	     */
	    offset: number;
	    /**
	     * The length of the offset.
	     */
	    length: number;
	    /**
	     * The group number for the highlight. A single string can have the same term highlighted multiple times.
	     * This allows to regroup the different highlights.
	     */
	    dataHighlightGroup?: number;
	    /**
	     * The string that represent the highlight. A single string can have the same term highlighted multiple times.
	     * This allows to regroup the different highlights.
	     */
	    dataHighlightGroupTerm?: string;
	}
	/**
	 * The data about a single term to highlight.
	 */
	interface IHighlightTerm {
	    /**
	     * The term that needs to be highlighted, as well as the list of stemming expansions.
	     */
	    [originalTerm: string]: string[];
	}
	/**
	 * The data about a single phrase to highlight.
	 */
	interface IHighlightPhrase {
	    /**
	     * The phrase that needs to be highlighted, with the different terms associated.
	     */
	    [phrase: string]: IHighlightTerm;
	}

}
declare module Coveo {
	function buildHistoryStore(): any;
	function buildNullHistoryStore(): any;

}
declare module Coveo {
	interface IEndpointError extends Error {
	    message: string;
	    type: string;
	    name: string;
	}

}
declare module Coveo {
	/**
	 * Describe a query function that can be executed against the index<br/>
	 * See: [Query Functions](https://docs.coveo.com/en/1451/)
	 */
	interface IQueryFunction {
	    /**
	     * Function to execute, as a string
	     */
	    function: string;
	    /**
	     * The field name on which to store the query function result when the query returns
	     */
	    fieldName: string;
	}

}
declare module Coveo {
	/**
	 * Describe a ranking function that can be executed against the index.<br/>
	 * See: [Ranking Functions](https://docs.coveo.com/en/1448/)
	 */
	interface IRankingFunction {
	    /**
	     * The mathematical expression that calculates the ranking value to add to the result score.
	     */
	    expression: string;
	    /**
	     * Whether to normalize the value using the standard index scale or not. If you don't want to completely override the index ranking and use the qrf as a boost, you should turn this on.
	     */
	    normalizeWeight: boolean;
	}

}
declare module Coveo {
	/**
	 * Describe a computed field request<br/>
	 * See: [Computed Fields](https://docs.coveo.com/en/1467/)
	 */
	interface IComputedFieldRequest {
	    /**
	     * This specifies the field on which the aggregate operation will be performed. This field is typically a numerical value.
	     */
	    field: string;
	    /**
	     * This specifies the operation to execute on the field value.<br/>
	     * Possible operations:
	     * -- sum: Computes the sum of all values.
	     * -- average: Computes the average of all values.
	     * --minimum: Retrieves the smallest of all values.
	     * --maximum: Retrieves the largest of all values.
	     */
	    operation: string;
	}

}
declare module Coveo {
	enum RangeEndScope {
	    Inclusive,
	    Exclusive,
	}
	type RangeType = string | number | Date;
	/**
	 * Describes a single range value in a [group by request]{@link IGroupByRequest} or [facet request]{@link IFacetRequest}.
	 */
	interface IRangeValue {
	    /**
	     * The value to start the range at.
	     *
	     * **Examples:**
	     * > - `0`
	     * > - `2018-01-01T00:00:00.000Z`
	     */
	    start?: RangeType;
	    /**
	     * The value to end the range at.
	     *
	     * **Examples:**
	     * > - `500`
	     * > - `2018-12-31T23:59:59.999Z`
	     */
	    end?: RangeType;
	    /**
	     * The label to associate with the range value.
	     *
	     * **Examples:**
	     * > - `0 - 500`
	     * > - `In 2018`
	     */
	    label?: string;
	    /**
	     * Whether to include the [`end`]{@link IRangeValue.end} value in the range.
	     */
	    endInclusive?: boolean;
	}

}
declare module Coveo {
	/**
	 * The possible values for the [allowedValuesPatternType]{@link IGroupByRequest.allowedValuesPatternType} property of the `IGroupByRequest` interface.
	 */
	enum AllowedValuesPatternType {
	    /**
	     * Only supports trailing wildcards in the pattern.
	     */
	    Legacy,
	    /**
	     * Fully supports wildcards.
	     */
	    Wildcards,
	    /**
	     * Supports regular expression as the pattern.
	     */
	    Regex,
	    /**
	     *Applies the Edit Distance algorithm to match values that are close to the specified pattern.
	     */
	    EditDistance,
	    /**
	     *Applies a phonetic algorithm to match values that are phonetically similar to the specified pattern.
	     */
	    Phonetic,
	}

}
declare module Coveo {
	/**
	 * The `IGroupByRequest` interface describes a Group By operation to perform against the index.
	 *
	 * See [Group By Operations](https://docs.coveo.com/en/1453/).
	 */
	interface IGroupByRequest {
	    /**
	     * Specifies the field on which to perform the Group By request. The Group By request returns a Group By value for
	     * each distinct value of this field within the result set.
	     */
	    field: string;
	    lookupField?: string;
	    /**
	     * Specifies how the indexer should sort the Group By values.
	     *
	     * The possible values are:
	     * - `score`: Sort by score. Score is computed from the number of occurrences of a field value, as well as from the
	     * position where results having this field value appear in the ranked result set. When using this sort criterion, a
	     * field value with 100 occurrences might appear after one with only 10 occurrences, if the occurrences of the latter
	     * tend to appear sooner in the ranked result set.
	     * - `occurrences`: Sort by number of occurrences, with values having the highest number of occurrences appearing
	     * first.
	     * - `alphaascending` / `alphadescending`: Sort alphabetically on the field values.
	     * - `computedfieldascending` / `computedfielddescending`: Sort on the values of the first computed field for each
	     * Group By value (see [Computed Fields](https://docs.coveo.com/en/1467/)).
	     * - `chisquare`: Sort based on the relative frequency of values in the result set compared to the frequency in the
	     * entire index. This means that a value that does not appear often in the index but does appear often in the result
	     * set will tend to appear first.
	     * - `nosort`: Do not sort the Group By values. When using this sort criterion, the index returns the Group By values
	     * in a random order.
	     *
	     * Default value is `score`.
	     */
	    sortCriteria?: string;
	    /**
	     * Specifies the maximum number of values that the Group By operation can return.
	     *
	     * Default value is `10`. Minimum value is `0`.
	     */
	    maximumNumberOfValues?: number;
	    /**
	     * Specifies how deep the index should scan the results to identify missing Group By values.
	     *
	     * When executing a Group By operation, the index uses various heuristics to try to list all of the field values that
	     * appear in the result set. In some corner cases, certain values might be omitted (it is a classical example of a
	     * trade-off between precision and performance). Using `injectionDepth` forces the index to explicitly scan the field
	     * values of the top n results of the query, and ensure that the field values present in those results are included.
	     *
	     * Consequently, specifying a high value for this parameter may negatively impact query performance.
	     *
	     * Default value is `1000`. Minimum value is `1000`.
	     *
	     * @examples 1500
	     */
	    injectionDepth?: number;
	    /**
	     * Specifies a different query expression on which to compute the Group By operation.
	     *
	     * This feature is typically used for performance reasons to retrieve Group By values on separate expressions while
	     * executing a normal query in a single operation.
	     *
	     * By default, the query expression being executed is used.
	     */
	    queryOverride?: string;
	    advancedQueryOverride?: string;
	    /**
	     * Specifies a constant query expression on which to compute the Group By operation.
	     *
	     * This feature is similar to the [`queryOverride`]{@link IGroupByRequest.queryOverride} feature, except that in this
	     * case, the index keeps the constant query expression in cache for faster queries. You should avoid specifying a
	     * dynamic query expression for this parameter, for doing so will negatively impact performance.
	     *
	     * By default, the constant part of the query expression being executed is used.
	     */
	    constantQueryOverride?: string;
	    /**
	     * Explicitly specifies a list of values for which to generate Group By values.
	     *
	     * You can use trailing wildcards to include ranges of values.
	     *
	     * **Example:**
	     * > The array `["foo", "bar*"]` would return Group By values for `foo` and any value starting with `bar`.
	     */
	    allowedValues?: string[];
	    /**
	     * The pattern type to use for the {@link IGroupByRequest.allowedValues} property (see {@link AllowedValuesPatternType}).
	     *
	     * This option is empty by default, which makes it behave as [`legacy`]{@link AllowedValuesPatternType.Legacy}.
	     */
	    allowedValuesPatternType?: AllowedValuesPatternType;
	    /**
	     * Specifies an array of computed fields that should be evaluated for each Group By value that is returned.
	     *
	     * Computed fields are used to perform aggregate operations on other fields for all the matching items having a
	     * specific value in the Group By field in the results. See
	     * [Computed Fields](https://docs.coveo.com/en/1467/).
	     */
	    computedFields?: IComputedFieldRequest[];
	    /**
	     * Explicitly specifies a list of range values for which Group By values should be generated.
	     */
	    rangeValues?: IRangeValue[];
	    /**
	     * Specifies whether to let the index calculate the ranges.
	     *
	     * Default value is `false`.
	     */
	    generateAutomaticRanges?: boolean;
	    completeFacetWithStandardValues?: boolean;
	}

}
declare module Coveo {
	/**
	 * A context, as returned by {@link SearchInterface.getQueryContext} or {@link PipelineContext.getContext}
	 */
	type Context = IStringMap<string | string[]>;
	interface IPipelineContextProvider {
	    getContext: () => Context;
	}

}
declare module Coveo {
	interface ICategoryFacetRequest {
	    field: string;
	    path?: string[];
	    maximumNumberOfValues?: number;
	    injectionDepth?: number;
	    delimitingCharacter?: string;
	}

}
declare module Coveo {
	/**
	 * The allowed states of a facet value in a Search API facet
	 * [request]{@link IFacetRequestValue.state} or
	 * [response]{@link IFacetResponseValue.state}.
	 */
	enum FacetValueState {
	    /**
	     * The facet value is not currently selected or excluded in the search
	     * interface.
	     */
	    idle,
	    /**
	     * The facet value is currently selected in the search interface.
	     */
	    selected,
	}

}
declare module Coveo {
	/**
	 * The allowed sort criteria for a Search API
	 * [facet request]{@link IFacetRequest}.
	 */
	enum FacetSortCriteria {
	    /**
	     * Sort facet values in descending score order.
	     *
	     * Facet value scores are based on number of occurrences and position in the
	     * ranked query result set.
	     *
	     * The Coveo Machine Learning dynamic navigation experience feature only
	     * works with this sort criterion.
	     */
	    score,
	    /**
	     * Sort facet values in ascending alphanumeric order.
	     */
	    alphanumeric,
	    /**
	     * Sort facet values in descending number of occurrences.
	     */
	    occurrences,
	}
	function isFacetSortCriteria(sortCriteria: string): boolean;

}
declare module Coveo {
	enum FacetRangeSortOrder {
	    /**
	     * Sort facet values in ascending order.
	     */
	    ascending,
	    /**
	     * Sort facet values in ascending order.
	     */
	    descending,
	}
	function isFacetRangeSortOrder(sortOrder: string): boolean;

}
declare module Coveo {
	/**
	 * The allowed values for the [`facetType`]{@link IFacetRequest.facetType} property of a [facet request]{@link IFacetRequest}.
	 */
	enum FacetType {
	    /**
	     * Request facet values representing specific values.
	     */
	    specific,
	    /**
	     * Request facet values representing ranges of numbers.
	     */
	    numericalRange,
	    /**
	     * Request facet values representing ranges of dates.
	     */
	    dateRange,
	    /**
	     * Request facet values representing a hierarchy.
	     */
	    hierarchical,
	}
	/**
	 * A [`currentValues`]{@link IFacetRequest.currentValues} item in a Search API
	 * [facet request]{@link IFacetRequest}.
	 */
	interface IFacetRequestValue extends IRangeValue {
	    /**
	     * The current facet value state in the search interface.
	     *
	     * **Default (Search API):** `idle`
	     */
	    state: FacetValueState;
	    /**
	     * **Required (Search API).** The facet value name.
	     */
	    value?: string;
	    /**
	     * Whether to prevent Coveo ML from automatically selecting the facet value.
	     *
	     * **Default:** `false`
	     */
	    preventAutoSelect?: boolean;
	    /**
	     * Whether to retrieve the children of this category facet value. Can only be used on leaf values in the request (i.e., values with no current children).
	     *
	     * **Default:** `false`
	     */
	    retrieveChildren?: boolean;
	    /**
	     * If [retrieveChildren]{@link IFacetRequestValue.retrieveChildren} is true, the maximum number of children to retrieve for this leaf value.
	     *
	     * **Default (Search API):** `0`
	     */
	    retrieveCount?: number;
	    /**
	     * The children of this category facet value.
	     * Each child is a full-fledged category facet value that may in turn have its own children and so forth,
	     * up to a maximum depth of 50 levels
	     */
	    children?: IFacetRequestValue[];
	}
	/**
	 * A Search API facet request.
	 */
	interface IFacetRequest {
	    /**
	     * The unique identifier of the facet in the search interface.
	     *
	     * **Note:** Must match `^[A-Za-z0-9-_]{1,60}$`.
	     *
	     * **Example:** `author-1`
	     */
	    facetId: string;
	    /**
	     * **Required (Search API).** The name of the field on which to base the
	     * facet request.
	     *
	     * **Note:** Must reference an index field whose **Facet** option is enabled.
	     *
	     * **Example:** `author`
	     */
	    field: string;
	    /**
	     * The kind of values to request for the facet.
	     *
	     * **Default (Search API):** [`Specific`]{@link FacetType.Specific}
	     */
	    type?: FacetType;
	    /**
	     * The sort criterion to apply to the returned facet values.
	     *
	     * **Default behaviour when [`type`]{@link IFacetRequest.type} is set to [`specific`]{@link FaceType.Specific}
	     * or [`hierarchical`]{@link FaceType.Hierarchical} (Search API):**
	     * - When [`isFieldExpanded`]{@link IFacetRequest.isFieldExpanded} is `false`
	     * in the facet request, and
	     * [`moreValuesAvailable`]{@link IFacetResponse.moreValuesAvailable} is
	     * `true` in the corresponding [facet response]{@link IFacetResponse}, use
	     * `score`.
	     * - Otherwise, use `alphanumeric`.
	     *
	     * **Default (Search API) when [`type`]{@link IFacetRequest.type} is set to [`dateRange`]{@link FaceType.dateRange}
	     * or [`numericalRange`]{@link FacetType.numericalRange} (Search API)::** `ascending`
	     * Other possible value: `descending`
	     */
	    sortCriteria?: FacetSortCriteria | FacetRangeSortOrder;
	    /**
	     * The maximum number of facet values to fetch.
	     *
	     * **Note:** If
	     * [`freezeCurrentValues`]{@link IFacetRequest.freezeCurrentValues} is
	     * `true`, `numberOfValues` must be equal to the
	     * [`currentValues`]{@link IFacetRequest.currentValues} array length.
	     *
	     * **Default (Search API):** `8`
	     */
	    numberOfValues?: number;
	    /**
	     * The maximum number of items to scan for facet values.
	     *
	     * **Note:** A high `injectionDepth` may negatively impact the facet request
	     * performance.
	     *
	     * **Default (Search API):** `1000`
	     */
	    injectionDepth?: number;
	    /**
	     * Whether to include the facet request's
	     * [`currentValues`]{@link IFacetRequest.currentValues} in the corresponding
	     * [facet response]{@link IFacetResponse}'s
	     * [`values`]{@link IFacetResponse.values} array.
	     *
	     * **Note:** Setting this to `true` is useful to ensure that the facet does
	     * not move around while the end-user is interacting with it in the search
	     * interface.
	     *
	     * **Default (Search API):** `false`
	     */
	    freezeCurrentValues?: boolean;
	    /**
	     * The values displayed by the facet in the search interface at the moment of
	     * the request.
	     *
	     * See [IFacetRequestValue]{@link IFacetRequestValue}.
	     *
	     * **Default (Search API):** `[]`
	     */
	    currentValues?: IFacetRequestValue[];
	    /**
	     * Whether the facet is expanded in the search interface at the moment of the
	     * request.
	     *
	     * **Default (Search API):** `false`
	     */
	    isFieldExpanded?: boolean;
	    /**
	     * Whether to automatically generate range values for the facet.
	     *
	     * **Notes:**
	     * - Setting this to `true` is only effective when [`type`]{@link IFacetRequest.type} is set to [`dateRange`]{@link FaceType.dateRange}
	     * or [`numericalRange`]{@link FacetType.numericalRange}, and the referenced [`field`]{@link IFacetRequest.field} is of a corresponding type (i.e., date or numeric).
	     * - Automatic range generation will fail if the referenced `field` is dynamically generated by a query function.
	     * - Enabling the **Use cache for numeric queries** option on the referenced `field` will speed up automatic range generation (see [Add or Edit Fields](https://docs.coveo.com/en/1982/)).
	     *
	     * **Default (Search API):** `false`
	     */
	    generateAutomaticRanges?: boolean;
	    /**
	     * The character to use to split field values into a hierarchical sequence.
	     *
	     * **Example:**
	     * For a multi-value field containing the following values: `c; c&gt;folder2; c&gt;folder2&gt;folder3;`
	     * The delimiting character is `&gt;`.
	     *
	     * **Default (Search API):** `;`
	     */
	    delimitingCharacter?: string;
	    /**
	     * Whether to exclude folded result parents when estimating result counts for facet values.
	     *
	     * **Default (Search API):** `true`
	     */
	    filterFacetCount?: boolean;
	    /**
	     * The base path shared by all values for a given hierarchical facet.
	     *
	     * **Default (Search API):** `[]`
	     */
	    basePath?: string[];
	    /**
	     * Whether to use the [`basePath`]{@link FacetRequest.basePath} as a filter for the results.
	     *
	     * **Note:** This parameter is ignored unless the facet [`type`]{@link FacetRequest.type} is `hierarchical`.
	     *
	     * **Default (Search API):** `true`
	     */
	    filterByBasePath?: boolean;
	    /**
	     * Whether to prevent Coveo ML from automatically selecting values from that facet.
	     *
	     * **Default:** `false`
	     */
	    preventAutoSelect?: boolean;
	}

}
declare module Coveo {
	/**
	 * The format of a successful response.
	 */
	type ResponseFormat = 'json' | 'opensearch-atom' | 'opensearch-rss' | 'xlsx';
	/**
	 * The available global configuration options when requesting facets through the [facets]{IQuery.facets} array.
	 */
	interface IFacetOptions {
	    /**
	     * Whether the facet values should be returned in their current order.
	     */
	    freezeFacetOrder?: Boolean;
	}
	/**
	 * The information about the user we'd like to check and its actions.
	 */
	interface IUserActionsRequest {
	    /**
	     * The id of the user for which we should check the document views.
	     */
	    tagViewsOfUser: string;
	}
	/**
	 * A Search API commerce request.
	 */
	interface ICommerceRequest {
	    /**
	     * The unique identifier of the catalog to query.
	     *
	     * **Example:** `46bc4275-e613-4dd5-b1ea-3e5aca1bcd9d`
	     */
	    catalogId?: string;
	    /**
	     * A mandatory query expression to apply if the commerce request affects the query.
	     * **Example:** `@storeid==1001`
	     */
	    filter?: string;
	    /**
	     * The way the commerce request should affect query results.
	     * **Example:** `selectCatalogObjects`
	     */
	    operation?: 'selectCatalogObjects' | 'excludeCatalogObjects';
	}
	/**
	 * The IQuery interface describes a query that can be performed on the Coveo REST Search API.
	 *
	 * For basic usage, see the {@link IQuery.q} and {@link IQuery.aq} properties.
	 *
	 * In a normal scenario, a query is built by the {@link QueryBuilder} class.
	 */
	interface IQuery {
	    /**
	     * The basic query expression. <br/>
	     * This is typically the query expression entered by the user in a query box.<br/>
	     * Since this part of the query is expected to come from user input, it is processed by the Did You Mean feature.
	     */
	    q: string;
	    /**
	     * The advanced query expression.<br/>
	     * This is the part of the query expression generated by code based on various rules.<br/>
	     * eg: Selecting a facet value will cause an expression to be added to the advanced query expression.
	     */
	    aq?: string;
	    /**
	     * The constant query expression.<br/>
	     * This part of the expression is much alike the advanced query expression, but it is meant to hold expressions that are constant for all users of a search interface/widget.<br/>
	     * The results of evaluating those expressions are kept in a special index cache, to avoid re-evaluating them on each query.<br/>
	     * You must be careful to not include dynamic parts in this expression, otherwise you risk filling up the cache with useless data and this might have a negative impact on performance.<br/>
	     * Expressions other than cq also benefit from caching in the index, but using cq allows to explicitly require that a part of the query be included in the cache.
	     */
	    cq?: string;
	    /**
	     * The contextual text.<br/>
	     * This is the contextual text part of the query. It uses the Coveo Machine Learning service to pick key keywords from
	     * the text and add them to the basic expression.
	     * This field is mainly used to pass context such a case description, long textual query or any other form of text that might help in
	     * refining the query.
	     */
	    lq?: string;
	    /**
	     * The disjunction query expression.<br/>
	     * This is the disjunctive part of the query expression that is merged with the other expression parts using an OR boolean operator.<br/>
	     * When specified, the final expression evaluated by the index ends up being (q aq cq) OR (dq).
	     */
	    dq?: string;
	    /**
	     * The hub value set from the {@link Analytics} component.<br/>
	     * Used for analytics reporting in the Coveo platform
	     */
	    searchHub?: string;
	    /**
	     * The tab value set from the {@link Tab} component.
	     */
	    tab?: string;
	    locale?: string;
	    /**
	     * Name of the query pipeline to use.<br/>
	     * Specifies the name of the query pipeline to use for the query. If not specified, the default value is default, which means the default query pipeline will be used.
	     */
	    pipeline?: string;
	    /**
	     * The maximum age for cached query results, in milliseconds.<br/>
	     * If results for the exact same request (including user identities) are available in the in-memory cache, they will be used if they are not older than the specified value.<br/>
	     * Otherwise, the query will be sent to the index.
	     */
	    maximumAge?: number;
	    /**
	     * Whether to enable wildcards on the basic expression keywords.<br/>
	     * This enables the wildcard features of the index. Coveo Platform will expand keywords containing wildcard characters to the possible matching keywords to broaden the query.<br/>
	     * See [Using Wildcards in Queries](https://docs.coveo.com/en/1580/).<br/>
	     * If not specified, this parameter defaults to false.
	     */
	    wildcards?: boolean;
	    /**
	     * Whether to enable question marks with wildcards.<br/>
	     * This enables using the question mark ? character within wildcard expressions.
	     */
	    questionMark?: boolean;
	    /**
	     * Whether to enable the support for operator in lowercase (AND OR -> and or)
	     */
	    lowercaseOperators?: boolean;
	    /**
	     * Whether to enable partial matching of the basic expression keywords.<br/>
	     * By activating this, when the basic expression contains at least {@link IQuery.partialMatchKeywords}, items containing only the number of keywords specified by {@link IQuery.partialMatchThreshold} will also match the query.<br/>
	     * Without this option, items are required to contain all the keywords in order to match the query.<br/>
	     * If not specified, this parameter defaults to false.
	     */
	    partialMatch?: boolean;
	    /**
	     * The minimum number of keywords needed to activate partial match.<br/>
	     * Specifies the minimum number of keywords needed for the partial match feature to activate.<br/>
	     * If the basic expression contains less than this number of keywords, no transformation is applied on the query.<br/>
	     * If not specified, this parameter defaults to 5.
	     */
	    partialMatchKeywords?: number;
	    /**
	     * The threshold to use for matching items when partial match is enabled.<br/>
	     * Specifies the minimum number of query keywords that an item must contain when partial match is enabled. This value can either be an absolute number or a percentage value based on the total number of keywords.<br/>
	     * If not specified, this parameter defaults to 50%.
	     */
	    partialMatchThreshold?: string;
	    /**
	     * This is the 0-based index of the first result to return.<br/>
	     * If not specified, this parameter defaults to 0.
	     */
	    firstResult?: number;
	    /**
	     * This is the number of results to return, starting from {@link IQuery.firstResult}.<br/>
	     * If not specified, this parameter defaults to 10.
	     */
	    numberOfResults?: number;
	    /**
	     * Specifies the sort criterion(s) to use to sort results. If not specified, this parameter defaults to Relevancy.<br/>
	     * Possible values are : <br/>
	     * -- relevancy :  This uses all the configured ranking weights as well as any specified ranking expressions to rank results.<br/>
	     * -- dateascending / datedescending : Sort using the value of the @date field, which is typically the last modification date of an item in the index.<br/>
	     * -- qre : Sort using only the weights applied through ranking expressions. This is much like using Relevancy except that automatic weights based on keyword proximity etc, are not computed.<br/>
	     * -- nosort : Do not sort the results. The order in which items are returned is essentially random.<br/>
	     * -- @field ascending / @field descending : Sort using the value of a custom field.
	     */
	    sortCriteria?: string;
	    sortField?: string;
	    /**
	     * Specifies a field on which {@link Folding} should be performed.<br/>
	     * Folding is a kind of duplicate filtering where only the first result with any given value of the field is included in the result set.<br/>
	     * It's typically used to return only one result in a conversation, for example when forum posts in a thread are indexed as separate items.
	     */
	    filterField?: string;
	    /**
	     * Number of results that should be folded, using the {@link IQuery.filterField}
	     */
	    filterFieldRange?: number;
	    /**
	     * Specifies an array of fields that should be returned for each result.<br/>
	     * eg: ['@foo','@bar']
	     *
	     */
	    fieldsToInclude?: string[];
	    /**
	     * Specifies an array of fields that should be excluded from the query results.<br/>
	     * eg: ['@foo','@bar']
	     *
	     */
	    fieldsToExclude?: string[];
	    /**
	     * Specifies the length (in number of characters) of the excerpts generated by the indexer based on the keywords present in the query.<br/>
	     * The index includes the top most interesting sentences (in the order they appear in the item) that fit in the specified number of characters.<br/>
	     * When not specified, the default value is 200.
	     */
	    excerptLength?: number;
	    /**
	     * Specifies whether the first sentences of the item should be included in the results.<br/>
	     * The retrieveFirstSentences option is typically used instead of excerpts when displaying email items, where the first sentence of the email might be of more interest than a contextually generated excerpt.
	     */
	    retrieveFirstSentences?: boolean;
	    /**
	     * This enables the query correction feature of the index.<br/>
	     * By activating this, the index returns an array of {link IQueryCorrection} with suggested word corrections.
	     */
	    enableDidYouMean?: boolean;
	    /**
	     * Specifies an array of Query Function operation that will be executed on the results.
	     */
	    queryFunctions?: IQueryFunction[];
	    /**
	     * Specifies an array of Ranking Function operations that will be executed on the result
	     */
	    rankingFunctions?: IRankingFunction[];
	    /**
	     * Specifies an array of Group By operations that can be performed on the query results to extract facets
	     */
	    groupBy?: IGroupByRequest[];
	    /**
	     * Specifies an array of request to retrieve facet values for the CategoryFacet component
	     */
	    categoryFacets?: ICategoryFacetRequest[];
	    /**
	     * Whether to include debug information from the Search API in the query response.
	     *
	     * **Note:**
	     * > This debug information does not include ranking information.
	     *
	     * Setting this property to `true` can have an adverse effect on query performance, so it should always be left to
	     * `false` in a production environment.
	     */
	    debug?: boolean;
	    timezone?: string;
	    /**
	     * Whether to enable the special query syntax such as field references for the basic query expression (parameter q).
	     * It is equivalent to a No syntax block applied to the basic query expression.
	     * If not specified, the parameter defaults to false
	     */
	    enableQuerySyntax?: boolean;
	    enableDuplicateFiltering?: boolean;
	    /**
	     * Whether the index should take collaborative rating in account when ranking result. See: {@link ResultRating}
	     */
	    enableCollaborativeRating?: boolean;
	    /**
	     * Specifies the childField when doing parent-child loading (See: {@link Folding})
	     */
	    childField?: string;
	    /**
	     * Specifies the parentField when doing parent-child loading (See: {@link Folding})
	     */
	    parentField?: string;
	    /**
	     * The context is a map of key_value that can be used in the Query pipeline in the Coveo platform.<br/>
	     */
	    context?: Context;
	    /**
	     * The actions history represents the past actions a user made and is used by the Coveo Machine Learning service to
	     * suggest recommendations. It is generated by the page view script (https://github.com/coveo/coveo.analytics.js)
	     */
	    actionsHistory?: string;
	    /**
	     * This is the id of the recommendation interface that generated the query.
	     */
	    recommendation?: string;
	    /**
	     * Specifies if the Search API should perform queries even when no keywords were entered by the end user.
	     *
	     * End user keywords are present in either the {@link IQuery.q} or {@link IQuery.lq} part of the query.
	     *
	     * This parameter is normally controlled by {@link SearchInterface.options.allowEmptyQuery} option.
	     */
	    allowQueriesWithoutKeywords?: boolean;
	    /**
	     * Specifies an array of request to retrieve facet values for the DynamicFacet component.
	     */
	    facets?: IFacetRequest[];
	    /**
	     * The global configuration options to apply to the requests in the [facets]{@link IQuery.facets} array.
	     */
	    facetOptions?: IFacetOptions;
	    /**
	     * The user ID or visitor ID whose item views should be tagged in the query results
	     * (see the [isUserActionView]{@link IQueryResult.isUserActionView} property of the [IQueryResult]{@link IQueryResult} interface).
	     *
	     * **Examples:**
	     *  - asmith@example.com
	     *  - 6318b0c6-9397-4d70-b393-cf4770fd1bab
	     */
	    userActions?: IUserActionsRequest;
	    /**
	     * The commerce request to execute.
	     */
	    commerce?: ICommerceRequest;
	    /**
	     * The format of a successful response.
	     * If not specified, this parameter defaults to 'json'.
	     */
	    format?: ResponseFormat;
	}

}
declare module Coveo {
	/**
	 * Describe the identity of a user on the Coveo platform
	 */
	interface IUserIdentity {
	    /**
	     * The name of the identity
	     */
	    name: string;
	    /**
	     * The provider of the identity in the Coveo platform
	     */
	    provider: string;
	    type: string;
	}

}
declare module Coveo {
	/**
	 * Describe a ranking expression performed against the index (qre)
	 */
	interface IRankingExpression {
	    /**
	     * The expression that was executed in the ranking expression
	     */
	    expression: string;
	    /**
	     * The relevance modifier that was applied
	     */
	    modifier: string;
	}

}
declare module Coveo {
	/**
	 * Describe an exception that was triggered by the index when performing the query.
	 */
	interface IQueryException {
	    /**
	     * The exception code
	     */
	    code: string;
	    context: string;
	}

}
declare module Coveo {
	/**
	 * Describe a field value returned by index
	 */
	interface IIndexFieldValue {
	    /**
	     * The value
	     */
	    value: string;
	    /**
	     * The optional lookupValue, if requested in the {@link IGroupByRequest}
	     */
	    lookupValue?: string;
	    /**
	     * The number of results in the index which have this value
	     */
	    numberOfResults: number;
	    /**
	     * The optional computedFieldResults, if requested in the {@link IGroupByRequest}
	     */
	    computedFieldResults?: number[];
	}

}
declare module Coveo {
	/**
	 * Describe a single group by value, returned by a {@link IGroupByResult}
	 */
	interface IGroupByValue extends IIndexFieldValue {
	    /**
	     * The string value. Think : Facet label.
	     */
	    value: string;
	    /**
	     * The lookup value if it was specified.
	     */
	    lookupValue?: string;
	    /**
	     * The number of results that match this value in the index for this particular group by request
	     */
	    numberOfResults: number;
	    /**
	     * The relevance score.
	     */
	    score: number;
	    /**
	     * If there was ny computed field request, the results will be available here.
	     */
	    computedFieldResults?: number[];
	}

}
declare module Coveo {
	/**
	 * A result for a {@link IGroupByRequest}.
	 *
	 * This is typically what the {@link Facet} component will use to render themselves.
	 */
	interface IGroupByResult {
	    /**
	     * The field on which the group by was performed.
	     */
	    field: string;
	    /**
	     * The differents values for this result
	     */
	    values: IGroupByValue[];
	    /**
	     * Available if there was any computed field request.
	     */
	    globalComputedFieldResults?: number[];
	}

}
declare module Coveo {
	/**
	 * Describe correction for a query
	 */
	interface IQueryCorrection {
	    /**
	     * The query once corrected
	     */
	    correctedQuery: string;
	    /**
	     * Array of correction for each word in the query
	     */
	    wordCorrections: IWordCorrection[];
	}
	interface IWordCorrection {
	    /**
	     * Offset, from the beginning of the query
	     */
	    offset: number;
	    /**
	     * Length of the correction
	     */
	    length: number;
	    /**
	     * The original word that was corrected
	     */
	    originalWord: string;
	    /**
	     * The new corrected word
	     */
	    correctedWord: string;
	}

}
declare module Coveo {
	/**
	 * A trigger is an action that the interface will perform (show a message, execute a function, redirect users) depending on the query that was performed.<br/>
	 * A trigger that can be configured in the Coveo Query Pipeline.
	 */
	interface ITrigger<T> {
	    type: string;
	    content: T;
	}
	/**
	 * Notify (show a message) to a user
	 */
	interface ITriggerNotify extends ITrigger<string> {
	}
	/**
	 * Redirect the user to another url
	 */
	interface ITriggerRedirect extends ITrigger<string> {
	}
	/**
	 * Perform a new query with a different query expression
	 */
	interface ITriggerQuery extends ITrigger<string> {
	}
	/**
	 * Execute a javascript function present in the page.
	 */
	interface ITriggerExecute extends ITrigger<{
	    name: string;
	    params: any[];
	}> {
	}

}
declare module Coveo {
	interface ICategoryFacetValue {
	    value: string;
	    numberOfResults: number;
	}

}
declare module Coveo {
	interface ICategoryFacetResult {
	    notImplemented?: boolean;
	    field: string;
	    values: ICategoryFacetValue[];
	    parentValues: ICategoryFacetValue[];
	}

}
declare module Coveo {
	/**
	 * A [values]{@link IFacetRequest.values} item in a Search API [facet response]{@link IFacetRequest}.
	 */
	interface IFacetResponseValue extends IRangeValue {
	    /**
	     * The facet value name.
	     */
	    value?: string;
	    /**
	     * The facet value state to display in the search interface.
	     */
	    state: FacetValueState;
	    /**
	     * The number of query result items matching the facet value.
	     */
	    numberOfResults: number;
	    /**
	     * Whether additional values are available for the facet.
	     */
	    moreValuesAvailable?: boolean;
	    /**
	     * The children of this hierarchical facet value.
	     */
	    children?: IFacetResponseValue[];
	    /**
	     * When the hierarchical value has no children, this property is `true`.
	     */
	    isLeafValue?: boolean;
	}
	/**
	 * An item in the response of a Search API [facet request]{@link IFacetRequest}.
	 */
	interface IFacetResponse {
	    /**
	     * The unique facet identifier in the search interface.
	     */
	    facetId: string;
	    /**
	     * The name of the field on which the facet is based.
	     */
	    field: string;
	    /**
	     * Whether additional values are available for the facet.
	     */
	    moreValuesAvailable: boolean;
	    /**
	     * The returned facet values.
	     *
	     * See [IFacetResponseValue]{@link IFacetResponseValue}
	     */
	    values: IFacetResponseValue[];
	}

}
declare module Coveo {
	interface IQuestionAnswerMeta {
	    documentId: {
	        contentIdKey: string;
	        contentIdValue: string;
	    };
	    score: number;
	}
	interface IRelatedQuestionAnswerResponse extends IQuestionAnswerMeta {
	    question: string;
	    answerSnippet: string;
	}
	interface IQuestionAnswerResponse extends IQuestionAnswerMeta {
	    question?: string;
	    answerSnippet?: string;
	    relatedQuestions: IRelatedQuestionAnswerResponse[];
	}

}
declare module Coveo {
	/**
	 * Describe a set a results returned by the Search API
	 */
	interface IQueryResults {
	    /**
	     * When an error occurs, and the errorsAsSuccess flag is passed, the error will be returned in the body of the response
	     */
	    error?: {
	        /**
	         * The error message
	         */
	        message: string;
	        /**
	         * The type of error
	         */
	        type: string;
	        /**
	         * A detailed execution report sent by the Search API
	         */
	        executionReport: any;
	    };
	    /**
	     * A detailed execution report sent by the Search API.<br/>
	     * Only sent if {@link IQuery.debug} is true
	     */
	    executionReport?: any;
	    /**
	     * The basic expression that was executed.<br/>
	     * Only sent if {@link IQuery.debug} is true
	     */
	    basicExpression?: string;
	    /**
	     * The advanced expression that was executed.<br/>
	     * Only sent if {@link IQuery.debug} is true
	     */
	    advancedExpression?: string;
	    /**
	     * The constant expression that was executed.<br/>
	     * Only sent if {@link IQuery.debug} is true
	     */
	    constantExpression?: string;
	    /**
	     * A list of user identities that were used to perform this query.<br/>
	     * Only sent if {@link IQuery.debug} is true
	     */
	    userIdentities?: IUserIdentity[];
	    /**
	     * A list of ranking expression that were used to tweak the relevance.<br/>
	     * Only sent if {@link IQuery.debug} is true
	     */
	    rankingExpressions?: IRankingExpression[];
	    /**
	     * The total number of results that matched the query in the index.
	     */
	    totalCount: number;
	    /**
	     * The total number of results that matched the query in the index, but with the duplicate filtered.
	     */
	    totalCountFiltered: number;
	    /**
	     * The total query duration, which is the sum of the `indexDuration` and `searchAPIDuration`, including any latency incurred through the necessary network hops.
	     */
	    duration: number;
	    /**
	     * The part of the total query `duration` that was spent in the index.
	     */
	    indexDuration: number;
	    /**
	     * The part of the total query `duration` that was spent in the Coveo Search API.
	     */
	    searchAPIDuration: number;
	    /**
	     * The duration of the query on the proxy (not always applicable, can be optional)
	     *
	     * @deprecated Use duration, indexDuration and searchAPIDuration instead.
	     */
	    proxyDuration?: number;
	    /**
	     * The duration of the query for the client.
	     *
	     * @deprecated Use searchAPIDuration instead.
	     */
	    clientDuration: number;
	    /**
	     * A unique identifier for this query, used mainly for the {@link Analytics} service.
	     */
	    searchUid?: string;
	    /**
	     * The pipeline that was used for this query.
	     */
	    pipeline?: string;
	    /**
	     * The search api version that was used for this query.
	     */
	    apiVersion?: number;
	    /**
	     * The split test run that was used for this query. (A/B tests feature of the Coveo Query Pipeline)
	     */
	    splitTestRun?: string;
	    /**
	     * The exception that can be returned by the index if the query triggered an error
	     */
	    exception?: IQueryException;
	    /**
	     * The results of the query
	     */
	    results: IQueryResult[];
	    /**
	     * The group by results of the query
	     */
	    groupByResults: IGroupByResult[];
	    /**
	     * Category facet results of the query
	     */
	    categoryFacets: ICategoryFacetResult[];
	    /**
	     * Possible query corrections (eg : {@link DidYouMean})
	     */
	    queryCorrections: IQueryCorrection[];
	    /**
	     * Terms to highlight (with stemming) in the results
	     */
	    termsToHighlight: {
	        [originalTerm: string]: string[];
	    };
	    /**
	     * Phrases to highlight (with stemming) in the results
	     */
	    phrasesToHighlight: {
	        [originalTerm: string]: string[];
	    };
	    /**
	     * The Coveo Query Pipeline triggers, if any were configured.
	     */
	    triggers: ITrigger<any>[];
	    /**
	     * The keywords selected by Coveo Machine Learning Refined Query feature
	     */
	    refinedKeywords?: string[];
	    _folded: boolean;
	    _reusedSearchUid?: boolean;
	    /**
	     * Facet results of the query
	     */
	    facets?: IFacetResponse[];
	    questionAnswer?: IQuestionAnswerResponse;
	}

}
declare module Coveo {
	class JQueryUtils {
	    static getJQuery(): any;
	    static isInstanceOfJQuery(obj: Object): boolean;
	    static isInstanceOfJqueryEvent(obj: Object): boolean;
	}

}
declare module Coveo {
	type ValidResponsiveMode = 'auto' | 'small' | 'medium' | 'large';
	/**
	 * This class serves as a way to get and set the different screen size breakpoints for the interface.
	 *
	 * By setting those, you can impact, amongst others, the {@link Facet}'s, {@link Tab}'s or the {@link ResultList}'s behaviour.
	 *
	 * For example, the {@link Facet} components of your interface will switch to a dropdown menu when the screen size reaches 800px or less.
	 *
	 * You could modify this value using `this` calls
	 *
	 * Normally, you would interact with this class using the instance bound to {@link SearchInterface.responsiveComponents}
	 */
	class ResponsiveComponents {
	    windoh: Window;
	    constructor(windoh?: Window);
	    /**
	     * Set the breakpoint for small screen size.
	     * @param width
	     */
	    setSmallScreenWidth(width: number): void;
	    /**
	     * Set the breakpoint for medium screen size
	     * @param width
	     */
	    setMediumScreenWidth(width: number): void;
	    setResponsiveMode(responsiveMode: ValidResponsiveMode): void;
	    /**
	     * Get the current breakpoint for small screen size.
	     *
	     * If it was not explicitly set by {@link ResponsiveComponents.setSmallScreenWidth}, the default value is `480`.
	     * @returns {number}
	     */
	    getSmallScreenWidth(): number;
	    /**
	     * Get the current breakpoint for medium screen size.
	     *
	     * If it was not explicitly set by {@link ResponsiveComponents.setMediumScreenWidth}, the default value is `800`.
	     * @returns {number}
	     */
	    getMediumScreenWidth(): number;
	    /** Return the current responsive mode.
	     * @returns {ValidResponsiveMode}
	     */
	    getResponsiveMode(): ValidResponsiveMode;
	    /**
	     * Return true if the current screen size is smaller than the current breakpoint set for small screen width.
	     * @returns {boolean}
	     */
	    isSmallScreenWidth(): boolean;
	    /**
	     * Return true if the current screen size is smaller than the current breakpoint set for medium screen width.
	     * @returns {boolean}
	     */
	    isMediumScreenWidth(): boolean;
	    /**
	     * Return true if the current screen size is larger than the current breakpoint set for medium and small.
	     * @returns {boolean}
	     */
	    isLargeScreenWidth(): boolean;
	}

}
declare module Coveo {
	class DeviceUtils {
	    static getDeviceName(userAgent?: string): string;
	    static isAndroid(): boolean;
	    static isIos(): boolean;
	    static isMobileDevice(): boolean;
	    /**
	     * @deprecated
	     *
	     * Use ResponsiveComponents.isSmallScreenWidth() instead
	     */
	    static isSmallScreenWidth(): boolean;
	}

}
declare module Coveo {
	interface IOffset {
	    left: number;
	    top: number;
	}
	/**
	 * This is essentially an helper class for dom manipulation.<br/>
	 * This is intended to provide some basic functionality normally offered by jQuery.<br/>
	 * To minimize the multiple jQuery conflict we have while integrating in various system, we implemented the very small subset that the framework needs.<br/>
	 * See {@link $$}, which is a function that wraps this class constructor, for less verbose code.
	 */
	class Dom {
	    /**
	     * Whether to always register, remove, and trigger events using standard JavaScript rather than attempting to use jQuery first.
	     * @type boolean
	     */
	    static useNativeJavaScriptEvents: boolean;
	    el: HTMLElement;
	    /**
	     * Create a new Dom object with the given HTMLElement
	     * @param el The HTMLElement to wrap in a Dom object
	     */
	    constructor(el: HTMLElement);
	    /**
	     * Helper function to quickly create an HTMLElement
	     * @param type The type of the element (e.g. div, span)
	     * @param props The props (id, className, attributes) of the element<br/>
	     * Can be either specified in dashed-case strings ('my-attribute') or camelCased keys (myAttribute),
	     * the latter of which will automatically get replaced to dash-case.
	     * @param innerHTML The contents of the new HTMLElement, either in string form or as another HTMLElement
	     */
	    static createElement(type: string, props?: Object, ...children: Array<string | HTMLElement | Dom>): HTMLElement;
	    /**
	     * Adds the element to the children of the current element
	     * @param element The element to append
	     * @returns {string}
	     */
	    append(element: HTMLElement): void;
	    /**
	     * Get the css value of the specified property.<br/>
	     * @param property The property
	     * @returns {string}
	     */
	    css(property: string): string;
	    /**
	     * Get or set the text content of the HTMLElement.<br/>
	     * @param txt Optional. If given, this will set the text content of the element. If not, will return the text content.
	     * @returns {string}
	     */
	    text(txt?: string): string;
	    /**
	     * Performant way to transform a NodeList to an array of HTMLElement, for manipulation<br/>
	     * http://jsperf.com/nodelist-to-array/72
	     * @param nodeList a {NodeList} to convert to an array
	     * @returns {HTMLElement[]}
	     */
	    static nodeListToArray(nodeList: NodeList): HTMLElement[];
	    /**
	     * Focuses on an element.
	     * @param preserveScroll Whether or not to scroll the page to the focused element.
	     */
	    focus(preserveScroll: boolean): void;
	    /**
	     * Empty (remove all child) from the element;
	     */
	    empty(): void;
	    removeChild(child: Node): void;
	    /**
	     * Empty the element and all childs from the dom;
	     */
	    remove(): void;
	    /**
	     * Show the element by setting display to block;
	     */
	    show(): void;
	    /**
	     * Hide the element;
	     */
	    hide(): void;
	    /**
	     * Show the element by setting display to an empty string.
	     */
	    unhide(): void;
	    /**
	     * Toggle the element visibility.<br/>
	     * Optional visible parameter, if specified will set the element visibility
	     * @param visible Optional parameter to display or hide the element
	     */
	    toggle(visible?: boolean): void;
	    /**
	     * Tries to determine if an element is "visible", in a generic manner.
	     *
	     * This is not meant to be a "foolproof" method, but only a superficial "best effort" detection is performed.
	     */
	    isVisible(): boolean;
	    /**
	     * Returns the value of the specified attribute.
	     * @param name The name of the attribute
	     */
	    getAttribute(name: string): string;
	    /**
	     * Sets the value of the specified attribute.
	     * @param name The name of the attribute
	     * @param value The value to set
	     */
	    setAttribute(name: string, value: string): void;
	    /**
	     * Find a child element, given a CSS selector
	     * @param selector A CSS selector, can be a .className or #id
	     * @returns {HTMLElement}
	     */
	    find(selector: string): HTMLElement;
	    /**
	     * Check if the element match the selector.<br/>
	     * The selector can be a class, an id or a tag.<br/>
	     * Eg : .is('.foo') or .is('#foo') or .is('div').
	     */
	    is(selector: string): boolean;
	    /**
	     * Get the first element that matches the classname by testing the element itself and traversing up through its ancestors in the DOM tree.
	     *
	     * Stops at the body of the document
	     * @param className A CSS classname
	     */
	    closest(className: string): HTMLElement;
	    /**
	     * Get the first element that matches the classname by testing the element itself and traversing up through its ancestors in the DOM tree.
	     *
	     * Stops at the body of the document
	     * @returns {any}
	     */
	    parent(className: string): HTMLElement;
	    /**
	     *  Get all the ancestors of the current element that match the given className
	     *
	     *  Return an empty array if none found.
	     * @param className
	     * @returns {HTMLElement[]}
	     */
	    parents(className: string): HTMLElement[];
	    /**
	     * Return all children
	     * @returns {HTMLElement[]}
	     */
	    children(): HTMLElement[];
	    /**
	     * Return all siblings
	     * @returns {HTMLElement[]}
	     */
	    siblings(selector: string): HTMLElement[];
	    /**
	     * Find all children that match the given CSS selector
	     * @param selector A CSS selector, can be a .className
	     * @returns {HTMLElement[]}
	     */
	    findAll(selector: string): HTMLElement[];
	    /**
	     * Find the child elements using a className
	     * @param className Class of the childs elements to find
	     * @returns {HTMLElement[]}
	     */
	    findClass(className: string): HTMLElement[];
	    /**
	     * Find an element using an ID
	     * @param id ID of the element to find
	     * @returns {HTMLElement}
	     */
	    findId(id: string): HTMLElement;
	    /**
	     * Add a class to the element. Takes care of not adding the same class if the element already has it.
	     * @param className Classname to add to the element
	     */
	    addClass(classNames: string[]): void;
	    addClass(className: string): void;
	    /**
	     * Remove the class on the element. Works even if the element does not possess the class.
	     * @param className Classname to remove on the the element
	     */
	    removeClass(className: string): void;
	    /**
	     * Toggle the class on the element.
	     * @param className Classname to toggle
	     * @param swtch If true, add the class regardless and if false, remove the class
	     */
	    toggleClass(className: string, swtch?: boolean): void;
	    /**
	     * Sets the inner html of the element
	     * @param html The html to set
	     */
	    setHtml(html: string): void;
	    /**
	     * Return an array with all the classname on the element. Empty array if the element has not classname
	     * @returns {any|Array}
	     */
	    getClass(): string[];
	    /**
	     * Check if the element has the given class name
	     * @param className Classname to verify
	     * @returns {boolean}
	     */
	    hasClass(className: string): boolean;
	    /**
	     * Detach the element from the DOM.
	     */
	    detach(): void;
	    /**
	     * Insert the current node after the given reference node
	     * @param refNode
	     */
	    insertAfter(refNode: HTMLElement): void;
	    /**
	     * Insert the current node before the given reference node
	     * @param refNode
	     */
	    insertBefore(refNode: HTMLElement): void;
	    /**
	     * Insert the given node as the first child of the current node
	     * @param toPrepend
	     */
	    prepend(toPrepend: HTMLElement): void;
	    /**
	     * Bind an event handler on the element. Accepts either one (a string) or multiple (Array<String>) event type.<br/>
	     * @param types The {string} or {Array<String>} of types on which to bind an event handler
	     * @param eventHandle The function to execute when the event is triggered
	     */
	    on(types: string[], eventHandle: (evt: Event, data: any) => void): void;
	    on(type: string, eventHandle: (evt: Event, data: any) => void): void;
	    /**
	     * Bind an event handler on the element. Accepts either one (a string) or multiple (Array<String>) event type.<br/>
	     * The event handler will execute only ONE time.
	     * @param types The {string} or {Array<String>} of types on which to bind an event handler
	     * @param eventHandle The function to execute when the event is triggered
	     */
	    one(types: string[], eventHandle: (evt: Event, args?: any) => void): void;
	    one(type: string, eventHandle: (evt: Event, args?: any) => void): void;
	    /**
	     * Remove an event handler on the element. Accepts either one (a string) or multiple (Array<String>) event type.<br/>
	     * @param types The {string} or {Array<String>} of types on which to remove an event handler
	     * @param eventHandle The function to remove on the element
	     */
	    off(types: string[], eventHandle: (evt: Event, arg?: any) => void): void;
	    off(type: string, eventHandle: (evt: Event, arg?: any) => void): void;
	    /**
	     * Trigger an event on the element.
	     * @param type The event type to trigger
	     * @param data
	     */
	    trigger(type: string, data?: {
	        [key: string]: any;
	    }): void;
	    /**
	     * Check if the element is "empty" (has no innerHTML content). Whitespace is considered empty</br>
	     * @returns {boolean}
	     */
	    isEmpty(): boolean;
	    /**
	     * Check if the element is not a locked node (`{ toString(): string }`) and thus have base element properties.
	     * @returns {boolean}
	     */
	    isValid(): boolean;
	    /**
	     * Check if the element is a descendant of parent
	     * @param other
	     */
	    isDescendant(parent: HTMLElement): boolean;
	    /**
	     * Replace the current element with the other element, then detach the current element
	     * @param otherElem
	     */
	    replaceWith(otherElem: HTMLElement): void;
	    /**
	     * Return the position relative to the offset parent.
	     */
	    position(): IOffset;
	    /**
	     * Returns the offset parent. The offset parent is the closest parent that is positioned.
	     * An element is positioned when its position property is not 'static', which is the default.
	     */
	    offsetParent(): HTMLElement;
	    /**
	     * Return the position relative to the document.
	     */
	    offset(): IOffset;
	    /**
	     * Returns the offset width of the element
	     */
	    width(): number;
	    /**
	     * Returns the offset height of the element
	     */
	    height(): number;
	    /**
	     * Clone the node
	     * @param deep true if the children of the node should also be cloned, or false to clone only the specified node.
	     * @returns {Dom}
	     */
	    clone(deep?: boolean): Dom;
	    /**
	     * Determine if an element support a particular native DOM event.
	     * @param eventName The event to evaluate. Eg: touchstart, touchend, click, scroll.
	     */
	    canHandleEvent(eventName: string): boolean;
	}
	class Win {
	    win: Window;
	    constructor(win: Window);
	    height(): number;
	    width(): number;
	    scrollY(): number;
	    scrollX(): number;
	}
	class Doc {
	    doc: Document;
	    constructor(doc: Document);
	    height(): number;
	    width(): number;
	}
	/**
	 * Convenience wrapper for the {@link Dom} class. Used to do $$(element).<br/>
	 * If passed with an argument which is not an HTMLElement, it will call {@link Dom.createElement}.
	 * @param el The HTMLElement to wrap in a Dom object
	 * @param type See {@link Dom.createElement}
	 * @param props See {@link Dom.createElement}
	 * @param ...children See {@link Dom.createElement}
	 */
	function $$(dom: Dom): Dom;
	function $$(html: HTMLElement): Dom;
	function $$(type: string, props?: IStringMap<any>, ...children: Array<string | HTMLElement | Dom>): Dom;

}
declare module Coveo {
	interface IComponentHtmlElement extends HTMLElement {
	    CoveoBoundComponents?: BaseComponent[];
	}
	/**
	 * Every component in the framework ultimately inherits from this base component class.
	 */
	class BaseComponent {
	    element: HTMLElement;
	    type: string;
	    /**
	     * Allows component to log in the dev console.
	     */
	    logger: Logger;
	    /**
	     * A disabled component will not participate in the query, or listen to {@link ComponentEvents}.
	     * @type {boolean}
	     */
	    disabled: boolean;
	    /**
	     * The static ID that each component needs in order to be identified.<br/>
	     * For example, SearchButton -> static ID: SearchButton -> className: CoveoSearchButton
	     */
	    static ID: string;
	    constructor(element: HTMLElement, type: string);
	    /**
	     * Return the debug info about this component.
	     * @returns {any}
	     */
	    debugInfo(): any;
	    /**
	     * Disable the component.
	     * Normally this means that the component will not execute handlers for the framework events (query events, for example).
	     * Components are enabled by default on creation.
	     */
	    disable(): void;
	    /**
	     * Enable the component.
	     * Normally this means that the component will execute handlers for the framework events (query events, for example).
	     * Components are enabled by default on creation.
	     */
	    enable(): void;
	    static bindComponentToElement(element: HTMLElement, component: BaseComponent): void;
	    static computeCssClassName(componentClass: any): string;
	    static computeCssClassNameForType(type: string): string;
	    static computeSelectorForType(type: string): string;
	    static getBoundComponentsForElement(element: IComponentHtmlElement): BaseComponent[];
	    static getComponentRef(component: string): any;
	}

}
declare module Coveo {
	const MODEL_EVENTS: {
	    PREPROCESS: string;
	    CHANGE_ONE: string;
	    CHANGE: string;
	    RESET: string;
	    ALL: string;
	};
	interface IModelSetOptions {
	    silent?: boolean;
	    customAttribute?: boolean;
	    validateType?: boolean;
	}
	interface IAttributeChangedEventArg {
	    attribute: string;
	    value: any;
	}
	interface IAttributesChangedEventArg {
	    attributes: {};
	}
	interface IModelChangedEventArg {
	    model: Model;
	}
	/**
	 * A *model* is a key-value store that triggers various JavaScript events when any value associated to one of its key changes.<br/>
	 * This class is meant to be extended, one of the most 
	 * Components set values in this key-value store and listen to triggered events in order to update themselves accordingly.<br/>
	 */
	class Model extends BaseComponent {
	    /**
	     * The attributes contained in this model.</br>
	     * Normally, you should not set attributes directly on this property, as this would prevent required events from being triggered.
	     */
	    attributes: IStringMap<any>;
	    defaultAttributes: IStringMap<any>;
	    /**
	     * The event types that can be triggered:<br/>
	     * • `preprocess`: triggered before a value is set on an attribute. This allows the value to be modified before it is set.<br/>
	     * • `changeOne`: triggered when a single value changes.</br>
	     * • `change`: triggered when one or many values change.</br>
	     * • `reset`: triggered when all attributes are reset to their default values. </br>
	     * • `all`: triggered after the `change` event.</br>
	     * @type {{preprocess: string, changeOne: string, change: string, reset: string, all: string}}
	     */
	    static eventTypes: {
	        preprocess: string;
	        changeOne: string;
	        change: string;
	        reset: string;
	        all: string;
	    };
	    constructor(element: HTMLElement, id: string, attributes: {
	        [key: string]: any;
	    });
	    /**
	     * Sets the value of a single specific attribute.</br>
	     * Note: this method calls the `setMultiple` method.
	     * @param attribute
	     * the specific attribute whose value is to be set.
	     * @param value
	     * the value to set the attribute to.
	     * @param options
	     * the options (see {@link setMultiple}).
	     */
	    set(attribute: string, value: any, options?: IModelSetOptions): void;
	    /**
	     * Gets an object containing all *active* registered attribute key-values.</br>
	     * An attribute is considered active when its value is not in its default state.
	     * @returns {{object}}
	     */
	    getAttributes(): {
	        [key: string]: any;
	    };
	    /**
	     * Sets the values of one or many attributes.</br>
	     * This method may trigger the following events (in order):</br>
	     * • `preprocess`</br>
	     * • `changeOne`</br>
	     * • `change`</br>
	     * • `all`
	     * @param toSet
	     * the key-value list of attributes with their new intended values.
	     * @param options
	     * if the `customAttribute` option is set to `true`, the method will not validate whether an attribute is registered or not.</br>
	     * If the `validateType` option is set to `true`, the method will ensure that each value type is correct.</br>
	     * If the `silent` option is set to `true`, then the `changeOne`, `change` and `all` events will not be triggered.
	     */
	    setMultiple(toSet: {
	        [key: string]: any;
	    }, options?: IModelSetOptions): void;
	    /**
	     * Sets a new default value to a single specific attribute.</br>
	     * Note: specifying a new attribute default value does not set the attribute to that value. This can be done using the {@link setDefault} method.
	     * @param attribute
	     * the specific attribute whose default value is to be changed.
	     * @param value
	     * the new intended default value.
	     * @param options
	     * if the `customAttribute` option is set to `true`, the method will not validate whether the attribute is registered or not.
	     */
	    setNewDefault(attribute: string, value: any, options?: IModelSetOptions): void;
	    /**
	     * Sets a single specific attribute to its default value.</br>
	     * Note: this method calls the {@link setMultiple} method without specifying any option.
	     * @param attribute
	     * the specific attribute whose value is to be set to its default value.
	     */
	    setDefault(attribute: string): void;
	    /**
	     * Gets the value of a single specific attribute.</br>
	     * If no attribute is specified, the method instead returns an object containing all registered attribute key-values.
	     * @param attribute
	     * the specific attribute whose value should be returned.
	     * @returns {any}
	     */
	    get(attribute?: string): any;
	    /**
	     * Gets the default value of a single specific attribute.</br>
	     * If no attribute is specified, the method instead returns an object containing all registered attribute key-default values.
	     * @param attribute
	     * the specific attribute whose default value should be returned.
	     * @returns {any}
	     */
	    getDefault(attribute?: string): any;
	    /**
	     * Resets each registered attribute to its default value.</br>
	     * Note: this method calls the {@link setMultiple} method without specifying any options.</br>
	     * After the `setMultiple` call has returned, this method triggers the `reset` event.
	     */
	    reset(): void;
	    /**
	     * Registers a new attribute key-value.
	     * @param attribute
	     * the name of the new attribute to register.
	     * @param defaultValue
	     * the newly registered attribute default value.
	     */
	    registerNewAttribute(attribute: string, defaultValue: any): void;
	    /**
	     * Gets a string displaying the event namespace followed by the specific event name. The returned string is formatted thus:</br>
	     * `[eventNameSpace]:[eventName]`
	     * @example `getEventName("reset");` could return `"state:reset"`.
	     * @param event
	     * the event name.
	     * @returns {string}
	     */
	    getEventName(event: string): string;
	    debugInfo(): any;
	}

}
declare module Coveo {
	const QUERY_STATE_ATTRIBUTES: {
	    Q: string;
	    FIRST: string;
	    T: string;
	    TG: string;
	    SORT: string;
	    LAYOUT: string;
	    HD: string;
	    HQ: string;
	    QUICKVIEW: string;
	    DEBUG: string;
	    NUMBER_OF_RESULTS: string;
	    MISSING_TERMS: string;
	};
	interface IQueryStateIncludedAttribute {
	    title: string;
	    included: string[];
	}
	interface IQueryStateExcludedAttribute {
	    title: string;
	    excluded: string[];
	}
	/**
	 * The `QueryStateModel` class is a key-value store which contains the current state of the components that can affect
	 * the query (see [State](https://docs.coveo.com/en/344/)). This class inherits from the [`Model`](https://coveo.github.io/search-ui/classes/model.html)
	 * class. Optionally, it is possible to persist the state in the query string in order to enable browser history
	 * management (see the [`HistoryController`]{@link HistoryController} class).
	 *
	 * Components set values in the `QueryStateModel` instance to reflect their current state. The `QueryStateModel`
	 * triggers state events (see [`eventTypes`]{@link Model.eventTypes}) whevoid one of its values is modified. Components
	 * listen to triggered state events to update themselves when appropriate.
	 *
	 * For instance, when a query is triggered, the [`Searchbox`]{@link Searchbox} component sets the `q` attribute (the
	 * basic query expression), while the [`Pager`]{@link Pager} component sets the `first` attribute (the index of the
	 * first result to display in the result list), and so on.
	 *
	 * **Example:**
	 *
	 * > The user modifies the content of the `Searchbox` and submits a query. This triggers the following state events:
	 * > - `state:change:q` (because the value of `q` has changed).
	 * > - `state:change` (because at least one value has changed in the `QueryStateModel`).
	 * >
	 * > Components or external code can attach handlers to those events:
	 * > ```javascript
	 * > Coveo.$$(document).on('state:change:q', function() {
	 * >   [ ... ]
	 * > });
	 * > ```
	 *
	 * **Note:**
	 * > Normally, you should interact with the `QueryStateModel` instance using the [`Coveo.state`]{@link state} top-level
	 * > function.
	 */
	class QueryStateModel extends Model {
	    static ID: string;
	    static defaultAttributes: {
	        q: string;
	        first: number;
	        fv: string;
	        t: string;
	        hd: string;
	        hq: string;
	        sort: string;
	        layout: string;
	        tg: string;
	        quickview: string;
	        debug: boolean;
	        numberOfResults: number;
	        missingTerms: any[];
	    };
	    static attributesEnum: {
	        q: string;
	        first: string;
	        fv: string;
	        t: string;
	        sort: string;
	        layout: string;
	        hd: string;
	        hq: string;
	        tg: string;
	        quickview: string;
	        debug: string;
	        numberOfResults: string;
	        missingTerms: string;
	    };
	    static getFacetId(id: string, include?: boolean): string;
	    static getFacetOperator(id: string): string;
	    static getFacetLookupValue(id: string): string;
	    /**
	     * Creates a new `QueryStateModel` instance.
	     * @param element The HTMLElement on which to instantiate the `QueryStateModel`.
	     * @param attributes The state key-value store to instantiate the `QueryStateModel` with.
	     */
	    constructor(element: HTMLElement, attributes?: IStringMap<string>);
	    /**
	     * Validates whether at least one facet is currently active (has selected or excluded values) in the interface.
	     *
	     * @returns {boolean} `true` if at least one facet is active; `false` otherwise.
	     */
	    atLeastOneFacetIsActive(): boolean;
	    set(attribute: string, value: any, options?: IModelSetOptions): void;
	}
	function setState(model: Model, args: any[]): any;

}
declare module Coveo {
	class ComponentStateModel extends Model {
	    static ID: string;
	    constructor(element: HTMLElement);
	    registerComponent(componentId: string, component: BaseComponent): void;
	}

}
declare module Coveo {
	const COMPONENT_OPTIONS_ATTRIBUTES: {
	    RESULT_LINK: string;
	    SEARCH_HUB: string;
	    SEARCH_BOX: string;
	};
	interface IComponentOptionsAttributes {
	    resultLink: any;
	    searchHub: string;
	    searchBox: any;
	}
	class ComponentOptionsModel extends Model {
	    static ID: string;
	    static defaultAttributes: IComponentOptionsAttributes;
	    static attributesEnum: {
	        resultLink: string;
	        searchHub: string;
	        searchBox: string;
	    };
	    constructor(element: HTMLElement, attributes?: IComponentOptionsAttributes);
	}

}
declare module Coveo {
	/**
	 * The IAnalyticsActionCause interface describes the cause of an event for the analytics service.
	 *
	 * See the {@link Analytics} component
	 */
	interface IAnalyticsActionCause {
	    /**
	     * Specifies the name of the event. While you can actually set this property to any arbitrary string value, its value
	     * should uniquely identify the precise action that triggers the event. Thus, each individual event should have its
	     * own unique `name` value.
	     *
	     * Example: `searchBoxSubmit`, `resultSort`, etc.
	     */
	    name: string;
	    /**
	     * Specifies the type of the event. While you can actually set this property to any arbitrary string value, it should
	     * describe the general category of the event. Thus, more than one event can have the same `type` value, which makes
	     * it possible to group events with identical types when doing reporting.
	     *
	     * Example: All search box related events could have `searchbox` as their `type` value.
	     */
	    type: string;
	}
	interface IAnalyticsNoMeta {
	}
	interface IAnalyticsInterfaceChange {
	    interfaceChangeTo: string;
	}
	interface IAnalyticsContextAddMeta {
	    contextName: string;
	}
	interface IAnalyticsContextRemoveMeta {
	    contextName: string;
	}
	interface IAnalyticsResultsSortMeta {
	    resultsSortBy: string;
	}
	/**
	 * The `IAnalyticsDocumentViewMeta` interface describes the expected metadata when logging a click event / item view.
	 *
	 * See also the [`Analytics`]{@link Analytics} component, and more specifically its
	 * [`logClickEvent`]{@link Analytics.logClickEvent} method.
	 */
	type IAnalyticsDocumentViewMeta = {
	    /**
	     * The URL of the clicked item.
	     */
	    documentURL?: string;
	    /**
	     * The title of the clicked item.
	     */
	    documentTitle?: string;
	    /**
	     * The author of the clicked item.
	     */
	    author: string;
	};
	interface IAnalyticsOmniboxFacetMeta {
	    facetId: string;
	    facetField: string;
	    facetTitle: string;
	    facetValue?: string;
	    suggestions: string;
	    suggestionRanking: number;
	    query: string;
	}
	interface IAnalyticsSimpleFilterMeta {
	    simpleFilterTitle: string;
	    simpleFilterSelectedValue?: string;
	    simpleFilterField: string;
	}
	interface IAnalyticsFacetMeta {
	    facetId: string;
	    facetField: string;
	    facetValue?: string;
	    facetRangeStart?: string;
	    facetRangeEnd?: string;
	    facetRangeEndInclusive?: boolean;
	    facetTitle: string;
	}
	interface IAnalyticsFacetSortMeta extends IAnalyticsFacetMeta {
	    criteria: string;
	}
	interface IAnalyticsCategoryFacetMeta {
	    categoryFacetId: string;
	    categoryFacetField: string;
	    categoryFacetPath?: string[];
	    categoryFacetTitle: string;
	}
	interface IAnalyticsQueryErrorMeta {
	    query: string;
	    aq: string;
	    cq: string;
	    dq: string;
	    errorType: string;
	    errorMessage: string;
	}
	interface IAnalyticsTopSuggestionMeta {
	    suggestionRanking: number;
	    partialQueries: string;
	    suggestions: string;
	    partialQuery: string;
	}
	interface IAnalyticsOmniboxSuggestionMeta {
	    suggestionRanking: number;
	    partialQueries: string;
	    suggestions: string;
	    partialQuery: string;
	}
	interface IAnalyticsFacetSliderChangeMeta {
	    facetId: string;
	    facetField: string;
	    facetRangeStart: any;
	    facetRangeEnd: any;
	}
	interface IAnalyticsFacetGraphSelectedMeta extends IAnalyticsFacetSliderChangeMeta {
	}
	interface IAnalyticsFacetOperatorMeta extends IAnalyticsFacetMeta {
	    facetOperatorBefore: string;
	    facetOperatorAfter: string;
	}
	interface IAnalyticsPreferencesChangeMeta {
	    preferenceName: string;
	    preferenceType: string;
	}
	interface IAnalyticsCustomFiltersChangeMeta {
	    customFilterName: string;
	    customFilterType: string;
	    customFilterExpression: string;
	}
	interface IAnalyticsCaseAttachMeta {
	    resultUriHash: string;
	    articleID: string;
	    caseID: string;
	    author: string;
	}
	interface IAnalyticsCaseContextAddMeta {
	    caseID: string;
	}
	interface IAnalyticsCaseContextRemoveMeta {
	    caseID: string;
	}
	interface IAnalyticsCaseDetachMeta extends IAnalyticsCaseAttachMeta {
	}
	interface IAnalyticsCaseCreationInputChangeMeta {
	    inputTitle: string;
	    input: string;
	    value: string;
	}
	interface IAnalyticsCaseCreationDeflectionMeta {
	    hasClicks: boolean;
	    values: {
	        [field: string]: string;
	    };
	}
	interface IAnalyticsPagerMeta {
	    pagerNumber: number;
	}
	interface IAnalyticsResultsPerPageMeta {
	    currentResultsPerPage: number;
	}
	interface IAnalyticsTriggerNotify {
	    notifications: string[];
	}
	interface IAnalyticsTriggerRedirect {
	    redirectedTo: string;
	    query?: string;
	}
	interface IAnalyticsTriggerQuery {
	    query: string;
	}
	interface IAnalyticsTriggerExecution {
	    functionName: string;
	    params: (string | number | boolean)[];
	}
	interface IAnalyticsTriggerExecute {
	    executions: IAnalyticsTriggerExecution[];
	}
	interface IAnalyticsSearchAlertsMeta {
	    subscription: string;
	}
	interface IAnalyticsSearchAlertsUpdateMeta extends IAnalyticsSearchAlertsMeta {
	    frequency: string;
	}
	type IAnalyticsSearchAlertsFollowDocumentMeta = IAnalyticsDocumentViewMeta & {
	    documentSource: string;
	    documentLanguage: string[];
	    contentIDKey: string;
	    contentIDValue: string;
	};
	interface IAnalyticsResultsLayoutChange {
	    resultsLayoutChangeTo: string;
	}
	interface IAnalyticsMissingTerm {
	    missingTerm: string;
	}
	interface IAnalyticsSmartSnippetMeta {
	    searchQueryUid: string;
	}
	enum AnalyticsSmartSnippetFeedbackReason {
	    DoesNotAnswer,
	    PartiallyAnswers,
	    WasNotAQuestion,
	    Other,
	}
	interface IAnalyticsSmartSnippetFeedbackMeta extends IAnalyticsSmartSnippetMeta {
	    reason: AnalyticsSmartSnippetFeedbackReason;
	    details?: string;
	}
	interface IAnalyticsSmartSnippetOpenSourceMeta extends IAnalyticsSmartSnippetMeta {
	    /**
	     * The URL of the snippet's source.
	     */
	    documentURL: string;
	    /**
	     * The title of the snippet's source.
	     */
	    documentTitle: string;
	    /**
	     * The author of the snippet's source..
	     */
	    author: string;
	}
	interface IAnalyticsSmartSnippetOpenSnippetInlineLinkMeta extends IAnalyticsSmartSnippetMeta {
	    /**
	     * The URL of the clicked link.
	     */
	    linkURL: string;
	    /**
	     * The text of the clicked link.
	     */
	    linkText: string;
	}
	interface IAnalyticsSmartSnippetSuggestionMeta extends IAnalyticsSmartSnippetMeta {
	    documentId: {
	        contentIdKey: string;
	        contentIdValue: string;
	    };
	}
	interface IAnalyticsSmartSnippetSuggestionOpenSourceMeta extends IAnalyticsSmartSnippetSuggestionMeta {
	    /**
	     * The URL of the snippet's source.
	     */
	    documentURL: string;
	    /**
	     * The title of the snippet's source.
	     */
	    documentTitle: string;
	    /**
	     * The author of the snippet's source..
	     */
	    author: string;
	}
	interface IAnalyticsSmartSnippetSuggestionOpenSnippetInlineLinkMeta extends IAnalyticsSmartSnippetSuggestionMeta {
	    /**
	     * The URL of the clicked link.
	     */
	    linkURL: string;
	    /**
	     * The text of the clicked link.
	     */
	    linkText: string;
	}
	/**
	 * Describes the object sent as metadata along with [`clickQuerySuggestPreview`]{@link analyticsActionCauseList.clickQuerySuggestPreview} usage analytics events.
	 */
	interface IAnalyticsClickQuerySuggestPreviewMeta {
	    /**
	     * The query suggestion for which a preview item was opened.
	     */
	    suggestion: string;
	    /**
	     * The 0-based position of the preview item that was opened.
	     */
	    displayedRank: number;
	}
	var analyticsActionCauseList: {
	    interfaceLoad: IAnalyticsActionCause;
	    interfaceChange: IAnalyticsActionCause;
	    contextRemove: IAnalyticsActionCause;
	    didyoumeanAutomatic: IAnalyticsActionCause;
	    didyoumeanClick: IAnalyticsActionCause;
	    resultsSort: IAnalyticsActionCause;
	    searchboxSubmit: IAnalyticsActionCause;
	    searchboxClear: IAnalyticsActionCause;
	    searchboxAsYouType: IAnalyticsActionCause;
	    breadcrumbFacet: IAnalyticsActionCause;
	    breadcrumbAdvancedSearch: IAnalyticsActionCause;
	    breadcrumbResetAll: IAnalyticsActionCause;
	    documentTag: IAnalyticsActionCause;
	    documentField: IAnalyticsActionCause;
	    documentQuickview: IAnalyticsActionCause;
	    documentOpen: IAnalyticsActionCause;
	    omniboxFacetSelect: IAnalyticsActionCause;
	    omniboxFacetExclude: IAnalyticsActionCause;
	    omniboxFacetDeselect: IAnalyticsActionCause;
	    omniboxFacetUnexclude: IAnalyticsActionCause;
	    omniboxAnalytics: IAnalyticsActionCause;
	    omniboxFromLink: IAnalyticsActionCause;
	    omniboxField: IAnalyticsActionCause;
	    facetClearAll: IAnalyticsActionCause;
	    facetSearch: IAnalyticsActionCause;
	    facetToggle: IAnalyticsActionCause;
	    facetRangeSlider: IAnalyticsActionCause;
	    facetRangeGraph: IAnalyticsActionCause;
	    facetSelect: IAnalyticsActionCause;
	    facetSelectAll: IAnalyticsActionCause;
	    facetDeselect: IAnalyticsActionCause;
	    facetExclude: IAnalyticsActionCause;
	    facetUnexclude: IAnalyticsActionCause;
	    facetUpdateSort: IAnalyticsActionCause;
	    facetShowMore: IAnalyticsActionCause;
	    facetShowLess: IAnalyticsActionCause;
	    categoryFacetSelect: IAnalyticsActionCause;
	    categoryFacetReload: IAnalyticsActionCause;
	    categoryFacetClear: IAnalyticsActionCause;
	    categoryFacetBreadcrumb: IAnalyticsActionCause;
	    categoryFacetSearch: IAnalyticsActionCause;
	    dynamicFacetSelect: IAnalyticsActionCause;
	    dynamicFacetDeselect: IAnalyticsActionCause;
	    dynamicFacetClearAll: IAnalyticsActionCause;
	    dynamicFacetShowMore: IAnalyticsActionCause;
	    dynamicFacetShowLess: IAnalyticsActionCause;
	    errorBack: IAnalyticsActionCause;
	    errorClearQuery: IAnalyticsActionCause;
	    errorRetry: IAnalyticsActionCause;
	    noResultsBack: IAnalyticsActionCause;
	    expandToFullUI: IAnalyticsActionCause;
	    caseCreationInputChange: IAnalyticsActionCause;
	    caseCreationSubmitButton: IAnalyticsActionCause;
	    caseCreationCancelButton: IAnalyticsActionCause;
	    caseCreationUnloadPage: IAnalyticsActionCause;
	    casecontextAdd: IAnalyticsActionCause;
	    casecontextRemove: IAnalyticsActionCause;
	    preferencesChange: IAnalyticsActionCause;
	    getUserHistory: IAnalyticsActionCause;
	    userActionDocumentClick: IAnalyticsActionCause;
	    caseAttach: IAnalyticsActionCause;
	    caseDetach: IAnalyticsActionCause;
	    customfiltersChange: IAnalyticsActionCause;
	    pagerNumber: IAnalyticsActionCause;
	    pagerNext: IAnalyticsActionCause;
	    pagerPrevious: IAnalyticsActionCause;
	    pagerScrolling: IAnalyticsActionCause;
	    pagerResize: IAnalyticsActionCause;
	    positionSet: IAnalyticsActionCause;
	    searchFromLink: IAnalyticsActionCause;
	    triggerNotify: IAnalyticsActionCause;
	    triggerExecute: IAnalyticsActionCause;
	    triggerQuery: IAnalyticsActionCause;
	    triggerRedirect: IAnalyticsActionCause;
	    queryError: IAnalyticsActionCause;
	    exportToExcel: IAnalyticsActionCause;
	    recommendation: IAnalyticsActionCause;
	    recommendationInterfaceLoad: IAnalyticsActionCause;
	    recommendationOpen: IAnalyticsActionCause;
	    advancedSearch: IAnalyticsActionCause;
	    searchAlertsFollowDocument: IAnalyticsActionCause;
	    searchAlertsFollowQuery: IAnalyticsActionCause;
	    searchAlertsUpdateSubscription: IAnalyticsActionCause;
	    searchAlertsDeleteSubscription: IAnalyticsActionCause;
	    searchAlertsUnfollowDocument: IAnalyticsActionCause;
	    searchAlertsUnfollowQuery: IAnalyticsActionCause;
	    simpleFilterSelectValue: IAnalyticsActionCause;
	    simpleFilterDeselectValue: IAnalyticsActionCause;
	    simpleFilterClearAll: IAnalyticsActionCause;
	    resultsLayoutChange: IAnalyticsActionCause;
	    foldingShowMore: IAnalyticsActionCause;
	    foldingShowLess: IAnalyticsActionCause;
	    addMissingTerm: IAnalyticsActionCause;
	    removeMissingTerm: IAnalyticsActionCause;
	    showQuerySuggestPreview: IAnalyticsActionCause;
	    clickQuerySuggestPreview: IAnalyticsActionCause;
	    likeSmartSnippet: IAnalyticsActionCause;
	    dislikeSmartSnippet: IAnalyticsActionCause;
	    expandSmartSnippet: IAnalyticsActionCause;
	    collapseSmartSnippet: IAnalyticsActionCause;
	    openSmartSnippetFeedbackModal: IAnalyticsActionCause;
	    closeSmartSnippetFeedbackModal: IAnalyticsActionCause;
	    sendSmartSnippetReason: IAnalyticsActionCause;
	    openSmartSnippetSource: IAnalyticsActionCause;
	    openSmartSnippetInlineLink: IAnalyticsActionCause;
	    expandSmartSnippetSuggestion: IAnalyticsActionCause;
	    collapseSmartSnippetSuggestion: IAnalyticsActionCause;
	    openSmartSnippetSuggestionSource: IAnalyticsActionCause;
	    openSmartSnippetSuggestionInlineLink: IAnalyticsActionCause;
	};

}
declare module Coveo {
	interface IAPIAnalyticsEventResponse {
	    visitId: string;
	    visitorId: string;
	}

}
declare module Coveo {
	/**
	 * Describe a request to get top queries
	 */
	interface ITopQueries extends IStringMap<any> {
	    /**
	     * Determine how many suggestions to receive
	     */
	    pageSize: number;
	    /**
	     * The query text for which to receive suggestions
	     */
	    queryText: string;
	}

}
declare module Coveo {
	/**
	 * The common subset of fields used to describe Coveo Cloud usage analytics [_search_]{@link ISearchEvent}, [_click_](@link IClickEvent), and [_custom_](@link ICustomEvent) events.
	 */
	interface IAnalyticsEvent {
	    /**
	     * The unique identifier of the related query.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related Search API query response.
	     *
	     * **Example:** `74682726-0e20-46eb-85ac-f37259346f57`
	     */
	    searchQueryUid: string;
	    /**
	     * A unique name describing the action that triggered the event.
	     *
	     * See the [`name`](https://coveo.github.io/search-ui/interfaces/ianalyticsactioncause.html#name) property of the [`IAnalyticsActionCause`](https://coveo.github.io/search-ui/interfaces/ianalyticsactioncause.html) interface.
	     *
	     * **Example:** `pagerNext`
	     */
	    actionCause: string;
	    /**
	     * A name describing the category of actions to which the action that triggered the event belongs.
	     *
	     * See the [`type`](https://coveo.github.io/search-ui/interfaces/ianalyticsactioncause.html#type) property of the [`IAnalyticsActionCause`](https://coveo.github.io/search-ui/interfaces/ianalyticsactioncause.html) interface.
	     *
	     * **Example:** `getMoreResults`
	     */
	    actionType: string;
	    /**
	     * The identifier of the end-user whose action triggered the event.
	     *
	     * **Note:** This field is normally set to the [`user`](https://coveo.github.io/search-ui/components/analytics.html#options.user) option value of the [`Analytics`](https://coveo.github.io/search-ui/components/analytics.html) component. However, when actually recording the event, the Coveo Cloud usage analytics service may override this value with information extracted from the search token.
	     *
	     * **Example:** `asmith@example.com`
	     */
	    username?: string;
	    /**
	     * The display name of the end-user whose action triggered the event.
	     *
	     * **Note:** This field is normally set to the [`userDisplayName`](https://coveo.github.io/search-ui/components/analytics.html#options.userdisplayname) option value of the [`Analytics`](https://coveo.github.io/search-ui/components/analytics.html) component. However, when actually recording the event, the Coveo Cloud usage analytics service may override this value with information extracted from the search token.
	     *
	     * **Example:** `Alice Smith`
	     */
	    userDisplayName?: string;
	    /**
	     * Whether the event should be logged anonymously to the Coveo Cloud usage analytics service.
	     *
	     * **Note:** This field is normally set to the [`anonymous`](https://coveo.github.io/search-ui/components/analytics.html#options.anonymous) option value of the [`Analytics`](https://coveo.github.io/search-ui/components/analytics.html) component.
	     */
	    anonymous?: boolean;
	    /**
	     * The name of the device or browser that triggered the event.
	     *
	     * **Note:** The framework normally sets this field by parsing the current `navigator.userAgent` value.
	     *
	     * **Example:** `Chrome`
	     */
	    device: string;
	    /**
	     * Whether the event originates from a mobile device.
	     *
	     * **Note:** The framework normally sets this field by parsing the current `navigator.userAgent` value.
	     */
	    mobile: boolean;
	    /**
	     * The identifier of the search interface from which the event originates.
	     *
	     * **Note:** This field is normally set through the [`searchHub`](https://coveo.github.io/search-ui/components/analytics.html#options.searchhub) option of the [`Analytics`](https://coveo.github.io/search-ui/components/analytics.html) component. However, when actually recording the event, the Coveo Cloud usage analytics service may override this value with information extracted from the search token.
	     *
	     * **Example:** `PartnerPortalSearch`
	     */
	    originLevel1: string;
	    /**
	     * The identifier of the tab from which the event originates.
	     *
	     * **Note:** The framework normally sets this field to the identifier of the currently selected [`Tab`](https://coveo.github.io/search-ui/components/tab.html) in the search interface.
	     *
	     * **Example:** `All`
	     */
	    originLevel2: string;
	    /**
	     * The address of the webpage that linked to the search interface from which the event originates.
	     *
	     * **Note:** The framework normally sets this field to the current `document.referrer` value.
	     *
	     * **Example:** `http://example.com/`
	     */
	    originLevel3?: string;
	    /**
	     * The broad application context from which the event originates.
	     *
	     * **Note:** By default, the framework sets this field to `Search`. However, you can use the [`setOriginContext`](https://coveo.github.io/search-ui/components/analytics.html#setorigincontext) method of the [`Analytics`](https://coveo.github.io/search-ui/components/analytics.html) component to modify the default value.
	     *
	     * **Example:** `Search`
	     */
	    originContext: string;
	    /**
	     * The language of the search interface from which the event originates.
	     *
	     * Must be a valid [ISO-639-1 code](https://en.wikipedia.org/wiki/ISO_639-1).
	     *
	     * **Note:** By default, the framework sets this field according to the currently loaded culture file (see [Changing the Language of Your Search Interface](https://docs.coveo.com/en/421/)).
	     *
	     * **Example:** `en`
	     */
	    language: string;
	    /**
	     * The time it took to get a response from the Search API for the query related to the event (in milliseconds).
	     *
	     * **Note:** The framework normally sets this field to `0`, except for [search events]{@link ISearchEvent} in which case it sets the field by retrieving the information from the related Search API query response.
	     *
	     */
	    responseTime: number;
	    /**
	     * The software acting on behalf of the end-user whose action triggered the event.
	     *
	     * **Note:** By default, the framework sets this field to the current `navigator.userAgent` value.
	     *
	     * **Example:** `Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36`
	     */
	    userAgent?: string;
	    /**
	     * The groups the end-user whose action triggered the event belongs to.
	     *
	     * **Note:** This field is normally left any, and the Coveo Cloud usage analytics service attempts to extract the information from the search token when actually recording the event.
	     */
	    userGroups?: string;
	    /**
	     * Additional metadata to send along with the event.
	     *
	     * **Note:** This field may include custom user context information (see [Sending Custom Context Information](https://docs.coveo.com/en/399/)).
	     *
	     * **Example:** `{ "currentResultsPerPage": 25, "userRole": "developer" }`
	     */
	    customData?: {
	        [key: string]: any;
	    };
	    /**
	     * A GUID representing the current user. This GUID is generated locally and stored in a non-expiring browser cookie.
	     */
	    clientId: string;
	}

}
declare module Coveo {
	/**
	 * Describes the current condition of a single dynamic facet value.
	 */
	interface IAnalyticsFacetState {
	    /**
	     * The name of the field the dynamic facet displaying the value is based on.
	     *
	     * **Example:** `author`
	     */
	    field: string;
	    /**
	     * The unique identifier of the dynamic facet displaying the value.
	     *
	     * **Example:** `author`
	     */
	    id: string;
	    /**
	     * The title of the dynamic facet.
	     *
	     * **Example:** `Author`
	     */
	    title: string;
	    /**
	     * The original name (i.e., field value) of the dynamic facet value.
	     *
	     * **Example:** `alice_r_smith`
	     */
	    value?: string;
	    /**
	     * The minimum value of the dynamic range facet value.
	     *
	     * **Examples:**
	     * > - `0`
	     * > - `2018-01-01T00:00:00.000Z`
	     */
	    start?: string;
	    /**
	     * The maximum value of the dynamic range facet value.
	     *
	     * **Examples:**
	     * > - `500`
	     * > - `2018-12-31T23:59:59.999Z`
	     */
	    end?: string;
	    /**
	     * Whether the [`end`]{@link IRangeValue.end} value is included in the dynamic range facet value.
	     */
	    endInclusive?: boolean;
	    /**
	     * The current 1-based position of the dynamic facet value, relative to other values in the same dynamic facet.
	     */
	    valuePosition?: number;
	    /**
	     * The custom display name of the dynamic facet value that was interacted with.
	     *
	     * **Example:** `Alice R. Smith`
	     */
	    displayValue?: string;
	    /**
	     * The type of values displayed in the dynamic facet.
	     */
	    facetType?: FacetType;
	    /**
	     * The new state of the dynamic facet value that was interacted with.
	     */
	    state?: FacetValueState;
	    facetPosition?: number;
	}

}
declare module Coveo {
	/**
	 * Describes a Coveo Cloud usage analytics _search_ event.
	 */
	interface ISearchEvent extends IAnalyticsEvent {
	    /**
	     * The name of the query pipeline to which the related query was routed.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related Search API query response.
	     *
	     * **Example:** `PartnerPortalSearchPipeline`
	     */
	    queryPipeline: string;
	    /**
	     * The name of the A/B test that applied to the related query.
	     *
	     * **Note:** This field may be set through the `splitTestRunName` option of the `Analytics` component. However, if the option is left any, the framework attempts to set this field by retrieving information from the related Search API query response.
	     *
	     * **Example:** `Test new ART model`
	     */
	    splitTestRunName: string;
	    /**
	     * The version of the A/B test that applied to the related query (i.e., version A or version B).
	     *
	     * **Note:** This field may be set through the `splitTestRunVersion` option of the `Analytics` component. However, if the option is left any and the related Search API query response indicates that an A/B test was applied, the framework sets this field to the name of the query pipeline to which the query was routed.
	     *
	     * **Example:** `PartnerPortalSearchPipelineWithART`
	     */
	    splitTestRunVersion: string;
	    /**
	     * The original basic query expression (i.e., `q`) sent for the related query.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related query.
	     *
	     * **Example:** `coveo machine learning`
	     */
	    queryText: string;
	    /**
	     * The number of query result items returned by the related query.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related Search API query response.
	     */
	    numberOfResults: number;
	    /**
	     * The number of results per page requested for the related query.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related query.
	     */
	    resultsPerPage: number;
	    /**
	     * The 0-based page of results requested for the related query.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related query.
	     */
	    pageNumber: number;
	    /**
	     * The original advanced query expression (i.e., `aq`) sent for the related query.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related query.
	     */
	    advancedQuery: string;
	    /**
	     * Whether the _did you mean_ feature was enabled for the related query.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related query.
	     *
	     * **Example:** `@source=="Product Documentation"`
	     */
	    didYouMean: boolean;
	    /**
	     * Whether the related query was contextual.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related query.
	     */
	    contextual: boolean;
	    /**
	     * A representation of the state of each dynamic facet in the search interface when the action that triggered the event was executed.
	     */
	    facetState?: IAnalyticsFacetState[];
	}

}
declare module Coveo {
	interface IAPIAnalyticsSearchEventsResponse {
	    searchEventResponses: IAPIAnalyticsEventResponse[];
	}

}
declare module Coveo {
	/**
	 * Describes a Coveo Cloud usage analytics _click_ event.
	 */
	interface IClickEvent extends IAnalyticsEvent {
	    /**
	     * The name of the query pipeline to which the Search API query that returned the clicked result item was routed.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related Search API query response.
	     *
	     * **Example:** `PartnerPortalSearchPipeline`
	     */
	    queryPipeline: string;
	    /**
	     * The name of the A/B test that applied to the related Search API query.
	     *
	     * **Note:** This field is normally set by the `splitTestRunName` option of the `Analytics` component. However, if this option is left any, the framework attempts to set this field by retrieving information from the related Search API query response.
	     *
	     * **Example:** `Testing new ART model`
	     */
	    splitTestRunName: string;
	    /**
	     * The version of the A/B test that applied to the related Search API query (i.e., version A or version B).
	     *
	     * **Note:** This field is normally set by the `splitTestRunVersion` option of the `Analytics` component. However, if this option is left any and the related Search API query response indicates that an A/B test was applied, the framework sets this field to the name of the query pipeline to which the query was routed.
	     *
	     * **Example:** `PartnerPortalSearchPipelineWithART`
	     */
	    splitTestRunVersion: string;
	    /**
	     * The URI of the clicked query result item.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related Search API query response.
	     *
	     * **Example:** `http://www.example.com/org:organization/articletype:FAQ/article:aB1c2000000A1BcDEF/language:en_US`
	     */
	    documentUri: string;
	    /**
	     * The hashed URI of the clicked query result item.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related Search API query response.
	     *
	     * **Example:** `AbCñdeFghiJKLM1n`
	     */
	    documentUriHash: string;
	    /**
	     * The URL of the clicked query result item.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related Search API query response.
	     *
	     * **Example:** `https://example.com/aB1c2000000A1Bc`
	     */
	    documentUrl: string;
	    /**
	     * The title of the clicked query result item.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related Search API query response.
	     *
	     * **Example:** `Coveo ML Frequently Asked Questions`
	     */
	    documentTitle: string;
	    /**
	     * The type of query result item that was clicked.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related Search API query response.
	     *
	     * **Example:** `FAQ`
	     */
	    documentCategory: string;
	    /**
	     * The name of the collection to which the clicked query result item belongs.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related Search API query response.
	     *
	     * **Example:** `default`
	     */
	    collectionName: string;
	    /**
	     * The name of the source that contains the clicked query result item.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related Search API query response.
	     *
	     * **Example:** `Product Documentation`
	     */
	    sourceName: string;
	    /**
	     * The 1-based position of the clicked item in the query results set.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related Search API query response.
	     */
	    documentPosition: number;
	    /**
	     * The way the item was clicked.
	     *
	     * **Note:** The framework normally sets this field to the exact same value as [`actionCause`]{@link IAnalyticsEvent.actionCause}.
	     *
	     * **Example:** `documentOpen`
	     */
	    viewMethod: string;
	    /**
	     * The ranking modifier that was applied to the clicked query result item.
	     *
	     * **Note:** The framework normally sets this field by retrieving the information from the related Search API query response.
	     *
	     * **Example:** `Reveal ART`
	     */
	    rankingModifier: string;
	}

}
declare module Coveo {
	interface IUrlNormalize {
	    paths: string[] | string;
	    queryAsString?: string[] | string;
	    query?: any;
	}
	interface IUrlNormalizedParts {
	    pathsNormalized: string[];
	    queryNormalized: string[];
	    path: string;
	}
	class UrlUtils {
	    static getUrlParameter(name: string): string;
	    static merge(endpointParameters: IEndpointCallParameters, ...parts: IUrlNormalize[]): IEndpointCallParameters;
	    static normalizeAsString(toNormalize: IUrlNormalize): string;
	    static normalizeAsParts(toNormalize: IUrlNormalize): IUrlNormalizedParts;
	}

}
declare module Coveo {
	class AnalyticsEndpointCaller implements IEndpointCaller {
	    options: IEndpointCallerOptions;
	    constructor(options?: IEndpointCallerOptions);
	    call<T>(params: IEndpointCallParameters): Promise<ISuccessResponse<T>>;
	}

}
declare module Coveo {
	type onTokenRefreshed = (newToken: string) => void;
	enum ACCESS_TOKEN_ERRORS {
	    NO_RENEW_FUNCTION,
	    REPEATED_FAILURES,
	}
	class AccessToken {
	    token: string;
	    renew: () => Promise<string>;
	    constructor(token: string, renew?: () => Promise<string>);
	    updateToken(token: string): void;
	    doRenew(onError?: (error: Error) => void): Promise<Boolean>;
	    subscribeToRenewal(onTokenRefreshed: onTokenRefreshed): void;
	}

}
declare module Coveo {
	interface IAPIAnalyticsVisitResponseRest {
	    id: string;
	}

}
declare module Coveo {
	/**
	 * Describes a Coveo Cloud usage analytics _custom_ event.
	 */
	interface ICustomEvent extends IAnalyticsEvent {
	    /**
	     * A name describing the category of actions to which the action that triggered the event belongs.
	     *
	     * **Note:** Normally, this field is set to the same value as [`actionType`]{@link IAnalyticsEvent.actionType}.
	     *
	     * **Example:** `getMoreResults`
	     */
	    eventType: string;
	    /**
	     * A unique name describing the action that triggered the event.
	     *
	     * **Note:** Normally, this field is set to the same value as [`actionCause`]{@link IAnalyticsEvent.actionCause}.
	     *
	     * **Example:** `pagerNext`
	     */
	    eventValue: string;
	}

}
declare module Coveo {

}
declare module Coveo {
	class Defer {
	    static defer(code: () => void): void;
	    static flush(): void;
	}

}
declare module Coveo {
	var L10N: {
	    format: (key: string, ...args: any[]) => string;
	    formatPlSn: (value: string, count: number | boolean) => string;
	};

}
declare module Coveo {
	class Options {
	    merge<T>(provided: T): T;
	    mergeDeep<T>(provided: T): T;
	}

}
declare module Coveo {
	function l(str: "box user"): any;
	function l(str: "filetype_box user"): any;
	function l(str: "html"): any;
	function l(str: "filetype_html"): any;
	function l(str: "wiki"): any;
	function l(str: "filetype_wiki"): any;
	function l(str: "webscraperwebpage"): any;
	function l(str: "filetype_webscraperwebpage"): any;
	function l(str: "image"): any;
	function l(str: "filetype_image"): any;
	function l(str: "folder"): any;
	function l(str: "filetype_folder"): any;
	function l(str: "txt"): any;
	function l(str: "filetype_txt"): any;
	function l(str: "zip"): any;
	function l(str: "filetype_zip"): any;
	function l(str: "olefile"): any;
	function l(str: "filetype_olefile"): any;
	function l(str: "gmailmessage"): any;
	function l(str: "filetype_gmailmessage"): any;
	function l(str: "pdf"): any;
	function l(str: "filetype_pdf"): any;
	function l(str: "swf"): any;
	function l(str: "filetype_swf"): any;
	function l(str: "xml"): any;
	function l(str: "filetype_xml"): any;
	function l(str: "vsd"): any;
	function l(str: "filetype_vsd"): any;
	function l(str: "svg"): any;
	function l(str: "filetype_svg"): any;
	function l(str: "svm"): any;
	function l(str: "filetype_svm"): any;
	function l(str: "rssitem"): any;
	function l(str: "filetype_rssitem"): any;
	function l(str: "doc"): any;
	function l(str: "filetype_doc"): any;
	function l(str: "docx"): any;
	function l(str: "filetype_docx"): any;
	function l(str: "xls"): any;
	function l(str: "filetype_xls"): any;
	function l(str: "ppt"): any;
	function l(str: "filetype_ppt"): any;
	function l(str: "video"): any;
	function l(str: "filetype_video"): any;
	function l(str: "youtube"): any;
	function l(str: "filetype_youtube"): any;
	function l(str: "saleforceitem"): any;
	function l(str: "filetype_saleforceitem"): any;
	function l(str: "dynamicscrmitem"): any;
	function l(str: "filetype_dynamicscrmitem"): any;
	function l(str: "salesforceitem"): any;
	function l(str: "filetype_salesforceitem"): any;
	function l(str: "odt"): any;
	function l(str: "filetype_odt"): any;
	function l(str: "box"): any;
	function l(str: "filetype_box"): any;
	function l(str: "jiraissue"): any;
	function l(str: "filetype_jiraissue"): any;
	function l(str: "cfpage"): any;
	function l(str: "filetype_cfpage"): any;
	function l(str: "cfcomment"): any;
	function l(str: "filetype_cfcomment"): any;
	function l(str: "cfspace"): any;
	function l(str: "filetype_cfspace"): any;
	function l(str: "cfblogentry"): any;
	function l(str: "filetype_cfblogentry"): any;
	function l(str: "confluencespace"): any;
	function l(str: "filetype_confluencespace"): any;
	function l(str: "exchangemessage"): any;
	function l(str: "filetype_exchangemessage"): any;
	function l(str: "exchangeappointment"): any;
	function l(str: "filetype_exchangeappointment"): any;
	function l(str: "exchangenote"): any;
	function l(str: "filetype_exchangenote"): any;
	function l(str: "exchangetask"): any;
	function l(str: "filetype_exchangetask"): any;
	function l(str: "exchangeperson"): any;
	function l(str: "filetype_exchangeperson"): any;
	function l(str: "activedirperson"): any;
	function l(str: "filetype_activedirperson"): any;
	function l(str: "exchangeactivity"): any;
	function l(str: "filetype_exchangeactivity"): any;
	function l(str: "exchangecalendarmessage"): any;
	function l(str: "filetype_exchangecalendarmessage"): any;
	function l(str: "exchangedocument"): any;
	function l(str: "filetype_exchangedocument"): any;
	function l(str: "exchangedsn"): any;
	function l(str: "filetype_exchangedsn"): any;
	function l(str: "exchangefreebusy"): any;
	function l(str: "filetype_exchangefreebusy"): any;
	function l(str: "exchangegroup"): any;
	function l(str: "filetype_exchangegroup"): any;
	function l(str: "exchangerssfeed"): any;
	function l(str: "filetype_exchangerssfeed"): any;
	function l(str: "exchangejunkmessage"): any;
	function l(str: "filetype_exchangejunkmessage"): any;
	function l(str: "exchangeofficecom"): any;
	function l(str: "filetype_exchangeofficecom"): any;
	function l(str: "lithiummessage"): any;
	function l(str: "filetype_lithiummessage"): any;
	function l(str: "lithiumthread"): any;
	function l(str: "filetype_lithiumthread"): any;
	function l(str: "lithiumboard"): any;
	function l(str: "filetype_lithiumboard"): any;
	function l(str: "lithiumcategory"): any;
	function l(str: "filetype_lithiumcategory"): any;
	function l(str: "lithiumcommunity"): any;
	function l(str: "filetype_lithiumcommunity"): any;
	function l(str: "people"): any;
	function l(str: "objecttype_people"): any;
	function l(str: "message"): any;
	function l(str: "objecttype_message"): any;
	function l(str: "feed"): any;
	function l(str: "objecttype_feed"): any;
	function l(str: "thread"): any;
	function l(str: "objecttype_thread"): any;
	function l(str: "file"): any;
	function l(str: "objecttype_file"): any;
	function l(str: "board"): any;
	function l(str: "objecttype_board"): any;
	function l(str: "category"): any;
	function l(str: "objecttype_category"): any;
	function l(str: "account"): any;
	function l(str: "objecttype_account"): any;
	function l(str: "annotation"): any;
	function l(str: "objecttype_annotation"): any;
	function l(str: "campaign"): any;
	function l(str: "objecttype_campaign"): any;
	function l(str: "case"): any;
	function l(str: "objecttype_case"): any;
	function l(str: "contact"): any;
	function l(str: "objecttype_contact"): any;
	function l(str: "contract"): any;
	function l(str: "objecttype_contract"): any;
	function l(str: "event"): any;
	function l(str: "objecttype_event"): any;
	function l(str: "email"): any;
	function l(str: "objecttype_email"): any;
	function l(str: "goal"): any;
	function l(str: "objecttype_goal"): any;
	function l(str: "incident"): any;
	function l(str: "objecttype_incident"): any;
	function l(str: "invoice"): any;
	function l(str: "objecttype_invoice"): any;
	function l(str: "lead"): any;
	function l(str: "objecttype_lead"): any;
	function l(str: "list"): any;
	function l(str: "objecttype_list"): any;
	function l(str: "solution"): any;
	function l(str: "objecttype_solution"): any;
	function l(str: "report"): any;
	function l(str: "objecttype_report"): any;
	function l(str: "task"): any;
	function l(str: "objecttype_task"): any;
	function l(str: "user"): any;
	function l(str: "objecttype_user"): any;
	function l(str: "attachment"): any;
	function l(str: "objecttype_attachment"): any;
	function l(str: "casecomment"): any;
	function l(str: "objecttype_casecomment"): any;
	function l(str: "opportunity"): any;
	function l(str: "objecttype_opportunity"): any;
	function l(str: "opportunityproduct"): any;
	function l(str: "objecttype_opportunityproduct"): any;
	function l(str: "feeditem"): any;
	function l(str: "objecttype_feeditem"): any;
	function l(str: "feedcomment"): any;
	function l(str: "objecttype_feedcomment"): any;
	function l(str: "note"): any;
	function l(str: "objecttype_note"): any;
	function l(str: "product"): any;
	function l(str: "objecttype_product"): any;
	function l(str: "partner"): any;
	function l(str: "objecttype_partner"): any;
	function l(str: "queueitem"): any;
	function l(str: "objecttype_queueitem"): any;
	function l(str: "quote"): any;
	function l(str: "objecttype_quote"): any;
	function l(str: "salesliterature"): any;
	function l(str: "objecttype_salesliterature"): any;
	function l(str: "salesorder"): any;
	function l(str: "objecttype_salesorder"): any;
	function l(str: "service"): any;
	function l(str: "objecttype_service"): any;
	function l(str: "socialprofile"): any;
	function l(str: "objecttype_socialprofile"): any;
	function l(str: "kbdocumentation"): any;
	function l(str: "objecttype_kbdocumentation"): any;
	function l(str: "kbtechnicalarticle"): any;
	function l(str: "objecttype_kbtechnicalarticle"): any;
	function l(str: "kbsolution"): any;
	function l(str: "objecttype_kbsolution"): any;
	function l(str: "kbknowledgearticle"): any;
	function l(str: "objecttype_kbknowledgearticle"): any;
	function l(str: "kbattachment"): any;
	function l(str: "objecttype_kbattachment"): any;
	function l(str: "kbarticle"): any;
	function l(str: "objecttype_kbarticle"): any;
	function l(str: "kbarticlecomment"): any;
	function l(str: "objecttype_kbarticlecomment"): any;
	function l(str: "knowledgearticle"): any;
	function l(str: "objecttype_knowledgearticle"): any;
	function l(str: "topic"): any;
	function l(str: "objecttype_topic"): any;
	function l(str: "dashboard"): any;
	function l(str: "objecttype_dashboard"): any;
	function l(str: "contentversion"): any;
	function l(str: "objecttype_contentversion"): any;
	function l(str: "collaborationgroup"): any;
	function l(str: "objecttype_collaborationgroup"): any;
	function l(str: "phonecall"): any;
	function l(str: "objecttype_phonecall"): any;
	function l(str: "appointment"): any;
	function l(str: "objecttype_appointment"): any;
	function l(str: "sn_hr_core_case"): any;
	function l(str: "filetype_sn_hr_core_case"): any;
	function l(str: "sc_cat_item"): any;
	function l(str: "filetype_sc_cat_item"): any;
	function l(str: "sn_customerservice_case"): any;
	function l(str: "filetype_sn_customerservice_case"): any;
	function l(str: "kb_social_qa_answer"): any;
	function l(str: "filetype_kb_social_qa_answer"): any;
	function l(str: "kb_social_qa_question"): any;
	function l(str: "filetype_kb_social_qa_question"): any;
	function l(str: "kb_social_qa_comment"): any;
	function l(str: "filetype_kb_social_qa_comment"): any;
	function l(str: "filetype_incident"): any;
	function l(str: "kb_knowledge"): any;
	function l(str: "filetype_kb_knowledge"): any;
	function l(str: "spportal"): any;
	function l(str: "filetype_spportal"): any;
	function l(str: "spsite"): any;
	function l(str: "filetype_spsite"): any;
	function l(str: "spuserprofile"): any;
	function l(str: "filetype_spuserprofile"): any;
	function l(str: "sparea"): any;
	function l(str: "filetype_sparea"): any;
	function l(str: "spannouncement"): any;
	function l(str: "filetype_spannouncement"): any;
	function l(str: "spannouncementlist"): any;
	function l(str: "filetype_spannouncementlist"): any;
	function l(str: "spcontact"): any;
	function l(str: "filetype_spcontact"): any;
	function l(str: "spcontactlist"): any;
	function l(str: "filetype_spcontactlist"): any;
	function l(str: "spcustomlist"): any;
	function l(str: "filetype_spcustomlist"): any;
	function l(str: "spdiscussionboard"): any;
	function l(str: "filetype_spdiscussionboard"): any;
	function l(str: "spdiscussionboardlist"): any;
	function l(str: "filetype_spdiscussionboardlist"): any;
	function l(str: "spdocumentlibrarylist"): any;
	function l(str: "filetype_spdocumentlibrarylist"): any;
	function l(str: "spevent"): any;
	function l(str: "filetype_spevent"): any;
	function l(str: "speventlist"): any;
	function l(str: "filetype_speventlist"): any;
	function l(str: "spformlibrarylist"): any;
	function l(str: "filetype_spformlibrarylist"): any;
	function l(str: "spissue"): any;
	function l(str: "filetype_spissue"): any;
	function l(str: "spissuelist"): any;
	function l(str: "filetype_spissuelist"): any;
	function l(str: "splink"): any;
	function l(str: "filetype_splink"): any;
	function l(str: "splinklist"): any;
	function l(str: "filetype_splinklist"): any;
	function l(str: "sppicturelibrarylist"): any;
	function l(str: "filetype_sppicturelibrarylist"): any;
	function l(str: "spsurvey"): any;
	function l(str: "filetype_spsurvey"): any;
	function l(str: "spsurveylist"): any;
	function l(str: "filetype_spsurveylist"): any;
	function l(str: "sptask"): any;
	function l(str: "filetype_sptask"): any;
	function l(str: "sptasklist"): any;
	function l(str: "filetype_sptasklist"): any;
	function l(str: "spagenda"): any;
	function l(str: "filetype_spagenda"): any;
	function l(str: "spagendalist"): any;
	function l(str: "filetype_spagendalist"): any;
	function l(str: "spattendee"): any;
	function l(str: "filetype_spattendee"): any;
	function l(str: "spattendeelist"): any;
	function l(str: "filetype_spattendeelist"): any;
	function l(str: "spcustomgridlist"): any;
	function l(str: "filetype_spcustomgridlist"): any;
	function l(str: "spdecision"): any;
	function l(str: "filetype_spdecision"): any;
	function l(str: "spdecisionlist"): any;
	function l(str: "filetype_spdecisionlist"): any;
	function l(str: "spobjective"): any;
	function l(str: "filetype_spobjective"): any;
	function l(str: "spobjectivelist"): any;
	function l(str: "filetype_spobjectivelist"): any;
	function l(str: "sptextbox"): any;
	function l(str: "filetype_sptextbox"): any;
	function l(str: "sptextboxlist"): any;
	function l(str: "filetype_sptextboxlist"): any;
	function l(str: "spthingstobring"): any;
	function l(str: "filetype_spthingstobring"): any;
	function l(str: "spthingstobringlist"): any;
	function l(str: "filetype_spthingstobringlist"): any;
	function l(str: "sparealisting"): any;
	function l(str: "filetype_sparealisting"): any;
	function l(str: "spmeetingserie"): any;
	function l(str: "filetype_spmeetingserie"): any;
	function l(str: "spmeetingserielist"): any;
	function l(str: "filetype_spmeetingserielist"): any;
	function l(str: "spsitedirectory"): any;
	function l(str: "filetype_spsitedirectory"): any;
	function l(str: "spsitedirectorylist"): any;
	function l(str: "filetype_spsitedirectorylist"): any;
	function l(str: "spdatasource"): any;
	function l(str: "filetype_spdatasource"): any;
	function l(str: "spdatasourcelist"): any;
	function l(str: "filetype_spdatasourcelist"): any;
	function l(str: "splisttemplatecataloglist"): any;
	function l(str: "filetype_splisttemplatecataloglist"): any;
	function l(str: "spwebpartcataloglist"): any;
	function l(str: "filetype_spwebpartcataloglist"): any;
	function l(str: "spwebtemplatecataloglist"): any;
	function l(str: "filetype_spwebtemplatecataloglist"): any;
	function l(str: "spworkspacepagelist"): any;
	function l(str: "filetype_spworkspacepagelist"): any;
	function l(str: "spunknownlist"): any;
	function l(str: "filetype_spunknownlist"): any;
	function l(str: "spadministratortask"): any;
	function l(str: "filetype_spadministratortask"): any;
	function l(str: "spadministratortasklist"): any;
	function l(str: "filetype_spadministratortasklist"): any;
	function l(str: "spareadocumentlibrarylist"): any;
	function l(str: "filetype_spareadocumentlibrarylist"): any;
	function l(str: "spblogcategory"): any;
	function l(str: "filetype_spblogcategory"): any;
	function l(str: "spblogcategorylist"): any;
	function l(str: "filetype_spblogcategorylist"): any;
	function l(str: "spblogcomment"): any;
	function l(str: "filetype_spblogcomment"): any;
	function l(str: "spblogcommentlist"): any;
	function l(str: "filetype_spblogcommentlist"): any;
	function l(str: "spblogpost"): any;
	function l(str: "filetype_spblogpost"): any;
	function l(str: "spblogpostlist"): any;
	function l(str: "filetype_spblogpostlist"): any;
	function l(str: "spdataconnectionlibrarylist"): any;
	function l(str: "filetype_spdataconnectionlibrarylist"): any;
	function l(str: "spdistributiongroup"): any;
	function l(str: "filetype_spdistributiongroup"): any;
	function l(str: "spdistributiongrouplist"): any;
	function l(str: "filetype_spdistributiongrouplist"): any;
	function l(str: "spipfslist"): any;
	function l(str: "filetype_spipfslist"): any;
	function l(str: "spkeyperformanceindicator"): any;
	function l(str: "filetype_spkeyperformanceindicator"): any;
	function l(str: "spkeyperformanceindicatorlist"): any;
	function l(str: "filetype_spkeyperformanceindicatorlist"): any;
	function l(str: "splanguagesandtranslator"): any;
	function l(str: "filetype_splanguagesandtranslator"): any;
	function l(str: "splanguagesandtranslatorlist"): any;
	function l(str: "filetype_splanguagesandtranslatorlist"): any;
	function l(str: "spmasterpagescataloglist"): any;
	function l(str: "filetype_spmasterpagescataloglist"): any;
	function l(str: "spnocodeworkflowlibrarylist"): any;
	function l(str: "filetype_spnocodeworkflowlibrarylist"): any;
	function l(str: "spprojecttask"): any;
	function l(str: "filetype_spprojecttask"): any;
	function l(str: "spprojecttasklist"): any;
	function l(str: "filetype_spprojecttasklist"): any;
	function l(str: "sppublishingpageslibrarylist"): any;
	function l(str: "filetype_sppublishingpageslibrarylist"): any;
	function l(str: "spreportdocumentlibrarylist"): any;
	function l(str: "filetype_spreportdocumentlibrarylist"): any;
	function l(str: "spreportlibrarylist"): any;
	function l(str: "filetype_spreportlibrarylist"): any;
	function l(str: "spslidelibrarylist"): any;
	function l(str: "filetype_spslidelibrarylist"): any;
	function l(str: "sptab"): any;
	function l(str: "filetype_sptab"): any;
	function l(str: "sptablist"): any;
	function l(str: "filetype_sptablist"): any;
	function l(str: "sptranslationmanagementlibrarylist"): any;
	function l(str: "filetype_sptranslationmanagementlibrarylist"): any;
	function l(str: "spuserinformation"): any;
	function l(str: "filetype_spuserinformation"): any;
	function l(str: "spuserinformationlist"): any;
	function l(str: "filetype_spuserinformationlist"): any;
	function l(str: "spwikipagelibrarylist"): any;
	function l(str: "filetype_spwikipagelibrarylist"): any;
	function l(str: "spworkflowhistory"): any;
	function l(str: "filetype_spworkflowhistory"): any;
	function l(str: "spworkflowhistorylist"): any;
	function l(str: "filetype_spworkflowhistorylist"): any;
	function l(str: "spworkflowprocess"): any;
	function l(str: "filetype_spworkflowprocess"): any;
	function l(str: "spworkflowprocesslist"): any;
	function l(str: "filetype_spworkflowprocesslist"): any;
	function l(str: "sppublishingimageslibrarylist"): any;
	function l(str: "filetype_sppublishingimageslibrarylist"): any;
	function l(str: "spcirculation"): any;
	function l(str: "filetype_spcirculation"): any;
	function l(str: "spcirculationlist"): any;
	function l(str: "filetype_spcirculationlist"): any;
	function l(str: "spdashboardslibrarylist"): any;
	function l(str: "filetype_spdashboardslibrarylist"): any;
	function l(str: "spdataconnectionforperformancepointlibrarylist"): any;
	function l(str: "filetype_spdataconnectionforperformancepointlibrarylist"): any;
	function l(str: "sphealthreport"): any;
	function l(str: "filetype_sphealthreport"): any;
	function l(str: "sphealthreportlist"): any;
	function l(str: "filetype_sphealthreportlist"): any;
	function l(str: "sphealthrule"): any;
	function l(str: "filetype_sphealthrule"): any;
	function l(str: "sphealthrulelist"): any;
	function l(str: "filetype_sphealthrulelist"): any;
	function l(str: "spimedictionary"): any;
	function l(str: "filetype_spimedictionary"): any;
	function l(str: "spimedictionarylist"): any;
	function l(str: "filetype_spimedictionarylist"): any;
	function l(str: "spperformancepointcontent"): any;
	function l(str: "filetype_spperformancepointcontent"): any;
	function l(str: "spperformancepointcontentlist"): any;
	function l(str: "filetype_spperformancepointcontentlist"): any;
	function l(str: "spphonecallmemo"): any;
	function l(str: "filetype_spphonecallmemo"): any;
	function l(str: "spphonecallmemolist"): any;
	function l(str: "filetype_spphonecallmemolist"): any;
	function l(str: "sprecordlibrarylist"): any;
	function l(str: "filetype_sprecordlibrarylist"): any;
	function l(str: "spresource"): any;
	function l(str: "filetype_spresource"): any;
	function l(str: "spresourcelist"): any;
	function l(str: "filetype_spresourcelist"): any;
	function l(str: "spprocessdiagramslibrarylist"): any;
	function l(str: "filetype_spprocessdiagramslibrarylist"): any;
	function l(str: "spsitethemeslibrarylist"): any;
	function l(str: "filetype_spsitethemeslibrarylist"): any;
	function l(str: "spsolutionslibrarylist"): any;
	function l(str: "filetype_spsolutionslibrarylist"): any;
	function l(str: "spwfpublibrarylist"): any;
	function l(str: "filetype_spwfpublibrarylist"): any;
	function l(str: "spwhereabout"): any;
	function l(str: "filetype_spwhereabout"): any;
	function l(str: "spwhereaboutlist"): any;
	function l(str: "filetype_spwhereaboutlist"): any;
	function l(str: "spdocumentlink"): any;
	function l(str: "filetype_spdocumentlink"): any;
	function l(str: "spdocumentset"): any;
	function l(str: "filetype_spdocumentset"): any;
	function l(str: "spmicrofeedpost"): any;
	function l(str: "filetype_spmicrofeedpost"): any;
	function l(str: "spmicrofeedlist"): any;
	function l(str: "filetype_spmicrofeedlist"): any;
	function l(str: "splistfolder"): any;
	function l(str: "filetype_splistfolder"): any;
	function l(str: "slackmessage"): any;
	function l(str: "filetype_slackmessage"): any;
	function l(str: "slackchannel"): any;
	function l(str: "filetype_slackchannel"): any;
	function l(str: "slackfile"): any;
	function l(str: "filetype_slackfile"): any;
	function l(str: "slackuser"): any;
	function l(str: "filetype_slackuser"): any;
	function l(str: "youtubevideo"): any;
	function l(str: "filetype_youtubevideo"): any;
	function l(str: "youtubeplaylistitem"): any;
	function l(str: "filetype_youtubeplaylistitem"): any;
	function l(str: "youtubeplaylist"): any;
	function l(str: "filetype_youtubeplaylist"): any;
	function l(str: "Unknown"): any;
	function l(str: "And"): any;
	function l(str: "Authenticating", param0: string): any;
	function l(str: "Clear", param0: string): any;
	function l(str: "CompleteQuery"): any;
	function l(str: "Exclude", param0: string): any;
	function l(str: "EnterTag"): any;
	function l(str: "Next"): any;
	function l(str: "Last"): any;
	function l(str: "Link"): any;
	function l(str: "Or"): any;
	function l(str: "Previous"): any;
	function l(str: "QueryDidntMatchAnyDocuments"): any;
	function l(str: "QueryException", param0: string): any;
	function l(str: "Me"): any;
	function l(str: "Remove"): any;
	function l(str: "Search"): any;
	function l(str: "SearchFor", param0: string): any;
	function l(str: "SubmitSearch"): any;
	function l(str: "ShareQuery"): any;
	function l(str: "Preferences"): any;
	function l(str: "LinkOpeningSettings"): any;
	function l(str: "Reauthenticate", param0: string): any;
	function l(str: "ResultsFilteringExpression"): any;
	function l(str: "FiltersInYourPreferences"): any;
	function l(str: "Create"): any;
	function l(str: "SearchIn", param0: string): any;
	function l(str: "Seconds", param0: string, count: number): any;
	function l(str: "ShowingResultsOf", param0: string, param1: string, param2: string, count: number): any;
	function l(str: "ShowingResultsOfWithQuery", param0: string, param1: string, param2: string, param3: string, count: number): any;
	function l(str: "SwitchTo", param0: string): any;
	function l(str: "Unexclude", param0: string): any;
	function l(str: "ClearAllFilters"): any;
	function l(str: "SkipLogin"): any;
	function l(str: "LoginInProgress"): any;
	function l(str: "Login"): any;
	function l(str: "GetStarted"): any;
	function l(str: "More"): any;
	function l(str: "NMore", param0: string): any;
	function l(str: "Less"): any;
	function l(str: "Settings"): any;
	function l(str: "Score"): any;
	function l(str: "ScoreDescription"): any;
	function l(str: "Occurrences"): any;
	function l(str: "OccurrencesDescription"): any;
	function l(str: "Label"): any;
	function l(str: "Of"): any;
	function l(str: "LabelDescription"): any;
	function l(str: "Value"): any;
	function l(str: "ValueDescription"): any;
	function l(str: "AlphaAscending"): any;
	function l(str: "AlphaDescending"): any;
	function l(str: "ChiSquare"): any;
	function l(str: "Nosort"): any;
	function l(str: "NosortDescription"): any;
	function l(str: "RelativeFrequency"): any;
	function l(str: "RelativeFrequencyDescription"): any;
	function l(str: "DateDistribution"): any;
	function l(str: "Custom"): any;
	function l(str: "CustomDescription"): any;
	function l(str: "ComputedField"): any;
	function l(str: "Ascending"): any;
	function l(str: "Descending"): any;
	function l(str: "noResultFor", param0: string): any;
	function l(str: "noResult"): any;
	function l(str: "autoCorrectedQueryTo", param0: string): any;
	function l(str: "didYouMean", param0: string): any;
	function l(str: "SuggestedResults"): any;
	function l(str: "SuggestedQueries"): any;
	function l(str: "MostRelevantItems"): any;
	function l(str: "AllItems"): any;
	function l(str: "ShowLess"): any;
	function l(str: "ShowMore"): any;
	function l(str: "HideFacet"): any;
	function l(str: "ShowFacet"): any;
	function l(str: "AndOthers", param0: string, count: number): any;
	function l(str: "Others", param0: string, count: number): any;
	function l(str: "MostRelevantPosts"): any;
	function l(str: "CompleteThread"): any;
	function l(str: "ShowCompleteThread"): any;
	function l(str: "ShowOnlyTopMatchingPosts"): any;
	function l(str: "MostRelevantReplies"): any;
	function l(str: "AllConversation"): any;
	function l(str: "ShowAllConversation"): any;
	function l(str: "ShowAllReplies"): any;
	function l(str: "ShowOnlyMostRelevantReplies"): any;
	function l(str: "Close"): any;
	function l(str: "Open"): any;
	function l(str: "OpenInOutlookWhenPossible"): any;
	function l(str: "AlwaysOpenInNewWindow"): any;
	function l(str: "Quickview"): any;
	function l(str: "NoQuickview"): any;
	function l(str: "ErrorReport"): any;
	function l(str: "OopsError"): any;
	function l(str: "ProblemPersists"): any;
	function l(str: "GoBack"): any;
	function l(str: "Reset"): any;
	function l(str: "Retry"): any;
	function l(str: "MoreInfo"): any;
	function l(str: "Username"): any;
	function l(str: "Password"): any;
	function l(str: "PostedBy"): any;
	function l(str: "CannotConnect"): any;
	function l(str: "BadUserPass"): any;
	function l(str: "PleaseEnterYourCredentials", param0: string): any;
	function l(str: "PleaseEnterYourSearchPage"): any;
	function l(str: "Collapse"): any;
	function l(str: "Collapsable"): any;
	function l(str: "Expand"): any;
	function l(str: "CollapseFacet", param0: string): any;
	function l(str: "ExpandFacet", param0: string): any;
	function l(str: "ShowLessFacetResults", param0: string): any;
	function l(str: "ShowMoreFacetResults", param0: string): any;
	function l(str: "ShowLessCategoryResults", param0: string): any;
	function l(str: "ShowMoreCategoryResults", param0: string): any;
	function l(str: "ShowLessHierarchicalResults", param0: string): any;
	function l(str: "ShowMoreHierarchicalResults", param0: string): any;
	function l(str: "SearchFacetResults", param0: string): any;
	function l(str: "Today"): any;
	function l(str: "Yesterday"): any;
	function l(str: "Tomorrow"): any;
	function l(str: "Duration", param0: string): any;
	function l(str: "IndexDuration", param0: string): any;
	function l(str: "ProxyDuration", param0: string): any;
	function l(str: "ClientDuration", param0: string): any;
	function l(str: "Unavailable"): any;
	function l(str: "Reply"): any;
	function l(str: "ReplyAll"): any;
	function l(str: "Forward"): any;
	function l(str: "From"): any;
	function l(str: "Caption"): any;
	function l(str: "Expression"): any;
	function l(str: "Tab"): any;
	function l(str: "Tabs"): any;
	function l(str: "EnterExpressionName"): any;
	function l(str: "EnterExpressionToFilterWith"): any;
	function l(str: "SelectTab"): any;
	function l(str: "SelectAll"): any;
	function l(str: "PageUrl"): any;
	function l(str: "ErrorSavingToDevice"): any;
	function l(str: "ErrorReadingFromDevice"): any;
	function l(str: "AppIntro"): any;
	function l(str: "TryDemo"): any;
	function l(str: "ContactUs"): any;
	function l(str: "NewToCoveo"): any;
	function l(str: "LetUsHelpGetStarted"): any;
	function l(str: "LikesThis", param0: string, count: number): any;
	function l(str: "CannotConnectSearchPage"): any;
	function l(str: "AreYouSureDeleteFilter", param0: string, param1: string): any;
	function l(str: "OnlineHelp"): any;
	function l(str: "Done"): any;
	function l(str: "SaveFacetState"): any;
	function l(str: "ClearFacetState"): any;
	function l(str: "DisplayingTheOnlyMessage"): any;
	function l(str: "NoNetworkConnection"): any;
	function l(str: "UnknownConnection"): any;
	function l(str: "EthernetConnection"): any;
	function l(str: "WiFi"): any;
	function l(str: "CELL"): any;
	function l(str: "CELL_2G"): any;
	function l(str: "CELL_3G"): any;
	function l(str: "CELL_4G"): any;
	function l(str: "Relevance"): any;
	function l(str: "Date"): any;
	function l(str: "Amount"): any;
	function l(str: "QueryExceptionNoException"): any;
	function l(str: "QueryExceptionInvalidSyntax"): any;
	function l(str: "QueryExceptionInvalidCustomField"): any;
	function l(str: "QueryExceptionInvalidDate"): any;
	function l(str: "QueryExceptionInvalidExactPhrase"): any;
	function l(str: "QueryExceptionInvalidDateOp"): any;
	function l(str: "QueryExceptionInvalidNear"): any;
	function l(str: "QueryExceptionInvalidWeightedNear"): any;
	function l(str: "QueryExceptionInvalidTerm"): any;
	function l(str: "QueryExceptionTooManyTerms"): any;
	function l(str: "QueryExceptionWildcardTooGeneral"): any;
	function l(str: "QueryExceptionInvalidSortField"): any;
	function l(str: "QueryExceptionInvalidSmallStringOp"): any;
	function l(str: "QueryExceptionRequestedResultsMax"): any;
	function l(str: "QueryExceptionAggregatedMirrorDead"): any;
	function l(str: "QueryExceptionAggregatedMirrorQueryTimeOut"): any;
	function l(str: "QueryExceptionAggregatedMirrorInvalidBuildNumber"): any;
	function l(str: "QueryExceptionAggregatedMirrorCannotConnect"): any;
	function l(str: "QueryExceptionNotEnoughLeadingCharsWildcard"): any;
	function l(str: "QueryExceptionSecurityInverterNotFound"): any;
	function l(str: "QueryExceptionSecurityInverterAccessDenied"): any;
	function l(str: "QueryExceptionAggregatedMirrorCannotImpersonate"): any;
	function l(str: "QueryExceptionUnexpected"): any;
	function l(str: "QueryExceptionAccessDenied"): any;
	function l(str: "QueryExceptionSuperUserTokenInvalid"): any;
	function l(str: "QueryExceptionSuperUserTokenExpired"): any;
	function l(str: "QueryExceptionLicenseQueriesExpired"): any;
	function l(str: "QueryExceptionLicenseSuperUserTokenNotSupported"): any;
	function l(str: "QueryExceptionInvalidSession"): any;
	function l(str: "QueryExceptionInvalidDocument"): any;
	function l(str: "QueryExceptionSearchDisabled"): any;
	function l(str: "FileType"): any;
	function l(str: "ShowAttachment"): any;
	function l(str: "OnFeed", param0: string): any;
	function l(str: "Author"): any;
	function l(str: "NoTitle"): any;
	function l(str: "CurrentSelections"): any;
	function l(str: "AllContent"): any;
	function l(str: "CancelLastAction"): any;
	function l(str: "SearchTips"): any;
	function l(str: "CheckSpelling"): any;
	function l(str: "TryUsingFewerKeywords"): any;
	function l(str: "SelectFewerFilters"): any;
	function l(str: "Document"): any;
	function l(str: "Time"): any;
	function l(str: "StartDate"): any;
	function l(str: "StartTime"): any;
	function l(str: "DurationTitle"): any;
	function l(str: "UserQuery"): any;
	function l(str: "ShowUserActions"): any;
	function l(str: "NoData"): any;
	function l(str: "EventType"): any;
	function l(str: "GoToFullSearch"): any;
	function l(str: "GoToEdition"): any;
	function l(str: "RemoveContext"): any;
	function l(str: "BoxAttachToCase"): any;
	function l(str: "AttachToCase"): any;
	function l(str: "Attach"): any;
	function l(str: "Attached"): any;
	function l(str: "Detach"): any;
	function l(str: "Details"): any;
	function l(str: "AdditionalFilters"): any;
	function l(str: "SelectNonContextualSearch"): any;
	function l(str: "CopyPasteToSupport"): any;
	function l(str: "FollowQueryDescription"): any;
	function l(str: "SearchAlerts_Panel"): any;
	function l(str: "SearchAlerts_PanelDescription"): any;
	function l(str: "SearchAlerts_PanelNoSearchAlerts"): any;
	function l(str: "SearchAlerts_Fail"): any;
	function l(str: "SearchAlerts_Type"): any;
	function l(str: "SearchAlerts_Content"): any;
	function l(str: "SearchAlerts_Actions"): any;
	function l(str: "EmptyQuery"): any;
	function l(str: "SearchAlerts_Type_followQuery"): any;
	function l(str: "SearchAlerts_Type_followDocument"): any;
	function l(str: "SearchAlerts_unFollowing"): any;
	function l(str: "SearchAlerts_follow"): any;
	function l(str: "SearchAlerts_followed"): any;
	function l(str: "SearchAlerts_followQuery"): any;
	function l(str: "Subscription_StopFollowingQuery"): any;
	function l(str: "SearchAlerts_Frequency"): any;
	function l(str: "SubscriptionsManageSubscriptions"): any;
	function l(str: "SubscriptionsMessageFollowQuery", param0: string): any;
	function l(str: "SubscriptionsMessageFollow", param0: string): any;
	function l(str: "Expiration"): any;
	function l(str: "Monthly"): any;
	function l(str: "Daily"): any;
	function l(str: "Monday"): any;
	function l(str: "Tuesday"): any;
	function l(str: "Wednesday"): any;
	function l(str: "Thursday"): any;
	function l(str: "Friday"): any;
	function l(str: "Saturday"): any;
	function l(str: "Sunday"): any;
	function l(str: "NextDay", param0: string): any;
	function l(str: "LastDay", param0: string): any;
	function l(str: "StartTypingCaseForSuggestions"): any;
	function l(str: "ExportToExcel"): any;
	function l(str: "ExportToExcelDescription"): any;
	function l(str: "CaseCreationNoResults"): any;
	function l(str: "SortBy"): any;
	function l(str: "BoxCreateArticle"): any;
	function l(str: "Facets"): any;
	function l(str: "AdvancedSearch"): any;
	function l(str: "Keywords"): any;
	function l(str: "AllTheseWords"): any;
	function l(str: "ExactPhrase"): any;
	function l(str: "AnyOfTheseWords"): any;
	function l(str: "NoneOfTheseWords"): any;
	function l(str: "Anytime"): any;
	function l(str: "InTheLast"): any;
	function l(str: "Days"): any;
	function l(str: "Months"): any;
	function l(str: "Month"): any;
	function l(str: "Year"): any;
	function l(str: "Between"): any;
	function l(str: "Language"): any;
	function l(str: "Size"): any;
	function l(str: "AtLeast"): any;
	function l(str: "AtMost"): any;
	function l(str: "Contains"): any;
	function l(str: "DoesNotContain"): any;
	function l(str: "Matches"): any;
	function l(str: "Bytes"): any;
	function l(str: "card"): any;
	function l(str: "table"): any;
	function l(str: "ResultLinks"): any;
	function l(str: "EnableQuerySyntax"): any;
	function l(str: "On"): any;
	function l(str: "Off"): any;
	function l(str: "Automatic"): any;
	function l(str: "ResultsPerPage"): any;
	function l(str: "PreviousMonth"): any;
	function l(str: "NextMonth"): any;
	function l(str: "Title"): any;
	function l(str: "FiltersInAdvancedSearch"): any;
	function l(str: "NoEndpoints", param0: string): any;
	function l(str: "InvalidToken"): any;
	function l(str: "AddSources"): any;
	function l(str: "TryAgain"): any;
	function l(str: "CoveoOnlineHelp"): any;
	function l(str: "CannotAccess", param0: string): any;
	function l(str: "CoveoOrganization"): any;
	function l(str: "SearchAPIDuration", param0: string): any;
	function l(str: "LastUpdated"): any;
	function l(str: "AllDates"): any;
	function l(str: "WithinLastDay"): any;
	function l(str: "WithinLastWeek"): any;
	function l(str: "WithinLastMonth"): any;
	function l(str: "WithinLastYear"): any;
	function l(str: "RelevanceInspector"): any;
	function l(str: "KeywordInCategory", param0: string, param1: string): any;
	function l(str: "Result"): any;
	function l(str: "ResultCount", param0: string, count: number): any;
	function l(str: "ShowingResults", param0: string, count: number): any;
	function l(str: "ShowingResultsWithQuery", param0: string, param1: string, count: number): any;
	function l(str: "NumberOfVideos"): any;
	function l(str: "AllCategories"): any;
	function l(str: "Recommended"): any;
	function l(str: "Featured"): any;
	function l(str: "CoveoHomePage"): any;
	function l(str: "SizeValue"): any;
	function l(str: "UnitMeasurement"): any;
	function l(str: "Toggle"): any;
	function l(str: "FilterOn", param0: string): any;
	function l(str: "RemoveFilterOn", param0: string): any;
	function l(str: "Enter"): any;
	function l(str: "InsertAQuery"): any;
	function l(str: "PressEnterToSend"): any;
	function l(str: "SortResultsBy", param0: string): any;
	function l(str: "SortResultsByAscending", param0: string): any;
	function l(str: "SortResultsByDescending", param0: string): any;
	function l(str: "DisplayResultsAs", param0: string): any;
	function l(str: "FacetTitle", param0: string): any;
	function l(str: "IncludeValueWithResultCount", param0: string, param1: string): any;
	function l(str: "ExcludeValueWithResultCount", param0: string, param1: string): any;
	function l(str: "PageNumber", param0: string): any;
	function l(str: "DisplayResultsPerPage", param0: string): any;
	function l(str: "GroupByAndFacetRequestsCannotCoexist"): any;
	function l(str: "MustContain"): any;
	function l(str: "Missing"): any;
	function l(str: "Filters"): any;
	function l(str: "FiltersDropdown"): any;
	function l(str: "OpenFiltersDropdown"): any;
	function l(str: "CloseFiltersDropdown"): any;
	function l(str: "NoValuesFound"): any;
	function l(str: "To"): any;
	function l(str: "DeselectFilterValues", param0: string): any;
	function l(str: "Rated", param0: string, param1: string, count: number): any;
	function l(str: "RatedBy", param0: string, count: number): any;
	function l(str: "NoRatings"): any;
	function l(str: "Pagination"): any;
	function l(str: "ThumbnailOf", param0: string): any;
	function l(str: "CollapsedUriParts"): any;
	function l(str: "HierarchicalFacetValueIndentedUnder", param0: string, param1: string): any;
	function l(str: "HierarchicalFacetValuePathPrefix"): any;
	function l(str: "UsefulnessFeedbackRequest"): any;
	function l(str: "UsefulnessFeedbackThankYou"): any;
	function l(str: "UsefulnessFeedbackExplainWhy"): any;
	function l(str: "UsefulnessFeedbackExplainWhyImperative"): any;
	function l(str: "UsefulnessFeedbackDoesNotAnswer"): any;
	function l(str: "UsefulnessFeedbackPartiallyAnswers"): any;
	function l(str: "UsefulnessFeedbackWasNotAQuestion"): any;
	function l(str: "Yes"): any;
	function l(str: "No"): any;
	function l(str: "Other"): any;
	function l(str: "Send"): any;
	function l(str: "Edit"): any;
	function l(str: "Delete"): any;
	function l(str: "Save"): any;
	function l(str: "UsefulnessFeedbackReason"): any;
	function l(str: "AnswerSnippet"): any;
	function l(str: "AnswerSpecificSnippet", param0: string): any;
	function l(str: "SuggestedQuestions"): any;
	function l(str: "ExpandQuestionAnswer", param0: string): any;
	function l(str: "MoreValuesAvailable"): any;
	function l(str: "Breadcrumb"): any;
	function l(str: "OrganizationIsPaused"): any;
	function l(str: "OrganizationWillResume"): any;
	function l(str: "UpdatingResults"): any;
	function l(str: "QuerySuggestionsAvailable", param0: string, count: number): any;
	function l(str: "QuerySuggestionsUnavailable"): any;
	function l(...params: any[]): any;

}
declare module Coveo {
	class QueryError implements IEndpointError {
	    status: number;
	    message: string;
	    type: string;
	    queryExecutionReport: any;
	    name: string;
	    constructor(errorResponse: IErrorResponse);
	}

}
declare module Coveo {
	class QueryUtils {
	    static createGuid(): string;
	    static generateWithRandom(): string;
	    static generateWithCrypto(): string;
	    static setStateObjectOnQueryResults(state: any, results: IQueryResults): void;
	    static setStateObjectOnQueryResult(state: any, result: IQueryResult): void;
	    static setSearchInterfaceObjectOnQueryResult(searchInterface: any, result: IQueryResult): void;
	    static setIndexAndUidOnQueryResults(query: IQuery, results: IQueryResults, queryUid: string, pipeline: string, splitTestRun: string): void;
	    static setTermsToHighlightOnQueryResults(query: IQuery, results: IQueryResults): void;
	    static splitFlags(flags: string, delimiter?: string): string[];
	    static isAttachment(result: IQueryResult): boolean;
	    static containsAttachment(result: IQueryResult): boolean;
	    static hasHTMLVersion(result: IQueryResult): boolean;
	    static hasThumbnail(result: IQueryResult): boolean;
	    static hasExcerpt(result: IQueryResult): boolean;
	    static getAuthor(result: IQueryResult): string;
	    static getUriHash(result: IQueryResult): string;
	    static getObjectType(result: IQueryResult): string;
	    static getCollection(result: IQueryResult): string;
	    static getSource(result: IQueryResult): string;
	    static getLanguage(result: IQueryResult): string[];
	    static getPermanentId(result: IQueryResult): {
	        fieldValue: string;
	        fieldUsed: string;
	    };
	    static quoteAndEscapeIfNeeded(str: string): string;
	    static quoteAndEscape(str: string): string;
	    static escapeString(str: string): string;
	    static isAtomicString(str: string): boolean;
	    static isRangeString(str: string): boolean;
	    static isRangeWithoutOuterBoundsString(str: string): boolean;
	    static buildFieldExpression(field: string, operator: string, values: string[]): string;
	    static buildFieldNotEqualExpression(field: string, values: string[]): string;
	    static setPropertyOnResults(results: IQueryResults, property: string, value: any, afterOneLoop?: () => any): void;
	    static setPropertyOnResult(result: IQueryResult, property: string, value: any): void;
	    static isStratusAgnosticField(fieldToVerify: string, fieldToMatch: string): boolean;
	}

}
declare module Coveo {
	/**
	 * An `ExpressionBuilder` that is mostly used by the {@link QueryBuilder}.<br/>
	 * It is used to build a single query expression.<br/>
	 * It allows combining multiple expression parts into a single string and provides utilities to generate common expression parts.
	 */
	class ExpressionBuilder {
	    wrapParts: boolean;
	    /**
	     * Add a new part to the expression.
	     * @param expression
	     */
	    add(expression: string): void;
	    /**
	     * Take another `ExpressionBuilder`, and copy it.
	     * @param expression
	     */
	    fromExpressionBuilder(expression: ExpressionBuilder): void;
	    /**
	     * Add a new part to the expression, but specific for field values<br/>
	     * eg @field=(value1,value2,value3).
	     * @param field The field for which to create an expression (e.g.: @foo).
	     * @param operator The operator to use e.g.: = (equal) == (strict equal) <> (not equal).
	     * @param values The values to put in the expression.
	     */
	    addFieldExpression(field: string, operator: string, values: string[]): void;
	    /**
	     * Add a new part to the expression, but specific for field values<br/>
	     * eg : NOT @field==(value1, value2, value3).
	     * @param field The field for which to create an expression (e.g.: @foo)
	     * @param values The values to put in the expression.
	     */
	    addFieldNotEqualExpression(field: string, values: string[]): void;
	    /**
	     * Removes an expression from the builder.
	     * @param expression
	     */
	    remove(expression: string): void;
	    /**
	     * Checks if the builder is currently empty.
	     * @returns {boolean}
	     */
	    isEmpty(): boolean;
	    /**
	     * Builds the expression string by combining all the parts together.<br/>
	     * @param exp expression to join the different parts, default to a space.
	     * @returns {any}
	     */
	    build(exp?: string): string;
	    /**
	     * @returns array containing the differents parts of the expression
	     */
	    getParts(): string[];
	    /**
	     * Merges several `ExpressionBuilder` together.
	     * @param builders Builders that should be merged.
	     * @returns {Coveo.ExpressionBuilder}
	     */
	    static merge(...builders: ExpressionBuilder[]): ExpressionBuilder;
	    /**
	     * Merges several `ExpressionBuilder` together, using the OR operator.
	     * @param builders Builders that should be merged.
	     * @returns {Coveo.ExpressionBuilder}
	     */
	    static mergeUsingOr(...builders: ExpressionBuilder[]): ExpressionBuilder;
	}

}
declare module Coveo {
	/**
	 * Describe the expressions part of a QueryBuilder.
	 */
	interface IQueryBuilderExpression {
	    /**
	     * The whole expression
	     */
	    full?: string;
	    /**
	     * The full part, but without the constant.
	     */
	    withoutConstant?: string;
	    /**
	     * The constant part of the expression
	     */
	    constant?: string;
	    /**
	     * The basic part of the expression
	     */
	    basic?: string;
	    /**
	     * The advanced part of the expression
	     */
	    advanced?: string;
	    /**
	     * The disjunction part of the expression
	     */
	    disjunction?: string;
	}
	class QueryBuilderExpression implements QueryBuilderExpression {
	    static isEmpty(queryBuilderExpression: QueryBuilderExpression): boolean;
	    constructor(basicExpression: string, advancedExpression: string, constantExpression: string, disjunctionExpression: string);
	    reset(): void;
	     withoutConstant: string;
	     full: string;
	    basic: string;
	    advanced: string;
	    constant: string;
	     expressionBuilders: {
	        basicExpression: ExpressionBuilder;
	        advancedExpression: ExpressionBuilder;
	        constantExpression: ExpressionBuilder;
	        disjunctionExpression: ExpressionBuilder;
	        withoutConstantExpression: ExpressionBuilder;
	        fullExpression: ExpressionBuilder;
	    };
	}

}
declare module Coveo {
	/**
	 * The QueryBuilder is used to build a {@link IQuery} that will be able to be executed using the Search API.
	 *
	 * The class exposes several members and methods that help components and external code to build up the final query that is sent to the Search API.
	 *
	 */
	class QueryBuilder {
	    /**
	     * Used to build the basic part of the query expression.
	     *
	     * This part typically consists of user-entered content such as query keywords, etc.
	     * @type {Coveo.ExpressionBuilder}
	     */
	    expression: ExpressionBuilder;
	    /**
	     * Used to build the advanced part of the query expression.
	     *
	     * This part is typically formed of filter expressions generated by components such as facets, external code, etc.
	     * @type {Coveo.ExpressionBuilder}
	     */
	    advancedExpression: ExpressionBuilder;
	    /**
	     * Used to build the advanced part of the query expression.
	     *
	     * This part is similar to `advancedExpression`, but its content is interpreted as a constant expression by the index and it takes advantage of special caching features.
	     * @type {Coveo.ExpressionBuilder}
	     */
	    constantExpression: ExpressionBuilder;
	    /**
	     * The contextual text.
	     *
	     * This is the contextual text part of the query. It uses the Coveo Machine Learning service to pick key keywords from the text and add them to the basic expression.
	     * This field is mainly used to pass context such a case description, long textual query or any other form of text that might help in
	     * refining the query.
	     */
	    longQueryExpression: ExpressionBuilder;
	    /**
	     * Used to build the disjunctive part of the query expression.
	     *
	     * When present, this part is evaluated separately from the other expressions and the matching results are merged to those matching expressions, `advancedExpression` and `constantExpression`.
	     *
	     * The final boolean expression for the query is thus (basic advanced constant) OR (disjunction).
	     * @type {Coveo.ExpressionBuilder}
	     */
	    disjunctionExpression: ExpressionBuilder;
	    /**
	     * The hub value set from the {@link Analytics} component.
	     *
	     * Used for analytics reporting in the Coveo platform.
	     */
	    searchHub: string;
	    /**
	     * The tab value set from the {@link Tab} component.
	     */
	    tab: string;
	    locale: string;
	    /**
	     * Name of the query pipeline to use.
	     *
	     * Specifies the name of the query pipeline to use for the query. If not specified, the default value is default, which means the default query pipeline will be used.
	     */
	    pipeline: string;
	    /**
	     * The maximum age for cached query results, in milliseconds.
	     *
	     * If results for the exact same request (including user identities) are available in the in-memory cache, they will be used if they are not older than the specified value.
	     *
	     * Otherwise, the query will be sent to the index.
	     */
	    maximumAge: number;
	    /**
	     * Whether to interpret wildcard characters (`*`) in the basic [`expression`]{@link QueryBuilder.expression} keywords.
	     *
	     * Setting this attribute to `true` enables the wildcards features of the index, effectively expanding keywords
	     * containing wildcard characters (`*`) to the possible matching keywords in order to broaden the query (see
	     * [Using Wildcards in Queries](https://docs.coveo.com/en/1580/)).
	     *
	     * See also [`enableQuestionMarks`]{@link QueryBuilder.enableQuestionMarks}.
	     *
	     * **Note:**
	     * > Normally, the [`enableWildcards`]{@link Querybox.options.enableWildcards} option of the
	     * > [`Querybox`]{@link Querybox} component determines the value of this attribute during the initialization of the
	     * > search page.
	     */
	    enableWildcards: boolean;
	    /**
	     * Whether to interpret question mark characters (`?`) in the basic [`expression`]{@link QueryBuilder.expression}
	     * keywords (see [Using Wildcards in Queries](https://docs.coveo.com/en/1580/).
	     *
	     * Setting this attribute to `true` has no effect unless [`enableWildcards`]{@link QueryBuilder.enableWildcards} is
	     * also `true`.
	     *
	     * **Note:**
	     * > Normally, the [`enableQuestionMarks`]{@link Querybox.options.enableQuestionMarks} option of the
	     * > [`Querybox`]{@link Querybox} component determines the value of this attribute during the initialization of the
	     * > search page.
	     */
	    enableQuestionMarks: boolean;
	    /**
	     * Whether to interpret special query syntax (e.g., `@objecttype=message`) in the basic
	     * [`expression`]{@link QueryBuilder.expression} (see
	     * [Coveo Query Syntax Reference](https://docs.coveo.com/en/1552/searching-with-coveo/coveo-cloud-query-syntax)).
	     *
	     * See also [`enableLowercaseOperators`]{@link QueryBuilder.enableLowercaseOperators}.
	     *
	     * **Note:**
	     * > Normally, the [`enableQuerySyntax`]{@link Querybox.options.enableQuerySyntax} option of the
	     * > [`Querybox`]{@link Querybox} component determines the value of this attribute during the initialization of the
	     * search page. End user preferences can also modify the value of this attribute.
	     *
	     * Default value is `false`
	     */
	    enableQuerySyntax: boolean;
	    /**
	     * Whether to interpret the `AND`, `NOT`, `OR`, and `NEAR` keywords in the basic
	     * [`expression`]{@link QueryBuilder.expression} as query operators, even if those keywords are in lowercase.
	     *
	     * Setting this attribute to `true` has no effect unless [`enableQuerySyntax`]{@link QueryBuilder.enableQuerySyntax}
	     * is also `true`.
	     *
	     * **Note:**
	     * > Normally, the [`enableLowercaseOperators`]{@link Querybox.options.enableLowercaseOperators} option of the
	     * > [`Querybox`]{@link Querybox} component determines the value of this attribute during the initialization of the
	     * > search page.
	     */
	    enableLowercaseOperators: boolean;
	    /**
	     * Whether to automatically convert the basic [`expression`]{@link QueryBuilder.expression} to a partial match
	     * expression if it contains at least a certain number of keywords (see
	     * [`partialMatchKeywords`]{@link QueryBuilder.partialMatchKeywords}), so that items containing at least a certain
	     * subset of those keywords (see [`partialMatchThreshold`]{@link QueryBuilder.partialMatchThreshold}) will match the
	     * query.
	     *
	     * **Note:**
	     * > Normally, the [`enablePartialMatch`]{@link Querybox.options.enablePartialMatch} option of the
	     * > [`Querybox`]{@link Querybox} component determines the value of this attribute during the initialization of the
	     * > search page.
	     */
	    enablePartialMatch: boolean;
	    /**
	     * The minimum number of keywords that need to be present in the basic [`expression`]{@link QueryBuilder.expression}
	     * to convert it to a partial match expression.
	     *
	     * The value of this attribute has no meaning unless [`enablePartialMatch`]{@link QueryBuilder.enablePartialMatch} is
	     * `true`.
	     *
	     * See also [`partialMatchThreshold`]{@link QueryBuilder.partialMatchThreshold}.
	     *
	     * **Note:**
	     * > Normally, the [`partialMatchKeywords`]{@link Querybox.options.partialMatchKeywords} option of the
	     * > [`Querybox`]{@link Querybox} component determines the value of this attribute during the initialization of the
	     * > search page.
	     */
	    partialMatchKeywords: number;
	    /**
	     * An absolute or relative (percentage) value indicating the minimum number of partial match expression keywords an
	     * item must contain to match the query.
	     *
	     * The value of this attribute has no meaning unless [`enablePartialMatch`]{@link QueryBuilder.enablePartialMatch} is
	     * `true`.
	     *
	     * See also [`partialMatchKeywords`]{@link QueryBuilder.partialMatchKeywords}.
	     *
	     * **Note:**
	     * > Normally, the [`partialMatchThreshold`]{@link Querybox.options.partialMatchThreshold} option of the
	     * > [`Querybox`]{@link Querybox} component determines the value of this attribute during the initialization of the
	     * > search page.
	     */
	    partialMatchThreshold: string;
	    /**
	     * This is the 0-based index of the first result to return.
	     *
	     * If not specified, this parameter defaults to 0.
	     */
	    firstResult: number;
	    /**
	     * This is the number of results to return, starting from {@link IQuery.firstResult}.
	     *
	     * If not specified, this parameter defaults to 10.
	     */
	    numberOfResults: number;
	    /**
	     * Specifies the length (in number of characters) of the excerpts generated by the indexer based on the keywords present in the query.
	     *
	     * The index includes the top most interesting sentences (in the order they appear in the item) that fit in the specified number of characters.
	     *
	     * When not specified, the default value is 200.
	     */
	    excerptLength: number;
	    /**
	     * Specifies a field on which {@link Folding} should be performed.
	     *
	     * Folding is a kind of duplicate filtering where only the first result with any given value of the field is included in the result set.
	     *
	     * It's typically used to return only one result in a conversation, for example when forum posts in a thread are indexed as separate items.
	     */
	    filterField: string;
	    /**
	     * Number of results that should be folded, using the {@link IQuery.filterField}.
	     */
	    filterFieldRange: number;
	    /**
	     * Specifies the `parentField` when doing parent-child loading (See: {@link Folding}).
	     */
	    parentField: string;
	    /**
	     * Specifies the childField when doing parent-child loading (See: {@link Folding}).
	     */
	    childField: string;
	    fieldsToInclude: string[];
	    requiredFields: string[];
	    includeRequiredFields: boolean;
	    fieldsToExclude: string[];
	    /**
	     * Whether to enable query corrections on this query (see {@link DidYouMean}).
	     */
	    enableDidYouMean: boolean;
	    /**
	     * Whether to enable debug info on the query.
	     *
	     * This will return additional information on the resulting JSON response from the Search API.
	     *
	     * Mostly: execution report (a detailed breakdown of the parsed and executed query).
	     */
	    enableDebug: boolean;
	    /**
	     * **Note:**
	     *
	     * > The Coveo Cloud V2 platform does not support collaborative rating. Therefore, this property is obsolete in Coveo Cloud V2.
	     *
	     * Whether the index should take collaborative rating in account when ranking result (See: {@link ResultRating}).
	     */
	    enableCollaborativeRating: boolean;
	    /**
	     * Specifies the sort criterion(s) to use to sort results. If not specified, this parameter defaults to relevancy.
	     *
	     * Possible values are : <br/>
	     * -- relevancy :  This uses all the configured ranking weights as well as any specified ranking expressions to rank results.<br/>
	     * -- dateascending / datedescending Sort using the value of the `@date` field, which is typically the last modification date of an item in the index.<br/>
	     * -- qre : Sort using only the weights applied through ranking expressions. This is much like using `relevancy` except that automatic weights based on keyword proximity etc, are not computed.<br/>
	     * -- nosort : Do not sort the results. The order in which items are returned is essentially random.<br/>
	     * -- @field ascending / @field descending Sort using the value of a custom field.
	     */
	    sortCriteria: string;
	    /**
	     * @deprecated
	     */
	    sortField: string;
	    retrieveFirstSentences: boolean;
	    timezone: string;
	    queryUid: string;
	    /**
	     * Specifies an array of Query Function operation that will be executed on the results.
	     */
	    queryFunctions: IQueryFunction[];
	    /**
	     * Specifies an array of Ranking Function operations that will be executed on the results.
	     */
	    rankingFunctions: IRankingFunction[];
	    /**
	     * Specifies an array of Group By operations that can be performed on the query results to extract facets.
	     * Cannot be used alongside [`facetRequests`]{@link QueryBuilder.facetRequests}
	     */
	    groupByRequests: IGroupByRequest[];
	    /**
	     * Specifies an array of request for the DynamicFacet component.
	     * Cannot be used alongside [`groupByRequests`]{@link QueryBuilder.groupByRequests}
	     */
	    facetRequests: IFacetRequest[];
	    /**
	     * The global configuration options to apply to the requests in the [facets]{@link QueryBuilder.facets} array.
	     */
	    facetOptions: IFacetOptions;
	    /**
	     * Specifies an array of request for the CategoryFacet component.
	     */
	    categoryFacets: ICategoryFacetRequest[];
	    enableDuplicateFiltering: boolean;
	    /**
	     * The custom context information to send along with the query. Each value should be a string or an array of strings.
	     *
	     * Custom context information can influence the output of Coveo Machine Learning models and can also be used in query pipeline conditions.
	     */
	    context: {
	        [key: string]: any;
	    };
	    /**
	     * The actions history represents the past actions a user made and is used by the Coveo Machine Learning service to suggest recommendations.
	     * It is generated by the page view script (https://github.com/coveo/coveo.analytics.js).
	     */
	    actionsHistory: string;
	    /**
	     * This is the ID of the recommendation interface that generated the query.
	     */
	    recommendation: string;
	    /**
	     * Specifies if the Search API should perform queries even when no keywords were entered by the end user.
	     *
	     * End user keywords are present in either the {@link IQuery.q} or {@link IQuery.lq} part of the query.
	     *
	     * This parameter is normally controlled by {@link SearchInterface.options.allowEmptyQuery} option.
	     */
	    allowQueriesWithoutKeywords: boolean;
	    /**
	     * A request to retrieve user actions in the query response.
	     */
	    userActions: IUserActionsRequest;
	    /**
	     * A request for a commerce query.
	     */
	    commerce: ICommerceRequest;
	    /**
	     * Build the current content or state of the query builder and return a {@link IQuery}.
	     *
	     * build can be called multiple times on the same QueryBuilder.
	     * @returns {IQuery}
	     */
	    build(): IQuery;
	    /**
	     * Return only the expression(s) part(s) of the query, as a string.
	     *
	     * This means the basic, advanced and constant part in a complete expression {@link IQuery.q}, {@link IQuery.aq}, {@link IQuery.cq}.
	     * @returns {string}
	     */
	    computeCompleteExpression(): string;
	    /**
	     * Return only the expression(s) part(s) of the query, as an object.
	     * @returns {{full: string, withoutConstant: string, constant: string}}
	     */
	    computeCompleteExpressionParts(): QueryBuilderExpression;
	    /**
	     * Return only the expression(s) part(s) of the query, as a string, except the given expression.
	     *
	     * This is used by {@link Facet}, to build their group by request with query override.
	     * @param except
	     * @returns {string}
	     */
	    computeCompleteExpressionExcept(except: string): string;
	    /**
	     * Return only the expression(s) part(s) of the query, as an object, except the given expression.
	     *
	     * This is used by {@link Facet}, to build their group by request with query override.
	     * @param except
	     * @returns {{full: string, withoutConstant: string, constant: string}}
	     */
	    computeCompleteExpressionPartsExcept(except: string): QueryBuilderExpression;
	    /**
	     * Add fields to specifically include when the results return.
	     *
	     * This can be used to accelerate the execution time of every query, as there is much less data to process if you whitelist specific fields.
	     * @param fields
	     */
	    addFieldsToInclude(fields: string[]): void;
	    addRequiredFields(fields: string[]): void;
	    /**
	     * Add fields to specifically exclude when the results return.
	     *
	     * This can be used to accelerate the execution time of every query, as there is much less data to process if you blacklist specific fields.
	     * @param fields
	     */
	    addFieldsToExclude(fields: string[]): void;
	    computeFieldsToInclude(): string[];
	    /**
	     * Adds or updates a single context key-value pair in the `context` object.
	     *
	     * @param key The context key. If this key is already present in the `context` object, its value is updated.
	     * @param value The context value. This should be a string or an array of strings.
	     */
	    addContextValue(key: string, value: any): void;
	    /**
	     * Merges the specified `values` into the `context` object.
	     *
	     * @param values The object to merge into the `context` object. Can contain multiple key-value pairs, where each value should be a string or an array of strings. If some keys are already present in the `context` object, their values are updated.
	     */
	    addContext(values: {
	        [key: string]: any;
	    }): void;
	    /**
	     * Returns true if the current query contains any expression that are considered "end user input".
	     *
	     * This usually means anything entered in the basic (see [q]{@link IQuery.options.q}) or long (see [lq]{@link IQuery.options.lq}) part of the query.
	     */
	    containsEndUserKeywords(): boolean;
	}

}
declare module Coveo {
	/**
	 * Argument sent to all handlers bound on {@link InitializationEvents.afterComponentsInitialization}, and {@link InitializationEvents.afterInitialization}.
	 */
	interface IInitializationEventArgs {
	    defer: Promise<any>[];
	}
	/**
	 * This static class is there to contain the different string definitions for all the events related to initialization.
	 *
	 * Note that these events will only be triggered when the {@link init} function is called.
	 *
	 * This means these events are normally called only once when the search interface is initialized.
	 */
	class InitializationEvents {
	    /**
	     * This event is triggered right before each components inside the search interface get initialized (eg: Before the constructor of each component is executed).
	     *
	     * The string value is `beforeInitialization`.
	     * @type {string}
	     */
	    static beforeInitialization: string;
	    /**
	     * Triggered after the components are initialized (eg: After the constructor of each component is executed)
	     * but before their state is set from the hash portion of the URL (e.g., `http://mysearchinterface#q=myQuery`).
	     *
	     * This is also before the first query is launched (if the {@link SearchInterface.options.autoTriggerQuery} is `true`).
	     *
	     * The string value is `afterComponentsInitialization`.
	     * @type {string}
	     */
	    static afterComponentsInitialization: string;
	    /**
	     * Triggered right before the state from the URL (e.g., `http://mysearchinterface#q=myQuery`) gets applied in the interface.
	     *
	     * This will typically only be useful if the {@link SearchInterface.options.enableHistory} is set to `true`.
	     *
	     * The string value is `restoreHistoryState`.
	     * @type {string}
	     */
	    static restoreHistoryState: string;
	    /**
	     * Triggered right after the UI is fully initialized.
	     *
	     * Concretely this means that the constructor of each component has been executed, and that the state coming for the URL (e.g., `http://mysearchinterface#q=myquery`) has been applied.
	     *
	     * It is triggered *before* the first query is launched, and if the {@link SearchInterface.options.autoTriggerQuery} is `true`.
	     *
	     * The string value is `afterInitialization`.
	     * @type {string}
	     */
	    static afterInitialization: string;
	    /**
	     * This is triggered when the UI needs to be dynamically removed so that components can unbind any internal handlers they might have set globally on the window or the document.
	     *
	     * After this event has been executed, the search interface can be dynamically removed and all handlers can be considered cleanly removed.
	     *
	     * The string value is `nuke`.
	     * @type {string}
	     */
	    static nuke: string;
	}

}
declare module Coveo {
	class HashUtils {
	    static getHash(w?: Window): string;
	    static getValue(key: string, toParse: string): any;
	    static encodeValues(values: {}): string;
	    static encodeArray(array: string[]): string;
	    static encodeObject(obj: Object): string;
	}

}
declare module Coveo {
	/**
	 * The bindings, or environment in which each component exists.
	 */
	interface IComponentBindings {
	    /**
	     * The root HTMLElement of the {@link SearchInterface} in which the component exists.
	     */
	    root?: HTMLElement;
	    /**
	     * Contains the state of the query. Allows to get/set values. Triggers state event when modified. Each component can listen to those events.
	     */
	    queryStateModel?: QueryStateModel;
	    /**
	     * Contains the state of different components (enabled vs disabled). Allows to get/set values. Triggers component state event when modified. Each component can listen to those events.
	     */
	    componentStateModel?: ComponentStateModel;
	    /**
	     * Contains the singleton that allows to trigger queries.
	     */
	    queryController?: QueryController;
	    /**
	     * A reference to the root of every component, the {@link SearchInterface}.
	     */
	    searchInterface?: SearchInterface;
	    /**
	     * A reference to the {@link Analytics.client}.
	     */
	    usageAnalytics?: IAnalyticsClient;
	    /**
	     * Contains the state of options for different components. Mainly used by {@link ResultLink}.
	     */
	    componentOptionsModel?: ComponentOptionsModel;
	}

}
declare module Coveo {
	interface IJQuery {
	    fn: any;
	}
	function initCoveoJQuery(): boolean;
	function jQueryIsDefined(): boolean;

}
declare module Coveo {
	class ColorUtils {
	    static hsvToRgb(h: any, s: any, v: any): number[];
	    static rgbToHsv(r: any, g: any, b: any): any[];
	}

}
declare module Coveo {
	class Cookie {
	    static set(name: string, value: string, expiration?: number): void;
	    static get(name: string): string;
	    static erase(name: string): void;
	}

}
declare module Coveo {
	/**
	 * The available options to format a numeric value as a currency string.
	 */
	interface ICurrencyToStringOptions {
	    /**
	     * The number of decimals to display.
	     *
	     * **Default:** `0`
	     */
	    decimals?: number;
	    /**
	     * The currency symbol to use.
	     */
	    symbol?: string;
	}
	class CurrencyUtils {
	    static currencyToString(value: number, options?: ICurrencyToStringOptions): string;
	}

}
declare module Coveo {
	/// <reference types="globalize" />
	/// <reference types="moment" />
	/**
	 * The `IDateToStringOptions` interface describes a set of options to use when converting a standard Date object to a
	 * string using the [ `dateToString` ]{@link DateUtils.dateToString}, or the
	 * [ `dateTimeToString` ]{@link DateUtils.dateTimeToString} method from the [ `DateUtils` ]{@link DateUtils} class.
	 * The precedence orders for the options are:
	 * [ `useTodayYesterdayAndTomorrow` ]{@link IDateToStringOptions.useTodayYesterdayAndTomorrow}
	 * -> [ `useWeekdayIfThisWeek` ]{@link IDateToStringOptions.useWeekdayIfThisWeek}
	 * -> [ `omitYearIfCurrentOne` ]{@link IDateToStringOptions.omitYearIfCurrentOne}
	 * -> [ `useLongDateFormat` ]{@link IDateToStringOptions.useLongDateFormat}
	 * and [ `alwaysIncludeTime` ]{@link IDateToStringOptions.alwaysIncludeTime}
	 * -> [ `includeTimeIfThisWeek` ]{@link IDateToStringOptions.includeTimeIfThisWeek}
	 * -> [ `includeTimeIfToday` ]{@link IDateToStringOptions.includeTimeIfToday}.
	 */
	interface IDateToStringOptions {
	    /**
	     * Contains a standard Date object that specifies the current date and time.
	     *
	     * Default value is `any`.
	     */
	    now?: Date;
	    /**
	     * Specifies whether to convert the Date object to the localized version of `Today`, `Yesterday`, or `Tomorrow`,
	     * if possible. This option takes precedence over
	     * [ `useWeekdayIfThisWeek` ]{@link IDateToStringOptions.useWeekdayIfThisWeek}.
	     *
	     * **Examples**
	     *
	     * If [ `useTodayYesterdayAndTomorrow` ]{@link IDateToStringOptions.useTodayYesterdayAndTomorrow} is `true`,
	     * and [ `now` ]{@link IDateToStringOptions.now} contains a Date object equivalent to `March 8, 2017`, then:
	     *
	     *  - If the Date object to convert contains a value equivalent to `March 7, 2017`, the resulting string is the
	     *  localized version of `Yesterday`.
	     *
	     *  - If the Date object to convert contains a value equivalent to `March 8, 2017`, the resulting string is the
	     *  localized version of `Today`.
	     *
	     *  - If the Date object to convert contains a value equivalent to `March 9, 2017`, the resulting string is the
	     *  localized version of `Tomorrow`.
	     *
	     * Default value is `true`.
	     */
	    useTodayYesterdayAndTomorrow?: boolean;
	    /**
	     * Specifies whether to convert the Date object to the localized version of the corresponding day of the week,
	     * if the date to convert is part of the current week. This option takes precedence over
	     * [ `omitYearIfCurrentOne` ]{@link IDateToStringOptions.omitYearIfCurrentOne}.
	     *
	     * **Examples**
	     *
	     *  If [ `useWeekdayIfThisWeek` ]{@link IDateToStringOptions.useWeekdayIfThisWeek} is `true`
	     *  and [ `now` ]{@link IDateToStringOptions.now} contains a Date object equivalent to `Monday, March 8, 2017`, then:
	     *
	     *   - If the date to convert is equivalent to `Saturday, March 6, 2017`, the resulting string is the localized
	     *   version of `Last Saturday`.
	     *
	     *   - If the date to convert is equivalent to `Thursday, March 11, 2017`, the resulting string is the localized
	     *   version of `Next Thursday`.
	     *
	     * Default value is `true`.
	     */
	    useWeekdayIfThisWeek?: boolean;
	    /**
	     * Specifies whether to omit the year from the resulting string when converting the Date object, if the year
	     * is the current one. This option takes precedence over
	     * [ `useLongDateFormat` ]{@link IDateToStringOptions.useLongDateFormat}.
	     *
	     * **Examples**
	     *
	     *  - If the Date object to convert is equivalent to `September 22, 2017`, the resulting string does not contain
	     *  the year (e.g., `September 22`).
	     *
	     *  - If the Date object to convert is equivalent to `September 22, 2016`, the resulting string contains the year
	     *  (e.g., `September 22, 2016`).
	     *
	     * Default value is `true`.
	     */
	    omitYearIfCurrentOne?: boolean;
	    /**
	     * Specifies whether to format the resulting string in the long date format (e.g., `Friday, August 04, 2017`).
	     *
	     * Default value is `false`.
	     */
	    useLongDateFormat?: boolean;
	    /**
	     * Specifies whether to include the time in the resulting string when converting the Date object (e.g. `May 15, 4:17 PM`)
	     * if the date to convert is equivalent to [ `now` ]{@link IDateToStringOptions.now}.
	     *
	     * **Examples**
	     *
	     * If [ `includeTimeIfToday` ]{@link IDateToStringOptions.includeTimeIfToday} is `true`
	     * and [ `now` ]{@link IDateToStringOptions.now} contains a Date object equivalent to `Monday, March 8, 2017`, then:
	     *
	     *    - If the Date object to convert is equivalent to `2017/03/08 17:23:11`, the resulting string is `3/8/2017, 5:23 PM`.
	     *
	     *    - If the Date object to convert is equivalent to `2017/03/09 17:23:11`, the resulting string is `3/9/2017`.
	     *
	     * Default value is `true`.
	     */
	    includeTimeIfToday?: boolean;
	    /**
	     * Specifies whether to include the time in the resulting string when converting the Date object (e.g. `May 15, 4:17 PM`)
	     * if the date to convert within a week from [ `now` ]{@link IDateToStringOptions.now}. This option takes precedence over
	     * [ `includeTimeIfToday` ]{@link IDateToStringOptions.includeTimeIfToday}.
	     *
	     * **Examples**
	     *
	     * If [ `includeTimeIfToday` ]{@link IDateToStringOptions.includeTimeIfToday} is `true`
	     * and [ `now` ]{@link IDateToStringOptions.now} contains a Date object equivalent to `Monday, March 8, 2017`, then:
	     *
	     *    - If the Date object to convert is equivalent to `2017/03/08 17:23:11`, the resulting string is `3/8/2017, 5:23 PM`.
	     *
	     *    - If the Date object to convert is equivalent to `2017/03/09 17:23:11`, the resulting string is `3/9/2017 ,5:23 PM`.
	     *
	     * Default value is `true`.
	     */
	    includeTimeIfThisWeek?: boolean;
	    /**
	     * Specifies whether to always include the time in the resulting string when converting the Date object (e.g. `May 15, 4:17 PM`)
	     * This option takes precedence over [ `includeTimeIfThisWeek` ]{@link IDateToStringOptions.includeTimeIfThisWeek}.
	     *
	     * **Example**
	     *
	     * If [ `includeTimeIfToday` ]{@link IDateToStringOptions.includeTimeIfToday} is `true`
	     * and [ `now` ]{@link IDateToStringOptions.now} contains a Date object equivalent to `Monday, March 8, 2017`, then:
	     *
	     *    - If the Date object to convert is equivalent to `2010/03/08 17:23:11`, the resulting string is `3/8/2010, 5:23 PM`.
	     *
	     * Default value is `false`.
	     */
	    alwaysIncludeTime?: boolean;
	    /**
	     * Specifies a custom date format (e.g., dd/MM/yyyy), regardless of browser locale or any other option.
	     *
	     * This option uses the following syntax. All examples use the April 5th, 2018 14:15:34 time.
	     * - `yyyy`: full length year (e.g., 2018)
	     * - `yy`: short length year (e.g., 18)
	     * - `MMMM`: month name (e.g., April)
	     * - `MMM`: shortened month name (e.g., Apr)
	     * - `MM`: month number (e.g., 04)
	     * - `M`: single digit month number for months before October (e.g., 4)
	     * - `dddd`: day name (e.g., Thursday)
	     * - `ddd`: shortened day name (e.g., Thu)
	     * - `dd`: day number (e.g., 05)
	     * - `d`: single digit day for days before the 10th (e.g., 5)
	     * - `hh`: hour, in the 24-hour format (e.g., 14)
	     * - `h`: hour, in the 12-hour format (e.g., 2)
	     * - `mm`: minutes (e.g., 15)
	     * - `ss`: seconds (e.g., 34)
	     */
	    predefinedFormat?: string;
	}
	/**
	 * The `DateUtils` class exposes methods to convert strings, numbers and date objects to standard ISO 8601 Date objects,
	 * using the correct culture, language and format. It also offers methods to convert date objects to strings.
	 */
	class DateUtils {
	    static convertFromJsonDateIfNeeded(date: any): Date;
	    /**
	     * Tries to parse an argument of any type to a standard Date object.
	     * @param date The value to parse. Can be of any type (string, number, Date, etc.).
	     * @returns {any} The parsed Date object, or `Invalid Date` if the `date` argument was not recognized as a valid date.
	     */
	    static convertToStandardDate(date: any): Date;
	    static setLocale(): void;
	    /**
	     * Creates a string from a Date object. The resulting string is in the date format required for queries.
	     * @param date The Date object to create a string from.
	     * @returns {string} A string corresponding to the `date` argument value, in the `YYYY/MM/DD` format.
	     */
	    static dateForQuery(date: Date): string;
	    /**
	     * Creates a string from a Date object. The resulting string is in the datetime format required for queries.
	     * @param date The Date object to create a string from.
	     * @returns {string} A string corresponding to the `date` argument value, in the `YYYY/MM/DD@HH:mm:ss` format.
	     */
	    static dateTimeForQuery(date: Date): string;
	    /**
	     * Creates a cropped version of a Date object. The resulting object contains no time information.
	     * @param date The original Date object to create a cropped Date object from.
	     * @returns {Date} A cropped Date object corresponding to the `date` argument value, excluding its time information.
	     */
	    static keepOnlyDatePart(date: Date): Date;
	    /**
	     * Creates an offset version of a Date object. The offset is counted in days.
	     * @param date The original Date object to create an offset Date object from.
	     * @param offset The number of days to add to (or subtract from) the `date` argument.
	     * @returns {Date} An offset Date object corresponding to the `date` argument value plus the `offset` value.
	     */
	    static offsetDateByDays(date: Date, offset: number): Date;
	    /**
	     * Creates a string from a Date object. The resulting string is formatted according to a set of options.
	     * This method calls [ `keepOnlyDatePart` ]{@link DateUtils.keepOnlyDatePart} to remove time information from the date.
	     * If you need to create a timestamp, use the [ `dateTimeToString` ]{@link DateUtils.dateTimeToString} method instead.
	     * @param date The Date object to create a string from.
	     * @param options The set of options to apply when formatting the resulting string. If you do not specify a value for
	     * this parameter, the method uses a default set of options.
	     * @returns {string} A date string corresponding to the `date` argument value, formatted according to the specified `options`.
	     */
	    static dateToString(date: Date, options?: IDateToStringOptions): string;
	    /**
	     * Creates a string from a Date object. The string corresponds to the time information of the Date object.
	     * @param date The Date object to create a string from.
	     * @param options The set of options to apply when formatting the resulting string. If you do not specify a
	     * value for this parameter, the method uses a default set of options.
	     * @returns {string} A string containing the time information of the `date` argument, and formatted according to the specified `options`.
	     */
	    static timeToString(date: Date, options?: IDateToStringOptions): string;
	    /**
	     * Creates a string from a Date object. The resulting string is formatted according to a set of options.
	     * This method calls [ `timeToString` ]{@link DateUtils.timeToString} to add time information to the date.
	     * If you need to create a date string without a timestamp, use the [ `dateToString` ]{@link DateUtils.dateToString} method instead.
	     * @param date The date object to create a string from.
	     * @param options The set of options to apply when formatting the resulting string. If you do not specify a value for
	     * this parameter, the method uses a default set of options.
	     * @returns {string} A date string corresponding to the `date` argument value, formatted according to the specified `options`.
	     */
	    static dateTimeToString(date: Date, options?: IDateToStringOptions): string;
	    /**
	     * Creates a string from a number. The resulting string is the localized name of the month that corresponds
	     * to this number (e.g., `0` results in the localized version of `January`).
	     * @param month The number to create a string from. Minimum value is `0` (which corresponds to `January`). Maximum
	     * value is `11` (which corresponds to `December`).
	     * @returns {string} A string whose value is the localized name of the corresponding `month`.
	     */
	    static monthToString(month: number): string;
	    /**
	     * Validates whether a value is an instance of Date.
	     * @param date The value to verify.
	     * @returns {boolean} `true` if the `date` argument is an instance of Date; `false` otherwise.
	     */
	    static isValid(date: any): boolean;
	    /**
	     * Creates a string from two Date objects. The resulting string corresponds to the amount of time between those two dates.
	     * @param from The Date object which contains the "oldest" value.
	     * @param to The Date object which contains the "newest" value.
	     * @returns {any} A string whose value corresponds to the amount of time between `from` and `to`,
	     * or an empty string if either argument was any.
	     */
	    static timeBetween(from: Date, to: Date): string;
	    static  currentGlobalizeCalendar: GlobalizeCalendar;
	    static  currentLocale: any;
	    static  momentjsCompatibleLocale: string;
	    static transformGlobalizeCalendarToMomentCalendar(): any;
	}

}
declare module Coveo {
	interface IFileTypeInfo {
	    icon: string;
	    caption: string;
	}
	class FileTypes {
	    static get(result: IQueryResult): IFileTypeInfo;
	    static getObjectType(objecttype: string, fallbackOnLocalization?: boolean): IFileTypeInfo;
	    static getFileType(filetype: string, fallbackOnLocalization?: boolean): IFileTypeInfo;
	    static getFileTypeCaptions(): {
	        [id: string]: string;
	    };
	    static safelyBuildFileTypeInfo(fieldname: string, iconClass: string, caption: string): IFileTypeInfo;
	}

}
declare module Coveo {
	function latinize(str: string): string;

}
declare module Coveo {
	class StringUtils {
	    static javascriptEncode(value: string): string;
	    static htmlEncode(value: string): string;
	    static splice(value: string, index: number, remove: number, toAdd: string): string;
	    static removeMiddle(value: string, length: number, toAdd: string): string;
	    static regexEncode(value: string): string;
	    static stringToRegex(value: string, ignoreAccent?: boolean): string;
	    static wildcardsToRegex(value: string, ignoreAccent?: boolean): string;
	    static getHighlights(strToSearch: string, regexToFind: RegExp, dataHighlightGroupTerm: string): IHighlight[];
	    static encodeCarriageReturn(strToEncode: string): string;
	    static equalsCaseInsensitive(str1: string, str2: string): boolean;
	    static match(value: string, regex: RegExp): string[][];
	    static hashCode(str: string): string;
	    static latinize(str: string): string;
	    static capitalizeFirstLetter(str: string): string;
	    static buildStringTemplateFromResult(template: string, result: IQueryResult): string;
	    static accented: {
	        [letter: string]: RegExp;
	    };
	}

}
declare module Coveo {
	class SVGIcons {
	    static icons: {
	        search: string;
	        more: string;
	        loading: string;
	        checkboxHookExclusionMore: string;
	        arrowUp: string;
	        arrowDown: string;
	        mainClear: string;
	        clearSmall: string;
	        clear: string;
	        close: string;
	        delete: string;
	        save: string;
	        checkYes: string;
	        orAnd: string;
	        sort: string;
	        ascending: string;
	        descending: string;
	        dropdownMore: string;
	        dropdownLess: string;
	        facetCollapse: string;
	        facetExpand: string;
	        dropdownShareQuery: string;
	        dropdownPreferences: string;
	        dropdownAuthenticate: string;
	        dropdownExport: string;
	        dropdownFollowQuery: string;
	        quickview: string;
	        pagerRightArrow: string;
	        pagerLeftArrow: string;
	        replies: string;
	        video: string;
	        coveoLogo: string;
	        coveoPoweredBy: string;
	        taggingOk: string;
	        edit: string;
	        star: string;
	        listLayout: string;
	        cardLayout: string;
	        tableLayout: string;
	        plus: string;
	    };
	}

}
declare module Coveo {
	class TemplateConditionEvaluator {
	    static getFieldFromString(text: string): string[];
	    static evaluateCondition(condition: string, result: IQueryResult, responsiveComponents?: ResponsiveComponents): Boolean;
	}

}
declare module Coveo {
	class TemplateFieldsEvaluator {
	    static evaluateFieldsToMatch(toMatches: IFieldsToMatch[], result: IQueryResult): boolean;
	}

}
declare module Coveo {
	/**
	 * The possible valid and supported layouts.
	 *
	 * See the [Result Layouts](https://docs.coveo.com/en/360/) documentation.
	 */
	type ValidLayout = 'list' | 'card' | 'table';
	type RendererValidLayout = ValidLayout | 'preview';

}
declare module Coveo {
	type TemplateRole = 'table-header' | 'table-footer';
	interface ITemplateProperties {
	    condition?: Function;
	    conditionToParse?: string;
	    layout?: ValidLayout;
	    mobile?: boolean;
	    tablet?: boolean;
	    desktop?: boolean;
	    fieldsToMatch?: IFieldsToMatch[];
	    role?: TemplateRole;
	}
	interface IFieldsToMatch {
	    values?: string[];
	    field: string;
	    reverseCondition?: boolean;
	}
	interface IInstantiateTemplateOptions {
	    currentLayout?: RendererValidLayout;
	    checkCondition?: boolean;
	    wrapInDiv?: boolean;
	    responsiveComponents?: ResponsiveComponents;
	}
	class DefaultInstantiateTemplateOptions implements IInstantiateTemplateOptions {
	    currentLayout: ValidLayout;
	    checkCondition: boolean;
	    wrapInDiv: boolean;
	    responsiveComponents: ResponsiveComponents;
	    constructor();
	    get(): IInstantiateTemplateOptions;
	    merge(other: IInstantiateTemplateOptions): IInstantiateTemplateOptions;
	}
	class Template implements ITemplateProperties {
	    dataToString: (object?: any) => string;
	    condition: Function;
	    conditionToParse: string;
	    fieldsToMatch: IFieldsToMatch[];
	    mobile: boolean;
	    tablet: boolean;
	    desktop: boolean;
	    fields: string[];
	    layout: ValidLayout;
	    role: TemplateRole;
	    constructor(dataToString?: (object?: any) => string);
	    instantiateToString(object: IQueryResult, instantiateOptions?: IInstantiateTemplateOptions): string;
	    addField(field: string): void;
	    addFields(fields: string[]): void;
	    getComponentsInside(tmplString: string): string[];
	    instantiateToElement(result: IQueryResult, templateOptions?: IInstantiateTemplateOptions): Promise<HTMLElement> | void;
	    toHtmlElement(): HTMLElement;
	    getFields(): string[];
	    getType(): string;
	    setConditionWithFallback(condition: string): void;
	    protected getTemplateInfo(): any;
	}

}
declare module Coveo {
	/**
	 * Information about a single field in the index
	 */
	interface IFieldDescription {
	    /**
	     * It's type, as a string
	     */
	    type: string;
	    /**
	     * It's name, as a string
	     */
	    name: string;
	    /**
	     * A small(ish) description of the field
	     */
	    description: string;
	    /**
	     * The default value of the field
	     */
	    defaultValue: string;
	    /**
	     * It's fieldType, as a string.<br/>
	     * eg: Date, Double, Integer, LargeString, Long, SmallString
	     */
	    fieldType: string;
	    /**
	     * It's fieldSourceType, as a string.
	     */
	    fieldSourceType: string;
	    /**
	     * Gets whether the field can be referenced in a query.
	     */
	    includeInQuery: boolean;
	    /**
	     * Gets whether the field is returned with results.
	     */
	    includeInResults: boolean;
	    /**
	     * Gets whether the field is considered groupBy (facet)
	     */
	    groupByField: boolean;
	    /**
	     * Gets whether the field is considered splitGroupBy (facet with ; between values)
	     */
	    splitGroupByField: boolean;
	    /**
	     * Gets whether the field can be used to sort results
	     */
	    sortByField: boolean;
	}

}
declare module Coveo {
	/**
	 * The `IFieldOption` interface declares a type for options that should contain a field to be used in a query.
	 *
	 * The only constraint this type has over a basic string is that it should start with the `@` character.
	 */
	interface IFieldOption extends String {
	}
	/**
	 * The `IFieldConditionOption` is a component option expressing a field-based condition that must be satisfied.
	 */
	interface IFieldConditionOption {
	    /**
	     * The name of the field on which the condition is based (e.g., `author`).
	     */
	    field: string;
	    /**
	     * The field values allowed (or disallowed) by the condition (e.g., `["Alice Smith", "Bob Jones"]`).
	     */
	    values: string[];
	    /**
	     * Whether the condition should disallow the specified [`values`]{@link IFieldConditionOption} rather than allowing them.
	     */
	    reverseCondition?: boolean;
	}
	/**
	 * The `IQueryExpression` type is a string type dedicated to query expressions.
	 *
	 * This type is used to build a specific option for query expressions.
	 */
	type IQueryExpression = string;
	interface IComponentOptionsLoadOption<T> {
	    (element: HTMLElement, name: string, option: IComponentOptionsOption<T>): T;
	}
	/**
	 * The `IComponentOptionsPostProcessing<T>` interface describes a post process function that should allow a component
	 * option to further modify its own value once all other options of that component have been built.
	 */
	interface IComponentOptionsPostProcessing<T> {
	    /**
	     * Specifies a function that should allow a component option to further modify its own value once all other options
	     * of that component have been built.
	     * @param value The value originally specified for the option.
	     * @param options The options of the component.
	     */
	    (value: T, options: any): T;
	}
	interface IComponentOptionsOption<T> extends IComponentOptions<T> {
	    type?: ComponentOptionsType;
	    load?: IComponentOptionsLoadOption<T>;
	}
	/**
	 * The `IComponentOptions` interface describes the available parameters when building any kind of component
	 * option.
	 */
	interface IComponentOptions<T> {
	    /**
	     * Specifies the value the option must take when no other value is explicitly specified.
	     */
	    defaultValue?: T;
	    /**
	     * Specifies a function that should return the value the option must take when no other value is explicitly specified.
	     *
	     * @param element The HTMLElement on which the current option is being parsed.
	     * @return The default value of the option.
	     */
	    defaultFunction?: (element: HTMLElement) => T;
	    /**
	     * Specifies whether it is necessary to explicitly specify a value for the option in order for the component to
	     * function properly.
	     *
	     * **Example:**
	     *
	     * > The [`field`]{@link Facet.options.field} option of the `Facet` component is required, since a facet cannot
	     * > function properly without a field.
	     */
	    required?: boolean;
	    /**
	     * Specifies a function that should allow a component option to further modify its own value once all other options
	     * of that component have been built.
	     *
	     * **Example:**
	     *
	     * > By default, the [`id`]{@link Facet.options.id} option of the `Facet` component uses a post processing function to
	     * > set its value to that of the [`field`]{@link Facet.options.field} option.
	     */
	    postProcessing?: IComponentOptionsPostProcessing<T>;
	    /**
	     * Specifies a different markup name to use for an option, rather than the standard name (i.e., `data-` followed by
	     * the hyphened name of the option).
	     *
	     * **Note:**
	     *
	     * > This should only be used for backward compatibility reasons.
	     */
	    attrName?: string;
	    /**
	     * Specifies an alias, or array of aliases, which can be used instead of the actual option name.
	     *
	     * **Note:**
	     *
	     * > This can be useful to modify an option name without introducing a breaking change.
	     */
	    alias?: string | string[];
	    /**
	     * Specifies a section name inside which the option should appear in the Coveo JavaScript Interface Editor.
	     */
	    section?: string;
	    /**
	     * Specifies the name of a boolean component option which must be `true` in order for this option to function
	     * properly.
	     *
	     * **Note:**
	     *
	     * > This is mostly useful for the Coveo JavaScript Interface Editor.
	     */
	    depend?: string;
	    priority?: number;
	    /**
	     * Specifies a message that labels the option as deprecated. This message appears in the console upon initialization
	     * if the deprecated option is used in the page. Consequently, this message should explain as clearly as possible why
	     * the option is deprecated, and what now replaces it.
	     *
	     * **Note:**
	     *
	     * > Deprecated options do not appear in the Coveo JavaScript Interface Editor.
	     */
	    deprecated?: string;
	    /**
	     * Specifies a function that should indicate whether the option value is valid.
	     *
	     * @param value The option value to validate.
	     * @returns `true` if the option value is valid; `false` otherwise.
	     */
	    validator?: (value: T) => boolean;
	}
	interface IComponentOptionsNumberOption extends IComponentOptionsOption<number>, IComponentOptionsNumberOptionArgs {
	}
	/**
	 * The `IComponentOptionsNumberOptionArgs` interface describes the available parameters when building a
	 * [number option]{@link ComponentOptions.buildNumberOption).
	 */
	interface IComponentOptionsNumberOptionArgs extends IComponentOptions<number> {
	    /**
	     * Specifies the exclusive minimum value the option can take.
	     *
	     * Configuring the option using a value strictly less than this minimum displays a warning message in the console and
	     * automatically sets the option to its minimum value.
	     */
	    min?: number;
	    /**
	     * Specifies the exclusive maximum value the option can take.
	     *
	     * Configuring the option using a value strictly greater than this maximum displays a warning message in the console
	     * and automatically sets the option to its maximum value.
	     */
	    max?: number;
	    /**
	     * Specifies whether the value of this option is a floating point number.
	     */
	    float?: boolean;
	}
	interface IComponentOptionsListOption extends IComponentOptionsOption<string[]>, IComponentOptionsListOptionArgs {
	}
	/**
	 * The `IComponentOptionsListOptionArgs` interface describes the available parameters when building a
	 * [list option]{@link ComponentOptions.buildListOption).
	 */
	interface IComponentOptionsListOptionArgs extends IComponentOptions<string[]> {
	    /**
	     * Specifies the regular expression to use to separate the elements of the list option.
	     *
	     * Default value is a regular expression that inserts a comma character (`,`) between each word.
	     */
	    separator?: RegExp;
	    /**
	     * Specifies the possible values the list option elements can take.
	     */
	    values?: any;
	}
	interface IComponentOptionsCustomListOptionArgs<T> extends IComponentOptions<T> {
	    separator?: RegExp;
	    values?: any;
	}
	interface IComponentOptionsChildHtmlElementOption extends IComponentOptionsOption<HTMLElement>, IComponentOptionsChildHtmlElementOptionArgs {
	}
	interface IComponentOptionsChildHtmlElementOptionArgs extends IComponentOptions<HTMLElement> {
	    selectorAttr?: string;
	    childSelector?: string;
	}
	/**
	 * The `IComponentOptionsTemplateOptionArgs` interface describes the available parameters when building a
	 * [template option]{@link ComponentOptions.buildTemplateOption}.
	 */
	interface IComponentOptionsFieldOption extends IComponentOptionsOption<string>, IComponentOptionsFieldOptionArgs {
	}
	/**
	 * The `IComponentOptionsFieldOptionArgs` interface describes the available parameters when building a
	 * [field option]{@link ComponentOptions.buildFieldOption}.
	 */
	interface IComponentOptionsFieldOptionArgs extends IComponentOptions<string> {
	    groupByField?: boolean;
	    includeInResults?: boolean;
	    sortByField?: boolean;
	    splitGroupByField?: boolean;
	    match?: (field: IFieldDescription) => boolean;
	}
	interface IComponentOptionsFieldsOption extends IComponentOptionsOption<string[]>, IComponentOptionsFieldsOptionArgs {
	}
	/**
	 * The `IComponentOptionsFieldsOptionArgs` interface describes the available parameters when building a
	 * [fields option]{@link ComponentOptions.buildFieldsOption}.
	 */
	interface IComponentOptionsFieldsOptionArgs extends IComponentOptions<string[]> {
	    groupByField?: boolean;
	    includeInResults?: boolean;
	    sortByField?: boolean;
	    splitGroupByField?: boolean;
	    match?: (field: IFieldDescription) => boolean;
	}
	/**
	 * The `IComponentLocalizedStringOptionArgs` interface describes the available parameters when building a
	 * [fields option]{@link ComponentOptions.buildLocalizedStringOption}.
	 */
	interface IComponentLocalizedStringOptionArgs extends IComponentOptions<string> {
	    localizedString?: () => string;
	    /**
	     * @deprecated Use `localizedString` instead. Using this option could cause localized string to appear incorrectly translated in the interface.
	     */
	    defaultValue?: string;
	}
	interface IComponentOptionsObjectOption extends IComponentOptionsOption<{
	    [key: string]: any;
	}>, IComponentOptionsObjectOptionArgs {
	}
	interface IComponentOptionsObjectOptionArgs extends IComponentOptions<{
	    [key: string]: any;
	}> {
	    subOptions: {
	        [key: string]: IComponentOptionsOption<any>;
	    };
	}
	interface IComponentJsonObjectOption<T> extends IComponentOptions<T> {
	}
	enum ComponentOptionsType {
	    BOOLEAN = 0,
	    NUMBER = 1,
	    STRING = 2,
	    LOCALIZED_STRING = 3,
	    LIST = 4,
	    SELECTOR = 5,
	    CHILD_HTML_ELEMENT = 6,
	    TEMPLATE = 7,
	    FIELD = 8,
	    FIELDS = 9,
	    ICON = 10,
	    COLOR = 11,
	    OBJECT = 12,
	    QUERY = 13,
	    HELPER = 14,
	    LONG_STRING = 15,
	    JSON = 16,
	    JAVASCRIPT = 17,
	    NONE = 18,
	    QUERY_EXPRESSION = 19,
	}

}
declare module Coveo {
	class ComponentOptionLoader {
	    element: HTMLElement;
	    values: any;
	    optionName: string;
	    optionDefinition: IComponentOptionsOption<any>;
	    constructor(element: HTMLElement, values: any);
	    load(): any;
	}

}
declare module Coveo {
	interface IComponentOptionsToMerge {
	    name: string;
	    value: any;
	}
	class ComponentOptionsMerger {
	    optionDefinition: IComponentOptionsOption<any>;
	    valueToMerge: IComponentOptionsToMerge;
	    optionsDictionary: any;
	    constructor(optionDefinition: IComponentOptionsOption<any>, valueToMerge: IComponentOptionsToMerge, optionsDictionary: any);
	    merge(): IComponentOptionsToMerge;
	}

}
declare module Coveo {
	class ComponentOptionsPostProcessor<T> {
	    allOptionsDefinitions: {
	        [name: string]: IComponentOptionsOption<T>;
	    };
	    optionsDictionnary: any;
	    componentID: string;
	    constructor(allOptionsDefinitions: {
	        [name: string]: IComponentOptionsOption<T>;
	    }, optionsDictionnary: any, componentID: string);
	    postProcess(): void;
	}

}
declare module Coveo {
	interface IComponentOptionsToValidate<T> {
	    name: string;
	    value: T;
	    componentID: string;
	}
	class ComponentOptionsValidator<T> {
	    optionDefinition: IComponentOptionsOption<T>;
	    valueToValidate: IComponentOptionsToValidate<T>;
	    optionsDictionnary: any;
	    constructor(optionDefinition: IComponentOptionsOption<T>, valueToValidate: IComponentOptionsToValidate<T>, optionsDictionnary: any);
	    validate(): void;
	}

}
declare module Coveo {
	interface ITemplateFromStringProperties {
	    condition?: string;
	    layout?: ValidLayout;
	    mobile?: boolean;
	    tablet?: boolean;
	    desktop?: boolean;
	    fieldsToMatch?: IFieldsToMatch[];
	    role?: TemplateRole;
	}
	class TemplateFromAScriptTag {
	    template: Template;
	    scriptTag: HTMLElement;
	    constructor(template: Template, scriptTag: HTMLElement);
	    toHtmlElement(container?: Dom): HTMLElement;
	    parseFieldsAttributes(): IFieldsToMatch[];
	    parseScreenSize(attribute: string): boolean;
	    parseLayout(): ValidLayout;
	    static fromString(template: string, properties?: ITemplateFromStringProperties, container?: HTMLElement): HTMLElement;
	}

}
declare module Coveo {
	class HtmlTemplate extends Template {
	    element: HTMLElement;
	    static mimeTypes: string[];
	    constructor(element: HTMLElement);
	    toHtmlElement(): HTMLElement;
	    getType(): string;
	    static create(element: HTMLElement): HtmlTemplate;
	    static fromString(template: string, properties: ITemplateFromStringProperties): HtmlTemplate;
	    protected getTemplateInfo(): HTMLElement;
	}

}
declare module Coveo {
	/**
	 * A function that describe a templates.
	 *
	 * It can take any number of arguments, but needs to return a simple string.
	 */
	interface ITemplateHelperFunction {
	    (...args: any[]): string;
	}
	/**
	 * Allow to register and return template helpers (essentially: Utility functions that can be executed in the context of a template to render complex elements).
	 */
	class TemplateHelpers {
	    static fieldHelpers: string[];
	    static registerFieldHelper(name: string, helper: (value: string, options?: any) => string): void;
	    static registerTemplateHelper<T1>(name: string, helper: (arg1: T1) => string): any;
	    static registerTemplateHelper<T1, T2>(name: string, helper: (arg1: T1, arg2: T2) => string): any;
	    static registerTemplateHelper<T1, T2, T3>(name: string, helper: (arg1: T1, arg2: T2, arg3: T3) => string): any;
	    static registerTemplateHelper<T1, T2, T3, T4>(name: string, helper: (arg1: T1, arg2: T2, arg3: T3, arg4: T4) => string): any;
	    static registerTemplateHelper<T1, T2, T3, T4, T5>(name: string, helper: (arg1: T1, arg2: T2, arg3: T3, arg4: T4, arg5: T5) => string): any;
	    /**
	     * Return a template helper function
	     * @param name
	     * @returns {ITemplateHelperFunction}
	     */
	    static getHelper(name: string): ITemplateHelperFunction;
	    /**
	     * Get all available helpers
	     */
	    static getHelpers(): {
	        [templateName: string]: ITemplateHelperFunction;
	    };
	}

}
declare module Coveo {
	class DefaultResultTemplate extends Template {
	    constructor();
	    instantiateToString(object: IQueryResult, instantiateOptions?: IInstantiateTemplateOptions): string;
	    getFields(): any[];
	    getType(): string;
	    getFallbackTemplate(): string;
	}

}
declare module Coveo {
	class UnderscoreTemplate extends Template {
	    element: HTMLElement;
	    static templateHelpers: {
	        [templateName: string]: ITemplateHelperFunction;
	    };
	    static mimeTypes: string[];
	    constructor(element: HTMLElement);
	    toHtmlElement(): HTMLElement;
	    getType(): string;
	    protected getTemplateInfo(): HTMLElement;
	    static registerTemplateHelper(helperName: string, helper: ITemplateHelperFunction): void;
	    static isLibraryAvailable(): boolean;
	    static fromString(template: string, properties: ITemplateFromStringProperties): UnderscoreTemplate;
	    static create(element: HTMLElement): UnderscoreTemplate;
	}

}
declare module Coveo {
	/**
	 * Holds a reference to all template available in the framework
	 */
	class TemplateCache {
	    static registerTemplate(name: string, template: Template, publicTemplate?: boolean, defaultTemplate?: boolean, pageTemplate?: boolean): any;
	    static registerTemplate(name: string, template: (data: {}) => string, publicTemplate?: boolean, defaultTemplate?: boolean, pageTemplate?: boolean): any;
	    /**
	     * Remove the given template from the cache.
	     * @param name
	     * @param string
	     */
	    static unregisterTemplate(name: any): void;
	    /**
	     * Return a template by its name/FacID.
	     * @param name
	     * @returns {Template}
	     */
	    static getTemplate(name: string): Template;
	    /**
	     * Get all templates currently registered in the framework.
	     * @returns {{}}
	     */
	    static getTemplates(): {
	        [templateName: string]: Template;
	    };
	    /**
	     * Get all templates name currently registered in the framework.
	     * @returns {string[]}
	     */
	    static getTemplateNames(): string[];
	    /**
	     * Get all page templates name currently registered in the framework.
	     * @returns {string[]}
	     */
	    static getResultListTemplateNames(): string[];
	    /**
	     * Get all the "default" templates in the framework.
	     * @returns {string[]}
	     */
	    static getDefaultTemplates(): string[];
	    /**
	     * Get a default template by name.
	     * @param name The name of the queried template
	     */
	    static getDefaultTemplate(name: string): Template;
	    static scanAndRegisterTemplates(): void;
	}

}
declare module Coveo {
	class TemplateList extends Template {
	    templates: Template[];
	    constructor(templates: Template[]);
	    instantiateToString(object: IQueryResult, instantiateOptions?: IInstantiateTemplateOptions): string;
	    instantiateToElement(object: IQueryResult, instantiateOptions?: IInstantiateTemplateOptions): Promise<HTMLElement>;
	    getFields(): string[];
	    getType(): string;
	    protected getFallbackTemplate(): Template;
	}

}
declare module Coveo {
	interface IComponentOptionsTemplateOptionArgs extends IComponentOptions<Template> {
	    /**
	     * Specifies the CSS selector the template must match. The first matching element in the page is used as the template
	     * option value, if this element is a valid template.
	     *
	     * If specified, this parameter takes precedence over [`idAttr`]{@link IComponentOptionsTemplateOptionArgs.idAttr}.
	     */
	    selectorAttr?: string;
	    /**
	     * Specifies the CSS selector the templates must match. The list of all matching, valid elements in the page is used
	     * as the template option value.
	     *
	     * Default value is `.`, followed by the hyphened name of the template option being configured (e.g.,
	     * `.content-template`, `.result-template`, `.sub-result-template`, `.preview-template`, etc.).
	     */
	    childSelector?: string;
	    /**
	     * Specifies the HTML `id` attribute the template must match. The corresponding template must be registered in
	     * the [`TemplateCache`]{@link TemplateCache} to be usable as the template option value.
	     *
	     * If specified, this parameter takes precedence over
	     * [`childSelector`]{@link IComponentOptionsTemplateOptionArgs.childSelector}.
	     */
	    idAttr?: string;
	}
	interface IComponentOptionsTemplateOption extends IComponentOptionsOption<Template>, IComponentOptionsTemplateOptionArgs {
	}
	class TemplateComponentOptions {
	    /**
	     * Builds a template option.
	     *
	     * The option accepts a CSS selector matching a valid template. This selector can either be a class, or an ID
	     * selector.
	     *
	     * When building a template option using an ID selector, the matching template must be registered in the
	     * [`TemplateCache`]{@link TemplateCache}, however.
	     *
	     * **Markup Examples:**
	     *
	     * > `data-foo-id="#bar"`
	     *
	     * > `data-foo-selector=".bar"`
	     *
	     * @param optionArgs The arguments to apply when building the option.
	     * @returns {Template} The resulting option value.
	     */
	    static buildTemplateOption(optionArgs?: IComponentOptionsTemplateOptionArgs): Template;
	    static loadTemplateOption(element: HTMLElement, name: string, option: IComponentOptionsTemplateOption, doc?: Document): Template;
	    static createResultTemplateFromElement(element: HTMLElement): Template;
	    static loadResultTemplateFromId(templateId: string): Template;
	    static loadChildrenResultTemplateFromSelector(element: HTMLElement, selector: string): Template;
	}

}
declare module Coveo {
	/**
	 * The `ComponentOptions` static class contains methods allowing the Coveo JavaScript Search Framework to initialize
	 * component options.
	 *
	 * Typically, each [`Component`]{@link Component} that exposes a set of options contains a static `options` property.
	 *
	 * This property "builds" each option using the `ComponentOptions` method corresponding to its type (e.g.,
	 * [`buildBooleanOption`]{@link ComponentOptions.buildBooleanOption},
	 * [`buildFieldOption`]{@link ComponentOptions.buildFieldOption},
	 * [`buildStringOption`]{@link ComponentOptions.buildStringOption}, etc.)
	 */
	class ComponentOptions {
	    static buildTemplateOption(optionArgs?: IComponentOptionsTemplateOptionArgs): Template;
	    /**
	     * Builds a boolean option.
	     *
	     * **Markup Examples:**
	     *
	     * > `data-foo="true"`
	     *
	     * > `data-foo="false"`
	     *
	     * @param optionArgs The arguments to apply when building the option.
	     * @returns {boolean} The resulting option value.
	     */
	    static buildBooleanOption(optionArgs?: IComponentOptions<boolean>): boolean;
	    /**
	     * Builds a number option.
	     *
	     * A number option can be an integer or a float in the markup.
	     *
	     * **Note:**
	     *
	     * > To build a float option, you need to set the `float` property in the [`IComponentOptionsNumberOptionArgs`]{@link IComponentOptionsNumberOptionArgs} to `true`.
	     *
	     * **Markup Examples:**
	     *
	     * > `data-foo="3"`
	     *
	     * > `data-foo="1.5"`
	     *
	     * @param optionArgs The arguments to apply when building the option.
	     * @returns {number} The resulting option value.
	     */
	    static buildNumberOption(optionArgs?: IComponentOptionsNumberOptionArgs): number;
	    /**
	     * Builds a string option.
	     *
	     * A string option can be any arbitrary string in the markup.
	     *
	     * **Markup Example:**
	     *
	     * > `data-foo="bar"`
	     *
	     * @param optionArgs The arguments to apply when building the option.
	     * @returns {string} The resulting option value.
	     */
	    static buildStringOption<T extends string>(optionArgs?: IComponentOptions<T>): T;
	    /**
	     * Builds an icon option.
	     *
	     * This takes an SVG icon name, validates it and returns the name of the icon.
	     * **Markup Examples:**
	     *
	     * > `data-foo="search"`
	     *
	     * > `data-foo="facet-expand"`
	     *
	     * @param optionArgs The arguments to apply when building the option.
	     * @returns {string} The resulting option value.
	     */
	    static buildIconOption(optionArgs?: IComponentOptions<string>): string;
	    /**
	     * Builds a color option.
	     *
	     * Normally, this simply builds a string that matches a CSS color.
	     *
	     * **Note:**
	     *
	     * > In the markup, this offers no advantage over using a plain string. This is mostly useful for the Coveo JavaScript
	     * > Interface Editor.
	     *
	     * **Markup Examples:**
	     *
	     * > `data-foo="coveo-sprites-user"`
	     *
	     * > `data-foo="coveo-sprites-database"`
	     *
	     * @param optionArgs The arguments to apply when building the option.
	     * @returns {string} The resulting option value.
	     */
	    static buildColorOption(optionArgs?: IComponentOptions<string>): string;
	    /**
	     * Builds a helper option.
	     *
	     * Normally, this simply builds a string that matches the name of a template helper.
	     *
	     * **Note:**
	     *
	     * > In the markup, this offers no advantage over using a plain string. This is mostly useful for the Coveo JavaScript
	     * > Interface Editor.
	     *
	     * **Markup Examples:**
	     *
	     * > `data-foo="date"`
	     *
	     * > `data-foo="dateTime"`
	     *
	     * @param optionArgs The arguments to apply when building the option.
	     * @returns {string} The resulting option value.
	     */
	    static buildHelperOption(optionArgs?: IComponentOptions<string>): string;
	    /**
	     * Tries to parse a stringified JSON option.
	     *
	     * If unsuccessful (because of invalid syntax), the JSON option is ignored altogether, and the console displays a warning message.
	     *
	     * **Markup Example:**
	     *
	     * > `data-foo='{"bar" : "baz"}'`
	     *
	     * **Note:**
	     *
	     * A JSON option can always be set as a property in the `init` call of the framework rather than as a `data-` property in the corresponding HTMLElement markup.
	     *
	     * **Initialization Example:**
	     *
	     * ```
	     * Coveo.init(root, {
	     *   Facet : {
	     *     foo : {
	     *       "bar" : "baz"
	     *     }
	     *   }
	     * })
	     * ```
	     * @param optionArgs The arguments to apply when building the option.
	     * @returns {T} The resulting option value.
	     */
	    static buildJsonOption<T extends IStringMap<any>>(optionArgs?: IComponentJsonObjectOption<T>): T;
	    /**
	     * @deprecated Use buildJsonOption instead
	     *
	     * @deprecatedsince [2017 Javascript Search Framework Releases](https://docs.coveo.com/en/373/#december-2017-release-v236794)
	     */
	    static buildJsonObjectOption<T>(optionArgs?: IComponentJsonObjectOption<T>): T;
	    /**
	     * Builds a localized string option.
	     *
	     * A localized string option can be any arbitrary string.
	     *
	     * When parsing the value, the Coveo JavaScript Search Framework tries to load the localization for that string, if it
	     * is available.
	     *
	     * If it is not available, it returns the non-localized value.
	     *
	     * This should be used for options that will be rendered directly to the end users.
	     *
	     * **Markup Example:**
	     *
	     * > `data-foo="bar"`
	     *
	     * @param optionArgs The arguments to apply when building the option.
	     * @returns {string} The resulting option value.
	     */
	    static buildLocalizedStringOption(optionArgs?: IComponentLocalizedStringOptionArgs): string;
	    /**
	     * Builds a field option.
	     *
	     * A field option validates whether the field has a valid name. This means that the string must start with the `@`
	     * character.
	     *
	     * **Markup Example:**
	     *
	     * > `data-foo="@bar"`
	     *
	     * @param optionArgs The arguments to apply when building the option.
	     * @returns {string} The resulting option value.
	     */
	    static buildFieldOption(optionArgs?: IComponentOptionsFieldOptionArgs): IFieldOption;
	    /**
	     * Builds an array of fields option.
	     *
	     * As with all options that expect an array, you should use commas to delimit the different values.
	     *
	     * **Markup Example:**
	     *
	     * > `data-foo="@bar,@baz"`
	     *
	     * @param optionArgs The arguments to apply when building the option.
	     * @returns {string[]} The resulting option value.
	     */
	    static buildFieldsOption(optionArgs?: IComponentOptionsFieldsOptionArgs): IFieldOption[];
	    /**
	     * Builds a query expression option.
	     *
	     * The query expression option should follow the [Coveo Cloud Query Syntax Reference](https://docs.coveo.com/en/1552/).
	     *
	     * **Markup Example:**
	     *
	     * > `data-foo="@bar==baz"`
	     *
	     * @param optionArgs The arguments to apply when building the option.
	     * @returns {IQueryExpression} The resulting option value.
	     */
	    static buildQueryExpressionOption(optionArgs?: IComponentOptions<string>): IQueryExpression;
	    /**
	     * Builds an array of strings option.
	     *
	     * As with all options that expect an array, you should use commas to delimit the different values.
	     *
	     * **Markup Example:**
	     *
	     * > `data-foo="bar,baz"`
	     *
	     * @param optionArgs The arguments to apply when building the option.
	     * @returns {string[]} The resulting option value.
	     */
	    static buildListOption<T>(optionArgs?: IComponentOptionsListOptionArgs): T[] | string[];
	    /**
	     * Builds an option that allow to select an HTMLElement.
	     *
	     * The option accepts a CSS selector matching the required HTMLElement. This selector can either be a class, or an ID
	     * selector.
	     *
	     * **Markup Examples:**
	     *
	     * > `data-foo-selector=".bar"`
	     *
	     * > `data-foo-selector="#bar"`
	     *
	     * @param optionArgs The arguments to apply when building the option.
	     * @returns {HTMLElement} The resulting option value.
	     */
	    static buildSelectorOption(optionArgs?: IComponentOptions<HTMLElement>): HTMLElement;
	    static buildChildHtmlElementOption(optionArgs?: IComponentOptionsChildHtmlElementOptionArgs): HTMLElement;
	    static buildCustomOption<T>(converter: (value: string) => T, optionArgs?: IComponentOptions<T>): T;
	    static buildCustomListOption<T>(converter: (value: string[]) => T, optionArgs?: IComponentOptionsCustomListOptionArgs<T>): T;
	    static buildObjectOption(optionArgs?: IComponentOptionsObjectOptionArgs): any;
	    /**
	     * Builds a field condition option.
	     *
	     * A field condition option defines a field-based condition that must be dynamically evaluated against,
	     * and satisfied by a query result item in order to initialize a result template component.
	     *
	     * **Markup Example:**
	     *
	     * ```html
	     * data-condition-field-author="Alice Smith, Bob Jones"
	     * data-condition-field-not-filetype="pdf"`
	     * ```
	     *
	     * @returns {string} The resulting option value.
	     */
	    static buildFieldConditionOption(): IFieldConditionOption[];
	    static buildOption<T>(type: ComponentOptionsType, load: IComponentOptionsLoadOption<T>, optionArg?: IComponentOptions<T>): T;
	    static attrNameFromName(name: string, optionArgs?: IComponentOptions<any>): string;
	    static camelCaseToHyphen(name: string): string;
	    static mergeCamelCase(parent: string, name: string): string;
	    /**
	     * Loads and parses the options of the current element.
	     *
	     * Each component calls this method in its constructor.
	     *
	     * @param element The element whose markup options the method should load and parse.
	     * @param component The class of the component whose options the method should load and parse (e.g., `Searchbox`,
	     * `Facet`, etc.)
	     * @param values The additional options which the method should merge with the specified markup option values.
	     */
	    static initComponentOptions(element: HTMLElement, component: any, values?: any): any;
	    static initOptions(element: HTMLElement, options: {
	        [name: string]: IComponentOptionsOption<any>;
	    }, values: any, componentID: string): any;
	    static tryLoadFromAttribute(element: HTMLElement, name: string, optionDefinition: IComponentOptionsOption<any>): any;
	    static loadStringOption<T extends string>(element: HTMLElement, name: string, option: IComponentOptions<any>): T;
	    static loadIconOption(element: HTMLElement, name: string, option: IComponentOptions<any>): string;
	    static loadFieldOption(element: HTMLElement, name: string, option: IComponentOptionsOption<any>): string;
	    static loadFieldConditionOption(element: HTMLElement, name: string, option: IComponentOptionsOption<any>): IFieldConditionOption[];
	    static loadFieldsOption(element: HTMLElement, name: string, option: IComponentOptionsOption<any>): string[];
	    static loadLocalizedStringOption(element: HTMLElement, name: string, option: IComponentOptionsOption<any>): string;
	    static loadNumberOption(element: HTMLElement, name: string, option: IComponentOptionsNumberOption): number;
	    static loadBooleanOption(element: HTMLElement, name: string, option: IComponentOptionsOption<any>): boolean;
	    static loadListOption(element: HTMLElement, name: string, option: IComponentOptionsListOption): string[];
	    static loadEnumOption(element: HTMLElement, name: string, option: IComponentOptionsOption<any>, _enum: any): number;
	    static loadJsonObjectOption<T>(element: HTMLElement, name: string, option: IComponentOptions<any>): T;
	    static loadSelectorOption(element: HTMLElement, name: string, option: IComponentOptionsOption<any>, doc?: Document): HTMLElement;
	    static loadChildHtmlElementOption(element: HTMLElement, name: string, option: IComponentOptionsChildHtmlElementOption, doc?: Document): HTMLElement;
	    static loadChildHtmlElementFromSelector(element: HTMLElement, selector: string): HTMLElement;
	    static loadChildrenHtmlElementFromSelector(element: HTMLElement, selector: string): HTMLElement[];
	    static findParentScrolling(element: HTMLElement, doc?: Document): HTMLElement;
	    static findParentScrollLockable(element: HTMLElement, doc?: Document): HTMLElement;
	    static isElementScrollable(element: HTMLElement): boolean;
	    static getAttributeFromAlias(element: HTMLElement, option: IComponentOptions<any>): any;
	}

}
declare module Coveo {
	/**
	 * The `IPopulateOmniboxObject` is an interface that is used by components to interact with the Omnibox and provides a framework for type-ahead suggestions.
	 */
	interface IPopulateOmniboxObject {
	    /**
	     * A {@link IPopulateOmniboxQueryExpression} object used to describe the complete content of the Querybox component.
	     */
	    completeQueryExpression: IPopulateOmniboxQueryExpression;
	    /**
	     * A {@link IPopulateOmniboxQueryExpression} object used to describe the current active content (the current position of the cursor/caret) of the Omnibox component.
	     */
	    currentQueryExpression: IPopulateOmniboxQueryExpression;
	    /**
	     * An array {@link IPopulateOmniboxQueryExpression} used to describe each part of the content of the Omnibox component.
	     */
	    allQueryExpressions: IPopulateOmniboxQueryExpression[];
	    /**
	     * The number representing the current position of the cursor/caret inside the {@link Omnibox} component.
	     */
	    cursorPosition: number;
	    /**
	     * Clears the content of the {@link Omnibox} Component.
	     */
	    clear(): void;
	    /**
	     * Clears the current expression (current cursor position in the Omnibox).
	     */
	    clearCurrentExpression(): void;
	    /**
	     * Replaces the specified `searchValue` by the `newValue` in the Omnibox.
	     * @param searchValue
	     * @param newValue
	     */
	    replace(searchValue: string, newValue: string): void;
	    /**
	     * Replaces the current expression in the `QueryBox` (the current cursor position in the omnibox) by the `newValue`.
	     * @param newValue
	     */
	    replaceCurrentExpression(newValue: string): void;
	    /**
	     * Inserts new content in the omnibox at the specified position.
	     * @param at
	     * @param toInsert
	     */
	    insertAt(at: number, toInsert: string): void;
	    /**
	     * Closes the Omnibox.
	     */
	    closeOmnibox(): void;
	}
	/**
	 * This object is a simple interface that describes the content of an omnibox query expression.
	 */
	interface IPopulateOmniboxQueryExpression {
	    /**
	     * This is a simple string with the plain content of the {@link Omnibox}.
	     */
	    word: string;
	    /**
	     * This is a regex of the content of the {@link Omnibox} with some special character escaped.
	     */
	    regex: RegExp;
	}
	interface IOmniboxData extends IPopulateOmniboxObject {
	    rows: IOmniboxDataRow[];
	}
	/**
	 * The content that external code that wants to populate the omnibox need to populate.
	 */
	interface IOmniboxDataRow {
	    /**
	     * This is an optional property. It is used by each component to influence their rendering order in the Omnibox. It works like a normal CSS `zIndex`: higher value will render at the top most level. Providing no `zIndex` will make your item render with a low priority.
	     */
	    zIndex?: number;
	    /**
	     * This an `HTMLElement` that you want the Omnibox to render.
	     *
	     * It can be any valid HTML element (div, span, image, table, etc.). You can bind any event you want to this element and also add logic to handle the Omnibox (e.g. should the Omnibox close itself when clicking on your suggestion, should the Omnibox clear itself?).
	     *
	     * This element you provide can be as complex as you want it to be (see Providing Suggestions for the Omnibox).
	     */
	    element?: HTMLElement;
	    /**
	     * This is a Promise object. It is used when you want to make an asynchronous call (most likely an Ajax request) to a service in order to retrieve the data that you will use to build your HTML content.
	     */
	    deferred?: Promise<IOmniboxDataRow>;
	}

}
declare module Coveo {
	class RefResult extends Result {
	    expression: Expression;
	    input: string;
	    failAttempt: Result;
	    constructor(results: Result[], expression: Expression, input: string, lastResult: Result);
	    /**
	     * Return all fail result.
	     */
	    getExpect(): Result[];
	    /**
	     * Clean the result to have the most relevant result. If the result is successful just return a clone of it.
	     */
	    clean(path?: Result[]): Result;
	}

}
declare module Coveo {

}
declare module Coveo {
	class ExpressionRef implements Expression {
	    ref: string;
	    occurrence: string | number;
	    id: string;
	    grammar: Grammar;
	    constructor(ref: string, occurrence: string | number, id: string, grammar: Grammar);
	    parse(input: string, end: boolean): Result;
	    parseOnce(input: string, end: boolean, ref: Expression): Result;
	    parseMany(input: string, end: boolean, ref: Expression): RefResult;
	    toString(): string;
	}

}
declare module Coveo {
	class OptionResult extends Result {
	    expression: Expression;
	    input: string;
	    failAttempt: Result[];
	    constructor(result: Result, expression: Expression, input: string, failAttempt: Result[]);
	    /**
	     * Return all fail result.
	     */
	    getExpect(): Result[];
	    /**
	     * Clean the result to have the most relevant result. If the result is successful just return a clone of it.
	     */
	    clean(path?: Result[]): Result;
	}

}
declare module Coveo {
	class ExpressionOptions implements Expression {
	    parts: ExpressionRef[];
	    id: string;
	    constructor(parts: ExpressionRef[], id: string);
	    parse(input: string, end: boolean): Result;
	    toString(): string;
	}

}
declare module Coveo {
	class ExpressionRegExp implements Expression {
	    value: RegExp;
	    id: string;
	    constructor(value: RegExp, id: string, grammar: Grammar);
	    parse(input: string, end: boolean): Result;
	    toString(): string;
	}

}
declare module Coveo {
	class ExpressionConstant implements Expression {
	    value: string;
	    id: string;
	    constructor(value: string, id: string);
	    parse(input: string, end: boolean): Result;
	    toString(): string;
	}

}
declare module Coveo {
	class ExpressionList implements Expression {
	    id: string;
	    constructor(parts: Expression[], id: string);
	    parse(input: string, end: boolean): Result;
	    toString(): string;
	}

}
declare module Coveo {
	class Grammar {
	    start: ExpressionRef;
	    expressions: {
	        [id: string]: Expression;
	    };
	    constructor(start: string, expressions?: {
	        [id: string]: ExpressionDef;
	    });
	    addExpressions(expressions: {
	        [id: string]: ExpressionDef;
	    }): void;
	    addExpression(id: string, basicExpression: ExpressionDef): void;
	    getExpression(id: string): Expression;
	    parse(value: string): Result;
	    static buildExpression(value: ExpressionDef, id: string, grammar: Grammar): Expression;
	    static buildStringExpression(value: string, id: string, grammar: Grammar): Expression;
	    static stringMatch(str: string, re: RegExp): string[][];
	    static spliter: RegExp;
	}

}
declare module Coveo {
	interface ExpressionFunctionArgument {
	    (input: string, end: boolean, expression: Expression): Result;
	}
	class ExpressionFunction implements Expression {
	    func: ExpressionFunctionArgument;
	    id: string;
	    grammar: Grammar;
	    constructor(func: ExpressionFunctionArgument, id: string, grammar: Grammar);
	    parse(input: string, end: boolean): Result;
	    toString(): string;
	}

}
declare module Coveo {
	type ExpressionDef = RegExp | string | string[] | ExpressionFunctionArgument;
	interface Expression {
	    id: string;
	    parse: (input: string, end: boolean) => Result;
	}

}
declare module Coveo {
	class Result {
	    expression: Expression;
	    input: string;
	    value: string;
	    subResults: Result[];
	    parent: Result;
	    constructor(value: string | Result[], expression: Expression, input: string);
	    isSuccess(): any;
	    /**
	     * Return path to this result ([parent.parent, parent, this])
	     */
	    path(until?: Result): Result[];
	    /**
	     * Return the closest parent that match the condition (can be it-self). If match is a string, it will search for the result expresion id
	     */
	    findParent(match: string | {
	        (result: Result): boolean;
	    }): Result;
	    /**
	     * Return the first child that match the condition (can be it-self). If match is a string, it will search for the result expresion id
	     */
	    find(match: string | {
	        (result: Result): boolean;
	    }): Result;
	    /**
	     * Return all children that match the condition (can be it-self). If match is a string, it will search for the result expresion id
	     */
	    findAll(match: string | {
	        (result: Result): boolean;
	    }): Result[];
	    /**
	     * Return the first child that match the condition (can be it-self). If match is a string, it will search for the result expresion id
	     */
	    resultAt(index: number, match?: string | {
	        (result: Result): boolean;
	    }): Result[];
	    /**
	     * Return all fail result.
	     */
	    getExpect(): Result[];
	    /**
	     * Return the best fail result (The farthest result who got parsed). We also remove duplicate and always return the simplest result of a kind
	     */
	    getBestExpect(): Result[];
	    getHumanReadableExpect(): string;
	    /**
	     * Return a string that represent what is before this result
	     */
	    before(): string;
	    /**
	     * Return a string that represent what is after this result
	     */
	    after(): string;
	    /**
	     * Return the length of the result
	     */
	    getLength(): any;
	    toHtmlElement(): HTMLElement;
	    /**
	     * Clean the result to have the most relevant result. If the result is successful just return a clone of it.
	     */
	    clean(path?: Result[]): Result;
	    clone(): Result;
	    toString(): any;
	    getHumanReadable(): string;
	}
	class EndOfInputResult extends Result {
	    constructor(result: Result);
	}

}
declare module Coveo {
	class MagicBoxUtils {
	    static escapeRegExp(str: any): any;
	    static highlightText(text: string, highligth: string, ignoreCase?: boolean, matchClass?: string, doNotMatchClass?: string): string;
	}

}
declare module Coveo {
	/// <reference path="Omnibox.d.ts" />
	class FieldAddon {
	    omnibox: Omnibox;
	    static INDEX: number;
	    cache: {
	        [hash: string]: Promise<IOmniboxSuggestion[]>;
	    };
	    constructor(omnibox: Omnibox);
	    getSuggestion(): Promise<IOmniboxSuggestion[]>;
	}

}
declare module Coveo {
	/**
	 * Information about a query extension
	 */
	interface IExtension {
	    /**
	     * The name of the extension
	     */
	    name: string;
	    /**
	     * An array of all possible arguments
	     */
	    argumentNames: string[];
	}

}
declare module Coveo {
	interface SubGrammar {
	    grammars?: {
	        [id: string]: ExpressionDef;
	    };
	    expressions?: string[];
	    basicExpressions?: string[];
	    include?: SubGrammar[];
	}
	function Expressions(...subGrammars: SubGrammar[]): {
	    start: string;
	    expressions: {
	        [id: string]: ExpressionDef;
	    };
	};
	function ExpressionsGrammar(...subGrammars: SubGrammar[]): Grammar;

}
declare module Coveo {

}
declare module Coveo {

}
declare module Coveo {

}
declare module Coveo {

}
declare module Coveo {

}
declare module Coveo {

}
declare module Coveo {

}
declare module Coveo {
	type SubGrammarImported = SubGrammar;
	type ExpressionFunctionArgumentImported = ExpressionFunctionArgument;
	const Grammars: {
	    Basic: SubGrammar;
	    notInWord: string;
	    notWordStart: string;
	    Complete: SubGrammar;
	    Date: SubGrammar;
	    Expressions: typeof Expressions;
	    ExpressionsGrammar: typeof ExpressionsGrammar;
	    Field: SubGrammar;
	    NestedQuery: SubGrammar;
	    QueryExtension: SubGrammar;
	    SubExpression: SubGrammar;
	};

}
declare module Coveo {
	enum KEYBOARD {
	    BACKSPACE = 8,
	    TAB = 9,
	    ENTER = 13,
	    SHIFT = 16,
	    CTRL = 17,
	    ALT = 18,
	    ESCAPE = 27,
	    SPACEBAR = 32,
	    PAGE_UP = 33,
	    PAGE_DOWN = 34,
	    END = 35,
	    HOME = 36,
	    LEFT_ARROW = 37,
	    UP_ARROW = 38,
	    RIGHT_ARROW = 39,
	    DOWN_ARROW = 40,
	    INSERT = 45,
	    DELETE = 46,
	}
	class KeyboardUtils {
	    static keysEqual(key: any, code: any): boolean;
	    static isAllowedKeyForOmnibox(e: KeyboardEvent): boolean;
	    static isAllowedKeyForSearchAsYouType(e: KeyboardEvent): boolean;
	    static isDeleteOrBackspace(e: KeyboardEvent): boolean;
	    static isArrowKeyPushed(keycode: number): boolean;
	    static isNumberKeyPushed(keycode: number): boolean;
	    static isLetterKeyPushed(keycode: number): boolean;
	    static keypressAction(keyCode: KEYBOARD | KEYBOARD[], action: Function): (e: KeyboardEvent, ...data: any[]) => void;
	}

}
declare module Coveo {
	class InputManager {
	    input: HTMLInputElement;
	    /**
	     * Binding event
	     */
	    onblur: () => void;
	    onfocus: () => void;
	    onkeyup: (key: number) => boolean;
	    onkeydown: (key: number) => boolean;
	    onchangecursor: () => void;
	    ontabpress: () => void;
	    expanded: boolean;
	    activeDescendant: HTMLElement;
	    constructor(element: HTMLElement, onchange: (text: string, wordCompletion: boolean) => void, magicBox: MagicBoxInstance);
	    /**
	     * Update the input with the result value
	     */
	    /**
	     * Update the highlight with the result value
	     */
	    /**
	     * Update the ghostText with the wordCompletion
	     */
	    /**
	     * Set the result and update visual if needed
	     */
	    setResult(result: Result, wordCompletion?: string): void;
	    /**
	     * Set the word completion. will be ignore if the word completion do not start with the result input
	     */
	    setWordCompletion(wordCompletion: string): void;
	    /**
	     * Set cursor position
	     */
	    setCursor(index: number): void;
	    getCursor(): number;
	    /**
	     * Update the scroll of the underlay this allowed the highlight to match the text
	     */
	    focus(): void;
	    blur(): void;
	    getValue(): string;
	    getWordCompletion(): string;
	}

}
declare module Coveo {
	interface IBuildingResultPreviewsQueryEventArgs {
	    /**
	     * The query to be sent to Search API.
	     */
	    query: IQuery;
	}
	/**
	 * Executed when a {@link Suggestion} is focused before {@link PopulateSearchResultPreviews} is called to fetch more options.
	 */
	interface IUpdateResultPreviewsManagerOptionsEventArgs {
	    /**
	     * How many milliseconds should a {@link Suggestion} be focused for before {@link PopulateSearchResultPreviews} is called.
	     *
	     * If this is not defined, it will default to 200ms.
	     */
	    displayAfterDuration?: number;
	}
	/**
	 * Executed when a {@link Suggestion} is focused and waiting for search result previews.
	 */
	interface IPopulateSearchResultPreviewsEventArgs {
	    /**
	     * The suggestion to look up search result previews for.
	     */
	    suggestion: Suggestion;
	    /**
	     * The result previews query. This must be set synchronously before the event resolves.
	     * Setting this to a non-empty array will display the given search result previews.
	     */
	    previewsQueries: (ISearchResultPreview[] | Promise<ISearchResultPreview[]>)[];
	}
	/**
	 * Those are the string definitions of events for ResultPreviewsManager.
	 *
	 * Those events should be bound to the element returned by `resolveRoot`.
	 */
	class ResultPreviewsManagerEvents {
	    /**
	     * Executed when building a query to fetch result previews.
	     * This always receives {@link IBuildingResultPreviewsQueryEventArgs} as arguments.
	     */
	    static buildingResultPreviewsQuery: string;
	    /**
	     * Executed when a {@link Suggestion} is focused before {@link PopulateSearchResultPreviews} is called to fetch more options.
	     * This always receives {@link IUpdateResultPreviewsManagerOptionsEventArgs} as arguments.
	     */
	    static updateResultPreviewsManagerOptions: string;
	    /**
	     * Executed when a {@link Suggestion} is focused and waiting for search result previews.
	     * This always receives {@link IPopulateSearchResultPreviewsEventArgs} as arguments.
	     */
	    static populateSearchResultPreviews: string;
	}

}
declare module Coveo {
	interface IQueryProcessorOptions {
	    timeout: number;
	}
	enum ProcessingStatus {
	    Finished = 0,
	    TimedOut = 1,
	    Overriden = 2,
	}
	interface IQueryProcessResult<T> {
	    status: ProcessingStatus;
	    results: T[];
	}
	class QueryProcessor<T> {
	    constructor(options?: any);
	    /**
	     * Overrides the previous queries and accumulates the result of promise arrays with a timeout.
	     */
	    processQueries(queries: (T[] | Promise<T[]>)[]): Promise<IQueryProcessResult<T>>;
	    overrideIfProcessing(): Promise<void>;
	}

}
declare module Coveo {
	interface ISearchResultPreview {
	    element: HTMLElement;
	    onSelect: () => void;
	}
	interface IResultPreviewsManagerOptions {
	    previewClass: string;
	    selectedClass: string;
	    previewHeaderText: string;
	    previewHeaderFieldText: string;
	    timeout: number;
	}
	class ResultPreviewsManager {
	     previewsOwner: Suggestion;
	     hasPreviews: boolean;
	     focusedPreviewElement: HTMLElement;
	     previewElements: HTMLElement[];
	    constructor(element: HTMLElement, options?: any);
	    displaySearchResultPreviewsForSuggestion(suggestion: Suggestion): Promise<void>;
	    getElementInDirection(direction: Direction): HTMLElement;
	}

}
declare module Coveo {
	interface Suggestion {
	    text?: string;
	    index?: number;
	    html?: string;
	    dom?: HTMLElement;
	    separator?: string;
	    advancedQuery?: string;
	    onSelect?: () => void;
	}
	interface SuggestionsManagerOptions {
	    suggestionClass?: string;
	    selectedClass?: string;
	    timeout?: number;
	    previewHeaderText?: string;
	}
	enum Direction {
	    Up,
	    Down,
	    Left,
	    Right,
	}
	class SuggestionsManager {
	    suggestionsListbox: Dom;
	     hasSuggestions: boolean;
	     hasFocus: boolean;
	     hasPreviews: boolean;
	    constructor(element: HTMLElement, magicBoxContainer: HTMLElement, inputManager: InputManager, options?: SuggestionsManagerOptions);
	    handleMouseOver(e: any): void;
	    handleMouseOut(e: any): void;
	    moveDown(): Promise<void>;
	    moveUp(): Promise<void>;
	    moveLeft(): Promise<void>;
	    moveRight(): Promise<void>;
	    selectAndReturnKeyboardFocusedElement(): HTMLElement;
	    clearKeyboardFocusedElement(): void;
	    receiveSuggestions(suggestions: (Promise<Suggestion[]> | Suggestion[])[]): Promise<Suggestion[]>;
	    clearSuggestions(): void;
	    updateSuggestions(suggestions: Suggestion[]): void;
	     selectedSuggestion: Suggestion;
	}

}
declare module Coveo {
	type ExpressionImportedLocally = Expression;
	type SuggestionImportedLocally = Suggestion;
	type SubGrammarLocally = SubGrammar;
	type ExpressionFunctionArgumentLocally = ExpressionFunctionArgument;
	const GrammarsImportedLocally: {
	    Basic: SubGrammar;
	    notInWord: string;
	    notWordStart: string;
	    Complete: SubGrammar;
	    Date: SubGrammar;
	    Expressions: (...subGrammars: SubGrammar[]) => {
	        start: string;
	        expressions: {
	            [id: string]: string | RegExp | string[] | ExpressionFunctionArgument;
	        };
	    };
	    ExpressionsGrammar: (...subGrammars: SubGrammar[]) => Grammar;
	    Field: SubGrammar;
	    NestedQuery: SubGrammar;
	    QueryExtension: SubGrammar;
	    SubExpression: SubGrammar;
	};
	function doMagicBoxExport(): void;
	namespace MagicBox {
	    const EndOfInputResult: EndOfInputResult;
	    const ExpressionConstant: ExpressionConstant;
	    const ExpressionFunction: ExpressionFunction;
	    const ExpressionList: ExpressionList;
	    const ExpressionOptions: ExpressionOptions;
	    const ExpressionRef: ExpressionRef;
	    const ExpressionRegExp: ExpressionRegExp;
	    const Grammar: Grammar;
	    const InputManager: InputManager;
	    const Instance: MagicBoxInstance;
	    const OptionResult: OptionResult;
	    const RefResult: RefResult;
	    const Result: Result;
	    const SuggestionsManager: SuggestionsManager;
	    const Utils: Utils;
	    const ExpressionEndOfInput: any;
	    type Instance = MagicBoxInstance;
	    type Suggestion = SuggestionImportedLocally;
	    namespace Grammars {
	        const Basic: typeof GrammarsImportedLocally.Basic;
	        const notInWord: typeof GrammarsImportedLocally.notInWord;
	        const notWordStart: typeof GrammarsImportedLocally.notWordStart;
	        const Complete: typeof GrammarsImportedLocally.Complete;
	        const Date: typeof GrammarsImportedLocally.Date;
	        const Expressions: typeof GrammarsImportedLocally.Expressions;
	        const ExpressionsGrammar: typeof GrammarsImportedLocally.ExpressionsGrammar;
	        const Field: typeof GrammarsImportedLocally.Field;
	        const NestedQuery: typeof GrammarsImportedLocally.NestedQuery;
	        const QueryExtension: typeof GrammarsImportedLocally.QueryExtension;
	        const SubExpression: typeof GrammarsImportedLocally.SubExpression;
	    }
	    const createMagicBox: any;
	    const create: any;
	    const requestAnimationFrame: any;
	}

}
declare module Coveo {
	enum ArrowDirection {
	    UP = 0,
	    RIGHT = 1,
	    DOWN = 2,
	    LEFT = 3,
	}
	class AccessibleButton {
	    constructor();
	    withOwner(owner: ComponentEvents): this;
	    withElement(element: Dom | HTMLElement): this;
	    withLabel(label: string): this;
	    withoutLabelOrTitle(): this;
	    withTitle(title: string): this;
	    withSelectAction(action: (e: Event) => void): this;
	    withClickAction(clickAction: (e: Event) => void): this;
	    withEnterKeyboardAction(enterAction: (e: Event) => void): this;
	    withFocusAndMouseEnterAction(action: (e: Event) => void): this;
	    withFocusAction(action: (e: Event) => void): this;
	    withMouseEnterAction(action: (e: Event) => void): this;
	    withBlurAndMouseLeaveAction(action: (e: Event) => void): this;
	    withMouseLeaveAction(action: (e: Event) => void): this;
	    withBlurAction(action: (e: Event) => void): this;
	    withArrowsAction(action: (direction: ArrowDirection, e: Event) => void): this;
	    withRole(role: string): this;
	    build(): this;
	}

}
declare module Coveo {
	class MagicBoxClear {
	    element: Dom;
	    constructor(magicBox: MagicBoxInstance);
	    toggleTabindexAndAriaHidden(hasText: boolean): void;
	}

}
declare module Coveo {
	interface Options {
	    inline?: boolean;
	    selectableSuggestionClass?: string;
	    selectedSuggestionClass?: string;
	    suggestionTimeout?: number;
	}
	class MagicBoxInstance {
	    element: HTMLElement;
	    grammar: Grammar;
	    options: Options;
	    onblur: () => void;
	    onfocus: () => void;
	    onchange: () => void;
	    onSuggestions: (suggestions: Suggestion[]) => void;
	    onsubmit: () => void;
	    onselect: (suggestion: Suggestion) => void;
	    onclear: () => void;
	    onmove: () => void;
	    ontabpress: () => void;
	    getSuggestions: () => Array<Promise<Suggestion[]> | Suggestion[]>;
	    constructor(element: HTMLElement, grammar: Grammar, options?: Options);
	    getResult(): Result;
	    getDisplayedResult(): Result;
	    setText(text: string): void;
	    setCursor(index: number): void;
	    getCursor(): number;
	    resultAtCursor(match?: string | {
	        (result: Result): boolean;
	    }): Result[];
	    addSuggestions(): Promise<void>;
	    focus(): void;
	    blur(): void;
	    clearSuggestion(): Promise<void>;
	    getText(): string;
	    getWordCompletion(): string;
	    clear(): void;
	    hasSuggestions(): boolean;
	}
	function createMagicBox(element: HTMLElement, grammar: Grammar, options?: Options): MagicBoxInstance;
	function requestAnimationFrame(callback: () => void): number;

}
declare module Coveo {
	/// <reference path="Omnibox.d.ts" />
	class QueryExtensionAddon {
	    omnibox: Omnibox;
	    static INDEX: number;
	    cache: {
	        [hash: string]: Promise<string[]>;
	    };
	    constructor(omnibox: Omnibox);
	    getSuggestion(): Promise<IOmniboxSuggestion[]>;
	    hash(): void;
	}

}
declare module Coveo {
	/**
	 * The IQuerySuggestCompletion interface describes a completion suggestion from the Coveo Machine Learning
	 * service (see [Coveo Machine Learning](https://docs.coveo.com/en/1727/).
	 */
	interface IQuerySuggestCompletion {
	    /**
	     * Contains the expression to complete.
	     */
	    expression: string;
	    /**
	     * Contains a value indicating how certain the Coveo Machine Learning service is that this suggestion is actually
	     * relevant.
	     */
	    score: number;
	    /**
	     * Contains the highlighted expression to complete.
	     */
	    highlighted: string;
	    /**
	     * Contains a value indicating the confidence level that this suggestion should be executed.
	     */
	    executableConfidence: number;
	}
	/**
	 * The IQuerySuggestResponse interface describes a response from the Coveo Machine Learning service query
	 * suggestions.
	 */
	interface IQuerySuggestResponse {
	    /**
	     * Contains an array of completions.
	     */
	    completions: IQuerySuggestCompletion[];
	}
	/**
	 * The IQuerySuggestRequest interface describes a request to the Coveo Machine Learning service query suggest.
	 */
	interface IQuerySuggestRequest {
	    /**
	     * Specifies the query / word for which to get completion.
	     */
	    q: string;
	    /**
	     * Specifies the search hub for which to get suggestions.
	     */
	    searchHub?: string;
	    /**
	     * Specifies the number of suggestions that the Coveo Machine Learning service should return.
	     *
	     * Default value is `5`.
	     */
	    count?: number;
	    /**
	     * Specifies the pipeline to use for the request.
	     */
	    pipeline?: string;
	    /**
	     * Specifies the context to use for the request.
	     */
	    context?: IStringMap<any>;
	    /**
	     * Specifies the second level of origin of the request, typically the identifier of the selected tab from which the request originates.
	     */
	    tab?: string;
	    /**
	     * Specifies the third level of origin of the request, typically the URL of the page that linked to the search interface from which the request originates (e.g., in JavaScript, this would correspond to the `document.referrer` value).
	     */
	    referrer?: string;
	    /**
	     * The locale of the current user. Will typically match the "language" parameter that is used to perform standard queries.
	     */
	    locale?: string;
	    /**
	     * Specifies whether to attempt to complete the last word of the current "q" parameter and boost the ranking score of the resulting expression so that it is returned as the first query suggestion.
	     */
	    enableWordCompletion?: boolean;
	    /**
	     * Specfies the actions history which represents the past actions a user made. It is generated by the page view script (https://github.com/coveo/coveo.analytics.js)
	     */
	    actionsHistory?: any[];
	    /**
	     * The tz database identifier of the time zone to use to correctly interpret dates in the query expression and result items.
	     */
	    timezone?: string;
	    /**
	     * A GUID representing the current user, who can be authenticated or anonymous. This GUID is normally generated by the usage analytics service and stored in a non-expiring browser cookie.
	     * @deprecated
	     */
	    visitorId?: string;
	    /**
	     * Whether the current user is anonymous. This can be specified when configuring the {@link SearchEndpoint}.
	     */
	    isGuestUser?: boolean;
	    autoCompleter?: string;
	    additionalData?: any;
	    format?: string;
	}

}
declare module Coveo {
	/// <reference path="Omnibox.d.ts" />
	interface IQuerySuggestAddon {
	    getSuggestion(): Promise<IOmniboxSuggestion[]>;
	}
	class QuerySuggestAddon implements IQuerySuggestAddon {
	    omnibox: Omnibox;
	    static INDEX: number;
	    constructor(omnibox: Omnibox);
	    getSuggestion(): Promise<IOmniboxSuggestion[]>;
	}
	class VoidQuerySuggestAddon implements IQuerySuggestAddon {
	    getSuggestion(): Promise<IOmniboxSuggestion[]>;
	}

}
declare module Coveo {
	/// <reference path="Omnibox.d.ts" />
	class OldOmniboxAddon {
	    omnibox: Omnibox;
	    constructor(omnibox: Omnibox);
	    getSuggestion(): Promise<IOmniboxSuggestion[]>[];
	}

}
declare module Coveo {
	/**
	 * Represent an item to insert in the breadcrumb
	 */
	interface IBreadcrumbItem {
	    /**
	     * The HTMLElement to insert in the breadcrumb
	     */
	    element: HTMLElement;
	}
	/**
	 * Event triggered when populating the breadcrumb
	 */
	interface IPopulateBreadcrumbEventArgs {
	    breadcrumbs: IBreadcrumbItem[];
	    headingLevel?: number;
	}
	interface IClearBreadcrumbEventArgs {
	}
	/**
	 * This static class is there to contains the different string definition for all the events related to {@link Breadcrumb}.
	 */
	class BreadcrumbEvents {
	    /**
	     * Triggered when the breadcrumb needs to update its content. External code can use this event to provide bits of HTML that should be included in the breadcrumb.
	     *
	     * All handlers bound to this event will receive a {@link IPopulateBreadcrumbEventArgs} as an argument.
	     */
	    static populateBreadcrumb: string;
	    /**
	     * Triggered when the user clicks the Clear All button in the breadcrumb. When this event is raised, every filter that is included in the breadcrumb should be removed.
	     *
	     * This event does not provide custom event data.
	     */
	    static clearBreadcrumb: string;
	    static redrawBreadcrumb: string;
	}

}
declare module Coveo {
	/**
	 * The `IBeforeRedirectEventArgs` interface describes the object that all
	 * [`beforeRedirect`]{@link StandaloneSearchInterfaceEvents.beforeRedirect} event handlers receive as an argument.
	 */
	interface IBeforeRedirectEventArgs {
	    /**
	     * The URI of the page that the search interface will redirect to when a query is performed by the [`StandaloneSearchBox`]{@link StandaloneSearchBox} component.
	     */
	    searchPageUri: string;
	    /**
	     * If this property is set to `true` by a `beforeRedirect` event handler, the [`StandaloneSearchBox`]{@link StandaloneSearchBox} component will not redirect to the full search page.
	     */
	    cancel: boolean;
	}
	/**
	 * The `StandaloneSearchInterfaceEvents` static class contains the string definitions of all events that strongly relate to the standalone search interface.
	 */
	class StandaloneSearchInterfaceEvents {
	    /**
	     * Triggered by the [`StandaloneSearchBox`]{@link StandaloneSearchBox} component during initialization, just before redirecting to the full search page.
	     *
	     * @type {string} The string value is `beforeRedirect`.
	     */
	    static beforeRedirect: string;
	}

}
declare module Coveo {
	class PendingSearchAsYouTypeSearchEvent extends PendingSearchEvent {
	    root: HTMLElement;
	    endpoint: AnalyticsEndpoint;
	    templateSearchEvent: ISearchEvent;
	    sendToCloud: any;
	    delayBeforeSending: number;
	    beforeResolve: Promise<PendingSearchAsYouTypeSearchEvent>;
	    constructor(root: HTMLElement, endpoint: AnalyticsEndpoint, templateSearchEvent: ISearchEvent, sendToCloud: any);
	    protected handleDuringQuery(e: Event, args: IDuringQueryEventArgs): void;
	    sendRightNow(): void;
	    modifyCustomData(key: string, newData: any): void;
	    modifyEventCause(newCause: IAnalyticsActionCause): void;
	    modifyQueryContent(query: string): void;
	    stopRecording(): void;
	}

}
declare module Coveo {
	function logSearchBoxSubmitEvent(client: IAnalyticsClient): void;
	function logSortEvent(client: IAnalyticsClient, resultsSortBy: string): void;

}
declare module Coveo {
	class QueryboxOptionsProcessing {
	    owner: Omnibox | Querybox;
	    constructor(owner: Omnibox | Querybox);
	    postProcess(): void;
	}

}
declare module Coveo {
	class QueryboxQueryParameters {
	    constructor(options: IQueryboxOptions);
	    static allowDuplicateQuery(): void;
	    addParameters(queryBuilder: QueryBuilder, lastQuery: string): void;
	}

}
declare module Coveo {
	interface IQueryboxOptions {
	    enableSearchAsYouType?: boolean;
	    searchAsYouTypeDelay?: number;
	    enableQuerySyntax?: boolean;
	    enableWildcards?: boolean;
	    enableQuestionMarks?: boolean;
	    enableLowercaseOperators?: boolean;
	    enablePartialMatch?: boolean;
	    partialMatchKeywords?: number;
	    partialMatchThreshold?: string;
	    placeholder?: string;
	    triggerQueryOnClear?: boolean;
	}
	/**
	 * The `Querybox` component renders an input which the end user can interact with to enter and submit queries.
	 *
	 * When the end user submits a search request, the `Querybox` component triggers a query and logs the corresponding
	 * usage analytics data.
	 *
	 * For technical reasons, it is necessary to instantiate this component on a `div` element rather than on an `input`
	 * element.
	 *
	 * See also the [`Searchbox`]{@link Searchbox} component, which can automatically instantiate a `Querybox` along with an
	 * optional [`SearchButton`]{@link SearchButton} component.
	 */
	class Querybox extends Component {
	    element: HTMLElement;
	    options: IQueryboxOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the Querybox.
	     * @componentOptions
	     */
	    static options: IQueryboxOptions;
	    MagicBoxImpl: any;
	    magicBox: MagicBoxInstance;
	    /**
	     * Creates a new `Querybox component`. Creates a new `Coveo.Magicbox` instance and wraps the Magicbox methods
	     * (`onblur`, `onsubmit` etc.). Binds event on `buildingQuery` and before redirection (for standalone box).
	     * @param element The HTMLElement on which to instantiate the component. This cannot be an HTMLInputElement for
	     * technical reasons.
	     * @param options The options for the `Querybox` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IQueryboxOptions, bindings?: IComponentBindings);
	    /**
	     * Adds the current content of the input to the query and triggers a query if the current content of the input has
	     * changed since last submit.
	     *
	     * Also logs the `serachboxSubmit` event in the usage analytics.
	     */
	    submit(): void;
	    /**
	     * Sets the content of the input.
	     *
	     * @param text The string to set in the input.
	     */
	    setText(text: string): void;
	    /**
	     * Clears the content of the input.
	     *
	     * See also the [`triggerQueryOnClear`]{@link Querybox.options.triggerQueryOnClear} option.
	     */
	    clear(): void;
	    /**
	     * Gets the content of the input.
	     *
	     * @returns {string} The content of the input.
	     */
	    getText(): string;
	    /**
	     * Gets the result from the input.
	     *
	     * @returns {Result} The result.
	     */
	    getResult(): Result;
	    /**
	     * Gets the displayed result from the input.
	     *
	     * @returns {Result} The displayed result.
	     */
	    getDisplayedResult(): Result;
	    /**
	     * Gets the current cursor position in the input.
	     *
	     * @returns {number} The cursor position (index starts at 0).
	     */
	    getCursor(): number;
	    /**
	     * Gets the result at cursor position.
	     *
	     * @param match {string | { (result): boolean }} The match condition.
	     *
	     * @returns {Result[]} The result.
	     */
	    resultAtCursor(match?: string | {
	        (result): boolean;
	    }): Result[];
	}

}
declare module Coveo {
	interface IOmniboxAnalytics {
	    partialQueries: string[];
	    suggestionRanking: number;
	    suggestions: string[];
	    partialQuery: string;
	    buildCustomDataForPartialQueries: () => IAnalyticsOmniboxSuggestionMeta;
	}
	class OmniboxAnalytics implements IOmniboxAnalytics {
	    partialQueries: string[];
	    suggestionRanking: number;
	    suggestions: string[];
	    partialQuery: string;
	    constructor();
	    buildCustomDataForPartialQueries(): IAnalyticsOmniboxSuggestionMeta;
	}

}
declare module Coveo {
	/// <reference path="FieldAddon.d.ts" />
	/// <reference path="QueryExtensionAddon.d.ts" />
	/// <reference path="QuerySuggestAddon.d.ts" />
	/// <reference path="OldOmniboxAddon.d.ts" />
	interface IOmniboxSuggestion extends Suggestion {
	    executableConfidence?: number;
	}
	interface IOmniboxOptions extends IQueryboxOptions {
	    inline?: boolean;
	    enableFieldAddon?: boolean;
	    enableSimpleFieldAddon?: boolean;
	    listOfFields?: IFieldOption[];
	    fieldAlias?: {
	        [alias: string]: IFieldOption;
	    };
	    enableQuerySuggestAddon?: boolean;
	    enableQueryExtensionAddon?: boolean;
	    omniboxTimeout?: number;
	    placeholder?: string;
	    numberOfSuggestions?: number;
	    querySuggestCharacterThreshold?: number;
	    grammar?: (grammar: {
	        start: string;
	        expressions: {
	            [id: string]: ExpressionDef;
	        };
	    }) => {
	        start: string;
	        expressions: {
	            [id: string]: ExpressionDef;
	        };
	    };
	    clearFiltersOnNewQuery?: boolean;
	}
	/**
	 * The `Omnibox` component extends the [`Querybox`]{@link Querybox}, and thus provides the same basic options and
	 * behaviors. Furthermore, the `Omnibox` adds a type-ahead capability to the search input.
	 *
	 * You can configure the type-ahead feature by enabling or disabling certain addons, which the Coveo JavaScript Search
	 * Framework provides out-of-the-box (see the [`enableFieldAddon`]{@link Omnibox.options.enableFieldAddon},
	 * [`enableQueryExtension`]{@link Omnibox.options.enableQueryExtensionAddon}, and
	 * [`enableQuerySuggestAddon`]{@link Omnibox.options.enableQuerySuggestAddon} options).
	 *
	 * Custom components and external code can also extend or customize the type-ahead feature and the query completion
	 * suggestions it provides by attaching their own handlers to the
	 * [`populateOmniboxSuggestions`]{@link OmniboxEvents.populateOmniboxSuggestions} event.
	 *
	 * See also the [`Searchbox`]{@link Searchbox} component, which can automatically instantiate an `Omnibox` along with an
	 * optional {@link SearchButton}.
	 */
	class Omnibox extends Component {
	    element: HTMLElement;
	    options: IOmniboxOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the omnibox
	     * @componentOptions
	     */
	    static options: IOmniboxOptions;
	    magicBox: MagicBoxInstance;
	    suggestionAddon: IQuerySuggestAddon;
	    /**
	     * Creates a new Omnibox component. Also enables necessary addons and binds events on various query events.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the Omnibox component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IOmniboxOptions, bindings?: IComponentBindings);
	    /**
	     * Adds the current content of the input to the query and triggers a query if the current content of the input has
	     * changed since last submit.
	     *
	     * Also logs a `searchboxSubmit` event in the usage analytics.
	     */
	    submit(): void;
	    /**
	     * Gets the current content of the input.
	     * @returns {string} The current content of the input.
	     */
	    getText(): string;
	    /**
	     * Sets the content of the input
	     * @param text The string to set in the input.
	     */
	    setText(text: string): void;
	    /**
	     * Clears the content of the input.
	     */
	    clear(): void;
	    /**
	     * Gets the `HTMLInputElement` of the Omnibox.
	     */
	    getInput(): HTMLInputElement;
	    getResult(): Result;
	    getDisplayedResult(): Result;
	    getCursor(): number;
	    resultAtCursor(match?: string | {
	        (result: Result): boolean;
	    }): Result[];
	    updateQueryState(): void;
	}

}
declare module Coveo {
	/**
	 * The `IPopulateOmniboxSuggestionsEventArgs` interface describes the object that all
	 * [`populateOmniboxSuggestions`]{@link OmniboxEvents.populateOmniboxSuggestions} event handlers receive as an argument.
	 */
	interface IPopulateOmniboxSuggestionsEventArgs {
	    /**
	     * The [`Omnibox`]{@link Omnibox} component instance.
	     */
	    omnibox: Omnibox;
	    /**
	     * The list of resolved query completion suggestions, and/or query completion suggestion promises.
	     */
	    suggestions: Array<Suggestion[] | Promise<Suggestion[]>>;
	}
	interface IPopulateOmniboxEventArgs extends IOmniboxData {
	}
	interface IPopulateOmniboxEventRow extends IOmniboxDataRow {
	}
	interface IOmniboxPreprocessResultForQueryEventArgs {
	    result: Result;
	}
	interface IBuildingQuerySuggestArgs {
	    payload: IQuerySuggestRequest;
	}
	interface IQuerySuggestSuccessArgs {
	    completions: IQuerySuggestCompletion[];
	}
	/**
	 * Describes the object that all [`querySuggestGetFocus`]{@link querySuggestGetFocus} and [`querySuggestSelection`]{@link querySuggestSelection} event handlers receive as an argument.
	 */
	interface IQuerySuggestSelection {
	    /**
	     * The query suggestion that had focus or was selected.
	     */
	    suggestion: string;
	}
	/**
	 * The `OmniboxEvents` static class contains the string definitions of all events that strongly relate to the
	 * [`Omnibox`]{@link Omnibox} component.
	 */
	class OmniboxEvents {
	    static populateOmnibox: string;
	    /**
	     * Triggered by the [`Omnibox`]{@link Omnibox} component before query completion suggestions are rendered.
	     *
	     * The out-of-the-box Coveo JavaScript Search Framework query completion suggestion addons (see the
	     * [`enableFieldAddon`]{@link Omnibox.options.enableFieldAddon},
	     * [`enableQueryExtensionAddon`]{@link Omnibox.options.enableQueryExtensionAddon}, and
	     * [`enableQuerySuggestAddon`]{@link Omnibox.options.enableQuerySuggestAddon} options of the `Omnibox`) push their
	     * respective suggestions in the argument object which is passed along with this event.
	     *
	     * All `populateOmniboxSuggestions` event handlers receive a
	     * [`PopulateOmniboxSuggestionsEventArgs`]{@link IPopulateOmniboxSuggestionsEventArgs} object as an argument.
	     *
	     * @type {string} The string value is `populateOmniboxSuggestions`.
	     */
	    static populateOmniboxSuggestions: string;
	    static omniboxPreprocessResultForQuery: string;
	    /**
	     * Triggered by the [`Omnibox`]{@link Omnibox} component before sending a query suggestion request to the Search API.
	     *
	     * Allows external functions to refine the payload b3efore sending the request.
	     *
	     * This event is only triggered by standard ML-powered query suggestions, and not {@link AnalyticsSuggestions} or {@link FieldSuggestions}.
	     */
	    static buildingQuerySuggest: string;
	    /**
	     * Triggered by the [`Omnibox`]{@link Omnibox} component when query suggestions are received from the Search API.
	     *
	     * Allows external functions to look into the received query suggestions, and modify them if needed.
	     *
	     * This event is only triggered by standard ML-powered query suggestions, and not {@link AnalyticsSuggestions} or {@link FieldSuggestions}.
	     */
	    static querySuggestSuccess: string;
	    /**
	     * Triggered by the [`Omnibox`]{@link Omnibox} component when a query suggestion has finished rendering.
	     */
	    static querySuggestRendered: string;
	    /**
	     * Triggered by the [`Omnibox`]{@link Omnibox} component when a query suggestion gets focus following a mouse hovering or keyboard navigation event.
	     *
	     * All `querySuggestGetFocus` event handlers receive an object implementing the [`IQuerySuggestSelection`]{@link IQuerySuggestSelection} interface as an argument.
	     */
	    static querySuggestGetFocus: string;
	    /**
	     * Triggered by the [`Omnibox`]{@link Omnibox} component when a query suggestion loses focus following a mouse hovering or keyboard navigation event.
	     */
	    static querySuggestLoseFocus: string;
	    /**
	     * Triggered by the [`Omnibox`]{@link Omnibox} component when a query suggestion is selected by a mouse click or pressing the enter key.
	     *
	     * All `querySuggestSelection` event handlers receive an object implementing the [`IQuerySuggestSelection`]{@link IQuerySuggestSelection} interface as an argument.
	     */
	    static querySuggestSelection: string;
	}

}
declare module Coveo {
	/**
	 * The `IDisplayedNewResultEventArgs` interface describes the object that all
	 * [`newResultDisplayed`]{@link ResultListEvents.newResultDisplayed} event handlers receive as an argument.
	 */
	interface IDisplayedNewResultEventArgs {
	    /**
	     * The query result that was just displayed by the [`ResultList`]{@link ResultList} component.
	     */
	    result: IQueryResult;
	    /**
	     * The HTML element which was rendered by the  the displayed result.
	     */
	    item: HTMLElement;
	}
	/**
	 * The `IDisplayedNewResultsEventArgs` interface describes the object that all
	 * [`newResultsDisplayed`]{@link ResultListEvents.newResultsDisplayed} event handlers receive as an argument.
	 */
	interface IDisplayedNewResultsEventArgs {
	    /**
	     * Whether the results are being displayed in a [`ResultList`]{@link ResultList} with infinite scroll enabled.
	     * See [`enableInfiniteScroll`]{@link ResultList.options.enableInfiniteScroll} option).
	     */
	    isInfiniteScrollEnabled: boolean;
	}
	/**
	 * The `IOpenQuickviewEventArgs` interface describes the object that all
	 * [`openQuickview`]{@link ResultList.openQuickview} event handlers receive as an argument.
	 */
	interface IOpenQuickviewEventArgs {
	    /**
	     * The array of query expression terms to highlight in the quickview modal window.
	     */
	    termsToHighlight: any;
	}
	/**
	 * The `IChangeLayoutEventArgs` interface describes the object that all
	 * [`ChangeLayout`]{@link ResultListEvents.changeLayout} event handlers receive as an argument.
	 */
	interface IChangeLayoutEventArgs {
	    /**
	     * The name of the new layout.
	     *
	     */
	    layout: ValidLayout;
	    /**
	     * The current page of results.
	     */
	    results?: IQueryResults;
	}
	/**
	 * The `ResultListEvents` static class contains the string definitions of all events that strongly relate to the result
	 * list.
	 *
	 * See [Events](https://docs.coveo.com/en/417/).
	 */
	class ResultListEvents {
	    /**
	     * Triggered when the result list has just finished rendering the current page of results.
	     *
	     * @type {string} The string value is `newResultsDisplayed`.
	     */
	    static newResultsDisplayed: string;
	    /**
	     * Triggered each time the result list has just finished rendering a single result.
	     *
	     * All `newResultDisplayed` event handlers receive a
	     * [`DisplayedNewResultEventArgs`]{@link IDisplayedNewResultEventArgs} object as an argument.
	     *
	     * @type {string} The string value is `newResultDisplayed`.
	     */
	    static newResultDisplayed: string;
	    /**
	     * Triggered by the [`ResultLink`]{@link ResultLink} result template component when its
	     * [`openQuickview`]{@link ResultLink.options.openQuickview} option is set to `true` and the end user clicks the
	     * result link. The [`Quickview`]{@link Quickview} component listens to this event to be able to open the quickview
	     * modal window in reaction.
	     *
	     * See also the [`openQuickview`]{@link QuickviewEvents.openQuickview} event (which is identical to this one, except
	     * that it is triggered by the [`QuickviewDocument`] result template component instead).
	     *
	     * All `openQuickview` event handlers receive an [`OpenQuickviewEventArgs`]{@link IOpenQuickviewEventArgs} object as
	     * an argument
	     *
	     * @type {string} The string value is `openQuickview`.
	     */
	    static openQuickview: string;
	    /**
	     * Triggered by the [`ResultLayout`]{@link ResultLayout} component whevoid the current result layout changes (see
	     * [Result Layouts](https://docs.coveo.com/en/360/)).
	     *
	     * All `changeLayout` event handlers receive a [`ChangeLayoutEventArgs`]{@link IChangeLayoutEventArgs} object as an
	     * argument.
	     *
	     * @type {string} The string value is `changeLayout`.
	     */
	    static changeLayout: string;
	}

}
declare module Coveo {
	class SettingsEvents {
	    static settingsPopulateMenu: string;
	}

}
declare module Coveo {
	interface ISavePreferencesEventArgs {
	}
	class PreferencesPanelEvents {
	    static savePreferences: string;
	    static exitPreferencesWithoutSave: string;
	}

}
declare module Coveo {
	interface IAPIDocumentViewEvent {
	    language: string;
	    device: string;
	    searchInterface: string;
	    searchHub: string;
	    responseTime: number;
	    searchQueryUid: string;
	    title: string;
	    documentUrl: string;
	    documentUri: string;
	    documentUriHash: string;
	    viewMethod: string;
	    actionCause: string;
	    queryPipeline: string;
	    splitTestRunName: string;
	    splitTestRunVersion: string;
	    collectionName: string;
	    sourceName: string;
	    documentPosition: number;
	    customMetadatas: {
	        [name: string]: string;
	    };
	}

}
declare module Coveo {
	interface IAPISearchEvent {
	    language: string;
	    device: string;
	    searchInterface: string;
	    searchHub: string;
	    responseTime: number;
	    customMetadatas: {
	        [name: string]: string;
	    };
	    queryText: string;
	    advancedQuery: string;
	    didYouMean: boolean;
	    numberOfResults: number;
	    resultsPerPage: number;
	    pageNumber: number;
	    type: string;
	    actionCause: string;
	    queryPipeline: string;
	    splitTestRunName: string;
	    splitTestRunVersion: string;
	    searchQueryUid: string;
	}

}
declare module Coveo {
	interface IAPICustomEvent {
	    language: string;
	    device: string;
	    searchInterface: string;
	    searchHub: string;
	    responseTime: number;
	    actionType: string;
	    actionCause: string;
	    customMetadatas: {
	        [name: string]: string;
	    };
	}

}
declare module Coveo {
	interface IAnalyticsSearchEventsArgs {
	    searchEvents: IAPISearchEvent[];
	}
	/**
	 * The `IAnalyticsDocumentViewEventArgs` interface describes the object that all
	 * [`documentViewEvent`]{@link AnalyticsEvents.documentViewEvent} handlers receive as an argument.
	 */
	interface IAnalyticsDocumentViewEventArgs {
	    /**
	     * The data to send in the request body of the Usage Analytics Write REST API call that logs the `click` event.
	     */
	    documentViewEvent: IAPIDocumentViewEvent;
	}
	interface IAnalyticsCustomEventArgs {
	    customEvent: IAPICustomEvent;
	}
	/**
	 * The object that all [`analyticsEventReady`]{@link AnalyticsEvents.analyticsEventReady} handlers receive as an argument.
	 */
	interface IAnalyticsEventArgs {
	    /**
	     * The type of Coveo Cloud usage analytics event.
	     */
	    event: 'CoveoCustomEvent' | 'CoveoClickEvent' | 'CoveoSearchEvent';
	    /**
	     * The fields describing the Coveo Cloud usage analytics event.
	     */
	    coveoAnalyticsEventData: ICustomEvent | IClickEvent | ISearchEvent;
	}
	/**
	 * The `IChangeAnalyticsCustomDataEventArgs` interface describes the object that all
	 * [`changeAnalyticsCustomData`]{@link AnalyticsEvents.changeAnalyticsCustomData} event handlers receive as an argument.
	 *
	 * This interface extends the [`IChangeableAnalyticsDataObject`]{@link IChangeableAnalyticsDataObject} interface.
	 *
	 * **Notes:**
	 * > * External code can only modify the attributes described by the `IChangeableAnalyticsDataObject` interface.
	 * > * When the analytics event being logged is a `ClickEvent`, the `ChangeAnalyticsCustomDataEventArgs` object also
	 * > contains a `resultData` attribute, which describes the [`QueryResult`]{@link IQueryResult} that was clicked.
	 * > External code **cannot** modify this object.
	 */
	interface IChangeAnalyticsCustomDataEventArgs extends IChangeableAnalyticsDataObject {
	    /**
	     * The type of the usage analytics event.
	     *
	     * **Note:**
	     * > External code **cannot** modify the value of this attribute.
	     */
	    type: 'SearchEvent' | 'CustomEvent' | 'ClickEvent';
	    /**
	     * The generic action type of the usage analytics event.
	     *
	     * All analytics events that strongly relate to a certain feature or component usually share the same `actionType`.
	     *
	     * For instance, all usage analytics events relating to the [`Facet`]{@link Facet} component have `facet` as their
	     * `actionType`, whereas all usage analytics events relating to the [`Breadcrumb`]{@link Breadcrumb} component have
	     * `breadcrumb` as their `actionType`.
	     *
	     * **Note:**
	     * > External code **cannot** modify the value of this attribute.
	     */
	    actionType: string;
	    /**
	     * The cause of the usage analytics event.
	     *
	     * For instance, triggering a query using the search box logs a usage analytics event with `searchBoxSubmit` as its
	     * `actionCause`, whereas triggering a query by selecting a facet value logs a usage analytics event with
	     * `facetSelect` as its `actionCause`.
	     *
	     * **Note:**
	     * > External code **cannot** modify the value of this attribute.
	     */
	    actionCause: string;
	}
	/**
	 * The `IChangeableAnalyticsMetaObject` interface describes the metadata which can be sent along with any usage
	 * analytics event.
	 */
	interface IChangeableAnalyticsMetaObject {
	    /**
	     * A metadata key-value pair to send along with the usage analytics event.
	     *
	     * **Notes:**
	     * > * A metadata key must contain only alphanumeric characters and underscores (the Coveo Usage Analytics REST
	     * > service automatically converts white spaces to underscores and uppercase characters to lowercase characters in key
	     * > names).
	     * > * A metadata value must be a simple string (no other type is allowed).
	     */
	    [name: string]: string;
	}
	/**
	 * The `IChangeableAnalyticsDataObject` interface describes the modifiable part of the object that all
	 * [`changeAnalyticsCustomData`]{@link AnalyticsEvents.changeAnalyticsCustomData} event handlers receive as an argument.
	 */
	interface IChangeableAnalyticsDataObject {
	    /**
	     * The metadata to send along with the usage analytics event.
	     *
	     * **Note:**
	     * > External code **can** modify existing values, or add new key-value pairs in this attribute.
	     */
	    metaObject: IChangeableAnalyticsMetaObject;
	    /**
	     * The high-level origin of the usage analytics event.
	     *
	     * For instance, this could be the name of the search hub, or a name that can uniquely identify the search page from
	     * which the usage analytics event originates.
	     *
	     * Default value is `default`.
	     *
	     * **Note:**
	     * > External code **can** modify the value of this attribute.
	     */
	    originLevel1: string;
	    /**
	     * The mid-level origin of the usage analytics event.
	     *
	     * By default, the framework populates this attribute with the `data-id` of the currently selected tab in the search
	     * interface from which the usage analytics event originates.
	     *
	     * **Note:**
	     * > External code **can** modify the value of this attribute.
	     */
	    originLevel2: string;
	    /**
	     * The low-level origin of the usage analytics event.
	     *
	     * For instance, this could be the HTTP identifier of the page from which the usage analytics event originates.
	     *
	     * Default value is the empty string.
	     *
	     * **Note:**
	     * > External code **can** modify the value of this attribute.
	     */
	    originLevel3: string;
	    /**
	     * The language of the search interface from which the usage analytics event originates.
	     *
	     * By default, the framework populates this attribute with the currently loaded localization and culture file of the
	     * search interface from which the usage analytics event originates.
	     *
	     * **Note:**
	     * > External code **can** modify the value of this attribute.
	     */
	    language: string;
	}
	/**
	 * The `AnalyticsEvents` static class contains the string definitions of all events that strongly relate to usage
	 * analytics.
	 *
	 * See [Events](https://docs.coveo.com/en/417/).
	 */
	class AnalyticsEvents {
	    static searchEvent: string;
	    /**
	     * Triggered when a `click` analytics event is logged (e.g., when the end user clicks a
	     * [`ResultLink`]{@link ResultLink} or [`Quickview`]{@link Quickview} to open a query result item).
	     *
	     * All `documentViewEvent` event handlers receive an
	     * [`AnalyticsDocumentViewEventArgs`]{@link IAnalyticsDocumentViewEventArgs} object as an argument.
	     *
	     * @type {string} The string value is `documentViewEvent`.
	     */
	    static documentViewEvent: string;
	    static customEvent: string;
	    /**
	     * Triggered when any event (i.e., `search`, `click`, or `custom`) is about to be logged.
	     *
	     * All `analyticsEventReady` event handlers receive an [`AnalyticsEventArgs`]{@link IAnalyticsEventArgs} object as an argument.
	     */
	    static analyticsEventReady: string;
	    /**
	     * Triggered whevoid an analytics event is about to be logged.
	     *
	     * This event allows external code to modify the analytics data before it is sent to the Coveo Usage Analytics REST
	     * service.
	     *
	     * All `changeAnalyticsCustomData` event handlers receive a
	     * [`ChangeAnalyticsCustomDataEventArgs`]{@link IChangeAnalyticsCustomDataEventArgs} object as an argument.
	     *
	     * @type {string} The string value is `changeAnalyticsCustomData`.
	     */
	    static changeAnalyticsCustomData: string;
	}

}
declare module Coveo {
	/**
	 * The `IQuickviewLoadedEventArgs` interface describes the object that all
	 * [`quickviewLoaded`]{@link QuickviewEvents.quickviewLoaded} event handlers receive as an argument.
	 */
	interface IQuickviewLoadedEventArgs {
	    /**
	     * The amount of time it took to download the content to display in the quickview modal window (in milliseconds).
	     */
	    duration: number;
	}
	/**
	 * The `QuickviewEvents` static class contains the string definitions of all events that strongly relate to the
	 * [`Quickview`]{@link Quickview} component.
	 */
	class QuickviewEvents {
	    /**
	     * Triggered by the [`QuickviewDocument`]{@link QuickviewDocument} component when the content to display in the
	     * quickview modal window has just finished downloading.
	     *
	     * The [`Quickview`]{@link Quickview} component listens to this event to know when to remove its loading animation.
	     *
	     * All `quickviewLoaded` event handlers receive a [`QuickviewLoadedEventArgs`]{@link IQuickviewLoadedEventArgs} object
	     * as an argument.
	     *
	     * @type {string} The string value is `quickviewLoaded`.
	     */
	    static quickviewLoaded: string;
	    /**
	     * Triggered by the [`QuickviewDocument`]{@link QuickviewDocument} component when the end user has just clicked the
	     * **Quickview** button/link to open the quickview modal window.
	     *
	     * This event allows external code to modify the terms to highlight before the content of the quickview modal window
	     * is rendered.
	     *
	     * All `openQuickview` event handlers receive an
	     * [`OpenQuickviewEventArgs`]{@link ResultListEvents.IOpenQuickviewEventArgs} object as an argument.
	     *
	     * @type {string} The string value is `openQuickview`.
	     */
	    static openQuickview: string;
	}

}
declare module Coveo {
	interface IResponsiveComponentOptions {
	    enableResponsiveMode?: boolean;
	    responsiveBreakpoint?: number;
	    dropdownHeaderLabel?: string;
	    initializationEventRoot?: Dom;
	}
	interface IResponsiveComponentConstructor {
	    new (root: Dom, ID: string, options: IResponsiveComponentOptions): IResponsiveComponent;
	}
	interface IResponsiveComponent {
	    ID: string;
	    handleResizeEvent(): void;
	    needDropdownWrapper?(): boolean;
	    registerComponent?(accept: Component): boolean;
	}
	class ResponsiveComponentsManager {
	    static DROPDOWN_HEADER_WRAPPER_CSS_CLASS: string;
	    resizeListener: any;
	    static register(responsiveComponentConstructor: IResponsiveComponentConstructor, root: Dom, ID: string, component: Component, options: IResponsiveComponentOptions): void;
	    static resizeAllComponentsManager(): void;
	    constructor(root: Dom);
	    register(responsiveComponentConstructor: IResponsiveComponentConstructor, root: Dom, ID: string, component: Component, options: IResponsiveComponentOptions): void;
	    disableComponent(ID: string): void;
	}

}
declare module Coveo {
	interface IResponsiveDropdownContent {
	    element: Dom;
	    positionDropdown(): void;
	    hideDropdown(): void;
	    cleanUp(): void;
	}
	class ResponsiveDropdownContent implements IResponsiveDropdownContent {
	    element: Dom;
	    static DEFAULT_CSS_CLASS_NAME: string;
	    static isTargetInsideOpenedDropdown(target: Dom): boolean;
	    constructor(componentName: string, element: Dom, coveoRoot: Dom, minWidth: number, widthRatio: number);
	    positionDropdown(): void;
	    hideDropdown(): void;
	    cleanUp(): void;
	}

}
declare module Coveo {
	class ResponsiveComponentsUtils {
	    static shouldDrawFacetSlider(root: Dom, facetSliderElement: Dom): boolean;
	    static isSmallTabsActivated(root: Dom): boolean;
	    static isSmallFacetActivated(root: Dom): boolean;
	    static isSmallRecommendationActivated(root: Dom): boolean;
	    static activateSmallTabs(root: Dom): void;
	    static deactivateSmallTabs(root: Dom): void;
	    static activateSmallFacet(root: Dom): void;
	    static deactivateSmallFacet(root: Dom): void;
	    static activateSmallRecommendation(root: Dom): void;
	    static deactivateSmallRecommendation(root: Dom): void;
	}

}
declare module Coveo {
	class RecommendationDropdownContent implements IResponsiveDropdownContent {
	    element: Dom;
	    static OPENED_DROPDOWN_CSS_CLASS_NAME: string;
	    constructor(componentName: string, element: Dom, coveoRoot: Dom);
	    positionDropdown(): void;
	    hideDropdown(): void;
	    cleanUp(): void;
	}

}
declare module Coveo {
	class ResponsiveDropdownHeader {
	    element: Dom;
	    static DEFAULT_CSS_CLASS_NAME: string;
	    static ACTIVE_HEADER_CSS_CLASS_NAME: string;
	    constructor(componentName: string, element: Dom);
	    open(): void;
	    close(): void;
	    cleanUp(): void;
	    hide(): void;
	    show(): void;
	}

}
declare module Coveo {
	class EventsUtils {
	    static addPrefixedEvent(element: HTMLElement, pascalCaseEventName: string, callback: any): void;
	    static removePrefixedEvent(element: HTMLElement, pascalCaseEventName: string, callback: any): void;
	}

}
declare module Coveo {
	enum ResponsiveDropdownEvent {
	    OPEN,
	    CLOSE,
	}
	class ResponsiveDropdown {
	    dropdownContent: IResponsiveDropdownContent;
	    dropdownHeader: ResponsiveDropdownHeader;
	    coveoRoot: Dom;
	    static TRANSPARENT_BACKGROUND_OPACITY: string;
	    static DROPDOWN_BACKGROUND_CSS_CLASS_NAME: string;
	    static DROPDOWN_BACKGROUND_ACTIVE_CSS_CLASS_NAME: string;
	    isOpened: boolean;
	    constructor(dropdownContent: IResponsiveDropdownContent, dropdownHeader: ResponsiveDropdownHeader, coveoRoot: Dom);
	    registerOnOpenHandler(handler: Function, context: any): void;
	    registerOnCloseHandler(handler: Function, context: any): void;
	    cleanUp(): void;
	    open(): void;
	    close(): void;
	    disablePopupBackground(): void;
	    enableScrollLocking(scrollableContainer: HTMLElement): void;
	}

}
declare module Coveo {
	class ResponsiveRecommendation implements IResponsiveComponent {
	    coveoRoot: Dom;
	    ID: string;
	    responsiveDropdown: ResponsiveDropdown;
	    static DROPDOWN_CONTAINER_CSS_CLASS_NAME: string;
	    static RESPONSIVE_BREAKPOINT: number;
	    recommendationRoot: Dom;
	    static init(root: HTMLElement, component: any, options: IResponsiveComponentOptions): void;
	    constructor(coveoRoot: Dom, ID: string, options: IResponsiveComponentOptions, responsiveDropdown?: ResponsiveDropdown);
	    handleResizeEvent(): void;
	    needDropdownWrapper(): boolean;
	}

}
declare module Coveo {
	class DefaultRecommendationTemplate extends Template {
	    instantiateToString(object?: IQueryResult): string;
	    instantiateToElement(object?: IQueryResult): Promise<HTMLElement>;
	}

}
declare module Coveo {
	interface IRecommendationQueryOptions {
	}
	class RecommendationQuery extends Component {
	    element: HTMLElement;
	    options: IRecommendationQueryOptions;
	    static ID: string;
	    /**
	     * The options for the RecommendationQuery component
	     * @componentOptions
	     */
	    static options: IRecommendationQueryOptions;
	    constructor(element: HTMLElement, options?: IRecommendationQueryOptions, bindings?: IComponentBindings);
	}

}
declare module Coveo {
	class APIAnalyticsBuilder {
	    static convertSearchEventToAPI(searchEvent: ISearchEvent): IAPISearchEvent;
	    static convertDocumentViewToAPI(documentView: IClickEvent): IAPIDocumentViewEvent;
	    static convertCustomEventToAPI(customEvent: ICustomEvent): IAPICustomEvent;
	}

}
declare module Coveo {
	class LocalStorageUtils<T> {
	    id: string;
	    constructor(id: string);
	    save(data: T): void;
	    load(): T;
	    remove(key?: string): void;
	}
	class SafeLocalStorage implements Storage {
	    [key: string]: any;
	    getItem(key: string): string;
	    removeItem(key: string): void;
	    setItem(key: string, value: string): void;
	    clear(): void;
	    key(index: number): string;
	     length: number;
	}

}
declare module Coveo {
	class RootComponent extends BaseComponent {
	    element: HTMLElement;
	    type: string;
	    constructor(element: HTMLElement, type: string);
	}

}
declare module Coveo {
	interface IHistoryManager {
	    setState(state: any): void;
	    replaceState(state: any): void;
	}

}
declare module Coveo {
	/**
	 * This component acts like the {@link HistoryController} excepts that is saves the {@link QueryStateModel} in the local storage.<br/>
	 * This will not allow 'back' and 'forward' navigation in the history, like the standard {@link HistoryController} allows. Instead, it load the query state only on page load.<br/>
	 * To enable this component, you should set the {@link SearchInterface.options.useLocalStorageForHistory} as well as the {@link SearchInterface.options.enableHistory} options to true.
	 */
	class LocalStorageHistoryController extends RootComponent implements IHistoryManager {
	    windoh: Window;
	    model: Model;
	    queryController: QueryController;
	    static ID: string;
	    storage: LocalStorageUtils<{
	        [key: string]: any;
	    }>;
	    /**
	     * Create a new LocalStorageHistoryController instance
	     * @param element
	     * @param windoh For mock purpose
	     * @param model
	     * @param queryController
	     */
	    constructor(element: HTMLElement, windoh: Window, model: Model, queryController: QueryController);
	    replaceState(state: any): void;
	    /**
	     * Specifies an array of attributes from the query state model that should not be persisted in the local storage
	     * @param attributes
	     */
	    withoutThoseAttribute(attributes: string[]): void;
	    setState(values: any): void;
	}

}
declare module Coveo {
	class LiveAnalyticsClient implements IAnalyticsClient {
	    endpoint: AnalyticsEndpoint;
	    rootElement: HTMLElement;
	    userId: string;
	    userDisplayName: string;
	    anonymous: boolean;
	    splitTestRunName: string;
	    splitTestRunVersion: string;
	    originLevel1: string;
	    sendToCloud: boolean;
	    bindings: IComponentBindings;
	    isContextual: boolean;
	    originContext: string;
	    constructor(endpoint: AnalyticsEndpoint, rootElement: HTMLElement, userId: string, userDisplayName: string, anonymous: boolean, splitTestRunName: string, splitTestRunVersion: string, originLevel1: string, sendToCloud: boolean, bindings: IComponentBindings);
	    isActivated(): boolean;
	    getCurrentVisitId(): string;
	    getCurrentVisitIdPromise(): Promise<string>;
	    getCurrentEventCause(): string;
	    getCurrentEventMeta(): {
	        [key: string]: any;
	    };
	    logSearchEvent<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta): void;
	    logSearchAsYouType<TMeta>(actionCause: IAnalyticsActionCause, meta?: TMeta): void;
	    logClickEvent<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta, result: IQueryResult, element: HTMLElement): Promise<IAPIAnalyticsEventResponse>;
	    logCustomEvent<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta, element: HTMLElement, result?: IQueryResult): Promise<IAPIAnalyticsEventResponse>;
	    getTopQueries(params: ITopQueries): Promise<string[]>;
	    sendAllPendingEvents(): void;
	    cancelAllPendingEvents(): void;
	    getPendingSearchEvent(): PendingSearchEvent;
	    warnAboutSearchEvent(): void;
	    setOriginContext(originContext: string): void;
	    getOriginContext(): string;
	    getUserDisplayName(): string;
	    protected getOriginLevel2(element: HTMLElement): string;
	}

}
declare module Coveo {
	class RecommendationAnalyticsClient extends LiveAnalyticsClient {
	    endpoint: AnalyticsEndpoint;
	    rootElement: HTMLElement;
	    userId: string;
	    userDisplayName: string;
	    anonymous: boolean;
	    splitTestRunName: string;
	    splitTestRunVersion: string;
	    originLevel1: string;
	    sendToCloud: boolean;
	    bindings: IComponentBindings;
	    constructor(endpoint: AnalyticsEndpoint, rootElement: HTMLElement, userId: string, userDisplayName: string, anonymous: boolean, splitTestRunName: string, splitTestRunVersion: string, originLevel1: string, sendToCloud: boolean, bindings: IComponentBindings);
	    logSearchEvent<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta): void;
	    logClickEvent<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta, result: IQueryResult, element: HTMLElement): Promise<IAPIAnalyticsEventResponse>;
	    protected getOriginLevel2(element: HTMLElement): string;
	}

}
declare module Coveo {
	/// <reference types="coveoanalytics" />
	interface IRecommendationOptions extends ISearchInterfaceOptions {
	    mainSearchInterface?: HTMLElement;
	    userContext?: IStringMap<any>;
	    id?: string;
	    optionsToUse?: string[];
	    sendActionsHistory?: boolean;
	    hideIfNoResults?: boolean;
	    enableResponsiveMode?: boolean;
	    responsiveBreakpoint?: number;
	    dropdownHeaderLabel?: string;
	}
	/**
	 * The Recommendation component is a {@link SearchInterface} that displays recommendations typically based on user
	 * history.
	 *
	 * This component usually listens to the main SearchInterface. When the main SearchInterface generates a query, the
	 * Recommendation component generates another query to get the recommendations at the same time.
	 *
	 * To get history-based recommendations, you will likely want to include the `pageview` script in your page (see
	 * [coveo.analytics.js](https://github.com/coveo/coveo.analytics.js)). However, including this script is not mandatory.
	 * For instance, you could use the Recommendation component without the Coveo Machine Learning service to create a
	 * simple "recommended people" interface.
	 *
	 * It is possible to include this component inside another SearchInterface, but it is also possible to instantiate it as
	 * a "standalone" search interface, without even instantiating a main SearchInterface component. In any case, a
	 * Recommendation component always acts as a full-fledged search interface. Therefore, you can include any component
	 * inside the Recommendation component (Searchbox, Facet, Sort, etc.), just as you would inside the main SearchInterface
	 * component.
	 *
	 * @availablesince [July 2016 Release (v1.667.24)](https://docs.coveo.com/en/309/#july-2016-release-v166724)
	 */
	class Recommendation extends SearchInterface implements IComponentBindings {
	    element: HTMLElement;
	    options: IRecommendationOptions;
	    analyticsOptions: {};
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the recommendation component
	     * @componentOptions
	     */
	    static options: IRecommendationOptions;
	    mainQuerySearchUID: string;
	    mainQueryPipeline: string;
	    /**
	     * Creates a new Recommendation component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the Recommendation component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time)
	     * @param _window
	     */
	    constructor(element: HTMLElement, options?: IRecommendationOptions, analyticsOptions?: {}, _window?: Window);
	     historyStore: CoveoAnalytics.HistoryStore;
	    getId(): string;
	    enable(): void;
	    disable(): void;
	    hide(): void;
	    show(): void;
	}

}
declare module Coveo {
	/**
	 * Set of utilities to determine where to load the lazy chunks from.
	 * You should add the `coveo-script` class on the script tag that includes the Coveo framework to make sure the framework can always
	 * auto-detect the path to load the lazy chunks from. More details [here]{@link https://docs.coveo.com/en/295/javascript-search-framework/lazy-versus-eager-component-loading#fixing-code-chunks-loading-path-issues}
	 */
	class PublicPathUtils {
	    static detectPublicPath(): void;
	    /**
	     * Helper function to resolve the public path used to load the chunks relative to the Coveo script.
	     * You should add the `coveo-script` class on the script tag that includes the Coveo framework
	     * to make sure the framework can always auto-detect the path to load the lazy chunks from.
	     * More details [here]{@link https://docs.coveo.com/en/295/javascript-search-framework/lazy-versus-eager-component-loading#fixing-code-chunks-loading-path-issues}
	     */
	    static getDynamicPublicPath(): string;
	    /**
	     * @deprecated Instead of using this method, you should add the `coveo-script` class on the script tag that includes the Coveo framework.
	     * @param path
	     */
	    static configureResourceRoot(path: string): void;
	    static reset(): void;
	    static getCurrentScript(): HTMLScriptElement;
	    static getCoveoScript(): Element;
	}

}
declare module Coveo {
	class NoopAnalyticsClient implements IAnalyticsClient {
	    isContextual: boolean;
	    endpoint: any;
	    isActivated(): boolean;
	    getCurrentEventCause(): string;
	    getCurrentEventMeta(): IStringMap<any>;
	    logSearchEvent<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta): void;
	    logSearchAsYouType<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta): void;
	    logClickEvent<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta, result?: IQueryResult, element?: HTMLElement): Promise<IAPIAnalyticsEventResponse>;
	    logCustomEvent<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta, element?: HTMLElement): Promise<IAPIAnalyticsEventResponse>;
	    getTopQueries(params: ITopQueries): Promise<string[]>;
	    getCurrentVisitIdPromise(): Promise<string>;
	    getCurrentVisitId(): string;
	    sendAllPendingEvents(): void;
	    cancelAllPendingEvents(): void;
	    warnAboutSearchEvent(): void;
	    getPendingSearchEvent(): any;
	    setOriginContext(originContext: string): void;
	    getOriginContext(): string;
	    getUserDisplayName(): string;
	}

}
declare module Coveo {
	class MultiAnalyticsClient implements IAnalyticsClient {
	    isContextual: boolean;
	    endpoint: AnalyticsEndpoint;
	    constructor(analyticsClients?: IAnalyticsClient[]);
	    isActivated(): boolean;
	    getCurrentEventCause(): string;
	    getCurrentEventMeta(): {
	        [key: string]: any;
	    };
	    logSearchEvent<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta): void;
	    logSearchAsYouType<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta): void;
	    logClickEvent<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta, result: IQueryResult, element: HTMLElement): Promise<IAPIAnalyticsEventResponse>;
	    logCustomEvent<TMeta>(actionCause: IAnalyticsActionCause, meta?: TMeta, element?: HTMLElement): Promise<IAPIAnalyticsEventResponse>;
	    getTopQueries(params: ITopQueries): Promise<string[]>;
	    getCurrentVisitIdPromise(): Promise<string>;
	    getCurrentVisitId(): string;
	    sendAllPendingEvents(): void;
	    warnAboutSearchEvent(): void;
	    cancelAllPendingEvents(): void;
	    getPendingSearchEvent(): PendingSearchEvent;
	    setOriginContext(originContext: string): void;
	    getOriginContext(): string;
	    getUserDisplayName(): string;
	}

}
declare module Coveo {
	interface IAnalyticsOptions {
	    user?: string;
	    userDisplayName?: string;
	    token?: string;
	    endpoint?: string;
	    anonymous?: boolean;
	    searchHub?: string;
	    splitTestRunName?: string;
	    splitTestRunVersion?: string;
	    sendToCloud?: boolean;
	    organization?: string;
	    autoPushToGtmDataLayer?: boolean;
	    gtmDataLayerName?: string;
	    renewAccessToken?: () => Promise<string>;
	}
	/**
	 * The `Analytics` component can log user actions performed in the search interface and send them to a REST web service
	 * exposed through the Coveo Cloud Platform.
	 *
	 * You can use analytics data to evaluate how users are interacting with your search interface, improve relevance and
	 * produce analytics dashboards within the Coveo Cloud Platform.
	 *
	 * See [JavaScript Search Framework Usage Analytics](https://docs.coveo.com/en/365) for an introduction.
	 *
	 * See also [Logging Your Own Search Events](https://docs.coveo.com/en/2726/#logging-your-own-search-events) for more advanced use cases.
	 */
	class Analytics extends Component {
	    element: HTMLElement;
	    options: IAnalyticsOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    static doExport(): void;
	    /**
	     * Options for the component
	     * @componentOptions
	     */
	    static options: IAnalyticsOptions;
	    /**
	     * A reference to the `AnalyticsClient`, which performs the heavy duty part of sending the usage analytics events to
	     * the Coveo Usage Analytics service.
	     */
	    client: IAnalyticsClient;
	    /**
	     * Creates a new `Analytics` component. Creates the [`AnalyticsClient`]{@link IAnalyticsClient}.
	     * @param element The HTMLElement on which the component will be instantiated.
	     * @param options The options for the `Analytics` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IAnalyticsOptions, bindings?: IComponentBindings);
	    /**
	     * Logs a `Search` usage analytics event.
	     *
	     * A `Search` event is actually sent to the Coveo Usage Analytics service only after the query successfully returns
	     * (not immediately after calling this method). Therefore, it is 
	     * the query. Otherwise, the `Search` event will not be logged, and you will get a warning message in the console.
	     *
	     * **Note:**
	     *
	     * > When logging custom `Search` events, you should use the `Coveo.logSearchEvent` top-level function rather than
	     * > calling this method directly from the `Analytics` component instance. See
	     * > [Logging Your Own Search Events](https://docs.coveo.com/en/2726/#logging-your-own-search-events).
	     *
	     * @param actionCause The cause of the event.
	     * @param meta The metadata you want to use to create custom dimensions. Metadata can contain as many key-value
	     * pairs as you need. Each key must contain only alphanumeric characters and underscores. The Coveo Usage Analytics
	     * service automatically converts white spaces to underscores, and uppercase characters to lowercase characters in key
	     * names. Each value must be a simple string. If you do not need to log metadata, you can simply pass an empty JSON
	     * ( `{}` ).
	     */
	    logSearchEvent<T>(actionCause: IAnalyticsActionCause, meta: T): void;
	    /**
	     * Logs a `SearchAsYouType` usage analytics event.
	     *
	     * This method is very similar to the [`logSearchEvent`]{@link Analytics.logSearchEvent} method, except that
	     * `logSearchAsYouType` should, by definition, be called more frequently. Consequently, in order to avoid logging
	     * every single partial query, the `PendingSearchAsYouTypeEvent` takes care of logging only the "relevant" last event:
	     * an event that occurs after 5 seconds have elapsed without any event being logged, or an event that occurs after
	     * another part of the interface triggers a search event.
	     *
	     * It is 
	     * logged, and you will get a warning message in the console.
	     *
	     * **Note:**
	     *
	     * > When logging custom `SearchAsYouType` events, you should use the `Coveo.logSearchAsYouTypeEvent` top-level
	     * > function rather than calling this method directly from the `Analytics` component instance. See
	     * > [Logging Your Own Search Events](https://docs.coveo.com/en/2726/#logging-your-own-search-events).
	     *
	     * @param actionCause The cause of the event.
	     * @param meta The metadata which you want to use to create custom dimensions. Metadata can contain as many key-value
	     * pairs as you need. Each key must contain only alphanumeric characters and underscores. The Coveo Usage Analytics
	     * service automatically converts white spaces to underscores and uppercase characters to lowercase characters in key
	     * names. Each value must be a simple string. If you do not need to log metadata, you can simply pass an empty JSON
	     * ( `{}` ).
	     */
	    logSearchAsYouType<T>(actionCause: IAnalyticsActionCause, meta: T): void;
	    /**
	     * Logs a `Custom` usage analytics event on the service.
	     *
	     * You can use `Custom` events to create custom reports, or to track events which are neither queries (see
	     * [`logSearchEvent`]{@link Analytics.logSearchEvent} and
	     * [`logSearchAsYouType`]{@link Analytics.logSearchAsYouType}), nor item views (see
	     * [`logClickEvent`]{@link Analytics.logClickEvent}).
	     *
	     * **Note:**
	     * > When logging `Custom` events, you should use the `Coveo.logClickEvent` top-level function rather than calling
	     * > this method directly from the `Analytics` component instance. See
	     * > [Logging Your Own Custom Events](https://docs.coveo.com/en/2726/#logging-your-own-custom-events).
	     *
	     * @param actionCause The cause of the event.
	     * @param meta The metadata which you want to use to create custom dimensions. Metadata can contain as many key-value
	     * pairs as you need. Each key must contain only alphanumeric characters and underscores. The Coveo Usage Analytics
	     * service automatically converts white spaces to underscores and uppercase characters to lowercase characters in key
	     * names. Each value must be a simple string. If you do not need to log metadata, you can simply pass an empty JSON
	     * ( `{}` ).
	     * @param element The HTMLElement that the user has interacted with for this custom event. Default value is the
	     * element on which the `Analytics` component is bound.
	     * @param result The IQueryResult that the custom event is linked to, if any.
	     */
	    logCustomEvent<T>(actionCause: IAnalyticsActionCause, meta: T, element?: HTMLElement, result?: IQueryResult): void;
	    /**
	     * Logs a `Click` usage analytics event.
	     *
	     * A `Click` event corresponds to an item view (e.g., clicking on a {@link ResultLink} or opening a
	     * {@link Quickview}).
	     *
	     * `Click` events are immediately sent to the Coveo Usage Analytics service.
	     *
	     * **Note:**
	     * > When logging custom `Click` events, you should use the `Coveo.logClickEvent` top-level function rather than
	     * > calling this method directly from the `Analytics` component instance. See
	     * > [Logging Your Own Click Events](https://docs.coveo.com/en/2726/#logging-your-own-click-events).
	     *
	     * @param actionCause The cause of the event.
	     * @param meta The metadata which you want to use to create custom dimensions. Metadata can contain as many key-value
	     * pairs as you need. Each key must contain only alphanumeric characters and underscores. The Coveo Usage Analytics
	     * service automatically converts uppercase characters to lowercase characters in key names. Each value must be a
	     * simple string. You do not have to pass an {@link IAnalyticsDocumentViewMeta} as meta when logging a `Click` event.
	     * You can actually send any arbitrary meta. If you do not need to log metadata, you can simply pass an empty JSON
	     * ( `{}` ).
	     * @param result The result that was clicked.
	     * @param element The HTMLElement that the user has clicked in the interface. Default value is the element on which
	     * the `Analytics` component is bound.
	     */
	    logClickEvent(actionCause: IAnalyticsActionCause, meta: IAnalyticsDocumentViewMeta, result: IQueryResult, element?: HTMLElement): void;
	    /**
	     * Sets the Origin Context dimension on the analytic events.
	     *
	     * You can use this dimension to specify the context of your application.
	     * Suggested values are "Search", "InternalSearch" and "CommunitySearch"
	     *
	     * Default value is `Search`.
	     *
	     * @param originContext The origin context value
	     */
	    setOriginContext(originContext: string): void;
	    /**
	     * Get the Origin Context dimension on the analytic events.
	     *
	     */
	    getOriginContext(): string;
	    /**
	     * Get the Origin Context dimension on the analytic events.
	     *
	     */
	    getUserDisplayName(): string;
	    /**
	     * Re-enables the component if it was previously disabled.
	     */
	    enable(): void;
	    /**
	     * Removes all session information stored in the browser (e.g., analytics visitor cookies, action history, etc.)
	     *
	     * @availablesince [October 2019 Release (v2.7219)](https://docs.coveo.com/en/3084/)
	     */
	    clearLocalData(): void;
	    /**
	     * Disables the component and clears local data by running [`clearLocalData`]{@link Analytics.clearLocalData}.
	     */
	    disable(): void;
	    /**
	     * Attempts to push data representing a single Coveo usage analytics event to the Google Tag Manager data layer.
	     *
	     * **Note:**
	     * If the [`autoPushToGtmDataLayer`]{@link Analytics.options.autoPushToGtmDataLayer} option is set to `true` and the GTM data layer has been properly initialized in the page, this method is called automatically whevoid an event is about to be logged to the Coveo Cloud usage analytics service.
	     *
	     * See also the [`gtmDataLayerName`]{@link Analytics.options.gtmDataLayerName} option.
	     *
	     * @param data The data to push.
	     */
	    pushToGtmDataLayer(data: IAnalyticsEventArgs): void;
	    protected initializeAnalyticsEndpoint(): AnalyticsEndpoint;
	    static create(element: HTMLElement, options: IAnalyticsOptions, bindings: IComponentBindings): IAnalyticsClient;
	}

}
declare module Coveo {
	class AnalyticsUtils {
	    static addActionCauseToList(newActionCause: IAnalyticsActionCause): void;
	    static removeActionCauseFromList(actionCauseToRemoveName: string): void;
	}

}
declare module Coveo {
	/**
	 * Initialize the framework with a basic search interface. Calls {@link Initialization.initSearchInterface}.
	 *
	 * If using the jQuery extension, this is called using <code>$('#root').coveo('init');</code>.
	 * @param element The root of the interface to initialize.
	 * @param options JSON options for the framework (e.g.: <code>{Searchbox : {enableSearchAsYouType : true}}</code>).
	 * @returns {Promise<{elem: HTMLElement}>}
	 */
	function init(element: HTMLElement, options?: any): Promise<{
	    elem: HTMLElement;
	}>;
	/**
	 * Initialize the framework with a standalone search box. Calls {@link Initialize.initStandaloneSearchInterface}.
	 *
	 * If using the jQuery extension, this is called using <code>$('#root').coveo('initSearchbox');</code>.
	 * @param element The root of the interface to initialize.
	 * @param searchPageUri The search page on which to redirect when there is a query.
	 * @param options JSON options for the framework (e.g.: <code>{Searchbox : {enableSearchAsYouType : true}}</code>).
	 * @returns {Promise<{elem: HTMLElement}>}
	 */
	function initSearchbox(element: HTMLElement, searchPageUri: string, options?: any): Promise<{
	    elem: HTMLElement;
	}>;
	/**
	 * Initialize the framework with a recommendation interface. Calls {@link Initialization.initRecommendationInterface}.
	 *
	 * If using the jQuery extension, this is called using <code>$('#root').coveo('initRecommendation');</code>.
	 * @param element The root of the interface to initialize.
	 * @param mainSearchInterface The search interface to link with the recommendation interface (see {@link Recommendation}).
	 * @param userContext The user context to pass with the query generated in the recommendation interface (see {@link Recommendation}).
	 * @param options JSON options for the framework (e.g.: <code>{Searchbox : {enableSearchAsYouType: true}}</code>).
	 * @returns {Promise<{elem: HTMLElement}>}
	 */
	function initRecommendation(element: HTMLElement, mainSearchInterface?: HTMLElement, userContext?: {
	    [name: string]: any;
	}, options?: any): Promise<{
	    elem: HTMLElement;
	}>;
	/**
	 * Execute a standard query. Active component in the interface will react to events/ push data in the query / handle the query success or failure as needed.
	 *
	 * It triggers a standard query flow for which the standard component will perform their expected behavior.
	 *
	 * If you wish to only perform a query on the index to retrieve results (without the component reacting), look into {@link SearchInterface} instead.
	 *
	 * Calling this method is the same as calling {@link QueryController.executeQuery}.
	 *
	 * @param element The root of the interface to initialize.
	 * @returns {Promise<IQueryResults>}
	 */
	function executeQuery(element: HTMLElement): Promise<IQueryResults>;
	/**
	 * Performs read and write operations on the [`QueryStateModel`]{@link QueryStateModel} instance of the search
	 * interface. See [State](https://docs.coveo.com/en/344/).
	 *
	 * Can perform the following actions:
	 *
	 * - Get the `QueryStateModel` instance:
	 * ```javascript
	 * Coveo.state(element);
	 * ```
	 *
	 * - Get the value of a single state attribute from the `QueryStateModel` instance:
	 * ```javascript
	 * // You can replace `q` with any registered state attribute.
	 * Coveo.state(element, "q");
	 * ```
	 *
	 * - Set the value of a single state attribute in the `QueryStateModel` instance:
	 * ```javascript
	 * // You can replace `q` with any registered state attribute.
	 * Coveo.state(element, "q", "my new value");
	 * ```
	 *
	 * - Set multiple state attribute values in the `QueryStateModel` instance:
	 * ```javascript
	 * // You can replace `q` and `sort` with any registered state attributes.
	 * Coveo.state(element, {
	 *     "q" : "my new value",
	 *     "sort" : "relevancy"
	 * });
	 * ```
	 *
	 * **Note:**
	 * > When setting one or several state attribute values with this function, you can pass an additional argument to set
	 * > the `silent` attribute to `true` in order to prevent the state change from triggering state change events.
	 * >
	 * > **Example:**
	 * > ```javascript
	 * > Coveo.state(element, "q", "my new value", { "silent" : true });
	 * > ```
	 *
	 * @param element The root of the interface whose `QueryStateModel` instance the function should interact with.
	 * @param args The arguments that determine the action to perform on the `QueryStateModel` instance.
	 * @returns {any} Depends on the action performed.
	 */
	function state(element: HTMLElement, ...args: any[]): any;
	/**
	 * Get the component bound on the given `HTMLElement`.
	 * @param element The `HTMLElement` for which to get the component instance.
	 * @param componentClass If multiple components are bound to a single `HTMLElement`, you need to specify which components you wish to get.
	 * @param noThrow By default, the GET method will throw if there is no component bound, or if there are multiple component and no `componentClass` is specified. This deletes the error if set to true.
	 * @returns {Component}
	 */
	function get(element: HTMLElement, componentClass?: any, noThrow?: boolean): BaseComponent;
	function result(element: HTMLElement, noThrow?: boolean): IQueryResult;
	/**
	 * Finds the [`Analytics`]{@link Analytics} component instance, and uses it to log a `Custom` usage analytics event.
	 *
	 * You can use `Custom` events to create custom reports, or to track events which are neither queries nor item
	 * views.
	 *
	 * @param element The root of the search interface which contains the [`Analytics`]{@link Analytics} component.
	 * @param customEventCause The cause of the event.
	 * @param metadata The metadata you want to use to create custom dimensions. Metadata can contain as many key-value
	 * pairs as you need. Each key must contain only alphanumeric characters and underscores. The Coveo Usage Analytics
	 * service automatically converts white spaces to underscores, and uppercase characters to lowercase characters in key
	 * names. Each value must be a simple string. If you do not need to log metadata, you can simply pass an empty JSON
	 * ( `{}` ).
	 * @param result The query result that relates to the custom event, if applicable.
	 */
	function logCustomEvent<TMeta extends IStringMap<any>>(element: HTMLElement, customEventCause: IAnalyticsActionCause, metadata: TMeta, result?: IQueryResult): void;
	/**
	 * Finds the [`Analytics`]{@link Analytics} component instance, and uses it to log a `Search` usage analytics event.
	 *
	 * A `Search` event is actually sent to the Coveo Usage Analytics service only after the query successfully returns (not
	 * immediately after calling this method). Therefore, it is 
	 * query. Otherwise, the `Search` event will not be logged, and you will get a warning message in the console. See
	 * [Logging Your Own Search Events](https://docs.coveo.com/en/2726/#logging-your-own-search-events).
	 *
	 * @param element The root of the search interface which contains the [`Analytics`]{@link Analytics} component.
	 * @param searchEventCause The cause of the event.
	 * @param metadata The metadata you want to use to create custom dimensions. Metadata can contain as many key-value
	 * pairs as you need. Each key must contain only alphanumeric characters and underscores. The Coveo Usage Analytics
	 * service automatically converts white spaces to underscores, and uppercase characters to lowercase characters in key
	 * names. Each value must be a simple string. If you do not need to log metadata, you can simply pass an empty JSON
	 * ( `{}` ).
	 */
	function logSearchEvent(element: HTMLElement, searchEventCause: IAnalyticsActionCause, metadata: IStringMap<string>): void;
	/**
	 * Finds the [`Analytics`]{@link Analytics} component instance, and uses it to log a `SearchAsYouType` usage analytics
	 * event.
	 *
	 * This function is very similar to the `logSearchEvent` function, except that `logSearchAsYouTypeEvent` should, by
	 * definition, be called more frequently. Consequently, in order to avoid logging every single partial query, the
	 * `PendingSearchAsYouTypeEvent` takes care of logging only the "relevant" last event: an event that occurs after 5
	 * seconds have elapsed without any event being logged, or an event that occurs after another part of the interface
	 * triggers a search event.
	 *
	 * It is 
	 * logged, and you will get a warning message in the console. See
	 * [Logging Your Own Search Events](https://docs.coveo.com/en/2726/#logging-your-own-search-events).
	 *
	 * @param element The root of the search interface which contains the [`Analytics`]{@link Analytics} component.
	 * @param searchAsYouTypeEventCause The cause of the event.
	 * @param metadata The metadata you want to use to create custom dimensions. Metadata can contain as many key-value
	 * pairs as you need. Each key must contain only alphanumeric characters and underscores. The Coveo Usage Analytics
	 * service automatically converts white spaces to underscores, and uppercase characters to lowercase characters in key
	 * names. Each value must be a simple string. If you do not need to log metadata, you can simply pass an empty JSON
	 * ( `{}` ).
	 */
	function logSearchAsYouTypeEvent<TMeta extends IStringMap<any>>(element: HTMLElement, searchAsYouTypeEventCause: IAnalyticsActionCause, metadata: TMeta): void;
	/**
	 * Finds the [`Analytics`]{@link Analytics} component instance, and uses it to log a `Click` usage analytics event.
	 *
	 * A `Click` event corresponds to an item view (e.g., clicking on a {@link ResultLink} or opening a {@link Quickview}).
	 *
	 * `Click` events are immediately sent to the Coveo Usage Analytics service.
	 *
	 * @param element The root of the search interface which contains the [`Analytics`]{@link Analytics} component.
	 * @param clickEventCause The cause of the event.
	 * @param metadata The metadata you want to use to create custom dimensions. Metadata can contain as many key-value
	 * pairs as you need. Each key must contain only alphanumeric characters and underscores. The Coveo Usage Analytics
	 * service automatically converts white spaces to underscores, and uppercase characters to lowercase characters in key
	 * names. Each value must be a simple string. If you do not need to log metadata, you can simply pass an empty JSON
	 * ( `{}` ).
	 * @param result The result that was clicked.
	 */
	function logClickEvent<TMeta extends IStringMap<any>>(element: HTMLElement, clickEventCause: IAnalyticsActionCause, metadata: TMeta, result: IQueryResult): void;
	/**
	 * Pass options to the framework, before it is initialized ({@link init}).<br/>
	 * All the options passed with this calls will be merged together on initialization.
	 * @param element The root of the interface for which you wish to set options.
	 * @param optionsToSet JSON options for the framework (e.g.: <code>{Searchbox : {enableSearchAsYouType: true}}</code>).
	 */
	function options(element: HTMLElement, optionsToSet?: any): void;
	/**
	 * Patch the given `methodName` on an instance of a component bound to an `HTMLElement` with a new handler.
	 * @param element
	 * @param methodName
	 * @param handler
	 */
	function patch(element: HTMLElement, methodName: string, handler: (...args: any[]) => any): void;
	function initBox(element: HTMLElement, ...args: any[]): void;
	function nuke(element: HTMLElement): void;
	/**
	 * Sets the path from where the chunks used for lazy loading will be loaded. In some cases, in IE11, we cannot automatically detect it, use this instead.
	 * @param path This should be the path of the Coveo script. It should also have a trailing slash.
	 */
	function configureResourceRoot(path: string): void;
	/**
	 * Re-enables an [`Analytics`]{@link Analytics} component if it was previously disabled.
	 * @param searchRoot
	 * The element to scan for an Analytics component.
	 * This can be an element onto which a component instance is bound
	 * (e.g., document.querySelector(".CoveoAnalytics"),
	 * or an ancestor of such an element (e.g., document.getElementById("search").
	 *
	 * @availablesince [October 2019 Release (v2.7219)](https://docs.coveo.com/en/3084/)
	 */
	function enableAnalytics(searchRoot?: HTMLElement): void;
	/**
	 * Removes all session information stored in the browser (e.g., analytics visitor cookies, action history, etc.)
	 * @param searchRoot
	 * The element to scan for an Analytics component.
	 * This can be an element onto which a component instance is bound
	 * (e.g., document.querySelector(".CoveoAnalytics"),
	 * or an ancestor of such an element (e.g., document.getElementById("search").
	 */
	function clearLocalData(searchRoot?: HTMLElement): void;
	/**
	 * Disables an [`Analytics`]{@link Analytics} component and clears local data.
	 * @param searchRoot
	 * The element to scan for an Analytics component.
	 * This can be an element onto which a component instance is bound
	 * (e.g., document.querySelector(".CoveoAnalytics"),
	 * or an ancestor of such an element (e.g., document.getElementById("search").
	 *
	 * @availablesince [October 2019 Release (v2.7219)](https://docs.coveo.com/en/3084/)
	 */
	function disableAnalytics(searchRoot?: HTMLElement): void;
	/**
	 * Adds a new analytics action cause to the ActionCauseList.
	 * Adding a new actionCause allows to specify a custom user-action when triggering a search event.
	 * @param newActionCause
	 * (e.g.,
	 * {
	 *  Name: "newActionCause",
	 *  Type: "exampleType"
	 * },
	 */
	function addActionCauseToList(newActionCause: IAnalyticsActionCause): void;
	/**
	 * Removes an actionCause from the ActionCauseList.
	 * @param actionCauseToRemoveName
	 */
	function removeActionCauseFromList(actionCauseToRemoveName: string): void;
	/**
	 * Asynchronously loads a module, or chunk.
	 *
	 * This is especially useful when you want to extend a base component, and make sure the lazy component loading process
	 * recognizes it (see [Lazy Versus Eager Component Loading](https://docs.coveo.com/en/295/)).
	 *
	 * **Example:**
	 *
	 * ```typescript
	 * function lazyCustomFacet() {
	 *   return Coveo.load<Facet>('Facet').then((Facet) => {
	 *     class CustomFacet extends Facet {
	 *       [ ... ]
	 *     };
	 *     Coveo.Initialization.registerAutoCreateComponent(CustomFacet);
	 *     return CustomFacet;
	 *   });
	 * };
	 *
	 * Coveo.LazyInitialization.registerLazyComponent('CustomFacet', lazyCustomFacet);
	 * ```
	 *
	 * You can also use this function to assert a component is fully loaded in your page before executing any code relating
	 * to it.
	 *
	 * **Example:**
	 *
	 * > You could do `Coveo.load('Searchbox').then((Searchbox) => {})` to load the [`Searchbox`]{@link Searchbox}
	 * > component, if it is not already loaded in your search page.
	 *
	 * @param id The identifier of the module you wish to load. In the case of components, this identifier is the component
	 * name (e.g., `Facet`, `Searchbox`).
	 * @returns {Promise} A Promise of the module, or chunk.
	 */
	function load<T>(id: string): Promise<T>;

}
declare module Coveo {
	interface IQuickViewHeaderOptions {
	    showDate: boolean;
	    title: string;
	}
	class DomUtils {
	    static getPopUpCloseButton(captionForClose: string, captionForReminder: string): string;
	    static getBasicLoadingAnimation(): HTMLDivElement;
	    static highlight(content: string, classToApply?: string, htmlEncode?: boolean): string;
	    static highlightElement(initialString: string, valueToSearch: string, classToApply?: string): string;
	    static getLoadingSpinner(): HTMLElement;
	    static getModalBoxHeader(title: string): Dom;
	    static getQuickviewHeader(result: IQueryResult, options: IQuickViewHeaderOptions, bindings: IComponentBindings): Dom;
	}

}
declare module Coveo {
	class EmailUtils {
	    static splitSemicolonSeparatedListOfEmailAddresses(addresses: string): string[];
	    static emailAddressesToHyperlinks(addresses: string[], companyDomain?: string, me?: string, lengthLimit?: number, truncateName?: boolean): string;
	    static buildEmailAddressesAndOthers(excessHyperLinks: string[]): string;
	    static parseEmail(email: string): string[];
	}

}
declare module Coveo {
	interface IStringHole {
	    begin: number;
	    size: number;
	    replacementSize: number;
	}
	class StringAndHoles {
	    value: string;
	    holes: IStringHole[];
	    static SHORTEN_END: string;
	    static WORD_SHORTER: number;
	    static replace(str: string, find: string, replace: string): StringAndHoles;
	    /**
	     * Shorten the passed path intelligently (path-aware).
	     * Works with *local paths* and *network paths*
	     * @param uriOrig The path to shorten
	     * @param length The length to which the path will be shortened.
	     */
	    static shortenPath(uriOrig: string, length: number): StringAndHoles;
	    /**
	     * Shorten the passed string.
	     * @param toShortenOrig The string to shorten
	     * @param length The length to which the string will be shortened.
	     * @param toAppend The string to append at the end (usually, it is set to '...')
	     */
	    static shortenString(toShortenOrig: string, length?: number, toAppend?: string): StringAndHoles;
	    /**
	     * Shorten the passed URI intelligently (path-aware).
	     * @param toShortenOrig The URI to shorten
	     * @param length The length to which the URI will be shortened.
	     */
	    static shortenUri(uri: string, length: number): StringAndHoles;
	}
	class HighlightUtils {
	    /**
	     * Highlight the passed string using specified highlights and holes.
	     * @param content The string to highlight items in.
	     * @param highlights The highlighted positions to highlight in the string.
	     * @param holes Possible holes which are used to skip highlighting.
	     * @param cssClass The css class to use on the highlighting `span`.
	     */
	    static highlightString(content: string, highlights: IHighlight[], holes: IStringHole[], cssClass: string): string;
	    static highlight(text: string, match: string, className: string): HTMLElement[];
	}

}
declare module Coveo {
	/**
	 * Options for building an `<a>` tag.
	 */
	interface IAnchorUtilsOptions {
	    /**
	     * The tag's text content.
	     */
	    text?: string;
	    /**
	     * The target (`href` attribute).
	     */
	    target?: string;
	    /**
	     * The CSS class(es) of the tag.
	     */
	    class?: string;
	}
	/**
	 * Options for building an `<img>` tag.
	 */
	interface IImageUtilsOptions {
	    /**
	     * The alternative text for the image (`alt` attribute).
	     */
	    alt?: string;
	    /**
	     * The height of the image
	     */
	    height?: string;
	    /**
	     * The width of the image
	     */
	    width?: string;
	    /**
	     * The template to use for the image source
	     */
	    srcTemplate?: string;
	}
	class HTMLUtils {
	    static buildAttributeString(options: any): string;
	}
	class AnchorUtils {
	    static buildAnchor(href: string, options?: IAnchorUtilsOptions): string;
	}
	class ImageUtils {
	    static buildImage(src?: string, options?: IImageUtilsOptions): string;
	    static selectImageFromResult(result: IQueryResult): HTMLElement;
	    static buildImageWithDirectSrcAttribute(endpoint: SearchEndpoint, result: IQueryResult): void;
	    static buildImageWithBase64SrcAttribute(endpoint: SearchEndpoint, result: IQueryResult): void;
	    static buildImageFromResult(result: IQueryResult, endpoint: SearchEndpoint, options?: IImageUtilsOptions): string;
	}

}
declare module Coveo {
	enum OS_NAME {
	    WINDOWS = 0,
	    MACOSX = 1,
	    UNIX = 2,
	    LINUX = 3,
	    UNKNOWN = 4,
	}
	class OSUtils {
	    static get(nav?: Navigator): any;
	}

}
declare module Coveo {
	interface IPopupPosition {
	    vertical: PopupVerticalAlignment;
	    horizontal: PopupHorizontalAlignment;
	    verticalOffset?: number;
	    horizontalOffset?: number;
	    horizontalClip?: boolean;
	}
	enum PopupVerticalAlignment {
	    TOP = 0,
	    MIDDLE = 1,
	    BOTTOM = 2,
	    INNERTOP = 3,
	    INNERBOTTOM = 4,
	}
	enum PopupHorizontalAlignment {
	    LEFT = 0,
	    CENTER = 1,
	    RIGHT = 2,
	    INNERLEFT = 3,
	    INNERRIGHT = 4,
	}
	class PopupUtils {
	    static positionPopup(popUp: HTMLElement, nextTo: HTMLElement, boundary: HTMLElement, desiredPosition: IPopupPosition, appendTo?: HTMLElement, checkForBoundary?: number): void;
	}

}
declare module Coveo {
	/**
	 * The possible options when highlighting a stream.
	 */
	interface IStreamHighlightOptions {
	    /**
	     * The css class that the highlight will generate.
	     * Defaults to `coveo-highlight`.
	     */
	    cssClass?: string;
	    /**
	     * The regex flags that should be applied to generate the highlighting.
	     * Defaults to `gi`.
	     */
	    regexFlags?: string;
	}
	class DefaultStreamHighlightOptions extends Options implements IStreamHighlightOptions {
	    cssClass: string;
	    shorten: number;
	    regexFlags: string;
	    constructor(cssClass?: string, shorten?: number, regexFlags?: string);
	}
	class StreamHighlightUtils {
	    static highlightStreamHTML(stream: string, termsToHighlight: IHighlightTerm, phrasesToHighlight: IHighlightPhrase, options?: IStreamHighlightOptions): string;
	    static highlightStreamText(stream: string, termsToHighlight: IHighlightTerm, phrasesToHighlight: IHighlightPhrase, options?: IStreamHighlightOptions): string;
	}
	function getRestHighlightsForAllTerms(toHighlight: string, termsToHighlight: IHighlightTerm, phrasesToHighlight: IHighlightPhrase, opts: IStreamHighlightOptions): IHighlight[];

}
declare module Coveo {
	/**
	 * The possible options to use when calculating a timespan
	 */
	interface ITimeSpanUtilsOptions {
	    /**
	     * Specify if the given timespan is in seconds or milliseconds
	     */
	    isMilliseconds: boolean;
	}
	class TimeSpan {
	    constructor(time: number, isMilliseconds?: boolean);
	    getMilliseconds(): number;
	    getSeconds(): number;
	    getMinutes(): number;
	    getHours(): number;
	    getDays(): number;
	    getWeeks(): number;
	    getHHMMSS(): string;
	    static fromDates(from: Date, to: Date): TimeSpan;
	}

}
declare module Coveo {
	type DOMElementToInitialize = {
	    componentClassId: string;
	    htmlElements: HTMLElement[];
	};
	class InitializationHelper {
	    static findDOMElementsToIgnore(container: HTMLElement, componentIdsToIgnore: string[]): HTMLElement[];
	    static findDOMElementsToInitialize(container: HTMLElement, htmlElementsToIgnore: HTMLElement[]): DOMElementToInitialize[];
	}

}
declare module Coveo {
	/**
	 * The bindings, or environment in which each component inside the {@link ResultList} exists.
	 */
	interface IResultsComponentBindings extends IComponentBindings {
	    resultElement: HTMLElement;
	}

}
declare module Coveo {
	/**
	 * Represent the initialization parameters required to init a new component.
	 */
	interface IInitializationParameters {
	    options: any;
	    result?: IQueryResult;
	    bindings: IComponentBindings;
	}
	interface IInitResult {
	    initResult: Promise<boolean>;
	    isLazyInit: boolean;
	}
	/**
	 * The main purpose of this class is to initialize the framework (a.k.a the code executed when calling `Coveo.init`).<br/>
	 * It's also in charge or registering the available components, as well as the method that we expost to the global Coveo scope.<br/>
	 * For example, the `Coveo.executeQuery` function will be registed in this class by the {@link QueryController}.
	 */
	class Initialization {
	    static componentsFactory: (elements: HTMLElement[], componentClassId: string, initParameters: IInitializationParameters) => {
	        factory: () => Promise<Component>[] | void;
	        isLazyInit: boolean;
	    };
	    static registeredComponents: String[];
	    static componentAliases: IStringMap<String[]>;
	    /**
	     * Register a new set of options for a given element.<br/>
	     * When the element is eventually initialized as a component, those options will be used / merged to create the final option set to use for this component.<br/>
	     * Note that this function should not normally be called directly, but instead using the global `Coveo.options` function
	     * @param element
	     * @param options
	     */
	    static registerDefaultOptions(element: HTMLElement, options: {}): void;
	    static resolveDefaultOptions(element: HTMLElement, options: {}): {};
	    /**
	     * Register a new Component to be recognized by the framework.
	     * This essentially mean that when we call `Coveo.init`, the Initialization class will scan the DOM for known component (which have registed themselves with this call) and create a new component on each element.
	     *
	     * This is meant to register the component to be loaded "eagerly" (Immediately available when the UI scripts are included)
	     * @param componentClass
	     */
	    static registerAutoCreateComponent(componentClass: IComponentDefinition): void;
	    /**
	     * Set the fields that the component needs to add to the query.
	     *
	     * This is used when the {@link ResultList.options.autoSelectFieldsToInclude } is set to `true` (which is `true` by default).
	     *
	     * The framework tries to only include the needed fields from the index, for performance reasons.
	     *
	     * @param componentId The id for the result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	     * @param fields
	     */
	    static registerComponentFields(componentId: string, fields: string[]): void;
	    /**
	     * Returns all the fields that the framework currently knows should be added to the query.
	     *
	     * This is used when the {@link ResultList.options.autoSelectFieldsToInclude } is set to `true` (which is `true` by default).
	     *
	     * The framework tries to only include the needed fields from the index, for performance reasons.
	     * @returns {string[]}
	     */
	    static getRegisteredFieldsForQuery(): string[];
	    /**
	     * Returns all the fields that the framework currently knows should be added to the query, for a given component.
	     *
	     * This is used when the {@link ResultList.options.autoSelectFieldsToInclude } is set to `true` (which is `true` by default).
	     *
	     * The framework tries to only include the needed fields from the index, for performance reasons.
	     * @param componentId
	     * @returns {string[]|Array}
	     */
	    static getRegisteredFieldsComponentForQuery(componentId: string): string[];
	    /**
	     * Check if a component is already registered, using it's ID (e.g. : 'Facet').
	     * @param componentClassId
	     * @returns {boolean}
	     */
	    static isComponentClassIdRegistered(componentClassId: string): boolean;
	    /**
	     * Return the list of all known components (the list of ID for each component), whether they are actually loaded or not.
	     * @returns {string[]}
	     */
	    static getListOfRegisteredComponents(): String[];
	    /**
	     * Return the list of all components that are currently eagerly loaded.
	     * @returns {string[]}
	     */
	    static getListOfLoadedComponents(): string[];
	    /**
	     * Return the component class definition, using it's ID (e.g. : 'CoveoFacet').
	     *
	     * This means the component needs to be eagerly loaded.
	     *
	     * @param name
	     * @returns {IComponentDefinition}
	     */
	    static getRegisteredComponent(name: string): IComponentDefinition;
	    /**
	     * Initialize the framework. Note that this function should not normally be called directly, but instead using a globally registered function (e.g.: Coveo.init), or {@link Initialization.initSearchInterface} or {@link Initialization.initStandaloneSearchInterface} <br/>
	     * (e.g. : `Coveo.init` or `Coveo.initSearchbox`).
	     * @param element The element on which to initialize the interface.
	     * @param options The options for all components (eg: {Searchbox : {enableSearchAsYouType : true}}).
	     * @param initSearchInterfaceFunction The function to execute to create the {@link SearchInterface} component. Different init call will create different {@link SearchInterface}.
	     */
	    static initializeFramework(element: HTMLElement, options: any, initSearchInterfaceFunction: (...args: any[]) => IInitResult): Promise<{
	        elem: HTMLElement;
	    }>;
	    /**
	     * Create a new standard search interface. This is the function executed when calling `Coveo.init`.
	     * @param element
	     * @param options
	     * @returns {IInitResult}
	     */
	    static initSearchInterface(element: HTMLElement, options?: any): IInitResult;
	    /**
	     * Create a new standalone search interface (standalone search box). This is the function executed when calling `Coveo.initSearchbox`.
	     * @param element
	     * @param options
	     * @returns {IInitResult}
	     */
	    static initStandaloneSearchInterface(element: HTMLElement, options?: any): IInitResult;
	    /**
	     * Create a new recommendation search interface. This is the function executed when calling `Coveo.initRecommendation`.
	     * @param element
	     * @param options
	     * @returns {IInitResult}
	     */
	    static initRecommendationInterface(element: HTMLElement, options?: any): IInitResult;
	    /**
	     * Scan the result element and all its children for known components. Initialize every known result component found.
	     *
	     * See also : {@link Initialization.automaticallyCreateComponentsInside}.
	     * @param resultElement The root element to scan for known components
	     * @param result The result which needs to be passed to each result component constructor.
	     * @param optionsToInject A set of options to inject for the components found inside the resultElement. These options will be merged with any options passed during the "init" call of the search interface.
	     */
	    static automaticallyCreateComponentsInsideResult(resultElement: HTMLElement, result: IQueryResult, optionsToInject?: {}): IInitResult;
	    /**
	     * Scan the element and all its children for known components. Initialize every known component found.
	     *
	     * @param element
	     * @param initParameters
	     * @param ignore
	     * @returns {IInitResult}
	     */
	    static automaticallyCreateComponentsInside(element: HTMLElement, initParameters: IInitializationParameters, ignore?: string[]): IInitResult;
	    /**
	     * Register a new globally available method in the Coveo namespace (e.g.: `Coveo.init`).
	     * @param methodName The method name to register.
	     * @param handler The function to execute when the method is called.
	     */
	    static registerNamedMethod(methodName: string, handler: (...args: any[]) => any): void;
	    /**
	     * Check if the method is already registed.
	     * @param methodName
	     * @returns {boolean}
	     */
	    static isNamedMethodRegistered(methodName: string): boolean;
	    /**
	     * 'Monkey patch' (replace the function with a new one) a given method on a component instance.
	     * @param methodName
	     * @param element
	     * @param handler
	     */
	    static monkeyPatchComponentMethod(methodName: string, element: HTMLElement, handler: (...args: any[]) => any): void;
	    static initBoxInterface(element: HTMLElement, options?: any, type?: string, injectMarkup?: boolean): IInitResult;
	    static dispatchNamedMethodCall(methodName: string, element: HTMLElement, args: any[]): any;
	    static dispatchNamedMethodCallOrComponentCreation(token: string, element: HTMLElement, args: any[]): any;
	    static isSearchFromLink(searchInterface: SearchInterface): boolean;
	    static isThereASingleComponentBoundToThisElement(element: HTMLElement): boolean;
	    static isThereANonSearchInterfaceComponentBoundToThisElement(element: HTMLElement): boolean;
	}
	class LazyInitialization {
	    static lazyLoadedComponents: IStringMap<() => Promise<IComponentDefinition>>;
	    static lazyLoadedModule: IStringMap<() => Promise<any>>;
	    static getLazyRegisteredComponent(name: string): Promise<IComponentDefinition>;
	    static getLazyRegisteredModule(name: string): Promise<any>;
	    static registerLazyComponent(id: string, load: () => Promise<IComponentDefinition>, aliases?: string[]): void;
	    static buildErrorCallback(chunkName: string, resolve: Function): (error: any) => void;
	    static registerLazyModule(id: string, load: () => Promise<any>): void;
	    static componentsFactory(elements: Element[], componentClassId: string, initParameters: IInitializationParameters): {
	        factory: () => Promise<Component>[];
	        isLazyInit: boolean;
	    };
	}
	class EagerInitialization {
	    static eagerlyLoadedComponents: IStringMap<IComponentDefinition>;
	    static componentsFactory(elements: Element[], componentClassId: string, initParameters: IInitializationParameters): {
	        factory: () => void;
	        isLazyInit: boolean;
	    };
	}

}
declare module Coveo {
	class SVGDom {
	    static addClassToSVGInContainer(svgContainer: HTMLElement, classToAdd: string): void;
	    static removeClassFromSVGInContainer(svgContainer: HTMLElement, classToRemove: string): void;
	    static addStyleToSVGInContainer(svgContainer: HTMLElement, styleToAdd: IStringMap<any>): void;
	    static addAttributesToSVGInContainer(svgContainer: HTMLElement, attributesToAdd: IStringMap<string>): void;
	}

}
declare module Coveo {
	/**
	 * Describe an interface for a simple form widget.
	 *
	 * {@link Checkbox}, {@link DatePicker}, {@link Dropdown} are all examples of `IFormWidgets`.
	 */
	interface IFormWidget {
	    reset: () => void;
	    getValue: () => string | number | string[];
	    build: () => HTMLElement;
	    getElement: () => HTMLElement;
	}
	interface IFormWidgetWithLabel extends IFormWidget {
	    label: string;
	    getLabel: () => HTMLElement;
	}
	interface IFormWidgetSelectable extends IFormWidget {
	    isSelected: () => boolean;
	    select: () => void;
	}
	interface IFormWidgetSettable extends IFormWidget {
	    setValue: (value: any) => void;
	}

}
declare module Coveo {
	/**
	 * A numeric spinner widget with standard styling.
	 */
	class NumericSpinner implements IFormWidget, IFormWidgetSettable {
	    onChange: (numericSpinner: NumericSpinner) => void;
	    min: number;
	    max: number;
	    name: string;
	    static doExport(): void;
	    /**
	     * Creates a new `NumericSpinner`.
	     * @param onChange The function to call when the numeric spinner value changes. This function takes the current
	     * `NumericSpinner` instance as an argument.
	     * @param min The minimum possible value of the numeric spinner.
	     * @param max The maximum possible value of the numeric spinner.
	     * @param label The label to use for the input for accessibility purposes.
	     */
	    constructor(onChange?: (numericSpinner: NumericSpinner) => void, min?: number, max?: number, label?: string);
	    /**
	     * Resets the numeric spinner.
	     */
	    reset(): void;
	    /**
	     * Gets the element on which the numeric spinner is bound.
	     * @returns {HTMLInputElement} The numeric spinner element.
	     */
	    getElement(): HTMLElement;
	    /**
	     * Gets the numeric spinner currently selected value (as a string).
	     * @returns {string} The numeric spinner value.
	     */
	    getValue(): string;
	    /**
	     * Gets the numeric spinner currently selected value (as an integer).
	     * @returns {number} The numeric spinner value.
	     */
	    getIntValue(): number;
	    /**
	     * Gets the numeric spinner currently selected value (as a float).
	     * @returns {number} The numeric spinner value.
	     */
	    getFloatValue(): number;
	    /**
	     * Sets the numeric spinner value.
	     *
	     * @param value The value to set the numeric spinner to. If `value` is greater than [`max`]{@link NumericSpinner.max},
	     * this method sets the numeric spinner to its maximum value instead. Likewise, if value is lesser than
	     * [`min`]{@link NumericSpinner.min}, the method sets the numeric spinner to its minimum value.
	     */
	    setValue(value: number): void;
	    /**
	     * Gets the element on which the numeric spinner is bound.
	     * @returns {HTMLInputElement} The numeric spinner element.
	     */
	    build(): HTMLElement;
	}

}
declare module Coveo {
	/**
	 * A date picker widget with standard styling.
	 */
	class DatePicker implements IFormWidget, IFormWidgetSettable {
	    onChange: (datePicker: DatePicker) => void;
	    static doExport: () => void;
	    /**
	     * Creates a new `DatePicker`.
	     * @param onChange The function to call when a new value is selected in the date picker. This function takes the
	     * current `DatePicker` instance as an argument.
	     */
	    constructor(onChange?: (datePicker: DatePicker) => void);
	    /**
	     * Resets the date picker.
	     */
	    reset(): void;
	    /**
	     * Gets the element on which the date picker is bound.
	     * @returns {HTMLInputElement} The date picker element.
	     */
	    getElement(): HTMLInputElement;
	    /**
	     * Gets the currently selected value in the date picker.
	     * @returns {string} A textual representation of the currently selected value (`YYYY-MM-DD` format).
	     */
	    getValue(): string;
	    /**
	     * Get the currently selected value in the date picker, as a Date object
	     * @returns {Date} A Date object for the current value, or null if the date picker was reset or a date has not been selected initially.
	     */
	    getDateValue(): Date;
	    /**
	     * Sets the date picker value.
	     * @param date The value to set the date picker to. Must be a
	     * [Date](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_Objects/Date) object.
	     */
	    setValue(date: Date): void;
	    /**
	     * Gets the element on which the date picker is bound.
	     * @returns {HTMLInputElement} The date picker element.
	     */
	    build(): HTMLInputElement;
	}

}
declare module Coveo {
	/**
	 * A dropdown widget with standard styling.
	 */
	class Dropdown implements IFormWidget, IFormWidgetSettable {
	    onChange: (dropdown: Dropdown) => void;
	    protected listOfValues: string[];
	    static doExport(): void;
	    /**
	     * Creates a new `Dropdown`.
	     * @param onChange The function to call when the dropdown selected value changes. This function takes the current
	     * `Dropdown` instance as an argument.
	     * @param listOfValues The selectable values to display in the dropdown.
	     * @param getDisplayValue An optional function to modify the display values, rather than using the values as they
	     * appear in the `listOfValues`.
	     * @param label The label to use for the input for accessibility purposes.
	     */
	    constructor(onChange: (dropdown: Dropdown) => void, listOfValues: string[], getDisplayValue?: (string) => string, label?: string);
	    /**
	     * Resets the dropdown.
	     */
	    reset(): void;
	    setId(id: string): void;
	    /**
	     * Gets the element on which the dropdown is bound.
	     * @returns {HTMLElement} The dropdown element.
	     */
	    getElement(): HTMLElement;
	    /**
	     * Gets the currently selected dropdown value.
	     * @returns {string} The currently selected dropdown value.
	     */
	    getValue(): string;
	    /**
	     * Selects a value from the dropdown [`listofValues`]{@link Dropdown.listOfValues}.
	     * @param index The 0-based index position of the value to select in the `listOfValues`.
	     * @param executeOnChange Indicates whether to execute the [`onChange`]{@link Dropdown.onChange} function when this
	     * method changes the dropdown selection.
	     */
	    select(index: number, executeOnChange?: boolean): void;
	    /**
	     * Gets the element on which the dropdown is bound.
	     * @returns {HTMLElement} The dropdown element.
	     */
	    build(): HTMLElement;
	    /**
	     * Sets the dropdown value.
	     * @param value The value to set the dropdown to.
	     */
	    setValue(value: string): void;
	}

}
declare module Coveo {
	interface ITextInputOptions {
	    /**
	     * Whether to add a placeholder to the `TextInput` rather than a label.
	     *
	     * **Default:** `false`
	     */
	    usePlaceholder?: boolean;
	    /**
	     * The class name to add to the `TextInput`'s HTML element.
	     *
	     * **Default:** `coveo-input`
	     */
	    className?: string;
	    /**
	     * Whether to trigger the `TextInput`'s `onChange` function on every key press
	     * rather than when the enter key is pressed or the input is blurred.
	     *
	     * **Default:** `false`
	     */
	    triggerOnChangeAsYouType?: boolean;
	    /**
	     * Whether to set the required attribute to `true` or `false`.
	     *
	     * **Default:** `true`
	     */
	    isRequired?: boolean;
	    /**
	     * A custom aria-label attribute to add to the `TextInput`'s HTML element.
	     */
	    ariaLabel?: string;
	    /**
	     * The name of an icon to display inside the input at its beginning.
	     *
	     * **Default:** `any`
	     */
	    icon?: string;
	}
	/**
	 * A text input widget with standard styling.
	 */
	class TextInput implements IFormWidget, IFormWidgetSettable {
	    onChange: (textInput: TextInput) => void;
	    name: string;
	    static doExport(): void;
	    /**
	     * Creates a new `TextInput`.
	     * @param onChange The function to call when the value entered in the text input changes. This function takes the
	     * current `TextInput` instance as an argument.
	     * @param name The text to display in the text input label or placeholder.
	     */
	    constructor(onChange?: (textInput: TextInput) => void, name?: string, options?: ITextInputOptions);
	    /**
	     * Gets the element on which the text input is bound.
	     * @returns {HTMLElement} The text input element.
	     */
	    getElement(): HTMLElement;
	    /**
	     * Gets the value currently entered in the text input.
	     * @returns {string} The text input current value.
	     */
	    getValue(): string;
	    /**
	     * Sets the value in the text input.
	     * @param value The value to set the text input to.
	     */
	    setValue(value: string): void;
	    /**
	     * Resets the text input.
	     */
	    reset(): void;
	    /**
	     * Gets the element on which the text input is bound.
	     * @returns {HTMLElement} The text input element.
	     */
	    build(): HTMLElement;
	    /**
	     * Gets the `input` element (the text input itself).
	     * @returns {HTMLElement} The `input` element.
	     */
	    getInput(): HTMLInputElement;
	}

}
declare module Coveo {
	/**
	 * A radio button widget with standard styling.
	 */
	class RadioButton implements IFormWidgetWithLabel, IFormWidgetSelectable {
	    onChange: (radioButton: RadioButton) => void;
	    label: string;
	    name: string;
	    protected element: HTMLElement;
	    static doExport(): void;
	    /**
	     * Creates a new `RadioButton`.
	     * @param onChange The function to call when the radio button value changes. This function takes the current
	     * `RadioButton` instance as an argument.
	     * @param label The label to display next to the radio button.
	     * @param name The value to set the `input` HTMLElement `name` attribute to.
	     */
	    constructor(onChange: (radioButton: RadioButton) => void, label: string, name: string, id?: string);
	    /**
	     * Resets the radio button.
	     */
	    reset(): void;
	    /**
	     * Select the radio button
	     * @param triggerChange will trigger change event if specified and the radio button is not already selected
	     */
	    select(triggerChange?: boolean): void;
	    /**
	     * Gets the element on which the radio button is bound.
	     * @returns {HTMLElement} The radio button element.
	     */
	    build(): HTMLElement;
	    /**
	     * Gets the element on which the radio button is bound.
	     * @returns {HTMLElement} The radio button element.
	     */
	    getElement(): HTMLElement;
	    getValue(): string;
	    /**
	     * Indicates whether the radio button is selected.
	     * @returns {boolean} `true` if the radio button is selected, `false` otherwise.
	     */
	    isSelected(): boolean;
	    /**
	     * Gets the `input` element (the radio button itself).
	     * @returns {HTMLInputElement} The `input` element.
	     */
	    getRadio(): HTMLInputElement;
	    /**
	     * Gets the radio button [`label`]{@link RadioButton.label} element.
	     * @returns {HTMLLabelElement} The `label` element.
	     */
	    getLabel(): HTMLLabelElement;
	}

}
declare module Coveo {
	/**
	 * The basic types of form available to build an advanced search section.
	 */
	type BaseFormTypes = NumericSpinner | DatePicker | Dropdown | TextInput | RadioButton;
	interface IAdvancedSearchInput {
	    build: () => HTMLElement;
	    updateQuery: (queryBuilder: QueryBuilder) => void;
	    reset: () => void;
	}
	interface IAdvancedSearchPrebuiltInput {
	    name: string;
	    parameters?: IFieldInputParameters;
	}
	interface IFieldInputParameters {
	    name: string;
	    field: string;
	}
	/**
	 * Describe a section in the {@link AdvancedSearch} component
	 */
	interface IAdvancedSearchSection {
	    /**
	     * The name of the section.
	     */
	    name: string;
	    /**
	     * The array of inputs to populate.
	     *
	     * External code should only push inputs that match the type {@link BaseFormTypes}.
	     */
	    inputs: (IAdvancedSearchInput | IAdvancedSearchPrebuiltInput)[];
	}
	/**
	 * Describe a section populated by external code, using the {@link AdvancedSearchEvents.buildingAdvancedSearch}
	 */
	interface IExternalAdvancedSearchSection extends IAdvancedSearchSection {
	    /**
	     * An handler to execute every time a new query is launched.
	     *
	     * The handler will receive the inputs used to build the external section, as well as the queryBuilder object to allow to modify the query.
	     * @param inputs
	     * @param queryBuilder
	     */
	    updateQuery: (inputs: BaseFormTypes[], queryBuilder: QueryBuilder) => void;
	    /**
	     * The content to add to the external section, as an HTMLElement.
	     */
	    content: HTMLElement;
	}

}
declare module Coveo {
	/**
	 * Argument sent to all handlers bound on {@link AdvancedSearchEvents.buildingAdvancedSearch}
	 */
	interface IBuildingAdvancedSearchEventArgs {
	    /**
	     * Sections which external code can populate by pushing into this array.
	     */
	    sections: IExternalAdvancedSearchSection[];
	    /**
	     * An easy way to execute a new query.
	     * @param options
	     */
	    executeQuery: (options: IQueryOptions) => Promise<IQueryResults>;
	}
	/**
	 * This static class is there to contains the different string definition for all the events related to the {@link AdvancedSearch} component.
	 */
	class AdvancedSearchEvents {
	    /**
	     * Triggered when the {@link AdvancedSearch} component is being built.
	     *
	     * Allows external code to add new sections in the **Advanced Search** panel.
	     *
	     * All bound handlers receive {@link IBuildingAdvancedSearchEventArgs} as an argument
	     *
	     * @type {string}
	     */
	    static buildingAdvancedSearch: string;
	    static executeAdvancedSearch: string;
	}

}
declare module Coveo {
	class DebugEvents {
	    static showDebugPanel: string;
	}

}
declare module Coveo {
	/**
	 * The `IGeolocationPosition` interface describes a geolocation position
	 * usable by the [DistanceResources]{@link DistanceResources} component.
	 */
	interface IGeolocationPosition {
	    longitude: number;
	    latitude: number;
	}
	/**
	 * The `IGeolocationPositionProvider` interface describes an object with a method that can provide
	 * a geolocation position to the [DistanceResources]{@link DistanceResources} component.
	 */
	interface IGeolocationPositionProvider {
	    getPosition(): Promise<IGeolocationPosition>;
	}
	/**
	 * The `IResolvingPositionEventArgs` interface describes the object that all
	 * [`onResolvingPosition`]{@link DistanceEvents.onResolvingPosition} event handlers receive as an argument.
	 */
	interface IResolvingPositionEventArgs {
	    /**
	     * The array of providers that can provide a position. The first provider that can resolve the position will be used.
	     */
	    providers: IGeolocationPositionProvider[];
	}
	/**
	 * The `IPositionResolvedEventArgs` interface describes the object that all
	 * [`onPositionResolved`]{@link DistanceEvents.onPositionResolved} event handlers receive as an argument.
	 */
	interface IPositionResolvedEventArgs {
	    /**
	     * The position that was resolved.
	     */
	    position: IGeolocationPosition;
	}
	/**
	 * The `DistanceEvents` static class contains the string definitions of all events related to distance
	 * list.
	 *
	 * See [Events](https://docs.coveo.com/en/417/).
	 */
	class DistanceEvents {
	    /**
	     * Triggered when the [`DistanceResources`]{@link DistanceResources} component successfully resolves the position.
	     *
	     * All `onPositionResolved` event handlers receive a [`PositionResolvedEventArgs`]{@link IPositionResolvedEventArgs}
	     * object as an argument.
	     *
	     * @type {string} The string value is `onPositionResolved`.
	     */
	    static onPositionResolved: string;
	    /**
	     * Triggered when the [`DistanceResources`]{@link DistanceResources} component tries to resolve the position.
	     *
	     * All `onResolvingPosition` event handlers receive a
	     * [`ResolvingPositionEventArgs`]{@link IResolvingPositionEventArgs} object as an argument.
	     *
	     * **Note:**
	     * > You should bind a handler to this event if you want to register one or several new position providers.
	     *
	     * @type {string} The string value is `onResolvingPosition`.
	     */
	    static onResolvingPosition: string;
	    /**
	     * Triggered when the [`DistanceResources`]{@link DistanceResources} component fails to resolve the position.
	     *
	     * **Note:**
	     * > You should bind a handler to this event if you want to display an error message to the end user, or hide
	     * > components that cannot be used.
	     *
	     * @type {string} The string value is `onPositionNotResolved`.
	     */
	    static onPositionNotResolved: string;
	}

}
declare module Coveo {
	interface IResultLayoutPopulateArgs {
	    layouts: string[];
	}
	class ResultLayoutEvents {
	    static populateResultLayout: string;
	}

}
declare module Coveo {
	const SUBSCRIPTION_TYPE: {
	    followQuery: string;
	    followDocument: string;
	};
	interface ISearchAlertsEndpointOptions {
	    restUri: string;
	    accessToken?: string;
	    errorsAsSuccess?: boolean;
	}
	interface ISearchAlertsEndpointCallOptions {
	    type?: string;
	    page?: number;
	}
	interface ISearchAlertsEndpointSearchCallOptions {
	    documentIds: string[];
	}
	/**
	 * Describe a subscription to the Coveo Search alerts service
	 */
	interface ISubscription extends ISubscriptionRequest {
	    /**
	     * The id of the subscription
	     */
	    id: string;
	    /**
	     * The user associated with the subscription
	     */
	    user: ISubscriptionUser;
	}
	/**
	 * Describe a user associated with a subscription to the Coveo Search alerts service
	 */
	interface ISubscriptionUser {
	    /**
	     * The email of the user
	     */
	    email: string;
	    /**
	     * The token used to manage the alerts via email.
	     */
	    manageToken: string;
	}
	/**
	 * Describe a request to subscribe to the Coveo Search alerts service
	 */
	interface ISubscriptionRequest {
	    /**
	     * Type of subscription.<br/>
	     * Can be 'followQuery' or 'followDocument'
	     */
	    type: string;
	    /**
	     * Config of the subscription
	     */
	    typeConfig: ISubscriptionQueryRequest | ISubscriptionItemRequest;
	    /**
	     * Frequency of the alerts
	     */
	    frequency?: string;
	    /**
	     * The name that should be used by the API to identify this subscription
	     */
	    name: string;
	}
	/**
	 * Describe a subscription to a single query
	 */
	interface ISubscriptionQueryRequest {
	    /**
	     * Query to subscribe to
	     */
	    query: IQuery;
	    /**
	     * Which field on the result set represent the modification date for which you wish to receive alerts
	     */
	    modifiedDateField?: string;
	}
	/**
	 * The `ISubscriptionItemRequest` interface describes a subscription to a single item (a result).
	 */
	interface ISubscriptionItemRequest {
	    /**
	     * Contains the unique ID of the item to subscribe to.
	     */
	    id: string;
	    /**
	     * Contains the title of the item to subscribe to.
	     */
	    title: string;
	    /**
	     * Indicates which field contains the modification date of the item to subscribe to.
	     */
	    modifiedDateField?: string;
	    /**
	     * Contains a list of fields to monitor for the item to subscribe to.
	     */
	    watchedFields?: string[];
	}

}
declare module Coveo {
	interface ISearchAlertsEventArgs {
	    subscription: ISubscription;
	    dom?: HTMLElement;
	}
	interface ISearchAlertsFailEventArgs {
	    dom?: HTMLElement;
	}
	interface ISearchAlertsPopulateMessageEventArgs {
	    text: Array<string | ISearchAlertsPopulateMessageText>;
	}
	interface ISearchAlertsPopulateMessageText {
	    lineThrough: boolean;
	    value: string;
	}
	class SearchAlertsEvents {
	    static searchAlertsCreated: string;
	    static searchAlertsDeleted: string;
	    static searchAlertsFail: string;
	    static searchAlertsPopulateMessage: string;
	}

}
declare module Coveo {
	interface IGraphValueSelectedArgs {
	    start: any;
	    end: any;
	    value: any;
	}
	class SliderEvents {
	    static startSlide: string;
	    static duringSlide: string;
	    static endSlide: string;
	    static graphValueSelected: string;
	}

}
declare module Coveo {
	class AnalyticsInformation {
	    pendingSearchEvent: PendingSearchEvent;
	    originContext: string;
	    userDisplayName: string;
	    clientId: string;
	     lastPageId: string;
	     location: string;
	     referrer: string;
	    clear(): void;
	}

}
declare module Coveo {
	interface IAnalyticsEndpointOptions {
	    accessToken: AccessToken;
	    serviceUrl: string;
	    organization: string;
	}
	class AnalyticsEndpoint {
	    options: IAnalyticsEndpointOptions;
	    logger: Logger;
	    static DEFAULT_ANALYTICS_URI: string;
	    static DEFAULT_ANALYTICS_VERSION: string;
	    static CUSTOM_ANALYTICS_VERSION: any;
	    static pendingRequest: Promise<any>;
	    endpointCaller: AnalyticsEndpointCaller;
	    constructor(options: IAnalyticsEndpointOptions);
	    static getURLFromSearchEndpoint(endpoint: SearchEndpoint): string;
	    getCurrentVisitId(): string;
	    getCurrentVisitIdPromise(): Promise<string>;
	    sendSearchEvents(searchEvents: ISearchEvent[]): Promise<IAPIAnalyticsSearchEventsResponse>;
	    sendDocumentViewEvent(documentViewEvent: IClickEvent): Promise<IAPIAnalyticsEventResponse>;
	    sendCustomEvent(customEvent: ICustomEvent): Promise<any>;
	    getTopQueries(params: ITopQueries): Promise<string[]>;
	    clearCookies(): void;
	}

}
declare module Coveo {
	class PendingSearchEvent {
	    root: HTMLElement;
	    endpoint: AnalyticsEndpoint;
	    templateSearchEvent: ISearchEvent;
	    sendToCloud: boolean;
	    protected cancelled: boolean;
	    protected finished: boolean;
	    protected searchEvents: ISearchEvent[];
	    constructor(root: HTMLElement, endpoint: AnalyticsEndpoint, templateSearchEvent: ISearchEvent, sendToCloud: boolean);
	    getEventCause(): string;
	    getEventMeta(): {
	        [key: string]: any;
	    };
	    addFacetState(state: IAnalyticsFacetState[]): void;
	    cancel(): void;
	    stopRecording(): void;
	    protected handleDuringQuery(evt: Event, args: IDuringQueryEventArgs, queryBoxContentToUse?: string): void;
	}

}
declare module Coveo {
	/**
	 * The `IAnalyticsClient` interface describes an analytics client that can log events to, or return information from the
	 * usage analytics service.
	 *
	 * See also the [`Analytics`]{@link Analytics} component.
	 */
	interface IAnalyticsClient {
	    isContextual: boolean;
	    endpoint: AnalyticsEndpoint;
	    /**
	     * Indicates whether there is an [`Analytics`]{@link Analytics} component in the search page. Returns `true` if an
	     * `Analytics` component is present, and `false` otherwise.
	     */
	    isActivated(): boolean;
	    getCurrentEventCause(): string;
	    getCurrentEventMeta(): {
	        [key: string]: any;
	    };
	    /**
	     * Logs a `Search` usage analytics event.
	     *
	     * A `Search` event is actually sent to the Coveo Usage Analytics service only after the query successfully returns
	     * (not immediately after calling this method). Therefore, it is 
	     * the query. Otherwise, the `Search` event will not be logged, and you will get a warning message in the console.
	     *
	     * **Note:**
	     *
	     * > When logging custom `Search` events, you should use the `Coveo.logSearchEvent` top-level function rather than
	     * > calling this method directly from the analytics client. See
	     * > [Logging Your Own Search Events](https://docs.coveo.com/en/2726/#logging-your-own-search-events).
	     *
	     * @param actionCause The cause of the event.
	     * @param meta The metadata you want to use to create custom dimensions. Metadata can contain as many key-value
	     * pairs as you need. Each key must contain only alphanumeric characters and underscores. The Coveo Usage Analytics
	     * service automatically converts white spaces to underscores, and uppercase characters to lowercase characters in key
	     * names. Each value must be a simple string. If you do not need to log metadata, you can simply pass an empty JSON
	     * ( `{}` ).
	     */
	    logSearchEvent<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta): void;
	    /**
	     * Logs a `SearchAsYouType` usage analytics event.
	     *
	     * This method is very similar to the [`logSearchEvent`]{@link AnalyticsClient.logSearchEvent} method, except that
	     * `logSearchAsYouType` should, by definition, be called more frequently. Consequently, in order to avoid logging
	     * every single partial query, the `PendingSearchAsYouTypeEvent` takes care of logging only the "relevant" last event:
	     * an event that occurs after 5 seconds have elapsed without any event being logged, or an event that occurs after
	     * another part of the interface triggers a search event.
	     *
	     * It is 
	     * logged, and you will get a warning message in the console.
	     *
	     * **Note:**
	     *
	     * > When logging custom `SearchAsYouType` events, you should use the `Coveo.logSearchAsYouTypeEvent` top-level
	     * > function rather than calling this method directly from the analytics client. See
	     * > [Logging Your Own Search Events](https://docs.coveo.com/en/2726/#logging-your-own-search-events).
	     *
	     * @param actionCause The cause of the event.
	     * @param meta The metadata which you want to use to create custom dimensions. Metadata can contain as many key-value
	     * pairs as you need. Each key must contain only alphanumeric characters and underscores. The Coveo Usage Analytics
	     * service automatically converts white spaces to underscores and uppercase characters to lowercase characters in key
	     * names. Each value must be a simple string. If you do not need to log metadata, you can simply pass an empty JSON
	     * ( `{}` ).
	     */
	    logSearchAsYouType<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta): void;
	    /**
	     * Logs a `Click` usage analytics event.
	     *
	     * A `Click` event corresponds to an item view (e.g., clicking on a {@link ResultLink} or opening a
	     * {@link Quickview}).
	     *
	     * `Click` events are immediately sent to the Coveo Usage Analytics service.
	     *
	     * **Note:**
	     * > When logging custom `Click` events, you should use the `Coveo.logClickEvent` top-level function rather than
	     * > calling this method directly from the analytics client. See
	     * > [Logging Your Own Search Events](https://docs.coveo.com/en/2726/#logging-your-own-search-events).
	     *
	     * @param actionCause The cause of the event.
	     * @param meta The metadata which you want to use to create custom dimensions. Metadata can contain as many key-value
	     * pairs as you need. Each key must contain only alphanumeric characters and underscores. The Coveo Usage Analytics
	     * service automatically converts uppercase characters to lowercase characters in key names. Each value must be a simple
	     * string. You do not have to pass an {@link IAnalyticsDocumentViewMeta} as meta when logging a `Click` event. You can
	     * actually send any arbitrary meta. If you do not need to log metadata, you can simply pass an empty JSON ( `{}` ).
	     * @param result The result that was clicked.
	     * @param element The HTMLElement that the user has clicked in the interface. Default value is the element on which
	     * the `Analytics` component is bound.
	     */
	    logClickEvent<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta, result: IQueryResult, element: HTMLElement): Promise<IAPIAnalyticsEventResponse>;
	    /**
	     * Logs a `Custom` usage analytics event on the service.
	     *
	     * You can use `Custom` events to create custom reports, or to track events which are neither queries (see
	     * [`logSearchEvent`]{@link AnalyticsClient.logSearchEvent} and
	     * [`logSearchAsYouType`]{@link AnalyticsClient.logSearchAsYouType}), nor item views (see
	     * [`logClickEvent`]{@link AnalyticsClient.logClickEvent}).
	     *
	     * **Note:**
	     * > When logging `Custom` events, you should use the `Coveo.logClickEvent` top-level function rather than calling
	     * > this method directly from the analytics client. See
	     * > [Logging Your Own Search Events](https://docs.coveo.com/en/2726/#logging-your-own-search-events).
	     *
	     * @param actionCause The cause of the event.
	     * @param meta The metadata which you want to use to create custom dimensions. Metadata can contain as many key-value
	     * pairs as you need. Each key must contain only alphanumeric characters and underscores. The Coveo Usage Analytics
	     * service automatically converts white spaces to underscores and uppercase characters to lowercase characters in key
	     * names. Each value must be a simple string. If you do not need to log metadata, you can simply pass an empty JSON
	     * ( `{}` ).
	     * @param element The HTMLElement that the user has interacted with for this custom event. Default value is the
	     * element on which the `Analytics` component is bound.
	     * @param result The IQueryResult that the custom event is linked to, if any.
	     */
	    logCustomEvent<TMeta>(actionCause: IAnalyticsActionCause, meta: TMeta, element: HTMLElement, result?: IQueryResult): Promise<IAPIAnalyticsEventResponse>;
	    /**
	     * Gets suggested queries from the Coveo Usage Analytics service.
	     * @param params
	     */
	    getTopQueries(params: ITopQueries): Promise<string[]>;
	    getCurrentVisitId(): string;
	    /**
	     * Gets the current visitor ID for tracking purpose in the Coveo Usage Analytics service.
	     */
	    getCurrentVisitIdPromise(): Promise<string>;
	    cancelAllPendingEvents(): void;
	    getPendingSearchEvent(): PendingSearchEvent;
	    sendAllPendingEvents(): void;
	    warnAboutSearchEvent(): void;
	    /**
	     * Sets the Origin Context dimension on the analytic events.
	     *
	     * You can use this dimension to specify the context of your application.
	     *
	     * Suggested values are `Search`, `InternalSearch`, or `CommunitySearch`.
	     *
	     * Default value is `Search`.
	     *
	     * @param originContext The origin context value.
	     */
	    setOriginContext(originContext: string): any;
	    /**
	     * Get the Origin Context dimension on the analytic events.
	     */
	    getOriginContext(): string;
	    /**
	     * Get the user display name;
	     */
	    getUserDisplayName(): string;
	}

}
declare module Coveo {
	/**
	 * Definition for a Component.
	 */
	interface IComponentDefinition {
	    /**
	     * The static ID that each component need to be identified.<br/>
	     * For example, SearchButton -> static ID : SearchButton -> className : CoveoSearchButton
	     */
	    ID: string;
	    aliases?: string[];
	    /**
	     * The generated `className` for this component.<br/>
	     * For example, SearchButton -> static ID : SearchButton -> className : CoveoSearchButton
	     */
	    className?: string;
	    /**
	     * Function that can be called to one or multiple module in the global scope.
	     */
	    doExport?: () => void;
	    /**
	     * Constructor for each component
	     * @param element The HTMLElement on which the component will instantiate.
	     * @param options The available options for the component.
	     * @param bindings The bindings (or environment) for the component.For exemple, the {@link QueryController} or {@link SearchInterface}. Optional, if not provided, the component will resolve those automatically. This has a cost on performance, though, since it has to traverses it's parents to find the correct elements.
	     * @param args Optional arguments, depending on the component type. For example, ResultComponent will receive the result there.
	     */
	    new (element: HTMLElement, options: any, bindings: IComponentBindings, ...args: any[]): Component;
	    /**
	     * The available options for the component.
	     */
	    options?: any;
	    /**
	     * The optional parent of the component, which will be a component itself.
	     */
	    parent?: IComponentDefinition;
	    /**
	     * The optional index fields that the component possess or display.
	     */
	    fields?: string[];
	}
	/**
	 * The `ComponentEvents` class is used by the various Coveo Component to trigger events and bind event handlers. It adds
	 * logic to execute handlers or triggers only when a component is "enabled", which serves as a way to avoid executing
	 * handlers on components that are invisible and inactive in the query.
	 *
	 * Typically, a component is disabled when it is not active in the current [`Tab`]{@link Tab}. It can also be disabled
	 * by external code, however.
	 *
	 * To manually enable or disable a component, simply use its [`enable`]{@link Component.enable} or
	 * [`disable`]{@link Component.disable} method.
	 */
	class ComponentEvents {
	    owner: Component;
	    static doExport(): void;
	    /**
	     * Creates a new `ComponentEvents` instance for a [`Component`]{@link Component}.
	     * @param owner The [`Component`]{@link Component} that owns the event handlers and triggers.
	     */
	    constructor(owner: Component);
	    /**
	     * Executes the handler for an event on a target element.
	     *
	     * Executes only if the component is enabled (see the [`enable`]{@link Component.enable} method).
	     * @param el The element from which the event originates.
	     * @param event The event for which to register a handler.
	     * @param handler The function to execute when the event is triggered.
	     */
	    on(el: HTMLElement | Window | Document, event: string, handler: Function): any;
	    on(el: Dom, event: string, handler: Function): any;
	    /**
	     * Executes the handler for the given event on the given target element.<br/>
	     * Execute only if the component is "enabled" (see {@link Component.enable}).<br/>
	     * Execute the handler only ONE time.
	     * @param el The target on which the event will originate.
	     * @param event The event for which to register an handler.
	     * @param handler The function to execute when the event is triggered.
	     */
	    one(el: HTMLElement, event: string, handler: Function): any;
	    one(el: Dom, event: string, handler: Function): any;
	    /**
	     * Bind on the "root" of the Component. The root is typically the {@link SearchInterface}.<br/>
	     * Bind an event using native javascript code.
	     * @param event The event for which to register an handler.
	     * @param handler The function to execute when the event is triggered.
	     */
	    onRootElement<T>(event: string, handler: (args: T) => any): void;
	    /**
	     * Bind on the "root" of the Component. The root is typically the {@link SearchInterface}.<br/>
	     * Bind an event using native javascript code.
	     * The handler will execute only ONE time.
	     * @param event The event for which to register an handler.
	     * @param handler The function to execute when the event is triggered.
	     */
	    oneRootElement<T>(event: string, handler: (args: T) => any): void;
	    /**
	     * Bind an event related specially to the query state model.<br/>
	     * This will build the correct string event and execute the handler only if the component is activated.
	     * @param eventType The event type for which to register an event.
	     * @param attribute The attribute for which to register an event.
	     * @param handler The handler to execute when the query state event is triggered.
	     */
	    onQueryState<T>(eventType: string, attribute?: string, handler?: (args: T) => any): void;
	    /**
	     * Bind an event related specially to the component option model.
	     * This will build the correct string event and execute the handler only if the component is activated.
	     * @param eventType The event type for which to register an event.
	     * @param attribute The attribute for which to register an event.
	     * @param handler The handler to execute when the query state event is triggered.
	     */
	    onComponentOptions<T>(eventType: string, attribute?: string, handler?: (args: T) => any): void;
	    /**
	     * Bind an event related specially to the query state model.<br/>
	     * This will build the correct string event and execute the handler only if the component is activated.<br/>
	     * Will execute only once.
	     * @param eventType The event type for which to register an event.
	     * @param attribute The attribute for which to register an event.
	     * @param handler The handler to execute when the query state event is triggered.
	     */
	    oneQueryState<T>(eventType: string, attribute?: string, handler?: (args: T) => any): void;
	    /**
	     * Trigger an event on the target element, with optional arguments.
	     * @param el The target HTMLElement on which to trigger the event.
	     * @param event The event to trigger.
	     * @param args The optional argument to pass to the handlers.
	     */
	    trigger(el: HTMLElement, event: string, args?: Object): any;
	    trigger(el: Dom, event: string, args?: Object): any;
	    /**
	     * Execute the function only if the component is enabled.
	     * @param func The function to execute if the component is enabled.
	     * @returns {function(...[any]): *}
	     */
	    protected wrapToCallIfEnabled(func: Function): (...args: any[]) => any;
	}
	/**
	 * The base class for every component in the framework.
	 */
	class Component extends BaseComponent {
	    element: HTMLElement;
	    type: string;
	    static ComponentEventClass: typeof ComponentEvents;
	    /**
	     * Allows the component to bind events and execute them only when it is enabled.
	     * @type {Coveo.ComponentEvents}
	     */
	    bind: ComponentEvents;
	    /**
	     * A reference to the root HTMLElement (the {@link SearchInterface}).
	     */
	    root: HTMLElement;
	    /**
	     * Contains the state of the query. Allows to get/set values. Trigger query state event when modified. Each component can listen to those events.
	     */
	    queryStateModel: QueryStateModel;
	    /**
	     * Contains the state of different components (enabled vs disabled). Allows to get/set values. Triggers component state event when modified. Each component can listen to those events.
	     */
	    componentStateModel: ComponentStateModel;
	    /**
	     * Contains the singleton that allows to trigger queries.
	     */
	    queryController: QueryController;
	    /**
	     * A reference to the root of every component, the {@link SearchInterface}.
	     */
	    searchInterface: SearchInterface;
	    /**
	     * Contains the state of options for different components. Mainly used by {@link ResultLink}.
	     */
	    componentOptionsModel: ComponentOptionsModel;
	    ensureDom: Function;
		options: any;
	    /**
	     * Create a new Component. Resolve all {@link IComponentBindings} if not provided.<br/>
	     * Create a new Logger for this component.
	     * Attach the component to the {@link SearchInterface}.<br/>
	     * @param element The HTMLElement on which to create the component. Used to bind data on the element.
	     * @param type The unique identifier for this component. See: {@link IComponentDefinition.ID}. Used to generate the unique Coveo CSS class associated with every component.
	     * @param bindings The environment for every component. Optional, but omitting to provide one will impact performance.
	     */
	    constructor(element: HTMLElement, type: string, bindings?: IComponentBindings);
	    /**
	     * Return the bindings, or environment, for the current component.
	     * @returns {IComponentBindings}
	     */
	    getBindings(): IComponentBindings;
	    /**
	     * A reference to the {@link Analytics.client}.
	     */
	     usageAnalytics: IAnalyticsClient;
	    createDom(): void;
	    resolveSearchInterface(): SearchInterface;
	    resolveQueryController(): QueryController;
	    resolveComponentStateModel(): ComponentStateModel;
	    resolveQueryStateModel(): QueryStateModel;
	    resolveComponentOptionsModel(): ComponentOptionsModel;
	    resolveUA(): IAnalyticsClient;
	    resolveResult(): IQueryResult;
	    protected removeTabSupport(): void;
	    /**
	     * Get the bound component to the given HTMLElement. Throws an assert if the HTMLElement has no component bound, unless using the noThrow argument.<br/>
	     * If there is multiple component bound to the current HTMLElement, you must specify the component class.
	     * @param element HTMLElement for which to get the bound component.
	     * @param componentClass Optional component class. If the HTMLElement has multiple components bound, you must specify which one you are targeting.
	     * @param noThrow Boolean option to tell the method to not throw on error.
	     * @returns {Component}
	     */
	    static get(element: HTMLElement, componentClass?: any, noThrow?: boolean): BaseComponent;
	    static getResult(element: HTMLElement, noThrow?: boolean): IQueryResult;
	    static bindResultToElement(element: HTMLElement, result: IQueryResult): void;
	    static bindFoldedResultToElement(element: HTMLElement): void;
	    static resolveRoot(element: HTMLElement): HTMLElement;
	    static resolveBinding(element: HTMLElement, componentClass: any): BaseComponent;
	    static pointElementsToDummyForm(element: HTMLElement): void;
	}

}
declare module Coveo {
	/**
	 * Argument sent to all handlers bound on {@link QueryEvents.newQuery}
	 */
	interface INewQueryEventArgs {
	    /**
	     * Whether the query is a search-as-you-type
	     */
	    searchAsYouType: boolean;
	    /**
	     * If this property is set to true by any handlers, the query will not be executed.
	     */
	    cancel: boolean;
	    shouldRedirectStandaloneSearchbox: boolean;
	    origin?: Component;
	}
	/**
	 * Argument sent to all handlers bound on {@link QueryEvents.buildingQuery}
	 */
	interface IBuildingQueryEventArgs {
	    /**
	     * Allow handlers to modify the query by using the {@link QueryBuilder}
	     */
	    queryBuilder: QueryBuilder;
	    /**
	     * Determine if the query is a "search-as-you-type"
	     */
	    searchAsYouType: boolean;
	    /**
	     * If this property is set to true by any handlers, the query will not be executed.
	     */
	    cancel: boolean;
	}
	/**
	 * Argument sent to all handlers bound on {@link QueryEvents.doneBuildingQuery}
	 */
	interface IDoneBuildingQueryEventArgs {
	    /**
	     * Allow handlers to modify the query by using the {@link QueryBuilder}
	     */
	    queryBuilder: QueryBuilder;
	    /**
	     * Whether the query is a search-as-you-type
	     */
	    searchAsYouType: boolean;
	    /**
	     * If this property is set to true by any handlers, the query will not be executed.
	     */
	    cancel: boolean;
	}
	/**
	 * Argument sent to all handlers bound on {@link QueryEvents.duringQuery}
	 */
	interface IDuringQueryEventArgs {
	    /**
	     * The {@link QueryBuilder} that was used for the current query
	     */
	    queryBuilder: QueryBuilder;
	    /**
	     * The query that was just executed
	     */
	    query: IQuery;
	    /**
	     * A promises for the results that will be returned by the Search API
	     */
	    promise: Promise<IQueryResults>;
	    /**
	     * Whether the query is a search-as-you-type
	     */
	    searchAsYouType: boolean;
	}
	/**
	 * Argument sent to all handlers bound on {@link QueryEvents.querySuccess}
	 */
	interface IQuerySuccessEventArgs {
	    /**
	     * The query that was just executed
	     */
	    query: IQuery;
	    /**
	     * The results returned by the query that was executed
	     */
	    results: IQueryResults;
	    /**
	     * The {@link QueryBuilder} that was used for the current query
	     */
	    queryBuilder: QueryBuilder;
	    /**
	     * Whether the query is a search-as-you-type
	     */
	    searchAsYouType: boolean;
	}
	/**
	 * Argument sent to all handlers bound on {@link QueryEvents.fetchMoreSuccess}
	 */
	interface IFetchMoreSuccessEventArgs {
	    /**
	     * The query that was just executed
	     */
	    query: IQuery;
	    /**
	     * The results returned by the query that was executed
	     */
	    results: IQueryResults;
	    /**
	     * The {@link QueryBuilder} that was used for the current query
	     */
	    queryBuilder: QueryBuilder;
	    /**
	     * Whether the query is a search-as-you-type
	     */
	    searchAsYouType: boolean;
	}
	/**
	 * Argument sent to all handlers bound on {@link QueryEvents.queryError}
	 */
	interface IQueryErrorEventArgs {
	    /**
	     * The {@link QueryBuilder} that was used for the current query
	     */
	    queryBuilder: QueryBuilder;
	    /**
	     * The endpoint on which the error happened.
	     */
	    endpoint: ISearchEndpoint;
	    /**
	     * The query that was just executed
	     */
	    query: IQuery;
	    /**
	     * The error info / message itself.
	     */
	    error: IEndpointError;
	    /**
	     * Whether the query is a search-as-you-type
	     */
	    searchAsYouType: boolean;
	}
	/**
	 * Argument sent to all handlers bound on {@link QueryEvents.preprocessResults}
	 */
	interface IPreprocessResultsEventArgs {
	    /**
	     * The {@link QueryBuilder} that was used for the current query
	     */
	    queryBuilder: QueryBuilder;
	    /**
	     * The query that was just executed
	     */
	    query: IQuery;
	    /**
	     * The results returned by the query that was executed
	     */
	    results: IQueryResults;
	    /**
	     * Whether the query is a search-as-you-type
	     */
	    searchAsYouType: boolean;
	}
	/**
	 * Argument sent to all handlers bound on {@link QueryEvents.preprocessMoreResults}
	 */
	interface IPreprocessMoreResultsEventArgs {
	    /**
	     * The results returned by the query that was executed
	     */
	    results: IQueryResults;
	}
	/**
	 * Argument sent to all handlers bound on {@link QueryEvents.noResults}
	 */
	interface INoResultsEventArgs {
	    /**
	     * The {@link QueryBuilder} that was used for the current query
	     */
	    queryBuilder: QueryBuilder;
	    /**
	     * The query that was just executed
	     */
	    query: IQuery;
	    /**
	     * The results returned by the query that was executed
	     */
	    results: IQueryResults;
	    /**
	     * Whether the query is a search-as-you-type
	     */
	    searchAsYouType: boolean;
	    /**
	     * If set to true by any handler, the last query will automatically be re-executed again.
	     */
	    retryTheQuery: boolean;
	}
	interface IBuildingCallOptionsEventArgs {
	    options: IEndpointCallOptions;
	}
	/**
	 * This static class is there to contains the different string definition for all the events related to query.
	 *
	 * Note that these events will only be triggered when the {@link QueryController.executeQuery} method is used, either directly or by using {@link executeQuery}
	 */
	class QueryEvents {
	    /**
	     * Triggered when a new query is launched.
	     *
	     * All bound handlers will receive {@link INewQueryEventArgs} as an argument.
	     *
	     * The string value is `newQuery`.
	     * @type {string}
	     */
	    static newQuery: string;
	    /**
	     * Triggered when the query is being built.
	     *
	     * This is typically where all components will contribute their part to the {@link IQuery} using the {@link QueryBuilder}.
	     *
	     * All bound handlers will receive {@link IBuildingQueryEventArgs} as an argument.
	     *
	     * The string value is `buildingQuery`.
	     * @type {string}
	     */
	    static buildingQuery: string;
	    /**
	     * Triggered when the query is done being built.
	     *
	     * This is typically where the facet will add it's {@link IGroupByRequest} to the {@link IQuery}.
	     *
	     * All bound handlers will receive {@link IDoneBuildingQueryEventArgs} as an argument.
	     *
	     * The string value is `doneBuildingQuery`.
	     * @type {string}
	     */
	    static doneBuildingQuery: string;
	    /**
	     * Triggered when the query is being executed on the Search API.
	     *
	     * All bound handlers will receive {@link IDuringQueryEventArgs} as an argument.
	     *
	     * The string value is `duringQuery`.
	     * @type {string}
	     */
	    static duringQuery: string;
	    /**
	     * Triggered when more results are being fetched on the Search API (think : infinite scrolling, or pager).
	     *
	     * All bound handlers will receive {@link IDuringQueryEventArgs} as an argument.
	     *
	     * The string value is `duringFetchMoreQuery`.
	     * @type {string}
	     */
	    static duringFetchMoreQuery: string;
	    /**
	     * Triggered when a query successfully returns from the Search API.
	     *
	     * All bound handlers will receive {@link IQuerySuccessEventArgs} as an argument.
	     *
	     * The string value is `querySuccess`.
	     * @type {string}
	     */
	    static querySuccess: string;
	    /**
	     * Triggered when a more results were successfully returned from the Search API. (think : infinite scrolling, or pager).
	     *
	     * All bound handlers will receive {@link IFetchMoreSuccessEventArgs} as an argument.
	     *
	     * The string value is `fetchMoreSuccess`.
	     * @type {string}
	     */
	    static fetchMoreSuccess: string;
	    /**
	     * Triggered after the main query success event has finished executing.
	     *
	     * This is typically where facets will process the {@link IGroupByResult} and render themselves.
	     *
	     * All bound handlers will receive {@link IQuerySuccessEventArgs} as an argument.
	     *
	     * The string value is `deferredQuerySuccess`.
	     * @type {string}
	     */
	    static deferredQuerySuccess: string;
	    /**
	     * Triggered when there was an error executing a query on the Search API.
	     *
	     * All bound handlers will receive {@link IQueryErrorEventArgs} as an argument.
	     *
	     * The string value is `queryError`.
	     * @type {string}
	     */
	    static queryError: string;
	    /**
	     * Triggered before the {@link QueryEvents.querySuccess} event.
	     *
	     * This allows external code to modify the results before rendering them.
	     *
	     * For example, the {@link Folding} component might use this event to construct a coherent parent child relationship between query results.
	     *
	     * All bound handlers will receive {@link IPreprocessResultsEventArgs} as an argument.
	     *
	     * The string value is `preprocessResults`.
	     * @type {string}
	     */
	    static preprocessResults: string;
	    /**
	     * Triggered before the {@link QueryEvents.fetchMoreSuccess} event.
	     *
	     * This allows external code to modify the results before rendering them.
	     *
	     * For example, the {@link Folding} component might use this event to construct a coherent parent child relationship between query results.
	     *
	     * All bound handlers will receive {@link IPreprocessResultsEventArgs} as an argument.
	     *
	     * The string value is `preprocessMoreResults`.
	     * @type {string}
	     */
	    static preprocessMoreResults: string;
	    /**
	     * Triggered when there is no result for a particular query.
	     *
	     * All bound handlers will receive {@link INoResultsEventArgs} as an argument.
	     *
	     * The string value is `noResults`.
	     * @type {string}
	     */
	    static noResults: string;
	    static buildingCallOptions: string;
	}

}
declare module Coveo {
	/**
	 * The `ITaggingRequest` interface describes a tag request on an item.
	 */
	interface ITaggingRequest {
	    /**
	     * Contains the field name to tag.
	     */
	    fieldName: string;
	    /**
	     * Contains the value to tag.
	     */
	    fieldValue: string;
	    /**
	     * Indicates whether to add the tag value, or to remove the tag value.
	     */
	    doAdd: boolean;
	    /**
	     * Contains the unique ID of the item to tag.
	     */
	    uniqueId: string;
	}

}
declare module Coveo {
	/**
	 * The `IRatingRequest` interface describes a request to rate an item in the index.
	 */
	interface IRatingRequest {
	    /**
	     * Contains the unique ID of the item to rate.
	     */
	    uniqueId: string;
	    /**
	     * Contains the rating description.
	     *
	     * Possible values are `Undefined` | `Lowest` | `Low` | `Average` | `Good` | `Best`.
	     */
	    rating: string;
	}

}
declare module Coveo {
	/**
	 * Describe a request to list the possible values of a field.
	 */
	interface IListFieldValuesRequest {
	    /**
	     * The field for which to list values
	     */
	    field: string;
	    /**
	     * The lookup field to use
	     */
	    lookupField?: string;
	    /**
	     * Whether to ignore accents in the values
	     */
	    ignoreAccents?: boolean;
	    /**
	     * The sort order for the returned field.
	     */
	    sortCriteria?: string;
	    /**
	     * Maximum number of field values to return
	     */
	    maximumNumberOfValues?: number;
	    /**
	     * A query to execute when returning possible field values
	     */
	    queryOverride?: string;
	    /**
	     * A query to execute when returning possible field values, put in cache in the index
	     */
	    constantQueryOverride?: string;
	    /**
	     * A pattern to filter out results
	     */
	    pattern?: string;
	    /**
	     * The type of the pattern (eg: regex)
	     */
	    patternType?: string;
	}
	/**
	 * Describe a request to list the possible values of multiple fields.
	 */
	interface IListFieldValuesBatchRequest {
	    /**
	     * The list of fields to request.
	     */
	    batch: IListFieldValuesRequest[];
	}
	interface IFieldValueBatchResponse {
	    batch: IIndexFieldValue[][];
	}

}
declare module Coveo {
	interface ISentryLog {
	    level?: 'WARNING' | 'INFO' | 'DEBUG' | 'FATAL';
	    message: string;
	    title: string;
	}

}
declare module Coveo {
	/**
	 * The facet types against which facet search is allowed.
	 */
	enum FacetSearchType {
	    /**
	     * Search among specific (i.e., scalar) facet values (e.g., Alice Smith, Bob Jones, etc.).
	     */
	    specific,
	    /**
	     * Search among hierarchical facet values (e.g., Electronics|Entertainment|Gaming Consoles;, Electronics|Computers|Laptops;, etc.).
	     */
	    hierarchical,
	}
	/**
	 * A Search API facet search request.
	 */
	interface IFacetSearchRequest {
	    /**
	     * The name of the field against which to execute the facet search request.
	     */
	    field: string;
	    /**
	     * Whether to exclude folded result parents when estimating result counts for facet values.
	     *
	     * **Note:** The target folding field must be a facet field with the **Use cache for nested queries** options enabled (see [Add or Edit a Field](https://docs.coveo.com/en/1982)).
	     *
	     * See also the [`Folding`]{@link Folding} and [`FoldingForThread`]{@link FoldingForThread} components.
	     *
	     * **Default:** `true`.
	     *
	     * @availablesince [March 2020 Release (v2.8521)](https://docs.coveo.com/en/3203/)
	     */
	    filterFacetCount: boolean;
	    /**
	     * The kind of facet values against which the search request is being made.
	     *
	     * **Default:** `specific`
	     */
	    type?: FacetSearchType;
	    /**
	     * A list of index field values to filter out from the facet search results.
	     *
	     * **Example:** `["blue", "green"]`
	     */
	    ignoreValues?: String[];
	    /**
	     * A list of paths to filter out from the hierarchical facet search results.
	     *
	     * **Example:** `[["Electronics", "Entertainment", "Gaming Consoles"],["Appliances", "Kitchen"]]`
	     */
	    ignorePaths?: String[][];
	    /**
	     * The maximum number of facet values to fetch.
	     *
	     * **Default (Search API):** `10`
	     */
	    numberOfValues?: number;
	    /**
	     * The string to match.
	     *
	     * Typically, the text entered by the end-user in the facet search box, to which one or more wildcard characters (`*`) may be added.
	     *
	     * **Example:** `"*oran*"`
	     */
	    query?: string;
	    /**
	     * A dictionary that maps index field values to facet value display names.
	     *
	     * **Example**
	     * > `{"acme_productA": "ACME Product A", "acme_productB": "ACME Product B"}`
	     */
	    captions?: any;
	    /**
	     * The query parameters representing the current state of the search interface.
	     *
	     * See the [query]{@link IQuery} documentation.
	     */
	    searchContext?: IQuery;
	    /**
	     * The character to use to split field values into a hierarchical sequence.
	     *
	     * **Example:**
	     *
	     * For a multi-value field containing the following values:
	     * ```
	     * c; c>folder2; c>folder2>folder3;
	     * ```
	     * The delimiting character is `>`.
	     *
	     * For a hierarchical field containing the following values:
	     * ```
	     * c;folder2;folder3;
	     * ```
	     * The delimiting character is `;`.
	     *
	     * **Default:** `;`
	     */
	    delimitingCharacter?: string;
	    /**
	     * The base path shared by all values for the facet.
	     *
	     * **Note:** This parameter has no effect unless the facet `type` is `hierarchical`.
	     */
	    basePath?: string[];
	}

}
declare module Coveo {
	interface IFacetSearchResultValue {
	    /**
	     * The custom facet value display name, as specified in the `captions` argument of the facet request.
	     *
	     * **Example:** `ACME Product A`
	     */
	    displayValue: string;
	    /**
	     * The hierarchical path to the value.
	     * **Note:** This property is only defined when the facet search request was made against hierarchical values.
	     */
	    path: string[];
	    /**
	     * The original facet value, as retrieved from the field in the index.
	     *
	     * **Example:** `acme_productA`
	     */
	    rawValue: string;
	    /**
	     * An estimate number of result items matching both the current query and
	     * the filter expression that would get generated if the facet value were selected.
	     */
	    count: number;
	}
	/**
	 * A Search API facet search response.
	 */
	interface IFacetSearchResponse {
	    /**
	     * The facet values.
	     */
	    values: IFacetSearchResultValue[];
	    /**
	     * Whether additional facet values matching the request are available.
	     */
	    moreValuesAvailable: boolean;
	}

}
declare module Coveo {
	/**
	 * Describes the plan of execution of a search request.
	 */
	interface IPlanResponse {
	    /**
	     * The output that would be included by the Search API in the query response
	     * once the search request has been fully processed by the query pipeline.
	     */
	    preprocessingOutput: {
	        /**
	         * The query response output generated by _trigger_ rules in the query
	         * pipeline (i.e., by `execute`, `notify`, `query`, and `redirect` rules).
	         */
	        triggers: ITrigger<any>[];
	    };
	    /**
	     * The query expressions that would be sent to the index once the search
	     * request has been fully processed by the query pipeline.
	     */
	    parsedInput: {
	        /**
	         * The final basic query expression (`q`).
	         */
	        basicExpression: string;
	        /**
	         * The final large query expression (`lq`).
	         */
	        largeExpression: string;
	    };
	}
	/**
	 * The plan of execution of a search request.
	 */
	class ExecutionPlan {
	    constructor(response: IPlanResponse);
	    /**
	     * Gets the final value of the basic expression (`q`) after the search request has been processed in the query pipeline, but before it is sent to the index.
	     */
	     basicExpression: string;
	    /**
	     * Gets the final value of the large expression (`lq`) after the search request has been processed in the query pipeline, but before it is sent to the index.
	     */
	     largeExpression: string;
	    /**
	     * Gets the URL to redirect the browser to, if the search request satisfies the condition of a `redirect` trigger rule in the query pipeline.
	     *
	     * Returns `null` otherwise.
	     */
	     redirectionURL: string;
	}

}
declare module Coveo {
	class SearchEndpointWithDefaultCallOptions implements ISearchEndpoint {
	    options: ISearchEndpointOptions;
	    constructor(endpoint: ISearchEndpoint, callOptions?: IEndpointCallOptions);
	     accessToken: AccessToken;
	    getBaseUri(): string;
	    getBaseAlertsUri(): string;
	    getAuthenticationProviderUri(provider: string, returnUri: string, message: string): string;
	    isJsonp(): boolean;
	    search(query: IQuery, callOptions?: IEndpointCallOptions): Promise<IQueryResults>;
	    fetchBinary(query: IQuery, callOptions?: IEndpointCallOptions): Promise<ArrayBuffer>;
	    plan(query: IQuery, callOptions?: IEndpointCallOptions): Promise<ExecutionPlan>;
	    getExportToExcelLink(query: IQuery, numberOfResults: number, callOptions?: IEndpointCallOptions): string;
	    tagDocument(taggingRequest: ITaggingRequest, callOptions?: IEndpointCallOptions): Promise<boolean>;
	    getQuerySuggest(request: IQuerySuggestRequest, callOptions?: IEndpointCallOptions): Promise<IQuerySuggestResponse>;
	    facetSearch(request: IFacetSearchRequest, callOptions?: IEndpointCallOptions): Promise<IFacetSearchResponse>;
	    rateDocument(ratingRequest: IRatingRequest, callOptions?: IEndpointCallOptions): Promise<boolean>;
	    getRawDataStream(documentUniqueId: string, dataStreamType: string, callOptions?: IViewAsHtmlOptions): Promise<ArrayBuffer>;
	    getDocument(documentUniqueId: string, callOptions?: IGetDocumentOptions): Promise<IQueryResult>;
	    getDocumentText(documentUniqueID: string, callOptions?: IEndpointCallOptions): Promise<string>;
	    getDocumentHtml(documentUniqueID: string, callOptions?: IViewAsHtmlOptions): Promise<HTMLDocument>;
	    getViewAsHtmlUri(documentUniqueID: string, callOptions?: IViewAsHtmlOptions): string;
	    getViewAsDatastreamUri(documentUniqueID: string, dataStreamType: string, callOptions?: IViewAsHtmlOptions): string;
	    listFieldValuesBatch(request: IListFieldValuesBatchRequest, callOptions?: IEndpointCallOptions): Promise<IIndexFieldValue[][]>;
	    listFieldValues(request: IListFieldValuesRequest, callOptions?: IEndpointCallOptions): Promise<IIndexFieldValue[]>;
	    listFields(callOptions?: IEndpointCallOptions): Promise<IFieldDescription[]>;
	    extensions(callOptions?: IEndpointCallOptions): Promise<IExtension[]> | Promise<IEndpointError>;
	    follow(request: ISubscriptionRequest): Promise<ISubscription>;
	    listSubscriptions(page: number): Promise<ISubscription[]>;
	    updateSubscription(subscription: ISubscription): Promise<ISubscription>;
	    deleteSubscription(subscription: ISubscription): Promise<ISubscription>;
	    logError(sentryLog: ISentryLog): Promise<boolean>;
	    exchangeHandshakeToken(options: IExchangeHandshakeTokenOptions): Promise<string>;
	}

}
declare module Coveo {
	/// <reference types="coveoanalytics" />
	/**
	 * Possible options when performing a query with the query controller
	 */
	interface IQueryOptions {
	    /**
	     * If the analytics component is enabled in the interface, it will look for any query executed by the query controller for which no analytics event was associated.<br/>
	     * By setting this property to true, this will cancel this check when the query is performed
	     */
	    ignoreWarningSearchEvent?: boolean;
	    /**
	     * Whether the query to execute is a search-as-you-type. This information will be passed down in the query events for component and external code to determine their behavior
	     */
	    searchAsYouType?: boolean;
	    /**
	     * Specify a function that you wish to execute just before the query is executed
	     */
	    beforeExecuteQuery?: () => void;
	    /**
	     * Cancel the query
	     */
	    cancel?: boolean;
	    /**
	     * The component from which the query originated. For example the pager will set the property to tweak it's behaviour
	     */
	    origin?: any;
	    /**
	     * Whether or not to log the query in the user actions history when using the page view script: https://github.com/coveo/coveo.analytics.js.
	     * Only the 'q' part of the query will be logged.
	     * This option is useful, because it prevents the query to be logged twice when a {@link Recommendation} component is present.
	     * It also makes sure that only relevant queries are logged. For exemple, the 'empty' interface load query isn't logged.
	     */
	    logInActionsHistory?: boolean;
	    isFirstQuery?: boolean;
	    keepLastSearchUid?: boolean;
	    closeModalBox?: boolean;
	    shouldRedirectStandaloneSearchbox?: boolean;
	}
	/**
	 * This class is automatically instantiated and bound to the root of your search interface when you initialize the framework.<br/>
	 * It is essentially a singleton that wraps the access to the {@link SearchEndpoint} endpoint to execute query, and is in charge of triggering the different query events.<br/>
	 * This is what every component of the framework uses internally to execute query or access the endpoint.<br/>
	 * When calling <code>Coveo.executeQuery</code> this class is used.
	 */
	class QueryController extends RootComponent {
	    options: ISearchInterfaceOptions;
	    searchInterface: SearchInterface;
	    static ID: string;
	    historyStore: CoveoAnalytics.HistoryStore;
	    firstQuery: boolean;
	    modalBox: any;
	    closeModalBox: boolean;
	    /**
	     * Create a new query controller
	     * @param element
	     * @param options
	     * @param usageAnalytics **Deprecated.** Since the [October 2019 Release (v2.7219)](https://docs.coveo.com/en/3084/), the class retrieves and uses the {@link AnalyticsClient} from its `searchInterface` constructor parameter.
	     * @param searchInterface
	     */
	    constructor(element: HTMLElement, options: ISearchInterfaceOptions, usageAnalytics: IAnalyticsClient, searchInterface: SearchInterface);
	     usageAnalytics: IAnalyticsClient;
	    /**
	     * Set the {@link SearchEndpoint} that the query controller should use to execute query
	     * @param endpoint
	     */
	    setEndpoint(endpoint: SearchEndpoint): void;
	    /**
	     * Get the {@link SearchEndpoint} that is currently used by the query controller to execute query
	     * @returns {SearchEndpoint}
	     */
	    getEndpoint(): ISearchEndpoint;
	    /**
	     * Return the last query that was performed by the query controller
	     * @returns {IQuery|Query}
	     */
	    getLastQuery(): IQuery;
	    /**
	     * Return the last query results set.
	     * @returns {IQueryResults}
	     */
	    getLastResults(): IQueryResults;
	    /**
	     * Returns the plan of execution of a search request, without executing it.
	     * @returns {ExecutionPlan}
	     */
	    fetchQueryExecutionPlan(): Promise<ExecutionPlan>;
	    /**
	     * Execute a query and return a Promise of IQueryResults.<br/>
	     * This will execute the normal query flow, triggering all the necessary query events (newQuery <br/>
	     * All components present in the interface will act accordingly (modify the query and render results if needed).
	     * @param options
	     * @returns {Promise<IQueryResults>}
	     */
	    executeQuery(options?: IQueryOptions): Promise<IQueryResults>;
	    /**
	     * Using the same parameters as the last successful query, fetch another batch of results. Particularly useful for infinite scrolling, for example.
	     * @param count
	     * @returns {any}
	     */
	    fetchMore(count: number): Promise<IQueryResults>;
	    /**
	     * Cancel any pending query
	     */
	    cancelQuery(): void;
	    deferExecuteQuery(options?: IQueryOptions): void;
	    ensureCreatedQueryBuilder(): void;
	    createQueryBuilder(options: IQueryOptions): QueryBuilder;
	    isStandaloneSearchbox(): boolean;
	    saveLastQuery(): void;
	    getLastQueryHash(): string;
	    resetHistory(): void;
	    enableHistory(): void;
	    disableHistory(): void;
	    debugInfo(): any;
	}

}
declare module Coveo {
	/**
	 * This component is instantiated automatically by the framework on the root if the {@link SearchInterface}.<br/>
	 * When the {@link SearchInterface.options.enableHistory} option is set to true, this component is instantiated.<br/>
	 * It's only job is to apply changes in the {@link QueryStateModel} to the hash in the URL, and vice versa.<br/>
	 * This component does *not* hold the state of the interface, it only represent it in the URL.
	 */
	class HistoryController extends RootComponent implements IHistoryManager {
	    window: Window;
	    queryStateModel: QueryStateModel;
	    queryController: QueryController;
	    static ID: string;
	    static attributesThatDoNotTriggerQuery: string[];
	    /**
	     * Create a new HistoryController
	     * @param element
	     * @param window
	     * @param queryStateModel
	     * @param queryController
	     * @param usageAnalytics **Deprecated.** Since the [October 2019 Release (v2.7219)](https://docs.coveo.com/en/3084/), the class retrieves and uses the {@link AnalyticsClient} from the `queryController` constructor parameter.
	     */
	    constructor(element: HTMLElement, window: Window, queryStateModel: QueryStateModel, queryController: QueryController, usageAnalytics?: IAnalyticsClient);
	     usageAnalytics: IAnalyticsClient;
	    hashUtils: typeof HashUtils;
	    setState(state: any): void;
	    replaceState(state: any): void;
	    /**
	     * Set the given map of key value in the hash of the URL
	     * @param values
	     */
	    setHashValues(values: any): void;
	    debugInfo(): {
	        state: {
	            [key: string]: any;
	        };
	    };
	    handleHashChange(): void;
	}

}
declare module Coveo {
	class NoopHistoryController implements IHistoryManager {
	    setState(state: any): void;
	    replaceState(state: any): void;
	}

}
declare module Coveo {
	interface IResultListOptions {
	    resultsContainer?: HTMLElement;
	    resultTemplate?: Template;
	    resultOptions?: {};
	    waitAnimationContainer?: HTMLElement;
	    enableInfiniteScroll?: boolean;
	    infiniteScrollPageSize?: number;
	    infiniteScrollContainer?: HTMLElement | Window;
	    waitAnimation?: string;
	    mobileScrollContainer?: HTMLElement;
	    enableInfiniteScrollWaitingAnimation?: boolean;
	    fieldsToInclude?: IFieldOption[];
	    autoSelectFieldsToInclude?: boolean;
	    layout?: string;
	    enableScrollToTop?: boolean;
	}

}
declare module Coveo {
	class QuerySummaryUtils {
	    static message(root: HTMLElement, data: IQuerySuccessEventArgs): string;
	    static htmlMessage(root: HTMLElement, data: IQuerySuccessEventArgs): string;
	    static replaceQueryTags(template: string, replacement: string): string;
	}

}
declare module Coveo {
	interface IAriaLive {
	    updateText: (text: string) => void;
	}
	class AriaLive implements IAriaLive {
	    constructor(root: HTMLElement);
	    updateText(text: string): void;
	}

}
declare module Coveo {
	interface IComponentsTypesSearchInterface {
	    getComponents: (type: string) => Component[];
	}
	class ComponentsTypes {
	    static  allFacetsType: string[];
	    static  allFacetsClassname: string[];
	    static getAllFacetElementsFromElement(root: HTMLElement | Dom): HTMLElement[];
	    static getAllFacetInstancesFromElement(root: HTMLElement | Dom): Component[];
	    static getAllFacetsFromSearchInterface(searchInterface: IComponentsTypesSearchInterface): Component[];
	}

}
declare module Coveo {
	interface InitializationPlaceholderOption {
	    searchInterface?: boolean;
	    facet?: boolean;
	    searchbox?: boolean;
	    resultList?: boolean;
	    layout?: string;
	    waitingForFirstQueryMode?: boolean;
	}
	class InitializationPlaceholder {
	    root: HTMLElement;
	    facetPlaceholder: string;
	    resultListPlaceholder: string;
	    cardResultListPlaceholder: string;
	    recommendationResultListPlaceholder: string;
	    static NUMBER_OF_FACETS: number;
	    static NUMBER_OF_RESULTS: number;
	    static NUMBER_OF_RESULTS_RECOMMENDATION: number;
	    static INITIALIZATION_CLASS: string;
	    static AFTER_INITIALIZATION_CLASS: string;
	    constructor(root: HTMLElement);
	    withEventToRemovePlaceholder(event: string): this;
	    withFullInitializationStyling(): this;
	    withHiddenRootElement(): this;
	    withVisibleRootElement(): this;
	    withWaitingForFirstQueryMode(): this;
	    withAllPlaceholders(): this;
	    withPlaceholderForFacets(): this;
	    withPlaceholderSearchbox(): this;
	    withPlaceholderForResultList(): this;
	}

}
declare module Coveo {
	/**
	 * A checkbox widget with standard styling.
	 */
	class Checkbox implements IFormWidgetWithLabel, IFormWidgetSelectable {
	    onChange: (checkbox: Checkbox) => void;
	    label: string;
	    ariaLabel: string;
	    labelSuffix: string;
	    protected element: HTMLElement;
	    protected checkbox: HTMLInputElement;
	    static doExport: () => void;
	    /**
	     * Creates a new `Checkbox`.
	     * @param onChange The function to call when the checkbox state changes. This function takes the current `Checkbox`
	     * instance as an argument.
	     * @param label The label to display next to the checkbox.
	     */
	    constructor(onChange: (checkbox: Checkbox) => void, label: string, ariaLabel?: string, labelSuffix?: string);
	    /**
	     * Toggles the checkbox state.
	     */
	    toggle(): void;
	    /**
	     * Gets the element on which the checkbox is bound.
	     * @returns {HTMLElement} The checkbox element.
	     */
	    getElement(): HTMLElement;
	    /**
	     * Gets the element on which the checkbox is bound.
	     * @returns {HTMLElement} The checkbox element.
	     */
	    build(): HTMLElement;
	    /**
	     * Gets the checkbox [`label`]{@link Checkbox.label} value.
	     * @returns {string} The checkbox label value.
	     */
	    getValue(): string;
	    /**
	     * Resets the checkbox.
	     */
	    reset(): void;
	    /**
	     * Select the checkbox
	     * @param triggerChange will trigger change even if specified and not already selected
	     */
	    select(triggerChange?: boolean): void;
	    /**
	     * Indicates whether the checkbox is checked.
	     * @returns {boolean} `true` if the checkbox is checked, `false` otherwise.
	     */
	    isSelected(): boolean;
	    /**
	     * Gets the element on which the checkbox [`label`]{@link Checkbox.label} is bound.
	     * @returns {HTMLElement} The `label` element.
	     */
	    getLabel(): HTMLElement;
	}

}
declare module Coveo {
	class DebugHeader {
	    debugInstance: Debug;
	    element: HTMLElement;
	    onSearch: (value: string) => void;
	    infoToDebug: any;
	    constructor(debugInstance: Debug, element: HTMLElement, onSearch: (value: string) => void, infoToDebug: any);
	    moveTo(newElement: HTMLElement): void;
	    setSearch(onSearch: (value: string) => void): void;
	    setNewInfoToDebug(newInfoToDebug: any): void;
	}

}
declare module Coveo {
	class DebugForResult {
	    bindings: IComponentBindings;
	    constructor(bindings: IComponentBindings);
	    generateDebugInfoForResult(result: IQueryResult): {
	        result: IQueryResult;
	        fields: () => Promise<{}>;
	        rankingInfo: () => {};
	    };
	}

}
declare module Coveo {
	interface IDebugOptions {
	    enableDebug?: boolean;
	}
	class Debug extends RootComponent {
	    element: HTMLElement;
	    bindings: IComponentBindings;
	    options: IDebugOptions;
	    ModalBox: any;
	    static ID: string;
	    static doExport: () => void;
	    static options: IDebugOptions;
	    static customOrder: string[];
	    static durationKeys: string[];
	    static maxDepth: number;
	    localStorageDebug: LocalStorageUtils<string[]>;
	    collapsedSections: string[];
	    showDebugPanel: () => void;
	    constructor(element: HTMLElement, bindings: IComponentBindings, options?: IDebugOptions, ModalBox?: any);
	    debugInfo(): any;
	    addInfoToDebugPanel(info: any): void;
	}

}
declare module Coveo {
	interface IBreadcrumbOptions {
	    headingLevel?: number;
	}
	/**
	 * The Breadcrumb component displays a summary of the currently active query filters.
	 *
	 * For example, when the user selects a {@link Facet} value, the breadcrumbs display this value.
	 *
	 * The active filters are obtained by the component by firing an event in the Breadcrumb component.
	 *
	 * All other components having an active state can react to this event by providing custom bits of HTML to display
	 * inside the breadcrumbs.
	 *
	 * Thus, it is possible to easily extend the Breadcrumb component using custom code to display information about custom
	 * states and filters.
	 *
	 * See {@link BreadcrumbEvents} for the list of events and parameters sent when a Breadcrumb component is populated.
	 */
	class Breadcrumb extends Component {
	    element: HTMLElement;
	    options: IBreadcrumbOptions;
	    static ID: string;
	    /**
	     * The options for the Breadcrumb.
	     * @componentOptions
	     */
	    static options: IBreadcrumbOptions;
	    static doExport: () => void;
	    /**
	     * Creates a new Breadcrumb component. Binds event on {@link QueryEvents.deferredQuerySuccess} to draw the
	     * breadcrumbs.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the Breadcrumb component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IBreadcrumbOptions, bindings?: IComponentBindings);
	    /**
	     * Triggers the event to populate the breadcrumbs. Components such as {@link Facet} can populate the breadcrumbs.
	     *
	     * This method triggers a {@link BreadcrumbEvents.populateBreadcrumb} event with an
	     * {@link IPopulateBreadcrumbEventArgs} object (an array) that other components or code can populate.
	     * @returns {IBreadcrumbItem[]} A populated breadcrumb item list.
	     */
	    getBreadcrumbs(): IBreadcrumbItem[];
	    /**
	     * Triggers the event to clear the current breadcrumbs that components such as {@link Facet} can populate.
	     *
	     * Also triggers a new query and logs the `breadcrumbResetAll` event in the usage analytics.
	     */
	    clearBreadcrumbs(): void;
	    /**
	     * Draws the specified breadcrumb items.
	     * @param breadcrumbs The breadcrumb items to draw.
	     */
	    drawBreadcrumb(breadcrumbs: IBreadcrumbItem[]): void;
	}

}
declare module Coveo {
	function getHeadingTag(level?: number, fallbackTag?: string): string;

}
declare module Coveo {
	class MissingTermManager {
	    static ID: string;
	    static wordBoundary: string;
	    constructor(args: IMissingTermManagerArgs);
	}

}
declare module Coveo {
	/// <reference types="map" />
	/// <reference types="lodash" />
	interface IAutoLayoutAdjustableInsideFacetColumn {
	    isCurrentlyDisplayed: () => boolean;
	}
	class FacetColumnAutoLayoutAdjustment {
	    static autoLayoutAdjustmentComponent: Map<HTMLElement, IAutoLayoutAdjustableInsideFacetColumn[]>;
	    static autoLayoutAdjustmentHandlers: Map<HTMLElement, () => void>;
	    static isAutoLayoutAdjustable(component: any): component is IAutoLayoutAdjustableInsideFacetColumn;
	    static initializeAutoLayoutAdjustment(root: HTMLElement, component: IAutoLayoutAdjustableInsideFacetColumn): void;
	}

}
declare module Coveo {
	class FacetValueStateHandler {
	    searchInterface: IComponentsTypesSearchInterface;
	    constructor(searchInterface: IComponentsTypesSearchInterface);
	    handleFacetValueState(stateToSet: any): void;
	}

}
declare module Coveo {
	interface IRankingInfo {
	    documentWeights: IListOfWeights;
	    totalWeight: number;
	    termsWeight: IListOfTermsWeights;
	    qreWeights: IListOfQRE[];
	}
	interface IListOfWeights {
	    Adjacency: number;
	    'Collaborative rating': number;
	    Custom: number;
	    Date: number;
	    QRE: number;
	    Quality: number;
	    'Ranking functions': number;
	    Source: number;
	    Title: number;
	    [key: string]: number;
	}
	interface IListOfQRE {
	    expression: string;
	    score: number;
	}
	type IListOfTermsWeights = any;
	interface IWeightsPerTerm {
	    Weights: IWeightsPerTermBreakdown;
	    terms: any;
	}
	interface IWeightsPerTermBreakdown {
	    Casing: number;
	    Concept: number;
	    Formatted: number;
	    Frequency: number;
	    Relation: number;
	    Summary: number;
	    Title: number;
	    URI: number;
	    [key: string]: number;
	}
	interface IWeightsPerTermPerDocument {
	    Correlation: number;
	    'TF-IDF': number;
	}

}
declare module Coveo {

}
declare module Coveo {
	class ResponsiveDefaultResultTemplate implements IResponsiveComponent {
	    coveoRoot: Dom;
	    ID: string;
	    static init(root: HTMLElement, component: ResultList, options: IResponsiveComponentOptions): void;
	    constructor(coveoRoot: Dom, ID: string, options: IResponsiveComponentOptions, responsiveDropdown?: ResponsiveDropdown);
	    registerComponent(accept: ResultList): boolean;
	    handleResizeEvent(): void;
	}

}
declare module Coveo {
	/**
	 * A class which holds information and operation available on a single facet value returned by a {@link IGroupByRequest}.<br/>
	 * This class is used extensively in the {@link Facet} component.
	 */
	class FacetValue {
	    value: string;
	    lookupValue: string;
	    occurrences: number;
	    computedField: number;
	    delta: number;
	    score: number;
	    selected: boolean;
	    excluded: boolean;
	    waitingForDelta: boolean;
	    reset(): void;
	    updateCountsFromNewValue(newValue: FacetValue): void;
	    clone(): FacetValue;
	    cloneWithZeroOccurrences(): FacetValue;
	    cloneWithDelta(count: number, delta: number): FacetValue;
	    getFormattedCount(): string;
	    getFormattedComputedField(format: string): any;
	    static create(value: any): FacetValue;
	    static createFromValue(value: string): FacetValue;
	    static createFromGroupByValue(groupByValue: IGroupByValue): FacetValue;
	    static createFromFieldValue(fieldValue: IIndexFieldValue): FacetValue;
	}

}
declare module Coveo {
	/// <reference path="Facet.d.ts" />
	class FacetSearchParameters {
	    facet: Facet;
	    nbResults: number;
	    ignoreAccents: boolean;
	    valueToSearch: string;
	    alwaysInclude: string[];
	    alwaysExclude: string[];
	    sortCriteria: string;
	    fetchMore: boolean;
	    completeFacetWithStandardValues: boolean;
	    constructor(facet: Facet);
	    setValueToSearch(value: string): this;
	    excludeCurrentlyDisplayedValuesInSearch(searchResults: HTMLElement): void;
	    getGroupByRequest(): IGroupByRequest;
	    getQuery(): IQuery;
	}

}
declare module Coveo {
	/// <reference path="../ui/Facet/Facet.d.ts" />
	class FacetQueryController {
	    facet: Facet;
	    expressionToUseForFacetSearch: string;
	    basicExpressionToUseForFacetSearch: string;
	    advancedExpressionToUseForFacetSearch: string;
	    constantExpressionToUseForFacetSearch: string;
	    lastGroupByRequestIndex: number;
	    lastGroupByRequest: IGroupByRequest;
	    lastGroupByResult: IGroupByResult;
	    constructor(facet: Facet);
	    /**
	     * Reset the expression for the facet search, used when a new query is triggered
	     */
	    prepareForNewQuery(): void;
	    /**
	     * Compute the filter expression that the facet needs to output for the query
	     * @returns {string}
	     */
	    computeOurFilterExpression(): string;
	    /**
	     * Build the group by request for the facet, and insert it in the query builder
	     * @param queryBuilder
	     */
	    putGroupByIntoQueryBuilder(queryBuilder: QueryBuilder): void;
	    /**
	     * Search inside the facet, using a group by request
	     * @param params
	     * @param oldLength Optional params, used by the search method to call itself recursively to fetch all required values
	     * @returns {Promise|Promise<T>}
	     */
	    search(params: FacetSearchParameters, oldLength?: number): Promise<IIndexFieldValue[]>;
	    fetchMore(numberOfValuesToFetch: number): Promise<IQueryResults>;
	    searchInFacetToUpdateDelta(facetValues: FacetValue[]): Promise<IQueryResults>;
	    protected createGroupByAllowedValues(): string[];
	    protected createBasicGroupByRequest(allowedValues?: string[], addComputedField?: boolean): IGroupByRequest;
	    protected getAllowedValuesFromSelected(): FacetValue[];
	}

}
declare module Coveo {
	interface IDependsOnCompatibleFacetOptions {
	    id?: string;
	    dependsOn?: string;
	    dependsOnCondition?: IDependentFacetCondition;
	}
	interface IDependsOnCompatibleFacet extends Component {
	    options: IDependsOnCompatibleFacetOptions;
	}
	interface IDependentFacet {
	    reset: () => void;
	    ref: IDependsOnCompatibleFacet;
	}
	interface IDependentFacetCondition {
	    (facet: IDependsOnCompatibleFacet): boolean;
	}
	class DependsOnManager {
	    constructor(facet: IDependentFacet);
	     hasDependentFacets: boolean;
	     dependentFacetsHaveSelectedValues: boolean;
	}

}
declare module Coveo {
	/**
	 * ResponsiveFacets options
	 */
	const ResponsiveFacetOptions: {
	    enableResponsiveMode: boolean;
	    responsiveBreakpoint: number;
	    dropdownHeaderLabel: string;
	};

}
declare module Coveo {
	interface FocusTrapOptions {
	    focusableSelector: string;
	}
	class FocusTrap {
	    constructor(container: HTMLElement, options?: FocusTrapOptions);
	    disable(): void;
	}

}
declare module Coveo {
	class ResponsiveDropdownModalContent implements IResponsiveDropdownContent {
	    element: Dom;
	    constructor(componentName: string, element: Dom, closeButtonLabel: string, close: () => void);
	    positionDropdown(): void;
	    hideDropdown(): void;
	    cleanUp(): void;
	}

}
declare module Coveo {
	interface IFacetsMobileModeConstructor {
	    new (element: HTMLElement, options: IFacetsMobileModeOptions, bindings: IComponentBindings): FacetsMobileMode;
	}
	interface IFacetsMobileModeOptions {
	    breakpoint?: number;
	    isModal?: boolean;
	    displayOverlayWhileOpen?: boolean;
	    preventScrolling?: boolean;
	    scrollContainer?: HTMLElement;
	}
	/**
	 * This component lets you customize the mobile responsive behavior of facets in your search interface.
	 *
	 * **Notes:**
	 * - You can include this component anywhere under the root element of your search interface.
	 * - You should only include this component once in your search interface.
	 */
	class FacetsMobileMode extends Component {
	    element: HTMLElement;
	    static ID: string;
	    /**
	     * @componentOptions
	     */
	    static options: IFacetsMobileModeOptions;
	    static doExport: () => void;
	    options: IFacetsMobileModeOptions;
	    constructor(element: HTMLElement, options?: IFacetsMobileModeOptions, bindings?: IComponentBindings);
	}

}
declare module Coveo {
	/**
	 * The names of the events that can be triggered by the [FacetsMobileMode]{@link FacetsMobileMode} component.
	 */
	class FacetsMobileModeEvents {
	    /**
	     * The name of the event that gets triggered when the facets pop-up (or modal) is opened in mobile mode.
	     */
	    static popupOpened: string;
	    /**
	     * The name of the event that gets triggered when the facets pop-up (or modal) is closed in mobile mode.
	     */
	    static popupClosed: string;
	}

}
declare module Coveo {
	class ResponsiveFacetColumn implements IResponsiveComponent {
	    coveoRoot: Dom;
	    ID: string;
	    static DEBOUNCE_SCROLL_WAIT: number;
	    protected dropdown: ResponsiveDropdown;
	    static init(responsiveComponentConstructor: any, root: HTMLElement, component: any, options: IResponsiveComponentOptions, ID: string): void;
	    constructor(coveoRoot: Dom, ID: string, options: IResponsiveComponentOptions, responsiveDropdown?: ResponsiveDropdown);
	    registerComponent(accept: Component): boolean;
	    needDropdownWrapper(): boolean;
	    handleResizeEvent(): void;
	    dismissFacetSearches(): void;
	}

}
declare module Coveo {
	class ResponsiveFacets extends ResponsiveFacetColumn {
	    static init(root: HTMLElement, component: any, options: IResponsiveComponentOptions): void;
	}

}
declare module Coveo {
	/// <reference path="Facet.d.ts" />
	interface IBreadcrumbValueElementKlass {
	    new (facet: Facet, facetValue: FacetValue): BreadcrumbValueElement;
	}
	class BreadcrumbValueElement {
	    facet: Facet;
	    facetValue: FacetValue;
	    constructor(facet: Facet, facetValue: FacetValue);
	    build(): Dom;
	    getBreadcrumbTooltip(): string;
	}

}
declare module Coveo {
	interface IBreadcrumbValueListOptions {
	    headingLevel?: number;
	}
	class BreadcrumbValueList {
	    facet: Facet;
	    facetValues: FacetValue[];
	    breadcrumbValueElementKlass: IBreadcrumbValueElementKlass;
	    protected elem: HTMLElement;
	    constructor(facet: Facet, facetValues: FacetValue[], breadcrumbValueElementKlass: IBreadcrumbValueElementKlass, options?: IBreadcrumbValueListOptions);
	    build(): HTMLElement;
	    buildAsString(): string;
	}

}
declare module Coveo {
	/// <reference path="../ui/FacetSlider/FacetSlider.d.ts" />
	class FacetSliderQueryController {
	    facet: FacetSlider;
	    graphGroupByQueriesIndex: number;
	    lastGroupByRequestIndex: number;
	    lastGroupByRequestForFullRangeIndex: number;
	    constructor(facet: FacetSlider);
	    prepareForNewQuery(): void;
	    putGroupByIntoQueryBuilder(queryBuilder: QueryBuilder): void;
	    computeOurFilterExpression(boundary?: number[]): string;
	}

}
declare module Coveo {
	interface IStartSlideEventArgs {
	    slider: Slider;
	    button: SliderButton;
	}
	interface IDuringSlideEventArgs {
	    slider: Slider;
	    button: SliderButton;
	}
	interface IEndSlideEventArgs {
	    slider: Slider;
	    button: SliderButton;
	}
	interface ISliderGraphData {
	    start: any;
	    y: number;
	    end: any;
	    isDate?: boolean;
	}
	interface ISliderOptions {
	    start?: any;
	    end?: any;
	    excludeOuterBounds?: boolean;
	    steps?: number;
	    getSteps?: (start: number, end: number) => number[];
	    rangeSlider?: boolean;
	    displayAsValue?: {
	        enable?: boolean;
	        unitSign?: string;
	        separator?: string;
	    };
	    displayAsPercent?: {
	        enable?: boolean;
	        separator?: string;
	    };
	    valueCaption?: (values: number[]) => string;
	    percentCaption?: (percent: number[]) => string;
	    dateFormat?: string;
	    document?: Document;
	    graph?: {
	        steps?: number;
	        animationDuration?: number;
	        margin?: {
	            top?: number;
	            bottom?: number;
	            left?: number;
	            right?: number;
	        };
	    };
	    dateField?: boolean;
	    rounded?: number;
	}
	class Slider {
	    element: HTMLElement;
	    options: ISliderOptions;
	    root: HTMLElement;
	    steps: number[];
	    currentValues: number[];
	    constructor(element: HTMLElement, options: ISliderOptions, root: HTMLElement);
	    onMoving(): void;
	    initializeState(values?: number[]): void;
	    getPosition(): number[];
	    getPercentPosition(): number[];
	    getValues(): any[];
	    getCaptionFromValue(values: number[]): string;
	    getCaption(): string;
	    setValues(values: number[]): void;
	    drawGraph(data?: ISliderGraphData[]): void;
	}
	class SliderButton {
	    slider: Slider;
	    leftBoundary: number;
	    rightBoundary: number;
	    element: HTMLElement;
	    constructor(slider: Slider, which: number);
	    build(): HTMLElement;
	    toBeginning(): void;
	    toEnd(): void;
	    setValue(value: number): void;
	    getPosition(): number;
	    getPercent(position?: number): number;
	    getValue(): any;
	    fromValueToPercent(value: number): number;
	    fromPositionToValue(position: number): any;
	    fromValueToPosition(value: number): number;
	}

}
declare module Coveo {
	class ResponsiveFacetSlider extends ResponsiveFacetColumn {
	    coveoRoot: Dom;
	    ID: string;
	    static init(root: HTMLElement, component: any, options: IResponsiveComponentOptions): void;
	    constructor(coveoRoot: Dom, ID: string, options: IResponsiveComponentOptions, responsiveDropdown?: ResponsiveDropdown);
	    registerComponent(accept: Component): boolean;
	    drawFacetSliderGraphs(): void;
	}

}
declare module Coveo {
	/// <reference path="../Facet/FacetHeader.d.ts" />
	/// <reference path="../../controllers/FacetSliderQueryController.d.ts" />
	interface IFacetSliderOptions extends ISliderOptions, IResponsiveComponentOptions {
	    dateField?: boolean;
	    queryOverride?: IQueryExpression;
	    id?: string;
	    field?: IFieldOption;
	    title?: string;
	}
	/**
	 * The `FacetSlider` component creates a facet which contains a slider widget that allows the end user to filter results
	 * based on a range of numerical values (e.g., a date range, a price range, etc.).
	 *
	 * **Note:**
	 * > This component does **not** inherit from the [`Facet`]{@link Facet} component. Consequently, it does not offer the
	 * > same configuration options. Moreover, some of the `FacetSlider` options (see
	 * > [`getSteps`]{@link FacetSlider.options.getSteps} and [`valueCaption`]{@link FacetSlider.options.valueCaption})
	 * > cannot be configured as `data-` attributes in the markup. If you wish to configure those options, you must either
	 * > do so in the [`init`]{@link init} call of your search interface (see
	 * > [Passing Component Options in the init Call](https://docs.coveo.com/en/346/#passing-component-options-in-the-init-call)),
	 * > or before the `init` call, using the `options` top-level function (see
	 * > [Passing Component Options Before the init Call](https://docs.coveo.com/en/346/#passing-component-options-before-the-init-call)).
	 * @notSupportedIn salesforcefree
	 */
	class FacetSlider extends Component {
	    element: HTMLElement;
	    options: IFacetSliderOptions;
	    /**
	     * The component options
	     * @componentOptions
	     */
	    static options: IFacetSliderOptions;
	    static ID: string;
	    static doExport: () => void;
	    static DEBOUNCED_RESIZE_DELAY: number;
	    startOfSlider: number;
	    endOfSlider: number;
	    initialStartOfSlider: number;
	    initialEndOfSlider: number;
	    facetQueryController: FacetSliderQueryController;
	    facetHeader: FacetHeader;
	    onResize: EventListener;
	    isSimpleSliderConfig: boolean;
	    isFieldValueCompatible: boolean;
	    /**
	     * Creates a new `FacetSlider` component. Binds multiple query events as well.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `FacetSlider` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param slider
	     */
	    constructor(element: HTMLElement, options: IFacetSliderOptions, bindings?: IComponentBindings, slider?: Slider);
	    isCurrentlyDisplayed(): boolean;
	    createDom(): void;
	    /**
	     * Resets the `FacetSlider` (meaning that you need to set the range value as inactive).
	     */
	    reset(): void;
	    /**
	     * Gets the current selection in the slider.
	     *
	     * **Note:**
	     * > This method returns an array of number for selected date values. These numbers represent a number of milliseconds
	     * > before or after January 1, 1970. Therefore, you can use these numbers to instantiate standard JavaScript Date
	     * > objects.
	     *
	     * @returns {any} An array of number containing the first and last selected values, if possible. An array containing
	     * two `any` values otherwise.
	     */
	    getSelectedValues(): number[];
	    /**
	     * Sets the selected values in the slider.
	     *
	     * **Note:**
	     * > You must set date values with numbers representing a number of milliseconds before or after January 1, 1970. You
	     * > can easily extract such numbers from standard JavaScript Date objects.
	     *
	     * @param values [start, end] An array containing the first and last values to select in the slider.
	     */
	    setSelectedValues(values: number[]): void;
	    /**
	     * Indicates whether the `FacetSlider` is active. An active `FacetSlider` outputs an expression in the query when a
	     * search is performed.
	     * @returns {boolean} `true` if the FacetSlider is active; `false` otherwise.
	     */
	    isActive(): boolean;
	    getSliderBoundaryForQuery(): number[];
	    drawDelayedGraphData(): void;
	    hasAGraph(): boolean;
	}

}
declare module Coveo {
	/// <reference path="Facet.d.ts" />
	/// <reference path="FacetSettings.d.ts" />
	interface IFacetSortKlass {
	    new (sorts: string[], facet: Facet): FacetSort;
	}
	interface IFacetSortDescription {
	    label: string;
	    directionToggle: boolean;
	    description: string;
	    name: string;
	    relatedSort?: string;
	}
	class FacetSort {
	    facet: Facet;
	    static availableSorts: {
	        [name: string]: IFacetSortDescription;
	    };
	    enabledSorts: IFacetSortDescription[];
	    activeSort: IFacetSortDescription;
	    customSortDirection: string;
	    constructor(sorts: string[], facet: Facet);
	}

}
declare module Coveo {
	interface IFacetSettingsKlass {
	    new (sorts: string[], facet: Facet): FacetSettings;
	}
	interface IFacetState {
	    included: string[];
	    excluded: string[];
	    operator: string;
	}
	/**
	 * Handle the rendering of the {@link Facet} settings menu (typically the ... in the facet header).
	 */
	class FacetSettings extends FacetSort {
	    sorts: string[];
	    facet: Facet;
	    loadedFromSettings: {
	        [attribute: string]: any;
	    };
	    settingsButton: HTMLElement;
	    settingsPopup: HTMLElement;
	    constructor(sorts: string[], facet: Facet);
	    /**
	     * Build the menu, hook click events.
	     * @returns {HTMLElement}
	     */
	    build(): HTMLElement;
	    /**
	     * Restore the facet state from local storage, and apply it in the query state model.
	     */
	    loadSavedState(): void;
	    /**
	     * Take the current state of the facet and save it in the local storage.
	     */
	    saveState(): void;
	    /**
	     * Close the settings menu
	     */
	    close(): void;
	    /**
	     * Open the settings menu
	     */
	    open(): void;
	    getSortItem(sortName: string): HTMLElement;
	     button: HTMLElement;
	    getCurrentDirectionItem(directionSection?: HTMLElement[]): HTMLElement;
	}

}
declare module Coveo {
	interface IFacetHeaderOptions {
	    facetElement: HTMLElement;
	    facet?: Facet;
	    title: string;
	    field: string;
	    enableClearElement: boolean;
	    enableCollapseElement: boolean;
	    icon?: string;
	    facetSlider?: FacetSlider;
	    settingsKlass?: IFacetSettingsKlass;
	    sortKlass?: IFacetSortKlass;
	    availableSorts?: string[];
	}
	class FacetHeader {
	    options: IFacetHeaderOptions;
	    element: HTMLElement;
	    iconElement: HTMLElement;
	    waitElement: HTMLElement;
	    collapseElement: HTMLElement;
	    expandElement: HTMLElement;
	    operatorElement: HTMLElement;
	    eraserElement: HTMLElement;
	    settings: FacetSettings;
	    sort: FacetSort;
	    constructor(options: IFacetHeaderOptions);
	    build(): HTMLElement;
	    switchToAnd(): void;
	    switchToOr(): void;
	    collapseFacet(): void;
	    expandFacet(): void;
	    updateOperatorQueryStateModel(): void;
	    buildEraser(): HTMLElement;
	}

}
declare module Coveo {
	class ValueElementRenderer {
	    facet: Facet;
	    facetValue: FacetValue;
	    listItem: HTMLElement;
	    label: HTMLElement;
	    checkbox: HTMLElement;
	    stylishCheckbox: HTMLElement;
	    valueCaption: HTMLElement;
	    valueCount: HTMLElement;
	    icon: HTMLElement;
	    excludeIcon: HTMLElement;
	    computedField: HTMLElement;
	    constructor(facet: Facet, facetValue: FacetValue);
	    withNo(element: HTMLElement[]): ValueElementRenderer;
	    withNo(element: HTMLElement): ValueElementRenderer;
	    build(): ValueElementRenderer;
	    setCssClassOnListValueElement(): void;
	     accessibleElement: HTMLElement;
	    protected buildExcludeIcon(): HTMLElement;
	    protected buildValueComputedField(): HTMLElement;
	    protected buildValueCheckbox(): HTMLElement;
	    protected buildValueStylishCheckbox(): HTMLElement;
	    protected buildValueIcon(): HTMLElement;
	    protected getValueIcon(): string;
	    protected buildValueIconFromSprite(): HTMLElement;
	    protected buildValueCaption(): HTMLElement;
	    protected buildValueCount(): HTMLElement;
	}

}
declare module Coveo {
	/// <reference path="Facet.d.ts" />
	interface IValueElementKlass {
	    new (facet: Facet, facetValue: FacetValue): ValueElement;
	}
	interface IValueElementEventsBinding {
	    displayNextTime: boolean;
	    pinFacet: boolean;
	    omniboxObject?: IPopulateOmniboxObject;
	}
	class ValueElement {
	    facet: Facet;
	    facetValue: FacetValue;
	    onSelect: (elem: ValueElement, cause: IAnalyticsActionCause) => void;
	    onExclude: (elem: ValueElement, cause: IAnalyticsActionCause) => void;
	    renderer: ValueElementRenderer;
	    constructor(facet: Facet, facetValue: FacetValue, onSelect?: (elem: ValueElement, cause: IAnalyticsActionCause) => void, onExclude?: (elem: ValueElement, cause: IAnalyticsActionCause) => void);
	    build(): ValueElement;
	    bindEvent(eventBindings: IValueElementEventsBinding): void;
	    select(): void;
	    unselect(): void;
	    exclude(): void;
	    unexclude(): void;
	    toggleExcludeWithUA(): void;
	    protected handleSelectValue(eventBindings: IValueElementEventsBinding): void;
	    protected handleExcludeClick(eventBindings: IValueElementEventsBinding): void;
	    protected handleSelectEventForExcludedValueElement(eventBindings: IValueElementEventsBinding): void;
	    protected handleExcludeEventForValueElement(eventBindings: IValueElementEventsBinding): void;
	    protected handleSelectEventForValueElement(eventBindings: IValueElementEventsBinding): void;
	    protected handleEventForExcludedValueElement(eventBindings: IValueElementEventsBinding): void;
	    protected handleEventForValueElement(eventBindings: IValueElementEventsBinding): void;
	    protected handleEventForCheckboxChange(eventBindings: IValueElementEventsBinding): void;
	    protected omniboxCloseEvent(eventArg: IPopulateOmniboxObject): void;
	}

}
declare module Coveo {
	/// <reference path="Facet.d.ts" />
	interface IFacetValueElementKlass {
	    new (facet: Facet, facetValue: FacetValue, displayNextTime?: boolean): FacetValueElement;
	}
	class FacetValueElement extends ValueElement {
	    facet: Facet;
	    facetValue: FacetValue;
	    keepDisplayedValueNextTime: boolean;
	    constructor(facet: Facet, facetValue: FacetValue, keepDisplayedValueNextTime: boolean);
	    bindEvent(): void;
	}

}
declare module Coveo {
	/// <reference path="Facet.d.ts" />
	interface IFacetSearchValuesListKlass {
	    new (facet: Facet, facetValueElementKlass: IFacetValueElementKlass): FacetSearchValuesList;
	}
	class FacetSearchValuesList {
	    facet: Facet;
	    facetValueElementKlass: IFacetValueElementKlass;
	    constructor(facet: Facet, facetValueElementKlass: IFacetValueElementKlass);
	    build(facetValues: FacetValue[]): HTMLElement[];
	}

}
declare module Coveo {
	class FacetValuesOrder {
	    facet: Facet;
	    facetSort: FacetSort;
	    constructor(facet: Facet, facetSort: FacetSort);
	    reorderValues(facetValues: IIndexFieldValue[]): IIndexFieldValue[];
	    reorderValues(facetValues: FacetValue[]): FacetValue[];
	    reorderValuesIfUsingCustomSort(values: FacetValue[]): any[];
	    reorderValuesIfUsingAlphabeticalSort(values: FacetValue[]): FacetValue[];
	}

}
declare module Coveo {
	interface IFacetSearch {
	    facetType: string;
	    facetTitle: string;
	    currentlyDisplayedResults: string[];
	    facetSearchElement: FacetSearchElement;
	    facetSearchPromise: Promise<IIndexFieldValue[]>;
	    moreValuesToFetch: boolean;
	    setExpandedFacetSearchAccessibilityAttributes: (searchResultsElement: HTMLElement) => void;
	    setCollapsedFacetSearchAccessibilityAttributes: () => void;
	    dismissSearchResults: () => void;
	    getCaptions: () => HTMLElement[];
	    displayNewValues: (params?) => void;
	    keyboardNavigationEnterPressed: (event: KeyboardEvent) => void;
	    keyboardNavigationDeletePressed?: (event: KeyboardEvent) => void;
	    keyboardEventDefaultHandler: () => void;
	    fetchMoreValues: () => void;
	    updateAriaLive: (text: string) => void;
	}

}
declare module Coveo {
	class FacetSearchUserInputHandler {
	    constructor(facetSearch: IFacetSearch);
	    handleKeyboardEvent(event: KeyboardEvent): void;
	    handleFacetSearchResultsScroll(): void;
	}

}
declare module Coveo {
	interface ISearchDropdownNavigator {
	    focusNextElement: () => void;
	    focusPreviousElement: () => void;
	    currentResult: Dom;
	    setAsCurrentResult: (el: Dom) => void;
	}
	interface ISearchDropdownConfig {
	    input: HTMLInputElement;
	    searchResults: HTMLElement;
	    setScrollTrigger: (value: boolean) => void;
	}
	class DefaultSearchDropdownNavigator implements ISearchDropdownNavigator {
	    currentResult: Dom;
	    constructor(config: ISearchDropdownConfig);
	    setAsCurrentResult(toSet: Dom): void;
	    focusNextElement(): void;
	    focusPreviousElement(): void;
	    moveCurrentResultDown(): void;
	    moveCurrentResultUp(): void;
	}

}
declare module Coveo {
	interface IFacetSearchDropdownConfig extends ISearchDropdownConfig {
	    facetSearch: IFacetSearch;
	}
	class FacetSearchDropdownNavigator implements ISearchDropdownNavigator {
	    constructor(config: IFacetSearchDropdownConfig);
	    setAsCurrentResult(dom: Dom): void;
	     currentResult: Dom;
	    focusNextElement(): void;
	    focusPreviousElement(): void;
	}

}
declare module Coveo {
	interface CategoryFacetData {
	    value: string;
	    count: number;
	}
	class CategoryFacetTemplates {
	    constructor();
	    buildListRoot(): Dom;
	    buildListElement(data: CategoryFacetData): Dom;
	    buildAllCategoriesButton(): Dom;
	    buildEllipsis(): Dom;
	    buildCollapseArrow(): Dom;
	}

}
declare module Coveo {
	interface CategoryValueParent {
	    listRoot: Dom;
	    path: string[];
	    categoryChildrenValueRenderer: CategoryChildrenValueRenderer;
	    renderAsParent(categoryFacetValue: ICategoryFacetValue): CategoryValue;
	    renderChildren(categoryFacetValues: ICategoryFacetValue[]): void;
	}
	class CategoryValue implements CategoryValueParent {
	    listRoot: Dom;
	    categoryValueDescriptor: CategoryValueDescriptor;
	    path: string[];
	    element: Dom;
	    isActive: boolean;
	    categoryChildrenValueRenderer: CategoryChildrenValueRenderer;
	    constructor(listRoot: Dom, categoryValueDescriptor: CategoryValueDescriptor, categoryFacetTemplates: CategoryFacetTemplates, categoryFacet: CategoryFacet);
	    render(isChild: boolean): void;
	    getDescriptor(): {
	        value: string;
	        count: number;
	        path: string[];
	    };
	    clear(): void;
	    renderChildren(values: ICategoryFacetValue[]): void;
	    renderAsParent(value: ICategoryFacetValue): CategoryValue;
	     children: CategoryValue[];
	    makeSelectable(): this;
	    showCollapseArrow(): this;
	}

}
declare module Coveo {
	class CategoryChildrenValueRenderer {
	    children: CategoryValue[];
	    constructor(element: Dom, categoryFacetTemplates: CategoryFacetTemplates, categoryValue: CategoryValueParent, categoryFacet: CategoryFacet);
	    clearChildren(): void;
	    renderChildren(values: ICategoryFacetValue[]): void;
	    renderAsParent(value: ICategoryFacetValue): CategoryValue;
	}

}
declare module Coveo {
	class CategoryValueRoot implements CategoryValueParent {
	    path: any[];
	    categoryChildrenValueRenderer: CategoryChildrenValueRenderer;
	    listRoot: Dom;
	    constructor(element: Dom, categoryFacetTemplates: CategoryFacetTemplates, categoryFacet: CategoryFacet);
	    renderChildren(values: ICategoryFacetValue[]): void;
	    renderAsParent(value: ICategoryFacetValue): CategoryValue;
	     children: CategoryValue[];
	    clear(): void;
	}

}
declare module Coveo {
	class CategoryFacetQueryController {
	    constructor(categoryFacet: CategoryFacet);
	    putCategoryFacetInQueryBuilder(queryBuilder: QueryBuilder, path: string[], maximumNumberOfValues: number): number;
	    searchFacetValues(value: string, numberOfValues: number): Promise<IGroupByValue[]>;
	    addDebugGroupBy(queryBuilder: QueryBuilder, value: string): void;
	}

}
declare module Coveo {
	class CategoryFacetSearch implements IFacetSearch {
	    container: Dom | any;
	    facetSearchElement: FacetSearchElement;
	    displayNewValues: () => void;
	    currentlyDisplayedResults: string[];
	    moreValuesToFetch: boolean;
	    facetSearchPromise: Promise<IIndexFieldValue[]>;
	    constructor(categoryFacet: CategoryFacet, displayButton?: boolean);
	     facetType: string;
	     facetTitle: string;
	    setExpandedFacetSearchAccessibilityAttributes(searchResultsElements: HTMLElement): void;
	    setCollapsedFacetSearchAccessibilityAttributes(): void;
	    build(): Dom;
	    focus(): void;
	    clear(): void;
	    dismissSearchResults(): void;
	    keyboardEventDefaultHandler(): void;
	    keyboardNavigationEnterPressed(): void;
	    fetchMoreValues(): void;
	    getCaptions(): HTMLElement[];
	    updateAriaLive(text: string): void;
	}

}
declare module Coveo {
	interface ICategoryFacetBreadcrumbOptions {
	    headingLevel?: number;
	}
	class CategoryFacetBreadcrumb {
	    constructor(categoryFacet: CategoryFacet, onClickHandler: (e: MouseEvent) => void, categoryValueDescriptor: CategoryValueDescriptor, options?: ICategoryFacetBreadcrumbOptions);
	    build(): HTMLElement;
	}

}
declare module Coveo {
	class CategoryFacetDebug {
	    constructor(categoryFacet: CategoryFacet);
	    static analyzeResults(groupByResults: IGroupByResult, delimiter: string): string[];
	}

}
declare module Coveo {
	interface ICategoryFacetHeaderOptions {
	    categoryFacet: CategoryFacet;
	    title: string;
	}
	class CategoryFacetHeader {
	    element: HTMLElement;
	    constructor(options: ICategoryFacetHeaderOptions);
	    build(): HTMLElement;
	}

}
declare module Coveo {
	class ResultListUtils {
	    static hideIfInfiniteScrollEnabled(cmp: Component): void;
	    static isInfiniteScrollEnabled(root: HTMLElement): boolean;
	    static scrollToTop(root: HTMLElement): void;
	}

}
declare module Coveo {
	type ISeenValue = {
	    result: ICategoryFacetValue;
	    children: ISeenValue[];
	};
	class CategoryFacetValuesTree {
	    seenValues: ISeenValue[];
	    getValueForLastPartInPath(path: string[]): ICategoryFacetValue;
	    storeNewValues(categoryFacetResult: ICategoryFacetResult): void;
	}

}
declare module Coveo {
	interface ICategoryFacetOptions extends IResponsiveComponentOptions, IDependsOnCompatibleFacetOptions {
	    field: IFieldOption;
	    title?: string;
	    numberOfResultsInFacetSearch?: number;
	    id?: string;
	    enableFacetSearch?: boolean;
	    facetSearchDelay?: number;
	    numberOfValues?: number;
	    injectionDepth?: number;
	    enableMoreLess?: boolean;
	    pageSize?: number;
	    delimitingCharacter?: string;
	    debug?: boolean;
	    basePath?: string[];
	    maximumDepth?: number;
	    valueCaption?: IStringMap<string>;
	    dependsOn?: string;
	    displaySearchOnTop?: boolean;
	    displaySearchButton?: boolean;
	}
	type CategoryValueDescriptor = {
	    value: string;
	    count: number;
	    path: string[];
	};
	/**
	 * The `CategoryFacet` component is a facet that renders values in a hierarchical fashion. It determines the filter to apply depending on the
	 * current selected path of values.
	 *
	 * The path is a sequence of values that leads to a specific value in the hierarchy.
	 * It is an array listing all the parents of a file (e.g., `['c', 'folder1']` for the `c:\folder1\text1.txt` file).
	 *
	 * This facet requires a [`field`]{@link CategoryFacet.options.field} with a special format to work correctly (see [Using the Category Facet Component](https://docs.coveo.com/en/2667)).
	 *
	 * @notSupportedIn salesforcefree
	 * @availablesince [January 2019 Release (v2.5395.12)](https://docs.coveo.com/en/3277/#january-2019-release-v2539512)
	 */
	class CategoryFacet extends Component implements IAutoLayoutAdjustableInsideFacetColumn {
	    element: HTMLElement;
	    options: ICategoryFacetOptions;
	    static doExport: () => void;
	    static ID: string;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: ICategoryFacetOptions;
	    categoryFacetQueryController: CategoryFacetQueryController;
	    listenToQueryStateChange: boolean;
	    categoryFacetSearch: CategoryFacetSearch;
	    activeCategoryValue: CategoryValue | any;
	    positionInQuery: number;
	    dependsOnManager: DependsOnManager;
	    isFieldValueCompatible: boolean;
	    static MAXIMUM_NUMBER_OF_VALUES_BEFORE_TRUNCATING: number;
	    static NUMBER_OF_VALUES_TO_KEEP_AFTER_TRUNCATING: number;
	    static WAIT_ELEMENT_CLASS: string;
	    constructor(element: HTMLElement, options: ICategoryFacetOptions, bindings?: IComponentBindings);
	    isCurrentlyDisplayed(): boolean;
	    activePath: string[];
	     queryStateAttribute: string;
	    handleBuildingQuery(args: IBuildingQueryEventArgs): void;
	    scrollToTop(): void;
	    handleQuerySuccess(args: IQuerySuccessEventArgs): void;
	    /**
	     * Changes the active path.
	     *
	     */
	    changeActivePath(path: string[]): void;
	    executeQuery(): Promise<void>;
	    /**
	     * Reloads the facet with the same path.
	     */
	    reload(): void;
	    /**
	     * Returns all the visible parent values.
	     * @returns simple object with three fields: `value`, `count` and `path`.
	     */
	    getVisibleParentValues(): CategoryValueDescriptor[];
	    /**
	     * Shows more values according to {@link CategoryFacet.options.pageSize}.
	     *
	     * See the [`enableMoreLess`]{@link CategoryFacet.options.enableMoreLess}, and
	     * [`numberOfValues`]{@link CategoryFacet.options.numberOfValues} options.
	     */
	    showMore(): void;
	    /**
	     * Shows less values, up to the original number of values.
	     *
	     * See the [`enableMoreLess`]{@link CategoryFacet.options.enableMoreLess}, and
	     * [`numberOfValues`]{@link CategoryFacet.options.numberOfValues} options.
	     */
	    showLess(): void;
	    /**
	     * Returns the values at the bottom of the hierarchy. These are the values that are not yet applied to the query.
	     * @returns simple object with three fields: `value`, `count` and `path`.
	     */
	    getAvailableValues(): {
	        value: string;
	        count: number;
	        path: string[];
	    }[];
	    /**
	     * Selects a value from the currently available values.
	     * If the given value to select is not in the available values, it will throw an error.
	     */
	    selectValue(value: string): void;
	    /**
	     * Deselects the last value in the hierarchy that is applied to the query. When at the top of the hierarchy, this method does nothing.
	     */
	    deselectCurrentValue(): void;
	    /**
	     * Resets the facet to its initial state.
	     */
	    reset(): void;
	    /**
	     * Hides the component.
	     */
	    hide(): void;
	    /**
	     * Shows the component.
	     */
	    show(): void;
	    enable(): void;
	    disable(): void;
	    /**
	     * Goes through any value that contains the value parameter, and verifies whether there are missing parents.
	     * Issues are then logged in the console.
	     * If you do not want to specify a value, you can simply enable {@link CategoryFacet.options.debug} and do an empty query.
	     */
	    debugValue(value: string): Promise<void>;
	    /**
	     *
	     * @param value The string to find a caption for.
	     * Returns the caption for a value or the value itself if no caption is available.
	     */
	    getCaption(value: string): string;
	    showWaitingAnimation(): void;
	    hideWaitingAnimation(): void;
	    logAnalyticsEvent(eventName: IAnalyticsActionCause, path?: string[]): void;
	    getEndpoint(): ISearchEndpoint;
	     children: CategoryValue[];
	}

}
declare module Coveo {
	function SearchDropdownNavigatorFactory(facetSearch: IFacetSearch, config: ISearchDropdownConfig): ISearchDropdownNavigator;

}
declare module Coveo {
	class FacetSearchElement {
	    search: HTMLElement | any;
	    magnifier: HTMLElement | any;
	    wait: HTMLElement | any;
	    clear: HTMLElement | any;
	    input: HTMLInputElement | any;
	    combobox: HTMLElement | any;
	    searchBarIsAnimating: boolean;
	    searchResults: HTMLElement;
	    facetSearchUserInputHandler: FacetSearchUserInputHandler;
	    constructor(facetSearch: IFacetSearch);
	    build(handleFacetSearchClear?: () => void): HTMLElement;
	    showFacetSearchWaitingAnimation(): void;
	    getValueInInputForFacetSearch(): string;
	    hideFacetSearchWaitingAnimation(): void;
	    detectSearchBarAnimation(): void;
	    positionSearchResults(): void;
	    setAsCurrentResult(toSet: Dom): void;
	     currentResult: Dom;
	    moveCurrentResultDown(): void;
	    moveCurrentResultUp(): void;
	    highlightCurrentQueryInSearchResults(regex: RegExp): void;
	    appendToSearchResults(el: HTMLElement): void;
	    emptyAndShowNoResults(): void;
	    updateAriaLiveWithResults(inputValue: string, numberOfResults: number, moreValuesToFetch: boolean): void;
	    focus(): void;
	    hideSearchResultsElement(): void;
	    clearSearchInput(): void;
	}

}
declare module Coveo {
	/// <reference path="Facet.d.ts" />
	/**
	 * Used by the {@link Facet} component to render and handle the facet search part of each facet.
	 */
	class FacetSearch implements IFacetSearch {
	    facet: Facet;
	    facetSearchValuesListKlass: IFacetSearchValuesListKlass;
	    currentlyDisplayedResults: string[];
	    facetSearchElement: FacetSearchElement;
	    facetSearchPromise: Promise<IIndexFieldValue[]>;
	    moreValuesToFetch: boolean;
	    constructor(facet: Facet, facetSearchValuesListKlass: IFacetSearchValuesListKlass, root: HTMLElement);
	     facetType: string;
	     facetTitle: string;
	    /**
	     * Build the search component and return an `HTMLElement` which can be appended to the {@link Facet}.
	     * @returns {HTMLElement}
	     */
	    build(): HTMLElement;
	    /**
	     * Position the search results at the footer of the facet.
	     */
	    positionSearchResults(): void;
	    fetchMoreValues(): void;
	    /**
	     * Dismiss the search results
	     */
	    dismissSearchResults(): void;
	    /**
	     * Trigger a new facet search, and display the results.
	     * @param params
	     */
	    triggerNewFacetSearch(params: FacetSearchParameters): void;
	    /**
	     * Trigger the event associated with the focus of the search input.
	     */
	    focus(): void;
	     searchResults: HTMLElement;
	     searchBarIsAnimating: boolean;
	     search: HTMLElement;
	    setExpandedFacetSearchAccessibilityAttributes(searchResultsElement: HTMLElement): void;
	    setCollapsedFacetSearchAccessibilityAttributes(): void;
	    keyboardEventDefaultHandler(): void;
	    keyboardNavigationEnterPressed(event: KeyboardEvent): void;
	    keyboardNavigationDeletePressed(event: KeyboardEvent): void;
	    displayNewValues(params?: FacetSearchParameters): void;
	    getCaptions(): HTMLElement[];
	    getValueInInputForFacetSearch(): string;
	    updateAriaLive(text: string): void;
	    protected buildParamsForExcludingCurrentlyDisplayedValues(): FacetSearchParameters;
	    protected selectAllValuesMatchingSearch(): void;
	}

}
declare module Coveo {
	type FacetSortCriterion = 'occurrences' | 'score' | 'alphaascending' | 'alphadescending' | 'computedfieldascending' | 'computedfielddescending' | 'chisquare' | 'nosort';

}
declare module Coveo {
	interface ISortFacetValuesOptions {
	    facetValuesOrder: FacetValuesOrder;
	    numberOfValues: number;
	}
	class FacetValues {
	    constructor(groupByResult?: IGroupByResult);
	    add(facetValue: FacetValue): void;
	    remove(value: string): void;
	    size(): number;
	    isEmpty(): boolean;
	    at(index: number): FacetValue;
	    get(value: string): FacetValue;
	    contains(value: string): boolean;
	    getAll(): FacetValue[];
	    getSelected(): FacetValue[];
	    getExcluded(): FacetValue[];
	    hasSelectedOrExcludedValues(): boolean;
	    hasSelectedAndExcludedValues(): boolean;
	    hasOnlyExcludedValues(): boolean;
	    hasOnlySelectedValues(): boolean;
	    reset(): void;
	    updateCountsFromNewValues(newValues: FacetValues): void;
	    updateDeltaWithFilteredFacetValues(filtered: FacetValues, isMultiValueField: boolean): void;
	    mergeWithUnfilteredFacetValues(unfiltered: FacetValues): void;
	    sort(options: ISortFacetValuesOptions): void;
	    sortValuesDependingOnStatus(numOfDisplayedValues: number): void;
	}

}
declare module Coveo {
	/// <reference path="Facet.d.ts" />
	class FacetValuesList {
	    facet: Facet;
	    facetValueElementKlass: IFacetValueElementKlass;
	    valueContainer: HTMLElement;
	    constructor(facet: Facet, facetValueElementKlass: IFacetValueElementKlass);
	    build(): HTMLElement;
	    getAllCurrentlyDisplayed(): ValueElement[];
	    getAll(): ValueElement[];
	    getAllFacetValue(): FacetValue[];
	    get(value: FacetValue | string): ValueElement;
	    select(value: FacetValue | string): ValueElement;
	    unselect(value: FacetValue | string): ValueElement;
	    exclude(value: FacetValue | string): ValueElement;
	    unExclude(value: FacetValue | string): ValueElement;
	    toggleSelect(value: FacetValue | string): ValueElement;
	    toggleExclude(value: FacetValue | string): ValueElement;
	    rebuild(numberOfValues: number): void;
	    protected getValuesToBuildWith(): FacetValue[];
	}

}
declare module Coveo {
	/// <reference path="Facet.d.ts" />
	interface IOmniboxValueElementKlass {
	    new (facet: Facet, facetValue: FacetValue, eventArg: IPopulateOmniboxObject, onSelect?: (elem: ValueElement, cause: IAnalyticsActionCause) => void, onExclude?: (elem: ValueElement, cause: IAnalyticsActionCause) => void): OmniboxValueElement;
	}
	class OmniboxValueElement extends ValueElement {
	    facet: Facet;
	    facetValue: FacetValue;
	    eventArg: IPopulateOmniboxObject;
	    constructor(facet: Facet, facetValue: FacetValue, eventArg: IPopulateOmniboxObject, onSelect?: (elem: ValueElement, cause: IAnalyticsActionCause) => void, onExclude?: (elem: ValueElement, cause: IAnalyticsActionCause) => void);
	    bindEvent(): void;
	}

}
declare module Coveo {
	/// <reference path="Facet.d.ts" />
	class OmniboxValuesList {
	    facet: Facet;
	    facetValues: FacetValue[];
	    omniboxObject: IPopulateOmniboxObject;
	    omniboxValueElementKlass: IOmniboxValueElementKlass;
	    constructor(facet: Facet, facetValues: FacetValue[], omniboxObject: IPopulateOmniboxObject, omniboxValueElementKlass: IOmniboxValueElementKlass);
	    build(): HTMLElement;
	}

}
declare module Coveo {
	function isFacetFieldValueCompatible(facet: Component): facet is IFieldValueCompatibleFacet;
	interface IFieldValueCompatibleFacet extends Component {
	    isFieldValueCompatible: boolean;
	    isFieldValueHierarchical: boolean;
	    hasSelectedValue(value: string): boolean;
	    selectValue(value: string): void;
	    deselectValue(value: string): void;
	    getCaptionForStringValue(value: string): string;
	}

}
declare module Coveo {
	interface IFacetOptions extends IResponsiveComponentOptions, IDependsOnCompatibleFacetOptions {
	    title?: string;
	    field?: IFieldOption;
	    isMultiValueField?: boolean;
	    numberOfValues?: number;
	    pageSize?: number;
	    sortCriteria?: string;
	    availableSorts?: string[];
	    injectionDepth?: number;
	    showIcon?: boolean;
	    useAnd?: boolean;
	    enableCollapse?: boolean;
	    enableTogglingOperator?: boolean;
	    enableMoreLess?: boolean;
	    valueCaption?: any;
	    lookupField?: IFieldOption;
	    enableFacetSearch?: boolean;
	    facetSearchDelay?: number;
	    facetSearchIgnoreAccents?: boolean;
	    numberOfValuesInFacetSearch?: number;
	    includeInBreadcrumb?: boolean;
	    includeInOmnibox?: boolean;
	    numberOfValuesInOmnibox?: number;
	    numberOfValuesInBreadcrumb?: number;
	    computedField?: IFieldOption;
	    computedFieldOperation?: string;
	    computedFieldFormat?: string;
	    computedFieldCaption?: string;
	    preservePosition?: boolean;
	    scrollContainer?: HTMLElement;
	    paddingContainer?: HTMLElement;
	    customSort?: string[];
	    enableSettings?: boolean;
	    enableSettingsFacetState?: boolean;
	    allowedValues?: string[];
	    headerIcon?: string;
	    valueIcon?: (facetValue: FacetValue) => string;
	    additionalFilter?: IQueryExpression;
	    useWildcardsInFacetSearch?: boolean;
	}
	/**
	 * The `Facet` component displays a *facet* of the results for the current query. A facet is a list of values for a
	 * certain field occurring in the results, ordered using a configurable criteria (e.g., number of occurrences).
	 *
	 * The list of values is obtained using a [`GroupByRequest`]{@link IGroupByRequest} operation performed at the same time
	 * as the main query.
	 *
	 * The `Facet` component allows the end user to drill down inside a result set by restricting the result to certain
	 * field values. It also allows filtering out values from the facet itself, and can provide a search box to look for
	 * specific values inside larger sets.
	 *
	 * This is probably the most complex component in the Coveo JavaScript Search Framework and as such, it allows for many
	 * configuration options.
	 *
	 * See also the [`FacetRange`]{@link FacetRange} and [`TimespanFacet`]{@link TimespanFacet} components (which
	 * extend this component), and the [`FacetSlider`]{@link FacetSlider} and [`CategoryFacet`]{@link CategoryFacet} components (which do not extend this
	 * component, but are very similar).
	 */
	class Facet extends Component implements IFieldValueCompatibleFacet {
	    element: HTMLElement;
	    options: IFacetOptions;
	    static ID: string;
	    static omniboxIndex: number;
	    static doExport: () => void;
	    /**
	     * The possible options for a facet
	     * @componentOptions
	     */
	    static options: IFacetOptions;
	    facetQueryController: FacetQueryController;
	    keepDisplayedValuesNextTime: boolean;
	    values: FacetValues;
	    currentPage: number;
	    numberOfValues: number;
	    firstQuery: boolean;
	    operatorAttributeId: string;
	    isFieldValueCompatible: boolean;
	    isFieldValueHierarchical: boolean;
	    /**
	     * Renders and handles the facet **Search** part of the component.
	     */
	    facetSearch: FacetSearch;
	    /**
	     * Renders and handles the facet **Settings** part of the component
	     */
	    facetSettings: FacetSettings;
	    facetSort: FacetSort;
	    facetValuesList: FacetValuesList;
	    facetHeader: FacetHeader;
	    searchContainer: ValueElementRenderer;
	    dependsOnManager: DependsOnManager;
	    protected omniboxZIndex: any;
	    protected moreElement: HTMLElement;
	    protected lessElement: HTMLElement;
	    protected headerElement: HTMLElement;
	    protected footerElement: HTMLElement;
	    /**
	     * Creates a new `Facet` component. Binds multiple query events as well.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `Facet` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param facetClassId The ID to use for this facet (as `Facet` inherited from by other component
	     * (e.g., [`FacetRange`]{@link FacetRange}). Default value is `Facet`.
	     */
	    constructor(element: HTMLElement, options: IFacetOptions, bindings?: IComponentBindings, facetClassId?: string);
	    setExpandedFacetSearchAccessibilityAttributes(searchResultsElement: HTMLElement): void;
	    setCollapsedFacetSearchAccessibilityAttributes(): void;
	    isCurrentlyDisplayed(): boolean;
	    createDom(): void;
	    /**
	     * Selects a single value.
	     *
	     * Does not trigger a query automatically.
	     *
	     * @param value Can be a [`FacetValue`]{@link FacetValue} or a string (e.g., `selectValue('foobar')` or
	     * `selectValue(new FacetValue('foobar'))`).
	     */
	    selectValue(value: FacetValue | string): void;
	    /**
	     * Selects multiple values.
	     *
	     * Does not trigger a query automatically.
	     *
	     * @param values Can be an array of [`FacetValue`]{@link FacetValue} or an array of strings.
	     */
	    selectMultipleValues(values: FacetValue[] | string[]): void;
	    /**
	     * Deselects a single value.
	     *
	     * Does not trigger a query automatically.
	     *
	     * @param value Can be a [`FacetValue`]{@link FacetValue} or a string (e.g., `deselectValue('foobar')` or
	     * `deselectValue(new FacetValue('foobar'))`).
	     */
	    deselectValue(value: FacetValue | string): void;
	    /**
	     * Deselects multiple values.
	     *
	     * Does not trigger a query automatically.
	     *
	     * @param values Can be an array of [`FacetValue`]{@link FacetValue} or an array of strings.
	     */
	    deselectMultipleValues(values: FacetValue[] | string[]): void;
	    /**
	     * Excludes a single value.
	     *
	     * Does not trigger a query automatically.
	     *
	     * @param value Can be a [`FacetValue`]{@link FacetValue} or a string (e.g., `excludeValue('foobar')` or
	     * `excludeValue(new FacetValue('foobar'))`).
	     */
	    excludeValue(value: FacetValue | string): void;
	    /**
	     * Excludes multiple values.
	     *
	     * Does not trigger a query automatically.
	     *
	     * @param values Can be an array of [`FacetValue`]{@link FacetValue} or an array of strings.
	     */
	    excludeMultipleValues(values: FacetValue[] | string[]): void;
	    /**
	     * Unexcludes a single value.
	     *
	     * Does not trigger a query automatically.
	     *
	     * @param value Can be a [`FacetValue`]{@link FacetValue} or a string.
	     */
	    unexcludeValue(value: FacetValue | string): void;
	    /**
	     * Unexcludes multiple values.
	     *
	     * Does not trigger a query automatically.
	     *
	     * @param values Can be an array of [`FacetValue`]{@link FacetValue} or an array of strings.
	     */
	    unexcludeMultipleValues(values: FacetValue[] | string[]): void;
	    /**
	     * Toggles the selection state of a single value (selects the value if it is not already selected; un-selects the
	     * value if it is already selected).
	     *
	     * Does not trigger a query automatically.
	     * @param value Can be a [`FacetValue`]{@link FacetValue} or a string.
	     */
	    toggleSelectValue(value: FacetValue | string): void;
	    /**
	     * Toggles the exclusion state of a single value (excludes the value if it is not already excluded; un-excludes the
	     * value if it is already excluded).
	     *
	     * Does not trigger a query automatically.
	     *
	     * @param value Can be a [`FacetValue`]{@link FacetValue} or a string.
	     */
	    toggleExcludeValue(value: FacetValue | string): void;
	    /**
	     * Returns the currently displayed values as an array of strings.
	     *
	     * @returns {any[]} The currently displayed values.
	     */
	    getDisplayedValues(): string[];
	    /**
	     * Returns the currently displayed values as an array of [`FacetValue`]{@link FacetValue}.
	     *
	     * @returns {T[]} The currently displayed values.
	     */
	    getDisplayedFacetValues(): FacetValue[];
	    /**
	     * Returns the currently selected values as an array of strings.
	     * @returns {string[]} The currently selected values.
	     */
	    getSelectedValues(): string[];
	    /**
	     * Determines whether the specified value is selected in the facet.
	     * @param value The name of the facet value to verify.
	     */
	    hasSelectedValue(value: string): boolean;
	    /**
	     * Returns the currently excluded values as an array of strings.
	     * @returns {string[]} The currently excluded values.
	     */
	    getExcludedValues(): string[];
	    /**
	     * Resets the facet by un-selecting all values, un-excluding all values, and redrawing the facet.
	     */
	    reset(): void;
	    /**
	     * Switches the facet to `AND` mode.
	     *
	     * See the [`useAnd`]{@link Facet.options.useAnd}, and
	     * [`enableTogglingOperator`]{@link Facet.options.enableTogglingOperator} options.
	     */
	    switchToAnd(): void;
	    /**
	     * Switches the facet to `OR` mode.
	     *
	     * See the [`useAnd`]{@link Facet.options.useAnd}, and
	     * [`enableTogglingOperator`]{@link Facet.options.enableTogglingOperator} options.
	     */
	    switchToOr(): void;
	    /**
	     * Returns the endpoint for the facet.
	     * @returns {ISearchEndpoint} The endpoint for the facet.
	     */
	    getEndpoint(): ISearchEndpoint;
	    /**
	     * Changes the sort parameter for the facet.
	     *
	     * See {@link Facet.options.availableSorts} for the list of possible values.
	     *
	     * Also triggers a new query.
	     *
	     * @param criteria The new sort parameter for the facet.
	     */
	    updateSort(criteria: string): void;
	    unfadeInactiveValuesInMainList(): void;
	    fadeInactiveValuesInMainList(delay: number): void;
	    /**
	     * Shows a waiting animation in the facet header (a spinner).
	     */
	    showWaitingAnimation(): void;
	    /**
	     * Hides the waiting animation in the facet header.
	     */
	    hideWaitingAnimation(): void;
	    processFacetSearchAllResultsSelected(facetValues: FacetValue[]): void;
	    pinFacetPosition(): void;
	    /**
	     * Returns the configured caption for the given [`FacetValue`]{@link FacetValue}.
	     *
	     * @param facetValue The `FacetValue` whose caption the method should return.
	     */
	    getValueCaption(facetValue: IIndexFieldValue | FacetValue | string): string;
	    /**
	     * Returns the configured caption for a desired facet value.
	     *
	     * @param value The string facet value whose caption the method should return.
	     */
	    getCaptionForStringValue(value: string): string;
	    /**
	     * Shows the next page of results in the facet.
	     *
	     * See the [`enableMoreLess`]{@link Facet.options.enableMoreLess}, and [`pageSize`]{@link Facet.options.pageSize}
	     * options.
	     *
	     * Triggers a query if needed, or displays the already available values.
	     */
	    showMore(): void;
	    /**
	     * Shows less elements in the Facet (up to the original number of values).
	     *
	     * See the [`enableMoreLess`]{@link Facet.options.enableMoreLess}, and
	     * [`numberOfValues`]{@link Facet.options.numberOfValues} options.
	     */
	    showLess(): void;
	    /**
	     * Collapses the facet.
	     */
	    collapse(): void;
	    /**
	     * Expands the facet.
	     */
	    expand(): void;
	    triggerNewQuery(beforeExecuteQuery?: () => void): void;
	    protected handleDeferredQuerySuccess(data: IQuerySuccessEventArgs): void;
	    protected handleQueryError(): void;
	    protected handlePopulateBreadcrumb(args: IPopulateBreadcrumbEventArgs): void;
	    protected handlePopulateSearchAlerts(args: ISearchAlertsPopulateMessageEventArgs): void;
	    protected initFacetQueryController(): void;
	    protected initFacetValuesList(): void;
	    protected initFacetSearch(): void;
	    protected facetValueHasChanged(): void;
	    protected updateAppearanceDependingOnState(): void;
	    protected initQueryEvents(): void;
	    protected initQueryStateEvents(): void;
	    protected initComponentStateEvents(): void;
	    protected initOmniboxEvents(): void;
	    protected initBreadCrumbEvents(): void;
	    protected initSearchAlertEvents(): void;
	    protected handleOmniboxWithStaticValue(eventArg: IPopulateOmniboxEventArgs): void;
	    protected processNewGroupByResults(groupByResult: IGroupByResult): void;
	    protected updateQueryStateModel(): void;
	    protected rebuildValueElements(): void;
	    protected updateSearchElement(moreValuesAvailable?: boolean): void;
	    protected updateMoreLess(lessElementIsShown?: boolean, moreValuesAvailable?: boolean): void;
	    protected handleClickMore(): void;
	    protected handleClickLess(): void;
	    protected triggerUpdateDeltaQuery(facetValues: FacetValue[]): void;
	    protected updateNumberOfValues(): void;
	    debugInfo(): any;
	}

}
declare module Coveo {
	/// <reference path="Facet.d.ts" />
	class FacetUtils {
	    static getRegexToUseForFacetSearch(value: string, ignoreAccent: boolean): RegExp;
	    static getDisplayValueFromValueCaption(value: string, field: string, valueCaption: any): string;
	    static getValuesToUseForSearchInFacet(original: Facet): string[];
	    static buildFacetSearchPattern(values: string[]): string;
	    static needAnotherFacetSearch(currentSearchLength: number, newSearchLength: number, oldSearchLength: number, desiredSearchLength: number): boolean;
	    static addNoStateCssClassToFacetValues(facet: Facet, container: HTMLElement): void;
	    static tryToGetTranslatedCaption(field: string, value: string, fallbackOnLocalization?: boolean): string;
	    static isMonthFieldValue(field: string, value: string): boolean;
	}

}
declare module Coveo {
	interface INumberFormatOptions {
	    format: string;
	}
	class NumberUtils {
	    static countDecimals(value: number | String): number;
	}

}
declare module Coveo {
	/**
	 * The core template helpers provided by default.
	 *
	 * **Examples:**
	 *
	 * **HTML**
	 *
	 * ```html
	 * <div class="CoveoFieldValue" data-field="@videoduration" data-helper="timeSpan" data-helper-options-is-milliseconds="false"></div>
	 * ```
	 *
	 * **Underscore**
	 *
	 * ```erb
	 * <%= timeSpan(raw.videoduration, { isMilliseconds: false }) %>
	 * ```
	 */
	interface ICoreHelpers {
	    /**
	     * Shortens a string so that its length does not exceed a specific number of
	     * characters. An ellipsis is appended to the string if it exceeds the
	     * maximum length.
	     *
	     * - `content`: The string to shorten.
	     * - `length`: The maximum length of the resulting string.
	     * - `highlights`: Optional. If provided, the string will be highlighted
	     *   using this highlight information.
	     * - `cssClass`: Optional. When highlighting, the name of the CSS class to use.
	     */
	    shorten: (content: string, length: number, highlights?: IHighlight[], cssClass?: string) => string;
	    /**
	     * Shortens a string using an algorithm suitable for file paths. The helper
	     * will insert an ellipsis in the string where text has been removed when
	     * the path exceeds the maximum length.
	     *
	     * - `content`: The path to shorten.
	     * - `length`: The maximum length of the resulting string.
	     * - `highlights`: Optional. If provided, the string will be highlighted using
	     *   this highlight information.
	     * - `cssClass`: Optional. When highlighting, the name of the CSS class to use.
	     */
	    shortenPath: (content: string, length: number, highlights?: IHighlight[], cssClass?: string) => string;
	    /**
	     * Shortens a string using an algorithm suitable for URIs. The helper will
	     * insert an ellipsis in the string where text has been removed when the URI
	     * exceeds the maximum length.
	     *
	     * - `content`: The URI to shorten.
	     * - `length`: The maximum length of the resulting string.
	     * - `highlights`: Optional. If provided, the string will be highlighted
	     *   using this highlight information.
	     * - `cssClass`: Optional. When highlighting, the name of the CSS class to use.
	     */
	    shortenUri: (content: string, length: number, highlights?: IHighlight[], cssClass?: string) => string;
	    /**
	     * Highlights a string using the provided highlight information.
	     *
	     * - `content`: The URI to shorten.
	     * - `highlights`: Optional. The highlight information to use.
	     * - `cssClass`: Optional. The name of the CSS class to use for highlighting.
	     */
	    highlight: (content: string, highlights?: IHighlight[], cssClass?: string) => string;
	    /**
	     * Highlights the provided terms in a given string.<br/>
	     * By default, the terms to highlight are the current query and the
	     * associated stemming words from the index.
	     * The only required parameter is the content, which specify the string that needs to be highlighted.
	     * The other parameters will normally be automatically resolved for you from the current result object.
	     *
	     * - `content`: The string content to highlight
	     * - `termsToHighlight`: The terms to highlight (see {@link IHighlightTerm})
	     * - `phraseToHighlight`: The phrases to highlight (see {@link IHighlightPhrase})
	     * - `options`: Optional. The options defined below as {@link IStreamHighlightOptions}
	     *
	     * **Note:**
	     * > `highlightStreamText` should only be used for very particular/specific use cases (e.g., augmenting the result template with additional information rather than the typical excerpt/title), and is not a proper replacement for actually having the correct title and excerpt on your results.
	     * >
	     * > Using incorrect result titles or excerpts on your search interface also causes relevancy to suffer greatly, as the index uses the title and excerpt to find relevant results. Consequently, end users are more likely to see results whose titles do not match their query.
	     * >
	     * > Moreover, the recommended method to implement simple title and/or excerpt highlighting is to simply use the {@link Excerpt} and {@link ResultLink} components.
	     */
	    highlightStreamText: (content: string, termsToHighlight: IHighlightTerm, phrasesToHighlight: IHighlightPhrase, options?: IStreamHighlightOptions) => string;
	    /**
	     * This helper operates exactly like the {@link highlightStreamText} helper, except
	     * that it should be used to highlight HTML content. The helper takes care
	     * of not highlighting the HTML markup.
	     *
	     * - `content`: The string content to highlight
	     * - `termsToHighlight`: The terms to highlight (see {@link IHighlightTerm})
	     * - `phraseToHighlight`: The phrases to highlight (see {@link IHighlightPhrase})
	     * - `options`: Optional. The options defined below as {@link IStreamHighlightOptions}
	     *
	     * **Note:**
	     * > `highlightStreamHTML` should only be used for very particular/specific use cases (e.g., augmenting the result template with additional information rather than the typical excerpt/title), and is not a proper replacement for actually having the correct title and excerpt on your results.
	     * >
	     * > Using incorrect result titles or excerpts on your search interface also causes relevancy to suffer greatly, as the index uses the title and excerpt to find relevant results. Consequently, end users are more likely to see results whose titles do not match their query.
	     * >
	     * > Moreover, the recommended method to implement simple title and/or excerpt highlighting is to simply use the {@link Excerpt} and {@link ResultLink} components.
	     */
	    highlightStreamHTML: (content: string, termsToHighlight: IHighlightTerm, phrasesToHighlight: IHighlightPhrase, options?: IStreamHighlightOptions) => string;
	    /**
	     * Formats a numeric value using the format string.
	     *
	     * - `content`: The numeric value to format.
	     * - `format` Optional. The string format to use. See the <a href="https://github.com/klaaspieter/jquery-global#numbers" target="_blank">Globalize</a> library for the list of available formats.
	     *
	     * When the helper is used in a [`FieldValue`]{@link FieldValue} component, this value is automatically retrieved from the specified [`field`]{@link FieldValue.options.field}.
	     *
	     * **Example:**
	     *
	     *  ```html
	     *  <div class="CoveoFieldValue" data-field="@viewcount" data-text-caption="Views" data-helper="number" data-helper-options-format="n0"></div>
	     *  ```
	     */
	    number: (content: string, format: string | INumberFormatOptions) => string;
	    /**
	     * Formats a date value to a date-only string using the specified options.
	     *
	     * - `content`: The Date value to format.
	     * - `options`: Optional. The options to use (see {@link IDateToStringOptions}).
	     */
	    date: (content: any, options?: IDateToStringOptions) => string;
	    /**
	     * Formats a date value to a time-only string using the specified options.
	     *
	     * - `content`: The Date value to format.
	     * - `options`: Optional. The options to use (see {@link IDateToStringOptions}).
	     */
	    time: (content: any, options?: IDateToStringOptions) => string;
	    /**
	     * Formats a date value to a date and time string using the specified
	     * options.
	     *
	     * - `content`: The Date value to format.
	     * - `options`: Optional. The options to use (see {@link IDateToStringOptions}).
	     */
	    dateTime: (content: any, options?: IDateToStringOptions) => string;
	    /**
	     * Formats a currency value to a string using the specified options.
	     *
	     * - `content`: The number value to format.
	     * - `options`: Optional. The options to use (see {@link ICurrencyToStringOptions}).
	     */
	    currency: (content: any, options?: ICurrencyToStringOptions) => string;
	    /**
	     * Formats a date value to a date and time string using options suitable for
	     * email dates
	     *
	     * - `content`: The Date value to format.
	     * - `options`: Optional. The options to use (see {@link IDateToStringOptions}).
	     */
	    emailDateTime: (content: any, options?: IDateToStringOptions) => string;
	    /**
	     * Renders one or several email values in `mailto:` hyperlinks.
	     *
	     * - `value`: The string or array of strings that contains a list of semicolon-separated email
	     *   values. When multiple values are passed, each value is displayed in a
	     *   separate hyperlink.
	     * - `companyDomain`: Optional. The string that contains your own domain (e.g.:
	     *   coveo.com). When specified, this parameter allows email addresses
	     *   coming from your own domain to be displayed in a shortened format
	     *   (e.g.: Full Name), whereas email addresses coming from an external
	     *   domain will be displayed in an extended format (e.g.: Full Name
	     *   (domain.com)). If this parameter is not specified, then the shortened
	     *   format will automatically be used.
	     * - `me`: Optional. The string that contains the current username. If it is
	     *   specified, then the email address containing the current username will
	     *   be replaced by the localized string 'Me'.
	     * - `lengthLimit`: Optional. The number of email addresses that you want to display
	     *   before an ellipse is added (e.g.: 'From Joe, John and 5 others').<br/>
	     *   The default value is 2.
	     * - `truncateName`: Optional. When the username is available from the email address,
	     *   then you can specify if you want to truncate the full name. (e.g.:
	     *   'John S.' instead of 'John Smith').<br/>
	     *   The default value is `false`.
	     */
	    email: (value: string | string[], companyDomain?: string, me?: string, lengthLimit?: number, truncateName?: boolean) => string;
	    /**
	     * Formats a clickable HTML link (`<a>`).
	     *
	     * - `href`: The link URI
	     * - `options`: Optional. The options to use (see {@link IAnchorUtilsOptions})
	     */
	    anchor: (href: string, options?: IAnchorUtilsOptions) => string;
	    /**
	     * Formats an HTML image tag (`<img>`).
	     *
	     * - `src`: The image source URI
	     * - `options`: Optional. The options to use (see {@link IImageUtilsOptions})
	     */
	    image: (src: string, options?: IImageUtilsOptions) => string;
	    /**
	     * Formats an HTML image tag (`<img>`), and automatically uses the result
	     * object to query the REST API to get the thumbnail for this result. For
	     * example, this can be used to great effect when designing a template
	     * showing users or previews of files.
	     * - `result`: Optional. The current result object inside your template. In
	     *   underscore, it is referenced as `obj`. By default, the result
	     *   will be resolved automatically from your current template function (
	     *   Meaning the nearest result in the current call stack execution inside
	     *   your template)
	     * - `endpoint`: Optional. The name of the endpoint to use for your
	     *   thumbnail. Default is default.
	     * - `options`: Optional. The options to use (see {@link IImageUtilsOptions}).
	     */
	    thumbnail: (result?: IQueryResult, endpoint?: string, options?: IImageUtilsOptions) => string;
	    /**
	     * Generates an icon based on the file type of the current result. The icon
	     * will be contained inside a `<span>` element with the appropriate CSS
	     * class.
	     *
	     * - `result`: Optional. The current result object inside your template. In
	     *   underscore, it is referenced as `obj`. By default, the result
	     *   will be resolved automatically from your current template function (
	     *   Meaning the nearest result in the current call stack execution inside
	     *   your template)
	     * - `options`: Optional. The options to use (see {@link IIconOptions}).
	     */
	    fromFileTypeToIcon: (result?: IQueryResult, options?: any) => string;
	    /**
	     * Loads a partial template in the current template, by passing the ID of
	     * the template to load, the condition for which this template should be
	     * loaded, and the context object (the object that the loaded template will
	     * use as its data). By default, the context object will be the same as the
	     * template that called this helper function. So, for example, in a
	     * ResultList Component, the contextObject would, by default, be the Query
	     * Results.
	     *
	     * - `templateId`: The ID of the template to load.
	     * - `condition`: Optional. The boolean condition to determine if this template should
	     *   load for this result set. Most of the time this would be a condition of
	     *   the type if raw.somefield == 'something'.
	     * - `contextObject`: Optional. The object that should be used by the loaded template
	     *   as its contextObject.
	     */
	    loadTemplate: (templateId: string, condition?: boolean, contextObject?: any) => string;
	    /**
	     * Given a number, either in millisecond or second, convert to a HH:MM:SS format.
	     *
	     * **Examples**
	     *
	     * >`timeSpan(1, {isMilliseconds: false}) => '00:01'`
	     * >
	     * >`timeSpan(1000, {isMilliseconds: true}) => '00:01'`
	     *
	     * - `value`: The number to convert to a timespan
	     * - `options` : The options to use (see {@link ITimeSpanUtilsOptions})
	     */
	    timeSpan: (value: number, options: ITimeSpanUtilsOptions) => string;
	    /**
	     * Formats a number, which represents a file size in bytes, into a logical unit size.
	     *
	     * **Examples:**
	     *
	     * >`size(1024) => 1024 B`
	     * >
	     * >`size(1025) => 1 KB`
	     * >
	     * >`size(10240) => 10 KB`
	     *
	     * **Examples:**
	     *
	     * >**HTML**
	     * >
	     * > ```html
	     * > <div class="CoveoFieldValue" data-field='@size' data-helper="size" data-helper-options-base="1"></div>
	     * > ```
	     *
	     * >**Underscore**
	     * >
	     * > ```erb
	     * > <%= size(raw.size, {base: 0, precision: 2}) %>
	     * > ```
	     *
	     * - `value`: The number to format
	     * - `options` : The options to use (see {@link ISizeOptions})
	     */
	    size: (value: number, options?: ISizeOptions) => string;
	    /**
	     * Given a filetype value, try to return a translated and human readable version.
	     *
	     * If the filetype is known and recognized by the framework, a translated value will be returned.
	     *
	     * **Examples**
	     *
	     * >`translatedCaption('doc') => Document`
	     * >
	     * >`translatedCaption('xls') => Spreadsheet Document`
	     *
	     * - `value`: The string value to translate
	     */
	    translatedCaption: (value: string) => string;
	    /**
	     * Replace all carriage return in a string by a &lt;br /&gt; tag
	     *
	     * - `value`: The string value to replace the carriage returns in.
	     */
	    encodeCarriageReturn: (value: string) => string;
	    /**
	     * Detect if the results is being rendered in a mobile device.
	     *
	     * If it's not a mobile device, the helper return null ;
	     *
	     * If it's a mobile device, return the type of device (Android, iPhone, iPad) etc.
	     */
	    isMobileDevice: () => string;
	}
	/**
	 * Available options for the size templateHelpers.
	 *
	 * Example:
	 * <div class="CoveoFieldValue" data-helper="helperName" data-helper-options-optionName="option-value"></div>
	 */
	interface ISizeOptions {
	    /**
	     * The base into which to format the value.
	     *
	     * Formula: value * 10^(3 * base)
	     *
	     * **Examples:**
	     * > **Base 0:**
	     * >
	     * > 1 => 1B
	     * >
	     * > 1000 => 1KB
	     *
	     * > **Base 1:**
	     * >
	     * > 1 => 1KB
	     * >
	     * > 1000 => 1MB
	     */
	    base?: number;
	    /**
	     * The precision to use to format the size (i.e., the number of digits to display after the decimal)
	     *
	     * **Examples:**
	     * > **Precision 0:**
	     * >
	     * > 1.0 => 1
	     * >
	     * > 1.85 => 1
	     *
	     * > **Precision 1:**
	     * >
	     * > 1.0 => 1.0
	     * >
	     * > 1.85 => 1.8
	     */
	    precision?: number;
	}
	interface IShortenOptions {
	    length: number;
	    highlights?: IHighlight[];
	    cssClass?: string;
	}
	interface IHighlightsOptions {
	    highlights: IHighlight[];
	    cssClass?: string;
	}
	interface IHelperStreamHighlightOptions {
	    termsToHighlight: IHighlightTerm;
	    phrasesToHighlight: IHighlightPhrase;
	    opts?: IStreamHighlightOptions;
	}
	interface IPluralOptions {
	    singular: string;
	    plural: string;
	}
	class CoreHelpers {
	    constructor();
	    /**
	     * For backward compatibility reason, the "global" template helper should be available under the
	     * coveo namespace.
	     * @param scope
	     */
	    static exportAllHelpersGlobally(scope: IStringMap<any>): void;
	}

}
declare module Coveo {
	class TableTemplate extends TemplateList {
	    instantiateRoleToString(role: TemplateRole): string;
	    instantiateRoleToElement(role: TemplateRole): Promise<HTMLElement>;
	    protected getFallbackTemplate(): Template;
	    hasTemplateWithRole(role: TemplateRole): Template;
	}

}
declare module Coveo {
	interface ResultToRender {
	    resultElement: HTMLElement;
	    componentsInside: Component[];
	}
	class ResultContainer {
	    static resultCurrentlyBeingRendered: IQueryResult;
	    resultContainerElement: Dom;
	    constructor(resultContainer: HTMLElement, searchInterface: SearchInterface);
	    empty(): void;
	    addClass(classToAdd: string): void;
	    isEmpty(): boolean;
	    hideChildren(): void;
	    getResultElements(): HTMLElement[];
	     el: HTMLElement;
	}

}
declare module Coveo {
	class ResultListRenderer {
	    protected resultListOptions: IResultListOptions;
	    protected autoCreateComponentsFn: Function;
	    constructor(resultListOptions: IResultListOptions, autoCreateComponentsFn: Function);
	    renderResults(resultElements: HTMLElement[], append: boolean, resultDisplayedCallback: (result: IQueryResult, resultElem: HTMLElement) => any): Promise<void>;
	    protected getStartFragment(resultElements: HTMLElement[], append: boolean): Promise<DocumentFragment>;
	    protected getEndFragment(resultElements: HTMLElement[], append: boolean): Promise<DocumentFragment>;
	}

}
declare module Coveo {
	class ResultListCardRenderer extends ResultListRenderer {
	    getEndFragment(resultElements: HTMLElement[]): Promise<DocumentFragment>;
	}

}
declare module Coveo {
	class ResultListTableRenderer extends ResultListRenderer {
	    protected resultListOptions: IResultListOptions;
	    protected autoCreateComponentsFn: Function;
	    constructor(resultListOptions: IResultListOptions, autoCreateComponentsFn: Function);
	    getStartFragment(resultElements: HTMLElement[], append: boolean): Promise<DocumentFragment>;
	    getEndFragment(resultElements: HTMLElement[], append: boolean): Promise<DocumentFragment>;
	}

}
declare module Coveo {
	class ResponsiveResultLayout implements IResponsiveComponent {
	    coveoRoot: Dom;
	    ID: string;
	    static init(root: HTMLElement, component: ResultLayoutSelector, options: IResponsiveComponentOptions): void;
	    constructor(coveoRoot: Dom, ID: string, options: IResponsiveComponentOptions, responsiveDropdown?: ResponsiveDropdown);
	    registerComponent(accept: Component): boolean;
	    handleResizeEvent(): void;
	}

}
declare module Coveo {
	interface IActiveLayouts {
	    button: {
	        el: HTMLElement;
	        visible: boolean;
	    };
	    enabled: boolean;
	}
	interface IResultLayoutOptions {
	    mobileLayouts: string[];
	    tabletLayouts: string[];
	    desktopLayouts: string[];
	}
	/**
	 * The ResultLayoutSelector component allows the end user to switch between multiple {@link ResultList} components that have
	 * different {@link ResultList.options.layout} values.
	 *
	 * This component automatically populates itself with buttons to switch between the ResultList components that have a
	 * valid layout value (see the {@link ValidLayout} type).
	 *
	 * See also the [Result Layouts](https://docs.coveo.com/en/360/) documentation.
	 *
	 * @availablesince [February 2018 Release (v2.3826.10)](https://docs.coveo.com/en/410/#february-2018-release-v2382610)
	 */
	class ResultLayoutSelector extends Component {
	    element: HTMLElement;
	    options: IResultLayoutOptions;
	    static ID: string;
	    static aliases: string[];
	    static doExport: () => void;
	    static validLayouts: ValidLayout[];
	    currentLayout: ValidLayout;
	    /**
	     * The component options
	     * @componentOptions
	     */
	    static options: IResultLayoutOptions;
	    /**
	     * Creates a new ResultLayoutSelector component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the ResultLayout component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IResultLayoutOptions, bindings?: IComponentBindings);
	     activeLayouts: {
	        [key: string]: IActiveLayouts;
	    };
	    /**
	     * Changes the current layout.
	     *
	     * Also logs a `resultLayoutChange` event in the usage analytics with the new layout as metadeta.
	     *
	     * Triggers a new query.
	     *
	     * @param layout The new layout. The page must contain a valid {@link ResultList} component with a matching
	     * {@link ResultList.options.layout} value for this method to work.
	     */
	    changeLayout(layout: ValidLayout): void;
	    /**
	     * Gets the current layout (`list`, `card` or `table`).
	     * @returns {string} The current current layout.
	     */
	    getCurrentLayout(): ValidLayout;
	    disableLayouts(layouts: ValidLayout[]): void;
	    enableLayouts(layouts: ValidLayout[]): void;
	}

}
declare module Coveo {
	interface ITemplateToHtml {
	    resultTemplate: Template;
	    queryStateModel: QueryStateModel;
	    searchInterface: SearchInterface;
	}
	class TemplateToHtml {
	    args: ITemplateToHtml;
	    constructor(args: ITemplateToHtml);
	    buildResults(results: IQueryResults, layout: RendererValidLayout, currentlyDisplayedResults: IQueryResult[]): Promise<HTMLElement[]>;
	    buildResult(result: IQueryResult, layout: RendererValidLayout, currentlyDisplayedResults: IQueryResult[]): Promise<HTMLElement>;
	    autoCreateComponentsInsideResult(element: HTMLElement, result: IQueryResult): IInitResult;
	}

}
declare module Coveo {
	/**
	 * The `ResultList` component is responsible for displaying query results by applying one or several result templates
	 * (see [Result Templates](https://docs.coveo.com/en/413/)).
	 *
	 * It is possible to include multiple `ResultList` components along with a single `ResultLayout`
	 * component in a search page to provide different result layouts (see
	 * [Result Layouts](https://docs.coveo.com/en/360/)).
	 *
	 * This component supports infinite scrolling (see the
	 * [`enableInfiniteScroll`]{@link ResultList.options.enableInfiniteScroll} option).
	 */
	class ResultList extends Component {
	    element: HTMLElement;
	    options: IResultListOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the ResultList
	     * @componentOptions
	     */
	    static options: IResultListOptions;
	    static resultCurrentlyBeingRendered: IQueryResult;
	    currentlyDisplayedResults: IQueryResult[];
	    /**
	     * Creates a new `ResultList` component. Binds various event related to queries (e.g., on querySuccess ->
	     * renderResults). Binds scroll event if the [`enableInfiniteScroll`]{@link ResultList.options.enableInfiniteScroll}
	     * option is `true`.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `ResultList` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param elementClassId The class that this component should instantiate. Components that extend the base ResultList
	     * use this. Default value is `CoveoResultList`.
	     */
	    constructor(element: HTMLElement, options?: IResultListOptions, bindings?: IComponentBindings, elementClassId?: string);
	    /**
	     * Get the fields needed to be automatically included in the query for this result list.
	     * @returns {string[]}
	     */
	    getAutoSelectedFieldsToInclude(): string[];
	    /**
	     * Empties the current result list content and appends the given array of HTMLElement.
	     *
	     * Can append to existing elements in the result list, or replace them.
	     *
	     * Triggers the `newResultsDisplayed` and `newResultDisplayed` events.
	     * @param resultsElement
	     * @param append
	     */
	    renderResults(resultElements: HTMLElement[], append?: boolean): Promise<void>;
	    /**
	     * Builds and returns an array of HTMLElement with the given result set.
	     * @param results the result set to build an array of HTMLElement from.
	     */
	    buildResults(results: IQueryResults): Promise<HTMLElement[]>;
	    /**
	     * Builds and returns an HTMLElement for the given result.
	     * @param result the result to build an HTMLElement from.
	     * @returns {HTMLElement}
	     */
	    buildResult(result: IQueryResult): Promise<HTMLElement>;
	    /**
	     * Executes a query to fetch new results. After the query returns, renders the new results.
	     *
	     * Asserts that there are more results to display by verifying whether the last query has returned as many results as
	     * requested.
	     *
	     * Asserts that the `ResultList` is not currently fetching results.
	     * @param count The number of results to fetch and display.
	     */
	    displayMoreResults(count: number): Promise<IQueryResults>;
	     templateToHtml: TemplateToHtml;
	    /**
	     * Gets the list of currently displayed result.
	     * @returns {IQueryResult[]}
	     */
	    getDisplayedResults(): IQueryResult[];
	    /**
	     * Gets the list of currently displayed result HTMLElement.
	     * @returns {HTMLElement[]}
	     */
	    getDisplayedResultsElements(): HTMLElement[];
	    enable(): void;
	    disable(): void;
	    protected autoCreateComponentsInsideResult(element: HTMLElement, result: IQueryResult): IInitResult;
	    protected triggerNewResultDisplayed(result: IQueryResult, resultElement: HTMLElement): void;
	    protected triggerNewResultsDisplayed(): void;
	    protected handleBuildingQuery(args: IBuildingQueryEventArgs): void;
	    protected handleChangeLayout(args: IChangeLayoutEventArgs): void;
	    hasPotentiallyMoreResultsToDisplay(): boolean;
	    protected initResultContainerAddToDom(): void;
	}

}
declare module Coveo {
	interface IResultLinkOptions {
	    logAnalytics?: (href: string) => void;
	    onClick?: (e: Event, result: IQueryResult) => any;
	    field?: IFieldOption;
	    openInOutlook?: boolean;
	    openQuickview?: boolean;
	    alwaysOpenInNewWindow?: boolean;
	    hrefTemplate?: string;
	    titleTemplate?: string;
	}

}
declare module Coveo {
	function bindAnalyticsToLink(element: HTMLElement, logAnalytics: () => void): void;

}
declare module Coveo {
	/**
	 * The `ResultLink` component automatically transform a search result title into a clickable link pointing to the
	 * original item.
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 */
	class ResultLink extends Component {
	    element: HTMLElement;
	    options: IResultLinkOptions;
	    bindings: IResultsComponentBindings;
	    result: IQueryResult;
	    os: OS_NAME;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the ResultLink
	     * @componentOptions
	     */
	    static options: IResultLinkOptions;
	    /**
	     * Creates a new `ResultLink` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `ResultLink` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     * @param os
	     */
	    constructor(element: HTMLElement, options: IResultLinkOptions, bindings?: IResultsComponentBindings, result?: IQueryResult, os?: OS_NAME);
	    renderUri(element: HTMLElement, result?: IQueryResult): void;
	    /**
	     * Opens the result in the same window, no matter how the actual component is configured for the end user.
	     * @param logAnalytics Specifies whether the method should log an analytics event.
	     */
	    openLink(logAnalytics?: boolean): void;
	    /**
	     * Opens the result in a new window, no matter how the actual component is configured for the end user.
	     * @param logAnalytics Specifies whether the method should log an analytics event.
	     */
	    openLinkInNewWindow(logAnalytics?: boolean): void;
	    /**
	     * Tries to open the result in Microsoft Outlook if the result has an `outlookformacuri` or `outlookuri` field.
	     *
	     * Normally, this implies the result should be a link to an email.
	     *
	     * If the needed fields are not present, this method does nothing.
	     * @param logAnalytics Specifies whether the method should log an analytics event.
	     */
	    openLinkInOutlook(logAnalytics?: boolean): void;
	    /**
	     * Opens the link in the same manner the end user would.
	     *
	     * This essentially simulates a click on the result link.
	     *
	     * @param logAnalytics Specifies whether the method should log an analytics event.
	     */
	    openLinkAsConfigured(logAnalytics?: boolean): void;
	    protected bindEventToOpen(): boolean;
	}

}
declare module Coveo {
	interface ITableDataSource extends Object {
	    content?: any;
	    width?: number;
	    children?: any[];
	    cellRenderer?: new () => any;
	}
	class TableBuilder {
	    build(sources: any[], table: Dom, gridOptions?: any): Promise<{
	        grid: any;
	        gridOptions: any;
	    }>;
	    static thumbnailCell(result: IQueryResult, bindings: IComponentBindings): any;
	}
	class ThumbnailHtmlRenderer implements Object {
	    init(params?: {
	        value: {
	            result: IQueryResult;
	            bindings: IComponentBindings;
	        };
	        api: any;
	    }): void;
	    getGui(): HTMLElement;
	    refresh(params: any): boolean;
	}
	class GenericHtmlRenderer implements Object {
	    init(params?: any): void;
	    getGui(): HTMLElement;
	    refresh(params: any): boolean;
	}

}
declare module Coveo {
	class RankingInfoTable implements IRelevanceInspectorTab {
	    results: IQueryResult[];
	    bindings: IComponentBindings;
	    gridOptions: any;
	    constructor(results: IQueryResult[], bindings: IComponentBindings);
	    build(): Promise<Dom>;
	}

}
declare module Coveo {
	class MetaDataTable implements IRelevanceInspectorTab {
	    results: IQueryResult[];
	    bindings: IComponentBindings;
	    gridOptions: any;
	    constructor(results: IQueryResult[], bindings: IComponentBindings);
	    build(): Promise<Dom>;
	}
	class FieldValuesRenderer implements Object {
	    init(params: any): void;
	    getGui(): HTMLElement;
	    refresh(params: any): boolean;
	}

}
declare module Coveo {
	class RelevanceInspectorTabs {
	    onTabChange: (id: string) => void;
	    navigationSection: Dom;
	    tabContentSection: Dom;
	    constructor(onTabChange: (id: string) => void);
	    select(id: string): void;
	    addNavigation(caption: string, id: string): this;
	    addContent(content: Dom, targetId: string): this;
	    addSection(caption: string, content: Dom, id: string): this;
	}

}
declare module Coveo {
	type GenericValueOutputType = string | number | string[] | any | boolean | any;
	class GenericValueOutput {
	    output(section: GenericValueOutputType): ITableDataSource;
	}

}
declare module Coveo {
	class ExecutionReportGenericSection {
	    build(executionReportSection: IExecutionReportSection): any;
	}

}
declare module Coveo {
	interface IUserIDExecutionReport {
	    name: string;
	    kind: string;
	    provider: string;
	    info: any;
	}
	interface IExecutionReportAuthenticationSection extends IExecutionReportSection {
	    name: 'PerformAuthentication';
	    configured: {
	        primary: string;
	        secondary: string[];
	        mandatory: string[];
	    };
	    result: {
	        userIds: IUserIDExecutionReport[];
	        queryRestrictions: any;
	        roles: string[];
	        userGroups: string[];
	    };
	}
	class ExecutionReportAuthenticationSection implements IExecutionReportSectionBuilder {
	    build(executionReport: IExecutionReport): Promise<{
	        container: Dom;
	        gridOptions: any;
	    }>;
	}

}
declare module Coveo {
	interface IExecutionReportResolvePipelineSection extends IExecutionReportSection {
	    result: {
	        pipeline: string;
	        splitTest: {
	            name: string;
	            ratio: number;
	        };
	    };
	}
	class ExecutionReportResolvedPipelineSection implements IExecutionReportSectionBuilder {
	    build(executionReport: IExecutionReport): Promise<{
	        container: Dom;
	        gridOptions: any;
	    }>;
	}

}
declare module Coveo {
	interface IExecutionReportQueryOverrideSection extends IExecutionReportSection {
	    applied: string[];
	}
	class ExecutionReportQueryOverrideSection implements IExecutionReportSectionBuilder {
	    build(executionReport: IExecutionReport): Promise<{
	        container: Dom;
	        gridOptions: any;
	    }>;
	}

}
declare module Coveo {
	interface IExecutionReportSimpleSection extends IExecutionReportSection {
	    applied: string[];
	}
	class ExecutionReportSimpleSection implements IExecutionReportSectionBuilder {
	    topLevelProperty: EXECUTION_REPORT_SECTION;
	    secondLevelProperty: EXECUTION_REPORT_SECTION;
	    sectionTitle: string;
	    constructor(topLevelProperty: EXECUTION_REPORT_SECTION, secondLevelProperty: EXECUTION_REPORT_SECTION, sectionTitle: string);
	    build(executionReport: IExecutionReport): Promise<{
	        container: Dom;
	        gridOptions: any;
	    }>;
	}

}
declare module Coveo {
	interface IExecutionReportEffectiveIndexQuerySection {
	    result: {
	        in: any;
	    };
	}
	class ExecutionReportEffectiveIndexQuerySection implements IExecutionReportSectionBuilder {
	    build(executionReport: IExecutionReport): Promise<{
	        container: Dom;
	    }>;
	}

}
declare module Coveo {
	class ExecutionReportRankingModifiers {
	    build(results: IQueryResult[], rankingExpressions: IRankingExpression[], bindings: IComponentBindings): Promise<{
	        container: Dom;
	        gridOptions: any;
	    }>;
	}

}
declare module Coveo {
	type IRefinedQueriesFromTopClicks = {
	    q: string;
	    score: number;
	};
	interface IExecutionReportITDSection extends IExecutionReportSection {
	    refinedQueries: IRefinedQueriesFromTopClicks[];
	}
	interface IExecutionReportMLTopClicksInput extends IExecutionReportSection {
	    largeQueryKeywords: string[];
	}
	class ExecutionReportITDSection implements IExecutionReportSectionBuilder {
	    build(executionReport: IExecutionReport): Promise<{
	        container: Dom;
	        gridOptions: any;
	    }>;
	}

}
declare module Coveo {
	interface IExecutionReport {
	    duration: number;
	    children: IExecutionReportSection[];
	}
	interface IRankingExpressionExecutionReport {
	    expression: string;
	    modifer: number;
	    isConstant: boolean;
	}
	enum EXECUTION_REPORT_SECTION {
	    PERFORM_AUTHENTICATION,
	    RESOLVE_PIPELINE,
	    QUERY_PARAM_OVERRIDE,
	    THESAURUS,
	    PREPROCESS_QUERY_EXPRESSION,
	    PREPROCESS_QUERY,
	    STOP_WORDS,
	    FILTERS,
	    RANKING,
	    TOP_RESULT,
	    RANKING_WEIGHT,
	    INDEX_QUERY,
	    TOP_CLICKS,
	    PARTIAL_MATCH,
	    NONE,
	}
	interface IExecutionReportSection {
	    name: string;
	    duration: number;
	    result: any;
	    description: string;
	    children?: IExecutionReportSection[];
	    applied?: string[];
	}
	interface IExecutionReportSectionBuilder {
	    build(executionReport: IExecutionReport): Promise<{
	        container: Dom;
	        gridOptions?: any;
	    }>;
	}
	class ExecutionReport implements IRelevanceInspectorTab {
	    results: IQueryResults;
	    bindings: IComponentBindings;
	    gridOptions: any;
	    constructor(results: IQueryResults, bindings: IComponentBindings);
	    static standardSectionHeader(title: string): {
	        container: Dom;
	        agGridElement: Dom;
	    };
	    build(): Promise<Dom>;
	}

}
declare module Coveo {
	class AvailableFieldsTable implements IRelevanceInspectorTab {
	    bindings: IComponentBindings;
	    gridOptions: any;
	    constructor(bindings: IComponentBindings);
	    build(): Promise<Dom>;
	}
	class AvailableFieldsSampleValue implements Object {
	    init(params: any): void;
	    getGui(): HTMLElement;
	    refresh(): boolean;
	}
	class AvailableFieldsDatasource implements Object {
	    dataSource: any[];
	    constructor(dataSource: any[]);
	    getRows(params: any): void;
	}

}
declare module Coveo {
	class InlineRankingInfo {
	    result: IQueryResult;
	    constructor(result: IQueryResult);
	    build(): Dom;
	}

}
declare module Coveo {
	interface IRelevanceInspectorConstructor {
	    new (element: HTMLElement, bindings: IComponentBindings): RelevanceInspector;
	}
	interface IRelevanceInspectorTab {
	    gridOptions: any;
	}
	class RelevanceInspector {
	    element: HTMLElement;
	    bindings: IComponentBindings;
	    constructor(element: HTMLElement, bindings: IComponentBindings);
	    modalBox: any;
	    hide(): void;
	    show(): void;
	    open(): Promise<void>;
	}

}
declare module Coveo {
	type ValidStorageProvider = 'local' | 'session';
	class StorageUtils<T> {
	    constructor(id: string, storageProvider?: ValidStorageProvider);
	    save(data: T): void;
	    load(): T;
	    remove(key?: string): void;
	}

}
declare module Coveo {
	class ScrollRestorer {
	    root: HTMLElement;
	    constructor(root: HTMLElement, queryStateModel: QueryStateModel);
	    handleNewResultsDisplayed(args: IDisplayedNewResultsEventArgs): void;
	}

}
declare module Coveo {
	interface ISearchInterfaceOptions {
	    enableHistory?: boolean;
	    enableAutomaticResponsiveMode?: boolean;
	    useLocalStorageForHistory?: boolean;
	    resultsPerPage?: number;
	    excerptLength?: number;
	    expression?: IQueryExpression;
	    filterField?: IFieldOption;
	    autoTriggerQuery?: boolean;
	    timezone?: string;
	    enableDebugInfo?: boolean;
	    enableCollaborativeRating?: boolean;
	    enableDuplicateFiltering?: boolean;
	    hideUntilFirstQuery?: boolean;
	    firstLoadingAnimation?: any;
	    pipeline?: string;
	    maximumAge?: number;
	    searchPageUri?: string;
	    initOptions?: any;
	    endpoint?: SearchEndpoint;
	    originalOptionsObject?: any;
	    allowQueriesWithoutKeywords?: boolean;
	    responsiveMediumBreakpoint?: number;
	    responsiveSmallBreakpoint?: number;
	    responsiveMode?: ValidResponsiveMode;
	    enableScrollRestoration?: boolean;
	    modalContainer?: HTMLElement;
	}
	interface IMissingTermManagerArgs {
	    element: HTMLElement;
	    queryStateModel: QueryStateModel;
	    queryController: QueryController;
	    usageAnalytics: IAnalyticsClient;
	}
	/**
	 * The SearchInterface component is the root and main component of your Coveo search interface. You should place all
	 * other Coveo components inside the SearchInterface component.
	 *
	 * It is also on the HTMLElement of the SearchInterface component that you call the {@link init} function.
	 *
	 * It is advisable to specify a unique HTML `id` attribute for the SearchInterface component in order to be able to
	 * reference it easily.
	 *
	 * **Example:**
	 *
	 * ```html
	 * <head>
	 *
	 * [ ... ]
	 *
	 * <script>
	 *   document.addEventListener('DOMContentLoaded', function() {
	 *
	 *     [ ... ]
	 *     // The init function is called on the SearchInterface element, in this case, the body of the page.
	 *     Coveo.init(document.body);
	 *
	 *     [ ... ]
	 *
	 *     });
	 * </script>
	 *
	 * [ ... ]
	 * </head>
	 *
	 * <!-- Specifying a unique HTML id attribute for the SearchInterface component is good practice. -->
	 * <body id='search' class='CoveoSearchInterface' [ ... other options ... ]>
	 *
	 *   [ ... ]
	 *
	 *   <!-- You should place all other Coveo components here, inside the SearchInterface component. -->
	 *
	 *   [ ... ]
	 *
	 * </body>
	 * ```
	 */
	class SearchInterface extends RootComponent implements IComponentBindings {
	    element: HTMLElement;
	    options: ISearchInterfaceOptions;
	    analyticsOptions: any;
	    _window: Window;
	    static ID: string;
	    /**
	     * The options for the search interface
	     * @componentOptions
	     */
	    static options: ISearchInterfaceOptions;
	    static SMALL_INTERFACE_CLASS_NAME: string;
	    root: HTMLElement;
	    queryStateModel: QueryStateModel;
	    componentStateModel: ComponentStateModel;
	    queryController: QueryController;
	    componentOptionsModel: ComponentOptionsModel;
	    usageAnalytics: IAnalyticsClient;
	    historyManager: IHistoryManager;
	    scrollRestorer: ScrollRestorer;
	    /**
	     * Allows to get and set the different breakpoints for mobile and tablet devices.
	     *
	     * This is useful, amongst other, for {@link Facet}, {@link Tab} and {@link ResultList}
	     */
	    responsiveComponents: ResponsiveComponents;
	    isResultsPerPageModifiedByPipeline: boolean;
	    ariaLive: IAriaLive;
	    /**
	     * Creates a new SearchInterface. Initialize various singletons for the interface (e.g., usage analytics, query
	     * controller, state model, etc.). Binds events related to the query.
	     * @param element The HTMLElement on which to instantiate the component. This cannot be an `HTMLInputElement` for
	     * technical reasons.
	     * @param options The options for the SearchInterface.
	     * @param analyticsOptions The options for the {@link Analytics} component. Since the Analytics component is normally
	     * global, it needs to be passed at initialization of the whole interface.
	     * @param _window The window object for the search interface. Used for unit tests, which can pass a mock. Default is
	     * the global window object.
	     */
	    constructor(element: HTMLElement, options?: ISearchInterfaceOptions, analyticsOptions?: any, _window?: Window);
	    resultsPerPage: number;
	    getOmniboxAnalytics(): OmniboxAnalytics;
	    /**
	     * Attaches a component to the search interface. This allows the search interface to easily list and iterate over its
	     * components.
	     * @param type Normally, the component type is a unique identifier without the `Coveo` prefix (e.g., `CoveoFacet` ->
	     * `Facet`, `CoveoPager` -> `Pager`, `CoveoQuerybox` -> `Querybox`, etc.).
	     * @param component The component instance to attach.
	     */
	    attachComponent(type: string, component: BaseComponent): void;
	    /**
	     * Detaches a component from the search interface.
	     * @param type Normally, the component type is a unique identifier without the `Coveo` prefix (e.g., `CoveoFacet` ->
	     * `Facet`, `CoveoPager` -> `Pager`, `CoveoQuerybox` -> `Querybox`, etc.).
	     * @param component The component instance to detach.
	     */
	    detachComponent(type: string, component: BaseComponent): void;
	    /**
	     * Returns the bindings, or environment, for the current component.
	     * @returns {IComponentBindings}
	     */
	    getBindings(): {
	        root: HTMLElement;
	        queryStateModel: QueryStateModel;
	        queryController: QueryController;
	        searchInterface: SearchInterface;
	        componentStateModel: ComponentStateModel;
	        componentOptionsModel: ComponentOptionsModel;
	        usageAnalytics: IAnalyticsClient;
	    };
	    /**
	     * Gets the query context for the current search interface.
	     *
	     * If the search interface has performed at least one query, it will try to resolve the context from the last query sent to the Coveo Search API.
	     *
	     * If the search interface has not performed a query yet, it will try to resolve the context from any avaiable {@link PipelineContext} component.
	     *
	     * If multiple {@link PipelineContext} components are available, it will merge all context values together.
	     *
	     * **Note:**
	     * Having multiple PipelineContext components in the same search interface is not recommended, especially if some context keys are repeated across those components.
	     *
	     * If no context is found, returns `any`
	     */
	    getQueryContext(): Context;
	    /**
	     * Gets all the components of a given type.
	     * @param type Normally, the component type is a unique identifier without the `Coveo` prefix (e.g., `CoveoFacet` ->
	     * `Facet`, `CoveoPager` -> `Pager`, `CoveoQuerybox` -> `Querybox`, etc.).
	     */
	    getComponents<T>(type: string): T[];
	    /**
	     * Detaches from the SearchInterface every component that is inside the given element.
	     * @param element
	     */
	    detachComponentsInside(element: HTMLElement): void;
	    protected initializeAnalytics(): IAnalyticsClient;
	}
	interface IStandaloneSearchInterfaceOptions extends ISearchInterfaceOptions {
	    redirectIfEmpty?: boolean;
	}
	class StandaloneSearchInterface extends SearchInterface {
	    element: HTMLElement;
	    options: IStandaloneSearchInterfaceOptions;
	    analyticsOptions: any;
	    _window: Window;
	    static ID: string;
	    static options: IStandaloneSearchInterfaceOptions;
	    constructor(element: HTMLElement, options?: IStandaloneSearchInterfaceOptions, analyticsOptions?: any, _window?: Window);
	    handleRedirect(e: Event, data: INewQueryEventArgs): void;
	    redirectToURL(url: string): void;
	    redirectToSearchPage(searchPage: string, hashValueToUse?: string): void;
	}

}
declare module Coveo {
	/**
	 * The `IQueryResult` interface describes a single result returned by the Coveo REST Search API.
	 */
	interface IQueryResult {
	    /**
	     * Contains the title of the item.
	     */
	    title: string;
	    titleHighlights: IHighlight[];
	    /**
	     * Contains the URI of the item.
	     */
	    uri: string;
	    /**
	     * Contains a printable URI (or path) to the item.
	     */
	    printableUri: string;
	    printableUriHighlights: IHighlight[];
	    /**
	     * Contains the clickable URI of the item, which you can set on an `href` in your search interface.
	     *
	     * See the [`ResultLink`]{@link ResultLink} component.
	     */
	    clickUri: string;
	    /**
	     * Contains the unique ID of the item.
	     *
	     * This parameter is useful when making certain calls to a [`SearchEndpoint`]{@link SearchEndpoint}.
	     */
	    uniqueId: string;
	    /**
	     * Contains an excerpt of the item. Can be empty for certain types of items (e.g., images, videos, etc.).
	     *
	     * See the [`Excerpt`]{@link Excerpt} component.
	     */
	    excerpt: string;
	    excerptHighlights: IHighlight[];
	    firstSentences: string;
	    firstSentencesHighlights: IHighlight[];
	    /**
	     * Contains a value specifying whether the item has an HTML version.
	     *
	     * See the [`Quickview`]{@link Quickview} component.
	     */
	    hasHtmlVersion: boolean;
	    hasMobileHtmlVersion: boolean;
	    /**
	     * Contains the list of flags for the item. Values are separated by a semicolon characters (`;`).
	     */
	    flags: string;
	    summary: string;
	    summaryHighlights: IHighlight[];
	    /**
	     * Contains ranking information, which the Coveo REST Search API returns along with the item when the query
	     * [`debug`]{@link IQuery.debug} property is `true`.
	     */
	    rankingInfo: string;
	    /**
	     * **Note:**
	     *
	     * > The Coveo Cloud V2 platform does not support collaborative rating. Therefore, this property is obsolete in Coveo Cloud V2.
	     *
	     * Contains the collaborative rating value for the item.
	     *
	     * See the [`ResultRating`]{@link ResultRating} component.
	     */
	    rating?: number;
	    /**
	     * Contains the raw field values of the item, expressed as key-value pairs.
	     */
	    raw: any;
	    /**
	     * Contains the parent result of the item, if parent-child loading was performed.
	     *
	     * See the [`Folding`]{@link Folding} component.
	     */
	    parentResult?: IQueryResult;
	    /**
	     * Contains the child results of the item, if parent-child loading was performed.
	     *
	     * See the [`Folding`]{@link Folding} component.
	     */
	    childResults: IQueryResult[];
	    /**
	     * Contains a value that specifies whether the result was recommended by the Coveo Machine Learning service.
	     *
	     * See the [`Recommendation`]{@link Recommendation} component.
	     *
	     * See also [Coveo Machine Learning](https://docs.coveo.com/en/1727/).
	     */
	    isRecommendation: boolean;
	    /**
	     * Whether the result item was previously viewed by the user specified in the [userActions]{@link IQuery.userActions} request of the query.
	     */
	    isUserActionView?: boolean;
	    /**
	     * Specifies whether the result is a Featured Result in the Coveo Query Pipeline (see [Adding and Managing Query Pipeline Featured Results](https://docs.coveo.com/en/1961/)).
	     */
	    isTopResult: boolean;
	    termsToHighlight?: IHighlightTerm;
	    phrasesToHighlight: IHighlightPhrase;
	    rankingModifier?: string;
	    /**
	     * Contains the 0-based index value of the result, as returned by the Coveo REST Search API.
	     */
	    index?: number;
	    /**
	     * Contains the query UID, as returned by the Coveo REST Search API.
	     *
	     * This value is used mainly for usage analytics.
	     *
	     * The Coveo JavaScript Search Framework adds this property client-side to each result.
	     */
	    queryUid?: string;
	    pipeline?: string;
	    splitTestRun?: string;
	    moreResults?: () => Promise<IQueryResult[]>;
	    totalNumberOfChildResults?: number;
	    attachments?: IQueryResult[];
	    /**
	     * Contains the query state of the [`SearchInterface`]{@link SearchInterface} inside which this result is rendered.
	     *
	     * This value is used mainly to allow for conditional rendering of results templates.
	     *
	     * The Coveo JavaScript Search Framework adds this property client-side to each result.
	     */
	    state: {
	        [attribute: string]: any;
	    };
	    /**
	     * The [`SearchInterface`]{@link SearchInterface} inside which this result is rendered.
	     *
	     * This value is used mainly to allow for conditional rendering of results templates.
	     *
	     * The Coveo JavaScript Search Framework adds this property client-side to each result.
	     */
	    searchInterface: SearchInterface;
	    orphan?: boolean;
	    fields?: {
	        [name: string]: any;
	    };
	    /**
	     * The query terms that are not matched by the result.
	     */
	    absentTerms: string[];
	}

}
declare module Coveo {
	class Utils {
	    static isUndefined(obj: any): boolean;
	    static isNull(obj: any): boolean;
	    static isNullOrUndefined(obj: any): boolean;
	    static exists(obj: any): boolean;
	    static toNotNullString(str: string): string;
	    static anyTypeToString(value: any): string;
	    static isNullOrEmptyString(str: string): boolean;
	    static isNonEmptyString(str: string): boolean;
	    static isEmptyString(str: string): boolean;
	    static stringStartsWith(str: string, startWith: string): boolean;
	    static stringEndsWith(str: string, endsWith: string): boolean;
	    static isNonEmptyArray(obj: any): boolean;
	    static isEmptyArray(obj: any): boolean;
	    static isHtmlElement(obj: any): obj is HTMLElement;
	    static parseIntIfNotUndefined(str: string): number;
	    static parseFloatIfNotUndefined(str: string): number;
	    static round(num: number, decimals: number): number;
	    static parseBooleanIfNotUndefined(str: string): boolean;
	    static trim(value: string): string;
	    static encodeHTMLEntities(rawStr: string): string;
	    static decodeHTMLEntities(rawString: string): string;
	    static safeEncodeURIComponent(rawString: string): string;
	    static arrayEqual(array1: any[], array2: any[], sameOrder?: boolean): boolean;
	    static objectEqual(obj1: Object, obj2: Object): boolean;
	    static isCoveoField(field: string): boolean;
	    static escapeRegexCharacter(str: string): string;
	    static getCaseInsensitiveProperty(object: {}, name: string): any;
	    /**
	     * Get the value of the first field from the array and defined in the result.
	     *
	     * @param result a QueryResult in which to ge the fieldvalue.
	     * @param name One or multiple fieldNames to get the value.
	     */
	    static getFirstAvailableFieldValue(result: IQueryResult, fieldNames: Array<string>): string | any;
	    static getFieldValue(result: IQueryResult, name: string): any;
	    static throttle(func: any, wait: any, options?: {
	        leading?: boolean;
	        trailing?: boolean;
	    }, context?: any, args?: any): () => any;
	    static extendDeep(target: any, src: any): {};
	    static getQueryStringValue(key: any, queryString?: string): string;
	    static isValidUrl(str: string): boolean;
	    static debounce(func: Function, wait: number): (...args: any[]) => void;
	    static readCookie(name: string): string;
	    static toDashCase(camelCased: string): string;
	    static toCamelCase(dashCased: string): string;
	    static parseXml(xml: string): XMLDocument;
	    static copyObject<T>(target: T, src: T): void;
	    static copyObjectAttributes<T>(target: T, src: T, attributes: string[]): void;
	    static concatWithoutDuplicate(firstArray: any[], secondArray: any[]): any[];
	    static differenceBetweenObjects<T>(firstObject: IStringMap<T>, secondObject: IStringMap<T>): IStringMap<T>;
	    static resolveAfter<T>(ms: number, returns?: T): Promise<T>;
	    static reorderValuesByKeys<T, K extends string>(values: T[], order: K[], getKey: (value: T) => K): T[];
	}

}
declare module Coveo {
	class Assert {
	    static failureHandler: (message?: string) => void;
	    static fail(message?: string): void;
	    static check(condition: boolean, message?: string): void;
	    static isUndefined(obj: any): void;
	    static isNotUndefined(obj: any): void;
	    static isNull(obj: any): void;
	    static isNotNull(obj: any): void;
	    static exists(obj: any): void;
	    static doesNotExists(obj: any): void;
	    static isString(obj: any): void;
	    static stringStartsWith(str: string, start: string): void;
	    static isNonEmptyString(str: string): void;
	    static isNumber(obj: any): void;
	    static isLargerThan(expected: number, actual: number): void;
	    static isLargerOrEqualsThan(expected: number, actual: number): void;
	    static isSmallerThan(expected: number, actual: number): void;
	    static isSmallerOrEqualsThan(expected: number, actual: number): void;
	}
	class PreconditionFailedException extends Error {
	    message: string;
	    constructor(message: string);
	    toString(): string;
	}

}
declare module Coveo {
	interface IEndpointCaller {
	    call<T>(params: IEndpointCallParameters): Promise<ISuccessResponse<T>>;
	    options: IEndpointCallerOptions;
	}
	/**
	 * Parameters that can be used when calling an {@link EndpointCaller}
	 */
	interface IEndpointCallParameters {
	    /**
	     * Url to target
	     */
	    url: string;
	    /**
	     * Array of query string params.<br/>
	     * eg: ['foo=1','bar=2']
	     */
	    queryString: string[];
	    /**
	     * Body of the request.<br/>
	     * key -> value map (JSON)
	     */
	    requestData: IStringMap<any>;
	    /**
	     * Request data type.<br/>
	     * eg: "application/json", "application/x-www-form-urlencoded; charset=UTF-8"
	     */
	    requestDataType?: string;
	    /**
	     * Or HTTP verb : GET, POST, PUT, etc.
	     */
	    method: string;
	    /**
	     * responseType of the request.</br>
	     * eg: "text", "arraybuffer" etc.
	     */
	    responseType: string;
	    /**
	     * Flag to specify if the endpoint should return different type of error as actual 200 success for the browser, but with the error code/message contained in the response.
	     */
	    errorsAsSuccess: boolean;
	}
	/**
	 * Information about a request
	 */
	interface IRequestInfo<T> {
	    /**
	     * Url that was requested
	     */
	    url: string;
	    /**
	     * The query string parameters that were used for this request
	     */
	    queryString: string[];
	    /**
	     * The data that was sent for this request
	     */
	    requestData: IStringMap<T>;
	    /**
	     * The requestDataType that was used for this request
	     */
	    requestDataType: string;
	    /**
	     * The timestamp at which the request started
	     */
	    begun: Date;
	    /**
	     * The method that was used for this request
	     */
	    method: string;
	    /**
	     * The headers for the request.
	     */
	    headers?: IStringMap<string>;
	}
	/**
	 * A generic response
	 */
	interface IResponse<T> {
	    /**
	     * Data of the response
	     */
	    data?: T;
	}
	/**
	 * A generic success response
	 */
	interface ISuccessResponse<T> extends IResponse<T> {
	    /**
	     * The time that the successfull response took to complete
	     */
	    duration: number;
	    /**
	     * Data of the response
	     */
	    data: T;
	}
	/**
	 * An error response
	 */
	interface IErrorResponse extends IResponse<IStringMap<any>> {
	    /**
	     * Status code for the error
	     */
	    statusCode: number;
	    /**
	     * Data about the error
	     */
	    data?: {
	        /**
	         * Message for the error
	         */
	        message?: string;
	        /**
	         * Type of the error
	         */
	        type?: string;
	        /**
	         * A report provided by the search api
	         */
	        executionReport?: string;
	        [key: string]: any;
	    };
	}
	/**
	 * Possible options when creating a {@link EndpointCaller}
	 */
	interface IEndpointCallerOptions {
	    /**
	     * The access token to use for this endpoint.
	     */
	    accessToken?: string;
	    /**
	     * The username to use to log into this endpoint. Used for basic auth.<br/>
	     * Not used if accessToken is provided.
	     */
	    username?: string;
	    /**
	     * The password to use to log into this endpoint. Used for basic auth.<br/>
	     * Not used if accessToken is provided.
	     */
	    password?: string;
	    /**
	     * A function which will allow external code to modify all endpoint call parameters before they are sent by the browser.
	     *
	     * Used in very specific scenario where the network infrastructure require special request headers to be added or removed, for example.
	     */
	    requestModifier?: (params: IRequestInfo<any>) => IRequestInfo<any>;
	    /**
	     * The XmlHttpRequest implementation to use instead of the native one.
	     * If not specified, the native one is used.
	     */
	    xmlHttpRequest?: new () => XMLHttpRequest;
	    /**
	     * Specifies that the request (and the Coveo Search API) does not need any kind of authentication.<br/>
	     * This flag is only needed for specific setups when your requests are being blocked by your browser. If your queries are executing correctly, you do not need to bother.<br/>
	     * Setting this flag will prevent the withCredentials option to be set on the XMLHttpRequest, allowing performing cross-domain requests on a server that returns * in the Access-Control-Allow-Origin HTTP header.
	     */
	    anonymous?: boolean;
	}
	/**
	 * This class is in charge of calling an endpoint (eg: a {@link SearchEndpoint}).
	 *
	 * This means it's only uses to execute an XMLHttpRequest (for example), massage the response and check if there are errors.
	 *
	 * Will execute the call and return a Promise.
	 *
	 * Call using one of those options :
	 *
	 * * XMLHttpRequest for recent browser that support CORS, or if the endpoint is on the same origin.
	 * * XDomainRequest for older IE browser that do not support CORS.
	 * * Jsonp if all else fails, or is explicitly enabled.
	 */
	class EndpointCaller implements IEndpointCaller {
	    options: IEndpointCallerOptions;
	    logger: Logger;
	    /**
	     * Set this property to true to enable Jsonp call to the endpoint.<br/>
	     * Be aware that jsonp is "easier" to setup endpoint wise, but has a lot of drawback and limitation for the client code.<br/>
	     * Default to false.
	     * @type {boolean}
	     */
	    useJsonp: boolean;
	    /**
	     * Create a new EndpointCaller.
	     * @param options Specify the authentication that will be used for this endpoint. Not needed if the endpoint is public and has no authentication
	     */
	    constructor(options?: IEndpointCallerOptions);
	    static convertJsonToQueryString(json: any): string[];
	    static convertJsonToFormBody(json: any): string;
	    /**
	     * Generic call to the endpoint using the provided {@link IEndpointCallParameters}.<br/>
	     * Internally, will decide which method to use to call the endpoint :<br/>
	     * -- XMLHttpRequest for recent browser that support CORS, or if the endpoint is on the same origin.<br/>
	     * -- XDomainRequest for older IE browser that do not support CORS.<br/>
	     * -- Jsonp if all else fails, or is explicitly enabled.
	     * @param params The parameters to use for the call
	     * @returns {any} A promise of the given type
	     */
	    call<T>(params: IEndpointCallParameters): Promise<ISuccessResponse<T>>;
	    /**
	     * Call the endpoint using XMLHttpRequest. Used internally by {@link EndpointCaller.call}.<br/>
	     * Will try internally to handle error if it can.<br/>
	     * Promise will otherwise fail with the error type.
	     * @param requestInfo The info about the request
	     * @param responseType The responseType. Default to text. https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/responseType
	     * @returns {Promise<T>|Promise}
	     */
	    callUsingXMLHttpRequest<T>(requestInfo: IRequestInfo<T>, responseType?: string): Promise<ISuccessResponse<T>>;
	    /**
	     * Call the endpoint using XDomainRequest https://msdn.microsoft.com/en-us/library/cc288060(v=vs.85).aspx<br/>
	     * Used for IE8/9
	     * @param requestInfo The info about the request
	     * @returns {Promise<T>|Promise}
	     */
	    callUsingXDomainRequest<T>(requestInfo: IRequestInfo<T>): Promise<ISuccessResponse<T>>;
	    /**
	     * Call the endpoint using Jsonp https://en.wikipedia.org/wiki/JSONP<br/>
	     * Should be used for dev only, or for very special setup as using jsonp has a lot of drawbacks.
	     * @param requestInfo The info about the request
	     * @returns {Promise<T>|Promise}
	     */
	    callUsingAjaxJsonP<T>(requestInfo: IRequestInfo<T>): Promise<ISuccessResponse<T>>;
	}

}
declare module Coveo {
	/**
	 * The possible options when creating a {@link SearchEndpoint}
	 */
	interface ISearchEndpointOptions extends IEndpointCallerOptions {
	    /**
	     * The uri for the search endpoint. eg: cloudplatform.coveo.com/rest/search
	     */
	    restUri?: string;
	    version?: string;
	    /**
	     * Query string arguments to add to every request to the search endpoint.<br/>
	     * eg : {'foo':'bar', 'a':'b'}
	     */
	    queryStringArguments?: IStringMap<any>;
	    /**
	     * Specifies that the request (and the Coveo Search API) does not need any kind of authentication.<br/>
	     * This flag is only needed for specific setups when your requests are being blocked by your browser. If your queries are executing correctly, you do not need to bother.<br/>
	     * Setting this flag will prevent the withCredentials option to be set on the XMLHttpRequest, allowing performing cross-domain requests on a server that returns * in the Access-Control-Allow-Origin HTTP header.
	     */
	    anonymous?: boolean;
	    /**
	     * This allows using an OAuth2 or a search token to authenticate against the Search API.
	     */
	    accessToken?: string;
	    /**
	     * Specifies a function that, when called, will arrange for a new search token to be generated.<br/>
	     * It is expected to return a Promise that should be resolved with the new token once it's available.
	     */
	    renewAccessToken?: () => Promise<string>;
	    /**
	     * This is the username part of the credentials used to authenticate with the Search API using Basic Authentication.<br/>
	     * This option should only be used for development purposes. Including secret credentials in an HTML page that is sent to a client browser is not secure.
	     */
	    username?: string;
	    /**
	     * This is the password part of the credentials used to authenticate with the REST API.<br/>
	     * This option should only be used for development purposes. Including secret credentials in an HTML page that is sent to a client browser is not secure.
	     */
	    password?: string;
	    /**
	     * The uri for the Coveo search alerts service. If not specified, will automatically resolve using the restUri otherwise
	     */
	    searchAlertsUri?: string;
	    isGuestUser?: boolean;
	}
	/**
	 * Available options when calling against the {@link SearchEndpoint}
	 */
	interface IEndpointCallOptions {
	    authentication?: string[];
	    analyticsInformation?: AnalyticsInformation;
	}
	/**
	 * The `IGetDocumentOptions` interface describes the available options when calling against a
	 * [`SearchEndpoint`]{@link SearchEndpoint} to get an item.
	 */
	interface IGetDocumentOptions extends IEndpointCallOptions {
	}
	/**
	 * The `IViewAsHtmlOptions` interface describes the available options when calling against a
	 * [`SearchEndpoint`]{@link SearchEndpoint} to view an item as an HTMLElement (think: quickview).
	 */
	interface IViewAsHtmlOptions extends IEndpointCallOptions {
	    query?: string;
	    queryObject?: IQuery;
	    requestedOutputSize?: number;
	    contentType?: string;
	}
	interface IExchangeHandshakeTokenOptions {
	    handshakeToken: string;
	    accessToken?: string;
	}
	interface ISearchEndpoint {
	    accessToken: AccessToken;
	    options?: ISearchEndpointOptions;
	    getBaseUri(): string;
	    getBaseAlertsUri(): string;
	    getAuthenticationProviderUri(provider: string, returnUri: string, message: string): string;
	    exchangeHandshakeToken(options: IExchangeHandshakeTokenOptions): Promise<string>;
	    isJsonp(): boolean;
	    search(query: IQuery, callOptions?: IEndpointCallOptions): Promise<IQueryResults>;
	    fetchBinary(query: IQuery, callOptions?: IEndpointCallOptions): Promise<ArrayBuffer>;
	    plan(query: IQuery, callOptions?: IEndpointCallOptions): Promise<ExecutionPlan>;
	    /** @deprecated getExportToExcelLink does not factor in all query parameters (e.g. dynamic facets) due to GET request url length limitations.
	     * Please use `fetchBinary` instead to ensure all query parameters are used.
	     * */
	    getExportToExcelLink(query: IQuery, numberOfResults: number, callOptions?: IEndpointCallOptions): string;
	    getRawDataStream(documentUniqueId: string, dataStreamType: string, callOptions?: IViewAsHtmlOptions): Promise<ArrayBuffer>;
	    getDocument(documentUniqueID: string, callOptions?: IGetDocumentOptions): Promise<IQueryResult>;
	    getDocumentText(documentUniqueID: string, callOptions?: IEndpointCallOptions): Promise<string>;
	    getDocumentHtml(documentUniqueID: string, callOptions?: IViewAsHtmlOptions): Promise<HTMLDocument>;
	    getViewAsHtmlUri(documentUniqueID: string, callOptions?: IViewAsHtmlOptions): string;
	    getViewAsDatastreamUri(documentUniqueID: string, dataStreamType: string, callOptions?: IViewAsHtmlOptions): string;
	    listFieldValuesBatch(request: IListFieldValuesBatchRequest, callOptions?: IEndpointCallOptions): Promise<IIndexFieldValue[][]>;
	    listFieldValues(request: IListFieldValuesRequest, callOptions?: IEndpointCallOptions): Promise<IIndexFieldValue[]>;
	    listFields(callOptions?: IEndpointCallOptions): Promise<IFieldDescription[]>;
	    extensions(callOptions?: IEndpointCallOptions): Promise<IExtension[]> | Promise<IEndpointError>;
	    tagDocument(taggingRequest: ITaggingRequest, callOptions?: IEndpointCallOptions): Promise<boolean>;
	    getQuerySuggest(request: IQuerySuggestRequest, callOptions?: IEndpointCallOptions): Promise<IQuerySuggestResponse>;
	    facetSearch(request: IFacetSearchRequest, callOptions?: IEndpointCallOptions): Promise<IFacetSearchResponse>;
	    rateDocument(ratingRequest: IRatingRequest, callOptions?: IEndpointCallOptions): Promise<boolean>;
	    follow(request: ISubscriptionRequest): Promise<ISubscription>;
	    listSubscriptions(page?: number, callOptions?: IEndpointCallOptions): Promise<ISubscription[]>;
	    updateSubscription(subscription: ISubscription): Promise<ISubscription>;
	    deleteSubscription(subscription: ISubscription): Promise<ISubscription>;
	    logError(sentryLog: ISentryLog): Promise<boolean>;
	}

}
declare module Coveo {
	interface IListFieldsResult {
	    fields: IFieldDescription[];
	}

}
declare module Coveo {
	class AjaxError implements IEndpointError {
	    message: string;
	    status: number;
	    type: any;
	    name: any;
	    constructor(message: string, status: number);
	}

}
declare module Coveo {
	class MissingAuthenticationError implements IEndpointError {
	    provider: string;
	    type: string;
	    message: string;
	    isMissingAuthentication: boolean;
	    name: string;
	    constructor(provider: string);
	}

}
declare module Coveo {
	interface IBackOffRequest<T> {
	    fn: () => Promise<T>;
	    options?: any;
	}
	function setBackOffModule(newModule?: (request: () => Promise<any>, options?: any) => Promise<any>): void;
	class BackOffRequest {
	    static enqueue<T>(request: IBackOffRequest<T>): Promise<T>;
	}

}
declare module Coveo {
	class DefaultSearchEndpointOptions implements ISearchEndpointOptions {
	    restUri: string;
	    version: string;
	    queryStringArguments: IStringMap<string>;
	    anonymous: boolean;
	    accessToken: string;
	    renewAccessToken: () => Promise<string>;
	    username: string;
	    password: string;
	    searchAlertsUri: string;
	    isGuestUser: boolean;
	}
	/**
	 * The `SearchEndpoint` class allows the framework to perform HTTP requests against the Search API (e.g., searching, getting query suggestions, getting the HTML preview of an item, etc.).
	 *
	 * **Note:**
	 *
	 * When writing custom code that interacts with the Search API, be aware that executing queries directly through an instance of this class will *not* trigger any [query events](https://docs.coveo.com/en/417/#query-events).
	 *
	 * In some cases, this may be what you want. However, if you *do* want query events to be triggered (e.g., to ensure that standard components update themselves as expected), use the [`queryController`]{@link QueryController} instance instead.
	 *
	 * @externaldocs [JavaScript Search Framework Endpoint](https://docs.coveo.com/en/331/)
	 */
	class SearchEndpoint implements ISearchEndpoint {
	    options: ISearchEndpointOptions;
	    /**
	     * A map of all initialized `SearchEndpoint` instances.
	     *
	     * **Example:** `Coveo.SearchEndpoint.endpoints["default"]` returns the default endpoint that was created at initialization.
	     * @type {{}}
	     */
	    static endpoints: {
	        [endpoint: string]: SearchEndpoint;
	    };
	    /**
	     * Configures a demo search endpoint on a Coveo Cloud V1 organization whose index contains various types of non-secured items.
	     *
	     * **Note:** This method mainly exists for demo and testing purposes.
	     *
	     * @param otherOptions Additional options to apply for this endpoint.
	     */
	    static configureSampleEndpoint(otherOptions?: ISearchEndpointOptions): void;
	    /**
	     * Configures a demo search endpoint on a Coveo Cloud V2 organization whose index contains various types of non-secured items.
	     *
	     * **Note:** This method mainly exists for demo and testing purposes.
	     *
	     * @param otherOptions Additional options to apply for this endpoint.
	     */
	    static configureSampleEndpointV2(otherOptions?: ISearchEndpointOptions): void;
	    /**
	     * Configures a search endpoint on a Coveo Cloud V1 index.
	     * @param organization The organization ID of your Coveo Cloud index.
	     * @param token The token to use to execute query. If not specified, you will likely need to login when querying.
	     * @param uri The URI of the Coveo Cloud REST Search API. By default, this points to the production environment.
	     * @param otherOptions A set of additional options to use when configuring this endpoint.
	     */
	    static configureCloudEndpoint(organization?: string, token?: string, uri?: string, otherOptions?: ISearchEndpointOptions): void;
	    /**
	     * [Configures a new search endpoint](https://docs.coveo.com/331/#configuring-a-new-search-endpoint) on a Coveo Cloud V2 organization.
	     * @param organization The unique identifier of the target Coveo Cloud V2 organization (e.g., `mycoveocloudv2organizationg8tp8wu3`).
	     * @param token The access token to authenticate Search API requests with (i.e., an [API key](https://docs.coveo.com/105/) or a [search token](https://docs.coveo.com/56/)).
	     *
	     * **Note:** This token will also authenticate Usage Analytics Write API requests if the search interface initializes an [`Analytics`]{@link Analytics} component whose [`token`]{@link Analytics.options.token} option is unspecified.
	     * @param uri The base URI of the Search API.
	     *
	     * **Allowed values:**
	     *
	     * - `https://platform.cloud.coveo.com/rest/search` (for organizations in the standard Coveo Cloud V2 environment)
	     * - `https://platform-eu.cloud.coveo.com/rest/search` (for organizations with European [data residency](https://docs.coveo.com/en/2976/#data-residency-configuration))
	     * - `https://platform-au.cloud.coveo.com/rest/search` (for organizations with Australian data residency)
	     * - `https://platformhipaa.cloud.coveo.com/rest/search` (for [HIPAA](https://docs.coveo.com/1853/) organizations)
	     *
	     * **Default:** `https://platform.cloud.coveo.com/rest/search`
	     * @param otherOptions Additional options to apply for this endpoint (e.g., a [`renewAccessToken`]{@link ISearchEndpointOptions.renewAccessToken} function).
	     */
	    static configureCloudV2Endpoint(organization?: string, token?: string, uri?: string, otherOptions?: ISearchEndpointOptions): void;
	    /**
	     * Configures a search endpoint on a Coveo on-premise index.
	     * @param uri The URI of your Coveo Search API endpoint (e.g., `http://myserver:8080/rest/search`)
	     * @param token The token to use to execute query. If not specified, you will likely need to login when querying
	     * (unless your Coveo Search API endpoint is configured using advanced auth options, such as Windows auth or claims).
	     * @param otherOptions A set of additional options to use when configuring this endpoint.
	     */
	    static configureOnPremiseEndpoint(uri: string, token?: string, otherOptions?: ISearchEndpointOptions): void;
	    static  defaultEndpoint: SearchEndpoint;
	    static removeUndefinedConfigOption(config: ISearchEndpointOptions): ISearchEndpointOptions;
	    static mergeConfigOptions(first: ISearchEndpointOptions, second: ISearchEndpointOptions): ISearchEndpointOptions;
	    logger: Logger;
	    isRedirecting: boolean;
	    accessToken: AccessToken;
	    protected caller: EndpointCaller;
	    /**
	     * Creates a new `SearchEndpoint` instance.
	     * Uses a set of adequate default options, and merges these with the `options` parameter.
	     * Also creates an [`EndpointCaller`]{@link EndpointCaller} instance and uses it to communicate with the endpoint
	     * internally.
	     * @param options The custom options to apply to the new `SearchEndpoint`.
	     */
	    constructor(options?: ISearchEndpointOptions);
	    reset(): void;
	    /**
	     * Sets a function which allows external code to modify all endpoint call parameters before the browser sends them.
	     *
	     * **Note:**
	     * > This is useful in very specific scenarios where the network infrastructure requires special request headers to be
	     * > added or removed, for example.
	     * @param requestModifier The function.
	     */
	    setRequestModifier(requestModifier: (params: IRequestInfo<any>) => IRequestInfo<any>): void;
	    /**
	     * Gets the base URI of the Search API endpoint.
	     * @returns {string} The base URI of the Search API endpoint.
	     */
	    getBaseUri(): string;
	    /**
	     * Gets the base URI of the search alerts endpoint.
	     * @returns {string} The base URI of the search alerts endpoint.
	     */
	    getBaseAlertsUri(): string;
	    /**
	     * Gets the URI that can be used to authenticate against the given provider.
	     * @param provider The provider name.
	     * @param returnUri The URI to return to after the authentication is completed.
	     * @param message The authentication message.
	     * @param callOptions Additional set of options to use for this call.
	     * @param callParams Options injected by the applied decorators.
	     * @returns {string} The authentication provider URI.
	     */
	    getAuthenticationProviderUri(provider: string, returnUri?: string, message?: string, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): string;
	    /**
	     * Exchanges a temporary handshake token to either get an initial access token
	     * or extend the privileges of an existing access token.
	     *
	     * @param token - the temporary token.
	     * @returns {string} The access token.
	     */
	    exchangeHandshakeToken(options: IExchangeHandshakeTokenOptions, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<string>;
	    /**
	     * Indicates whether the search endpoint is using JSONP internally to communicate with the Search API.
	     * @returns {boolean} `true` in the search enpoint is using JSONP; `false` otherwise.
	     */
	    isJsonp(): boolean;
	    /**
	     * Performs a search on the index and returns a Promise of [`IQueryResults`]{@link IQueryResults}.
	     *
	     * This method slightly modifies the query results by adding additional information to each result (id, state object,
	     * etc.).
	     * @param query The query to execute. Typically, the query object is built using a
	     * [`QueryBuilder`]{@link QueryBuilder}.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<IQueryResults>} A Promise of query results.
	     */
	    search(query: IQuery, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<IQueryResults>;
	    /**
	     * Performs a search on the index and returns a Promise of `ArrayBuffer`.
	     *
	     * @param query The query to execute. Typically, the query object is built using a
	     * [`QueryBuilder`]{@link QueryBuilder}.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<ArrayBuffer>} A Promise of query results.
	     */
	    fetchBinary(query: IQuery, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<ArrayBuffer>;
	    /**
	     * Gets the plan of execution of a search request, without performing it.
	     *
	     * @param query The query to execute. Typically, the query object is built using a
	     * [`QueryBuilder`]{@link QueryBuilder}.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<ExecutionPlan>} A Promise of plan results.
	     */
	    plan(query: IQuery, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<ExecutionPlan>;
	    /**
	     * @deprecated getExportToExcelLink does not factor in all query parameters (e.g. dynamic facets) due to GET request url length limitations.
	     * Please use `fetchBinary` instead to ensure all query parameters are used.
	     *
	     * Gets a link / URI to download a query result set to the XLSX format.
	     *
	     * **Note:**
	     * > This method does not automatically download the query result set, but rather provides an URI from which to
	     * > download it.
	     * @param query The query for which to get the XLSX result set.
	     * @param numberOfResults The number of results to download.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {string} The download URI.
	     */
	    getExportToExcelLink(query: IQuery, numberOfResults: number, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): string;
	    /**
	     * Gets the raw datastream for an item. This is typically used to get a thumbnail for an item.
	     *
	     * Returns an array buffer.
	     *
	     * **Example:**
	     * ```
	     * let rawBinary = String.fromCharCode.apply(null, new Uint8Array(response));
	     * img.setAttribute('src', 'data:image/png;base64,' + btoa(rawBinary));
	     * ```
	     * @param documentUniqueId Typically, the {@link IQueryResult.uniqueId} on each result.
	     * @param dataStreamType Normally, `$Thumbnail`.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<TResult>|Promise<U>}
	     */
	    getRawDataStream(documentUniqueId: string, dataStreamType: string, callOptions?: IViewAsHtmlOptions, callParams?: IEndpointCallParameters): Promise<ArrayBuffer>;
	    /**
	     * Gets an URL from which it is possible to see the datastream for an item. This is typically used to get a
	     * thumbnail for an item.
	     * @param documentUniqueID Typically, the {@link IQueryResult.uniqueId} on each result.
	     * @param dataStreamType Normally, `$Thumbnail`.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {string} The datastream URL.
	     */
	    getViewAsDatastreamUri(documentUniqueID: string, dataStreamType: string, callOptions?: IViewAsHtmlOptions, callParams?: IEndpointCallParameters): string;
	    /**
	     * Gets a single item, using its `uniqueId`.
	     * @param documentUniqueID Typically, the {@link IQueryResult.uniqueId} on each result.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<IQueryResult>} A Promise of the item.
	     */
	    getDocument(documentUniqueID: string, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<IQueryResult>;
	    /**
	     * Gets the content of a single item, as text (think: quickview).
	     * @param documentUniqueID Typically, the {@link IQueryResult.uniqueId} on each result.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<string>} A Promise of the item content.
	     */
	    getDocumentText(documentUniqueID: string, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<string>;
	    /**
	     * Gets the content for a single item, as an HTMLDocument (think: quickview).
	     * @param documentUniqueID Typically, the {@link IQueryResult.uniqueId} on each result.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<HTMLDocument>} A Promise of the item content.
	     */
	    getDocumentHtml(documentUniqueID: string, callOptions?: IViewAsHtmlOptions, callParams?: IEndpointCallParameters): Promise<HTMLDocument>;
	    /**
	     * Gets an URL from which it is possible to see a single item content, as HTML (think: quickview).
	     * @param documentUniqueID Typically, the {@link IQueryResult.uniqueId} on each result.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {string} The URL.
	     */
	    getViewAsHtmlUri(documentUniqueID: string, callOptions?: IViewAsHtmlOptions, callParams?: IEndpointCallParameters): string;
	    /**
	     * Lists the possible field values for a request.
	     * @param request The request for which to list the possible field values.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<TResult>|Promise<U>} A Promise of the field values.
	     */
	    listFieldValues(request: IListFieldValuesRequest, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<IIndexFieldValue[]>;
	    /**
	     * Lists the possible field values for a request.
	     * @param request The request for which to list the possible field values.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<TResult>|Promise<U>} A Promise of the field values.
	     */
	    listFieldValuesBatch(request: IListFieldValuesBatchRequest, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<IIndexFieldValue[][]>;
	    /**
	     * Lists all fields for the index, and returns an array of their descriptions.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<TResult>|Promise<U>} A Promise of the index fields and descriptions.
	     */
	    listFields(callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<IFieldDescription[]>;
	    /**
	     * Lists all available query extensions for the search endpoint.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<IExtension[]>} A Promise of the extensions.
	     */
	    extensions(callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<IExtension[]>;
	    /**
	     * **Note:**
	     *
	     * > The Coveo Cloud V2 platform does not support collaborative rating. Therefore, this method is obsolete in Coveo Cloud V2.
	     *
	     * Rates a single item in the index (granted that collaborative rating is enabled on your index)
	     * @param ratingRequest The item id, and the rating to add.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<boolean>|Promise<T>}
	     */
	    rateDocument(ratingRequest: IRatingRequest, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<boolean>;
	    /**
	     * Tags a single item.
	     * @param taggingRequest The item id, and the tag action to perform.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<boolean>|Promise<T>}
	     */
	    tagDocument(taggingRequest: ITaggingRequest, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<boolean>;
	    /**
	     * Gets a list of query suggestions for a request.
	     * @param request The query, and the number of suggestions to return.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<IQuerySuggestResponse>} A Promise of query suggestions.
	     */
	    getQuerySuggest(request: IQuerySuggestRequest, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<IQuerySuggestResponse>;
	    getRevealQuerySuggest(request: IQuerySuggestRequest, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<IQuerySuggestResponse>;
	    /**
	     * Searches through the values of a facet.
	     * @param request The request for which to search through the values of a facet.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<IFacetSearchResponse>} A Promise of facet search results.
	     */
	    facetSearch(request: IFacetSearchRequest, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<IFacetSearchResponse>;
	    /**
	     * Follows an item, or a query result, using the search alerts service.
	     * @param request The subscription details.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<ISubscription>}
	     */
	    follow(request: ISubscriptionRequest, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<ISubscription>;
	    /**
	     * Gets a Promise of an array of the current subscriptions.
	     * @param page The page of the subscriptions.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {any}
	     */
	    listSubscriptions(page?: number, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<ISubscription[]>;
	    /**
	     * Updates a subscription with new parameters.
	     * @param subscription The subscription to update with new parameters.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<ISubscription>}
	     */
	    updateSubscription(subscription: ISubscription, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<ISubscription>;
	    /**
	     * Deletes a subscription.
	     * @param subscription The subscription to delete.
	     * @param callOptions An additional set of options to use for this call.
	     * @param callParams The options injected by the applied decorators.
	     * @returns {Promise<ISubscription>}
	     */
	    deleteSubscription(subscription: ISubscription, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<ISubscription>;
	    logError(sentryLog: ISentryLog, callOptions?: IEndpointCallOptions, callParams?: IEndpointCallParameters): Promise<boolean>;
	    nuke(): void;
	    protected createEndpointCaller(): void;
	    buildBaseUri(path: string): string;
	    buildSearchAlertsUri(path: string): string;
	}

}
declare module Coveo {
	function defaultLanguage(): void;
	function setLanguageAfterPageLoaded(): void;

}
declare module Coveo {
	interface IMenuItem {
	    text: string;
	    className: string;
	    tooltip?: string;
	    index?: number;
	    onOpen: () => void;
	    onClose?: () => void;
	    svgIcon?: string;
	    svgIconClassName?: string;
	}

}
declare module Coveo {
	interface ISettingsPopulateMenuArgs {
	    settings: Settings;
	    menuData: IMenuItem[];
	}
	interface ISettingsOptions {
	    menuDelay: number;
	}
	/**
	 * The Settings component renders a **Settings** button that the end user can click to access a popup menu from which
	 * it is possible to perform several contextual actions. The usual location of the **Settings** button in the page is to
	 * the right of the {@link Searchbox}.
	 *
	 * This component can reference several components to populate its popup menu:
	 * - {@link AdvancedSearch}
	 * - {@link ExportToExcel}
	 * - {@link PreferencesPanel} (see also {@link ResultsFiltersPreferences} and {@link ResultsPreferences})
	 * - {@link SearchAlerts} (see also {@link SearchAlertsMessage})
	 * - {@link ShareQuery}
	 */
	class Settings extends Component {
	    element: HTMLElement;
	    options: ISettingsOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for Settings
	     * @componentOptions
	     */
	    static options: ISettingsOptions;
	    /**
	     * Creates a new Settings component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the Settings component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options: ISettingsOptions, bindings?: IComponentBindings);
	    /**
	     * Opens the **Settings** popup menu.
	     */
	    open(): void;
	    /**
	     * Closes the **Settings** popup menu.
	     */
	    close(): void;
	}

}
declare module Coveo {
	class KeywordsInput implements IAdvancedSearchInput {
	    inputName: string;
	    root: HTMLElement;
	    protected input: TextInput;
	    constructor(inputName: string, root: HTMLElement);
	    reset(): void;
	    build(): HTMLElement;
	    setValue(value: string): void;
	    getValue(): string;
	    clear(): void;
	    updateQuery(queryBuilder: QueryBuilder): void;
	    protected onChange(): void;
	}

}
declare module Coveo {
	class AllKeywordsInput extends KeywordsInput {
	    root: HTMLElement;
	    constructor(root: HTMLElement);
	    getValue(): string;
	}

}
declare module Coveo {
	class ExactKeywordsInput extends KeywordsInput {
	    root: HTMLElement;
	    constructor(root: HTMLElement);
	    getValue(): string;
	}

}
declare module Coveo {
	class AnyKeywordsInput extends KeywordsInput {
	    root: HTMLElement;
	    constructor(root: HTMLElement);
	    getValue(): string;
	}

}
declare module Coveo {
	class NoneKeywordsInput extends KeywordsInput {
	    root: HTMLElement;
	    constructor(root: HTMLElement);
	    getValue(): string;
	}

}
declare module Coveo {
	abstract class DateInput implements IAdvancedSearchInput {
	    inputName: string;
	    root: HTMLElement;
	    protected element: HTMLElement;
	    constructor(inputName: string, root: HTMLElement);
	    reset(): void;
	    build(): HTMLElement;
	    getElement(): HTMLElement;
	    abstract getValue(): string;
	    isSelected(): boolean;
	    updateQuery(queryBuilder: QueryBuilder): void;
	    protected getRadio(): HTMLInputElement;
	    protected onChange(): void;
	}

}
declare module Coveo {
	class AnytimeDateInput extends DateInput {
	    root: HTMLElement;
	    constructor(root: HTMLElement);
	    getValue(): any;
	    build(): HTMLElement;
	}

}
declare module Coveo {
	class InTheLastDateInput extends DateInput {
	    root: HTMLElement;
	    dropdown: Dropdown;
	    spinner: NumericSpinner;
	    constructor(root: HTMLElement);
	    reset(): void;
	    build(): HTMLElement;
	    getValue(): string;
	}

}
declare module Coveo {
	class BetweenDateInput extends DateInput {
	    root: HTMLElement;
	    firstDatePicker: DatePicker;
	    secondDatePicker: DatePicker;
	    constructor(root: HTMLElement);
	    reset(): void;
	    build(): HTMLElement;
	    getValue(): string;
	}

}
declare module Coveo {
	class DocumentInput implements IAdvancedSearchInput {
	    inputName: string;
	    root: HTMLElement;
	    protected element: HTMLElement;
	    constructor(inputName: string, root: HTMLElement);
	    reset(): void;
	    build(): HTMLElement;
	    getValue(): string;
	    updateQuery(queryBuilder: QueryBuilder): void;
	    protected onChange(): void;
	}

}
declare module Coveo {
	class SimpleFieldInput extends DocumentInput {
	    inputName: string;
	    fieldName: string;
	    root: HTMLElement;
	    protected element: HTMLElement;
	    dropDown: Dropdown;
	    constructor(inputName: string, fieldName: string, endpoint: ISearchEndpoint, root: HTMLElement);
	    reset(): void;
	    build(): HTMLElement;
	    getValue(): string;
	}

}
declare module Coveo {
	class AdvancedFieldInput extends DocumentInput {
	    inputName: string;
	    fieldName: string;
	    root: HTMLElement;
	    protected element: HTMLElement;
	    mode: Dropdown;
	    input: TextInput;
	    constructor(inputName: string, fieldName: string, root: HTMLElement);
	    reset(): void;
	    build(): HTMLElement;
	    getValue(): string;
	}

}
declare module Coveo {
	class SizeInput extends DocumentInput {
	    root: HTMLElement;
	    static modes: string[];
	    static sizes: string[];
	    protected element: HTMLElement;
	    modeSelect: Dropdown;
	    sizeInput: NumericSpinner;
	    sizeSelect: Dropdown;
	    constructor(root: HTMLElement);
	    reset(): void;
	    build(): HTMLElement;
	    getValue(): string;
	}

}
declare module Coveo {
	class AdvancedSearchInputFactory {
	    constructor(endpoint: ISearchEndpoint, root: HTMLElement);
	    create(name: string, options?: IFieldInputParameters): IAdvancedSearchInput;
	    createAllKeywordsInput(): AllKeywordsInput;
	    createExactKeywordsInput(): ExactKeywordsInput;
	    createAnyKeywordsInput(): AnyKeywordsInput;
	    createNoneKeywordsInput(): NoneKeywordsInput;
	    createAnytimeDateInput(): AnytimeDateInput;
	    createInTheLastDateInput(): InTheLastDateInput;
	    createBetweenDateInput(): BetweenDateInput;
	    createSimpleFieldInput(name: string, field: string): SimpleFieldInput;
	    createAdvancedFieldInput(name: string, field: string): AdvancedFieldInput;
	    createSizeInput(): SizeInput;
	}

}
declare module Coveo {
	/**
	 * Argument sent to all handlers bound on {@link QuerySummaryEvents.cancelLastAction}
	 */
	interface IQuerySummaryCancelLastActionArgs {
	}
	/**
	 * This static class is there to contains the different string definition for all the events related to the {@link AdvancedSearch} component.
	 */
	class QuerySummaryEvents {
	    /**
	     * Triggered when the last action is being cancelled by the query summary component
	     *
	     * Allows external code to revert their last action.
	     * @type {string}
	     */
	    static cancelLastAction: string;
	}

}
declare module Coveo {
	interface IAdvancedSearchOptions {
	    includeKeywords?: boolean;
	    includeDate?: boolean;
	    includeDocument?: boolean;
	}
	/**
	 * The `AdvancedSearch` component is meant to render a section in the [`Settings`]{@link Settings} menu to allow the end
	 * user to easily create complex queries to send to the index.
	 *
	 * **Note:**
	 * > You can write custom code to add new sections in the **Advanced Search** modal box generated by this component by
	 * > attaching a handler to the [`buildingAdvancedSearch`]{@link AdvancedSearchEvents.buildingAdvancedSearch} event.
	 *
	 * @availablesince [October 2016 Release (v1.1550.5)](https://docs.coveo.com/en/309/#october-2016-release-v115505)
	 */
	class AdvancedSearch extends Component {
	    element: HTMLElement;
	    options: IAdvancedSearchOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * @componentOptions
	     */
	    static options: IAdvancedSearchOptions;
	    inputs: IAdvancedSearchInput[];
	    content: Dom;
	    /**
	     * Creates a new `AdvancedSearch` component.
	     *
	     * Triggers the [`buildingAdvancedSearch`]{@link AdvancedSearchEvents.buildingAdvancedSearch} event.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `AdvancedSearch` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IAdvancedSearchOptions, bindings?: IComponentBindings, ModalBox?: any);
	    /**
	     * Launches the advanced search query.
	     * If query returns successfully, also logs an `advancedSearch` event in the usage analytics (see
	     * {@link Analytics.logSearchEvent}).
	     */
	    executeAdvancedSearch(): void;
	    /**
	     * Resets the state of all form inputs inside the `AdvancedSearch` component.
	     */
	    reset(): void;
	    /**
	     * Opens the `AdvancedSearch` modal box.
	     */
	    open(): void;
	    /**
	     * Closes the `AdvancedSearch` modal box.
	     */
	    close(): void;
	}

}
declare module Coveo {
	interface IAggregateOptions {
	    field: IFieldOption;
	    operation?: string;
	    format?: string;
	}
	/**
	 * The Aggregate component allows to display the result on an aggregate operation on the index.
	 *
	 * It hooks itself to the query to add a new {@link IGroupByRequest}, then displays the result.
	 */
	class Aggregate extends Component {
	    element: HTMLElement;
	    options: IAggregateOptions;
	    static ID: string;
	    static doExport(): void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IAggregateOptions;
	    /**
	     * Creates a new Aggregate component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the Aggregate component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IAggregateOptions, bindings?: IComponentBindings);
	}

}
declare module Coveo {
	interface ISuggestionForOmniboxOptionsOnSelect {
	    (value: string, args: IPopulateOmniboxEventArgs): void;
	}
	interface ISuggestionForOmniboxOptions {
	    omniboxZIndex?: number;
	    headerTitle?: string;
	    onSelect?: ISuggestionForOmniboxOptionsOnSelect;
	    numberOfSuggestions?: number;
	}
	interface ISuggestionForOmniboxTemplate {
	    header?: {
	        template: (...args: any[]) => string;
	        title: string;
	    };
	    row: (...args: any[]) => string;
	}
	interface ISuggestionForOmniboxResult {
	    value: string;
	}
	class SuggestionForOmnibox {
	    structure: ISuggestionForOmniboxTemplate;
	    onSelect: (value: string, args: IPopulateOmniboxEventArgs) => void;
	    onTabPress: (value: string, args: IPopulateOmniboxEventArgs) => void;
	    constructor(structure: ISuggestionForOmniboxTemplate, onSelect: (value: string, args: IPopulateOmniboxEventArgs) => void, onTabPress: (value: string, args: IPopulateOmniboxEventArgs) => void);
	    buildOmniboxElement(results: ISuggestionForOmniboxResult[], args: IPopulateOmniboxEventArgs): HTMLElement;
	}

}
declare module Coveo {
	interface IAnalyticsSuggestionsOptions extends ISuggestionForOmniboxOptions {
	}
	/**
	 * The AnalyticsSuggestion component provides query suggestions based on the queries that a Coveo Analytics service most
	 * commonly logs (see [`topQueries`](https://platform.cloud.coveo.com/docs?urls.primaryName=Usage%20Analytics%20Read#/Statistics%20API%20-%20Version%2015/get__v15_stats_topQueries)).
	 *
	 * This component orders possible query suggestions by their respective number of successful item views, thus
	 * prioritizing the most relevant query suggestions. Consequently, when better options are available, this component
	 * does not suggest queries resulting in no clicks from users or requiring refinements.
	 *
	 * The query suggestions appear in the {@link Omnibox} Component. The AnalyticsSuggestion component strongly
	 * relates to the {@link Analytics} component. While a user is typing in a query box, the AnalyticsSuggestion component
	 * allows them to see and select the most commonly used and relevant queries.
	 *
	 * @deprecated This component is exposed for legacy reasons. If possible, you should avoid using this component.
	 * Instead, you should use the [`Omnibox`]{@link Omnibox}
	 * [`enableQuerySuggestAddon`]{@link Omnibox.options.enableQuerySuggestAddon} option.
	 */
	class AnalyticsSuggestions extends Component {
	    options: IAnalyticsSuggestionsOptions;
	    static ID: string;
	    static doExport(): void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IAnalyticsSuggestionsOptions;
	    /**
	     * Creates a new AnalyticsSuggestions component.
	     *
	     * Also binds event handlers so that when a user selects a suggestion, an `omniboxFromLink` usage analytics event is
	     * logged if the suggestion comes from a standalone search box, or an `omniboxAnalytics` usage analytics
	     * event is logged otherwise.
	     *
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the AnalyticsSuggestions component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options: IAnalyticsSuggestionsOptions, bindings?: IComponentBindings);
	    /**
	     * Selects a currently displayed query suggestion. This implies that at least one suggestion must have been returned
	     * at least once. The suggestion parameter can either be a number (0-based index position of the query suggestion to
	     * select) or a string that matches the suggestion.
	     *
	     * @param suggestion
	     */
	    selectSuggestion(suggestion: number): any;
	    selectSuggestion(suggestion: string): any;
	}

}
declare module Coveo {
	interface IAuthenticationProviderOptions {
	    name?: string;
	    caption?: string;
	    useIFrame?: boolean;
	    showIFrame?: boolean;
	}
	/**
	 * The `AuthenticationProvider` component makes it possible to execute queries with an identity that the end user
	 * can obtain using an authentication provider configured on the Coveo REST Search API
	 * (see [Claims Authentication](https://docs.coveo.com/en/113/)).
	 *
	 * When necessary, this component handles redirecting the browser to the address that starts the authentication process.
	 *
	 * You can use the `data-tab` attribute to enable the `AuthenticationProvider` component only for the tabs of your
	 * search interface that require authentication (see the [`Tab`]{@link Tab} component).
	 */
	class AuthenticationProvider extends Component {
	    element: HTMLElement;
	    options: IAuthenticationProviderOptions;
	    _window: Window;
	    static ID: string;
	    static handshakeInProgress: boolean;
	    static doExport: () => void;
	    /**
	     * The options for the component.
	     * @componentOptions
	     */
	    static options: IAuthenticationProviderOptions;
	    /**
	     * Creates a new `AuthenticationProvider` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `AuthenticationProvider` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IAuthenticationProviderOptions, bindings?: IComponentBindings, _window?: Window);
	}

}
declare module Coveo {
	/// <reference types="modal-box" />
	interface IAccessibleModalOptions {
	    overlayClose?: boolean;
	    sizeMod: 'small' | 'normal' | 'big';
	    focusOnOpen?(): HTMLElement;
	}
	interface IAccessibleModalOpenParameters {
	    content: HTMLElement;
	    validation: () => boolean;
	    origin: HTMLElement;
	}
	interface IAccessibleModalOpenResultParameters extends IAccessibleModalOpenParameters {
	    result: IQueryResult;
	    options: IQuickViewHeaderOptions;
	    bindings: IComponentBindings;
	}
	interface IAccessibleModalOpenNormalParameters extends IAccessibleModalOpenParameters {
	    title: HTMLElement;
	}
	class AccessibleModal {
	     isOpen: boolean;
	     element: HTMLElement;
	     content: HTMLElement;
	     wrapper: HTMLElement;
	    constructor(className: string, ownerElement: HTMLElement, modalboxModule?: Coveo.ModalBox.ModalBox, options?: any);
	    openResult(parameters: IAccessibleModalOpenResultParameters): void;
	    open(parameters: IAccessibleModalOpenNormalParameters): void;
	    close(): void;
	}

}
declare module Coveo {
	interface IYouTubeThumbnailOptions {
	    width: string;
	    height: string;
	    embed: boolean;
	}
	/**
	 * The YouTubeThumbnail component automatically fetches the thumbnail of a YouTube video.
	 *
	 * This component differs from the standard {@link Thumbnail} component because the thumbnail it outputs is always
	 * clickable.
	 *
	 * Depending on the component configuration, clicking a YouTube thumbnail can either automatically open a modal box
	 * containing the `iframe` from YouTube, or open the target URL in the current window (see
	 * {@link YouTubeThumbnail.options.embed}).
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 */
	class YouTubeThumbnail extends Component {
	    element: HTMLElement;
	    options: IYouTubeThumbnailOptions;
	    bindings: IResultsComponentBindings;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * @componentOptions
	     */
	    static options: IYouTubeThumbnailOptions;
	    resultLink: Dom;
	    constructor(element: HTMLElement, options?: IYouTubeThumbnailOptions, bindings?: IResultsComponentBindings, result?: IQueryResult, ModalBox?: any, origin?: HTMLElement);
	    /**
	     * Open the result link embedded in this component.
	     *
	     * With a standard configuration of this component, this will open an iframe that automatically plays the video.
	     */
	    openResultLink(): void;
	}

}
declare module Coveo {
	interface IBackdropOptions {
	    imageUrl?: string;
	    imageField?: IFieldOption;
	    overlayColor?: string;
	    overlayGradient?: boolean;
	}
	/**
	 * The Backdrop component renders an image URL (either passed as a direct URL or contained in a result field) as a
	 * background image. It is useful for displaying information in front of a dynamic background image.
	 *
	 * The Backdrop component will automatically initialize components embedded within itself:
	 *
	 * ```html
	 *   <div class="CoveoBackdrop" data-image-field="ytthumbnailurl">
	 *     <div class="CoveoFieldValue" data-field="somefield"></div>
	 *   </div>
	 * ```
	 */
	class Backdrop extends Component {
	    element: HTMLElement;
	    options: IBackdropOptions;
	    result: IQueryResult;
	    _window: Window;
	    ModalBox: any;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * @componentOptions
	     */
	    static options: IBackdropOptions;
	    /**
	     * Creates a new Backdrop component.
	     * @param element The HTMLElement on which the component will be instantiated.
	     * @param options The options for the Backdrop component.
	     * @param bindings The bindings that the component requires to function normally. If not set, it will be automatically
	     * resolved (with a slower execution time).
	     * @param result The {@link IQueryResult}.
	     */
	    constructor(element: HTMLElement, options?: IBackdropOptions, bindings?: IComponentBindings, result?: IQueryResult, _window?: Window, ModalBox?: any);
	}

}
declare module Coveo {
	interface IFieldValueOptions {
	    field?: IFieldOption;
	    facet?: string;
	    dynamicFacet?: string;
	    htmlValue?: boolean;
	    helper?: string;
	    helperOptions?: {
	        [key: string]: any;
	    };
	    splitValues?: boolean;
	    separator?: string;
	    displaySeparator?: string;
	    textCaption?: string;
	    conditions?: IFieldConditionOption[];
	}
	interface IAnalyticsFieldValueMeta {
	    facetId: string;
	    facetField: string;
	    facetValue?: string;
	    facetTitle?: string;
	}
	/**
	 * The FieldValue component displays the value of a field associated to its parent search result. It is normally usable
	 * within a {@link FieldTable}.
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 *
	 * A common use of this component is to display a specific field value which also happens to be an existing
	 * {@link Facet.options.field}. When the user clicks on the FieldValue component, it activates the corresponding Facet.
	 */
	class FieldValue extends Component {
	    element: HTMLElement;
	    options: IFieldValueOptions;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IFieldValueOptions;
	    static simpleOptions: any;
	    static helperOptions: any;
	    /**
	     * Creates a new FieldValue.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the FieldValue component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     */
	    constructor(element: HTMLElement, options: IFieldValueOptions, bindings?: IComponentBindings, result?: IQueryResult, fieldValueClassId?: string);
	    /**
	     * Gets the current FieldValue from the current {@link IQueryResult}.
	     *
	     * @returns {any} The current FieldValue or `null` if value is and `Object`.
	     */
	    getValue(): any;
	    /**
	     * Renders a value to HTML using all of the current FieldValue component options.
	     * @param value The value to render.
	     * @returns {HTMLElement} The element containing the rendered value.
	     */
	    renderOneValue(value: string): HTMLElement;
	    protected getValueContainer(): HTMLElement;
	    protected prependTextCaptionToDom(): void;
	}

}
declare module Coveo {
	interface IBadgeOptions extends IFieldValueOptions {
	    colors: IBadgeColors;
	}
	/**
	 * Badge Colors
	 */
	interface IBadgeColors extends IBadgeColor {
	    values?: {
	        [value: string]: IBadgeColors;
	    };
	}
	interface IBadgeColor {
	    icon?: string;
	    text?: string;
	}
	/**
	 * The Badge component outputs a field value with customizable colors and an icon preceding it.
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)). It
	 * extends the {@link FieldValue} component. Therefore all FieldValue options are also available for a Badge component.
	 */
	class Badge extends FieldValue implements IComponentBindings {
	    options: IBadgeOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IBadgeOptions;
	    static parent: typeof FieldValue;
	    /**
	     * Creates a new Badge component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the Badge component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     */
	    constructor(element: HTMLElement, options: IBadgeOptions, bindings?: IComponentBindings, result?: IQueryResult);
	    /**
	     * Parses a {@link Badge.options.colors} option string into a workable JSON format.
	     *
	     * @param colorsOption The colors option string to parse. See {@link Badge.options.colors}.
	     */
	    static parseColors(colorsOption: string): IBadgeColors;
	    /**
	     * Gets the icon and text color of a field value.
	     *
	     * @param value The field value whose colors to return.
	     * @returns {{icon: string, text: string}} An object with the `icon` and `text` keys.
	     */
	    getColor(value?: string): IBadgeColor;
	    /**
	     * Renders one string value with the appropriate colors and icon.
	     *
	     * @param value The field value to render.
	     * @returns {HTMLElement} An HTML `<span>` tag containing the rendered value.
	     */
	    renderOneValue(value: string): HTMLElement;
	    protected prependTextCaptionToDom(): void;
	}

}
declare module Coveo {
	interface ICardActionBarOptions {
	    hidden?: boolean;
	    openOnMouseOver?: boolean;
	}
	/**
	 * The `CardActionBar` component displays an action bar at the bottom of a card result (see
	 * [Result Layouts](https://docs.coveo.com/en/360/)). It is a simple container for buttons or complementary
	 * information.
	 *
	 * You should place this component at the bottom of a card result template (i.e., as the last child of the surrounding
	 * `coveo-result-frame` div).
	 *
	 * See [Using the CardActionBar Component](https://docs.coveo.com/en/1349/#using-the-cardactionbar-component)
	 */
	class CardActionBar extends Component {
	    element: HTMLElement;
	    options: ICardActionBarOptions;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    parentResult: HTMLElement;
	    arrowContainer: HTMLElement;
	    removedTabIndexElements: HTMLElement[];
	    /**
	     * @componentOptions
	     */
	    static options: ICardActionBarOptions;
	    /**
	     * Creates a new `CardActionBar` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The parent [query result]{@link IQueryResult}..
	     */
	    constructor(element: HTMLElement, options?: ICardActionBarOptions, bindings?: IComponentBindings, result?: IQueryResult);
	    /**
	     * Shows the component.
	     */
	    show(): void;
	    /**
	     * Hides the component.
	     */
	    hide(): void;
	}

}
declare module Coveo {
	/**
	 * The CardOverlayEvents class contains string definitions for all events related to the {@link CardOverlay} component.
	 */
	class CardOverlayEvents {
	    /**
	     * Opening a {@link CardOverlay} component triggers this event (see {@link CardOverlay.openOverlay}).
	     *
	     * @type {string}
	     */
	    static openCardOverlay: string;
	    /**
	     * Closing a {@link CardOverlay} component triggers this event (see {@link CardOverlay.closeOverlay}).
	     *
	     * @type {string}
	     */
	    static closeCardOverlay: string;
	}

}
declare module Coveo {
	interface ICardOverlayOptions {
	    title: string;
	    icon?: string;
	}
	/**
	 * The CardOverlay component displays a button that the user can click to toggle the visibility of an overlay on top of
	 * an {@link IQueryResult}. While this component typically populates a {@link CardActionBar} component, it is actually
	 * possible to place a CardOverlay component anywhere in any result.
	 *
	 * The primary purpose of the CardOverlay component is to display additional information about a result in a format that
	 * fits well within a card result layout (see [Result Layouts](https://docs.coveo.com/en/360/)).
	 *
	 * When initialized, this component creates a `<div class="coveo-card-overlay">` element as the last child of its parent
	 * IQueryResult, and displays a button which toggles the visibility of the overlay.
	 */
	class CardOverlay extends Component {
	    element: HTMLElement;
	    options: ICardOverlayOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * @componentOptions
	     */
	    static options: ICardOverlayOptions;
	    /**
	     * Creates a new CardOverlay component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the CardOverlay component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: ICardOverlayOptions, bindings?: IComponentBindings);
	    /**
	     * Toggles the CardOverlay visibility.
	     *
	     * @param swtch Specifying a value for this parameter forces the component visibility to take the corresponding value
	     * (`true` for visible; `false` for hidden).
	     */
	    toggleOverlay(swtch?: boolean): void;
	    /**
	     * Opens the CardOverlay.
	     *
	     * Also triggers the {@link CardOverlayEvents.openCardOverlay} event.
	     */
	    openOverlay(): void;
	    /**
	     * Closes the CardOverlay.
	     *
	     * Also triggers the {@link CardOverlayEvents.closeCardOverlay} event.
	     */
	    closeOverlay(): void;
	}

}
declare module Coveo {
	class ChatterUtils {
	    static buildURI(objectURI: string, objectId: string, newObjectId: string): string;
	    static bindClickEventToElement(element: HTMLElement, openInPrimaryTab: boolean, openInSubTab: boolean): HTMLElement;
	}

}
declare module Coveo {
	interface IChatterLikedByOptions {
	    nbLikesToRender: number;
	    openInPrimaryTab: boolean;
	    openInSubTab: boolean;
	}
	class ChatterLikedBy extends Component {
	    element: HTMLElement;
	    options: IChatterLikedByOptions;
	    bindings: IComponentBindings;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    static options: IChatterLikedByOptions;
	    constructor(element: HTMLElement, options?: IChatterLikedByOptions, bindings?: IComponentBindings, result?: IQueryResult);
	}

}
declare module Coveo {
	function registerFields(): void;

}
declare module Coveo {
	interface IChatterPostAttachmentOption {
	}
	class ChatterPostAttachment extends Component {
	    element: HTMLElement;
	    options: IChatterPostAttachmentOption;
	    bindings: IResultsComponentBindings;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    constructor(element: HTMLElement, options?: IChatterPostAttachmentOption, bindings?: IResultsComponentBindings, result?: IQueryResult);
	}

}
declare module Coveo {
	function registerFields(): void;

}
declare module Coveo {
	interface IChatterPostedByOption {
	    enablePostedOn: boolean;
	    useFromInstead: boolean;
	    openInPrimaryTab: boolean;
	    openInSubTab: boolean;
	}
	class ChatterPostedBy extends Component {
	    element: HTMLElement;
	    options: IChatterPostedByOption;
	    bindings: IResultsComponentBindings;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    static options: IChatterPostedByOption;
	    static fields: string[];
	    constructor(element: HTMLElement, options?: IChatterPostedByOption, bindings?: IResultsComponentBindings, result?: IQueryResult);
	}

}
declare module Coveo {
	function registerFields(): void;

}
declare module Coveo {
	interface IChatterTopicOption {
	}
	class ChatterTopic extends Component {
	    element: HTMLElement;
	    options: IChatterTopicOption;
	    bindings: IResultsComponentBindings;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    constructor(element: HTMLElement, options?: IChatterTopicOption, bindings?: IResultsComponentBindings, result?: IQueryResult);
	}

}
declare module Coveo {
	function registerFields(): void;

}
declare module Coveo {
	interface IDidYouMeanOptions {
	    enableAutoCorrection?: boolean;
	}
	/**
	 * The DidYouMean component is responsible for displaying query corrections. If this component is in the page and the
	 * query returns no result but finds a possible query correction, the component either suggests the correction or
	 * automatically triggers a new query with the suggested term.
	 */
	class DidYouMean extends Component {
	    element: HTMLElement;
	    options: IDidYouMeanOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IDidYouMeanOptions;
	    correctedTerm: string;
	    /**
	     * Creates a new DidYouMean component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the DidYouMean component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IDidYouMeanOptions, bindings?: IComponentBindings);
	    /**
	     * Executes a query with the corrected term.
	     * Throws an exception if the corrected term has not been initialized.
	     * If successful, logs a `didyoumeanClick` event in the usage analytics.
	     */
	    doQueryWithCorrectedTerm(): void;
	}

}
declare module Coveo {
	/**
	 * The `GoogleApiPositionProvider` class uses the
	 * [Google Maps Geolocation API](https://developers.google.com/maps/documentation/geolocation/intro) to provide the
	 * position of the end user to a [`DistanceResources`]{@link DistanceResources} component whose
	 * [`googleApiKey`]{@link DistanceResources.options.googleApiKey} option is set to a valid  Google Maps Geolocation API
	 * key.
	 */
	class GoogleApiPositionProvider implements IGeolocationPositionProvider {
	    constructor(googleApiKey: string);
	    getPosition(): Promise<IGeolocationPosition>;
	}

}
declare module Coveo {
	/**
	 * The `NavigatorPositionProvider` class uses the current web browser to provide the position of the end user to
	 * a [`DistanceResources`]{@link DistanceResources} component whose
	 * [`useNavigator`]{DistanceResources.options.useNavigator} option is set to `true`.
	 *
	 * **Note:**
	 * > Recent web browsers typically require a site to be in HTTPS to enable their geolocation service.
	 */
	class NavigatorPositionProvider implements IGeolocationPositionProvider {
	    getPosition(): Promise<IGeolocationPosition>;
	}

}
declare module Coveo {
	/**
	 * The `StaticPositionProvider` class provides a static end user position to a
	 * [`DistanceResources`]{@link DistanceResources} component.
	 */
	class StaticPositionProvider implements IGeolocationPositionProvider {
	    constructor(latitude: number, longitude: number);
	    getPosition(): Promise<IGeolocationPosition>;
	}

}
declare module Coveo {
	interface IDistanceOptions {
	    distanceField: IFieldOption;
	    latitudeField: IFieldOption;
	    longitudeField: IFieldOption;
	    unitConversionFactor: number;
	    disabledDistanceCssClass: string;
	    latitudeValue: number;
	    longitudeValue: number;
	    googleApiKey: string;
	    useNavigator: boolean;
	    triggerNewQueryOnNewPosition: boolean;
	    cancelQueryUntilPositionResolved: boolean;
	}
	/**
	 * The `DistanceResources` component defines a field that computes the distance according to the current position of the
	 * end user.
	 *
	 * Components relying on the current distance should be disabled until this component successfully provides a distance.
	 *
	 * See also [`DistanceEvents`]{@link DistanceEvents}.
	 *
	 * @availablesince [November 2017 Release (v2.3477.9)](https://docs.coveo.com/en/373/#november-2017-release-v234779)
	 */
	class DistanceResources extends Component {
	    element: HTMLElement;
	    options: IDistanceOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The possible options for a DistanceResources.
	     * @componentOptions
	     */
	    static options: IDistanceOptions;
	    /**
	     * Creates a new `DistanceResources` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `DistanceResources` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options: IDistanceOptions, bindings: IComponentBindings);
	    /**
	     * Overrides the current position with the provided values.
	     *
	     * **Note:**
	     * > Calling this method does not automatically trigger a query.
	     *
	     * @param latitude The latitude to set.
	     * @param longitude The longitude to set.
	     */
	    setPosition(latitude: number, longitude: number): void;
	    /**
	     * Returns a promise of the last position resolved using the registered position providers.
	     *
	     * @returns {Promise<IGeolocationPosition>} A promise of the last resolved position value.
	     */
	    getLastPositionRequest(): Promise<IGeolocationPosition>;
	}

}
declare module Coveo {
	interface IErrorReportOptions {
	    showDetailedError: boolean;
	}
	/**
	 * The ErrorReport component takes care of handling fatal error when doing a query on the index / Search API.
	 *
	 * For example, the ErrorReport component displays a message when the service responds with a 401 or 503 error. This
	 * component also renders a small text area with the JSON content of the error response, for debugging purposes.
	 */
	class ErrorReport extends Component {
	    element: HTMLElement;
	    options: IErrorReportOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IErrorReportOptions;
	    /**
	     * Creates a new ErrorReport component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the ErrorReport component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IErrorReportOptions, bindings?: IComponentBindings);
	    /**
	     * Performs the "back" action in the browser.
	     * Also logs an `errorBack` event in the usage analytics.
	     */
	    back(): void;
	    /**
	     * Resets the current state of the query and triggers a new query.
	     * Also logs an `errorClearQuery` event in the usage analytics.
	     */
	    reset(): void;
	    /**
	     * Retries the same query, in case of a temporary service error.
	     * Also logs an `errorRetry` event in the usage analytics.
	     */
	    retry(): void;
	}

}
declare module Coveo {
	/**
	 * The Excerpt component renders an excerpt of its associated result and highlights the keywords from the query using
	 * the appropriate template helpers.
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 */
	class Excerpt extends Component {
	    element: HTMLElement;
	    options: any;
	    bindings: IComponentBindings;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * Creates a new Excerpt component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the Excerpt component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     */
	    constructor(element: HTMLElement, options?: any, bindings?: IComponentBindings, result?: IQueryResult);
	}

}
declare module Coveo {
	function setCreateAnchor(fn: () => HTMLAnchorElement): void;
	interface IExportToExcelOptions {
	    numberOfResults?: number;
	    fieldsToInclude?: IFieldOption[];
	}
	/**
	 * The ExportToExcel component renders an item in the {@link Settings} menu to allow the end user to the current
	 * search results to the Microsoft Excel format (.xlsx).
	 *
	 * @availablesince [November 2015 Release (v1.0.139)](https://docs.coveo.com/en/289/#november-2015-release-v10139)
	 */
	class ExportToExcel extends Component {
	    element: HTMLElement;
	    options: IExportToExcelOptions;
	    bindings: IComponentBindings;
	    _window: Window;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the ExportToExcel
	     * @componentOptions
	     */
	    static options: IExportToExcelOptions;
	    /**
	     * Creates a new ExportToExcel component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the ExportToExcel component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param _window The global Window object (used to download the Excel link).
	     */
	    constructor(element: HTMLElement, options: IExportToExcelOptions, bindings?: IComponentBindings, _window?: Window);
	    /**
	     * Downloads the Excel representation of the current query.
	     *
	     * Also logs an `exportToExcel` event in the usage analytics.
	     */
	    download(): void;
	    static create(element: HTMLElement, options?: IExportToExcelOptions, root?: HTMLElement): ExportToExcel;
	}

}
declare module Coveo {
	/// <reference path="../ui/FacetRange/FacetRange.d.ts" />
	class FacetRangeQueryController extends FacetQueryController {
	    facet: FacetRange;
	    graphGroupByQueriesIndex: number;
	    constructor(facet: FacetRange);
	    protected createBasicGroupByRequest(allowedValues?: string[], addComputedField?: boolean): IGroupByRequest;
	    protected createGroupByAllowedValues(): string[];
	}

}
declare module Coveo {
	/// <reference path="../Facet/Facet.d.ts" />
	interface IFacetRangeOptions extends IFacetOptions {
	    ranges?: IRangeValue[];
	    dateField?: boolean;
	    valueFormat?: string;
	}
	/**
	 * A `FacetRange` is a [facet](https://docs.coveo.com/en/198/) whose values are expressed as ranges.
	 *
	 * You must set the [`field`]{@link Facet.options.field} option to a value targeting a numeric or date [field](https://docs.coveo.com/en/200/) in your index for this component to work.
	 *
	 * This component extends the [`Facet`]{@link Facet} component and supports all `Facet` options except:
	 *
	 * - **Settings** menu options
	 *   - [`enableSettings`]{@link Facet.options.enableSettings}
	 *   - [`enableSettingsFacetState`]{@link Facet.options.enableSettingsFacetState}
	 *   - [`enableCollapse`]{@link Facet.options.enableCollapse}
	 *   - [`availableSorts`]{@link Facet.options.availableSorts}
	 *   - [`customSort`]{@link Facet.options.customSort}
	 *   - [`computedFieldCaption`]{@link Facet.options.computedFieldCaption}
	 * - **Facet Search** options
	 *   - [`enableFacetSearch`]{@link Facet.options.enableFacetSearch}
	 *   - [`facetSearchDelay`]{@link Facet.options.facetSearchDelay}
	 *   - [`facetSearchIgnoreAccents`]{@link Facet.options.facetSearchIgnoreAccents}
	 *   - [`numberOfValuesInFacetSearch`]{@link Facet.options.numberOfValuesInFacetSearch}
	 * - **More and Less** options
	 *   - [`enableMoreLess`]{@link Facet.options.enableMoreLess}
	 *   - [`pageSize`]{@link Facet.options.pageSize}
	 *
	 *  @notSupportedIn salesforcefree
	 */
	class FacetRange extends Facet implements IComponentBindings {
	    element: HTMLElement;
	    static ID: string;
	    static parent: typeof Facet;
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IFacetRangeOptions;
	    options: IFacetRangeOptions;
	    isFieldValueCompatible: boolean;
	    /**
	     * Creates a new `FacetRange`.
	     * @param element The HTML element on which to instantiate the component.
	     * @param options The configuration options to apply when creating the component.
	     * @param bindings The bindings required by the component.
	     */
	    constructor(element: HTMLElement, options: IFacetRangeOptions, bindings?: IComponentBindings);
	    getValueCaption(facetValue: FacetValue): string;
	    protected initFacetQueryController(): void;
	    protected processNewGroupByResults(groupByResults: IGroupByResult): void;
	}

}
declare module Coveo {
	interface IFieldSuggestionsOptions extends ISuggestionForOmniboxOptions {
	    field?: IFieldOption;
	    queryOverride?: IQueryExpression;
	}
	/**
	 * The `FieldSuggestions` component provides query suggestions based on a particular facet field. For example, you could
	 * use this component to provide auto-complete suggestions while the end user is typing the title of an item.
	 *
	 * The query suggestions provided by this component appear in the [`Omnibox`]{@link Omnibox} component.
	 *
	 * **Note:** Consider [providing Coveo ML query suggestions](https://docs.coveo.com/en/340/#providing-coveo-machine-learning-query-suggestions)
	 * rather than field suggestions, as the former yields better performance and relevance.
	 */
	class FieldSuggestions extends Component {
	    options: IFieldSuggestionsOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * @componentOptions
	     */
	    static options: IFieldSuggestionsOptions;
	    /**
	     * Creates a new `FieldSuggestions` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `FieldSuggestions` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options: IFieldSuggestionsOptions, bindings?: IComponentBindings);
	    selectSuggestion(suggestion: number): any;
	    selectSuggestion(suggestion: string): any;
	}

}
declare module Coveo {
	/**
	 * Used to define a row returned by an [`IFacetValueSuggestionsProvider`]{@link IFacetValueSuggestionsProvider}.
	 */
	interface IFacetValueSuggestionRow {
	    /**
	     * The score computed by the suggestions provider.
	     *
	     * A higher score means the results is more relevant.
	     */
	    score: IFacetValueSuggestionScore;
	    /**
	     * The field value returned by the suggestion that should be used to filter the results.
	     */
	    value: string;
	    /**
	     * The number of results matching the value for the given keyword.
	     */
	    numberOfResults: number;
	    /**
	     * The keyword that was used in the query to retrieve results.
	     */
	    keyword: IQuerySuggestionKeyword;
	    /**
	     * The field that was used for the suggestions.
	     */
	    field: IFieldOption;
	}
	interface IFacetValueSuggestionScore {
	    distanceFromTotalForField: number;
	}
	/**
	 * Defines options for the [`FacetValueSuggestions`]{@link FacetValueSuggestions} component.
	 */
	interface IFacetValueSuggestionsProviderOptions {
	    field: string;
	    expression?: string;
	}
	/**
	 * Provides suggestions for the [`FacetValueSuggestions`]{@link FacetValueSuggestions} component.
	 */
	interface IFacetValueSuggestionsProvider {
	    getSuggestions(valuesToSearch: IQuerySuggestionKeyword[]): Promise<IFacetValueSuggestionRow[]>;
	}
	class FacetValueSuggestionsProvider implements IFacetValueSuggestionsProvider {
	    constructor(queryController: QueryController, options: IFacetValueSuggestionsProviderOptions);
	    getSuggestions(valuesToSearch: IQuerySuggestionKeyword[]): Promise<IFacetValueSuggestionRow[]>;
	}

}
declare module Coveo {
	interface IFacetValueSuggestionsOptions {
	    numberOfSuggestions: number;
	    field?: IFieldOption;
	    isCategoryField?: boolean;
	    categoryFieldDelimitingCharacter?: string;
	    useQuerySuggestions?: boolean;
	    useValueFromSearchbox?: boolean;
	    displayEstimateNumberOfResults?: boolean;
	    expression?: string;
	    templateHelper?: (row: IFacetValueSuggestionRow, omnibox: Omnibox) => string;
	}
	interface IQuerySuggestionKeyword {
	    text: string;
	    html: string;
	}
	/**
	 * This component provides [`Omnibox`]{@link Omnibox} query suggestions scoped to distinct categories based on the values of a
	 * specific [`field`]{@link FacetValueSuggestions.options.field} whose [Facet](https://docs.coveo.com/en/1982/#facet) option is enabled.
	 *
	 * @externaldocs [Providing Facet Value Suggestions](https://docs.coveo.com/en/340/#providing-facet-value-suggestions)
	 *
	 * @availablesince [May 2018 Release (v2.4094.8)](https://docs.coveo.com/410/#may-2018-release-v240948)
	 */
	class FacetValueSuggestions extends Component {
	    options: IFacetValueSuggestionsOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * @componentOptions
	     */
	    static options: IFacetValueSuggestionsOptions;
	    facetValueSuggestionsProvider: IFacetValueSuggestionsProvider;
	    static defaultTemplate(row: IFacetValueSuggestionRow, omnibox: Omnibox): string;
	    /**
	     * Creates a new `FacetValueSuggestions` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `FacetValueSuggestions` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options: IFacetValueSuggestionsOptions, bindings?: IComponentBindings);
	    getSuggestions(omnibox: Omnibox): Promise<IOmniboxSuggestion[]>;
	}

}
declare module Coveo {
	interface IFieldTableOptions {
	    allowMinimization: boolean;
	    expandedTitle: string;
	    minimizedTitle: string;
	    minimizedByDefault: boolean;
	}
	/**
	 * The FieldTable component displays a set of {@link FieldValue} components in a table that can optionally be
	 * expandable and minimizable. This component automatically takes care of not displaying empty field values.
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 *
	 * **Example:**
	 *
	 * ```
	 * // This is the FieldTable component itself, which holds a list of table rows.
	 * // Each row is a FieldValue component.
	 * <table class='CoveoFieldTable'>
	 *    // Items
	 *    <tr data-field='@sysdate' data-caption='Date' data-helper='dateTime' />
	 *    <tr data-field='@sysauthor' data-caption='Author' />
	 *    <tr data-field='@clickuri' data-html-value='true' data-caption='URL' data-helper='anchor' data-helper-options='{text: \"<%= raw.syssource %>\" , target:\"_blank\"}'>
	 * </table>
	 * ```
	 */
	class FieldTable extends Component {
	    element: HTMLElement;
	    options: IFieldTableOptions;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IFieldTableOptions;
	    /**
	     * Creates a new FieldTable.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the FieldTable component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     */
	    constructor(element: HTMLElement, options?: IFieldTableOptions, bindings?: IComponentBindings, result?: IQueryResult);
	    isExpanded: boolean;
	    /**
	     * Toggles between expanding (showing) and minimizing (collapsing) the FieldTable.
	     *
	     * @param anim Specifies whether to show a sliding animation when toggling the display of the FieldTable.
	     */
	    toggle(anim?: boolean): void;
	    /**
	     * Expands (shows) the FieldTable,
	     * @param anim Specifies whether to show a sliding animation when expanding the FieldTable.
	     */
	    expand(anim?: boolean): void;
	    /**
	     * Minimizes (collapses) the FieldTable.
	     * @param anim Specifies whether to show a sliding animation when minimizing the FieldTable.
	     */
	    minimize(anim?: boolean): void;
	    /**
	     * Updates the toggle height if the content was dynamically resized, so that the expanding and minimizing animation
	     * can match the new content size.
	     */
	    updateToggleHeight(): void;
	    protected isTogglable(): boolean;
	}
	interface IValueRowOptions extends IFieldValueOptions {
	    caption?: string;
	}

}
declare module Coveo {
	enum VALID_SORT {
	    RELEVANCY,
	    DATE,
	    QRE,
	}
	enum VALID_DIRECTION {
	    ASCENDING,
	    DESCENDING,
	}
	class SortCriterion {
	    sort: VALID_SORT;
	    direction: VALID_DIRECTION | '';
	    /**
	     * Create a new SortCriteria
	     * @param sort The sort criteria (e.g.: relevancy, date)
	     * @param direction The direction by which to sort (e.g.: ascending, descending)
	     */
	    constructor(sort: VALID_SORT, direction?: VALID_DIRECTION | '');
	}
	class SortCriteria {
	    constructor(rawCriteriaString: string);
	     direction: "" | VALID_DIRECTION;
	     sort: VALID_SORT;
	    /**
	     * Return a new SortCriteria from a string
	     * @param criteria The string from which to create the SortCriteria
	     */
	    static parse(criteria: string): SortCriteria;
	    /**
	     * Put the sort criteria in the passed queryBuilder
	     * @param queryBuilder The queryBuilder in which to put the sort criteria.
	     */
	    putInQueryBuilder(queryBuilder: QueryBuilder): void;
	    /**
	     * Returns a string representation of the sort criteria (e.g.: 'date ascending').
	     */
	    toString(): string;
	    /**
	     * Checks if the SortCriteria is equal to another.
	     * @param criteria The SortCriteria to compare with
	     */
	    equals(criteria: SortCriteria): boolean;
	}

}
declare module Coveo {
	interface IFoldingOptions {
	    field?: IFieldOption;
	    child?: IFieldOption;
	    parent?: IFieldOption;
	    childField?: IFieldOption;
	    parentField?: IFieldOption;
	    range?: number;
	    rearrange?: SortCriteria;
	    enableExpand?: boolean;
	    expandExpression?: IQueryExpression;
	    maximumExpandedResults?: number;
	    /**
	     * Manage folding for each results individually
	     */
	    getResult?: (result: IQueryResult) => IQueryResult;
	    /**
	     * Manage folding of all more results
	     */
	    getMoreResults?: (results: IQueryResult[]) => IQueryResult[];
	}
	/**
	 * The `Folding` component makes it possible to render hierarchic representations of search results sharing a common
	 * [`field`]{@link Folding.options.field}.
	 *
	 * This component has no visual impact on its own. It simply folds certain search results so that the
	 * [`ResultFolding`]{@link ResultFolding} and [`ResultAttachments`]{@link ResultAttachments} components can then nicely
	 * render them within result templates (see [Result Templates](https://docs.coveo.com/en/413/)).
	 *
	 * A typical use case of the `Folding` component is to fold email conversations and message board threads results in a
	 * result set in order to display them in a convenient format. Messages belonging to a single conversation typically
	 * have a unique conversation ID. By indexing this ID on a field, you can use it to fold search results (see
	 * [Folding Results](https://docs.coveo.com/en/428/)).
	 *
	 * **Note:**
	 * > There can only be one `Folding` component per [`Tab`]{@link Tab} component.
	 *
	 */
	class Folding extends Component {
	    element: HTMLElement;
	    options: IFoldingOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IFoldingOptions;
	    /**
	     * Creates a new `Folding` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `Folding` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options: IFoldingOptions, bindings?: IComponentBindings);
	    static foldWithParent(queryResults: IQueryResult[]): IQueryResult[];
	    static defaultGetResult(result: IQueryResult): IQueryResult;
	    static defaultGetMoreResults(results: IQueryResult[]): IQueryResult[];
	}

}
declare module Coveo {
	/**
	 * The `FoldingForThread` component inherits from the [`Folding`]{@link Folding} component. It offers the
	 * same configuration options.
	 *
	 * Folding conversations and threads requires different processing. When you need to fold all child items (including
	 * their attachments) on the same level under a common ancestor item, use this component rather than the `Folding`
	 * component.
	 *
	 * This component works well with Chatter and Lithium.
	 *
	 * **Note:**
	 * > There can only be one `FoldingForThread` component per [`Tab`]{@link Tab} component.
	 *
	 * See [Folding Results](https://docs.coveo.com/en/428/).
	 */
	class FoldingForThread extends Folding {
	    element: HTMLElement;
	    options: IFoldingOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * Creates a new `FoldingForThread` component
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `FoldingForThread` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options: IFoldingOptions, bindings?: IComponentBindings);
	}

}
declare module Coveo {
	interface IFollowItemOptions {
	    watchedFields?: IFieldOption[];
	    modifiedDateField?: string;
	}
	/**
	 * The FollowItem component renders a widget that the end user can click to follow a particular item. A user following
	 * an item receives email notifications when the item changes.
	 *
	 * **Note:**
	 * > A {@link SearchAlerts} component must be present in the page for this component to work. It is also necessary to
	 * > meet certain requirements to be able to use this component (see
	 * > [Deploying Search Alerts on a Coveo JS Search Page](https://docs.coveo.com/en/1932/)).
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 */
	class FollowItem extends Component {
	    element: HTMLElement;
	    options: IFollowItemOptions;
	    bindings: IResultsComponentBindings;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the follow item component
	     * @componentOptions
	     */
	    static options: IFollowItemOptions;
	    /**
	     * Creates a new FollowItem component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the FollowItem component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time)
	     * @param result The result to associate the component with.
	     */
	    constructor(element: HTMLElement, options?: IFollowItemOptions, bindings?: IResultsComponentBindings, result?: IQueryResult);
	    setFollowed(subscription: ISubscription): void;
	    setNotFollowed(): void;
	    /**
	     * Follows the item if not already following it. Stops following the item otherwise.
	     *
	     * Also logs the appropriate event in the usage analytics (either `searchAlertsFollowDocument` or
	     * `searchAlertsUnfollowDocument`).
	     */
	    toggleFollow(): void;
	    protected getText(): string;
	}

}
declare module Coveo {
	function registerFields(): void;

}
declare module Coveo {
	interface IHiddenQueryOptions {
	    maximumDescriptionLength: number;
	    title: string;
	}
	/**
	 * The HiddenQuery component handles a "hidden" query parameter (`hq`) and its description (`hd`).
	 *
	 * Concretely, this means that if a HiddenQuery component is present in your page and you load your search interface
	 * with `hq=foo&hd=bar` in the URL hash, the component adds `foo` as an expression to the query (`hq` is the hidden
	 * query) and renders `bar` in the {@link Breadcrumb} (`hd` is the hidden query description).
	 */
	class HiddenQuery extends Component {
	    element: HTMLElement;
	    options: IHiddenQueryOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * Possible options for the `HiddenQuery` component
	     * @componentOptions
	     */
	    static options: IHiddenQueryOptions;
	    /**
	     * Creates a new HiddenQuery component, which binds multiple events ({@link QueryEvents.buildingQuery},
	     * {@link BreadcrumbEvents.populateBreadcrumb} and {@link BreadcrumbEvents.clearBreadcrumb}).
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the HiddenQuery component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IHiddenQueryOptions, bindings?: IComponentBindings);
	    /**
	     * Clears any `hd` or `hq` set in the {@link QueryStateModel}.
	     * Also logs the `contextRemove` event in the usage analytics and triggers a new query.
	     */
	    clear(): void;
	}

}
declare module Coveo {
	/// <reference path="../ui/HierarchicalFacet/HierarchicalFacet.d.ts" />
	/// <reference path="FacetQueryController.d.ts" />
	class HierarchicalFacetQueryController extends FacetQueryController {
	    facet: HierarchicalFacet;
	    constructor(facet: HierarchicalFacet);
	    search(params: FacetSearchParameters, oldLength?: number): Promise<IIndexFieldValue[]>;
	    protected getAllowedValuesFromSelected(): any[];
	}

}
declare module Coveo {
	/// <reference path="HierarchicalFacet.d.ts" />
	class HierarchicalFacetValuesList extends FacetValuesList {
	    facet: HierarchicalFacet;
	    facetValueElementKlass: IFacetValueElementKlass;
	    hierarchyFacetValues: FacetValue[];
	    constructor(facet: HierarchicalFacet, facetValueElementKlass: IFacetValueElementKlass);
	    sortFacetValues(hierarchyFacetValues?: FacetValue[]): FacetValue[];
	    protected getValuesToBuildWith(): FacetValue[];
	}

}
declare module Coveo {
	/// <reference path="HierarchicalFacet.d.ts" />
	class HierarchicalFacetSearch extends FacetSearch {
	    facet: HierarchicalFacet;
	    facetSearchValuesListKlass: IFacetSearchValuesListKlass;
	    constructor(facet: HierarchicalFacet, facetSearchValuesListKlass: IFacetSearchValuesListKlass, root: HTMLElement);
	    protected buildParamsForExcludingCurrentlyDisplayedValues(): FacetSearchParameters;
	    protected selectAllValuesMatchingSearch(): void;
	}

}
declare module Coveo {
	class HierarchicalBreadcrumbValueElement extends BreadcrumbValueElement {
	    facet: HierarchicalFacet;
	    facetValue: FacetValue;
	    constructor(facet: HierarchicalFacet, facetValue: FacetValue);
	    build(): Dom;
	}

}
declare module Coveo {
	/// <reference path="HierarchicalFacet.d.ts" />
	interface IHierarchicalBreadcrumbValuesListOptions {
	    headingLevel?: number;
	}
	class HierarchicalBreadcrumbValuesList extends BreadcrumbValueList {
	    facet: HierarchicalFacet;
	    facetValues: FacetValue[];
	    valueHierarchy: {
	        [facetValue: string]: IValueHierarchy;
	    };
	    constructor(facet: HierarchicalFacet, facetValues: FacetValue[], valueHierarchy: {
	        [facetValue: string]: IValueHierarchy;
	    }, options?: IHierarchicalBreadcrumbValuesListOptions);
	    buildAsString(): string;
	}

}
declare module Coveo {
	/// <reference path="HierarchicalFacet.d.ts" />
	class HierarchicalFacetValueElement extends FacetValueElement {
	    facet: HierarchicalFacet;
	    facetValue: FacetValue;
	    keepDisplayedValueNextTime: boolean;
	    constructor(facet: HierarchicalFacet, facetValue: FacetValue, keepDisplayedValueNextTime: boolean);
	}

}
declare module Coveo {
	class HierarchicalFacetSearchValueElement extends FacetValueElement {
	    facet: HierarchicalFacet;
	    facetValue: FacetValue;
	    keepDisplayedValueNextTime: boolean;
	    constructor(facet: HierarchicalFacet, facetValue: FacetValue, keepDisplayedValueNextTime: boolean);
	    _handleSelectValue(eventBindings: IValueElementEventsBinding): void;
	    _handleExcludeClick(eventBindings: IValueElementEventsBinding): void;
	}

}
declare module Coveo {
	/// <reference path="../Facet/Facet.d.ts" />
	class HierarchicalFacetSearchValuesList extends FacetSearchValuesList {
	    facet: Facet;
	    constructor(facet: Facet);
	}

}
declare module Coveo {
	/// <reference path="HierarchicalFacet.d.ts" />
	class OmniboxHierarchicalValueElement extends OmniboxValueElement {
	    facet: HierarchicalFacet;
	    facetValue: FacetValue;
	    eventArg: IPopulateOmniboxObject;
	    constructor(facet: HierarchicalFacet, facetValue: FacetValue, eventArg: IPopulateOmniboxObject);
	    _handleSelectValue(eventBindings: IValueElementEventsBinding): void;
	    _handleExcludeClick(eventBindings: IValueElementEventsBinding): void;
	}

}
declare module Coveo {
	/// <reference path="HierarchicalFacet.d.ts" />
	class OmniboxHierarchicalValuesList extends OmniboxValuesList {
	    facet: HierarchicalFacet;
	    facetValues: FacetValue[];
	    omniboxObject: IPopulateOmniboxObject;
	    constructor(facet: HierarchicalFacet, facetValues: FacetValue[], omniboxObject: IPopulateOmniboxObject);
	}

}
declare module Coveo {
	/// <reference path="../../controllers/HierarchicalFacetQueryController.d.ts" />
	/// <reference path="HierarchicalFacetValuesList.d.ts" />
	/// <reference path="HierarchicalFacetSearch.d.ts" />
	/// <reference path="HierarchicalBreadcrumbValuesList.d.ts" />
	/// <reference path="HierarchicalFacetValueElement.d.ts" />
	interface IHierarchicalFacetOptions extends IFacetOptions {
	    delimitingCharacter?: string;
	    levelStart?: number;
	    levelEnd?: number;
	    marginByLevel?: number;
	}
	interface IValueHierarchy {
	    childs?: IValueHierarchy[];
	    parent?: IValueHierarchy;
	    originalPosition?: number;
	    facetValue: FacetValue;
	    level: number;
	    keepOpened: boolean;
	    hasChildSelected: boolean;
	    allChildShouldBeSelected: boolean;
	}
	/**
	 * @deprecated This component is exposed for legacy reasons. Instead, use the {@link CategoryFacet} component, which is more performant and easier to use.
	 *
	 * The `HierarchicalFacet` component inherits all of its options and behaviors from the [`Facet`]{@link Facet}
	 * component, but is meant to be used to render hierarchical values.
	 *
	 * **Note:**
	 * > The `HierarchicalFacet` component does not support the [`customSort`]{@link Facet.options.customSort}
	 * > `Facet` option.
	 *
	 * The `HierarchicalFacet` component can be used to display files in a file system, or categories for items in a
	 * hierarchy.
	 *
	 * This facet requires a group by field with a special format to work correctly.
	 *
	 * **Example:**
	 *
	 * You have the following files indexed on a file system:
	 * ```
	 * c:\
	 *   folder1\
	 *     text1.txt
	 *   folder2\
	 *     folder3\
	 *       text2.txt
	 * ```
	 * The `text1.txt` item would have a field with the following format:
	 * `c; c|folder1;`
	 *
	 * The `text2.txt` item would have a field with the following format:
	 * `c; c|folder2; c|folder2|folder3;`
	 *
	 * By default, the `|` character determines the hierarchy (`folder3` inside `folder2` inside `c`).
	 *
	 * Since both items contain the `c` value, selecting it value in the facet would return both items.
	 *
	 * Selecting the `folder3` value in the facet would only return the `text2.txt` item.
	 *
	 * @notSupportedIn salesforcefree
	 *
	 * @deprecatedSince [January 2019 Release (v2.5395.12)](https://docs.coveo.com/en/2763/)
	 */
	class HierarchicalFacet extends Facet implements IComponentBindings {
	    element: HTMLElement;
	    bindings: IComponentBindings;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IHierarchicalFacetOptions;
	    static parent: typeof Facet;
	    options: IHierarchicalFacetOptions;
	    facetValuesList: HierarchicalFacetValuesList;
	    numberOfValuesToShow: number;
	    facetQueryController: HierarchicalFacetQueryController;
	    topLevelHierarchy: IValueHierarchy[];
	    shouldReshuffleFacetValuesClientSide: boolean;
	    isFieldValueCompatible: boolean;
	    /**
	     * Creates a new `HierarchicalFacet` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `HierarchicalFacet` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options: IHierarchicalFacetOptions, bindings: IComponentBindings);
	    /**
	     * Selects a single value.
	     * @param value The value to select.
	     * @param selectChildren Specifies whether to also select all child values (if any). Default value is the opposite of
	     * the [`useAnd`]{@link Facet.options.useAnd} option value set for this `HierarchicalFacet`.
	     */
	    selectValue(value: FacetValue | string, selectChildren?: boolean): void;
	    /**
	     * Selects multiple values
	     * @param values The array of values to select.
	     * @param selectChildren Specifies whether to also select all child values (if any). Default value is the opposite of
	     * the [`useAnd`]{@link Facet.options.useAnd} option value set for this `HierarchicalFacet`.
	     */
	    selectMultipleValues(values: FacetValue[] | string[], selectChildren?: boolean): void;
	    /**
	     * Deselects a single value
	     * @param value The value to deselect.
	     * @param deselectChildren Specifies whether to also deselect all child values (if any). Default value is `true`.
	     */
	    deselectValue(value: FacetValue | string, deselectChildren?: boolean): void;
	    /**
	     * Excludes a single value.
	     * @param value The value to exclude.
	     * @param excludeChildren Specifies whether to also exclude all child values (if any). Default value is the opposite
	     * of the [`useAnd`]{@link Facet.options.useAnd} option value set for this `HierarchicalFacet`.
	     */
	    excludeValue(value: FacetValue | string, excludeChildren?: boolean): void;
	    /**
	     * Un-excludes a single value.
	     * @param value The value to un-exclude.
	     * @param unexludeChildren Specifies whether to also un-exclude all child values (if any). Default value is the
	     * opposite of the [`useAnd`]{@link Facet.options.useAnd} option value set for this `HierarchicalFacet`.
	     */
	    unexcludeValue(value: FacetValue | string, unexludeChildren?: boolean): void;
	    /**
	     * Deselects multiple values.
	     * @param values The array of values to deselect.
	     * @param deselectChildren Specifies whether to also deselect all child values (if any). Default value is the opposite
	     * of the [`useAnd`]{@link Facet.options.useAnd} option value set for this `HierarchicalFacet`.
	     */
	    deselectMultipleValues(values: FacetValue[] | string[], deselectChildren?: boolean): void;
	    /**
	     * Toggles the selection of a single value (selects value if not selected; deselects value if selected).
	     * @param value The value to select or deselect.
	     */
	    toggleSelectValue(value: FacetValue | string): void;
	    /**
	     * Toggles the exclusion of a single value (excludes value if not excluded; un-excludes value if excluded).
	     * @param value The value to exclude or un-exclude.
	     */
	    toggleExcludeValue(value: FacetValue | string): void;
	    /**
	     * Gets the caption of a single value.
	     * @param facetValue The value whose caption the method should return.
	     * @returns {string} The caption of the value.
	     */
	    getValueCaption(facetValue: IIndexFieldValue | FacetValue): string;
	    /**
	     * Gets the values that the `HierarchicalFacet` is currently displaying.
	     * @returns {any[]} An array containing all the values that the `HierarchicalFacet` is currently displaying.
	     */
	    getDisplayedValues(): string[];
	    /**
	     * Updates the sort criteria for the `HierarchicalFacet`.
	     *
	     * See the [`sortCriteria`]{@link IGroupByRequest.sortCriteria} property of the [`IGroupByRequest`] interface for the
	     * list and description of possible values.
	     *
	     * @param criteria The new sort criteria.
	     */
	    updateSort(criteria: string): void;
	    /**
	     * Opens (expands) a single value and shows all its children.
	     * @param value The value to open.
	     */
	    open(value: FacetValue | IValueHierarchy | string): void;
	    /**
	     * Closes (collapses) a single value and hides all its children.
	     * @param value The value to close.
	     */
	    close(value: FacetValue | IValueHierarchy | string): void;
	    /**
	     * Resets the `HierarchicalFacet` state.
	     */
	    reset(): void;
	    processFacetSearchAllResultsSelected(facetValues: FacetValue[]): void;
	    protected triggerUpdateDeltaQuery(facetValues: FacetValue[]): void;
	    protected updateSearchElement(moreValuesAvailable?: boolean): void;
	    protected facetValueHasChanged(): void;
	    protected initFacetQueryController(): void;
	    protected initFacetSearch(): void;
	    protected handleDeferredQuerySuccess(data: IQuerySuccessEventArgs): void;
	    protected handlePopulateSearchAlerts(args: ISearchAlertsPopulateMessageEventArgs): void;
	    protected handlePopulateBreadcrumb(args: IPopulateBreadcrumbEventArgs): void;
	    protected handleOmniboxWithStaticValue(eventArg: IPopulateOmniboxEventArgs): void;
	    protected rebuildValueElements(): void;
	    protected initFacetValuesList(): void;
	    protected updateMoreLess(): void;
	    protected handleClickMore(): void;
	    protected handleClickLess(): void;
	    protected updateNumberOfValues(): void;
	    getValueFromHierarchy(value: any): IValueHierarchy;
	    getAllValueHierarchy(): {
	        [facetValue: string]: IValueHierarchy;
	    };
	}

}
declare module Coveo {
	/**
	 * Available options for the {@link Icon} component.
	 */
	interface IIconOptions {
	    value?: string;
	    small?: boolean;
	    withLabel?: boolean;
	    labelValue?: string;
	    conditions?: IFieldConditionOption[];
	}
	/**
	 * The Icon component outputs the corresponding icon for a given file type. The component searches for a suitable icon
	 * from those available in the Coveo JavaScript Search Framework. If the component finds no suitable icon, it instead
	 * outputs a generic icon.
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 */
	class Icon extends Component {
	    element: HTMLElement;
	    options: IIconOptions;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the Icon
	     * @componentOptions
	     */
	    static options: IIconOptions;
	    /**
	     * Creates a new Icon component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the Icon component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     */
	    constructor(element: HTMLElement, options?: IIconOptions, bindings?: IComponentBindings, result?: IQueryResult);
	    static createIcon(result: IQueryResult, options?: IIconOptions, element?: HTMLElement, bindings?: IComponentBindings): HTMLElement;
	    static shouldDisplayLabel(options: IIconOptions, bindings: IComponentBindings): boolean;
	    static preprocessIconInfo(options: IIconOptions, info: IFileTypeInfo): IFileTypeInfo;
	}

}
declare module Coveo {
	function registerFields(): void;

}
declare module Coveo {
	type ValidLogoTarget = '_top' | '_blank' | '_self' | '_parent';
	interface ILogoOptions {
	    target: string;
	}
	/**
	 * The Logo component adds a clickable Coveo logo in the search interface.
	 */
	class Logo extends Component {
	    element: HTMLElement;
	    options: ILogoOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The possible options for the component
	     * @componentOptions
	     */
	    static options: ILogoOptions;
	    /**
	     * Creates a new Logo component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the Logo component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: ILogoOptions, bindings?: IComponentBindings);
	    hide(): void;
	    show(): void;
	}

}
declare module Coveo {
	/**
	 * Represent a single cell of data in the {@link Matrix} component.
	 */
	class Cell {
	    constructor(value?: any, el?: HTMLElement);
	    /**
	     * Return the value of the cell.
	     * @returns {any}
	     */
	    getValue(): any;
	    /**
	     * Return the `HTMLElement` for the cell.
	     * @returns {HTMLElement}
	     */
	    getHTML(): HTMLElement;
	    /**
	     * Set the value if the cell.
	     * @param value
	     */
	    setValue(value: any): void;
	    /**
	     * Set the `HTMLElement` for the cell.
	     * @param html
	     */
	    setHTML(html: HTMLElement): void;
	    /**
	     * Show the preview of the cell.
	     * @param minWidth css minWidth property : eg 100px
	     * @param maxWidth css maxWidth property : eg 100px
	     */
	    addPreview(minWidth: string, maxWidth: string): void;
	    /**
	     * Remove the preview of the cell
	     */
	    removePreview(): void;
	    /**
	     * Update the preview with a new template
	     * @param template
	     */
	    updatePreview(template: string): void;
	}

}
declare module Coveo {
	class DefaultMatrixResultPreviewTemplate extends Template {
	    constructor(computedField: string, format: string);
	    instantiateToString(object?: IQueryResult, instantiateOptions?: IInstantiateTemplateOptions): string;
	    instantiateToElement(object?: IQueryResult, instantiateOptions?: IInstantiateTemplateOptions): Promise<HTMLElement>;
	}

}
declare module Coveo {
	interface IMatrixOptions {
	    title?: string;
	    rowField: IFieldOption;
	    sortCriteria?: string;
	    maximumNumberOfRows?: number;
	    enableRowTotals?: boolean;
	    columnField: IFieldOption;
	    columnFieldValues?: string[];
	    columnLabels?: string[];
	    columnHeader?: string;
	    maximumNumberOfValuesInGroupBy?: number;
	    enableColumnTotals?: boolean;
	    computedField: IFieldOption;
	    computedFieldOperation?: string;
	    computedFieldFormat?: string;
	    cellFontSize?: string;
	    enableHoverPreview?: boolean;
	    previewSortCriteria?: string;
	    previewSortField?: IFieldOption;
	    previewMaxWidth?: string;
	    previewMinWidth?: string;
	    previewDelay?: number;
	    previewTemplate?: Template;
	}
	/**
	 * The Matrix component uses the values of two fields (row and column) to display the results of the specified computed
	 * field in a table.
	 *
	 * The user specifies the values to use for the columns. An {@link IGroupByRequest} operation performed at the same time
	 * as the main query retrieves the values to use for the rows.
	 *
	 * In a way that is similar to the {@link Facet} component, selecting a Matrix cell allows the end user to drill down
	 * inside the results by restricting the row field and the column field to match the values of the selected cell.
	 *
	 * @notSupportedIn salesforcefree
	 */
	class Matrix extends Component {
	    element: HTMLElement;
	    options: IMatrixOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The possible options for the component
	     * @componentOptions
	     */
	    static options: IMatrixOptions;
	    /**
	     * Holds the data for the Matrix.
	     */
	    data: Cell[][];
	    groupByIndex: any[];
	    rowId: string;
	    columnId: string;
	    /**
	     * The currently selected row value, or `any` if nothing is selected.
	     */
	    selectedRowValue: string;
	    /**
	     * The currently selected column value, or `any` if nothing is selected.
	     */
	    selectedColumnValue: any;
	    /**
	     * Creates a new Matrix. Also verifies whether options are valid and coherent. Binds query events.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the Matrix component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IMatrixOptions, bindings?: IComponentBindings);
	    /**
	     * Selects a cell by its row and column number. Does not execute a query.
	     * @param rowNumber The row number of the cell to select.
	     * @param columnNumber The column number of the cell to select.
	     */
	    selectCell(rowNumber: number, columnNumber: number): void;
	    /**
	     * Returns the currently selected column value.
	     */
	    getSelectedColumnValue(): string;
	    /**
	     * Returns the currently selected row value.
	     */
	    getSelectedRowValue(): string;
	    /**
	     * Gets the HTMLElement associated to a cell.
	     * @param rowNumber The row number of the cell.
	     * @param columnNumber The column number of the cell.
	     * @returns {HTMLElement} The associated HTMLElement.
	     */
	    getCellElement(rowNumber: number, columnNumber: number): HTMLElement;
	    /**
	     * Gets the string associated to a cell.
	     * @param rowNumber The row number of the cell.
	     * @param columnNumber The column number of the cell.
	     * @returns {string} The associated string.
	     */
	    getCellValue(rowNumber: number, columnNumber: number): string;
	    drawMatrix(): void;
	}

}
declare module Coveo {
	interface IOmniboxResultListOptions extends IResultListOptions {
	    omniboxZIndex?: number;
	    onSelect?: (result: IQueryResult, resultElement: HTMLElement, omniboxObject: IPopulateOmniboxEventArgs, event?: Event) => void;
	    headerTitle?: string;
	    queryOverride?: IQueryExpression;
	}
	/**
	 * The OmniboxResultList component behaves exactly like the {@link ResultList} component (which it extends), except that
	 * it renders itself inside the {@link Omnibox} component.
	 *
	 * This component can provide a kind of search-as-you-type functionality, allowing you to easily render complex Result
	 * Templates inside the Omnibox component.
	 *
	 * **Example:**
	 *
	 * ```html
	 * <div class="CoveoOmniboxResultList">
	 *   <script class="result-template" type="text/x-underscore">
	 *     <div>
	 *       <a class='CoveoResultLink'></a>
	 *     </div>
	 *   </script>
	 * </div>
	 * ```
	 */
	class OmniboxResultList extends ResultList implements IComponentBindings {
	    element: HTMLElement;
	    options: IOmniboxResultListOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    /**
	     * Specifies a list a css class that should be ignored when the end user click result in the omnibox
	     *
	     * Any element that is specified here should normally be able to handle the standard click event.
	     *
	     * Any element that does not match this css class and that is clicked will trigger a redirection by the OmniboxResultList.
	     */
	    static elementsToIgnore: string[];
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IOmniboxResultListOptions;
	    /**
	     * Creates a new OmniboxResultList component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the OmniboxResultList component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IOmniboxResultListOptions, bindings?: IComponentBindings);
	    /**
	     * Builds and returns an array of `HTMLElement` from the {@link IQueryResults} set received as an argument.
	     * @param results The IQueryResults set to build an array of `HTMLElement` from.
	     */
	    buildResults(results: IQueryResults): Promise<HTMLElement[]>;
	    /**
	     * Creates a result container and appends each element from the received `HTMLElement` array to it. For each element
	     * it appends to the result container, this method triggers a `newResultDisplayed` event. Once all elements have been
	     * appended to the result container, the method triggers a `newResultsDisplayed` event.
	     * @param resultElements The array of `HTMLElement` to render.
	     * @param append
	     */
	    renderResults(resultElements: HTMLElement[], append?: boolean): Promise<any>;
	    protected handleChangeLayout(): void;
	    protected handleBuildingQuery(args: IBuildingQueryEventArgs): void;
	    protected initResultContainerAddToDom(): void;
	}

}
declare module Coveo {
	interface IPagerOptions {
	    numberOfPages: number;
	    enableNavigationButton: boolean;
	    maxNumberOfPages: number;
	    maximumNumberOfResultsFromIndex: number;
	}
	/**
	 * The Pager component attaches itself to a `div` element and renders widgets that allow the end user to navigate
	 * through the different result pages.
	 *
	 * This component takes care of triggering a query with the correct result range whevoid the end user selects a page or
	 * uses the navigation buttons (**Previous** and **Next**).
	 */
	class Pager extends Component {
	    element: HTMLElement;
	    options: IPagerOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the Pager
	     * @componentOptions
	     */
	    static options: IPagerOptions;
	    /**
	     * Creates a new Pager. Binds multiple query events ({@link QueryEvents.newQuery}, {@link QueryEvents.buildingQuery},
	     * {@link QueryEvents.querySuccess}, {@link QueryEvents.queryError} and {@link QueryEvents.noResults}. Renders itself
	     * on every query success.
	     * @param element The HTMLElement on which to instantiate the component (normally a `div`).
	     * @param options The options for the Pager component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IPagerOptions, bindings?: IComponentBindings);
	    /**
	     * The current page (1-based index).
	     */
	    currentPage: number;
	    /**
	     * Sets the current page, then executes a query.
	     *
	     * Also logs an event in the usage analytics (`pageNumber` by default) with the new current page number as meta data.
	     *
	     * @param pageNumber The page number to navigate to.
	     * @param analyticCause The event to log in the usage analytics.
	     */
	    setPage(pageNumber: number, analyticCause?: IAnalyticsActionCause): void;
	    /**
	     * Navigates to the previous page, then executes a query.
	     *
	     * Also logs the `pagePrevious` event in the usage analytics with the new current page number as meta data.
	     */
	    previousPage(): void;
	    /**
	     * Navigates to the next page, then executes a query.
	     *
	     * Also logs the `pageNext` event in the usage analytics with the new current page number as meta data.
	     */
	    nextPage(): void;
	}

}
declare module Coveo {
	interface IPipelineContextOptions {
	}
	/**
	 * The `PipelineContext` component injects custom contextual information into the search requests and usage analytics search events sent from a search interface.
	 *
	 * This component is meant to be initialized on a `script` HTML tag whose `type` attribute is set to `text/context` and whose optional JSON content defines the custom information to send (each value can be set to a string or array of strings).
	 *
	 * See [Sending Custom Context Information](https://docs.coveo.com/en/399/).
	 * Note: To customize the context sent on all usage analytics events, see [Sending Custom Metadata with Search, Click, or Custom Events](https://docs.coveo.com/en/2004/javascript-search-framework/sending-custom-metadata-with-search-click-or-custom-events).
	 */
	class PipelineContext extends Component implements IPipelineContextProvider {
	    element: HTMLElement;
	    options: IPipelineContextOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    static CURRENT_URL: string;
	    static doExport: () => void;
	    constructor(element: HTMLElement, options?: IPipelineContextOptions, bindings?: IComponentBindings);
	    /**
	     * **Available since the [December 2017 Release](https://docs.coveo.com/en/373).**
	     *
	     * Sets a new context, replacing the previous context if applicable.
	     *
	     * @param newContext The new context to set, which can be directly passed as a JSON, or as a stringified JSON.
	     */
	    setContext(newContext: string | Context): void;
	    /**
	     * Returns the current context
	     */
	    getContext(): Context;
	    /**
	     * **Available since the [December 2017 Release](https://docs.coveo.com/en/373).**
	     *
	     * Sets a value for a context key, replacing the previous value if applicable.
	     * @param contextKey
	     * @param contextValue
	     */
	    setContextValue(contextKey: string, contextValue: string | string[]): void;
	    /**
	     * Return all the context keys configured for context.
	     * @returns {string[]}
	     */
	    getContextKeys(): string[];
	    /**
	     * Get the context value associated to the given key.
	     *
	     * If the global variable Coveo.context contains the requested key, this method will return the value contained in Coveo.context instead of the one contained internally.
	     *
	     * This is especially useful in a Coveo for Salesforce context, where context values can be extracted from a backend service.
	     * @param key
	     * @returns {string}
	     */
	    getContextValue(key: string): string | string[];
	}

}
declare module Coveo {
	interface IPreferencesPanelOptions {
	}
	/**
	 * The PreferencesPanel component renders a **Preferences** item inside the {@link Settings} component which the end
	 * user can click to access a panel from which it is possible to specify certain customization options for the search
	 * interface. These customization options are then saved in the browser local storage.
	 *
	 * This component should be used inside the {@link Settings} component.
	 *
	 * See also the {@link ResultsFiltersPreferences} and {@link ResultsPreferences} components.
	 */
	class PreferencesPanel extends Component {
	    element: HTMLElement;
	    options: IPreferencesPanelOptions;
	    static ID: string;
	    static doExport: () => void;
	    static options: IPreferencesPanelOptions;
	    /**
	     * Creates a new PreferencesPanel.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the PreferencesPanel component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options: IPreferencesPanelOptions, bindings?: IComponentBindings, ModalBox?: any);
	    /**
	     * Opens the PreferencesPanel.
	     */
	    open(): void;
	    /**
	     * Closes the PreferencesPanel without saving changes.
	     *
	     * Also triggers the `exitPreferencesWithoutSave` event.
	     */
	    close(): void;
	    /**
	     * Saves the changes and executes a new query.
	     *
	     * Also triggers the `savePreferences` event.
	     */
	    save(): void;
	}

}
declare module Coveo {
	interface IPrintableUriOptions extends IResultLinkOptions {
	}
	/**
	 * The `PrintableUri` component inherits from the [ `ResultLink` ]{@link ResultLink} component and supports all of its options.
	 *
	 * This component displays the URI, or path, to access a result.
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 */
	class PrintableUri extends Component {
	    element: HTMLElement;
	    options: IPrintableUriOptions;
	    bindings: IResultsComponentBindings;
	    result: IQueryResult;
	    static ID: string;
	    static options: IPrintableUriOptions;
	    static doExport: () => void;
	    /**
	     * Creates a new PrintableUri.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the PrintableUri component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     */
	    constructor(element: HTMLElement, options: IPrintableUriOptions, bindings?: IResultsComponentBindings, result?: IQueryResult);
	    /**
	     * Opens the result in the same window, no matter how the actual component is configured for the end user.
	     * @param logAnalytics Specifies whether the method should log an analytics event.
	     */
	    openLink(logAnalytics?: boolean): void;
	    /**
	     * Opens the result in a new window, no matter how the actual component is configured for the end user.
	     * @param logAnalytics Specifies whether the method should log an analytics event.
	     */
	    openLinkInNewWindow(logAnalytics?: boolean): void;
	    /**
	     * Opens the link in the same manner the end user would.
	     *
	     * This essentially simulates a click on the result link.
	     *
	     * @param logAnalytics Specifies whether the method should log an analytics event.
	     */
	    openLinkAsConfigured(logAnalytics?: boolean): void;
	}

}
declare module Coveo {
	function registerFields(): void;

}
declare module Coveo {
	interface IQueryDurationOptions {
	}
	/**
	 * The QueryDuration component displays the duration of the last query execution.
	 *
	 * When a {@link QueryEvents.querySuccess} event is triggered, the QueryDuration component becomes visible. It also
	 * displays the global duration, the index duration, and the client duration in a single tooltip.
	 *
	 * If a {@link QueryEvents.queryError} event is triggered, the QueryDuration component becomes hidden.
	 */
	class QueryDuration extends Component {
	    element: HTMLElement;
	    options: IQueryDurationOptions;
	    static ID: string;
	    static doExport: () => void;
	    static options: IQueryDurationOptions;
	    /**
	     * Creates a new QueryDuration component.
	     * Binds handlers on the {@link QueryEvents.querySuccess} and {@link QueryEvents.queryError} events.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the QueryDuration component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IQueryDurationOptions, bindings?: IComponentBindings);
	}

}
declare module Coveo {
	interface IQuerySummaryOptions {
	    onlyDisplaySearchTips?: boolean;
	    enableNoResultsFoundMessage?: boolean;
	    noResultsFoundMessage?: string;
	    enableCancelLastAction?: boolean;
	    enableSearchTips?: boolean;
	}
	/**
	 * The QuerySummary component can display information about the currently displayed range of results (e.g., "Results
	 * 1-10 of 123").
	 *
	 * When the query does not match any items, the QuerySummary component can instead display information to the end users.
	 *
	 * The information displayed to the end user is customizable through this component.
	 */
	class QuerySummary extends Component {
	    element: HTMLElement;
	    options: IQuerySummaryOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * Options for the component
	     * @componentOptions
	     */
	    static options: IQuerySummaryOptions;
	    /**
	     * Creates a new QuerySummary component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the QuerySummary component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IQuerySummaryOptions, bindings?: IComponentBindings);
	}

}
declare module Coveo {
	class DefaultQuickviewTemplate extends Template {
	    constructor();
	    instantiateToString(queryResult?: IQueryResult): string;
	}

}
declare module Coveo {
	class QuickviewDocumentIframe {
	    el: HTMLElement;
	    constructor();
	     iframeHTMLElement: HTMLIFrameElement;
	     document: Document;
	     body: HTMLElement;
	     window: Window;
	    isNewQuickviewDocument(): boolean;
	    render(htmlDocument: HTMLDocument, title: string): Promise<HTMLIFrameElement>;
	    renderError(error: AjaxError): Promise<HTMLIFrameElement>;
	}

}
declare module Coveo {
	class QuickviewDocumentWordColor {
	    htmlColor: string;
	    r: number;
	    g: number;
	    b: number;
	    constructor(htmlColor: string);
	    invert(): string;
	    saturate(): string;
	}

}
declare module Coveo {
	class QuickviewDocumentWord {
	    result: IQueryResult;
	    text: string;
	    count: number;
	    numberOfEmbeddedWords: number;
	    occurrence: number;
	    indexIdentifier: string;
	    indexTermPart: number;
	    elements: HTMLElement[];
	    currentNavigationPosition: number;
	    color: QuickviewDocumentWordColor;
	    constructor(result: IQueryResult);
	    addElement(element: HTMLElement): void;
	    navigateForward(): HTMLElement;
	    navigateBackward(): HTMLElement;
	    navigateTo(position: number): HTMLElement;
	    doCompleteInitialScanForKeywordInDocument(element: HTMLElement): void;
	    isTaggedWord(element: HTMLElement): boolean;
	}

}
declare module Coveo {
	class QuickviewDocumentWords {
	    iframe: QuickviewDocumentIframe;
	    result: IQueryResult;
	    words: any;
	    constructor(iframe: QuickviewDocumentIframe, result: IQueryResult);
	}

}
declare module Coveo {
	/// <reference types="map" />
	/// <reference types="lodash" />
	class QuickviewDocumentPreviewBar {
	    iframe: QuickviewDocumentIframe;
	    words: QuickviewDocumentWords;
	    wordIndicators: Map<QuickviewDocumentWord, {
	        indicators: HTMLElement[];
	        position: number;
	    }>;
	    constructor(iframe: QuickviewDocumentIframe, words: QuickviewDocumentWords);
	    navigateForward(word: QuickviewDocumentWord): HTMLElement;
	    navigateBackward(word: QuickviewDocumentWord): HTMLElement;
	    navigateTo(position: number, word: QuickviewDocumentWord): HTMLElement;
	}

}
declare module Coveo {
	class QuickviewDocumentWordButton {
	    word: QuickviewDocumentWord;
	    previewBar: QuickviewDocumentPreviewBar;
	    iframe: QuickviewDocumentIframe;
	    el: HTMLElement;
	    constructor(word: QuickviewDocumentWord, previewBar: QuickviewDocumentPreviewBar, iframe: QuickviewDocumentIframe);
	    render(): HTMLElement;
	}

}
declare module Coveo {
	class QuickviewDocumentHeader {
	    el: HTMLElement;
	    constructor();
	    addWord(wordButton: QuickviewDocumentWordButton): void;
	}

}
declare module Coveo {
	interface IQuickviewDocumentOptions {
	    maximumDocumentSize?: number;
	}
	/**
	 * The `QuickviewDocument` component normally exists within a [`Quickview`]{@link Quickview} component. The sole purpose
	 * of this component is to add an `<iframe>` which loads the correct HTML version of the current item.
	 *
	 * The default [`contentTemplate`]{@link Quickview.options.contentTemplate} of the
	 * `Quickview` component includes the `QuickviewDocument` component.
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 */
	class QuickviewDocument extends Component {
	    element: HTMLElement;
	    options: IQuickviewDocumentOptions;
	    result: IQueryResult;
	    static ID: string;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IQuickviewDocumentOptions;
	    /**
	     * Creates a new `QuickviewDocument` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `QuickviewDocument` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The current result.
	     */
	    constructor(element: HTMLElement, options?: IQuickviewDocumentOptions, bindings?: IComponentBindings, result?: IQueryResult);
	    createDom(): void;
	    open(): Promise<void>;
	}

}
declare module Coveo {
	/// <reference types="modal-box" />
	/**
	 * The allowed [`Quickview`]{@link Quickview} [`tooltipPlacement`]{@link Quickview.options.tooltipPlacement} option values. The `-start` and `-end` variations indicate relative alignement. Horizontally (`top`, `bottom`), `-start` means _left_ and `-end` means _right_. Vertically (`left`, `right`), `-start` means _top_ and `-end` means _bottom_. No variation means _center_.
	 */
	type ValidTooltipPlacement = 'auto-start' | 'auto' | 'auto-end' | 'top-start' | 'top' | 'top-end' | 'right-start' | 'right' | 'right-end' | 'bottom-end' | 'bottom' | 'bottom-start' | 'left-end' | 'left' | 'left-start';
	interface IQuickviewOptions {
	    title?: string;
	    showDate?: boolean;
	    contentTemplate?: Template;
	    enableLoadingAnimation?: boolean;
	    loadingAnimation?: HTMLElement | Promise<HTMLElement>;
	    alwaysShow?: boolean;
	    tooltipPlacement?: ValidTooltipPlacement;
	}
	/**
	 * The `Quickview` component renders a button/link which the end user can click to open a modal box containing certain
	 * information about a result. Most of the time, this component references a
	 * [`QuickviewDocument`]{@link QuickviewDocument} in its [`contentTemplate`]{@link Quickview.options.contentTemplate}.
	 *
	 * **Notes:**
	 * > - `Quickview` is not meant to replace a [ResultLink]{@link ResultLink} to access an item; it has certain limitations (e.g., custom styles and embedded
	 * images/links may not work as expected in a `Quickview`).
	 * > - You can change the appearance of the `Quickview` link/button by adding elements in the inner HTML of its `div`.
	 * > - You can change the content of the `Quickview` modal box link by specifying a template `id` or CSS selector (see
	 * > the [`contentTemplate`]{@link Quickview.options.contentTemplate} option).
	 * > - When using Coveo for Salesforce 3.16, in an environment compliant with LockerService, ensure you use `CoveoSalesforceQuickview` (see [Changing the Default Quick View in Coveo for Salesforce](https://docs.coveo.com/en/1234/)).
	 *
	 * **Example:**
	 * ```html
	 * [ ... ]
	 *
	 * <script class='result-template' type='text/underscore' id='myContentTemplateId'>
	 *   <div>
	 *     <span>This content will be displayed when then end user opens the quickview modal box. It could also include other Coveo component, and use core helpers.</span>
	 *     <table class="CoveoFieldTable">
	 *       <tr data-field="@liboardshorttitle" data-caption="Board" />
	 *       <tr data-field="@licategoryshorttitle" data-caption="Category" />
	 *       <tr data-field="@sysauthor" data-caption="Author" />
	 *     </table>
	 *   </div>
	 * </script>
	 *
	 * [ ... ]
	 *
	 * <div class='CoveoResultList'>
	 *   <script class='result-template' type='text/underscore' id='myResultTemplateId'>
	 *
	 *   [ ... ]
	 *
	 *     <!-- The `myContentTemplateId` template applies when displaying content in the quickview modal box. -->
	 *       <div class='CoveoQuickview' data-template-id='myContentTemplateId'>
	 *         <!-- This changes the appearance of the Quickview button itself in the results -->
	 *         <span>Click here for a quickview</span>
	 *       </div>
	 *   </script>
	 *
	 *   [ ... ]
	 *
	 * <!-- Note that simply including `<div class='CoveoQuickview'></div>` in the markup will be enough most of the time, since the component includes a default template and a default button appearance. -->
	 * ```
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 */
	class Quickview extends Component {
	    element: HTMLElement;
	    options: IQuickviewOptions;
	    bindings: IResultsComponentBindings;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * @componentOptions
	     */
	    static options: IQuickviewOptions;
	    static resultCurrentlyBeingRendered: IQueryResult;
	    /**
	     * Creates a new `Quickview` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `Quickview` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     * @param ModalBox The quickview modal box.
	     */
	    constructor(element: HTMLElement, options?: IQuickviewOptions, bindings?: IResultsComponentBindings, result?: IQueryResult, ModalBox?: Coveo.ModalBox.ModalBox);
	    /**
	     * Opens the `Quickview` modal box.
	     */
	    open(): Promise<void>;
	    /**
	     * Closes the `Quickview` modal box.
	     */
	    close(): void;
	    getHashId(): string;
	}

}
declare module Coveo {
	function registerFields(): void;

}
declare module Coveo {
	class DefaultResultAttachmentTemplate extends Template {
	    constructor();
	    instantiateToString(queryResult?: IQueryResult): string;
	}

}
declare module Coveo {
	interface IResultAttachmentsOptions {
	    resultTemplate?: Template;
	    subResultTemplate?: Template;
	    maximumAttachmentLevel?: number;
	}
	/**
	 * The `ResultAttachments` component renders attachments in a result set, for example when displaying emails. This
	 * component is usable inside a result template when there is an active [`Folding`]{@link Folding} component in the
	 * page.
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 * @notSupportedIn salesforcefree
	 */
	class ResultAttachments extends Component {
	    element: HTMLElement;
	    options: IResultAttachmentsOptions;
	    bindings: IComponentBindings;
	    attachmentLevel: number;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IResultAttachmentsOptions;
	    /**
	     * Creates a new `ResultAttachments` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `ResultAttachments` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     * @param attachmentLevel The nesting depth.
	     */
	    constructor(element: HTMLElement, options?: IResultAttachmentsOptions, bindings?: IComponentBindings, result?: IQueryResult, attachmentLevel?: number);
	}

}
declare module Coveo {
	interface IResultActionsMenuOptions {
	    openOnMouseOver?: boolean;
	}
	/**
	 * The _ResultActionsMenu_ component adds a floating result action menu, meant to be used inside result templates (see [Result Templates](https://docs.coveo.com/en/413/javascript-search-framework/result-templates)).
	 * It is designed to contain other components that can execute actions related to the result,
	 * typically the [Quickview]{@link Quickview} and AttachToCase components, available in the Coveo for Salesforce and Coveo for Dynamics integrations.
	 *
	 * ```html
	 * <script type="text/html" class="result-template" [...]
	 *   <div class="coveo-result-frame">
	 *     <div class="CoveoResultActionsMenu">
	 *       <div class="CoveoQuickview"></div>
	 *     </div>
	 *   [...]
	 * </script>
	 * ```
	 *
	 * @availablesince [July 2018 Release (v2.4382.10)](https://docs.coveo.com/410/#july-2018-release-v2438210)
	 */
	class ResultActionsMenu extends Component {
	    element: HTMLElement;
	    options: IResultActionsMenuOptions;
	    bindings: IResultsComponentBindings;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    static  SHOW_CLASS: string;
	    /**
	     * @componentOptions
	     */
	    static options: IResultActionsMenuOptions;
	    /**
	     * The rendered result that contains this menu.
	     */
	    parentResult: HTMLElement;
	    /**
	     * A list containing menu items for this menu.
	     */
	    menuItems: HTMLElement[];
	    /**
	     * Creates a new `ResultActionsMenu` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `ResultActionsMenu` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     */
	    constructor(element: HTMLElement, options: IResultActionsMenuOptions, bindings?: IResultsComponentBindings, result?: IQueryResult);
	    /**
	     * Shows the floating menu.
	     */
	    show(): void;
	    /**
	     * Hides the floating menu.
	     */
	    hide(): void;
	}

}
declare module Coveo {
	class DefaultFoldingTemplate extends Template {
	    constructor();
	    instantiateToString(queryResult?: IQueryResult): string;
	    getType(): string;
	}

}
declare module Coveo {
	interface IResultFoldingOptions {
	    resultTemplate?: Template;
	    normalCaption?: string;
	    expandedCaption?: string;
	    moreCaption?: string;
	    lessCaption?: string;
	    oneResultCaption?: string;
	}
	/**
	 * The `ResultFolding` component renders folded result sets. It is usable inside a result template when there is an
	 * active [`Folding`]{@link Folding} component in the page. This component takes care of rendering the parent result and
	 * its child results in a coherent manner.
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 *
	 * See [Folding Results](https://docs.coveo.com/en/428/).
	 */
	class ResultFolding extends Component {
	    element: HTMLElement;
	    options: IResultFoldingOptions;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IResultFoldingOptions;
	    childResults: IQueryResult[];
	    /**
	     * Creates a new ResultFolding component.
	     * @param options The options for the ResultFolding component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     */
	    constructor(element: HTMLElement, options?: IResultFoldingOptions, bindings?: IComponentBindings, result?: IQueryResult);
	    /**
	     * Show more results by fetching additional results from the index, which match the current folded conversation.
	     * This is the equivalent of clicking "Show all conversation".
	     * @returns {Promise<IQueryResult[]>}
	     */
	    showMoreResults(): Promise<IQueryResult[]>;
	    /**
	     * Show less results for a given conversation. This is the equivalent of clicking "Show less"
	     */
	    showLessResults(): Promise<void>;
	}

}
declare module Coveo {
	function registerFields(): void;

}
declare module Coveo {
	enum RatingValues {
	    Undefined = 0,
	    Lowest = 1,
	    Low = 2,
	    Average = 3,
	    Good = 4,
	    Best = 5,
	}
	interface IResultRatingOptions {
	}
	/**
	 * **Note:**
	 *
	 * > The Coveo Cloud V2 platform does not support collaborative rating. Therefore, this component is obsolete in Coveo Cloud V2.
	 *
	 * The `ResultRating` component renders a 5-star rating widget. Interactive rating is possible if
	 * the [`enableCollaborativeRating`]{@link SearchInterface.options.enableCollaborativeRating} option of your
	 * search interface is `true`, and if collaborative rating is enabled on your Coveo index.
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 *
	 * @notSupportedIn salesforcefree
	 */
	class ResultRating extends Component {
	    element: HTMLElement;
	    options: IResultRatingOptions;
	    bindings: IComponentBindings;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * Creates a new `ResultRating` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `ResultRating` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     */
	    constructor(element: HTMLElement, options?: IResultRatingOptions, bindings?: IComponentBindings, result?: IQueryResult);
	    /**
	     * Rates an item using the the specified `rating` value.
	     * @param rating The rating to assign to the item.
	     *
	     * The possible values are:
	     *
	     * - `0`: renders no star.
	     * - `1`: renders 1 star.
	     * - `2`: renders 2 stars.
	     * - `3`: renders 3 stars.
	     * - `4`: renders 4 stars.
	     * - `5`: renders 5 stars.
	     */
	    rateDocument(rating: RatingValues): void;
	}

}
declare module Coveo {
	/**
	 * A simple `fieldset` HTMLElement containing multiple form widgets.
	 */
	class FormGroup {
	    labelElement: Dom;
	    static doExport(): void;
	    /**
	     * Creates a new `FormGroup`.
	     * @param contents The form widgets to include in the form group.
	     * @param label The label to display for the form group.
	     */
	    constructor(contents: IFormWidget[], label: string);
	    /**
	     * Gets the element on which the form group is bound.
	     * @returns {HTMLElement} The form group element.
	     */
	    build(): HTMLElement;
	}

}
declare module Coveo {
	/**
	 * A multi select widget with standard styling.
	 */
	class MultiSelect implements IFormWidget, IFormWidgetSettable {
	    onChange: (multiSelect: MultiSelect) => void;
	    options: string[];
	    label: string;
	    static doExport(): void;
	    /**
	     * Creates a new `MultiSelect`.
	     * @param onChange The function to call when the widget selected values change. This function takes the current
	     * `MultiSelect` instance as an argument.
	     * @param options The values which can be selected with the multi select.
	     * @param label The label to display for the multi select.
	     */
	    constructor(onChange: (multiSelect: MultiSelect) => void, options: string[], label: string);
	    /**
	     * Gets the element on which the multi select is bound.
	     * @returns {HTMLSelectElement} The multi select element.
	     */
	    build(): HTMLElement;
	    /**
	     * Gets the element on which the multi select is bound.
	     * @returns {HTMLSelectElement} The multi select element.
	     */
	    getElement(): HTMLElement;
	    /**
	     * Gets the currently selected values.
	     * @returns {string[]} The array of selected multi select values.
	     */
	    getValue(): string[];
	    /**
	     * Gets the currently un-selected values.
	     * @returns {string[]} The array of un-selected multi select values.
	     */
	    getUnselectedValues(): string[];
	    /**
	     * Sets the currently selected values.
	     * @param values The values to select.
	     */
	    setValue(values: string[]): void;
	    /**
	     * Resets the multi select.
	     */
	    reset(): void;
	}

}
declare module Coveo {
	class ResponsiveTabs implements IResponsiveComponent {
	    ID: string;
	    constructor(coveoRoot: Dom, ID: string);
	    static init(root: HTMLElement, component: Component, options: IResponsiveComponentOptions): void;
	    handleResizeEvent(): void;
	}

}
declare module Coveo {
	interface ITabOptions {
	    expression?: IQueryExpression;
	    constant?: boolean;
	    id?: string;
	    icon?: string;
	    caption?: string;
	    sort?: string;
	    layout?: string;
	    endpoint?: SearchEndpoint;
	    enableDuplicateFiltering?: boolean;
	    pipeline?: string;
	    maximumAge?: number;
	    enableResponsiveMode?: boolean;
	    dropdownHeaderLabel?: string;
	}
	/**
	 * The Tab component renders a widget that allows the end user to select a specific search interface.
	 *
	 * This component attaches itself to a `div` element. It is in charge of adding an advanced expression to the outgoing
	 * query in order to refine the results.
	 *
	 * The Tab component can also hide and show different parts of the UI. For each individual component in the UI, you can
	 * specify whether you wish to include or exclude that component when the user selects a certain Tab (see [Using Components
	 * Only on Specific Tabs](https://docs.coveo.com/en/508/javascript-search-framework/using-components-only-on-specific-tabs)).
	 *
	 * **Setting a New Endpoint for a Tab:**
	 *
	 * A Tab can use a custom endpoint when performing a query. Of course, you need to make sure that the endpoint exists in
	 * the array of Coveo.SearchEndpoint.endpoints (see {@link SearchEndpoint.endpoints}).
	 *
	 * ```
	 * Coveo.SearchEndpoint.endpoints["specialEndpoint"] = new Coveo.SearchEndpoint({
	 *     restUri : 'https://somewhere.com/rest/search'
	 * })
	 *
	 * [ ... ]
	 *
	 * <div class='CoveoTab' data-endpoint='specialEndpoint'></div>
	 *
	 * ```
	 */
	class Tab extends Component {
	    element: HTMLElement;
	    options: ITabOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for a Tab
	     * @componentOptions
	     */
	    static options: ITabOptions;
	    /**
	     * Creates a new Tab. Binds on buildingQuery event as well as an event on click of the element.
	     * @param element The HTMLElement on which to instantiate the component. Normally a `div`.
	     * @param options The options for the Tab component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: ITabOptions, bindings?: IComponentBindings);
	    /**
	     * Selects the current Tab.
	     *
	     * Also logs the `interfaceChange` event in the usage analytics with the new current {@link Tab.options.id} as metada
	     * and triggers a new query.
	     */
	    select(): void;
	    /**
	     * Indicates whether the HTMLElement argument is included in the Tab. *Included* elements are shown when the Tab is
	     * selected, whereas *excluded* elements are not.
	     * @param element The HTMLElement to verify.
	     * @returns {boolean} `true` if the HTMLElement is included in the Tab; `false` if it is excluded.
	     */
	    isElementIncludedInTab(element: HTMLElement): boolean;
	    protected handleBuildingQuery(data: IBuildingQueryEventArgs): void;
	    protected isSelected(): boolean;
	    enable(): void;
	    disable(): void;
	}

}
declare module Coveo {
	interface IResultFilterPreference {
	    selected?: boolean;
	    custom?: boolean;
	    tab?: string[];
	    caption: string;
	    expression: string;
	}
	interface IResultsFiltersPreferencesOptions {
	    filters?: {
	        [caption: string]: {
	            expression: string;
	            tab?: string[];
	        };
	    };
	    includeInBreadcrumb?: boolean;
	    showAdvancedFilters?: boolean;
	}
	/**
	 * The `ResultFiltersPreferences` component allows end users to create custom filters to apply to queries. These filters
	 * are saved to local storage.
	 *
	 * Only advanced end users who understand the Coveo query syntax should use this feature (see
	 * [Coveo Query Syntax Reference](https://docs.coveo.com/en/1552/searching-with-coveo/coveo-cloud-query-syntax)).
	 *
	 * This component is normally accessible through the [`Settings`]{@link Settings} menu. Its usual location in the DOM is
	 * inside the [`PreferencesPanel`]{@link PreferencesPanel} element.
	 *
	 * See also the {@link ResultsPreferences} component.
	 */
	class ResultsFiltersPreferences extends Component {
	    element: HTMLElement;
	    options: IResultsFiltersPreferencesOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IResultsFiltersPreferencesOptions;
	    preferences: {
	        [caption: string]: IResultFilterPreference;
	    };
	    container: HTMLFieldSetElement;
	    /**
	     * Creates a new `ResultsFiltersPreferences` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `ResultsFiltersPreferences` component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options: IResultsFiltersPreferencesOptions, bindings: IComponentBindings);
	    createDom(): void;
	    save(): void;
	    exitWithoutSave(): void;
	}

}
declare module Coveo {
	interface IResultsPerPageOptions {
	    choicesDisplayed?: number[];
	    initialChoice?: number;
	}
	/**
	 * The ResultsPerPage component attaches itself to a `div` and allows the end user to choose how many results to
	 * display per page.
	 *
	 * **Note:** Adding a ResultPerPage component to your page overrides the value of
	 * {@link SearchInterface.options.resultsPerPage}.
	 */
	class ResultsPerPage extends Component {
	    element: HTMLElement;
	    options: IResultsPerPageOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the ResultsPerPage
	     * @componentOptions
	     */
	    static options: IResultsPerPageOptions;
	    /**
	     * Creates a new ResultsPerPage. The component renders itself on every query success.
	     * @param element The HTMLElement on which to instantiate the component (normally a `div`).
	     * @param options The options for the ResultsPerPage component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IResultsPerPageOptions, bindings?: IComponentBindings);
	    /**
	     * Sets the current number of results per page, then executes a query.
	     *
	     * Also logs an event in the usage analytics (`pagerResize` by default) with the new current number of results per
	     * page as meta data.
	     * @param resultsPerPage The new number of results per page to select.
	     * @param analyticCause The event to log in the usage analytics.
	     */
	    setResultsPerPage(resultsPerPage: number, analyticCause?: IAnalyticsActionCause): void;
	    /**
	     * Returns the current number of results per page.
	     */
	     resultsPerPage: number;
	}

}
declare module Coveo {
	interface IResultsPreferencesOptions {
	    enableOpenInOutlook?: boolean;
	    enableOpenInNewWindow?: boolean;
	    enableQuerySyntax?: boolean;
	}
	interface IPossiblePreferences {
	    openInOutlook?: boolean;
	    alwaysOpenInNewWindow?: boolean;
	    enableQuerySyntax?: boolean;
	}
	/**
	 * The ResultsPreferences component allows the end user to select preferences related to the search results. These
	 * preferences are then saved in the local storage of the end user.
	 *
	 * This component is normally accessible through the {@link Settings} menu. Its usual location in the DOM is inside the
	 * {@link PreferencesPanel} component.
	 *
	 * See also the {@link ResultsFiltersPreferences} component.
	 */
	class ResultsPreferences extends Component {
	    element: HTMLElement;
	    options: IResultsPreferencesOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IResultsPreferencesOptions;
	    preferences: IPossiblePreferences;
	    /**
	     * Creates a new ResultsPreference component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the ResultsPreferences component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options: IResultsPreferencesOptions, bindings: IComponentBindings);
	    /**
	     * Saves the current state of the ResultsPreferences component in the local storage.
	     */
	    save(): void;
	    exitWithoutSave(): void;
	}

}
declare module Coveo {
	interface IResultTaggingOptions {
	    field: IFieldOption;
	    suggestBoxSize?: number;
	    autoCompleteTimer?: number;
	}
	interface IAnalyticsResultTaggingMeta {
	    facetId: string;
	    facetField: string;
	    facetValue?: string;
	    facetTitle?: string;
	}
	/**
	 * The ResultTagging component lists the current tag field values of its associated result and renders a control that
	 * allows the end user to add values to a tag field.
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 *
	 * **Note:**
	 * > The ResultTagging component is not supported with Coveo Cloud V2. To implement the ResultTagging component in Coveo Cloud V1, contact [Coveo Support](https://support.coveo.com/s/).
	 *
	 * @notSupportedIn salesforcefree
	 */
	class ResultTagging extends Component {
	    element: HTMLElement;
	    options: IResultTaggingOptions;
	    result: IQueryResult;
	    static ID: string;
	    static autoCompleteClass: string;
	    static doExport: () => void;
	    /**
	     * @componentOptions
	     */
	    static options: IResultTaggingOptions;
	    static AUTO_COMPLETE_CLASS: string;
	    /**
	     * Creates a new ResultTagging component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the ResultTagging component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     */
	    constructor(element: HTMLElement, options?: IResultTaggingOptions, bindings?: IComponentBindings, result?: IQueryResult);
	}

}
declare module Coveo {
	interface ISearchAlertMessageOptions {
	    closeDelay: number;
	}
	/**
	 * The SearchAlertsMessage component allows the {@link SearchAlerts} component to display messages.
	 *
	 * You should not include this component in your page. Instead, use a {@link SearchAlerts} component, and access the
	 * {@link SearchAlerts.message} attribute.
	 */
	class SearchAlertsMessage extends Component {
	    element: HTMLElement;
	    options: ISearchAlertMessageOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    /**
	     * The options for the SearchAlertsMessage component
	     * @componentOptions
	     */
	    static options: ISearchAlertMessageOptions;
	    /**
	     * Creates a new SearchAlertsMessage component
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the SearchAlertsMessage component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options: ISearchAlertMessageOptions, bindings?: IComponentBindings);
	    getCssClass(): string;
	    getFollowQueryMessage(query?: string, htmlFormatted?: boolean): string;
	    /**
	     * Displays a message near the passed dom attribute.
	     * @param dom Specifies where to display the message.
	     * @param message The message.
	     * @param error Specifies whether the message is an error message.
	     */
	    showMessage(dom: Dom, message: string, error: boolean): void;
	}

}
declare module Coveo {
	interface ISearchAlertsOptions {
	    enableManagePanel?: boolean;
	    enableFollowQuery?: boolean;
	    modifiedDateField?: IFieldOption;
	    enableMessage?: boolean;
	    messageCloseDelay?: number;
	}
	/**
	 * The Search Alerts component renders items in the {@link Settings} menu that allow the end user to follow queries
	 * and to manage search alerts. A user following a query receives email notifications when the query results change.
	 *
	 * **Note:**
	 * > It is necessary to meet certain requirements to be able to use this component (see
	 * > [Deploying Search Alerts on a Coveo JS Search Page](https://docs.coveo.com/en/1932/)).
	 *
	 * See also the {@link FollowItem} component.
	 */
	class SearchAlerts extends Component {
	    element: HTMLElement;
	    options: ISearchAlertsOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the search alerts
	     * @componentOptions
	     */
	    static options: ISearchAlertsOptions;
	    /**
	     * A reference to a {@link SearchAlertsMessage} component that the SearchAlerts component uses to display messages.
	     */
	    message: SearchAlertsMessage;
	    /**
	     * Creates a new SearchAlerts component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the SearchAlerts component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options: ISearchAlertsOptions, bindings?: IComponentBindings, ModalBox?: any);
	    /**
	     * Follows the last query. The user will start receiving email notifications when the query results change.
	     *
	     * Also logs the `searchAlertsFollowQuery` event in the usage analytics with the name of the request as meta data.
	     */
	    followQuery(): void;
	    /**
	     * Opens the **Manage Alerts** panel. This panel allows the end user to stop following queries or items. It also
	     * allows the end user to specify email notification frequency for each followed query or item.
	     */
	    openPanel(): Promise<void>;
	    protected findQueryBoxDom(): HTMLElement;
	    static create(element: HTMLElement, options?: ISearchAlertsOptions, root?: HTMLElement): SearchAlerts;
	}

}
declare module Coveo {
	class SearchBoxResize {
	    static resize(element: HTMLElement, size: number): void;
	}

}
declare module Coveo {
	interface ISearchButtonOptions {
	    searchbox?: ISearchButtonSearchbox;
	}
	interface ISearchButtonSearchbox {
	    getText: () => string;
	}
	/**
	 * The SearchButton component renders a search icon that the end user can click to trigger a new query.
	 *
	 * See also the {@link Searchbox} component, which can automatically instantiate a SearchButton component along with a
	 * {@link Querybox} component or an {@link Omnibox} component.
	 */
	class SearchButton extends Component {
	    element: HTMLElement;
	    options: ISearchButtonOptions;
	    static ID: string;
	    static doExport: () => void;
	    static options: ISearchButtonOptions;
	    /**
	     * Creates a new SearchButton. Binds a `click` event on the element. Adds a search icon on the element.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the SearchButton component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: ISearchButtonOptions, bindings?: IComponentBindings);
	    /**
	     * Triggers the `click` event handler, which logs a `searchboxSubmit` event in the usage analytics and executes a
	     * query.
	     */
	    click(): void;
	}

}
declare module Coveo {
	interface ISearchboxOptions extends IOmniboxOptions {
	    addSearchButton?: boolean;
	    enableOmnibox?: boolean;
	    height?: number;
	}
	/**
	 * The `Searchbox` component allows you to conveniently instantiate two components which end users frequently use to
	 * enter and submit queries.
	 *
	 * This component attaches itself to a `div` element and takes care of instantiating either a
	 * [`Querybox`]{@link Querybox} or an [`Omnibox`]{@link Omnibox} component (see the
	 * [`enableOmnibox`]{@link Searchbox.options.enableOmnibox} option). Optionally, the `Searchbox` can also instantiate a
	 * [`SearchButton`]{@link SearchButton} component, and append it inside the same `div` (see the
	 * [`addSearchButton`]{@link Searchbox.options.addSearchButton} option).
	 */
	class Searchbox extends Component {
	    element: HTMLElement;
	    options: ISearchboxOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    static parent: typeof Omnibox;
	    static doExport: () => void;
	    /**
	     * Possible options for the {@link Searchbox}
	     * @componentOptions
	     */
	    static options: ISearchboxOptions;
	    /**
	     * The [`SearchButton`]{@link SearchButton} component instance.
	     */
	    searchButton: SearchButton;
	    /**
	     * The component instance which allows end users to input queries.
	     *
	     * Can be either a [`Querybox`]{@link Querybox} or an [`Omnibox`]{@link Omnibox} component, depending on the value of
	     * [`enableOmnibox`]{@link Searchbox.options.enableOmnibox}.
	     */
	    searchbox: Querybox | Omnibox;
	    /**
	     * Creates a new `Searchbox` component. Creates a new `Coveo.Magicbox` instance and wraps magic box methods (`onblur`,
	     * `onsubmit`, etc.). Binds event on `buildingQuery` and on redirection (for standalone box).
	     * @param element The HTMLElement on which to instantiate the component. This cannot be an HTMLInputElement for
	     * technical reasons.
	     * @param options The options for the `Searchbox component`. These will merge with the options from the component set
	     * directly on the `HTMLElement`.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: ISearchboxOptions, bindings?: IComponentBindings);
	}

}
declare module Coveo {
	interface IShareQueryOptions {
	}
	/**
	 * The ShareQuery component populates the {@link Settings} popup menu with the **Share Query** menu item. When the end
	 * user clicks this item, it displays a panel containing two input boxes: one containing a shareable link and the other
	 * containing the complete current query expression.
	 */
	class ShareQuery extends Component {
	    element: HTMLElement;
	    options: IShareQueryOptions;
	    static ID: string;
	    static options: IShareQueryOptions;
	    static doExport: () => void;
	    dialogBoxContent: HTMLElement;
	    /**
	     * Creates a new ShareQuery component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the ShareQuery component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options: IShareQueryOptions, bindings?: IComponentBindings, ModalBox?: any);
	    /**
	     * Open the **Share Query** modal box.
	     */
	    open(): void;
	    /**
	     * Close the **Share Query** modal box.
	     */
	    close(): void;
	    /**
	     * Gets the link to the current query.
	     */
	    getLinkToThisQuery(): string;
	    /**
	     * Sets the link to the current query.
	     */
	    setLinkToThisQuery(link: string): void;
	    /**
	     * Gets the complete query expression string
	     */
	    getCompleteQuery(): string;
	    /**
	     * Set the complete query expression string.
	     */
	    setCompleteQuery(completeQuery: string): void;
	}

}
declare module Coveo {
	interface ISortOptions {
	    sortCriteria?: SortCriteria[];
	    caption?: string;
	}
	/**
	 * The `Sort` component renders a widget that the end user can interact with to select the criterion to use when sorting query results.
	 *
	 * To improve accessibility, it's recommended to group `Sort` components in a container with `role="radiogroup"`.
	 */
	class Sort extends Component {
	    element: HTMLElement;
	    options: ISortOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * Options for the component
	     * @componentOptions
	     */
	    static options: ISortOptions;
	    /**
	     * Creates a new `Sort` component instance.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for this component instance.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: ISortOptions, bindings?: IComponentBindings);
	    createDom(): void;
	    /**
	     * Selects this `Sort` component.
	     *
	     * Updates the state model if selecting this component toggles its current [`sortCriteria`]{@link Sort.options.sortCriteria}.
	     *
	     * @param direction The sort direction. Can be one of: `ascending`, `descending`.
	     */
	    select(direction?: string): void;
	    /**
	     * Selects this `Sort` component, then triggers a query if selecting this component toggles its current [`sortCriteria`]{@link Sort.options.sortCriteria}.
	     *
	     * Also logs an event in the usage analytics with the new current sort criteria.
	     */
	    selectAndExecuteQuery(): void;
	    enable(): void;
	    disable(): void;
	    /**
	     * Gets the current [`sortCriteria`]{@link Sort.options.sortCriteria} of this `Sort` component.
	     * @returns {SortCriteria}
	     */
	    getCurrentCriteria(): SortCriteria;
	    /**
	     * Indicates whether the name of any of the available [`sortCriteria`]{@link Sort.options.sortCriteria} of this `Sort` component matches the argument.
	     * @param sortId The sort criteria name to look for (e.g., `date descending`).
	     */
	    match(sortId: string): boolean;
	}

}
declare module Coveo {
	interface IStarRatingOptions {
	    ratingField?: IFieldOption;
	    numberOfRatingsField?: IFieldOption;
	    ratingScale?: number;
	}
	/**
	 * The `StarRating` component renders a five-star rating widget for use in commerce result templates.
	 *
	 * @isresulttemplatecomponent
	 *
	 * @availablesince [January 2020 Release (v2.7968)](https://docs.coveo.com/en/3163/)
	 */
	class StarRating extends Component {
	    element: HTMLElement;
	    options: IStarRatingOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * @componentOptions
	     */
	    static options: IStarRatingOptions;
	    /**
	     * Creates a new `StarRating` component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the `StarRating` component.
	     * @param bindings The bindings that the component requires to function normally.
	     */
	    constructor(element: HTMLElement, options: IStarRatingOptions, bindings?: IComponentBindings, result?: IQueryResult);
	}

}
declare module Coveo {
	interface ITemplateLoaderOptions {
	    template: Template;
	    condition?: String;
	}
	/**
	 * The TemplateLoader component can load one result template into another. You should normally declare any reusable
	 * result template outside of the {@link ResultList} component. Otherwise, the framework will evaluate the
	 * `data-condition` of the reusable result template and possibly render it.
	 *
	 * **Example:**
	 *
	 * ```html
	 * [ ... ]
	 *
	 * <!-- A reusable result template. Note that it is 
	 * <script type='text/underscore' class='result-template' id='ReusableTemplate'>
	 *   <table class='CoveoFieldTable'>
	 *     <tr data-field='@source' data-caption='Source'></tr>
	 *     <tr data-field='@percentScore' data-caption='Score'></tr>
	 *   </table>
	 * </script>
	 *
	 * [ ... ]
	 *
	 * <div class="CoveoResultList" data-wait-animation="fade" data-auto-select-fields-to-include="true">
	 *
	 *   <!-- A custom result template for Lithium messages. -->
	 *   <script type='text/underscore' class='result-template' data-condition='raw.filetype == "lithiummessage"'>
	 *     <div>
	 *       <img class='CoveoIcon' data-small='true'>
	 *       <a class='CoveoResultLink'></a>
	 *       <div class='CoveoTemplateLoader' data-template-id='ReusableTemplate'></div>
	 *     </div>
	 *   </script>
	 *
	 *   <!-- A custom result template for images. -->
	 *   <script type='text/underscore' class='result-template' data-condition='raw.filetype == "Image"'>
	 *     <div>
	 *       <img class='CoveoIcon' data-small='true'></img>
	 *         <a class='CoveoResultLink'>
	 *           <img class='CoveoThumbnail'>
	 *         </a>
	 *       <div class='CoveoTemplateLoader' data-template-id='ReusableTemplate'></div>
	 *     </div>
	 *   </script>
	 * </div>
	 *
	 * [ ... ]
	 * ```
	 *
	 * See [Result Templates](https://docs.coveo.com/en/413/).
	 */
	class TemplateLoader extends Component {
	    element: HTMLElement;
	    options: ITemplateLoaderOptions;
	    bindings: IComponentBindings;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The possible options for a TemplateLoader.
	     * @componentOptions
	     */
	    static options: ITemplateLoaderOptions;
	    /**
	     * Creates a new TemplateLoader.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the TemplateLoader component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     */
	    constructor(element: HTMLElement, options?: ITemplateLoaderOptions, bindings?: IComponentBindings, result?: IQueryResult);
	}

}
declare module Coveo {
	interface ITextOptions {
	    value?: string;
	    size?: string;
	    style?: string;
	    color?: string;
	    weight?: string;
	    textAlign?: string;
	    marginTop?: string;
	    marginBottom?: string;
	    marginLeft?: string;
	    marginRight?: string;
	    paddingTop?: string;
	    paddingBottom?: string;
	    paddingLeft?: string;
	    paddingRight?: string;
	}
	/**
	 * The Text component embeds itself in a result template to output a simple text value.
	 *
	 * The only purpose of this component is to make it possible to easily add different text values to result templates
	 * when using the Coveo JavaScript Search Interface Editor (see
	 * [Interface Editor](https://docs.coveo.com/en/1852/)).
	 *
	 * If you are not designing a search interface using the Coveo JavaScript Search Interface Editor, using this component
	 * is unnecessary.
	 *
	 * This component is a result template component (see [Result Templates](https://docs.coveo.com/en/413/)).
	 */
	class Text extends Component {
	    element: HTMLElement;
	    options: ITextOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * @componentOptions
	     */
	    static options: ITextOptions;
	    /**
	     * Creates a new Text component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the Text component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: ITextOptions, bindings?: IComponentBindings);
	}

}
declare module Coveo {
	interface IThumbnailOptions extends IResultLinkOptions {
	    noThumbnailClass?: string;
	    clickable?: boolean;
	}
	/**
	 * The Thumbnail component automatically fetches the thumbnail of the result object and outputs an HTML `img` tag with
	 * it.
	 * @notSupportedIn salesforcefree
	 */
	class Thumbnail extends Component {
	    element: HTMLElement;
	    options: IThumbnailOptions;
	    bindings: IResultsComponentBindings;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * Options for the Thumbnail
	     * @componentOptions
	     */
	    static options: IThumbnailOptions;
	    static parent: typeof ResultLink;
	    img: HTMLImageElement;
	    /**
	     * Creates a new Thumbnail component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the Thumbnail component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     */
	    constructor(element: HTMLElement, options?: IThumbnailOptions, bindings?: IResultsComponentBindings, result?: IQueryResult);
	}

}
declare module Coveo {
	function registerFields(): void;

}
declare module Coveo {
	interface ITriggersOptions {
	}
	/**
	 * The Triggers component enables the use of triggers (`notify`, `execute`, `query`, `redirect`) generated by the Coveo
	 * Search API (see [Trigger](https://docs.coveo.com/en/1458/)) in the query pipeline (see
	 * [Managing the Query Pipeline](https://docs.coveo.com/en/1450/)).
	 *
	 * Note: adding the Triggers component gives query pipeline administrators the power to influence users' search experience.
	 * Bad actors will be able to perform XSS attacks, or redirect users to dangerous sites. Make sure only individuals you trust
	 * have query pipeline edit privileges.
	 */
	class Triggers extends Component {
	    element: HTMLElement;
	    options: ITriggersOptions;
	    bindings: IComponentBindings;
	    _window: Window;
	    static ID: string;
	    static options: ITriggersOptions;
	    static doExport: () => void;
	    /**
	     * The list of notifications returned by the Search API for the current query (via `notify` triggers).
	     *
	     * The Triggers component automatically renders this list visually.
	     */
	    notifications: string[];
	    /**
	     * Creates a new Triggers component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the Triggers component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param _window The window on which to execute the triggers.
	     */
	    constructor(element: HTMLElement, options?: ITriggersOptions, bindings?: IComponentBindings, _window?: Window);
	}

}
declare module Coveo {
	function registerFields(): void;

}
declare module Coveo {
	class SimpleFilterValues {
	    simpleFilter: SimpleFilter;
	    options: ISimpleFilterOptions;
	    constructor(simpleFilter: SimpleFilter, options: ISimpleFilterOptions);
	    getValuesFromGroupBy(): string[];
	    groupBy(data: IQuerySuccessEventArgs): void;
	    handleDoneBuildingQuery(data: IDoneBuildingQueryEventArgs): void;
	}

}
declare module Coveo {
	interface ISimpleFilterOptions {
	    title: string;
	    values: string[];
	    field: IFieldOption;
	    valueCaption: any;
	    maximumNumberOfValues: number;
	    sortCriteria: string;
	    enableClearButton?: boolean;
	}
	/**
	 * The `SimpleFilter` component displays a dropdown menu containing field values which the end user can select to filter
	 * the query results.
	 *
	 * The list of available field values in the dropdown menu can either be static (defined through the
	 * [`values`]{@link SimpleFilter.options.values} option), or dynamic (automatically obtained through a
	 * [`GroupByRequest`]{@link IGroupByRequest} operation performed at the same time as the main query).
	 *
	 * @availablesince [November 2017 Release (v2.3477.9)](https://docs.coveo.com/en/373/#november-2017-release-v234779)
	 */
	class SimpleFilter extends Component {
	    element: HTMLElement;
	    options: ISimpleFilterOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    static doExport: () => void;
	    static simpleFilterSortCritera(): string[];
	    /**
	     * The possible options for the SimpleFilter.
	     * @componentOptions
	     */
	    static options: ISimpleFilterOptions;
	    /**
	     * Creates a new `SimpleFilter` component. Binds multiple query events as well.
	     * @param element the HTMLElement on which to instantiate the component.
	     * @param options The options for the `SimpleFilter` component.
	     * @param bindings The bindings that the component requires to function normally.
	     */
	    constructor(element: HTMLElement, options: ISimpleFilterOptions, bindings?: IComponentBindings);
	    /**
	     * Gets the `SimpleFilter` `valueContainer`.
	     * @returns {Dom} The `SimpleFilter` valueContainer.
	     */
	    getValueContainer(): Dom;
	    /**
	     * Gets the caption of a specific field value.
	     * @param value The field value whose caption the method should attempt to get.
	     * @returns {any} The value caption, if available; the original value otherwise.
	     */
	    getValueCaption(value: string): string;
	    /**
	     * Gets the captions of the currently selected field values in the `SimpleFilter`.
	     * @returns {string[]} An array containing the selected captions.
	     */
	    getSelectedCaptions(): string[];
	    /**
	     * Opens or closes the `SimpleFilter` `valueContainer`, depending on its current state.
	     */
	    toggleContainer(): void;
	    /**
	     * Selects the specified value. Also triggers a query, by default.
	     * @param value The value to select.
	     * @param triggerQuery `true` by default. If set to `false`, the method triggers no query.
	     */
	    selectValue(value: string, triggerQuery?: boolean): void;
	    /**
	     * Un-selects the specified value.
	     * @param value The value whose state the method should reset.
	     */
	    deselectValue(value: string): void;
	    /**
	     * Selects or un-selects the specified value, depending on its current state.
	     * @param value The value whose state the method should toggle.
	     */
	    toggleValue(value: string): void;
	    /**
	     * Resets the component to its original state.
	     */
	    resetSimpleFilter(): void;
	    /**
	     * Opens the `SimpleFilter` `valueContainer`.
	     */
	    openContainer(): void;
	    /**
	     * Closes the `SimpleFilter` `valueContainer`.
	     */
	    closeContainer(): void;
	    getSelectedValues(): string[];
	    buildClearElement(): HTMLElement;
	}

}
declare module Coveo {
	interface ITimespanFacetOptions extends IResponsiveComponentOptions {
	    title?: string;
	    field?: IFieldOption;
	    id?: string;
	}
	/**
	 * The TimespanFacet component displays a {@link FacetRange} with prebuilt ranges.
	 *
	 * The prebuilt ranges allow you to see the items last updated in the last day, week, month, or year.
	 *
	 * This component in a thin wrapper around the standard {@link FacetRange} component.
	 *
	 * This component is meant to offer out of the box default ranges, so it can easily be inserted in a standard search page.
	 *
	 * To configure different ranges than those offered by this component, use the standard {@link FacetRange} component instead.
	 *
	 * @notSupportedIn salesforcefree
	 */
	class TimespanFacet extends Component {
	    element: HTMLElement;
	    options: ITimespanFacetOptions;
	    static ID: string;
	    /**
	     * @componentOptions
	     */
	    static options: ITimespanFacetOptions;
	    static doExport: () => void;
	    isFieldValueCompatible: boolean;
	    constructor(element: HTMLElement, options?: ITimespanFacetOptions, bindings?: IComponentBindings);
	    isCurrentlyDisplayed(): boolean;
	    /**
	     * Returns the current range the facet uses to query the index
	     */
	    /**
	     * Sets a new range for the component.
	     */
	    ranges: IRangeValue[];
	    /**
	     * Returns the underlying {@link FacetRange} component associated to the Timespan Facet.
	     */
	     facet: FacetRange;
	}

}
declare module Coveo {
	interface IDynamicFacetManagerOptions {
	    enableReorder?: boolean;
	    onUpdate?: IDynamicFacetManagerOnUpdate;
	    compareFacets?: IDynamicFacetManagerCompareFacet;
	    maximumNumberOfExpandedFacets?: number;
	}
	interface IDynamicFacetManagerOnUpdate {
	    (facet: IDynamicManagerCompatibleFacet, index: number): void;
	}
	interface IDynamicFacetManagerCompareFacet {
	    (facetA: IDynamicManagerCompatibleFacet, facetB: IDynamicManagerCompatibleFacet): number;
	}
	interface IDynamicManagerCompatibleFacet extends Component, IAutoLayoutAdjustableInsideFacetColumn {
	    dynamicFacetManager: DynamicFacetManager;
	    hasActiveValues: boolean;
	    isDynamicFacet: boolean;
	    handleQueryResults(results: IQueryResults): void;
	    putStateIntoQueryBuilder(queryBuilder: QueryBuilder): void;
	    putStateIntoAnalytics(): void;
	    expand(): void;
	    collapse(): void;
	}
	/**
	 * The `DynamicFacetManager` component is meant to be a parent for multiple [DynamicFacet]{@link DynamicFacet} & [DynamicFacetRange]{@link DynamicFacetRange} components.
	 * This component allows controlling a set of [`DynamicFacet`]{@link DynamicFacet} and [`DynamicFacetRange`]{@link DynamicFacetRange} as a group.
	 *
	 * @externaldocs [Using Dynamic Facets](https://docs.coveo.com/en/2917/).
	 * @availablesince [May 2019 Release (v2.6063)](https://docs.coveo.com/en/2909/)
	 */
	class DynamicFacetManager extends Component {
	    options: IDynamicFacetManagerOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the DynamicFacetManager
	     * @componentOptions
	     */
	    static options: IDynamicFacetManagerOptions;
	    /**
	     * Creates a new `DynamicFacetManager` instance.
	     *
	     * @param element The element from which to instantiate the component.
	     * @param options The component options.
	     * @param bindings The component bindings. Automatically resolved by default.
	     */
	    constructor(element: HTMLElement, options?: IDynamicFacetManagerOptions);
	    isCurrentlyDisplayed(): boolean;
	}

}
declare module Coveo {
	interface IBasicFacetRequestParameters {
	    facetId: string;
	    field: string;
	    type: FacetType;
	    injectionDepth: number;
	    sortCriteria?: FacetSortCriteria;
	    delimitingCharacter?: string;
	    filterFacetCount?: boolean;
	}
	class DynamicFacetRequestBuilder {
	    constructor(request: IFacetRequest);
	    buildBaseRequestForQuery(): IFacetRequest;
	}
	function determineFilterFacetCount(options: {
	    filterFacetCount?: boolean;
	}): boolean;

}
declare module Coveo {
	class DynamicFacetQueryController {
	    protected facet: IDynamicFacet;
	    protected requestBuilder: DynamicFacetRequestBuilder;
	    constructor(facet: IDynamicFacet);
	    increaseNumberOfValuesToRequest(additionalNumberOfValues: number): void;
	    resetNumberOfValuesToRequest(): void;
	    enablePreventAutoSelectionFlag(): void;
	    enableFreezeCurrentValuesFlag(): void;
	    enableFreezeFacetOrderFlag(): void;
	    /**
	     * Build the facets request for the DynamicFacet, and insert it in the query builder
	     * @param queryBuilder
	     */
	    putFacetIntoQueryBuilder(queryBuilder: QueryBuilder): void;
	    buildFacetRequest(): IFacetRequest;
	    getQueryResults(): Promise<IQueryResults>;
	    protected  currentValues: IFacetRequestValue[];
	    protected  numberOfValues: number;
	}

}
declare module Coveo {
	interface IDynamicFacetHeaderButtonOptions {
	    label: string;
	    ariaLabel?: string;
	    shouldDisplay?: boolean;
	    className?: string;
	    iconSVG?: string;
	    iconClassName?: string;
	    action?: () => void;
	}
	class DynamicFacetHeaderButton {
	    element: HTMLElement;
	    constructor(rootOptions: IDynamicFacetHeaderButtonOptions);
	    toggle(shouldDisplay: boolean): void;
	}

}
declare module Coveo {
	interface IDynamicFacetCollapseToggleOptions {
	    collapsed: boolean;
	}
	class DynamicFacetHeaderCollapseToggle {
	    element: HTMLElement;
	    constructor(options: IDynamicFacetHeaderOptions);
	    toggleButton(isCollapsed: boolean): void;
	}

}
declare module Coveo {
	interface IDynamicFacetHeaderOptions {
	    id: string;
	    title: string;
	    enableCollapse: boolean;
	    headingLevel: number;
	    toggleCollapse: () => void;
	    collapse: () => void;
	    expand: () => void;
	    clear: () => void;
	}
	function getDynamicFacetHeaderId(facetId: string): string;
	class DynamicFacetHeader {
	    options: IDynamicFacetHeaderOptions;
	    static showLoadingDelay: number;
	    element: HTMLElement;
	    constructor(options: IDynamicFacetHeaderOptions);
	    toggleCollapse(isCollapsed: boolean): void;
	    toggleClear(visible: boolean): void;
	    showLoading(): void;
	    hideLoading(): void;
	}

}
declare module Coveo {
	interface IDynamicFacetOptions extends IResponsiveComponentOptions, IDependsOnCompatibleFacetOptions {
	    title?: string;
	    field?: IFieldOption;
	    sortCriteria?: FacetSortCriteria;
	    customSort?: string[];
	    numberOfValues?: number;
	    enableCollapse?: boolean;
	    enableScrollToTop?: boolean;
	    enableMoreLess?: boolean;
	    enableFacetSearch?: boolean;
	    useLeadingWildcardInFacetSearch?: boolean;
	    collapsedByDefault?: boolean;
	    includeInBreadcrumb?: boolean;
	    numberOfValuesInBreadcrumb?: number;
	    valueCaption?: any;
	    injectionDepth?: number;
	    filterFacetCount?: boolean;
	    headingLevel?: number;
	}
	interface IDynamicFacet extends Component, IDynamicManagerCompatibleFacet, IAutoLayoutAdjustableInsideFacetColumn, IFieldValueCompatibleFacet {
	    header: DynamicFacetHeader;
	    options: IDynamicFacetOptions;
	    dependsOnManager: DependsOnManager;
	    dynamicFacetQueryController: DynamicFacetQueryController;
	    values: IDynamicFacetValues;
	    position: number;
	    moreValuesAvailable: boolean;
	    isCollapsed: boolean;
	    fieldName: string;
	    facetType: FacetType;
	    analyticsFacetState: IAnalyticsFacetState[];
	    basicAnalyticsFacetState: IAnalyticsFacetState;
	    basicAnalyticsFacetMeta: IAnalyticsFacetMeta;
	    isCurrentlyDisplayed(): boolean;
	    selectValue(value: string): void;
	    selectMultipleValues(values: string[]): void;
	    deselectValue(value: string): void;
	    deselectMultipleValues(values: string[]): void;
	    toggleSelectValue(value: string): void;
	    focusValueAfterRerender(value: string): void;
	    showMoreValues(additionalNumberOfValues?: number): void;
	    showLessValues(): void;
	    reset(): void;
	    toggleCollapse(): void;
	    enableFreezeCurrentValuesFlag(): void;
	    enableFreezeFacetOrderFlag(): void;
	    enablePreventAutoSelectionFlag(): void;
	    scrollToTop(): void;
	    logAnalyticsEvent(actionCause: IAnalyticsActionCause, facetMeta: IAnalyticsFacetMeta): void;
	    triggerNewQuery(beforeExecuteQuery?: () => void): void;
	    triggerNewIsolatedQuery(beforeExecuteQuery?: () => void): void;
	}
	interface IValueCreator {
	    createFromResponse(facetValue: IFacetResponseValue, index: number): IDynamicFacetValue;
	    createFromValue(value: string): IDynamicFacetValue;
	    getDefaultValues(): IDynamicFacetValue[];
	}
	interface IValueRenderer {
	    render(): HTMLElement;
	}
	interface IValueRendererKlass {
	    new (facetValue: IDynamicFacetValueProperties, facet: IDynamicFacet): IValueRenderer;
	}
	interface IDynamicFacetValueProperties extends IRangeValue {
	    value: string;
	    displayValue: string;
	    state: FacetValueState;
	    numberOfResults: number;
	    position: number;
	}
	interface IDynamicFacetValue extends IDynamicFacetValueProperties {
	    renderer: IValueRenderer;
	    isSelected: boolean;
	    isIdle: boolean;
	    formattedCount: string;
	    selectAriaLabel: string;
	    renderedElement: HTMLElement;
	    analyticsFacetState: IAnalyticsFacetState;
	    analyticsFacetMeta: IAnalyticsFacetMeta;
	    select(): void;
	    toggleSelect(): void;
	    deselect(): void;
	    equals(arg: string | IDynamicFacetValue): boolean;
	    focus(): void;
	    logSelectActionToAnalytics(): void;
	}
	interface IDynamicFacetValues {
	    createFromResponse(response: IFacetResponse): void;
	    resetValues(): void;
	    clearAll(): void;
	    hasSelectedValue(arg: string | IDynamicFacetValue): boolean;
	    get(arg: string | IDynamicFacetValue): IDynamicFacetValue;
	    focus(value: string): void;
	    render(): HTMLElement;
	    allValues: string[];
	    selectedValues: string[];
	    allFacetValues: IDynamicFacetValue[];
	    activeValues: IDynamicFacetValue[];
	    hasSelectedValues: boolean;
	    hasActiveValues: boolean;
	    hasIdleValues: boolean;
	    hasValues: boolean;
	}

}
declare module Coveo {
	class ResponsiveDynamicFacets extends ResponsiveFacetColumn {
	    static init(root: HTMLElement, component: any, options: IResponsiveComponentOptions): void;
	}

}
declare module Coveo {
	interface IDynamicFacetBreadcrumbsOptions {
	    headingLevel?: number;
	}
	class DynamicFacetBreadcrumbs {
	    element: HTMLElement;
	    constructor(facet: IDynamicFacet, options?: IDynamicFacetBreadcrumbsOptions);
	}

}
declare module Coveo {
	class DynamicFacetValue implements IDynamicFacetValue {
	    value: string;
	    start: RangeType;
	    end: RangeType;
	    endInclusive: boolean;
	    state: FacetValueState;
	    numberOfResults: number;
	    position: number;
	    displayValue: string;
	    renderer: IValueRenderer;
	    constructor(facetValue: IDynamicFacetValueProperties, facet: IDynamicFacet, rendererKlass: IValueRendererKlass);
	     isSelected: boolean;
	     isIdle: boolean;
	    toggleSelect(): void;
	    select(): void;
	    deselect(): void;
	    equals(arg: string | IDynamicFacetValue): boolean;
	    focus(): void;
	     formattedCount: string;
	     selectAriaLabel: string;
	     analyticsFacetState: IAnalyticsFacetState;
	     analyticsFacetMeta: IAnalyticsFacetMeta;
	    logSelectActionToAnalytics(): void;
	     renderedElement: HTMLElement;
	}

}
declare module Coveo {
	interface IDynamicFacetValueMoreLessButtonOptions {
	    label: string;
	    ariaLabel: string;
	    className: string;
	    action: () => void;
	}
	class DynamicFacetValueShowMoreLessButton {
	    element: HTMLElement;
	    constructor(options: IDynamicFacetValueMoreLessButtonOptions);
	}

}
declare module Coveo {
	interface IDynamicFacetValueCreatorKlass {
	    new (facet: IDynamicFacet): IValueCreator;
	}
	class DynamicFacetValues implements IDynamicFacetValues {
	    constructor(facet: IDynamicFacet, creatorKlass: IDynamicFacetValueCreatorKlass);
	    createFromResponse(response: IFacetResponse): void;
	    reorderValues(order: string[]): void;
	    resetValues(): void;
	     allFacetValues: IDynamicFacetValue[];
	     allValues: string[];
	     selectedValues: string[];
	     activeValues: IDynamicFacetValue[];
	     hasSelectedValues: boolean;
	     hasActiveValues: boolean;
	     hasIdleValues: boolean;
	    clearAll(): void;
	     hasValues: boolean;
	     hasDisplayedValues: boolean;
	    hasSelectedValue(arg: string | DynamicFacetValue): boolean;
	    get(arg: string | DynamicFacetValue): IDynamicFacetValue;
	    focus(value: string): void;
	    render(): HTMLElement;
	}

}
declare module Coveo {
	interface IComboboxValue {
	    value: any;
	    element: HTMLElement;
	}
	interface IComboboxOptions {
	    label: string;
	    requestValues: (terms: string) => Promise<any>;
	    createValuesFromResponse: (response: any) => IComboboxValue[];
	    onSelectValue: (value: IComboboxValue) => void;
	    ariaLive: IAriaLive;
	    placeholderText?: string;
	    wrapperClassName?: string;
	    clearOnBlur?: boolean;
	    scrollable?: {
	        maxDropdownHeight: number;
	        requestMoreValues: () => Promise<any>;
	        areMoreValuesAvailable: () => boolean;
	    };
	    highlightValueClassName?: string;
	}
	interface ICombobox {
	    options: IComboboxOptions;
	    element: HTMLElement;
	    id: string;
	    values: IComboboxValues;
	    clearAll(): void;
	    onInputChange(value: string): void;
	    onInputBlur(): void;
	    updateAccessibilityAttributes(attributes: IComboboxAccessibilityAttributes): void;
	    updateAriaLive(): void;
	    onScrollEndReached(): void;
	}
	interface IComboboxValues {
	    element: HTMLElement;
	    mouseIsOverValue: boolean;
	    isRenderingNewValues: boolean;
	    numberOfValues: number;
	    hasValues(): boolean;
	    renderFromResponse(response: any): void;
	    clearValues(): void;
	    selectActiveValue(): void;
	    resetScroll(): void;
	    focusNextValue(): void;
	    focusPreviousValue(): void;
	    focusFirstValue(): void;
	    focusLastValue(): void;
	    saveFocusedValue(): void;
	    restoreFocusedValue(): void;
	}
	interface IComboboxAccessibilityAttributes {
	    activeDescendant: string;
	    expanded: boolean;
	}

}
declare module Coveo {
	class ComboboxInput {
	    element: HTMLElement;
	    constructor(combobox: ICombobox);
	     value: string;
	    updateAccessibilityAttributes(attributes: IComboboxAccessibilityAttributes): void;
	    clearInput(): void;
	}

}
declare module Coveo {
	class ComboboxValues implements IComboboxValues {
	    element: HTMLElement;
	    mouseIsOverValue: boolean;
	    isRenderingNewValues: boolean;
	    constructor(combobox: ICombobox);
	    renderFromResponse(response: any): void;
	    hasValues(): boolean;
	     numberOfValues: number;
	    clearValues(): void;
	    selectActiveValue(): void;
	    resetScroll(): void;
	    focusFirstValue(): void;
	    focusLastValue(): void;
	    focusNextValue(): void;
	    focusPreviousValue(): void;
	    saveFocusedValue(): void;
	    restoreFocusedValue(): void;
	}

}
declare module Coveo {
	class Combobox implements ICombobox {
	    options: IComboboxOptions;
	    element: HTMLElement;
	    id: string;
	    values: ComboboxValues;
	    constructor(options: IComboboxOptions);
	    clearAll(): void;
	    onInputChange(value: string): void;
	    onInputBlur(): void;
	    updateAccessibilityAttributes(attributes: IComboboxAccessibilityAttributes): void;
	    updateAriaLive(): void;
	    onScrollEndReached(): void;
	}

}
declare module Coveo {
	class FacetSearchController {
	    moreValuesAvailable: boolean;
	    constructor(facet: IDynamicFacet);
	    search(terms: string): Promise<IFacetSearchResponse>;
	    fetchMoreResults(): Promise<IFacetSearchResponse>;
	}

}
declare module Coveo {
	class DynamicFacetValueCheckbox {
	    element: HTMLElement;
	    constructor(facetValue: DynamicFacetValue, selectAction?: () => void);
	}

}
declare module Coveo {
	class DynamicFacetSearchValueRenderer implements IValueRenderer {
	    constructor(facetValue: DynamicFacetValue, facet: IDynamicFacet);
	    render(): HTMLElement;
	    selectAction(): void;
	}

}
declare module Coveo {
	class DynamicFacetSearch {
	    element: HTMLElement;
	    constructor(facet: IDynamicFacet);
	}

}
declare module Coveo {
	class DynamicFacetValueRenderer implements IValueRenderer {
	    constructor(facetValue: DynamicFacetValue, facet: IDynamicFacet);
	    render(): HTMLElement;
	}

}
declare module Coveo {
	class DynamicFacetValueCreator implements IValueCreator {
	    constructor(facet: IDynamicFacet);
	    getDefaultValues(): any[];
	    createFromResponse(facetValue: IFacetResponseValue, index: number): DynamicFacetValue;
	    createFromValue(value: string): DynamicFacetValue;
	}

}
declare module Coveo {
	/**
	 * The `DynamicFacet` component displays a *facet* of the results for the current query. A facet is a list of values for a
	 * certain field occurring in the results, ordered using a configurable criteria (e.g., number of occurrences).
	 *
	 * The list of values is obtained using an array of [`FacetRequest`]{@link IFacetRequest} operations performed at the same time
	 * as the main query.
	 *
	 * The `DynamicFacet` component allows the end-user to drill down inside a result set by restricting the result to certain
	 * field values.
	 *
	 * This facet is more easy to use than the original [`Facet`]{@link Facet} component. It implements additional Coveo Machine Learning (Coveo ML) features
	 * such as dynamic navigation experience (DNE).
	 *
	 * @notSupportedIn salesforcefree
	 * @availablesince [May 2019 Release (v2.6063)](https://docs.coveo.com/en/2909/)
	 */
	class DynamicFacet extends Component implements IDynamicFacet {
	    element: HTMLElement;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the DynamicFacet
	     * @componentOptions
	     */
	    static options: IDynamicFacetOptions;
	    header: DynamicFacetHeader;
	    options: IDynamicFacetOptions;
	    dynamicFacetManager: DynamicFacetManager;
	    dependsOnManager: DependsOnManager;
	    dynamicFacetQueryController: DynamicFacetQueryController;
	    values: DynamicFacetValues;
	    position: number;
	    moreValuesAvailable: boolean;
	    isCollapsed: boolean;
	    isDynamicFacet: boolean;
	    isFieldValueCompatible: boolean;
	    isFieldValueHierarchical: boolean;
	    /**
	     * Creates a new `DynamicFacet` instance.
	     *
	     * @param element The element from which to instantiate the component.
	     * @param options The component options.
	     * @param bindings The component bindings. Automatically resolved by default.
	     */
	    constructor(element: HTMLElement, options?: IDynamicFacetOptions, bindings?: IComponentBindings, classId?: string);
	     fieldName: string;
	     facetType: FacetType;
	    /**
	     * Selects a single value in this facet.
	     *
	     * Does **not** trigger a query automatically.
	     * Does **not** update the visual of the facet until a query is performed.
	     *
	     * @param value The name of the facet value to select.
	     */
	    selectValue(value: string): void;
	    /**
	     * Selects multiple values in this facet.
	     *
	     * Does **not** trigger a query automatically.
	     * Does **not** update the visual of the facet until a query is performed.
	     *
	     * @param values The names of the facet values to select.
	     */
	    selectMultipleValues(values: string[]): void;
	    /**
	     * Deselects a single value in this facet.
	     *
	     * Does **not** trigger a query automatically.
	     * Does **not** update the visual of the facet until a query is performed.
	     *
	     * @param values The name of the facet value to deselect.
	     */
	    deselectValue(value: string): void;
	    /**
	     * Determines whether the specified value is selected in the facet.
	     * @param value The name of the facet value to verify.
	     */
	    hasSelectedValue(value: string): boolean;
	    /**
	     * Deselects multiple values in this facet.
	     *
	     * Does **not** trigger a query automatically.
	     * Does **not** update the visual of the facet until a query is performed.
	     *
	     * @param values The names of the facet values to deselect.
	     */
	    deselectMultipleValues(values: string[]): void;
	    /**
	     * Toggles the selection state of a single value in this facet.
	     *
	     * Does **not** trigger a query automatically.
	     *
	     * @param values The name of the facet value to toggle.
	     */
	    toggleSelectValue(value: string): void;
	    /**
	     * Keyboard focuses a value once it has been re-rendered.
	     *
	     * @param value The name of the facet value to focus
	     */
	    focusValueAfterRerender(value: string): void;
	    /**
	     * Returns the configured caption for a desired facet value.
	     *
	     * @param value The string facet value whose caption the method should return.
	     */
	    getCaptionForStringValue(value: string): string;
	    /**
	     * Requests additional values.
	     *
	     * Automatically triggers an isolated query.
	     * @param additionalNumberOfValues The number of additional values to request. Minimum value is 1. Defaults to the [numberOfValues]{@link DynamicFacet.options.numberOfValues} option value.
	     */
	    showMoreValues(additionalNumberOfValues?: number): void;
	    /**
	     * Reduces the number of displayed facet values down to [numberOfValues]{@link DynamicFacet.options.numberOfValues}.
	     *
	     * Automatically triggers an isolated query.
	     */
	    showLessValues(): void;
	    /**
	     * Deselects all values in this facet.
	     *
	     * Does **not** trigger a query automatically.
	     * Updates the visual of the facet.
	     *
	     */
	    reset(): void;
	    /**
	     * Collapses or expands the facet depending on it's current state.
	     */
	    toggleCollapse(): void;
	    /**
	     * Expands the facet, displaying all of its currently fetched values.
	     */
	    expand(): void;
	    /**
	     * Collapses the facet, displaying only its currently selected values.
	     */
	    collapse(): void;
	    /**
	     * Sets a flag indicating whether the facet values should be returned in their current order.
	     *
	     * Setting the flag to `true` helps ensuring that the values do not move around while the end-user is interacting with them.
	     *
	     * The flag is automatically set back to `false` after a query is built.
	     */
	    enableFreezeCurrentValuesFlag(): void;
	    /**
	     * For this method to work, the component has to be the child of a [DynamicFacetManager]{@link DynamicFacetManager} component.
	     *
	     * Sets a flag indicating whether the facets should be returned in their current order.
	     *
	     * Setting the flag to `true` helps ensuring that the facets do not move around while the end-user is interacting with them.
	     *
	     * The flag is automatically set back to `false` after a query is built.
	     */
	    enableFreezeFacetOrderFlag(): void;
	    enablePreventAutoSelectionFlag(): void;
	    scrollToTop(): void;
	     analyticsFacetState: IAnalyticsFacetState[];
	     basicAnalyticsFacetState: IAnalyticsFacetState;
	     basicAnalyticsFacetMeta: IAnalyticsFacetMeta;
	    logAnalyticsEvent(actionCause: IAnalyticsActionCause, facetMeta: IAnalyticsFacetMeta): void;
	    putStateIntoQueryBuilder(queryBuilder: QueryBuilder): void;
	    putStateIntoAnalytics(): void;
	    isCurrentlyDisplayed(): boolean;
	     hasActiveValues: boolean;
	    protected initBreadCrumbEvents(): void;
	    protected initValues(): void;
	    protected initDynamicFacetQueryController(): void;
	    handleQueryResults(results: IQueryResults): void;
	    createDom(): void;
	    triggerNewQuery(beforeExecuteQuery?: () => void): void;
	    triggerNewIsolatedQuery(beforeExecuteQuery?: () => void): Promise<void>;
	}

}
declare module Coveo {
	/**
	 * The allowed values for the [`valueFormat`]{@link DynamicFacetRange.options.valueFormat} option
	 * of the [`DynamicFacetRange`]{@link DynamicFacetRange} component.
	 */
	enum DynamicFacetRangeValueFormat {
	    /**
	     * Format range values as localized currency strings.
	     */
	    currency,
	    /**
	     * Format range values as localized numeric strings.
	     */
	    number,
	    /**
	     * Format range values as localized date strings.
	     */
	    date,
	}
	function isFacetRangeValueFormat(rangeValueFormat: string): boolean;
	interface IDynamicFacetRangeOptions extends IDynamicFacetOptions {
	    valueSeparator?: string;
	    valueFormat?: DynamicFacetRangeValueFormat;
	    ranges?: IRangeValue[];
	    numberOfDecimals?: number;
	    currencySymbol?: string;
	    sortOrder?: FacetRangeSortOrder;
	}
	interface IDynamicFacetRange extends IDynamicFacet {
	    options: IDynamicFacetRangeOptions;
	}

}
declare module Coveo {
	class DynamicFacetRangeValueParser {
	    constructor(facet: IDynamicFacetRange);
	    formatDisplayValue(range: IRangeValue): string;
	    validate(unvalidatedRange: IRangeValue): IRangeValue;
	    formatValue(range: IRangeValue): string;
	    parse(value: string): IRangeValue;
	}

}
declare module Coveo {
	class DynamicFacetRangeValueCreator implements IValueCreator {
	    constructor(facet: IDynamicFacetRange);
	    getDefaultValues(): DynamicFacetValue[];
	    createFromResponse(responseValue: IFacetResponseValue, index: number): DynamicFacetValue;
	    createFromValue(value: string): DynamicFacetValue;
	}

}
declare module Coveo {
	class DynamicFacetRangeQueryController extends DynamicFacetQueryController {
	    protected facet: IDynamicFacetRange;
	    buildFacetRequest(): IFacetRequest;
	    protected  numberOfValues: number;
	    protected  currentValues: IFacetRequestValue[];
	}

}
declare module Coveo {
	/**
	 * A `DynamicFacetRange` is a [facet](https://docs.coveo.com/en/198/) whose values are expressed as ranges.
	 *
	 * You must set the [`field`]{@link DynamicFacet.options.field} option to a value targeting a numeric or date [field](https://docs.coveo.com/en/200/)
	 * in your index for this component to work.
	 *
	 * This component extends the [`DynamicFacet`]{@link DynamicFacet} component and supports all `DynamicFacet` options except:
	 *
	 * - [`enableFacetSearch`]{@link DynamicFacet.options.enableFacetSearch}
	 * - [`useLeadingWildcardInFacetSearch`]{@link DynamicFacet.options.useLeadingWildcardInFacetSearch}
	 * - [`enableMoreLess`]{@link DynamicFacet.options.enableMoreLess}
	 * - [`valueCaption`]{@link DynamicFacet.options.valueCaption}
	 *
	 * @notSupportedIn salesforcefree
	 * @availablesince [October 2019 Release (v2.7219)](https://docs.coveo.com/en/3084/)
	 */
	class DynamicFacetRange extends DynamicFacet implements IComponentBindings {
	    element: HTMLElement;
	    options: IDynamicFacetRangeOptions;
	    static ID: string;
	    static parent: typeof DynamicFacet;
	    static doExport: () => void;
	    /**
	     * The options for the DynamicFacetRange
	     * @componentOptions
	     */
	    static options: IDynamicFacetRangeOptions;
	    isFieldValueCompatible: boolean;
	    /**
	     * Creates a new `DynamicFacetRange` instance.
	     *
	     * @param element The element from which to instantiate the component.
	     * @param options The component options.
	     * @param bindings The component bindings. Automatically resolved by default.
	     */
	    constructor(element: HTMLElement, options: IDynamicFacetRangeOptions, bindings?: IComponentBindings);
	    protected initValues(): void;
	    protected initDynamicFacetQueryController(): void;
	     facetType: FacetType;
	    showMoreValues(): void;
	    showLessValues(): void;
	    triggerNewIsolatedQuery(): Promise<void>;
	}

}
declare module Coveo {
	interface IPromotedResultsBadgeOptions {
	    showBadgeForFeaturedResults: boolean;
	    showBadgeForRecommendedResults: boolean;
	    captionForRecommended: string;
	    captionForFeatured: string;
	    colorForFeaturedResults: string;
	    colorForRecommendedResults: string;
	}
	/**
	 * Depending on its configuration, this component will render badges on query result items whose ranking scores were increased by [featured results](https://docs.coveo.com/en/1961/) query pipeline rules and/or [Coveo ML ART](https://docs.coveo.com/en/1671/#automatic-relevance-tuning-art-feature).
	 *
	 * This component can be put anywhere in the markup configuration of a search interface. However, it is meant to be initialized only once, and should thus void be included in a result template.
	 *
	 * @externaldocs [Adding Promoted Results Badges](https://docs.coveo.com/en/3123/)
	 * @availablesince [July 2018 Release (v2.4382.10)](https://docs.coveo.com/en/1360/)
	 */
	class PromotedResultsBadge extends Component {
	    element: HTMLElement;
	    options: IPromotedResultsBadgeOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * @componentOptions
	     */
	    static options: IPromotedResultsBadgeOptions;
	    constructor(element: HTMLElement, options: IPromotedResultsBadgeOptions, bindings: IComponentBindings);
	}

}
declare module Coveo {
	type HierarchicalFacetSortCriteria = 'alphanumeric' | 'occurrences';
	interface IDynamicHierarchicalFacetOptions extends IResponsiveComponentOptions, IDependsOnCompatibleFacetOptions {
	    field: IFieldOption;
	    title?: string;
	    enableCollapse?: boolean;
	    collapsedByDefault?: boolean;
	    enableScrollToTop?: boolean;
	    numberOfValues?: number;
	    sortCriteria?: HierarchicalFacetSortCriteria;
	    customSort?: string;
	    customSortDelimitingCharacter?: string;
	    injectionDepth?: number;
	    enableMoreLess?: boolean;
	    enableFacetSearch?: boolean;
	    delimitingCharacter?: string;
	    valueCaption?: IStringMap<string>;
	    includeInBreadcrumb?: boolean;
	    filterFacetCount?: boolean;
	    clearLabel?: string;
	    basePath?: string[];
	    headingLevel?: number;
	}
	interface IDynamicHierarchicalFacet extends Component, IDynamicManagerCompatibleFacet, IAutoLayoutAdjustableInsideFacetColumn {
	    header: DynamicFacetHeader;
	    options: IDynamicHierarchicalFacetOptions;
	    dependsOnManager: DependsOnManager;
	    dynamicHierarchicalFacetQueryController: DynamicHierarchicalFacetQueryController;
	    isCollapsed: boolean;
	    values: IDynamicHierarchicalFacetValues;
	    moreValuesAvailable: boolean;
	    position: number;
	    fieldName: string;
	    facetType: FacetType;
	    isCurrentlyDisplayed(): boolean;
	    scrollToTop(): void;
	    triggerNewQuery(beforeExecuteQuery?: () => void): void;
	    triggerNewIsolatedQuery(beforeExecuteQuery?: () => void): void;
	    showMoreValues(additionalNumberOfValues?: number): void;
	    showLessValues(): void;
	    selectPath(path: string[]): void;
	    reset(): void;
	    toggleCollapse(): void;
	    getCaption(value: string): string;
	    logAnalyticsEvent(eventName: IAnalyticsActionCause): void;
	    enableFreezeFacetOrderFlag(): void;
	    enablePreventAutoSelectionFlag(): void;
	}
	interface IDynamicHierarchicalFacetSearchValueProperties {
	    fullPath: string[];
	    displayValue: string;
	    numberOfResults: number;
	}
	interface IDynamicHierarchicalFacetValueProperties {
	    value: string;
	    path: string[];
	    displayValue: string;
	    state: FacetValueState;
	    numberOfResults: number;
	    moreValuesAvailable: boolean;
	    children: IDynamicHierarchicalFacetValue[];
	    isLeafValue: boolean;
	}
	interface IDynamicHierarchicalFacetValue extends IDynamicHierarchicalFacetValueProperties {
	    retrieveCount: number;
	    isIdle: boolean;
	    isSelected: boolean;
	    selectAriaLabel: string;
	    formattedCount: string;
	    select(): void;
	    render(fragement: DocumentFragment): HTMLElement;
	    logSelectActionToAnalytics(): void;
	}
	interface IDynamicHierarchicalFacetValues {
	    resetValues(): void;
	    clearPath(): void;
	    createFromResponse(response: IFacetResponse): void;
	    reorderValues(order: string[][]): void;
	    selectPath(path: string[]): void;
	    render(): HTMLElement;
	    hasSelectedValue: boolean;
	    selectedPath: string[];
	    allFacetValues: IDynamicHierarchicalFacetValue[];
	}

}
declare module Coveo {
	class DynamicHierarchicalFacetQueryController {
	    constructor(facet: IDynamicHierarchicalFacet);
	    increaseNumberOfValuesToRequest(additionalNumberOfValues: number): void;
	    resetNumberOfValuesToRequest(): void;
	    enableFreezeFacetOrderFlag(): void;
	    enablePreventAutoSelectionFlag(): void;
	    putFacetIntoQueryBuilder(queryBuilder: QueryBuilder): void;
	    buildFacetRequest(): IFacetRequest;
	    getQueryResults(): Promise<IQueryResults>;
	}

}
declare module Coveo {
	interface IDynamicHierarchicalFacetBreadcrumbsOptions {
	    headingLevel?: number;
	}
	class DynamicHierarchicalFacetBreadcrumb {
	    element: HTMLElement;
	    constructor(facet: IDynamicHierarchicalFacet, options?: IDynamicHierarchicalFacetBreadcrumbsOptions);
	}

}
declare module Coveo {
	class DynamicHierarchicalFacetValueRenderer {
	    constructor(facetValue: IDynamicHierarchicalFacetValue, facet: IDynamicHierarchicalFacet);
	    render(): HTMLElement;
	}

}
declare module Coveo {
	class DynamicHierarchicalFacetValue implements IDynamicHierarchicalFacetValue {
	    retrieveCount: number;
	    constructor(facetValue: IDynamicHierarchicalFacetValueProperties, facet: IDynamicHierarchicalFacet);
	     value: string;
	     path: string[];
	    state: FacetValueState;
	     moreValuesAvailable: boolean;
	     numberOfResults: number;
	     displayValue: string;
	    children: IDynamicHierarchicalFacetValue[];
	     isLeafValue: boolean;
	     isIdle: boolean;
	     isSelected: boolean;
	    select(): void;
	     selectAriaLabel: string;
	     formattedCount: string;
	    render(fragment: DocumentFragment): HTMLElement;
	    logSelectActionToAnalytics(): void;
	}

}
declare module Coveo {
	class DynamicHierarchicalFacetValues implements IDynamicHierarchicalFacetValues {
	    constructor(facet: IDynamicHierarchicalFacet);
	    createFromResponse(response: IFacetResponse): void;
	    reorderValues(pathsOrder: string[][]): void;
	     allFacetValues: IDynamicHierarchicalFacetValue[];
	     hasSelectedValue: boolean;
	     selectedPath: string[];
	    resetValues(): void;
	    clearPath(): void;
	    selectPath(path: string[]): void;
	    render(): HTMLElement;
	}

}
declare module Coveo {
	class HierarchicalFacetSearchController {
	    moreValuesAvailable: boolean;
	    constructor(facet: IDynamicHierarchicalFacet);
	    search(terms: string): Promise<IFacetSearchResponse>;
	    fetchMoreResults(): Promise<IFacetSearchResponse>;
	}

}
declare module Coveo {
	const DynamicHierarchicalFacetSearchValueRendererClassNames: {
	    VALUE_CLASSNAME: string;
	    HEADER_CLASSNAME: string;
	    LABEL_CLASSNAME: string;
	    COUNT_CLASSNAME: string;
	    PATH_CLASSNAME: string;
	    PATH_ELLIPSIS_CLASSNAME: string;
	    PATH_PREFIX_CLASSNAME: string;
	    PATH_PART_CLASSNAME: string;
	    PATH_SEPARATOR_CLASSNAME: string;
	};
	class DynamicHierarchicalFacetSearchValueRenderer {
	    constructor(facetValue: DynamicHierarchicalFacetSearchValue, facet: IDynamicHierarchicalFacet);
	    render(): HTMLElement;
	    selectAction(): void;
	}

}
declare module Coveo {
	class DynamicHierarchicalFacetSearchValue implements IDynamicHierarchicalFacetSearchValueProperties {
	    renderer: DynamicHierarchicalFacetSearchValueRenderer;
	    constructor(facetValue: IDynamicHierarchicalFacetSearchValueProperties, facet: IDynamicHierarchicalFacet);
	     fullPath: string[];
	     displayValue: string;
	     numberOfResults: number;
	     renderedElement: HTMLElement;
	    logSelectActionToAnalytics(): void;
	}

}
declare module Coveo {
	class DynamicHierarchicalFacetSearch {
	    element: HTMLElement;
	    constructor(facet: IDynamicHierarchicalFacet);
	}

}
declare module Coveo {
	/**
	 * The `DynamicHierarchicalFacet` component is a facet that renders values in a hierarchical fashion. It determines the filter to apply depending on the
	 * selected path of values.
	 *
	 * This facet requires a [`field`]{@link DynamicHierarchicalFacet.options.field} with a special format to work correctly.
	 *
	 * @notSupportedIn salesforcefree
	 * @availablesince [January 2020 Release (v2.7968)](https://docs.coveo.com/en/3163/)
	 * @externaldocs [Using Hierarchical Facets](https://docs.coveo.com/en/2667)
	 */
	class DynamicHierarchicalFacet extends Component implements IDynamicHierarchicalFacet, IFieldValueCompatibleFacet {
	    element: HTMLElement;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the DynamicHierarchicalFacet
	     * @componentOptions
	     */
	    static options: IDynamicHierarchicalFacetOptions;
	    options: IDynamicHierarchicalFacetOptions;
	    dynamicHierarchicalFacetQueryController: DynamicHierarchicalFacetQueryController;
	    dependsOnManager: DependsOnManager;
	    isCollapsed: boolean;
	    header: DynamicFacetHeader;
	    values: IDynamicHierarchicalFacetValues;
	    moreValuesAvailable: boolean;
	    position: number;
	    dynamicFacetManager: DynamicFacetManager;
	    isDynamicFacet: boolean;
	    isFieldValueCompatible: boolean;
	    isFieldValueHierarchical: boolean;
	    constructor(element: HTMLElement, options: IDynamicHierarchicalFacetOptions, bindings?: IComponentBindings);
	     fieldName: string;
	     facetType: FacetType;
	    isCurrentlyDisplayed(): boolean;
	     hasActiveValues: boolean;
	    hasSelectedValue(value: string): boolean;
	    selectValue(value: string): void;
	    deselectValue(): void;
	    getCaptionForStringValue(value: string): string;
	    putStateIntoQueryBuilder(queryBuilder: QueryBuilder): void;
	    putStateIntoAnalytics(): void;
	    scrollToTop(): void;
	    handleQueryResults(results: IQueryResults): void;
	    triggerNewQuery(beforeExecuteQuery?: () => void): void;
	    triggerNewIsolatedQuery(beforeExecuteQuery?: () => void): Promise<void>;
	    /**
	     * Requests additional values.
	     *
	     * See the [`enableMoreLess`]{@link DynamicHierarchicalFacet.options.enableMoreLess} option.
	     *
	     * Automatically triggers an isolated query.
	     * @param additionalNumberOfValues The number of additional values to request. Minimum value is 1. Defaults to the [numberOfValues]{@link DynamicHierarchicalFacet.options.numberOfValues} option value.
	     */
	    showMoreValues(additionalNumberOfValues?: number): void;
	    /**
	     * Reduces the number of displayed facet values down to [numberOfValues]{@link DynamicFacet.options.numberOfValues}.
	     *
	     * See the [`enableMoreLess`]{@link DynamicHierarchicalFacet.options.enableMoreLess} option.
	     *
	     * Automatically triggers an isolated query.
	     */
	    showLessValues(): void;
	    /**
	     * Select a path in the hierarchy.
	     *
	     * Does **not** trigger a query automatically.
	     * Does **not** update the visual of the facet until a query is performed.
	     *
	     * @param path The values representing the path.
	     */
	    selectPath(path: string[]): void;
	    /**
	     * Deselects the path in the facet.
	     *
	     * Does **not** trigger a query automatically.
	     * Does **not** update the visual of the facet until a query is performed.
	     */
	    reset(): void;
	    /**
	     * Collapses or expands the facet depending on it's current state.
	     */
	    toggleCollapse(): void;
	    /**
	     * Expands the facet, displaying all of its currently fetched values.
	     */
	    expand(): void;
	    /**
	     * For this method to work, the component has to be the child of a [DynamicFacetManager]{@link DynamicFacetManager} component.
	     *
	     * Sets a flag indicating whether the facets should be returned in their current order.
	     *
	     * Setting the flag to `true` helps ensuring that the facets do not move around while the end-user is interacting with them.
	     *
	     * The flag is automatically set back to `false` after a query is built.
	     */
	    enableFreezeFacetOrderFlag(): void;
	    enablePreventAutoSelectionFlag(): void;
	    /**
	     * Collapses the facet, hiding values.
	     */
	    collapse(): void;
	    createDom(): void;
	    /**
	     *
	     * @param value The string to find a caption for.
	     * Returns the caption for a value or the value itself if no caption is available.
	     */
	    getCaption(value: string): string;
	    logAnalyticsEvent(actionCause: IAnalyticsActionCause): void;
	     analyticsFacetState: IAnalyticsFacetState[];
	     analyticsFacetMeta: IAnalyticsFacetMeta;
	}

}
declare module Coveo {
	interface IMissingTermsOptions {
	    caption?: string;
	    clickable?: boolean;
	    numberOfTerms?: number;
	}
	/**
	 * This [result template component](https://docs.coveo.com/en/513/#using-result-template-components) renders a list of query terms
	 * that were not matched by the associated result item.
	 *
	 * @availablesince [July 2019 Release (v2.6459)](https://docs.coveo.com/en/2938/)
	 */
	class MissingTerms extends Component {
	    element: HTMLElement;
	    options: IMissingTermsOptions;
	    result: IQueryResult;
	    static ID: string;
	    /**
	     * @componentOptions
	     */
	    static options: IMissingTermsOptions;
	    static doExport: () => void;
	    /**
	     * Creates a new `MissingTerms` component instance.
	     * @param element The element on which to instantiate the component.
	     * @param options The configuration options for the component.
	     * @param bindings The bindings required by the component to function normally. If not set, these will be automatically resolved (with a slower execution time).
	     * @param result The query result item to associate the component with.
	     */
	    constructor(element: HTMLElement, options?: IMissingTermsOptions, bindings?: IComponentBindings, result?: IQueryResult);
	    /**
	     * Returns all original basic query expression terms and phrases that were not matched by the result item the component instance is associated with.
	     */
	     missingTerms: string[];
	    /**
	     * Injects a term in the advanced part of the query expression (aq) to filter out items that do not match the term.
	     * @param term The term to add to the advanced query expression.
	     */
	    addTermForcedToAppear(term: string): void;
	}

}
declare module Coveo {
	interface IImageFieldValue {
	    field?: IFieldOption;
	    width?: number;
	    height?: number;
	    alt?: string;
	    srcTemplate?: string;
	}
	/**
	 * This component renders an image from a URL retrieved in a given [`field`]{@link ImageFieldValue.options.field}.
	 *
	 * A typical use case of this component is to display product images in the context of commerce.
	 *
	 * @isresulttemplatecomponent
	 * @availablesince [September 2019 Release (v2.7023)](https://docs.coveo.com/en/2990/)
	 */
	class ImageFieldValue extends Component {
	    element: HTMLElement;
	    options: IImageFieldValue;
	    result: IQueryResult;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IImageFieldValue;
	    /**
	     * Creates a new ImageFieldValue.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the ImageFieldValue component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     * @param result The result to associate the component with.
	     */
	    constructor(element: HTMLElement, options: IImageFieldValue, bindings?: IComponentBindings, result?: IQueryResult);
	}

}
declare module Coveo {
	interface IQuerySuggestPreview {
	    numberOfPreviewResults?: number;
	    resultTemplate?: Template;
	    executeQueryDelay?: number;
	}
	/**
	 * This component renders previews of the top query results matching the currently focused query suggestion in the search box.
	 *
	 * As such, this component only works when the search interface can
	 * [provide Coveo Machine Learning query suggestions](https://docs.coveo.com/en/340/#providing-coveo-machine-learning-query-suggestions).
	 *
	 * This component should be initialized on a `div` which can be nested anywhere inside the root element of your search interface.
	 *
	 * See [Rendering Query Suggestion Result Previews](https://docs.coveo.com/en/340/#rendering-query-suggestion-result-previews).
	 *
	 * @availablesince [December 2019 Release (v2.7610)](https://docs.coveo.com/en/3142/)
	 */
	class QuerySuggestPreview extends Component implements IComponentBindings {
	    element: HTMLElement;
	    options: IQuerySuggestPreview;
	    bindings: IComponentBindings;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the component
	     * @componentOptions
	     */
	    static options: IQuerySuggestPreview;
	    /**
	     * Creates a new QuerySuggestPreview component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the QuerySuggestPreview component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: IQuerySuggestPreview, bindings?: IComponentBindings);
	}

}
declare module Coveo {
	interface ICommerceQueryOptions {
	    listing?: string;
	}
	/**
	 * This component exposes options to handle commerce-related queries.
	 *
	 * @availablesince [March 2020 Release (v2.8521)](https://docs.coveo.com/en/3203/)
	 */
	class CommerceQuery extends Component {
	    element: HTMLElement;
	    options: ICommerceQueryOptions;
	    bindings: IComponentBindings;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the CommerceQuery.
	     * @componentOptions
	     */
	    static options: ICommerceQueryOptions;
	    /**
	     * Creates a new CommerceQuery component.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for the CommerceQuery component.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: ICommerceQueryOptions, bindings?: IComponentBindings);
	}

}
declare module Coveo {
	/**
	 * The `SortDropdown` component renders a dropdown that the end user can interact with to select the criteria to use when sorting query results.
	 *
	 * It is meant to be a parent of regular [`Sort`]{@link Sort} components. Example:
	 * ```
	 * <div class="CoveoSortDropdown">
	 *   <span class="CoveoSort" data-sort-criteria="relevancy" data-caption="Relevance"></span>
	 *   <span class="CoveoSort" data-sort-criteria="date descending" data-caption="Newest"></span>
	 *   <span class="CoveoSort" data-sort-criteria="date ascending" data-caption="Oldest"></span>
	 * </div>
	 * ```
	 * Each one of the children `Sort` components should have only one sort criteria to prevent the regular toggle behaviour.
	 *
	 * @availablesince [March 2020 Release (v2.8521)](https://docs.coveo.com/en/3203/)
	 */
	class SortDropdown extends Component {
	    element: HTMLElement;
	    options: any;
	    static ID: string;
	    static options: any;
	    static doExport: () => void;
	    /**
	     * Creates a new `SortDropdown` component instance.
	     * @param element The HTMLElement on which to instantiate the component.
	     * @param options The options for this component instance.
	     * @param bindings The bindings that the component requires to function normally. If not set, these will be
	     * automatically resolved (with a slower execution time).
	     */
	    constructor(element: HTMLElement, options?: any, bindings?: IComponentBindings);
	    /**
	     * Selects a sort criteria from the options.
	     * @param sortCriteria The sort criteria to select.
	     * @param executeQuery Whether to execute a query after changing the sort criteria
	     */
	    select(sortCriteria: string, executeQuery?: boolean): void;
	}

}
declare module Coveo {
	const UserFeedbackBannerClassNames: {
	    ROOT_CLASSNAME: string;
	    CONTAINER_CLASSNAME: string;
	    LABEL_CLASSNAME: string;
	    BUTTONS_CONTAINER_CLASSNAME: string;
	    YES_BUTTON_CLASSNAME: string;
	    NO_BUTTON_CLASSNAME: string;
	    BUTTON_ACTIVE_CLASSNAME: string;
	    THANK_YOU_BANNER_CLASSNAME: string;
	    THANK_YOU_BANNER_ACTIVE_CLASSNAME: string;
	    ICON_CLASSNAME: string;
	    EXPLAIN_WHY_CLASSNAME: string;
	    EXPLAIN_WHY_ACTIVE_CLASSNAME: string;
	};
	class UserFeedbackBanner {
	    explainWhy: HTMLElement;
	    constructor(sendUsefulnessAnalytics: (isUseful: boolean) => void, onExplainWhyPressed: () => void);
	    build(): HTMLElement;
	    reset(): void;
	}

}
declare module Coveo {
	const HeightLimiterClassNames: {
	    CONTAINER_ACTIVE_CLASSNAME: string;
	    CONTAINER_EXPANDED_CLASSNAME: string;
	    BUTTON_CLASSNAME: string;
	    BUTTON_LABEL_CLASSNAME: string;
	    BUTTON_ICON_CLASSNAME: string;
	    BUTTON_ACTIVE_CLASSNAME: string;
	};
	class HeightLimiter {
	     toggleButton: HTMLElement;
	    constructor(containerElement: HTMLElement, contentElement: HTMLElement, heightLimit: number, onToggle?: (isExpanded: boolean) => void);
	    onContentHeightChanged(): void;
	}

}
declare module Coveo {
	/// <reference types="modal-box" />
	interface IReason {
	    label: string;
	    id: string;
	    onSelect: () => void;
	    hasDetails?: boolean;
	}
	interface IExplanationModalOptions {
	    ownerElement: HTMLElement;
	    reasons: IReason[];
	    onClosed: () => void;
	    modalBoxModule?: Coveo.ModalBox.ModalBox;
	}
	const ExplanationModalClassNames: {
	    ROOT_CLASSNAME: string;
	    CONTENT_CLASSNAME: string;
	    EXPLANATION_SECTION_CLASSNAME: string;
	    REASONS_CLASSNAME: string;
	    REASONS_LABEL_CLASSNAME: string;
	    DETAILS_SECTION_CLASSNAME: string;
	    DETAILS_TEXTAREA_CLASSNAME: string;
	    DETAILS_LABEL_CLASSNAME: string;
	    BUTTONS_SECTION_CLASSNAME: string;
	    SEND_BUTTON_CLASSNAME: string;
	    CANCEL_BUTTON_CLASSNAME: string;
	};
	class ExplanationModal {
	    options: IExplanationModalOptions;
	    constructor(options: IExplanationModalOptions);
	     details: string;
	    open(origin: HTMLElement): void;
	}

}
declare module Coveo {
	interface IShadowOptions {
	    title: string;
	    onSizeChanged?: Function;
	    useIFrame?: Boolean;
	}
	function attachShadow(element: HTMLElement, options: IShadowOptions & any): Promise<HTMLElement>;

}
declare module Coveo {
	function getSanitizedAnswerSnippet(questionAnswer: IQuestionAnswerResponse | IRelatedQuestionAnswerResponse): string;

}
declare module Coveo {
	const SmartSnippetClassNames: {
	    QUESTION_CLASSNAME: string;
	    ANSWER_CONTAINER_CLASSNAME: string;
	    HAS_ANSWER_CLASSNAME: string;
	    SHADOW_CLASSNAME: string;
	    CONTENT_CLASSNAME: string;
	    SOURCE_CLASSNAME: string;
	    SOURCE_TITLE_CLASSNAME: string;
	    SOURCE_URL_CLASSNAME: string;
	};
	interface ISmartSnippetOptions {
	    maximumSnippetHeight: number;
	    titleField: IFieldOption;
	    hrefTemplate?: string;
	    alwaysOpenInNewWindow?: boolean;
	    useIFrame?: boolean;
	}
	/**
	 * The SmartSnippet component displays the excerpt of a document that would be most likely to answer a particular query.
	 *
	 * This excerpt can be visually customized using inline styling.
	 */
	class SmartSnippet extends Component {
	    element: HTMLElement;
	    options: ISmartSnippetOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the SmartSnippet
	     * @componentOptions
	     */
	    static options: ISmartSnippetOptions;
	    constructor(element: HTMLElement, options?: ISmartSnippetOptions, bindings?: IComponentBindings, ModalBox?: any);
	     loading: Promise<HTMLElement>;
	    createDom(): void;
	    /**
	     * @warning This method only works for the demo. In practice, the source of the answer will not always be part of the results.
	     */
	}

}
declare module Coveo {
	const SmartSnippetCollapsibleSuggestionClassNames: {
	    QUESTION_CLASSNAME: string;
	    QUESTION_TITLE_CLASSNAME: string;
	    QUESTION_TITLE_LABEL_CLASSNAME: string;
	    QUESTION_TITLE_CHECKBOX_CLASSNAME: string;
	    QUESTION_SNIPPET_CLASSNAME: string;
	    QUESTION_SNIPPET_CONTAINER_CLASSNAME: string;
	    QUESTION_SNIPPET_HIDDEN_CLASSNAME: string;
	    SHADOW_CLASSNAME: string;
	    RAW_CONTENT_CLASSNAME: string;
	    SOURCE_CLASSNAME: string;
	    SOURCE_TITLE_CLASSNAME: string;
	    SOURCE_URL_CLASSNAME: string;
	};
	class SmartSnippetCollapsibleSuggestion {
	    constructor(options: {
	         questionAnswer: IRelatedQuestionAnswerResponse;
	         bindings: IComponentBindings;
	         innerCSS: string;
	         searchUid: string;
	         titleField: IFieldOption;
	         hrefTemplate?: string;
	         alwaysOpenInNewWindow?: boolean;
	         source?: IQueryResult;
	         useIFrame?: boolean;
	    });
	     loading: Promise<void>;
	    build(): HTMLLIElement;
	}

}
declare module Coveo {
	const SmartSnippetSuggestionsClassNames: {
	    HAS_QUESTIONS_CLASSNAME: string;
	    QUESTIONS_LIST_CLASSNAME: string;
	    QUESTIONS_LIST_TITLE_CLASSNAME: string;
	};
	interface ISmartSnippetSuggestionsOptions {
	    titleField: IFieldOption;
	    hrefTemplate?: string;
	    alwaysOpenInNewWindow?: boolean;
	    useIFrame?: boolean;
	}
	/**
	 * The SmartSnippetSuggestions component displays additional queries for which a Coveo Smart Snippets model can provide relevant excerpts.
	 */
	class SmartSnippetSuggestions extends Component {
	    element: HTMLElement;
	    options: ISmartSnippetSuggestionsOptions;
	    static ID: string;
	    static doExport: () => void;
	    /**
	     * The options for the SmartSnippetSuggestions
	     * @componentOptions
	     */
	    static options: ISmartSnippetSuggestionsOptions;
	    constructor(element: HTMLElement, options?: ISmartSnippetSuggestionsOptions, bindings?: IComponentBindings);
	     loading: Promise<SmartSnippetCollapsibleSuggestion[]>;
	    /**
	     * @warning This method only works for the demo. In practice, the source of the answer will not always be part of the results.
	     */
	}

}
declare module Coveo {
	function lazyAdvancedSearch(): void;

}
declare module Coveo {
	function lazyAggregate(): void;

}
declare module Coveo {
	function lazyAnalyticsSuggestions(): void;

}
declare module Coveo {
	function lazyAuthenticationProvider(): void;

}
declare module Coveo {
	function lazyBackdrop(): void;

}
declare module Coveo {
	function lazyBadge(): void;

}
declare module Coveo {
	function lazyBreadcrumb(): void;

}
declare module Coveo {
	function lazyCardActionBar(): void;

}
declare module Coveo {
	function lazyCardOverlay(): void;

}
declare module Coveo {
	function lazyChatterLikedBy(): void;

}
declare module Coveo {
	function lazyChatterPostAttachment(): void;

}
declare module Coveo {
	function lazyChatterPostedBy(): void;

}
declare module Coveo {
	function lazyChatterTopic(): void;

}
declare module Coveo {
	function lazyDebug(): void;

}
declare module Coveo {
	function lazyDidYouMean(): void;

}
declare module Coveo {
	function lazyDistanceResources(): void;

}
declare module Coveo {
	function lazyErrorReport(): void;

}
declare module Coveo {
	function lazyExcerpt(): void;

}
declare module Coveo {
	function lazyExportToExcel(): void;

}
declare module Coveo {
	function lazyFacet(): void;

}
declare module Coveo {
	function lazyFacetRange(): void;

}
declare module Coveo {
	function lazyFacetSlider(): void;

}
declare module Coveo {
	function lazyFieldSuggestions(): void;

}
declare module Coveo {
	function lazyFacetValueSuggestions(): void;

}
declare module Coveo {
	function lazyFieldTable(): void;

}
declare module Coveo {
	function lazyFieldValue(): void;

}
declare module Coveo {
	function lazyFolding(): void;

}
declare module Coveo {
	function lazyFoldingForThread(): void;

}
declare module Coveo {
	function lazyHiddenQuery(): void;

}
declare module Coveo {
	function lazyCategoryFacet(): void;

}
declare module Coveo {
	function lazyHierarchicalFacet(): void;

}
declare module Coveo {
	function lazyIcon(): void;

}
declare module Coveo {
	function lazyLogo(): void;

}
declare module Coveo {
	function lazyMatrix(): void;

}
declare module Coveo {
	function lazyOmnibox(): void;

}
declare module Coveo {
	function lazyOmniboxResultList(): void;

}
declare module Coveo {
	function lazyPager(): void;

}
declare module Coveo {
	function lazyPipelineContext(): void;

}
declare module Coveo {
	function lazyPreferencesPanel(): void;

}
declare module Coveo {
	function lazyPrintableUri(): void;

}
declare module Coveo {
	function lazyQuerybox(): void;

}
declare module Coveo {
	function lazyQueryDuration(): void;

}
declare module Coveo {
	function lazyQuerySummary(): void;

}
declare module Coveo {
	function lazyQuickview(): void;

}
declare module Coveo {
	function lazyRecommendation(): void;

}
declare module Coveo {
	function lazyResultActionsMenu(): void;

}
declare module Coveo {
	function lazyResultAttachment(): void;

}
declare module Coveo {
	function lazyResultFolding(): void;

}
declare module Coveo {
	function lazyResultLayoutSelector(): void;

}
declare module Coveo {
	function lazyResultLink(): void;

}
declare module Coveo {
	function lazyResultList(): void;

}
declare module Coveo {
	function lazyResultRating(): void;

}
declare module Coveo {
	function lazyStarRating(): void;

}
declare module Coveo {
	function lazyResultsFiltersPreferences(): void;

}
declare module Coveo {
	function lazyResultsPerPage(): void;

}
declare module Coveo {
	function lazyResultsPreferences(): void;

}
declare module Coveo {
	function lazyResultTagging(): void;

}
declare module Coveo {
	function lazyFollowItem(): void;

}
declare module Coveo {
	function lazySearchAlerts(): void;

}
declare module Coveo {
	function lazySearchbox(): void;

}
declare module Coveo {
	function lazySearchButton(): void;

}
declare module Coveo {
	function lazySettings(): void;

}
declare module Coveo {
	function lazyShareQuery(): void;

}
declare module Coveo {
	function lazySort(): void;

}
declare module Coveo {
	function lazyTab(): void;

}
declare module Coveo {
	function lazyTemplateLoader(): void;

}
declare module Coveo {
	function lazyText(): void;

}
declare module Coveo {
	function lazyThumbnail(): void;

}
declare module Coveo {
	function lazyTriggers(): void;

}
declare module Coveo {
	function lazyYouTubeThumbnail(): void;

}
declare module Coveo {
	function lazyCheckbox(): void;

}
declare module Coveo {
	function lazyDatePicker(): void;

}
declare module Coveo {
	function lazyDropdown(): void;

}
declare module Coveo {
	function lazyFormGroup(): void;

}
declare module Coveo {
	function lazyMultiSelect(): void;

}
declare module Coveo {
	function lazyNumericSpinner(): void;

}
declare module Coveo {
	function lazyRadioButton(): void;

}
declare module Coveo {
	function lazyTextInput(): void;

}
declare module Coveo {
	function lazySimpleFilter(): void;

}
declare module Coveo {
	function lazyTimespanFacet(): void;

}
declare module Coveo {
	function lazyPromotedResultsBadge(): void;

}
declare module Coveo {
	function lazyDynamicHierarchicalFacet(): void;

}
declare module Coveo {
	function lazyDynamicFacet(): void;

}
declare module Coveo {
	function lazyDynamicFacetRange(): void;

}
declare module Coveo {
	function lazyDynamicFacetManager(): void;

}
declare module Coveo {
	function lazyMissingTerms(): void;

}
declare module Coveo {
	function lazyImageFieldValue(): void;

}
declare module Coveo {
	function lazyQuerySuggestPreview(): void;

}
declare module Coveo {
	function lazyCommerceQuery(): void;

}
declare module Coveo {
	function lazySortDropdown(): void;

}
declare module Coveo {
	function lazySmartSnippet(): void;

}
declare module Coveo {
	function lazySmartSnippetSuggestions(): void;

}
declare module Coveo {
	function lazyFacetsMobileMode(): void;

}
declare module Coveo {
	interface IAPIAnalyticsFacetSelection {
	    entryName: string;
	    status: string;
	}

}
declare module Coveo {
	interface IAPIAnalyticsFacet {
	    name: string;
	    fieldName: string;
	    sort: string;
	    mode: string;
	    selections: IAPIAnalyticsFacetSelection[];
	}

}
declare module Coveo {
	class NoopComponent extends Component {
	    static ID: string;
	    constructor(element: HTMLElement, options: any, bindings: IComponentBindings);
	}

}
declare module Coveo {
	function actionButton(text: string, callback: () => any): HTMLElement;

}
declare module Coveo {
	 class ResultLayout extends ResultLayoutSelector { }
}
declare module "coveo-search-ui" {
	export = Coveo;
}