// Type definitions for Underscore 1.8
// Project: http://underscorejs.org/
// Definitions by: Boris Yankov <https://github.com/borisyankov>, Josh Baldwin <https://github.com/jbaldwin>, Christopher Currens <https://github.com/ccurrens>
// Definitions: https://github.com/DefinitelyTyped/DefinitelyTyped

declare var _: _.UnderscoreStatic;



declare module _ {
    /**
    * underscore.js _.throttle options.
    **/
    interface ThrottleSettings {

        /**
        * If you'd like to disable the leading-edge call, pass this as false.
        **/
        leading?: boolean;

        /**
        * If you'd like to disable the execution on the trailing-edge, pass false.
        **/
        trailing?: boolean;
    }

    /**
    * underscore.js template settings, set templateSettings or pass as an argument
    * to 'template()' to override defaults.
    **/
    interface TemplateSettings {
        /**
        * Default value is '/<%([\s\S]+?)%>/g'.
        **/
        evaluate?: RegExp;

        /**
        * Default value is '/<%=([\s\S]+?)%>/g'.
        **/
        interpolate?: RegExp;

        /**
        * Default value is '/<%-([\s\S]+?)%>/g'.
        **/
        escape?: RegExp;

        /**
        * By default, 'template()' places the values from your data in the local scope via the 'with' statement.
        * However, you can specify a single variable name with this setting.
        **/
        variable?: string;
    }

    interface Collection<T> { }

    // Common interface between Arrays and jQuery objects
    interface List<T> extends Collection<T> {
        [index: number]: T;
        length: number;
    }

    interface Dictionary<T> extends Collection<T> {
        [index: string]: T;
    }

    interface ListIterator<T, TResult> {
        (value: T, index: number, list: List<T>): TResult;
    }

    interface ObjectIterator<T, TResult> {
        (element: T, key: string, list: Dictionary<T>): TResult;
    }

    type IterateePropertyShorthand = string | number;

    type IterateeMatcherShorthand<T> = Dictionary<T>;

    interface MemoIterator<T, TResult> {
        (prev: TResult, curr: T, index: number, list: List<T>): TResult;
    }

    interface MemoObjectIterator<T, TResult> {
        (prev: TResult, curr: T, key: string, list: Dictionary<T>): TResult;
    }

    interface Cancelable {
        cancel(): void;
    }

    interface UnderscoreStatic {
        /**
        * Underscore OOP Wrapper, all Underscore functions that take an object
        * as the first parameter can be invoked through this function.
        * @param key First argument to Underscore object functions.
        **/
        <T>(value: _.Dictionary<T>): Underscore<T>;
        <T>(value: Array<T>): Underscore<T>;
        <T>(value: T): Underscore<T>;

        /* *************
        * Collections *
        ************* */

        /**
        * Iterates over a list of elements, yielding each in turn to an iterator function. The iterator is
        * bound to the context object, if one is passed. Each invocation of iterator is called with three
        * arguments: (element, index, list). If list is a JavaScript object, iterator's arguments will be
        * (value, key, object). Delegates to the native forEach function if it exists.
        * @param list Iterates over this list of elements.
        * @param iterator Iterator function for each element `list`.
        * @param context 'this' object in `iterator`, optional.
        **/
        each<T>(
            list: _.List<T>,
            iterator: _.ListIterator<T, void>,
            context?: any): _.List<T>;

        /**
        * @see _.each
        * @param object Iterates over properties of this object.
        * @param iterator Iterator function for each property on `object`.
        * @param context 'this' object in `iterator`, optional.
        **/
        each<T>(
            object: _.Dictionary<T>,
            iterator: _.ObjectIterator<T, void>,
            context?: any): _.Dictionary<T>;

        /**
        * @see _.each
        **/
        forEach<T>(
            list: _.List<T>,
            iterator: _.ListIterator<T, void>,
            context?: any): _.List<T>;

        /**
        * @see _.each
        **/
        forEach<T>(
            object: _.Dictionary<T>,
            iterator: _.ObjectIterator<T, void>,
            context?: any): _.Dictionary<T>;

        /**
        * Produces a new array of values by mapping each value in list through a transformation function
        * (iterator). If the native map method exists, it will be used instead. If list is a JavaScript
        * object, iterator's arguments will be (value, key, object).
        * @param list Maps the elements of this array.
        * @param iterator Map iterator function for each element in `list`.
        * @param context `this` object in `iterator`, optional.
        * @return The mapped array result.
        **/
        map<T, TResult>(
            list: _.List<T>,
            iterator: _.ListIterator<T, TResult>,
            context?: any): TResult[];

        map<T>(
            list: _.List<T>,
            iterator: _.IterateePropertyShorthand,
            context?: any): T[];

        map<T>(
            list: _.List<T>,
            iterator: _.IterateeMatcherShorthand<any>,
            context?: any): boolean[];

        /**
        * @see _.map
        * @param object Maps the properties of this object.
        * @param iterator Map iterator function for each property on `object`.
        * @param context `this` object in `iterator`, optional.
        * @return The mapped object result.
        **/
        map<T, TResult>(
            object: _.Dictionary<T>,
            iterator: _.ObjectIterator<T, TResult>,
            context?: any): TResult[];

        /**
        * @see _.map
        **/
        collect: typeof _.map;

        /**
        * Also known as inject and foldl, reduce boils down a list of values into a single value.
        * Memo is the initial state of the reduction, and each successive step of it should be
        * returned by iterator. The iterator is passed four arguments: the memo, then the value
        * and index (or key) of the iteration, and finally a reference to the entire list.
        * @param list Reduces the elements of this array.
        * @param iterator Reduce iterator function for each element in `list`.
        * @param memo Initial reduce state.
        * @param context `this` object in `iterator`, optional.
        * @return Reduced object result.
        **/
        reduce<T, TResult>(
            list: _.List<T>,
            iterator: _.MemoIterator<T, TResult>,
            memo?: TResult,
            context?: any): TResult;

        reduce<T, TResult>(
            list: _.Dictionary<T>,
            iterator: _.MemoObjectIterator<T, TResult>,
            memo?: TResult,
            context?: any): TResult;

        /**
        * @see _.reduce
        **/
        inject<T, TResult>(
            list: _.List<T>,
            iterator: _.MemoIterator<T, TResult>,
            memo?: TResult,
            context?: any): TResult;

        inject<T, TResult>(
            list: _.Dictionary<T>,
            iterator: _.MemoObjectIterator<T, TResult>,
            memo?: TResult,
            context?: any): TResult;

        /**
        * @see _.reduce
        **/
        foldl<T, TResult>(
            list: _.Collection<T>,
            iterator: _.MemoIterator<T, TResult>,
            memo?: TResult,
            context?: any): TResult;

        /**
        * The right-associative version of reduce. Delegates to the JavaScript 1.8 version of
        * reduceRight, if it exists. `foldr` is not as useful in JavaScript as it would be in a
        * language with lazy evaluation.
        * @param list Reduces the elements of this array.
        * @param iterator Reduce iterator function for each element in `list`.
        * @param memo Initial reduce state.
        * @param context `this` object in `iterator`, optional.
        * @return Reduced object result.
        **/
        reduceRight<T, TResult>(
            list: _.Collection<T>,
            iterator: _.MemoIterator<T, TResult>,
            memo?: TResult,
            context?: any): TResult;

        /**
        * @see _.reduceRight
        **/
        foldr<T, TResult>(
            list: _.Collection<T>,
            iterator: _.MemoIterator<T, TResult>,
            memo?: TResult,
            context?: any): TResult;

        /**
        * Looks through each value in the list, returning the first one that passes a truth
        * test (iterator). The function returns as soon as it finds an acceptable element,
        * and doesn't traverse the entire list.
        * @param list Searches for a value in this list.
        * @param iterator Search iterator function for each element in `list`.
        * @param context `this` object in `iterator`, optional.
        * @return The first acceptable found element in `list`, if nothing is found any/null is returned.
        **/
        find<T>(
            list: _.List<T>,
            iterator: _.ListIterator<T, boolean>,
            context?: any): T | any;

        /**
        * @see _.find
        **/
        find<T>(
            object: _.Dictionary<T>,
            iterator: _.ObjectIterator<T, boolean>,
            context?: any): T | any;

        /**
        * @see _.find
        **/
        find<T, U extends {}>(
            object: _.List<T> | _.Dictionary<T>,
            iterator: U): T | any;

        /**
        * @see _.find
        **/
        find<T>(
            object: _.List<T> | _.Dictionary<T>,
            iterator: string): T | any;

        /**
        * @see _.find
        **/
        detect<T>(
            list: _.List<T>,
            iterator: _.ListIterator<T, boolean>,
            context?: any): T | any;

        /**
        * @see _.find
        **/
        detect<T>(
            object: _.Dictionary<T>,
            iterator: _.ObjectIterator<T, boolean>,
            context?: any): T | any;

        /**
        * @see _.find
        **/
        detect<T, U extends {}>(
            object: _.List<T> | _.Dictionary<T>,
            iterator: U): T | any;

        /**
        * @see _.find
        **/
        detect<T>(
            object: _.List<T> | _.Dictionary<T>,
            iterator: string): T | any;

        /**
        * Looks through each value in the list, returning an array of all the values that pass a truth
        * test (iterator). Delegates to the native filter method, if it exists.
        * @param list Filter elements out of this list.
        * @param iterator Filter iterator function for each element in `list`.
        * @param context `this` object in `iterator`, optional.
        * @return The filtered list of elements.
        **/
        filter<T>(
            list: _.List<T>,
            iterator: _.ListIterator<T, boolean>,
            context?: any): T[];

        /**
        * @see _.filter
        **/
        filter<T>(
            object: _.Dictionary<T>,
            iterator: _.ObjectIterator<T, boolean>,
            context?: any): T[];

        /**
        * @see _.filter
        **/
        select<T>(
            list: _.List<T>,
            iterator: _.ListIterator<T, boolean>,
            context?: any): T[];

        /**
        * @see _.filter
        **/
        select<T>(
            object: _.Dictionary<T>,
            iterator: _.ObjectIterator<T, boolean>,
            context?: any): T[];

        /**
        * Looks through each value in the list, returning an array of all the values that contain all
        * of the key-value pairs listed in properties.
        * @param list List to match elements again `properties`.
        * @param properties The properties to check for on each element within `list`.
        * @return The elements within `list` that contain the required `properties`.
        **/
        where<T, U extends {}>(
            list: _.List<T>,
            properties: U): T[];

        /**
        * Looks through the list and returns the first value that matches all of the key-value pairs listed in properties.
        * @param list Search through this list's elements for the first object with all `properties`.
        * @param properties Properties to look for on the elements within `list`.
        * @return The first element in `list` that has all `properties`.
        **/
        findWhere<T, U extends {}>(
            list: _.List<T>,
            properties: U): T | any;

        /**
        * Returns the values in list without the elements that the truth test (iterator) passes.
        * The opposite of filter.
        * Return all the elements for which a truth test fails.
        * @param list Reject elements within this list.
        * @param iterator Reject iterator function for each element in `list`.
        * @param context `this` object in `iterator`, optional.
        * @return The rejected list of elements.
        **/
        reject<T>(
            list: _.List<T>,
            iterator: _.ListIterator<T, boolean>,
            context?: any): T[];

        /**
        * @see _.reject
        **/
        reject<T>(
            object: _.Dictionary<T>,
            iterator: _.ObjectIterator<T, boolean>,
            context?: any): T[];

        /**
        * Returns true if all of the values in the list pass the iterator truth test. Delegates to the
        * native method every, if present.
        * @param list Truth test against all elements within this list.
        * @param iterator Trust test iterator function for each element in `list`.
        * @param context `this` object in `iterator`, optional.
        * @return True if all elements passed the truth test, otherwise false.
        **/
        every<T>(
            list: _.List<T>,
            iterator?: _.ListIterator<T, boolean>,
            context?: any): boolean;

        /**
        * @see _.every
        **/
        every<T>(
            list: _.Dictionary<T>,
            iterator?: _.ObjectIterator<T, boolean>,
            context?: any): boolean;

        /**
        * @see _.every
        **/
        all<T>(
            list: _.List<T>,
            iterator?: _.ListIterator<T, boolean>,
            context?: any): boolean;

        /**
        * @see _.every
        **/
        all<T>(
            list: _.Dictionary<T>,
            iterator?: _.ObjectIterator<T, boolean>,
            context?: any): boolean;

        /**
        * Returns true if any of the values in the list pass the iterator truth test. Short-circuits and
        * stops traversing the list if a true element is found. Delegates to the native method some, if present.
        * @param list Truth test against all elements within this list.
        * @param iterator Trust test iterator function for each element in `list`.
        * @param context `this` object in `iterator`, optional.
        * @return True if any elements passed the truth test, otherwise false.
        **/
        some<T>(
            list: _.List<T>,
            iterator?: _.ListIterator<T, boolean>,
            context?: any): boolean;

        /**
        * @see _.some
        **/
        some<T>(
            object: _.Dictionary<T>,
            iterator?: _.ObjectIterator<T, boolean>,
            context?: any): boolean;

        /**
        * @see _.some
        **/
        any<T>(
            list: _.List<T>,
            iterator?: _.ListIterator<T, boolean>,
            context?: any): boolean;

        /**
        * @see _.some
        **/
        any<T>(
            object: _.Dictionary<T>,
            iterator?: _.ObjectIterator<T, boolean>,
            context?: any): boolean;

        any<T>(
            list: _.List<T>,
            value: T): boolean;

        /**
        * Returns true if the value is present in the list. Uses indexOf internally,
        * if list is an Array.
        * @param list Checks each element to see if `value` is present.
        * @param value The value to check for within `list`.
        * @return True if `value` is present in `list`, otherwise false.
        **/
        contains<T>(
            list: _.List<T>,
            value: T,
            fromIndex?: number): boolean;

        /**
        * @see _.contains
        **/
        contains<T>(
            object: _.Dictionary<T>,
            value: T): boolean;

        /**
        * @see _.contains
        **/
        include<T>(
            list: _.Collection<T>,
            value: T,
            fromIndex?: number): boolean;

        /**
        * @see _.contains
        **/
        include<T>(
            object: _.Dictionary<T>,
            value: T): boolean;

        /**
        * @see _.contains
        **/
        includes<T>(
            list: _.Collection<T>,
            value: T,
            fromIndex?: number): boolean;

        /**
        * @see _.contains
        **/
        includes<T>(
            object: _.Dictionary<T>,
            value: T): boolean;

        /**
        * Calls the method named by methodName on each value in the list. Any extra arguments passed to
        * invoke will be forwarded on to the method invocation.
        * @param list The element's in this list will each have the method `methodName` invoked.
        * @param methodName The method's name to call on each element within `list`.
        * @param arguments Additional arguments to pass to the method `methodName`.
        **/
        invoke<T extends {}>(
            list: _.List<T>,
            methodName: string,
            ...args: any[]): any;

        /**
        * A convenient version of what is perhaps the most common use-case for map: extracting a list of
        * property values.
        * @param list The list to pluck elements out of that have the property `propertyName`.
        * @param propertyName The property to look for on each element within `list`.
        * @return The list of elements within `list` that have the property `propertyName`.
        **/
        pluck<T extends {}>(
            list: _.List<T>,
            propertyName: string): any[];

        /**
        * Returns the maximum value in list.
        * @param list Finds the maximum value in this list.
        * @return Maximum value in `list`.
        **/
        max(list: _.List<number>): number;

        /**
        * @see _.max
        */
        max(object: _.Dictionary<number>): number;

        /**
        * Returns the maximum value in list. If iterator is passed, it will be used on each value to generate
        * the criterion by which the value is ranked.
        * @param list Finds the maximum value in this list.
        * @param iterator Compares each element in `list` to find the maximum value.
        * @param context `this` object in `iterator`, optional.
        * @return The maximum element within `list`.
        **/
        max<T>(
            list: _.List<T>,
            iterator?: _.ListIterator<T, any>,
            context?: any): T;

        /**
        * @see _.max
        */
        max<T>(
            list: _.Dictionary<T>,
            iterator?: _.ObjectIterator<T, any>,
            context?: any): T;

        /**
        * Returns the minimum value in list.
        * @param list Finds the minimum value in this list.
        * @return Minimum value in `list`.
        **/
        min(list: _.List<number>): number;

        /**
         * @see _.min
         */
        min(o: _.Dictionary<number>): number;

        /**
        * Returns the minimum value in list. If iterator is passed, it will be used on each value to generate
        * the criterion by which the value is ranked.
        * @param list Finds the minimum value in this list.
        * @param iterator Compares each element in `list` to find the minimum value.
        * @param context `this` object in `iterator`, optional.
        * @return The minimum element within `list`.
        **/
        min<T>(
            list: _.List<T>,
            iterator?: _.ListIterator<T, any>,
            context?: any): T;

        /**
        * @see _.min
        */
        min<T>(
            list: _.Dictionary<T>,
            iterator?: _.ObjectIterator<T, any>,
            context?: any): T;

        /**
        * Returns a sorted copy of list, ranked in ascending order by the results of running each value
        * through iterator. Iterator may also be the string name of the property to sort by (eg. length).
        * @param list Sorts this list.
        * @param iterator Sort iterator for each element within `list`.
        * @param context `this` object in `iterator`, optional.
        * @return A sorted copy of `list`.
        **/
        sortBy<T, TSort>(
            list: _.List<T>,
            iterator?: _.ListIterator<T, TSort>,
            context?: any): T[];

        /**
        * @see _.sortBy
        * @param iterator Sort iterator for each element within `list`.
        **/
        sortBy<T>(
            list: _.List<T>,
            iterator: string,
            context?: any): T[];

        /**
        * Splits a collection into sets, grouped by the result of running each value through iterator.
        * If iterator is a string instead of a function, groups by the property named by iterator on
        * each of the values.
        * @param list Groups this list.
        * @param iterator Group iterator for each element within `list`, return the key to group the element by.
        * @param context `this` object in `iterator`, optional.
        * @return An object with the group names as properties where each property contains the grouped elements from `list`.
        **/
        groupBy<T>(
            list: _.List<T>,
            iterator?: _.ListIterator<T, any>,
            context?: any): _.Dictionary<T[]>;

        /**
        * @see _.groupBy
        * @param iterator Property on each object to group them by.
        **/
        groupBy<T>(
            list: _.List<T>,
            iterator: string,
            context?: any): _.Dictionary<T[]>;

        /**
        * Given a `list`, and an `iterator` function that returns a key for each element in the list (or a property name),
        * returns an object with an index of each item.  Just like _.groupBy, but for when you know your keys are unique.
        **/
        indexBy<T>(
            list: _.List<T>,
            iterator: _.ListIterator<T, any>,
            context?: any): _.Dictionary<T>;

        /**
        * @see _.indexBy
        * @param iterator Property on each object to index them by.
        **/
        indexBy<T>(
            list: _.List<T>,
            iterator: string,
            context?: any): _.Dictionary<T>;

        /**
        * Sorts a list into groups and returns a count for the number of objects in each group. Similar
        * to groupBy, but instead of returning a list of values, returns a count for the number of values
        * in that group.
        * @param list Group elements in this list and then count the number of elements in each group.
        * @param iterator Group iterator for each element within `list`, return the key to group the element by.
        * @param context `this` object in `iterator`, optional.
        * @return An object with the group names as properties where each property contains the number of elements in that group.
        **/
        countBy<T>(
            list: _.List<T>,
            iterator?: _.ListIterator<T, any>,
            context?: any): _.Dictionary<number>;

        /**
        * @see _.countBy
        * @param iterator Function name
        **/
        countBy<T>(
            list: _.List<T>,
            iterator: string,
            context?: any): _.Dictionary<number>;

        /**
        * Returns a shuffled copy of the list, using a version of the Fisher-Yates shuffle.
        * @param list List to shuffle.
        * @return Shuffled copy of `list`.
        **/
        shuffle<T>(list: _.Collection<T>): T[];

        /**
        * Produce a random sample from the `list`.  Pass a number to return `n` random elements from the list.  Otherwise a single random item will be returned.
        * @param list List to sample.
        * @return Random sample of `n` elements in `list`.
        **/
        sample<T>(list: _.Collection<T>, n: number): T[];

        /**
        * @see _.sample
        **/
        sample<T>(list: _.Collection<T>): T;

        /**
        * Converts the list (anything that can be iterated over), into a real Array. Useful for transmuting
        * the arguments object.
        * @param list object to transform into an array.
        * @return `list` as an array.
        **/
        toArray<T>(list: _.Collection<T>): T[];

        /**
        * Return the number of values in the list.
        * @param list Count the number of values/elements in this list.
        * @return Number of values in `list`.
        **/
        size<T>(list: _.Collection<T>): number;

        /**
        * Split array into two arrays:
        * one whose elements all satisfy predicate and one whose elements all do not satisfy predicate.
        * @param array Array to split in two.
        * @param iterator Filter iterator function for each element in `array`.
        * @param context `this` object in `iterator`, optional.
        * @return Array where Array[0] are the elements in `array` that satisfies the predicate, and Array[1] the elements that did not.
        **/
        partition<T>(
            array: Array<T>,
            iterator: _.ListIterator<T, boolean>,
            context?: any): T[][];

        /*********
        * Arrays *
        **********/

        /**
        * Returns the first element of an array. Passing n will return the first n elements of the array.
        * @param array Retrieves the first element of this array.
        * @return Returns the first element of `array`.
        **/
        first<T>(array: _.List<T>): T | any;

        /**
        * @see _.first
        * @param n Return more than one element from `array`.
        **/
        first<T>(
            array: _.List<T>,
            n: number): T[];

        /**
        * @see _.first
        **/
        head<T>(array: _.List<T>): T | any;

        /**
        * @see _.first
        **/
        head<T>(
            array: _.List<T>,
            n: number): T[];

        /**
        * @see _.first
        **/
        take<T>(array: _.List<T>): T;

        /**
        * @see _.first
        **/
        take<T>(
            array: _.List<T>,
            n: number): T[];

        /**
        * Returns everything but the last entry of the array. Especially useful on the arguments object.
        * Pass n to exclude the last n elements from the result.
        * @param array Retrieve all elements except the last `n`.
        * @param n Leaves this many elements behind, optional.
        * @return Returns everything but the last `n` elements of `array`.
        **/
        initial<T>(
            array: _.List<T>,
            n?: number): T[];

        /**
        * Returns the last element of an array. Passing n will return the last n elements of the array.
        * @param array Retrieves the last element of this array.
        * @return Returns the last element of `array`.
        **/
        last<T>(array: _.List<T>): T | any;

        /**
        * @see _.last
        * @param n Return more than one element from `array`.
        **/
        last<T>(
            array: _.List<T>,
            n: number): T[];

        /**
        * Returns the rest of the elements in an array. Pass an index to return the values of the array
        * from that index onward.
        * @param array The array to retrieve all but the first `index` elements.
        * @param n The index to start retrieving elements forward from, optional, default = 1.
        * @return Returns the elements of `array` from `index` to the end of `array`.
        **/
        rest<T>(
            array: _.List<T>,
            n?: number): T[];

        /**
        * @see _.rest
        **/
        tail<T>(
            array: _.List<T>,
            n?: number): T[];

        /**
        * @see _.rest
        **/
        drop<T>(
            array: _.List<T>,
            n?: number): T[];

        /**
        * Returns a copy of the array with all falsy values removed. In JavaScript, false, null, 0, "",
        * any and NaN are all falsy.
        * @param array Array to compact.
        * @return Copy of `array` without false values.
        **/
        compact<T>(array: _.List<T>): T[];

        /**
        * Flattens a nested array (the nesting can be to any depth). If you pass shallow, the array will
        * only be flattened a single level.
        * @param array The array to flatten.
        * @param shallow If true then only flatten one level, optional, default = false.
        * @return `array` flattened.
        **/
        flatten(
            array: _.List<any>,
            shallow?: boolean): any[];

        /**
        * Returns a copy of the array with all instances of the values removed.
        * @param array The array to remove `values` from.
        * @param values The values to remove from `array`.
        * @return Copy of `array` without `values`.
        **/
        without<T>(
            array: _.List<T>,
            ...values: T[]): T[];

        /**
        * Computes the union of the passed-in arrays: the list of unique items, in order, that are
        * present in one or more of the arrays.
        * @param arrays Array of arrays to compute the union of.
        * @return The union of elements within `arrays`.
        **/
        union<T>(...arrays: _.List<T>[]): T[];

        /**
        * Computes the list of values that are the intersection of all the arrays. Each value in the result
        * is present in each of the arrays.
        * @param arrays Array of arrays to compute the intersection of.
        * @return The intersection of elements within `arrays`.
        **/
        intersection<T>(...arrays: _.List<T>[]): T[];

        /**
        * Similar to without, but returns the values from array that are not present in the other arrays.
        * @param array Keeps values that are within `others`.
        * @param others The values to keep within `array`.
        * @return Copy of `array` with only `others` values.
        **/
        difference<T>(
            array: _.List<T>,
            ...others: _.List<T>[]): T[];

        /**
        * Produces a duplicate-free version of the array, using === to test object equality. If you know in
        * advance that the array is sorted, passing true for isSorted will run a much faster algorithm. If
        * you want to compute unique items based on a transformation, pass an iterator function.
        * @param array Array to remove duplicates from.
        * @param isSorted True if `array` is already sorted, optional, default = false.
        * @param iterator Transform the elements of `array` before comparisons for uniqueness.
        * @param context 'this' object in `iterator`, optional.
        * @return Copy of `array` where all elements are unique.
        **/
        uniq<T, TSort>(
            array: _.List<T>,
            isSorted?: boolean,
            iterator?: _.ListIterator<T, TSort> | _.IterateePropertyShorthand,
            context?: any): T[];

        /**
        * @see _.uniq
        **/
        uniq<T, TSort>(
            array: _.List<T>,
            iterator?: _.ListIterator<T, TSort>,
            context?: any): T[];

        /**
        * @see _.uniq
        **/
        unique<T, TSort>(
            array: _.List<T>,
            iterator?: _.ListIterator<T, TSort> | _.IterateePropertyShorthand,
            context?: any): T[];

        /**
        * @see _.uniq
        **/
        unique<T, TSort>(
            array: _.List<T>,
            isSorted?: boolean,
            iterator?: _.ListIterator<T, TSort>,
            context?: any): T[];


        /**
        * Merges together the values of each of the arrays with the values at the corresponding position.
        * Useful when you have separate data sources that are coordinated through matching array indexes.
        * If you're working with a matrix of nested arrays, zip.apply can transpose the matrix in a similar fashion.
        * @param arrays The arrays to merge/zip.
        * @return Zipped version of `arrays`.
        **/
        zip(...arrays: any[][]): any[][];

        /**
        * @see _.zip
        **/
        zip(...arrays: any[]): any[];

        /**
        * The opposite of zip. Given a number of arrays, returns a series of new arrays, the first
        * of which contains all of the first elements in the input arrays, the second of which
        * contains all of the second elements, and so on. Use with apply to pass in an array
        * of arrays
        * @param arrays The arrays to unzip.
        * @return Unzipped version of `arrays`.
        **/
        unzip(...arrays: any[][]): any[][];

        /**
        * Converts arrays into objects. Pass either a single list of [key, value] pairs, or a
        * list of keys, and a list of values.
        * @param keys Key array.
        * @param values Value array.
        * @return An object containing the `keys` as properties and `values` as the property values.
        **/
        object<TResult extends {}>(
            keys: _.List<string>,
            values: _.List<any>): TResult;

        /**
        * Converts arrays into objects. Pass either a single list of [key, value] pairs, or a
        * list of keys, and a list of values.
        * @param keyValuePairs Array of [key, value] pairs.
        * @return An object containing the `keys` as properties and `values` as the property values.
        **/
        object<TResult extends {}>(...keyValuePairs: any[][]): TResult;

        /**
        * @see _.object
        **/
        object<TResult extends {}>(
            list: _.List<any>,
            values?: any): TResult;

        /**
        * Returns the index at which value can be found in the array, or -1 if value is not present in the array.
        * Uses the native indexOf function unless it's missing. If you're working with a large array, and you know
        * that the array is already sorted, pass true for isSorted to use a faster binary search ... or, pass a number
        * as the third argument in order to look for the first matching value in the array after the given index.
        * @param array The array to search for the index of `value`.
        * @param value The value to search for within `array`.
        * @param isSorted True if the array is already sorted, optional, default = false.
        * @return The index of `value` within `array`.
        **/
        indexOf<T>(
            array: _.List<T>,
            value: T,
            isSorted?: boolean): number;

        /**
        * @see _indexof
        **/
        indexOf<T>(
            array: _.List<T>,
            value: T,
            startFrom: number): number;

        /**
        * Returns the index of the last occurrence of value in the array, or -1 if value is not present. Uses the
        * native lastIndexOf function if possible. Pass fromIndex to start your search at a given index.
        * @param array The array to search for the last index of `value`.
        * @param value The value to search for within `array`.
        * @param from The starting index for the search, optional.
        * @return The index of the last occurrence of `value` within `array`.
        **/
        lastIndexOf<T>(
            array: _.List<T>,
            value: T,
            from?: number): number;

        /**
        * Returns the first index of an element in `array` where the predicate truth test passes
        * @param array The array to search for the index of the first element where the predicate truth test passes.
        * @param predicate Predicate function.
        * @param context `this` object in `predicate`, optional.
        * @return Returns the index of an element in `array` where the predicate truth test passes or -1.`
        **/
        findIndex<T>(
            array: _.List<T>,
            predicate: _.ListIterator<T, boolean> | {},
            context?: any): number;

        /**
        * Returns the last index of an element in `array` where the predicate truth test passes
        * @param array The array to search for the index of the last element where the predicate truth test passes.
        * @param predicate Predicate function.
        * @param context `this` object in `predicate`, optional.
        * @return Returns the index of an element in `array` where the predicate truth test passes or -1.`
        **/
        findLastIndex<T>(
            array: _.List<T>,
            predicate: _.ListIterator<T, boolean> | {},
            context?: any): number;

        /**
        * Uses a binary search to determine the index at which the value should be inserted into the list in order
        * to maintain the list's sorted order. If an iterator is passed, it will be used to compute the sort ranking
        * of each value, including the value you pass.
        * @param list The sorted list.
        * @param value The value to determine its index within `list`.
        * @param iterator Iterator to compute the sort ranking of each value, optional.
        * @return The index where `value` should be inserted into `list`.
        **/
        sortedIndex<T, TSort>(
            list: _.List<T>,
            value: T,
            iterator?: (x: T) => TSort, context?: any): number;

        /**
        * A function to create flexibly-numbered lists of integers, handy for each and map loops. start, if omitted,
        * defaults to 0; step defaults to 1. Returns a list of integers from start to stop, incremented (or decremented)
        * by step, exclusive.
        * @param start Start here.
        * @param stop Stop here.
        * @param step The number to count up by each iteration, optional, default = 1.
        * @return Array of numbers from `start` to `stop` with increments of `step`.
        **/

        range(
            start: number,
            stop: number,
            step?: number): number[];

        /**
        * @see _.range
        * @param stop Stop here.
        * @return Array of numbers from 0 to `stop` with increments of 1.
        * @note If start is not specified the implementation will void pull the step (step = arguments[2] || 0)
        **/
        range(stop: number): number[];

        /**
        * Split an **array** into several arrays containing **count** or less elements
        * of initial array.
        * @param array The array to split
        * @param count The maximum size of the inner arrays.
        */
        chunk<T>(array: _.Collection<T>, count: number): (_.Collection<T>)[]

        /*************
         * Functions *
         *************/

        /**
        * Bind a function to an object, meaning that whevoid the function is called, the value of this will
        * be the object. Optionally, bind arguments to the function to pre-fill them, also known as partial application.
        * @param func The function to bind `this` to `object`.
        * @param context The `this` pointer whevoid `fn` is called.
        * @param arguments Additional arguments to pass to `fn` when called.
        * @return `fn` with `this` bound to `object`.
        **/
        bind(
            func: Function,
            context: any,
            ...args: any[]): () => any;

        /**
        * Binds a number of methods on the object, specified by methodNames, to be run in the context of that object
        * whevoid they are invoked. Very handy for binding functions that are going to be used as event handlers,
        * which would otherwise be invoked with a fairly useless this. If no methodNames are provided, all of the
        * object's function properties will be bound to it.
        * @param object The object to bind the methods `methodName` to.
        * @param methodNames The methods to bind to `object`, optional and if not provided all of `object`'s
        * methods are bound.
        **/
        bindAll(
            object: any,
            ...methodNames: string[]): any;

        /**
        * Partially apply a function by filling in any number of its arguments, without changing its dynamic this value.
        * A close cousin of bind.  You may pass _ in your list of arguments to specify an argument that should not be
        * pre-filled, but left open to supply at call-time.
        * @param fn Function to partially fill in arguments.
        * @param arguments The partial arguments.
        * @return `fn` with partially filled in arguments.
        **/

        partial<T1, T2>(
            fn: { (p1: T1): T2 },
            p1: T1
        ): { (): T2 };

        partial<T1, T2, T3>(
            fn: { (p1: T1, p2: T2): T3 },
            p1: T1
        ): { (p2: T2): T3 };

        partial<T1, T2, T3>(
            fn: { (p1: T1, p2: T2): T3 },
            p1: T1,
            p2: T2
        ): { (): T3 };

        partial<T1, T2, T3>(
            fn: { (p1: T1, p2: T2): T3 },
            stub1: UnderscoreStatic,
            p2: T2
        ): { (p1: T1): T3 };

        partial<T1, T2, T3, T4>(
            fn: { (p1: T1, p2: T2, p3: T3): T4 },
            p1: T1
        ): { (p2: T2, p3: T3): T4 };

        partial<T1, T2, T3, T4>(
            fn: { (p1: T1, p2: T2, p3: T3): T4 },
            p1: T1,
            p2: T2
        ): { (p3: T3): T4 };

        partial<T1, T2, T3, T4>(
            fn: { (p1: T1, p2: T2, p3: T3): T4 },
            stub1: UnderscoreStatic,
            p2: T2
        ): { (p1: T1, p3: T3): T4 };

        partial<T1, T2, T3, T4>(
            fn: { (p1: T1, p2: T2, p3: T3): T4 },
            p1: T1,
            p2: T2,
            p3: T3
        ): { (): T4 };

        partial<T1, T2, T3, T4>(
            fn: { (p1: T1, p2: T2, p3: T3): T4 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3
        ): { (p1: T1): T4 };

        partial<T1, T2, T3, T4>(
            fn: { (p1: T1, p2: T2, p3: T3): T4 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3
        ): { (p2: T2): T4 };

        partial<T1, T2, T3, T4>(
            fn: { (p1: T1, p2: T2, p3: T3): T4 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3
        ): { (p1: T1, p2: T2): T4 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            p1: T1
        ): { (p2: T2, p3: T3, p4: T4): T5 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            p1: T1,
            p2: T2
        ): { (p3: T3, p4: T4): T5 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            stub1: UnderscoreStatic,
            p2: T2
        ): { (p1: T1, p3: T3, p4: T4): T5 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            p1: T1,
            p2: T2,
            p3: T3
        ): { (p4: T4): T5 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3
        ): { (p1: T1, p4: T4): T5 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3
        ): { (p2: T2, p4: T4): T5 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3
        ): { (p1: T1, p2: T2, p4: T4): T5 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4
        ): { (): T5 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4
        ): { (p1: T1): T5 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4
        ): { (p2: T2): T5 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4
        ): { (p1: T1, p2: T2): T5 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p3: T3): T5 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p1: T1, p3: T3): T5 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p2: T2, p3: T3): T5 };

        partial<T1, T2, T3, T4, T5>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4): T5 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p1: T1, p2: T2, p3: T3): T5 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1
        ): { (p2: T2, p3: T3, p4: T4, p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            p2: T2
        ): { (p3: T3, p4: T4, p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            p2: T2
        ): { (p1: T1, p3: T3, p4: T4, p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            p2: T2,
            p3: T3
        ): { (p4: T4, p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3
        ): { (p1: T1, p4: T4, p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3
        ): { (p2: T2, p4: T4, p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3
        ): { (p1: T1, p2: T2, p4: T4, p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4
        ): { (p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4
        ): { (p1: T1, p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4
        ): { (p2: T2, p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4
        ): { (p1: T1, p2: T2, p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p3: T3, p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p1: T1, p3: T3, p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p2: T2, p3: T3, p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p1: T1, p2: T2, p3: T3, p5: T5): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4,
            p5: T5
        ): { (): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4,
            p5: T5
        ): { (p1: T1): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            p5: T5
        ): { (p2: T2): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            p5: T5
        ): { (p1: T1, p2: T2): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5
        ): { (p3: T3): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5
        ): { (p1: T1, p3: T3): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5
        ): { (p2: T2, p3: T3): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5
        ): { (p1: T1, p2: T2, p3: T3): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p4: T4): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p1: T1, p4: T4): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p2: T2, p4: T4): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p1: T1, p2: T2, p4: T4): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p3: T3, p4: T4): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p1: T1, p3: T3, p4: T4): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p2: T2, p3: T3, p4: T4): T6 };

        partial<T1, T2, T3, T4, T5, T6>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T6 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p1: T1, p2: T2, p3: T3, p4: T4): T6 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1
        ): { (p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2
        ): { (p3: T3, p4: T4, p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2
        ): { (p1: T1, p3: T3, p4: T4, p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            p3: T3
        ): { (p4: T4, p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3
        ): { (p1: T1, p4: T4, p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3
        ): { (p2: T2, p4: T4, p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3
        ): { (p1: T1, p2: T2, p4: T4, p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4
        ): { (p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4
        ): { (p1: T1, p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4
        ): { (p2: T2, p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4
        ): { (p1: T1, p2: T2, p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p3: T3, p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p1: T1, p3: T3, p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p2: T2, p3: T3, p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p1: T1, p2: T2, p3: T3, p5: T5, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4,
            p5: T5
        ): { (p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4,
            p5: T5
        ): { (p1: T1, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            p5: T5
        ): { (p2: T2, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            p5: T5
        ): { (p1: T1, p2: T2, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5
        ): { (p3: T3, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5
        ): { (p1: T1, p3: T3, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5
        ): { (p2: T2, p3: T3, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5
        ): { (p1: T1, p2: T2, p3: T3, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p4: T4, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p1: T1, p4: T4, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p2: T2, p4: T4, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p1: T1, p2: T2, p4: T4, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p3: T3, p4: T4, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p1: T1, p3: T3, p4: T4, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p2: T2, p3: T3, p4: T4, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p1: T1, p2: T2, p3: T3, p4: T4, p6: T6): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p1: T1): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p2: T2): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p1: T1, p2: T2): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p3: T3): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p1: T1, p3: T3): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p2: T2, p3: T3): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p1: T1, p2: T2, p3: T3): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p4: T4): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p1: T1, p4: T4): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p2: T2, p4: T4): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p1: T1, p2: T2, p4: T4): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p3: T3, p4: T4): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p1: T1, p3: T3, p4: T4): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p2: T2, p3: T3, p4: T4): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p1: T1, p2: T2, p3: T3, p4: T4): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p2: T2, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p2: T2, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p3: T3, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p3: T3, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p2: T2, p3: T3, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p2: T2, p3: T3, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p4: T4, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p4: T4, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p2: T2, p4: T4, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p2: T2, p4: T4, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p3: T3, p4: T4, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p3: T3, p4: T4, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p2: T2, p3: T3, p4: T4, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T7 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T7 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1
        ): { (p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2
        ): { (p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2
        ): { (p1: T1, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3
        ): { (p4: T4, p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3
        ): { (p1: T1, p4: T4, p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3
        ): { (p2: T2, p4: T4, p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3
        ): { (p1: T1, p2: T2, p4: T4, p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4
        ): { (p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4
        ): { (p1: T1, p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4
        ): { (p2: T2, p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4
        ): { (p1: T1, p2: T2, p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p3: T3, p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p1: T1, p3: T3, p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p2: T2, p3: T3, p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4
        ): { (p1: T1, p2: T2, p3: T3, p5: T5, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4,
            p5: T5
        ): { (p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4,
            p5: T5
        ): { (p1: T1, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            p5: T5
        ): { (p2: T2, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            p5: T5
        ): { (p1: T1, p2: T2, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5
        ): { (p3: T3, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5
        ): { (p1: T1, p3: T3, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5
        ): { (p2: T2, p3: T3, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5
        ): { (p1: T1, p2: T2, p3: T3, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p4: T4, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p1: T1, p4: T4, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p2: T2, p4: T4, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p1: T1, p2: T2, p4: T4, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p3: T3, p4: T4, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p1: T1, p3: T3, p4: T4, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p2: T2, p3: T3, p4: T4, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5
        ): { (p1: T1, p2: T2, p3: T3, p4: T4, p6: T6, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p1: T1, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p2: T2, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p1: T1, p2: T2, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p3: T3, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p1: T1, p3: T3, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p2: T2, p3: T3, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            p6: T6
        ): { (p1: T1, p2: T2, p3: T3, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p4: T4, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p1: T1, p4: T4, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p2: T2, p4: T4, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p1: T1, p2: T2, p4: T4, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p3: T3, p4: T4, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p1: T1, p3: T3, p4: T4, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p2: T2, p3: T3, p4: T4, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6
        ): { (p1: T1, p2: T2, p3: T3, p4: T4, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p2: T2, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p2: T2, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p3: T3, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p3: T3, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p2: T2, p3: T3, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p2: T2, p3: T3, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p4: T4, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p4: T4, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p2: T2, p4: T4, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p2: T2, p4: T4, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p3: T3, p4: T4, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p3: T3, p4: T4, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p2: T2, p3: T3, p4: T4, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6
        ): { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p7: T7): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p1: T1): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p2: T2): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p1: T1, p2: T2): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p3: T3): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p1: T1, p3: T3): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p2: T2, p3: T3): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p1: T1, p2: T2, p3: T3): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p4: T4): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p1: T1, p4: T4): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p2: T2, p4: T4): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p1: T1, p2: T2, p4: T4): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p3: T3, p4: T4): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p1: T1, p3: T3, p4: T4): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p2: T2, p3: T3, p4: T4): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            p6: T6,
            p7: T7
        ): { (p1: T1, p2: T2, p3: T3, p4: T4): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p1: T1, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p2: T2, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p1: T1, p2: T2, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p3: T3, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p1: T1, p3: T3, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p2: T2, p3: T3, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p1: T1, p2: T2, p3: T3, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p4: T4, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p1: T1, p4: T4, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p2: T2, p4: T4, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p1: T1, p2: T2, p4: T4, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p3: T3, p4: T4, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p1: T1, p3: T3, p4: T4, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p2: T2, p3: T3, p4: T4, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            p6: T6,
            p7: T7
        ): { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p2: T2, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p2: T2, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p3: T3, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p3: T3, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p2: T2, p3: T3, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p2: T2, p3: T3, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p4: T4, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p4: T4, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p2: T2, p4: T4, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p2: T2, p4: T4, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p3: T3, p4: T4, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p3: T3, p4: T4, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p2: T2, p3: T3, p4: T4, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            p5: T5,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p2: T2, p3: T3, p4: T4, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p2: T2, p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            p4: T4,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p2: T2, p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p3: T3, p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p3: T3, p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p2: T2, p3: T3, p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            p4: T4,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p2: T2, p3: T3, p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p4: T4, p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p4: T4, p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p2: T2, p4: T4, p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            p3: T3,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p2: T2, p4: T4, p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p3: T3, p4: T4, p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            p2: T2,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p3: T3, p4: T4, p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            p1: T1,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T8 };

        partial<T1, T2, T3, T4, T5, T6, T7, T8>(
            fn: { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6, p7: T7): T8 },
            stub1: UnderscoreStatic,
            stub2: UnderscoreStatic,
            stub3: UnderscoreStatic,
            stub4: UnderscoreStatic,
            stub5: UnderscoreStatic,
            stub6: UnderscoreStatic,
            p7: T7
        ): { (p1: T1, p2: T2, p3: T3, p4: T4, p5: T5, p6: T6): T8 };

        /**
        * Memoizes a given function by caching the computed result. Useful for speeding up slow-running computations.
        * If passed an optional hashFunction, it will be used to compute the hash key for storing the result, based
        * on the arguments to the original function. The default hashFunction just uses the first argument to the
        * memoized function as the key.
        * @param fn Computationally expensive function that will now memoized results.
        * @param hashFn Hash function for storing the result of `fn`.
        * @return Memoized version of `fn`.
        **/
        memoize(
            fn: Function,
            hashFn?: (...args: any[]) => string): Function;

        /**
        * Much like setTimeout, invokes function after wait milliseconds. If you pass the optional arguments,
        * they will be forwarded on to the function when it is invoked.
        * @param func Function to delay `waitMS` amount of ms.
        * @param wait The amount of milliseconds to delay `fn`.
        * @arguments Additional arguments to pass to `fn`.
        **/
        delay(
            func: Function,
            wait: number,
            ...args: any[]): any;

        /**
        * @see _delay
        **/
        delay(
            func: Function,
            ...args: any[]): any;

        /**
        * Defers invoking the function until the current call stack has cleared, similar to using setTimeout
        * with a delay of 0. Useful for performing expensive computations or HTML rendering in chunks without
        * blocking the UI thread from updating. If you pass the optional arguments, they will be forwarded on
        * to the function when it is invoked.
        * @param fn The function to defer.
        * @param arguments Additional arguments to pass to `fn`.
        **/
        defer(
            fn: Function,
            ...args: any[]): void;

        /**
        * Creates and returns a new, throttled version of the passed function, that, when invoked repeatedly,
        * will only actually call the original function at most once per every wait milliseconds. Useful for
        * rate-limiting events that occur faster than you can keep up with.
        * By default, throttle will execute the function as soon as you call it for the first time, and,
        * if you call it again any number of times during the wait period, as soon as that period is over.
        * If you'd like to disable the leading-edge call, pass {leading: false}, and if you'd like to disable
        * the execution on the trailing-edge, pass {trailing: false}.
        * @param func Function to throttle `waitMS` ms.
        * @param wait The number of milliseconds to wait before `fn` can be invoked again.
        * @param options Allows for disabling execution of the throttled function on either the leading or trailing edge.
        * @return `fn` with a throttle of `wait`.
        **/
        throttle<T extends Function>(
            func: T,
            wait: number,
            options?: _.ThrottleSettings): T & _.Cancelable;

        /**
        * Creates and returns a new debounced version of the passed function that will postpone its execution
        * until after wait milliseconds have elapsed since the last time it was invoked. Useful for implementing
        * behavior that should only happen after the input has stopped arriving. For example: rendering a preview
        * of a Markdown comment, recalculating a layout after the window has stopped being resized, and so on.
        *
        * Pass true for the immediate parameter to cause debounce to trigger the function on the leading instead
        * of the trailing edge of the wait interval. Useful in circumstances like preventing accidental double
        *-clicks on a "submit" button from firing a second time.
        * @param fn Function to debounce `waitMS` ms.
        * @param wait The number of milliseconds to wait before `fn` can be invoked again.
        * @param immediate True if `fn` should be invoked on the leading edge of `waitMS` instead of the trailing edge.
        * @return Debounced version of `fn` that waits `wait` ms when invoked.
        **/
        debounce<T extends Function>(
            fn: T,
            wait: number,
            immediate?: boolean): T & _.Cancelable;

        /**
        * Creates a version of the function that can only be called one time. Repeated calls to the modified
        * function will have no effect, returning the value from the original call. Useful for initialization
        * functions, instead of having to set a boolean flag and then check it later.
        * @param fn Function to only execute once.
        * @return Copy of `fn` that can only be invoked once.
        **/
        once<T extends Function>(fn: T): T;

        /**
        * Similar to ES6's rest param (http://ariya.ofilabs.com/2013/03/es6-and-rest-parameter.html)
        * This accumulates the arguments passed into an array, after a given index.
        **/
        restArgs(func: Function, starIndex?: number): Function;

        /**
        * Creates a version of the function that will only be run after first being called count times. Useful
        * for grouping asynchronous responses, where you want to be sure that all the async calls have finished,
        * before proceeding.
        * @param number count Number of times to be called before actually executing.
        * @param Function fn The function to defer execution `count` times.
        * @return Copy of `fn` that will not execute until it is invoked `count` times.
        **/
        after(
            count: number,
            fn: Function): Function;

        /**
        * Creates a version of the function that can be called no more than count times.  The result of
        * the last function call is memoized and returned when count has been reached.
        * @param number count  The maxmimum number of times the function can be called.
        * @param Function fn The function to limit the number of times it can be called.
        * @return Copy of `fn` that can only be called `count` times.
        **/
        before(
            count: number,
            fn: Function): Function;

        /**
        * Wraps the first function inside of the wrapper function, passing it as the first argument. This allows
        * the wrapper to execute code before and after the function runs, adjust the arguments, and execute it
        * conditionally.
        * @param fn Function to wrap.
        * @param wrapper The function that will wrap `fn`.
        * @return Wrapped version of `fn.
        **/
        wrap(
            fn: Function,
            wrapper: (fn: Function, ...args: any[]) => any): Function;

        /**
        * Returns a negated version of the pass-in predicate.
        * @param (...args: any[]) => boolean predicate
        * @return (...args: any[]) => boolean
        **/
        negate(predicate: (...args: any[]) => boolean): (...args: any[]) => boolean;

        /**
        * Returns the composition of a list of functions, where each function consumes the return value of the
        * function that follows. In math terms, composing the functions f(), g(), and h() produces f(g(h())).
        * @param functions List of functions to compose.
        * @return Composition of `functions`.
        **/
        compose(...functions: Function[]): Function;

        /**********
        * Objects *
        ***********/

        /**
        * Retrieve all the names of the object's properties.
        * @param object Retrieve the key or property names from this object.
        * @return List of all the property names on `object`.
        **/
        keys(object: any): string[];

        /**
        * Retrieve all the names of object's own and inherited properties.
        * @param object Retrieve the key or property names from this object.
        * @return List of all the property names on `object`.
        **/
        allKeys(object: any): string[];

        /**
        * Return all of the values of the object's properties.
        * @param object Retrieve the values of all the properties on this object.
        * @return List of all the values on `object`.
        **/
        values<T>(object: _.Dictionary<T>): T[];

        /**
        * Return all of the values of the object's properties.
        * @param object Retrieve the values of all the properties on this object.
        * @return List of all the values on `object`.
        **/
        values(object: any): any[];

        /**
         * Like map, but for objects. Transform the value of each property in turn.
         * @param object The object to transform
         * @param iteratee The function that transforms property values
         * @param context The optional context (value of `this`) to bind to
         * @return a new _.Dictionary of property values
         */
        mapObject<T, U>(object: _.Dictionary<T>, iteratee: (val: T, key: string, object: _.Dictionary<T>) => U, context?: any): _.Dictionary<U>;

        /**
         * Like map, but for objects. Transform the value of each property in turn.
         * @param object The object to transform
         * @param iteratee The function that tranforms property values
         * @param context The optional context (value of `this`) to bind to
         */
        mapObject<T>(object: any, iteratee: (val: any, key: string, object: any) => T, context?: any): _.Dictionary<T>;

        /**
         * Like map, but for objects. Retrieves a property from each entry in the object, as if by _.property
         * @param object The object to transform
         * @param iteratee The property name to retrieve
         * @param context The optional context (value of `this`) to bind to
         */
        mapObject(object: any, iteratee: string, context?: any): _.Dictionary<any>;

        /**
        * Convert an object into a list of [key, value] pairs.
        * @param object Convert this object to a list of [key, value] pairs.
        * @return List of [key, value] pairs on `object`.
        **/
        pairs(object: any): any[][];

        /**
        * Returns a copy of the object where the keys have become the values and the values the keys.
        * For this to work, all of your object's values should be unique and string serializable.
        * @param object Object to invert key/value pairs.
        * @return An inverted key/value paired version of `object`.
        **/
        invert(object: any): any;

        /**
        * Returns a sorted list of the names of every method in an object - that is to say,
        * the name of every function property of the object.
        * @param object Object to pluck all function property names from.
        * @return List of all the function names on `object`.
        **/
        functions(object: any): string[];

        /**
        * @see _functions
        **/
        methods(object: any): string[];

        /**
        * Copy all of the properties in the source objects over to the destination object, and return
        * the destination object. It's in-order, so the last source will override properties of the
        * same name in previous arguments.
        * @param destination Object to extend all the properties from `sources`.
        * @param sources Extends `destination` with all properties from these source objects.
        * @return `destination` extended with all the properties from the `sources` objects.
        **/
        extend(
            destination: any,
            ...sources: any[]): any;

        /**
        * Like extend, but only copies own properties over to the destination object. (alias: assign)
        */
        extendOwn(
            destination: any,
            ...source: any[]): any;

        /**
        * Like extend, but only copies own properties over to the destination object. (alias: extendOwn)
        */
        assign(
            destination: any,
            ...source: any[]): any;

        /**
        * Returns the first key on an object that passes a predicate test.
        * @param obj the object to search in
        * @param predicate Predicate function.
        * @param context `this` object in `iterator`, optional.
        */
        findKey<T>(obj: _.Dictionary<T>, predicate: _.ObjectIterator<T, boolean>, context?: any): string;

        /**
        * Return a copy of the object, filtered to only have values for the whitelisted keys
        * (or array of valid keys).
        * @param object Object to strip unwanted key/value pairs.
        * @keys The key/value pairs to keep on `object`.
        * @return Copy of `object` with only the `keys` properties.
        **/
        pick(
            object: any,
            ...keys: any[]): any;

        /**
        * @see _.pick
        **/
        pick(
            object: any,
            fn: (value: any, key: any, object: any) => any): any;

        /**
        * Return a copy of the object, filtered to omit the blacklisted keys (or array of keys).
        * @param object Object to strip unwanted key/value pairs.
        * @param keys The key/value pairs to remove on `object`.
        * @return Copy of `object` without the `keys` properties.
        **/
        omit(
            object: any,
            ...keys: string[]): any;

        /**
        * @see _.omit
        **/
        omit(
            object: any,
            keys: string[]): any;

        /**
        * @see _.omit
        **/
        omit(
            object: any,
            iteratee: Function): any;

        /**
        * Fill in null and any properties in object with values from the defaults objects,
        * and return the object. As soon as the property is filled, further defaults will have no effect.
        * @param object Fill this object with default values.
        * @param defaults The default values to add to `object`.
        * @return `object` with added `defaults` values.
        **/
        defaults(
            object: any,
            ...defaults: any[]): any;


        /**
        * Creates an object that inherits from the given prototype object.
        * If additional properties are provided then they will be added to the
        * created object.
        * @param prototype The prototype that the returned object will inherit from.
        * @param props Additional props added to the returned object.
        **/
        create(prototype: any, props?: Object): any;

        /**
        * Create a shallow-copied clone of the object.
        * Any nested objects or arrays will be copied by reference, not duplicated.
        * @param object Object to clone.
        * @return Copy of `object`.
        **/
        clone<T>(object: T): T;

        /**
        * Invokes interceptor with the object, and then returns object. The primary purpose of this method
        * is to "tap into" a method chain, in order to perform operations on intermediate results within the chain.
        * @param object Argument to `interceptor`.
        * @param intercepter The function to modify `object` before continuing the method chain.
        * @return Modified `object`.
        **/
        tap<T>(object: T, intercepter: Function): T;

        /**
        * Does the object contain the given key? Identical to object.hasOwnProperty(key), but uses a safe
        * reference to the hasOwnProperty function, in case it's been overridden accidentally.
        * @param object Object to check for `key`.
        * @param key The key to check for on `object`.
        * @return True if `key` is a property on `object`, otherwise false.
        **/
        has(object: any, key: string): boolean;

        /**
        * Returns a predicate function that will tell you if a passed in object contains all of the key/value properties present in attrs.
        * @param attrs Object with key values pair
        * @return Predicate function
        **/
        matches<T>(attrs: T): _.ListIterator<T, boolean>;

        /**
        * Returns a predicate function that will tell you if a passed in object contains all of the key/value properties present in attrs.
        * @see _.matches
        * @param attrs Object with key values pair
        * @return Predicate function
        **/
        matcher<T>(attrs: T): _.ListIterator<T, boolean>;

        /**
        * Returns a function that will itself return the key property of any passed-in object.
        * @param key Property of the object.
        * @return Function which accept an object an returns the value of key in that object.
        **/
        property(key: string): (object: Object) => any;

        /**
        * Returns a function that will itself return the value of a object key property.
        * @param key The object to get the property value from.
        * @return Function which accept a key property in `object` and returns its value.
        **/
        propertyOf(object: Object): (key: string) => any;

        /**
        * Performs an optimized deep comparison between the two objects,
        * to determine if they should be considered equal.
        * @param object Compare to `other`.
        * @param other Compare to `object`.
        * @return True if `object` is equal to `other`.
        **/
        isEqual(object: any, other: any): boolean;

        /**
        * Returns true if object contains no values.
        * @param object Check if this object has no properties or values.
        * @return True if `object` is empty.
        **/
        isEmpty(object: any): boolean;

        /**
        * Returns true if the keys and values in `properties` matches with the `object` properties.
        * @param object Object to be compared with `properties`.
        * @param properties Properties be compared with `object`
        * @return True if `object` has matching keys and values, otherwise false.
        **/
        isMatch(object: any, properties: any): boolean;

        /**
        * Returns true if object is a DOM element.
        * @param object Check if this object is a DOM element.
        * @return True if `object` is a DOM element, otherwise false.
        **/
        isElement(object: any): object is Element;

        /**
        * Returns true if object is an Array.
        * @param object Check if this object is an Array.
        * @return True if `object` is an Array, otherwise false.
        **/
        isArray(object: any): object is any[];

        /**
        * Returns true if object is an Array.
        * @param object Check if this object is an Array.
        * @return True if `object` is an Array, otherwise false.
        **/
        isArray<T>(object: any): object is T[];

        /**
         * Returns true if object is a Symbol.
         * @param object Check if this object is a Symbol.
         * @return True if `object` is a Symbol, otherwise false.
         **/
        isSymbol(object: any): object is symbol;

        /**
        * Returns true if value is an Object. Note that JavaScript arrays and functions are objects,
        * while (normal) strings and numbers are not.
        * @param object Check if this object is an Object.
        * @return True of `object` is an Object, otherwise false.
        **/
        isObject(object: any): boolean;

        /**
        * Returns true if object is an Arguments object.
        * @param object Check if this object is an Arguments object.
        * @return True if `object` is an Arguments object, otherwise false.
        **/
        isArguments(object: any): object is IArguments;

        /**
        * Returns true if object is a Function.
        * @param object Check if this object is a Function.
        * @return True if `object` is a Function, otherwise false.
        **/
        isFunction(object: any): object is Function;

        /**
        * Returns true if object inherits from an Error.
        * @param object Check if this object is an Error.
        * @return True if `object` is a Error, otherwise false.
        **/
        isError(object: any): object is Error;

        /**
        * Returns true if object is a String.
        * @param object Check if this object is a String.
        * @return True if `object` is a String, otherwise false.
        **/
        isString(object: any): object is string;

        /**
        * Returns true if object is a Number (including NaN).
        * @param object Check if this object is a Number.
        * @return True if `object` is a Number, otherwise false.
        **/
        isNumber(object: any): object is number;

        /**
        * Returns true if object is a finite Number.
        * @param object Check if this object is a finite Number.
        * @return True if `object` is a finite Number.
        **/
        isFinite(object: any): boolean;

        /**
        * Returns true if object is either true or false.
        * @param object Check if this object is a bool.
        * @return True if `object` is a bool, otherwise false.
        **/
        isBoolean(object: any): object is boolean;

        /**
        * Returns true if object is a Date.
        * @param object Check if this object is a Date.
        * @return True if `object` is a Date, otherwise false.
        **/
        isDate(object: any): object is Date;

        /**
        * Returns true if object is a RegExp.
        * @param object Check if this object is a RegExp.
        * @return True if `object` is a RegExp, otherwise false.
        **/
        isRegExp(object: any): object is RegExp;

        /**
        * Returns true if object is NaN.
        * Note: this is not the same as the native isNaN function,
        * which will also return true if the variable is any.
        * @param object Check if this object is NaN.
        * @return True if `object` is NaN, otherwise false.
        **/
        isNaN(object: any): boolean;

        /**
        * Returns true if the value of object is null.
        * @param object Check if this object is null.
        * @return True if `object` is null, otherwise false.
        **/
        isNull(object: any): boolean;

        /**
        * Returns true if value is any.
        * @param object Check if this object is any.
        * @return True if `object` is any, otherwise false.
        **/
        isUndefined(value: any): boolean;

        /* *********
        * Utility *
        ********** */

        /**
        * Give control of the "_" variable back to its previous owner.
        * Returns a reference to the Underscore object.
        * @return Underscore object reference.
        **/
        noConflict(): any;

        /**
        * Returns the same value that is used as the argument. In math: f(x) = x
        * This function looks useless, but is used throughout Underscore as a default iterator.
        * @param value Identity of this object.
        * @return `value`.
        **/
        identity<T>(value: T): T;

        /**
        * Creates a function that returns the same value that is used as the argument of _.constant
        * @param value Identity of this object.
        * @return Function that return value.
        **/
        constant<T>(value: T): () => T;

        /**
        * Returns any irrespective of the arguments passed to it.  Useful as the default
        * for optional callback arguments.
        * Note there is no way to indicate a 'any' return, so it is currently typed as void.
        * @return any
        **/
        noop(): void;

        /**
        * Invokes the given iterator function n times.
        * Each invocation of iterator is called with an index argument
        * @param n Number of times to invoke `iterator`.
        * @param iterator Function iterator to invoke `n` times.
        * @param context `this` object in `iterator`, optional.
        **/
        times<TResult>(n: number, iterator: (n: number) => TResult, context?: any): TResult[];

        /**
        * Returns a random integer between min and max, inclusive. If you only pass one argument,
        * it will return a number between 0 and that number.
        * @param max The maximum random number.
        * @return A random number between 0 and `max`.
        **/
        random(max: number): number;

        /**
        * @see _.random
        * @param min The minimum random number.
        * @return A random number between `min` and `max`.
        **/
        random(min: number, max: number): number;

        /**
        * Allows you to extend Underscore with your own utility functions. Pass a hash of
        * {name: function} definitions to have your functions added to the Underscore object,
        * as well as the OOP wrapper.
        * @param object Mixin object containing key/function pairs to add to the Underscore object.
        **/
        mixin(object: any): void;

        /**
        * A mostly-internal function to generate callbacks that can be applied to each element
        * in a collection, returning the desired result -- either identity, an arbitrary callback,
        * a property matcher, or a propetery accessor.
        * @param string|Function|Object value The value to iterate over, usually the key.
        * @param any context
        * @return Callback that can be applied to each element in a collection.
        **/
        iteratee(value: string): Function;
        iteratee(value: Function, context?: any): Function;
        iteratee(value: Object): Function;

        /**
        * Generate a globally-unique id for client-side models or DOM elements that need one.
        * If prefix is passed, the id will be appended to it. Without prefix, returns an integer.
        * @param prefix A prefix string to start the unique ID with.
        * @return Unique string ID beginning with `prefix`.
        **/
        uniqueId(prefix?: string): string;

        /**
        * Escapes a string for insertion into HTML, replacing &, <, >, ", ', and / characters.
        * @param str Raw string to escape.
        * @return `str` HTML escaped.
        **/
        escape(str: string): string;

        /**
        * The opposite of escape, replaces &amp;, &lt;, &gt;, &quot;, and &#x27; with their unescaped counterparts.
        * @param str HTML escaped string.
        * @return `str` Raw string.
        **/
        unescape(str: string): string;

        /**
        * If the value of the named property is a function then invoke it; otherwise, return it.
        * @param object Object to maybe invoke function `property` on.
        * @param property The function by name to invoke on `object`.
        * @param defaultValue The value to be returned in case `property` doesn't exist or is any.
        * @return The result of invoking the function `property` on `object.
        **/
        result(object: any, property: string, defaultValue?: any): any;

        /**
        * Compiles JavaScript templates into functions that can be evaluated for rendering. Useful
        * for rendering complicated bits of HTML from JSON data sources. Template functions can both
        * interpolate variables, using <%= ... %>, as well as execute arbitrary JavaScript code, with
        * <% ... %>. If you wish to interpolate a value, and have it be HTML-escaped, use <%- ... %> When
        * you evaluate a template function, pass in a data object that has properties corresponding to
        * the template's free variables. If you're writing a one-off, you can pass the data object as
        * the second parameter to template in order to render immediately instead of returning a template
        * function. The settings argument should be a hash containing any _.templateSettings that should
        * be overridden.
        * @param templateString Underscore HTML template.
        * @param data Data to use when compiling `templateString`.
        * @param settings Settings to use while compiling.
        * @return Returns the compiled Underscore HTML template.
        **/
        template(templateString: string, settings?: _.TemplateSettings): (...data: any[]) => string;

        /**
        * By default, Underscore uses ERB-style template delimiters, change the
        * following template settings to use alternative delimiters.
        **/
        templateSettings: _.TemplateSettings;

        /**
        * Returns an integer timestamp for the current time, using the fastest method available in the runtime. Useful for implementing timing/animation functions.
        **/
        now(): number;

        /* **********
        * Chaining *
        *********** */

        /**
        * Returns a wrapped object. Calling methods on this object will continue to return wrapped objects
        * until value() is used.
        * @param obj Object to chain.
        * @return Wrapped `obj`.
        **/
        chain<T>(obj: T[]): _Chain<T>;
        chain<T>(obj: _.Dictionary<T>): _Chain<T>;
        chain<T extends {}>(obj: T): _Chain<T>;
    }

    interface Underscore<T> {

        /* *************
        * Collections *
        ************* */

        /**
        * Wrapped type `any[]`.
        * @see _.each
        **/
        each(iterator: _.ListIterator<T, void>, context?: any): _.List<T>;

        /**
        * @see _.each
        **/
        each(iterator: _.ObjectIterator<T, void>, context?: any): _.List<T>;

        /**
        * @see _.each
        **/
        forEach(iterator: _.ListIterator<T, void>, context?: any): _.List<T>;

        /**
        * @see _.each
        **/
        forEach(iterator: _.ObjectIterator<T, void>, context?: any): _.List<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.map
        **/
        map<TResult>(iterator: _.ListIterator<T, TResult>, context?: any): TResult[];

        /**
        * Wrapped type `any[]`.
        * @see _.map
        **/
        map<TResult>(iterator: _.ObjectIterator<T, TResult>, context?: any): TResult[];

        /**
        * @see _.map
        **/
        collect<TResult>(iterator: _.ListIterator<T, TResult>, context?: any): TResult[];

        /**
        * @see _.map
        **/
        collect<TResult>(iterator: _.ObjectIterator<T, TResult>, context?: any): TResult[];

        /**
        * Wrapped type `any[]`.
        * @see _.reduce
        **/
        reduce<TResult>(iterator: _.MemoIterator<T, TResult>, memo?: TResult, context?: any): TResult;

        /**
        * @see _.reduce
        **/
        inject<TResult>(iterator: _.MemoIterator<T, TResult>, memo?: TResult, context?: any): TResult;

        /**
        * @see _.reduce
        **/
        foldl<TResult>(iterator: _.MemoIterator<T, TResult>, memo?: TResult, context?: any): TResult;

        /**
        * Wrapped type `any[]`.
        * @see _.reduceRight
        **/
        reduceRight<TResult>(iterator: _.MemoIterator<T, TResult>, memo?: TResult, context?: any): TResult;

        /**
        * @see _.reduceRight
        **/
        foldr<TResult>(iterator: _.MemoIterator<T, TResult>, memo?: TResult, context?: any): TResult;

        /**
        * Wrapped type `any[]`.
        * @see _.find
        **/
        find<T>(iterator: _.ListIterator<T, boolean> | _.ObjectIterator<T, boolean>, context?: any): T | any;

        /**
        * @see _.find
        **/
        find<T, U extends {}>(interator: U): T | any;

        /**
        * @see _.find
        **/
        find<T>(interator: string): T | any;

        /**
        * @see _.find
        **/
        detect<T>(iterator: _.ListIterator<T, boolean> | _.ObjectIterator<T, boolean>, context?: any): T | any;

        /**
        * @see _.find
        **/
        detect<T, U extends {}>(interator?: U): T | any;

        /**
        * @see _.find
        **/
        detect<T>(interator?: string): T | any;

        /**
        * Wrapped type `any[]`.
        * @see _.filter
        **/
        filter(iterator: _.ListIterator<T, boolean>, context?: any): T[];

        /**
        * @see _.filter
        **/
        select(iterator: _.ListIterator<T, boolean>, context?: any): T[];

        /**
        * Wrapped type `any[]`.
        * @see _.where
        **/
        where<U extends {}>(properties: U): T[];

        /**
        * Wrapped type `any[]`.
        * @see _.findWhere
        **/
        findWhere<U extends {}>(properties: U): T | any;

        /**
        * Wrapped type `any[]`.
        * @see _.reject
        **/
        reject(iterator: _.ListIterator<T, boolean>, context?: any): T[];

        /**
        * Wrapped type `any[]`.
        * @see _.all
        **/
        all(iterator?: _.ListIterator<T, boolean>, context?: any): boolean;

        /**
        * @see _.all
        **/
        every(iterator?: _.ListIterator<T, boolean>, context?: any): boolean;

        /**
        * Wrapped type `any[]`.
        * @see _.any
        **/
        any(iterator?: _.ListIterator<T, boolean>, context?: any): boolean;

        /**
        * @see _.any
        **/
        some(iterator?: _.ListIterator<T, boolean>, context?: any): boolean;

        /**
        * Wrapped type `any[]`.
        * @see _.contains
        **/
        contains(value: T, fromIndex?: number): boolean;

        /**
        * Alias for 'contains'.
        * @see contains
        **/
        include(value: T, fromIndex?: number): boolean;

        /**
         * Alias for 'contains'.
         * @see contains
         **/
        includes(value: T, fromIndex?: number): boolean;

        /**
        * Wrapped type `any[]`.
        * @see _.invoke
        **/
        invoke(methodName: string, ...args: any[]): any;

        /**
        * Wrapped type `any[]`.
        * @see _.pluck
        **/
        pluck(propertyName: string): any[];

        /**
        * Wrapped type `number[]`.
        * @see _.max
        **/
        max(): number;

        /**
        * Wrapped type `any[]`.
        * @see _.max
        **/
        max(iterator: _.ListIterator<T, number>, context?: any): T;

        /**
        * Wrapped type `any[]`.
        * @see _.max
        **/
        max(iterator?: _.ListIterator<T, any>, context?: any): T;

        /**
        * Wrapped type `number[]`.
        * @see _.min
        **/
        min(): number;

        /**
        * Wrapped type `any[]`.
        * @see _.min
        **/
        min(iterator: _.ListIterator<T, number>, context?: any): T;

        /**
        * Wrapped type `any[]`.
        * @see _.min
        **/
        min(iterator?: _.ListIterator<T, any>, context?: any): T;

        /**
        * Wrapped type `any[]`.
        * @see _.sortBy
        **/
        sortBy(iterator?: _.ListIterator<T, any>, context?: any): T[];

        /**
        * Wrapped type `any[]`.
        * @see _.sortBy
        **/
        sortBy(iterator: string, context?: any): T[];

        /**
        * Wrapped type `any[]`.
        * @see _.groupBy
        **/
        groupBy(iterator?: _.ListIterator<T, any>, context?: any): _.Dictionary<_.List<T>>;

        /**
        * Wrapped type `any[]`.
        * @see _.groupBy
        **/
        groupBy(iterator: string, context?: any): _.Dictionary<T[]>;

        /**
        * Wrapped type `any[]`.
        * @see _.indexBy
        **/
        indexBy(iterator: _.ListIterator<T, any>, context?: any): _.Dictionary<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.indexBy
        **/
        indexBy(iterator: string, context?: any): _.Dictionary<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.countBy
        **/
        countBy(iterator?: _.ListIterator<T, any>, context?: any): _.Dictionary<number>;

        /**
        * Wrapped type `any[]`.
        * @see _.countBy
        **/
        countBy(iterator: string, context?: any): _.Dictionary<number>;

        /**
        * Wrapped type `any[]`.
        * @see _.shuffle
        **/
        shuffle(): T[];

        /**
        * Wrapped type `any[]`.
        * @see _.sample
        **/
        sample<T>(n: number): T[];

        /**
        * @see _.sample
        **/
        sample<T>(): T;

        /**
        * Wrapped type `any`.
        * @see _.toArray
        **/
        toArray(): T[];

        /**
        * Wrapped type `any`.
        * @see _.size
        **/
        size(): number;

        /*********
        * Arrays *
        **********/

        /**
        * Wrapped type `any[]`.
        * @see _.first
        **/
        first(): T | any;

        /**
        * Wrapped type `any[]`.
        * @see _.first
        **/
        first(n: number): T[];

        /**
        * @see _.first
        **/
        head(): T | any;

        /**
        * @see _.first
        **/
        head(n: number): T[];

        /**
        * @see _.first
        **/
        take(): T;

        /**
        * @see _.first
        **/
        take(n: number): T[];

        /**
        * Wrapped type `any[]`.
        * @see _.initial
        **/
        initial(n?: number): T[];

        /**
        * Wrapped type `any[]`.
        * @see _.last
        **/
        last(): T | any;

        /**
        * Wrapped type `any[]`.
        * @see _.last
        **/
        last(n: number): T[];

        /**
        * Wrapped type `any[]`.
        * @see _.rest
        **/
        rest(n?: number): T[];

        /**
        * @see _.rest
        **/
        tail(n?: number): T[];

        /**
        * @see _.rest
        **/
        drop(n?: number): T[];

        /**
        * Wrapped type `any[]`.
        * @see _.compact
        **/
        compact(): T[];

        /**
        * Wrapped type `any`.
        * @see _.flatten
        **/
        flatten(shallow?: boolean): any[];

        /**
        * Wrapped type `any[]`.
        * @see _.without
        **/
        without(...values: T[]): T[];

        /**
        * Wrapped type `any[]`.
        * @see _.partition
        **/
        partition(iterator: _.ListIterator<T, boolean>, context?: any): T[][];

        /**
        * Wrapped type `any[][]`.
        * @see _.union
        **/
        union(...arrays: _.List<T>[]): T[];

        /**
        * Wrapped type `any[][]`.
        * @see _.intersection
        **/
        intersection(...arrays: _.List<T>[]): T[];

        /**
        * Wrapped type `any[]`.
        * @see _.difference
        **/
        difference(...others: _.List<T>[]): T[];

        /**
        * Wrapped type `any[]`.
        * @see _.uniq
        **/
        uniq(isSorted?: boolean, iterator?: _.ListIterator<T, any>): T[];

        /**
        * Wrapped type `any[]`.
        * @see _.uniq
        **/
        uniq<TSort>(iterator?: _.ListIterator<T, TSort>, context?: any): T[];

        /**
        * @see _.uniq
        **/
        unique<TSort>(isSorted?: boolean, iterator?: _.ListIterator<T, TSort>): T[];

        /**
        * @see _.uniq
        **/
        unique<TSort>(iterator?: _.ListIterator<T, TSort>, context?: any): T[];

        /**
        * Wrapped type `any[][]`.
        * @see _.zip
        **/
        zip(...arrays: any[][]): any[][];

        /**
        * Wrapped type `any[][]`.
        * @see _.unzip
        **/
        unzip(...arrays: any[][]): any[][];

        /**
        * Wrapped type `any[][]`.
        * @see _.object
        **/
        object(...keyValuePairs: any[][]): any;

        /**
        * @see _.object
        **/
        object(values?: any): any;

        /**
        * Wrapped type `any[]`.
        * @see _.indexOf
        **/
        indexOf(value: T, isSorted?: boolean): number;

        /**
        * @see _.indexOf
        **/
        indexOf(value: T, startFrom: number): number;

        /**
        * Wrapped type `any[]`.
        * @see _.lastIndexOf
        **/
        lastIndexOf(value: T, from?: number): number;

        /**
        * @see _.findIndex
        **/
        findIndex<T>(array: _.List<T>, predicate: _.ListIterator<T, boolean> | {}, context?: any): number;

        /**
        * @see _.findLastIndex
        **/
        findLastIndex<T>(array: _.List<T>, predicate: _.ListIterator<T, boolean> | {}, context?: any): number;

        /**
        * Wrapped type `any[]`.
        * @see _.sortedIndex
        **/
        sortedIndex(value: T, iterator?: (x: T) => any, context?: any): number;

        /**
        * Wrapped type `number`.
        * @see _.range
        **/
        range(stop: number, step?: number): number[];

        /**
        * Wrapped type `number`.
        * @see _.range
        **/
        range(): number[];

        /**
         * Wrapped type any[][].
         * @see _.chunk
         **/
        chunk(): any[][];

        /* ***********
        * Functions *
        ************ */

        /**
        * Wrapped type `Function`.
        * @see _.bind
        **/
        bind(object: any, ...args: any[]): Function;

        /**
        * Wrapped type `object`.
        * @see _.bindAll
        **/
        bindAll(...methodNames: string[]): any;

        /**
        * Wrapped type `Function`.
        * @see _.partial
        **/
        partial(...args: any[]): Function;

        /**
        * Wrapped type `Function`.
        * @see _.memoize
        **/
        memoize(hashFn?: (n: any) => string): Function;

        /**
        * Wrapped type `Function`.
        * @see _.defer
        **/
        defer(...args: any[]): void;

        /**
        * Wrapped type `Function`.
        * @see _.delay
        **/
        delay(wait: number, ...args: any[]): any;

        /**
        * @see _.delay
        **/
        delay(...args: any[]): any;

        /**
        * Wrapped type `Function`.
        * @see _.throttle
        **/
        throttle(wait: number, options?: _.ThrottleSettings): Function & _.Cancelable;

        /**
        * Wrapped type `Function`.
        * @see _.debounce
        **/
        debounce(wait: number, immediate?: boolean): Function & _.Cancelable;

        /**
        * Wrapped type `Function`.
        * @see _.once
        **/
        once(): Function;

        /**
        * Wrapped type `Function`.
        * @see _.once
        **/
        restArgs(starIndex?: number): Function;

        /**
        * Wrapped type `number`.
        * @see _.after
        **/
        after(fn: Function): Function;

        /**
        * Wrapped type `number`.
        * @see _.before
        **/
        before(fn: Function): Function;

        /**
        * Wrapped type `Function`.
        * @see _.wrap
        **/
        wrap(wrapper: Function): () => Function;

        /**
        * Wrapped type `Function`.
        * @see _.negate
        **/
        negate(): (...args: any[]) => boolean;

        /**
        * Wrapped type `Function[]`.
        * @see _.compose
        **/
        compose(...functions: Function[]): Function;

        /********* *
         * Objects *
        ********** */

        /**
        * Wrapped type `object`.
        * @see _.keys
        **/
        keys(): string[];

        /**
        * Wrapped type `object`.
        * @see _.allKeys
        **/
        allKeys(): string[];

        /**
        * Wrapped type `object`.
        * @see _.values
        **/
        values(): T[];

        /**
        * Wrapped type `object`.
        * @see _.pairs
        **/
        pairs(): any[][];

        /**
        * Wrapped type `object`.
        * @see _.invert
        **/
        invert(): any;

        /**
        * Wrapped type `object`.
        * @see _.functions
        **/
        functions(): string[];

        /**
        * @see _.functions
        **/
        methods(): string[];

        /**
        * Wrapped type `object`.
        * @see _.extend
        **/
        extend(...sources: any[]): any;

        /**
        * Wrapped type `object`.
        * @see _.extend
        **/
        findKey(predicate: _.ObjectIterator<any, boolean>, context?: any): any

        /**
        * Wrapped type `object`.
        * @see _.pick
        **/
        pick(...keys: any[]): any;
        pick(keys: any[]): any;
        pick(fn: (value: any, key: any, object: any) => any): any;

        /**
        * Wrapped type `object`.
        * @see _.omit
        **/
        omit(...keys: string[]): any;
        omit(keys: string[]): any;
        omit(fn: Function): any;

        /**
        * Wrapped type `object`.
        * @see _.defaults
        **/
        defaults(...defaults: any[]): any;

        /**
        * Wrapped type `any`.
        * @see _.create
        **/
        create(props?: Object): any;

        /**
        * Wrapped type `any[]`.
        * @see _.clone
        **/
        clone(): T;

        /**
        * Wrapped type `object`.
        * @see _.tap
        **/
        tap(interceptor: (...as: any[]) => any): any;

        /**
        * Wrapped type `object`.
        * @see _.has
        **/
        has(key: string): boolean;

        /**
        * Wrapped type `any[]`.
        * @see _.matches
        **/
        matches(): _.ListIterator<T, boolean>;

        /**
         * Wrapped type `any[]`.
         * @see _.matcher
         **/
        matcher(): _.ListIterator<T, boolean>;

        /**
        * Wrapped type `string`.
        * @see _.property
        **/
        property(): (object: Object) => any;

        /**
        * Wrapped type `object`.
        * @see _.propertyOf
        **/
        propertyOf(): (key: string) => any;

        /**
        * Wrapped type `object`.
        * @see _.isEqual
        **/
        isEqual(other: any): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isEmpty
        **/
        isEmpty(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isMatch
        **/
        isMatch(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isElement
        **/
        isElement(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isArray
        **/
        isArray(): boolean;

        /**
         * Wrapped type `object`.
         * @see _.isSymbol
         **/
        isSymbol(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isObject
        **/
        isObject(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isArguments
        **/
        isArguments(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isFunction
        **/
        isFunction(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isError
        **/
        isError(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isString
        **/
        isString(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isNumber
        **/
        isNumber(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isFinite
        **/
        isFinite(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isBoolean
        **/
        isBoolean(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isDate
        **/
        isDate(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isRegExp
        **/
        isRegExp(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isNaN
        **/
        isNaN(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isNull
        **/
        isNull(): boolean;

        /**
        * Wrapped type `object`.
        * @see _.isUndefined
        **/
        isUndefined(): boolean;

        /********* *
         * Utility *
        ********** */

        /**
        * Wrapped type `any`.
        * @see _.identity
        **/
        identity(): any;

        /**
        * Wrapped type `any`.
        * @see _.constant
        **/
        constant(): () => T;

        /**
        * Wrapped type `any`.
        * @see _.noop
        **/
        noop(): void;

        /**
        * Wrapped type `number`.
        * @see _.times
        **/
        times<TResult>(iterator: (n: number) => TResult, context?: any): TResult[];

        /**
        * Wrapped type `number`.
        * @see _.random
        **/
        random(): number;
        /**
        * Wrapped type `number`.
        * @see _.random
        **/
        random(max: number): number;

        /**
        * Wrapped type `object`.
        * @see _.mixin
        **/
        mixin(): void;

        /**
        * Wrapped type `string|Function|Object`.
        * @see _.iteratee
        **/
        iteratee(context?: any): Function;

        /**
        * Wrapped type `string`.
        * @see _.uniqueId
        **/
        uniqueId(): string;

        /**
        * Wrapped type `string`.
        * @see _.escape
        **/
        escape(): string;

        /**
        * Wrapped type `string`.
        * @see _.unescape
        **/
        unescape(): string;

        /**
        * Wrapped type `object`.
        * @see _.result
        **/
        result(property: string, defaultValue?: any): any;

        /**
        * Wrapped type `string`.
        * @see _.template
        **/
        template(settings?: _.TemplateSettings): (...data: any[]) => string;

        /********** *
         * Chaining *
        *********** */

        /**
        * Wrapped type `any`.
        * @see _.chain
        **/
        chain(): _Chain<T>;

        /**
        * Wrapped type `any`.
        * Extracts the value of a wrapped object.
        * @return Value of the wrapped object.
        **/
        value<TResult>(): TResult;
    }

    interface _Chain<T> {

        /* *************
        * Collections *
        ************* */

        /**
        * Wrapped type `any[]`.
        * @see _.each
        **/
        each(iterator: _.ListIterator<T, void>, context?: any): _Chain<T>;

        /**
        * @see _.each
        **/
        each(iterator: _.ObjectIterator<T, void>, context?: any): _Chain<T>;

        /**
        * @see _.each
        **/
        forEach(iterator: _.ListIterator<T, void>, context?: any): _Chain<T>;

        /**
        * @see _.each
        **/
        forEach(iterator: _.ObjectIterator<T, void>, context?: any): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.map
        **/
        map<TArray>(iterator: _.ListIterator<T, TArray[]>, context?: any): _ChainOfArrays<TArray>;

        /**
        * Wrapped type `any[]`.
        * @see _.map
        **/
        map<TResult>(iterator: _.ListIterator<T, TResult>, context?: any): _Chain<TResult>;

        /**
        * Wrapped type `any[]`.
        * @see _.map
        **/
        map<TArray>(iterator: _.ObjectIterator<T, TArray[]>, context?: any): _ChainOfArrays<TArray>;

        /**
        * Wrapped type `any[]`.
        * @see _.map
        **/
        map<TResult>(iterator: _.ObjectIterator<T, TResult>, context?: any): _Chain<TResult>;

        /**
        * @see _.map
        **/
        collect<TResult>(iterator: _.ListIterator<T, TResult>, context?: any): _Chain<TResult>;

        /**
        * @see _.map
        **/
        collect<TResult>(iterator: _.ObjectIterator<T, TResult>, context?: any): _Chain<TResult>;

        /**
        * Wrapped type `any[]`.
        * @see _.reduce
        **/
        reduce<TResult>(iterator: _.MemoIterator<T, TResult>, memo?: TResult, context?: any): _ChainSingle<TResult>;

        /**
        * @see _.reduce
        **/
        inject<TResult>(iterator: _.MemoIterator<T, TResult>, memo?: TResult, context?: any): _ChainSingle<TResult>;

        /**
        * @see _.reduce
        **/
        foldl<TResult>(iterator: _.MemoIterator<T, TResult>, memo?: TResult, context?: any): _ChainSingle<TResult>;

        /**
        * Wrapped type `any[]`.
        * @see _.reduceRight
        **/
        reduceRight<TResult>(iterator: _.MemoIterator<T, TResult>, memo?: TResult, context?: any): _ChainSingle<TResult>;

        /**
        * @see _.reduceRight
        **/
        foldr<TResult>(iterator: _.MemoIterator<T, TResult>, memo?: TResult, context?: any): _ChainSingle<TResult>;

        /**
        * Wrapped type `any[]`.
        * @see _.find
        **/
        find<T>(iterator: _.ListIterator<T, boolean> | _.ObjectIterator<T, boolean>, context?: any): _ChainSingle<T | any>;

        /**
        * @see _.find
        **/
        find<T, U extends {}>(interator: U): _ChainSingle<T | any>;

        /**
        * @see _.find
        **/
        find<T>(interator: string): _ChainSingle<T | any>;

        /**
        * @see _.find
        **/
        detect<T>(iterator: _.ListIterator<T, boolean> | _.ObjectIterator<T, boolean>, context?: any): _ChainSingle<T | any>;

        /**
        * @see _.find
        **/
        detect<T, U extends {}>(interator: U): _ChainSingle<T | any>;

        /**
        * @see _.find
        **/
        detect<T>(interator: string): _ChainSingle<T | any>;

        /**
        * Wrapped type `any[]`.
        * @see _.filter
        **/
        filter(iterator: _.ListIterator<T, boolean>, context?: any): _Chain<T>;

        /**
        * @see _.filter
        **/
        select(iterator: _.ListIterator<T, boolean>, context?: any): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.where
        **/
        where<U extends {}>(properties: U): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.findWhere
        **/
        findWhere<U extends {}>(properties: U): _ChainSingle<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.reject
        **/
        reject(iterator: _.ListIterator<T, boolean>, context?: any): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.all
        **/
        all(iterator?: _.ListIterator<T, boolean>, context?: any): _ChainSingle<boolean>;

        /**
        * @see _.all
        **/
        every(iterator?: _.ListIterator<T, boolean>, context?: any): _ChainSingle<boolean>;

        /**
        * Wrapped type `any[]`.
        * @see _.any
        **/
        any(iterator?: _.ListIterator<T, boolean>, context?: any): _ChainSingle<boolean>;

        /**
        * @see _.any
        **/
        some(iterator?: _.ListIterator<T, boolean>, context?: any): _ChainSingle<boolean>;

        /**
        * Wrapped type `any[]`.
        * @see _.contains
        **/
        contains(value: T, fromIndex?: number): _ChainSingle<boolean>;

        /**
        * Alias for 'contains'.
        * @see contains
        **/
        include(value: T, fromIndex?: number): _ChainSingle<boolean>;

        /**
         * Alias for 'contains'.
         * @see contains
         **/
        includes(value: T, fromIndex?: number): _ChainSingle<boolean>;

        /**
        * Wrapped type `any[]`.
        * @see _.invoke
        **/
        invoke(methodName: string, ...args: any[]): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.pluck
        **/
        pluck(propertyName: string): _Chain<any>;

        /**
        * Wrapped type `number[]`.
        * @see _.max
        **/
        max(): _ChainSingle<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.max
        **/
        max(iterator: _.ListIterator<T, number>, context?: any): _ChainSingle<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.max
        **/
        max(iterator?: _.ListIterator<T, any>, context?: any): _ChainSingle<T>;

        /**
        * Wrapped type `number[]`.
        * @see _.min
        **/
        min(): _ChainSingle<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.min
        **/
        min(iterator: _.ListIterator<T, number>, context?: any): _ChainSingle<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.min
        **/
        min(iterator?: _.ListIterator<T, any>, context?: any): _ChainSingle<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.sortBy
        **/
        sortBy(iterator?: _.ListIterator<T, any>, context?: any): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.sortBy
        **/
        sortBy(iterator: string, context?: any): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.groupBy
        **/
        groupBy(iterator?: _.ListIterator<T, any>, context?: any): _ChainOfArrays<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.groupBy
        **/
        groupBy(iterator: string, context?: any): _ChainOfArrays<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.indexBy
        **/
        indexBy(iterator: _.ListIterator<T, any>, context?: any): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.indexBy
        **/
        indexBy(iterator: string, context?: any): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.countBy
        **/
        countBy(iterator?: _.ListIterator<T, any>, context?: any): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.countBy
        **/
        countBy(iterator: string, context?: any): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.shuffle
        **/
        shuffle(): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.sample
        **/
        sample<T>(n: number): _Chain<T>;

        /**
        * @see _.sample
        **/
        sample<T>(): _Chain<T>;

        /**
        * Wrapped type `any`.
        * @see _.toArray
        **/
        toArray(): _Chain<T>;

        /**
        * Wrapped type `any`.
        * @see _.size
        **/
        size(): _ChainSingle<number>;

        /*********
        * Arrays *
        **********/

        /**
        * Wrapped type `any[]`.
        * @see _.first
        **/
        first(): _ChainSingle<T | any>;

        /**
        * Wrapped type `any[]`.
        * @see _.first
        **/
        first(n: number): _Chain<T>;

        /**
        * @see _.first
        **/
        head(): _Chain<T>;

        /**
        * @see _.first
        **/
        head(n: number): _Chain<T>;

        /**
        * @see _.first
        **/
        take(): _Chain<T>;

        /**
        * @see _.first
        **/
        take(n: number): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.initial
        **/
        initial(n?: number): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.last
        **/
        last(): _ChainSingle<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.last
        **/
        last(n: number): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.rest
        **/
        rest(n?: number): _Chain<T>;

        /**
        * @see _.rest
        **/
        tail(n?: number): _Chain<T>;

        /**
        * @see _.rest
        **/
        drop(n?: number): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.compact
        **/
        compact(): _Chain<T>;

        /**
        * Wrapped type `any`.
        * @see _.flatten
        **/
        flatten(shallow?: boolean): _Chain<any>;

        /**
        * Wrapped type `any[]`.
        * @see _.without
        **/
        without(...values: T[]): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.partition
        **/
        partition(iterator: _.ListIterator<T, boolean>, context?: any): _Chain<T[]>;

        /**
        * Wrapped type `any[][]`.
        * @see _.union
        **/
        union(...arrays: _.List<T>[]): _Chain<T>;

        /**
        * Wrapped type `any[][]`.
        * @see _.intersection
        **/
        intersection(...arrays: _.List<T>[]): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.difference
        **/
        difference(...others: _.List<T>[]): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.uniq
        **/
        uniq(isSorted?: boolean, iterator?: _.ListIterator<T, any>): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.uniq
        **/
        uniq<TSort>(iterator?: _.ListIterator<T, TSort>, context?: any): _Chain<T>;

        /**
        * @see _.uniq
        **/
        unique<TSort>(isSorted?: boolean, iterator?: _.ListIterator<T, TSort>): _Chain<T>;

        /**
        * @see _.uniq
        **/
        unique<TSort>(iterator?: _.ListIterator<T, TSort>, context?: any): _Chain<T>;

        /**
        * Wrapped type `any[][]`.
        * @see _.zip
        **/
        zip(...arrays: any[][]): _Chain<T>;

        /**
        * Wrapped type `any[][]`.
        * @see _.unzip
        **/
        unzip(...arrays: any[][]): _Chain<T>;

        /**
        * Wrapped type `any[][]`.
        * @see _.object
        **/
        object(...keyValuePairs: any[][]): _Chain<T>;

        /**
        * @see _.object
        **/
        object(values?: any): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.indexOf
        **/
        indexOf(value: T, isSorted?: boolean): _ChainSingle<number>;

        /**
        * @see _.indexOf
        **/
        indexOf(value: T, startFrom: number): _ChainSingle<number>;

        /**
        * Wrapped type `any[]`.
        * @see _.lastIndexOf
        **/
        lastIndexOf(value: T, from?: number): _ChainSingle<number>;

        /**
        * @see _.findIndex
        **/
        findIndex<T>(predicate: _.ListIterator<T, boolean> | {}, context?: any): _ChainSingle<number>;

        /**
        * @see _.findLastIndex
        **/
        findLastIndex<T>(predicate: _.ListIterator<T, boolean> | {}, context?: any): _ChainSingle<number>;

        /**
        * Wrapped type `any[]`.
        * @see _.sortedIndex
        **/
        sortedIndex(value: T, iterator?: (x: T) => any, context?: any): _ChainSingle<number>;

        /**
        * Wrapped type `number`.
        * @see _.range
        **/
        range(stop: number, step?: number): _Chain<T>;

        /**
        * Wrapped type `number`.
        * @see _.range
        **/
        range(): _Chain<T>;

        /**
         * Wrapped type `any[][]`.
         * @see _.chunk
         **/
        chunk(): _Chain<T>;

        /* ***********
        * Functions *
        ************ */

        /**
        * Wrapped type `Function`.
        * @see _.bind
        **/
        bind(object: any, ...args: any[]): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.bindAll
        **/
        bindAll(...methodNames: string[]): _Chain<T>;

        /**
        * Wrapped type `Function`.
        * @see _.partial
        **/
        partial(...args: any[]): _Chain<T>;

        /**
        * Wrapped type `Function`.
        * @see _.memoize
        **/
        memoize(hashFn?: (n: any) => string): _Chain<T>;

        /**
        * Wrapped type `Function`.
        * @see _.defer
        **/
        defer(...args: any[]): _Chain<T>;

        /**
        * Wrapped type `Function`.
        * @see _.delay
        **/
        delay(wait: number, ...args: any[]): _Chain<T>;

        /**
        * @see _.delay
        **/
        delay(...args: any[]): _Chain<T>;

        /**
        * Wrapped type `Function`.
        * @see _.throttle
        **/
        throttle(wait: number, options?: _.ThrottleSettings): _Chain<T>;

        /**
        * Wrapped type `Function`.
        * @see _.debounce
        **/
        debounce(wait: number, immediate?: boolean): _Chain<T>;

        /**
        * Wrapped type `Function`.
        * @see _.once
        **/
        once(): _Chain<T>;

        /**
         * Wrapped type `Function`.
         * @see _.once
         **/
        restArgs(startIndex?: number): _Chain<T>;

        /**
        * Wrapped type `number`.
        * @see _.after
        **/
        after(func: Function): _Chain<T>;

        /**
        * Wrapped type `number`.
        * @see _.before
        **/
        before(fn: Function): _Chain<T>;

        /**
        * Wrapped type `Function`.
        * @see _.wrap
        **/
        wrap(wrapper: Function): () => _Chain<T>;

        /**
        * Wrapped type `Function`.
        * @see _.negate
        **/
        negate(): _Chain<T>;

        /**
        * Wrapped type `Function[]`.
        * @see _.compose
        **/
        compose(...functions: Function[]): _Chain<T>;

        /********* *
         * Objects *
        ********** */

        /**
        * Wrapped type `object`.
        * @see _.keys
        **/
        keys(): _Chain<string>;

        /**
        * Wrapped type `object`.
        * @see _.allKeys
        **/
        allKeys(): _Chain<string>;

        /**
        * Wrapped type `object`.
        * @see _.values
        **/
        values(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.pairs
        **/
        pairs(): _Chain<T[]>;

        /**
        * Wrapped type `object`.
        * @see _.invert
        **/
        invert(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.functions
        **/
        functions(): _Chain<T>;

        /**
        * @see _.functions
        **/
        methods(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.extend
        **/
        extend(...sources: any[]): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.extend
        **/
        findKey(predicate: _.ObjectIterator<any, boolean>, context?: any): _Chain<T>

        /**
        * Wrapped type `object`.
        * @see _.pick
        **/
        pick(...keys: any[]): _Chain<T>;
        pick(keys: any[]): _Chain<T>;
        pick(fn: (value: any, key: any, object: any) => any): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.omit
        **/
        omit(...keys: string[]): _Chain<T>;
        omit(keys: string[]): _Chain<T>;
        omit(iteratee: Function): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.defaults
        **/
        defaults(...defaults: any[]): _Chain<T>;

        /**
         * Wrapped type `any`.
         * @see _.create
         **/
        create(props?: Object): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.clone
        **/
        clone(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.tap
        **/
        tap(interceptor: (...as: any[]) => any): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.has
        **/
        has(key: string): _Chain<T>;

        /**
        * Wrapped type `any[]`.
        * @see _.matches
        **/
        matches(): _Chain<T>;

        /**
         * Wrapped type `any[]`.
         * @see _.matcher
         **/
        matcher(): _Chain<T>;

        /**
        * Wrapped type `string`.
        * @see _.property
        **/
        property(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.propertyOf
        **/
        propertyOf(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isEqual
        **/
        isEqual(other: any): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isEmpty
        **/
        isEmpty(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isMatch
        **/
        isMatch(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isElement
        **/
        isElement(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isArray
        **/
        isArray(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isSymbol
        **/
        isSymbol(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isObject
        **/
        isObject(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isArguments
        **/
        isArguments(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isFunction
        **/
        isFunction(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isError
        **/
        isError(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isString
        **/
        isString(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isNumber
        **/
        isNumber(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isFinite
        **/
        isFinite(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isBoolean
        **/
        isBoolean(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isDate
        **/
        isDate(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isRegExp
        **/
        isRegExp(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isNaN
        **/
        isNaN(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isNull
        **/
        isNull(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.isUndefined
        **/
        isUndefined(): _Chain<T>;

        /********* *
         * Utility *
        ********** */

        /**
        * Wrapped type `any`.
        * @see _.identity
        **/
        identity(): _Chain<T>;

        /**
        * Wrapped type `any`.
        * @see _.constant
        **/
        constant(): _Chain<T>;

        /**
        * Wrapped type `any`.
        * @see _.noop
        **/
        noop(): _Chain<T>;

        /**
        * Wrapped type `number`.
        * @see _.times
        **/
        times<TResult>(iterator: (n: number) => TResult, context?: any): _Chain<T>;

        /**
        * Wrapped type `number`.
        * @see _.random
        **/
        random(): _Chain<T>;
        /**
        * Wrapped type `number`.
        * @see _.random
        **/
        random(max: number): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.mixin
        **/
        mixin(): _Chain<T>;

        /**
        * Wrapped type `string|Function|Object`.
        * @see _.iteratee
        **/
        iteratee(context?: any): _Chain<T>;

        /**
        * Wrapped type `string`.
        * @see _.uniqueId
        **/
        uniqueId(): _Chain<T>;

        /**
        * Wrapped type `string`.
        * @see _.escape
        **/
        escape(): _Chain<T>;

        /**
        * Wrapped type `string`.
        * @see _.unescape
        **/
        unescape(): _Chain<T>;

        /**
        * Wrapped type `object`.
        * @see _.result
        **/
        result(property: string, defaultValue?: any): _Chain<T>;

        /**
        * Wrapped type `string`.
        * @see _.template
        **/
        template(settings?: _.TemplateSettings): (...data: any[]) => _Chain<T>;

        /************* *
        * Array proxy *
        ************** */

        /**
        * Returns a new array comprised of the array on which it is called
        * joined with the array(s) and/or value(s) provided as arguments.
        * @param arr Arrays and/or values to concatenate into a new array. See the discussion below for details.
        * @return A new array comprised of the array on which it is called
        **/
        concat(...arr: Array<T[]>): _Chain<T>;

        /**
        * Join all elements of an array into a string.
        * @param separator Optional. Specifies a string to separate each element of the array. The separator is converted to a string if necessary. If omitted, the array elements are separated with a comma.
        * @return The string conversions of all array elements joined into one string.
        **/
        join(separator?: any): _ChainSingle<T>;

        /**
        * Removes the last element from an array and returns that element.
        * @return Returns the popped element.
        **/
        pop(): _ChainSingle<T>;

        /**
        * Adds one or more elements to the end of an array and returns the new length of the array.
        * @param item The elements to add to the end of the array.
        * @return The array with the element added to the end.
        **/
        push(...item: Array<T>): _Chain<T>;

        /**
        * Reverses an array in place. The first array element becomes the last and the last becomes the first.
        * @return The reversed array.
        **/
        reverse(): _Chain<T>;

        /**
        * Removes the first element from an array and returns that element. This method changes the length of the array.
        * @return The shifted element.
        **/
        shift(): _ChainSingle<T>;

        /**
        * Returns a shallow copy of a portion of an array into a new array object.
        * @param start Zero-based index at which to begin extraction.
        * @param end Optional. Zero-based index at which to end extraction. slice extracts up to but not including end.
        * @return A shallow copy of a portion of an array into a new array object.
        **/
        slice(start: number, end?: number): _Chain<T>;

        /**
        * Sorts the elements of an array in place and returns the array. The sort is not necessarily stable. The default sort order is according to string Unicode code points.
        * @param compareFn Optional. Specifies a function that defines the sort order. If omitted, the array is sorted according to each character's Unicode code point value, according to the string conversion of each element.
        * @return The sorted array.
        **/
        sort(compareFn?: (a: T, b: T) => boolean): _Chain<T>;

        /**
        * Changes the content of an array by removing existing elements and/or adding new elements.
        * @param index Index at which to start changing the array. If greater than the length of the array, actual starting index will be set to the length of the array. If negative, will begin that many elements from the end.
        * @param quantity An integer indicating the number of old array elements to remove. If deleteCount is 0, no elements are removed. In this case, you should specify at least one new element. If deleteCount is greater than the number of elements left in the array starting at index, then all of the elements through the end of the array will be deleted.
        * @param items The element to add to the array. If you don't specify any elements, splice will only remove elements from the array.
        * @return An array containing the deleted elements. If only one element is removed, an array of one element is returned. If no elements are removed, an empty array is returned.
        **/
        splice(index: number, quantity: number, ...items: Array<T>): _Chain<T>;

        /**
        * A string representing the specified array and its elements.
        * @return A string representing the specified array and its elements.
        **/
        toString(): _ChainSingle<T>;

        /**
        * Adds one or more elements to the beginning of an array and returns the new length of the array.
        * @param items The elements to add to the front of the array.
        * @return The array with the element added to the beginning.
        **/
        unshift(...items: Array<T>): _Chain<T>;

        /********** *
         * Chaining *
        *********** */

        /**
        * Wrapped type `any`.
        * @see _.chain
        **/
        chain(): _Chain<T>;

        /**
        * Wrapped type `any`.
        * @see _.value
        **/
        value<TResult>(): T[];
    }
    interface _ChainSingle<T> {
        value(): T;
    }
    interface _ChainOfArrays<T> extends _Chain<T[]> {
        flatten(shallow?: boolean): _Chain<T>;
        mapObject(fn: _.ListIterator<T, any>): _ChainOfArrays<T>;
    }
}

// Type definitions for es6-promise
// Project: https://github.com/jakearchibald/ES6-Promise
// Definitions by: François de Campredon <https://github.com/fdecampredon/>, vvakame <https://github.com/vvakame>
// Definitions: https://github.com/borisyankov/DefinitelyTyped

interface Thenable<T> {
  then<U>(onFulfilled?: (value: T) => U | Thenable<U>, onRejected?: (error: any) => U | Thenable<U>): Thenable<U>;
  then<U>(onFulfilled?: (value: T) => U | Thenable<U>, onRejected?: (error: any) => void): Thenable<U>;
  catch<U>(onRejected?: (error: any) => U | Thenable<U>): Thenable<U>;
}

declare class Promise<T> implements Thenable<T> {
  /**
   * If you call resolve in the body of the callback passed to the constructor,
   * your promise is fulfilled with result object passed to resolve.
   * If you call reject your promise is rejected with the object passed to reject.
   * For consistency and debugging (eg stack traces), obj should be an instanceof Error.
   * Any errors thrown in the constructor callback will be implicitly passed to reject().
   */
  constructor(callback: (resolve: (value?: T | Thenable<T>) => void, reject: (error?: any) => void) => void);

  /**
   * onFulfilled is called when/if "promise" resolves. onRejected is called when/if "promise" rejects.
   * Both are optional, if either/both are omitted the next onFulfilled/onRejected in the chain is called.
   * Both callbacks have a single parameter , the fulfillment value or rejection reason.
   * "then" returns a new promise equivalent to the value you return from onFulfilled/onRejected after being passed through Promise.resolve.
   * If an error is thrown in the callback, the returned promise rejects with that error.
   *
   * @param onFulfilled called when/if "promise" resolves
   * @param onRejected called when/if "promise" rejects
   */
  then<U>(onFulfilled?: (value: T) => U | Thenable<U>, onRejected?: (error: any) => U | Thenable<U>): Promise<U>;
  then<U>(onFulfilled?: (value: T) => U | Thenable<U>, onRejected?: (error: any) => void): Promise<U>;

  /**
   * Sugar for promise.then(any, onRejected)
   *
   * @param onRejected called when/if "promise" rejects
   */
  catch<U>(onRejected?: (error: any) => U | Thenable<U>): Promise<U>;

  finally(always: ()=> any);

  done<U>(onFulfilled?: (value: T) => U | Thenable<U>, onRejected?: (error: any) => U | Thenable<U>): Promise<U>;

  fail<U>(onFulfilled?: (value: T) => U | Thenable<U>, onRejected?: (error: any) => U | Thenable<U>): Promise<U>;

}

declare module Promise {
  /**
   * Make a new promise from the thenable.
   * A thenable is promise-like in as far as it has a "then" method.
   */
  function resolve<T>(value?: T | Thenable<T>): Promise<T>;

  /**
   * Make a promise that rejects to obj. For consistency and debugging (eg stack traces), obj should be an instanceof Error
   */
  function reject(error: any): Promise<any>;

  /**
   * Make a promise that fulfills when every item in the array fulfills, and rejects if (and when) any item rejects.
   * the array passed to all can be a mixture of promise-like objects and other objects.
   * The fulfillment value is an array (in order) of fulfillment values. The rejection value is the first rejection value.
   */
  function all<T>(promises: (T | Thenable<T>)[]): Promise<T[]>;

  /**
   * Make a Promise that fulfills when any item fulfills, and rejects if any item rejects.
   */
  function race<T>(promises: (T | Thenable<T>)[]): Promise<T>;
}

declare module 'es6-promise' {
  var foo: typeof Promise; // Temp variable to reference Promise in local context
  module rsvp {
    var Promise: typeof foo;
  }
  
}


declare namespace Coveo.ModalBox {
  /**
   * The button to use when creating a ModalBox
   */
  enum BUTTON {
    OK = 1,
    APPLY = 2,
    YES = 4,
    NO = 8,
    CANCEL = 16
  }
  /**
   * Content of a ModalBox
   */
  interface ModalBox {
    /**
     * The modalBox container itself
     */
    modalBox: HTMLElement;
    /**
     * The overlay added on the body, which can be clicked to close the modalbox
     */
    overlay: HTMLElement;
    /**
     * The wrapper of the content
     */
    wrapper: HTMLElement;
    /**
     * The availables buttons (Ok, Apply, Cancel, etc.)
     */
    buttons: HTMLElement;
    /**
     * The content itself
     */
    content: HTMLElement;
    /**
     * The function that can be called to close the modal box. Note that this is also called by validation button such as APPLY, YES, etc.<br/>
     * Force close will close all open modalbox and skip the validation (if one was provided)
     * @param button
     * @param forceClose
     */
    close: (button?: BUTTON, forceClose?: boolean) => boolean;
    open: (content: HTMLElement, options?: Options) => ModalBox;
  }
  /**
   * Possible options when creating a ModalBox
   */
  interface Options {
    /**
     * Specify if you wish to open the modal box full screen. Default is `false`. If false, the modal box will fit the size of the content.
     */
    fullscreen?: boolean;
    /**
     * Specify that you wish the modal box to close when the user click on the title. Default is `false`.
     */
    titleClose?: boolean;
    /**
     * Specify if you wish to close the modal box when the overlay (black background) is clicked. Default is `false`.
     */
    overlayClose?: boolean;
    /**
     * Specify that you wish to add a prefix to the class name of the modal box container, to not clash with existing css in the page
     */
    className?: string;
    /**
     * The button you wish to create (Using {@link BUTTON} enum
     */
    buttons?: number;
    /**
     * Specify a validation function, which receives the button that was pressed.<br/>
     * If the validation function return true, the modal box closes, otherwise it stays open
     * @param button
     */
    validation?: (button: BUTTON) => boolean;
    /**
     * Specify the title of the modal box
     */
    title?: string | HTMLElement;
    /**
     * Specify the content that you wish to put inside the modal box
     */
    body?: HTMLElement;
    /**
     * The size for the modal box
     */
    sizeMod?: 'small' | 'normal' | 'big';
  }
  /**
   * Open a modal box with the given content
   * @param content The content to display, as an HTMLElement
   * @param options The {@link Options} to use for this modal box
   * @returns {{modalBox: (HTMLDivElement|HTMLElement), overlay: (HTMLDivElement|HTMLElement), wrapper: (HTMLDivElement|HTMLElement), buttons: HTMLElement, content: HTMLElement, close: (function(BUTTON=, boolean=): (boolean|boolean))}}
   */
  function open(content: HTMLElement, options?: Options): ModalBox;
  /**
   * Close all open modal box instance
   * @param forceClose Will skip validation
   */
  function close(forceClose?: boolean): void;
}

// Type definitions for d3JS v3.5.17
// Project: http://d3js.org/
// Definitions by: Alex Ford <https://github.com/gustavderdrache>, Boris Yankov <https://github.com/borisyankov>
// Definitions: https://github.com/DefinitelyTyped/DefinitelyTyped




declare namespace d3 {
    /**
     * The current version of D3.js.
     */
    var version: string;

    /**
     * Find the first element that matches the given selector string.
     */
    function select(selector: string): Selection<any>;

    /**
     * Create a selection from the given node reference.
     */
    function select(node: EventTarget): Selection<any>;

    /**
     * Find all elements that match the given selector string.
     */
    function selectAll(selector: string): Selection<any>;

    /**
     * Create a selection from the given list of nodes.
     */
    function selectAll(nodes: EventTarget[]): Selection<any>;

    /**
     * Returns the root selection (as if by d3.select(document.documentElement)). This function may be used for 'instanceof' tests, and extending its prototype will add properties to all selections.
     */
    function selection(): Selection<any>;

    namespace selection {
        var prototype: Selection<any>;

        /**
         * Selections are grouped into arrays of nodes, with the parent tracked in the 'parentNode' property.
         */
        interface Group extends Array<EventTarget> {
            parentNode: EventTarget;
        }

        interface Update<Datum> {
            /**
             * Retrieve a grouped selection.
             */
            [index: number]: Group;

            /**
             * The number of groups in this selection.
             */
            length: number;

            /**
             * Retrieve the value of the given attribute for the first node in the selection.
             *
             * @param name The attribute name to query. May be prefixed (see d3.ns.prefix).
             */
            attr(name: string): string;

            /**
             * For all nodes, set the attribute to the specified constant value. Use null to remove.
             *
             * @param name The attribute name, optionally prefixed.
             * @param value The attribute value to use. Note that this is coerced to a string automatically.
             */
            attr(name: string, value: Primitive): Update<Datum>;

            /**
             * Derive an attribute value for each node in the selection based on bound data.
             *
             * @param name The attribute name, optionally prefixed.
             * @param value The function of the datum (the bound data item), index (the position in the subgrouping), and outer index (overall position in nested selections) which computes the attribute value. If the function returns null, the attribute is removed.
             */
            attr(name: string, value: (datum: Datum, index: number, outerIndex: number) => Primitive): Update<Datum>;

            /**
             * Set multiple properties at once using an Object. D3 iterates over all enumerable properties and either sets or computes the attribute's value based on the corresponding entry in the Object.
             *
             * @param obj A key-value mapping corresponding to attributes and values. If the value is a simple string or number, it is taken as a constant. Otherwise, it is a function that derives the attribute value.
             */
            attr(obj: { [key: string]: Primitive | ((datum: Datum, index: number, outerIndex: number) => Primitive) }): Update<Datum>;

            /**
             * Returns true if the first node in this selection has the given class list. If multiple classes are specified (i.e., "foo bar"), then returns true only if all classes match.
             *
             * @param name The class list to query.
             */
            classed(name: string): boolean;

            /**
             * Adds (or removes) the given class list.
             *
             * @param name The class list to toggle. Spaces separate class names: "foo bar" is a list of two classes.
             * @param value If true, add the classes. If false, remove them.
             */
            classed(name: string, value: boolean): Update<Datum>;

            /**
             * Determine if the given class list should be toggled for each node in the selection.
             *
             * @param name The class list. Spaces separate multiple class names.
             * @param value The function to run for each node. Should return true to add the class to the node, or false to remove it.
             */
            classed(name: string, value: (datum: Datum, index: number, outerIndex: number) => boolean): Update<Datum>;

            /**
             * Set or derive classes for multiple class lists at once.
             *
             * @param obj An Object mapping class lists to values that are either plain booleans or functions that return booleans.
             */
            classed(obj: { [key: string]: boolean | ((datum: Datum, index: number, outerIndex: number) => boolean) }): Update<Datum>;

            /**
             * Retrieve the computed style value for the first node in the selection.
             * @param name The CSS property name to query
             */
            style(name: string): string;

            /**
             * Set a style property for all nodes in the selection.
             * @param name the CSS property name
             * @param value the property value
             * @param priority if specified, either null or the string "
             */
            style(name: string, value: Primitive, priority?: string): Update<Datum>;

            /**
             * Derive a property value for each node in the selection.
             * @param name the CSS property name
             * @param value the function to derive the value
             * @param priority if specified, either null or the string "
             */
            style(name: string, value: (datum: Datum, index: number, outerIndex: number) => Primitive, priority?: string): Update<Datum>;

            /**
             * Set a large number of CSS properties from an object.
             *
             * @param obj an Object whose keys correspond to CSS property names and values are either constants or functions that derive property values
             * @param priority if specified, either null or the string "
             */
            style(obj: { [key: string]: Primitive | ((datum: Datum, index: number, outerIndex: number) => Primitive) }, priority?: string): Update<Datum>;

            /**
             * Retrieve an arbitrary node property such as the 'checked' property of checkboxes, or the 'value' of text boxes.
             *
             * @param name the node's property to retrieve
             */
            property(name: string): any;

            /**
             * For each node, set the property value. Internally, this sets the node property directly (e.g., node[name] = value), so take care not to mutate special properties like __proto__.
             *
             * @param name the property name
             * @param value the property value
             */
            property(name: string, value: any): Update<Datum>;

            /**
             * For each node, derive the property value. Internally, this sets the node property directly (e.g., node[name] = value), so take care not to mutate special properties like __proto__.
             *
             * @param name the property name
             * @param value the function used to derive the property's value
             */
            property(name: string, value: (datum: Datum, index: number, outerIndex: number) => any): Update<Datum>;

            /**
             * Set multiple node properties. Caveats apply: take care not to mutate special properties like __proto__.
             *
             * @param obj an Object whose keys correspond to node properties and values are either constants or functions that will compute a value.
             */
            property(obj: { [key: string]: any | ((datum: Datum, index: number, outerIndex: number) => any) }): Update<Datum>;

            /**
             * Retrieve the textContent of the first node in the selection.
             */
            text(): string;

            /**
             * Set the textContent of each node in the selection.
             * @param value the text to use for all nodes
             */
            text(value: Primitive): Update<Datum>;

            /**
             * Compute the textContent of each node in the selection.
             * @param value the function which will compute the text
             */
            text(value: (datum: Datum, index: number, outerIndex: number) => Primitive): Update<Datum>;

            /**
             * Retrieve the HTML content of the first node in the selection. Uses 'innerHTML' internally and will not work with SVG or other elements without a polyfill.
             */
            html(): string;

            /**
             * Set the HTML content of every node in the selection. Uses 'innerHTML' internally and thus will not work with SVG or other elements without a polyfill.
             * @param value the HTML content to use.
             */
            html(value: string): Selection<Datum>;

            /**
             * Compute the HTML content for each node in the selection. Uses 'innerHTML' internally and thus will not work with SVG or other elements without a polyfill.
             * @param value the function to compute HTML content
             */
            html(value: (datum: Datum, index: number, outerIndex: number) => string): Selection<Datum>;

            /**
             * Appends a new child to each node in the selection. This child will inherit the parent's data (if available). Returns a fresh selection consisting of the newly-appended children.
             *
             * @param name the element name to append. May be prefixed (see d3.ns.prefix).
             */
            append(name: string): Selection<Datum>;

            /**
             * Appends a new child to each node in the selection by computing a new node. This child will inherit the parent's data (if available). Returns a fresh selection consisting of the newly-appended children.
             *
             * @param name the function to compute a new element
             */
            append(name: (datum: Datum, index: number, outerIndex: number) => EventTarget): Update<Datum>;

            /**
             * Inserts a new child to each node in the selection. This child will inherit its parent's data (if available). Returns a fresh selection consisting of the newly-inserted children.
             * @param name the element name to append. May be prefixed (see d3.ns.prefix).
             * @param before the selector to determine position (e.g., ":first-child")
             */
            insert(name: string, before: string): Update<Datum>;

            /**
             * Inserts a new child to each node in the selection. This child will inherit its parent's data (if available). Returns a fresh selection consisting of the newly-inserted children.
             * @param name the element name to append. May be prefixed (see d3.ns.prefix).
             * @param before a function to determine the node to use as the next sibling
             */
            insert(name: string, before: (datum: Datum, index: number, outerIndex: number) => EventTarget): Update<Datum>;

            /**
             * Inserts a new child to the end of each node in the selection by computing a new node. This child will inherit its parent's data (if available). Returns a fresh selection consisting of the newly-inserted children.
             * @param name the function to compute a new child
             * @param before the selector to determine position (e.g., ":first-child")
             */
            insert(name: (datum: Datum, index: number, outerIndex: number) => EventTarget, before: string): Update<Datum>;

            /**
             * Inserts a new child to the end of each node in the selection by computing a new node. This child will inherit its parent's data (if available). Returns a fresh selection consisting of the newly-inserted children.
             * @param name the function to compute a new child
             * @param before a function to determine the node to use as the next sibling
             */
            insert(name: (datum: Datum, index: number, outerIndex: number) => EventTarget, before: (datum: Datum, index: number, outerIndex: number) => EventTarget): Update<Datum>;

            /**
             * Removes the elements from the DOM. They are in a detached state and may be re-added (though there is currently no dedicated API for doing so).
             */
            remove(): Update<Datum>;

            /**
             * Retrieves the data bound to the first group in this selection.
             */
            data(): Datum[];

            /**
             * Binds data to this selection.
             * @param data the array of data to bind to this selection
             * @param key the optional function to determine the unique key for each piece of data. When unspecified, uses the index of the element.
             */
            data<NewDatum>(data: NewDatum[], key?: (datum: NewDatum, index: number, outerIndex: number) => string): Update<NewDatum>;

            /**
             * Derives data to bind to this selection.
             * @param data the function to derive data. Must return an array.
             * @param key the optional function to determine the unique key for each data item. When unspecified, uses the index of the element.
             */
            data<NewDatum>(data: (datum: Datum, index: number, outerIndex: number) => NewDatum[], key?: (datum: NewDatum, index: number, outerIndex: number) => string): Update<NewDatum>;

            /**
             * Filters the selection, returning only those nodes that match the given CSS selector.
             * @param selector the CSS selector
             */
            filter(selector: string): Update<Datum>;

            /**
             * Filters the selection, returning only those nodes for which the given function returned true.
             * @param selector the filter function
             */
            filter(selector: (datum: Datum, index: number, outerIndex: number) => boolean): Update<Datum>;

            /**
             * Return the data item bound to the first element in the selection.
             */
            datum(): Datum;

            /**
             * Derive the data item for each node in the selection. Useful for situations such as the HTML5 'dataset' attribute.
             * @param value the function to compute data for each node
             */
            datum<NewDatum>(value: (datum: Datum, index: number, outerIndex: number) => NewDatum): Update<NewDatum>;

            /**
             * Set the data item for each node in the selection.
             * @param value the constant element to use for each node
             */
            datum<NewDatum>(value: NewDatum): Update<NewDatum>;

            /**
             * Reorders nodes in the selection based on the given comparator. Nodes are re-inserted into the document once sorted.
             * @param comparator the comparison function, which defaults to d3.ascending
             */
            sort(comparator?: (a: Datum, b: Datum) => number): Update<Datum>;

            /**
             * Reorders nodes in the document to match the selection order. More efficient than calling sort() if the selection is already ordered.
             */
            order(): Update<Datum>;

            /**
             * Returns the listener (if any) for the given event.
             * @param type the type of event to load the listener for. May have a namespace (e.g., ".foo") at the end.
             */
            on(type: string): (datum: Datum, index: number, outerIndex: number) => any;

            /**
             * Adds a listener for the specified event. If one was already registered, it is removed before the new listener is added. The return value of the listener function is ignored.
             * @param type the of event to listen to. May have a namespace (e.g., ".foo") at the end.
             * @param listener an event listener function, or null to unregister
             * @param capture sets the DOM useCapture flag
             */
            on(type: string, listener: (datum: Datum, index: number, outerIndex: number) => any, capture?: boolean): Update<Datum>;

            /**
             * Begins a new transition. Interrupts any active transitions of the same name.
             * @param name the transition name (defaults to "")
             */
            transition(name?: string): Transition<Datum>;

            /**
             * Interrupts the active transition of the provided name. Does not cancel scheduled transitions.
             * @param name the transition name (defaults to "")
             */
            interrupt(name?: string): Update<Datum>;

            /**
             * Creates a subselection by finding the first descendent matching the selector string. Bound data is inherited.
             * @param selector the CSS selector to match against
             */
            select(selector: string): Update<Datum>;

            /**
             * Creates a subselection by using a function to find descendent elements. Bound data is inherited.
             * @param selector the function to find matching descendants
             */
            select(selector: (datum: Datum, index: number, outerIndex: number) => EventTarget): Update<Datum>;

            /**
             * Creates a subselection by finding all descendents that match the given selector. Bound data is not inherited.
             * @param selector the CSS selector to match against
             */
            selectAll(selector: string): Update<Datum>;

            /**
             * Creates a subselection by using a function to find descendent elements. Bound data is not inherited.
             * @param selector the function to find matching descendents
             */
            selectAll(selector: (datum: Datum, index: number, outerIndex: number) => Array<EventTarget> | NodeList): Update<any>;

            /**
             * Invoke the given function for each element in the selection. The return value of the function is ignored.
             * @param func the function to invoke
             */
            each(func: (datum: Datum, index: number, outerIndex: number) => any): Update<Datum>;

            /**
             * Call a function on the selection. sel.call(foo) is equivalent to foo(sel).
             * @param func the function to call on the selection
             * @param args any optional args
             */
            call(func: (sel: Update<Datum>, ...args: any[]) => any, ...args: any[]): Update<Datum>;

            /**
             * Returns true if the current selection is empty.
             */
            empty(): boolean;

            /**
             * Returns the first non-null element in the selection, or null otherwise.
             */
            node(): Node;

            /**
             * Returns the total number of elements in the selection.
             */
            size(): number;

            /**
             * Returns the placeholder nodes for each data element for which no corresponding DOM element was found.
             */
            enter(): Enter<Datum>;

            /**
             * Returns a selection for those DOM nodes for which no new data element was found.
             */
            exit(): Selection<Datum>;
        }

        interface Enter<Datum> {
            append(name: string): Selection<Datum>;
            append(name: (datum: Datum, index: number, outerIndex: number) => EventTarget): Selection<Datum>;

            insert(name: string, before?: string): Selection<Datum>;
            insert(name: string, before: (datum: Datum, index: number, outerIndex: number) => EventTarget): Selection<Datum>;
            insert(name: (datum: Datum, index: number, outerIndex: number) => EventTarget, before?: string): Selection<Datum>;
            insert(name: (datum: Datum, index: number, outerIndex: number) => EventTarget, before: (datum: Datum, index: number, outerIndex: number) => EventTarget): Selection<Datum>;

            select(name: (datum: Datum, index: number, outerIndex: number) => EventTarget): Selection<Datum>;
            call(func: (selection: Enter<Datum>, ...args: any[]) => any, ...args: any[]): Enter<Datum>;

            empty(): boolean;
            size(): number;
        }
    }

    /**
     * Administrivia: JavaScript primitive types, or "things that toString() predictably".
     */
    type Primitive = number | string | boolean;

    /**
     * Administrivia: anything with a valueOf(): number method is comparable, so we allow it in numeric operations
     */
    interface Numeric {
        valueOf(): number;
    }

    /**
     * A grouped array of nodes.
     * @param Datum the data bound to this selection.
     */
    interface Selection<Datum> {
        /**
         * Retrieve a grouped selection.
         */
        [index: number]: selection.Group;

        /**
         * The number of groups in this selection.
         */
        length: number;

        /**
         * Retrieve the value of the given attribute for the first node in the selection.
         *
         * @param name The attribute name to query. May be prefixed (see d3.ns.prefix).
         */
        attr(name: string): string;

        /**
         * For all nodes, set the attribute to the specified constant value. Use null to remove.
         *
         * @param name The attribute name, optionally prefixed.
         * @param value The attribute value to use. Note that this is coerced to a string automatically.
         */
        attr(name: string, value: Primitive): Selection<Datum>;

        /**
         * Derive an attribute value for each node in the selection based on bound data.
         *
         * @param name The attribute name, optionally prefixed.
         * @param value The function of the datum (the bound data item), index (the position in the subgrouping), and outer index (overall position in nested selections) which computes the attribute value. If the function returns null, the attribute is removed.
         */
        attr(name: string, value: (datum: Datum, index: number, outerIndex: number) => Primitive): Selection<Datum>;

        /**
         * Set multiple properties at once using an Object. D3 iterates over all enumerable properties and either sets or computes the attribute's value based on the corresponding entry in the Object.
         *
         * @param obj A key-value mapping corresponding to attributes and values. If the value is a simple string or number, it is taken as a constant. Otherwise, it is a function that derives the attribute value.
         */
        attr(obj: { [key: string]: Primitive | ((datum: Datum, index: number, outerIndex: number) => Primitive) }): Selection<Datum>;

        /**
         * Returns true if the first node in this selection has the given class list. If multiple classes are specified (i.e., "foo bar"), then returns true only if all classes match.
         *
         * @param name The class list to query.
         */
        classed(name: string): boolean;

        /**
         * Adds (or removes) the given class list.
         *
         * @param name The class list to toggle. Spaces separate class names: "foo bar" is a list of two classes.
         * @param value If true, add the classes. If false, remove them.
         */
        classed(name: string, value: boolean): Selection<Datum>;

        /**
         * Determine if the given class list should be toggled for each node in the selection.
         *
         * @param name The class list. Spaces separate multiple class names.
         * @param value The function to run for each node. Should return true to add the class to the node, or false to remove it.
         */
        classed(name: string, value: (datum: Datum, index: number, outerIndex: number) => boolean): Selection<Datum>;

        /**
         * Set or derive classes for multiple class lists at once.
         *
         * @param obj An Object mapping class lists to values that are either plain booleans or functions that return booleans.
         */
        classed(obj: { [key: string]: boolean | ((datum: Datum, index: number, outerIndex: number) => boolean) }): Selection<Datum>;

        /**
         * Retrieve the computed style value for the first node in the selection.
         * @param name The CSS property name to query
         */
        style(name: string): string;

        /**
         * Set a style property for all nodes in the selection.
         * @param name the CSS property name
         * @param value the property value
         * @param priority if specified, either null or the string "
         */
        style(name: string, value: Primitive, priority?: string): Selection<Datum>;

        /**
         * Derive a property value for each node in the selection.
         * @param name the CSS property name
         * @param value the function to derive the value
         * @param priority if specified, either null or the string "
         */
        style(name: string, value: (datum: Datum, index: number, outerIndex: number) => Primitive, priority?: string): Selection<Datum>;

        /**
         * Set a large number of CSS properties from an object.
         *
         * @param obj an Object whose keys correspond to CSS property names and values are either constants or functions that derive property values
         * @param priority if specified, either null or the string "
         */
        style(obj: { [key: string]: Primitive | ((datum: Datum, index: number, outerIndex: number) => Primitive) }, priority?: string): Selection<Datum>;

        /**
         * Retrieve an arbitrary node property such as the 'checked' property of checkboxes, or the 'value' of text boxes.
         *
         * @param name the node's property to retrieve
         */
        property(name: string): any;

        /**
         * For each node, set the property value. Internally, this sets the node property directly (e.g., node[name] = value), so take care not to mutate special properties like __proto__.
         *
         * @param name the property name
         * @param value the property value
         */
        property(name: string, value: any): Selection<Datum>;

        /**
         * For each node, derive the property value. Internally, this sets the node property directly (e.g., node[name] = value), so take care not to mutate special properties like __proto__.
         *
         * @param name the property name
         * @param value the function used to derive the property's value
         */
        property(name: string, value: (datum: Datum, index: number, outerIndex: number) => any): Selection<Datum>;

        /**
         * Set multiple node properties. Caveats apply: take care not to mutate special properties like __proto__.
         *
         * @param obj an Object whose keys correspond to node properties and values are either constants or functions that will compute a value.
         */
        property(obj: { [key: string]: any | ((datum: Datum, index: number, innerInder: number) => any) }): Selection<Datum>;

        /**
         * Retrieve the textContent of the first node in the selection.
         */
        text(): string;

        /**
         * Set the textContent of each node in the selection.
         * @param value the text to use for all nodes
         */
        text(value: Primitive): Selection<Datum>;

        /**
         * Compute the textContent of each node in the selection.
         * @param value the function which will compute the text
         */
        text(value: (datum: Datum, index: number, outerIndex: number) => Primitive): Selection<Datum>;

        /**
         * Retrieve the HTML content of the first node in the selection. Uses 'innerHTML' internally and will not work with SVG or other elements without a polyfill.
         */
        html(): string;

        /**
         * Set the HTML content of every node in the selection. Uses 'innerHTML' internally and thus will not work with SVG or other elements without a polyfill.
         * @param value the HTML content to use.
         */
        html(value: string): Selection<Datum>;

        /**
         * Compute the HTML content for each node in the selection. Uses 'innerHTML' internally and thus will not work with SVG or other elements without a polyfill.
         * @param value the function to compute HTML content
         */
        html(value: (datum: Datum, index: number, outerIndex: number) => string): Selection<Datum>;

        /**
         * Appends a new child to each node in the selection. This child will inherit the parent's data (if available). Returns a fresh selection consisting of the newly-appended children.
         *
         * @param name the element name to append. May be prefixed (see d3.ns.prefix).
         */
        append(name: string): Selection<Datum>;

        /**
         * Appends a new child to each node in the selection by computing a new node. This child will inherit the parent's data (if available). Returns a fresh selection consisting of the newly-appended children.
         *
         * @param name the function to compute a new element
         */
        append(name: (datum: Datum, index: number, outerIndex: number) => EventTarget): Selection<Datum>;

        /**
         * Inserts a new child to each node in the selection. This child will inherit its parent's data (if available). Returns a fresh selection consisting of the newly-inserted children.
         * @param name the element name to append. May be prefixed (see d3.ns.prefix).
         * @param before the selector to determine position (e.g., ":first-child")
         */
        insert(name: string, before: string): Selection<Datum>;

        /**
         * Inserts a new child to each node in the selection. This child will inherit its parent's data (if available). Returns a fresh selection consisting of the newly-inserted children.
         * @param name the element name to append. May be prefixed (see d3.ns.prefix).
         * @param before a function to determine the node to use as the next sibling
         */
        insert(name: string, before: (datum: Datum, index: number, outerIndex: number) => EventTarget): Selection<Datum>;

        /**
         * Inserts a new child to the end of each node in the selection by computing a new node. This child will inherit its parent's data (if available). Returns a fresh selection consisting of the newly-inserted children.
         * @param name the function to compute a new child
         * @param before the selector to determine position (e.g., ":first-child")
         */
        insert(name: (datum: Datum, index: number, outerIndex: number) => EventTarget, before: string): Selection<Datum>;

        /**
         * Inserts a new child to the end of each node in the selection by computing a new node. This child will inherit its parent's data (if available). Returns a fresh selection consisting of the newly-inserted children.
         * @param name the function to compute a new child
         * @param before a function to determine the node to use as the next sibling
         */
        insert(name: (datum: Datum, index: number, outerIndex: number) => EventTarget, before: (datum: Datum, index: number, outerIndex: number) => EventTarget): Selection<Datum>;

        /**
         * Removes the elements from the DOM. They are in a detached state and may be re-added (though there is currently no dedicated API for doing so).
         */
        remove(): Selection<Datum>;

        /**
         * Retrieves the data bound to the first group in this selection.
         */
        data(): Datum[];

        /**
         * Binds data to this selection.
         * @param data the array of data to bind to this selection
         * @param key the optional function to determine the unique key for each piece of data. When unspecified, uses the index of the element.
         */
        data<NewDatum>(data: NewDatum[], key?: (datum: NewDatum, index: number, outerIndex: number) => string): selection.Update<NewDatum>;

        /**
         * Derives data to bind to this selection.
         * @param data the function to derive data. Must return an array.
         * @param key the optional function to determine the unique key for each data item. When unspecified, uses the index of the element.
         */
        data<NewDatum>(data: (datum: Datum, index: number, outerIndex: number) => NewDatum[], key?: (datum: NewDatum, index: number, outerIndex: number) => string): selection.Update<NewDatum>;

        /**
         * Filters the selection, returning only those nodes that match the given CSS selector.
         * @param selector the CSS selector
         */
        filter(selector: string): Selection<Datum>;

        /**
         * Filters the selection, returning only those nodes for which the given function returned true.
         * @param selector the filter function
         */
        filter(selector: (datum: Datum, index: number, outerIndex: number) => boolean): Selection<Datum>;

        /**
         * Return the data item bound to the first element in the selection.
         */
        datum(): Datum;

        /**
         * Derive the data item for each node in the selection. Useful for situations such as the HTML5 'dataset' attribute.
         * @param value the function to compute data for each node
         */
        datum<NewDatum>(value: (datum: Datum, index: number, outerIndex: number) => NewDatum): Selection<NewDatum>;

        /**
         * Set the data item for each node in the selection.
         * @param value the constant element to use for each node
         */
        datum<NewDatum>(value: NewDatum): Selection<NewDatum>;

        /**
         * Reorders nodes in the selection based on the given comparator. Nodes are re-inserted into the document once sorted.
         * @param comparator the comparison function, which defaults to d3.ascending
         */
        sort(comparator?: (a: Datum, b: Datum) => number): Selection<Datum>;

        /**
         * Reorders nodes in the document to match the selection order. More efficient than calling sort() if the selection is already ordered.
         */
        order(): Selection<Datum>;

        /**
         * Returns the listener (if any) for the given event.
         * @param type the type of event to load the listener for. May have a namespace (e.g., ".foo") at the end.
         */
        on(type: string): (datum: Datum, index: number, outerIndex: number) => any;

        /**
         * Adds a listener for the specified event. If one was already registered, it is removed before the new listener is added. The return value of the listener function is ignored.
         * @param type the of event to listen to. May have a namespace (e.g., ".foo") at the end.
         * @param listener an event listener function, or null to unregister
         * @param capture sets the DOM useCapture flag
         */
        on(type: string, listener: (datum: Datum, index: number, outerIndex: number) => any, capture?: boolean): Selection<Datum>;

        /**
         * Begins a new transition. Interrupts any active transitions of the same name.
         * @param name the transition name (defaults to "")
         */
        transition(name?: string): Transition<Datum>;

        /**
         * Interrupts the active transition of the provided name. Does not cancel scheduled transitions.
         * @param name the transition name (defaults to "")
         */
        interrupt(name?: string): Selection<Datum>;

        /**
         * Creates a subselection by finding the first descendent matching the selector string. Bound data is inherited.
         * @param selector the CSS selector to match against
         */
        select(selector: string): Selection<Datum>;

        /**
         * Creates a subselection by using a function to find descendent elements. Bound data is inherited.
         * @param selector the function to find matching descendants
         */
        select(selector: (datum: Datum, index: number, outerIndex: number) => EventTarget): Selection<Datum>;

        /**
         * Creates a subselection by finding all descendents that match the given selector. Bound data is not inherited.
         * @param selector the CSS selector to match against
         */
        selectAll(selector: string): Selection<any>;

        /**
         * Creates a subselection by finding all descendants that match the given selector. Bound data is not inherited.
         *
         * Use this overload when data-binding a subselection (that is, sel.selectAll('.foo').data(d => ...)). The type will carry over.
         */
        selectAll<T>(selector: string): Selection<T>;

        /**
         * Creates a subselection by using a function to find descendent elements. Bound data is not inherited.
         * @param selector the function to find matching descendents
         */
        selectAll(selector: (datum: Datum, index: number, outerIndex: number) => Array<EventTarget> | NodeList): Selection<any>;

        /**
         * Creates a subselection by using a function to find descendent elements. Bound data is not inherited.
         *
         * Use this overload when data-binding a subselection (that is, sel.selectAll('.foo').data(d => ...)). The type will carry over.
         * @param selector the function to find matching descendents
         */
        selectAll<T>(selector: (datum: Datum, index: number, outerIndex: number) => Array<EventTarget> | NodeList): Selection<T>;

        /**
         * Invoke the given function for each element in the selection. The return value of the function is ignored.
         * @param func the function to invoke
         */
        each(func: (datum: Datum, index: number, outerIndex: number) => any): Selection<Datum>;

        /**
         * Call a function on the selection. sel.call(foo) is equivalent to foo(sel).
         * @param func the function to call on the selection
         * @param args any optional args
         */
        call(func: (sel: Selection<Datum>, ...args: any[]) => any, ...args: any[]): Selection<Datum>;

        /**
         * Returns true if the current selection is empty.
         */
        empty(): boolean;

        /**
         * Returns the first non-null element in the selection, or null otherwise.
         */
        node(): Node;

        /**
         * Returns the total number of elements in the selection.
         */
        size(): number;
    }

    function transition(): Transition<any>;
    namespace transition {
        var prototype: Transition<any>;
    }

    interface Transition<Datum> {

        transition(): Transition<Datum>;

        delay(): number;
        delay(delay: number): Transition<Datum>;
        delay(delay: (datum: Datum, index: number, outerIndex: number) => number): Transition<Datum>;

        duration(): number;
        duration(duration: number): Transition<Datum>;
        duration(duration: (datum: Datum, index: number, outerIndex: number) => number): Transition<Datum>;

        ease(): (t: number) => number;
        ease(value: string, ...args: any[]): Transition<Datum>;
        ease(value: (t: number) => number): Transition<Datum>;

        attr(name: string, value: Primitive): Transition<Datum>;
        attr(name: string, value: (datum: Datum, index: number, outerIndex: number) => Primitive): Transition<Datum>;
        attr(obj: { [key: string]: Primitive | ((datum: Datum, index: number, outerIndex: number) => Primitive) }): Transition<Datum>;

        attrTween(name: string, tween: (datum: Datum, index: number, attr: string) => (t: number) => Primitive): Transition<Datum>;

        style(name: string, value: Primitive, priority?: string): Transition<Datum>;
        style(name: string, value: (datum: Datum, index: number, outerIndex: number) => Primitive, priority?: string): Transition<Datum>;
        style(obj: { [key: string]: Primitive | ((datum: Datum, index: number, outerIndex: number) => Primitive) }, priority?: string): Transition<Datum>;

        styleTween(name: string, tween: (datum: Datum, index: number, attr: string) => (t: number) => Primitive, priority?: string): Transition<Datum>;

        text(value: Primitive): Transition<Datum>;
        text(value: (datum: Datum, index: number, outerIndex: number) => Primitive): Transition<Datum>;

        tween(name: string, factory: () => (t: number) => any): Transition<Datum>;

        remove(): Transition<Datum>;

        select(selector: string): Transition<Datum>;
        select(selector: (d: Datum, i: number) => EventTarget): Transition<Datum>;

        selectAll(selector: string): Transition<any>;
        selectAll(selector: (d: Datum, i: number) => EventTarget[]): Transition<any>;

        filter(selector: string): Transition<Datum>;
        filter(selector: (d: Datum, i: number) => boolean): Transition<Datum>;

        each(type: string, listener: (d: Datum, i: number) => any): Transition<Datum>;
        each(listener: (d: Datum, i: number) => any): Transition<Datum>;

        call(func: (transition: Transition<Datum>, ...args: any[]) => any, ...args: any[]): Transition<Datum>;

        empty(): boolean;
        node(): Node;
        size(): number;
    }

    function ease(type: 'linear'): (t: number) => number;
    function ease(type: 'linear-in'): (t: number) => number;
    function ease(type: 'linear-out'): (t: number) => number;
    function ease(type: 'linear-in-out'): (t: number) => number;
    function ease(type: 'linear-out-in'): (t: number) => number;

    function ease(type: 'poly', k: number): (t: number) => number;
    function ease(type: 'poly-in', k: number): (t: number) => number;
    function ease(type: 'poly-out', k: number): (t: number) => number;
    function ease(type: 'poly-in-out', k: number): (t: number) => number;
    function ease(type: 'poly-out-in', k: number): (t: number) => number;

    function ease(type: 'quad'): (t: number) => number;
    function ease(type: 'quad-in'): (t: number) => number;
    function ease(type: 'quad-out'): (t: number) => number;
    function ease(type: 'quad-in-out'): (t: number) => number;
    function ease(type: 'quad-out-in'): (t: number) => number;

    function ease(type: 'cubic'): (t: number) => number;
    function ease(type: 'cubic-in'): (t: number) => number;
    function ease(type: 'cubic-out'): (t: number) => number;
    function ease(type: 'cubic-in-out'): (t: number) => number;
    function ease(type: 'cubic-out-in'): (t: number) => number;

    function ease(type: 'sin'): (t: number) => number;
    function ease(type: 'sin-in'): (t: number) => number;
    function ease(type: 'sin-out'): (t: number) => number;
    function ease(type: 'sin-in-out'): (t: number) => number;
    function ease(type: 'sin-out-in'): (t: number) => number;

    function ease(type: 'circle'): (t: number) => number;
    function ease(type: 'circle-in'): (t: number) => number;
    function ease(type: 'circle-out'): (t: number) => number;
    function ease(type: 'circle-in-out'): (t: number) => number;
    function ease(type: 'circle-out-in'): (t: number) => number;

    function ease(type: 'elastic', a?: number, b?: number): (t: number) => number;
    function ease(type: 'elastic-in', a?: number, b?: number): (t: number) => number;
    function ease(type: 'elastic-out', a?: number, b?: number): (t: number) => number;
    function ease(type: 'elastic-in-out', a?: number, b?: number): (t: number) => number;
    function ease(type: 'elastic-out-in', a?: number, b?: number): (t: number) => number;

    function ease(type: 'back', s: number): (t: number) => number;
    function ease(type: 'back-in', s: number): (t: number) => number;
    function ease(type: 'back-out', s: number): (t: number) => number;
    function ease(type: 'back-in-out', s: number): (t: number) => number;
    function ease(type: 'back-out-in', s: number): (t: number) => number;

    function ease(type: 'bounce'): (t: number) => number;
    function ease(type: 'bounce-in'): (t: number) => number;
    function ease(type: 'bounce-out'): (t: number) => number;
    function ease(type: 'bounce-in-out'): (t: number) => number;
    function ease(type: 'bounce-out-in'): (t: number) => number;

    function ease(type: string, ...args: any[]): (t: number) => number;

    function timer(func: () => any, delay?: number, time?: number): void;

    namespace timer {
        function flush(): void;
    }

	 interface BaseEvent {
		 type: string;
		 sourceEvent?: Event;
	 }

	 /**
	  * Define a D3-specific ZoomEvent per https://github.com/mbostock/d3/wiki/Zoom-Behavior#event
	  */
	 interface ZoomEvent extends BaseEvent {
		 scale: number;
		 translate: [number, number];
	 }

	 /**
	  * Define a D3-specific DragEvent per https://github.com/mbostock/d3/wiki/Drag-Behavior#on
	  */
	 interface DragEvent extends BaseEvent {
		 x: number;
		 y: number;
		 dx: number;
		 dy: number;
	 }

    /**
     * The current event's value. Use this variable in a handler registered with `selection.on`.
     */
    var event: Event | BaseEvent;

    /**
     * Returns the x and y coordinates of the mouse relative to the provided container element, using d3.event for the mouse's position on the page.
     * @param container the container element (e.g. an SVG <g> element)
     */
    function mouse(container: EventTarget): [number, number];

    /**
     * Given a container element and a touch identifier, determine the x and y coordinates of the touch.
     * @param container the container element (e.g., an SVG <svg> element)
     * @param identifier the given touch identifier
     */
    function touch(container: EventTarget, identifer: number): [number, number];

    /**
     * Given a container element, a list of touches, and a touch identifier, determine the x and y coordinates of the touch.
     * @param container the container element (e.g., an SVG <svg> element)
     * @param identifier the given touch identifier
     */
    function touch(container: EventTarget, touches: TouchList, identifer: number): [number, number];

    /**
     * Given a container element and an optional list of touches, return the position of every touch relative to the container.
     * @param container the container element
     * @param touches an optional list of touches (defaults to d3.event.touches)
     */
    function touches(container: EventTarget, touches?: TouchList): Array<[number, number]>;

    // NB. this is limited to primitive values due to D3's use of the <, >, and >= operators. Results get weird for object instances.
    /**
     * Compares two primitive values for sorting (in ascending order).
     */
    function ascending(a: Primitive, b: Primitive): number;

    /**
     * Compares two primitive values for sorting (in ascending order).
     */
    function descending(a: Primitive, b: Primitive): number;

    /**
     * Return the minimum value in the array using natural order.
     */
    function min(array: number[]): number;

    /**
     * Return the minimum value in the array using natural order.
     */
    function min(array: string[]): string;

    /**
     * Return the minimum value in the array using natural order.
     */
    function min<T extends Numeric>(array: T[]): T;

    /**
     * Return the minimum value in the array using natural order.
     */
    function min<T>(array: T[], accessor: (datum: T, index: number) => number): number;

    /**
     * Return the minimum value in the array using natural order.
     */
    function min<T>(array: T[], accessor: (datum: T, index: number) => string): string;

    /**
     * Return the minimum value in the array using natural order.
     */
    function min<T, U extends Numeric>(array: T[], accessor: (datum: T, index: number) => U): U;

    /**
     * Return the maximum value in the array of numbers using natural order.
     */
    function max(array: number[]): number;

    /**
     * Return the maximum value in the array of strings using natural order.
     */
    function max(array: string[]): string;

    /**
     * Return the maximum value in the array of numbers using natural order.
     */
    function max<T extends Numeric>(array: T[]): T;

    /**
     * Return the maximum value in the array using natural order and a projection function to map values to numbers.
     */
    function max<T>(array: T[], accessor: (datum: T, index: number) => number): number;

    /**
     * Return the maximum value in the array using natural order and a projection function to map values to strings.
     */
    function max<T>(array: T[], accessor: (datum: T, index: number) => string): string;

    /**
     * Return the maximum value in the array using natural order and a projection function to map values to easily-sorted values.
     */
    function max<T, U extends Numeric>(array: T[], accessor: (datum: T, index: number) => U): U;

    /**
     * Return the min and max simultaneously.
     */
    function extent(array: number[]): [number, number];

    /**
     * Return the min and max simultaneously.
     */
    function extent(array: string[]): [string, string];

    /**
     * Return the min and max simultaneously.
     */
    function extent<T extends Numeric>(array: T[]): [T, T];

    /**
     * Return the min and max simultaneously.
     */
    function extent<T extends Numeric>(array: Array<T | Primitive>): [T | Primitive, T | Primitive];

    /**
     * Return the min and max simultaneously.
     */
    function extent<T>(array: T[], accessor: (datum: T, index: number) => number): [number, number];

    /**
     * Return the min and max simultaneously.
     */
    function extent<T>(array: T[], accessor: (datum: T, index: number) => string): [string, string];

    /**
     * Return the min and max simultaneously.
     */
    function extent<T>(array: T[], accessor: (datum: T, index: number) => Date): [Date, Date];

    /**
     * Return the min and max simultaneously.
     */
    function extent<T, U extends Numeric>(array: T[], accessor: (datum: T, index: number) => U): [U | Primitive, U | Primitive];

    /**
     * Compute the sum of an array of numbers.
     */
    function sum(array: number[]): number;

    /**
     * Compute the sum of an array, using the given accessor to convert values to numbers.
     */
    function sum<T>(array: T[], accessor: (datum: T, index: number) => number): number;

    function mean(array: number[]): number;
    function mean<T>(array: T[], accessor: (datum: T, index: number) => number): number;

    /**
     * Compute the median of an array of numbers (the 0.5-quantile).
     */
    function median(array: number[]): number;
    function median<T>(datum: T[], accessor: (datum: T, index: number) => number): number;

    function quantile(array: number[], p: number): number;

    function variance(array: number[]): number;
    function variance<T>(array: T[], accessor: (datum: T, index: number) => number): number;

    function deviation(array: number[]): number;
    function deviation<T>(array: T[], accessor: (datum: T, index: number) => number): number;

    function bisectLeft<T>(array: T[], x: T, lo?: number, hi?: number): number;

    var bisect: typeof bisectRight;

    function bisectRight<T>(array: T[], x: T, lo?: number, hi?: number): number;

    function bisector<T, U>(accessor: (x: T) => U): {
        left: (array: T[], x: U, lo?: number, hi?: number) => number;
        right: (array: T[], x: U, lo?: number, hi?: number) => number;
    }

    function bisector<T, U>(comparator: (a: T, b: U) => number): {
        left: (array: T[], x: U, lo?: number, hi?: number) => number;
        right: (array: T[], x: U, lo?: number, hi?: number) => number;
    }

    function shuffle<T>(array: T[], lo?: number, hi?: number): T[];

    /**
     * Returns the enumerable property names of the specified object.
     * @param object a JavaScript object
     */
    function keys(object: Object): string[];

    /**
     * Returns an array containing the property values of the specified object.
     */
    function values<T>(object: { [key: string]: T }): T[];
    /**
     * Returns an array containing the property values of the specified object.
     */
    function values<T>(object: { [key: number]: T }): T[];
    /**
     * Returns an array containing the property values of the specified object.
     */
    function values(object: Object): any[];

    /**
     * Returns an array of key-value pairs containing the property values of the specified object.
     */
    function entries<T>(object: { [key: string]: T }): { key: string; value: T }[];

    /**
     * Returns an array of key-value pairs containing the property values of the specified object.
     */
    function entries<T>(object: { [key: number]: T }): { key: string; value: T }[];

    /**
     * Returns an array of key-value pairs containing the property values of the specified object.
     */
    function entries(object: Object): { key: string; value: any }[];

    /**
     * A shim for ES6 maps. The implementation uses a JavaScript object internally, and thus keys are limited to strings.
     */
    interface Map<T> {
        /**
         * Does the map contain the given key?
         */
        has(key: string): boolean;

        /**
         * Retrieve the value for the given key. Returns any if there is no value stored.
         */
        get(key: string): T;

        /**
         * Set the value for the given key. Returns the new value.
         */
        set(key: string, value: T): T;

        /**
         * Remove the value for the given key. Returns true if there was a value and false otherwise.
         */
        remove(key: string): boolean;

        /**
         * Returns an array of all keys in arbitrary order.
         */
        keys(): string[];

        /**
         * Returns an array of all values in arbitrary order.
         */
        values(): T[];

        /**
         * Returns an array of key-value objects in arbitrary order.
         */
        entries(): { key: string; value: T }[];

        /**
         * Calls the function for each key and value pair in the map. The 'this' context is the map itself.
         */
        forEach(func: (key: string, value: T) => any): void;

        /**
         * Is this map empty?
         */
        empty(): boolean;

        /**
         * Returns the number of elements stored in the map.
         */
        size(): number;
    }

    /**
     * Constructs an initially empty map.
     */
    function map<T>(): Map<T>;

    /**
     * Construct a new map by copying keys and values from the given one.
     */
    function map<T>(object: Map<T>): Map<T>;

    /**
     * Construct a new map by copying enumerable properties and values from the given object.
     */
    function map<T>(object: { [key: string]: T }): Map<T>;

    /**
     * Construct a new map by copying enumerable properties and values from the given object.
     */
    function map<T>(object: { [key: number]: T }): Map<T>;

    /**
     * Construct a new map by copying elements from the array. The key function is used to identify each object.
     */
    function map<T>(array: T[], key: (datum: T, index: number) => string): Map<T>;

    /**
     * Construct a new map by copying enumerable properties and values from the given object.
     */
    function map(object: Object): Map<any>;

    /**
     * A shim for ES6 sets. Is only able to store strings.
     */
    interface Set {
        /**
         * Is the given string stored in this set?
         */
        has(value: string): boolean;

        /**
         * Add the string to this set. Returns the value.
         */
        add(value: string): string;

        /**
         * Remove the given value from the set. Returns true if it was stored, and false otherwise.
         */
        remove(value: string): boolean;

        /**
         * Returns an array of the strings stored in this set.
         */
        values(): string[];

        /**
         * Calls a given function for each value in the set. The return value of the function is ignored. The this context of the function is the set itself.
         */
        forEach(func: (value: string) => any): void;

        /**
         * Is this set empty?
         */
        empty(): boolean;

        /**
         * Returns the number of values stored in this set.
         */
        size(): number;
    }

    /**
     * Creates an initially-empty set.
     */
    function set(): Set;

    /**
     * Initializes a set from the given array of strings.
     */
    function set(array: string[]): Set;

    /**
     * Merges the specified arrays into a single array.
     */
    function merge<T>(arrays: T[][]): T[];

    /**
     * Generates a 0-based numeric sequence. The output range does not include 'stop'.
     */
    function range(stop: number): number[];

    /**
     * Generates a numeric sequence starting from the given start and stop values. 'step' defaults to 1. The output range does not include 'stop'.
     */
    function range(start: number, stop: number, step?: number): number[];

    /**
     * Given the specified array, return an array corresponding to the list of indices in 'keys'.
     */
    function permute<T>(array: { [key: number]: T }, keys: number[]): T[];

    /**
     * Given the specified object, return an array corresponding to the list of property names in 'keys'.
     */
    function permute<T>(object: { [key: string]: T }, keys: string[]): T[];

    // TODO construct n-tuples from n input arrays
    function zip<T>(...arrays: T[][]): T[][];

    function transpose<T>(matrix: T[][]): T[][];

    /**
     * For each adjacent pair of elements in the specified array, returns a new array of tuples of elements i and i - 1.
     * Returns the empty array if the input array has fewer than two elements.
     */
    function pairs<T>(array: T[]): Array<[T, T]>;

    interface Nest<T> {
        key(func: (datum: T) => string): Nest<T>;
        sortKeys(comparator: (a: string, b: string) => number): Nest<T>;
        sortValues(comparator: (a: T, b: T) => number): Nest<T>;
        rollup<U>(func: (values: T[]) => U): Nest<T>;
        map(array: T[]): { [key: string]: any };
        map(array: T[], mapType: typeof d3.map): Map<any>;
        entries(array: T[]): { key: string; values: any }[];
    }

    function nest<T>(): Nest<T>;

    module random {
        function normal(mean?: number, deviation?: number): () => number;
        function logNormal(mean?: number, deviation?: number): () => number;
        function bates(count: number): () => number;
        function irwinHall(count: number): () => number;
    }

    interface Transform {
        rotate: number;
        translate: [number, number];
        skew: number;
        scale: [number, number];
        toString(): string;
    }

    function transform(transform: string): Transform;

    function format(specifier: string): (n: number) => string;

    interface FormatPrefix {
        symbol: string;
        scale(n: number): number;
    }

    function formatPrefix(value: number, precision?: number): FormatPrefix;

    function round(x: number, n?: number): number;

    function requote(string: string): string;

    var rgb: {
        new (r: number, g: number, b: number): Rgb;
        new (color: string): Rgb;

        (r: number, g: number, b: number): Rgb;
        (color: string): Rgb;
    };

    interface Rgb extends Color {
        r: number;
        g: number;
        b: number;

        brighter(k?: number): Rgb;
        darker(k?: number): Rgb;

        hsl(): Hsl;

        toString(): string;
    }

    var hsl: {
        new (h: number, s: number, l: number): Hsl;
        new (color: string): Hsl;

        (h: number, s: number, l: number): Hsl;
        (color: string): Hsl;
    };

    interface Hsl extends Color {
        h: number;
        s: number;
        l: number;

        brighter(k?: number): Hsl;
        darker(k?: number): Hsl;

        rgb(): Rgb;

        toString(): string;
    }

    var hcl: {
        new (h: number, c: number, l: number): Hcl;
        new (color: string): Hcl;

        (h: number, c: number, l: number): Hcl;
        (color: string): Hcl;
    };

    interface Hcl extends Color {
        h: number;
        c: number;
        l: number;

        brighter(k?: number): Hcl;
        darker(k?: number): Hcl;
    }

    var lab: {
        new (l: number, a: number, b: number): Lab;
        new (color: string): Lab;

        (l: number, a: number, b: number): Lab;
        (color: string): Lab;
    }

    interface Lab extends Color {
        l: number;
        a: number;
        b: number;

        brighter(k?: number): Lab;
        darker(k?: number): Lab;

        rgb(): Rgb;
        toString(): string;
    }

    var color: {
        (): Color;
        new (): Color;
    };

    interface Color {
        rgb(): Rgb;
    }

    module ns {
        interface Qualified {
            space: string;
            local: string;
        }

        var prefix: { [key: string]: string };
        function qualify(name: string): Qualified | string;
    }

    function functor<T extends Function>(value: T): T;
    function functor<T>(value: T): () => T;

    function rebind(target: {}, source: {}, ...names: string[]): any;

    function dispatch(...names: string[]): Dispatch;

    interface Dispatch {
        on(type: string): (...args: any[]) => void;
        on(type: string, listener: (...args: any[]) => any): Dispatch;
        [event: string]: (...args: any[]) => void;
    }

    module scale {
        function identity(): Identity;

        interface Identity {
            (n: number): number;
            invert(n: number): number;

            domain(): number[];
            domain(numbers: number[]): Identity;

            range(): number[];
            range(numbers: number[]): Identity;

            ticks(count?: number): number[];

            tickFormat(count?: number, format?: string): (n: number) => string;

            copy(): Identity;
        }

        function linear(): Linear<number, number>;
        function linear<Output>(): Linear<Output, Output>;
        function linear<Range, Output>(): Linear<Range, Output>;

        interface Linear<Range, Output> {
            (x: number): Output;
            invert(y: number): number;

            domain(): number[];
            domain(numbers: number[]): Linear<Range, Output>;

            range(): Range[];
            range(values: Range[]): Linear<Range, Output>;

            rangeRound(values: number[]): Linear<number, number>;

            interpolate(): (a: Range, b: Range) => (t: number) => Output;
            interpolate(factory: (a: Range, b: Range) => (t: number) => Output): Linear<Range, Output>;

            clamp(): boolean;
            clamp(clamp: boolean): Linear<Range, Output>;

            nice(count?: number): Linear<Range, Output>;

            ticks(count?: number): number[];

            tickFormat(count?: number, format?: string): (n: number) => string;

            copy(): Linear<Range, Output>;
        }

        function sqrt(): Pow<number, number>;
        function sqrt<Output>(): Pow<Output, Output>;
        function sqrt<Range, Output>(): Pow<Range, Output>;

        function pow(): Pow<number, number>;
        function pow<Output>(): Pow<Output, Output>;
        function pow<Range, Output>(): Pow<Range, Output>;

        interface Pow<Range, Output> {
            (x: number): Output;

            invert(y: number): number;

            domain(): number[];
            domain(numbers: number[]): Pow<Range, Output>;

            range(): Range[];
            range(values: Range[]): Pow<Range, Output>;

            rangeRound(values: number[]): Pow<number, number>;

            exponent(): number;
            exponent(k: number): Pow<Range, Output>;

            interpolate(): (a: Range, b: Range) => (t: number) => Output;
            interpolate(factory: (a: Range, b: Range) => (t: number) => Output): Pow<Range, Output>;

            clamp(): boolean;
            clamp(clamp: boolean): Pow<Range, Output>;

            nice(m?: number): Pow<Range, Output>;

            ticks(count?: number): number[];

            tickFormat(count?: number, format?: string): (n: number) => string;

            copy(): Pow<Range, Output>;
        }

        function log(): Log<number, number>;
        function log<Output>(): Log<Output, Output>;
        function log<Range, Output>(): Log<Range, Output>;

        interface Log<Range, Output> {
            (x: number): Output;

            invert(y: number): number;

            domain(): number[];
            domain(numbers: number[]): Log<Range, Output>;

            range(): Range[];
            range(values: Range[]): Log<Range, Output>;

            rangeRound(values: number[]): Log<number, number>;

            base(): number;
            base(base: number): Log<Range, Output>;

            interpolate(): (a: Range, b: Range) => (t: number) => Output;
            interpolate(factory: (a: Range, b: Range) => (t: number) => Output): Log<Range, Output>;

            clamp(): boolean;
            clamp(clamp: boolean): Log<Range, Output>;

            nice(): Log<Range, Output>;

            ticks(): number[];

            tickFormat(count?: number, format?: string): (t: number) => string;

            copy(): Log<Range, Output>;
        }

        function quantize<T>(): Quantize<T>;

        interface Quantize<T> {
            (x: number): T;

            invertExtent(y: T): [number, number];

            domain(): number[];
            domain(numbers: number[]): Quantize<T>;

            range(): T[];
            range(values: T[]): Quantize<T>;

            copy(): Quantize<T>;
        }

        function quantile<T>(): Quantile<T>;

        interface Quantile<T> {
            (x: number): T;

            invertExtent(y: T): [number, number];

            domain(): number[];
            domain(numbers: number[]): Quantile<T>;

            range(): T[];
            range(values: T[]): Quantile<T>;

            quantiles(): number[];

            copy(): Quantile<T>;
        }

        function threshold<Range>(): Threshold<number, Range>;
        function threshold<Domain, Range>(): Threshold<Domain, Range>;

        interface Threshold<Domain, Range> {
            (x: number): Range;

            invertExtent(y: Range): [Domain, Domain];

            domain(): Domain[];
            domain(domain: Domain[]): Threshold<Domain, Range>;

            range(): Range[];
            range(values: Range[]): Threshold<Domain, Range>;

            copy(): Threshold<Domain, Range>;
        }

        function ordinal<Range>(): Ordinal<string, Range>;
        function ordinal<Domain extends { toString(): string }, Range>(): Ordinal<Domain, Range>;
        function category10(): Ordinal<string, string>;
        function category10<Domain extends { toString(): string }>(): Ordinal<Domain, string>;
        function category20(): Ordinal<string, string>;
        function category20<Domain extends { toString(): string }>(): Ordinal<Domain, string>;
        function category20b(): Ordinal<string, string>;
        function category20b<Domain extends { toString(): string }>(): Ordinal<Domain, string>;
        function category20c(): Ordinal<string,string>;
        function category20c<Domain extends { toString(): string }>(): Ordinal<Domain, string>;

        interface Ordinal<Domain extends { toString(): string }, Range> {
            (x: Domain): Range;

            domain(): Domain[];
            domain(values: Domain[]): Ordinal<Domain, Range>;

            range(): Range[];
            range(values: Range[]): Ordinal<Domain, Range>;

            rangePoints(interval: [number, number], padding?: number): Ordinal<Domain, number>;
            rangeRoundPoints(interval: [number, number], padding?: number): Ordinal<Domain, number>;

            rangeBands(interval: [number, number], padding?: number, outerPadding?: number): Ordinal<Domain, number>;
            rangeRoundBands(interval: [number, number], padding?: number, outerPadding?: number): Ordinal<Domain, number>;

            rangeBand(): number;
            rangeExtent(): [number, number];

            copy(): Ordinal<Domain, Range>;
        }
    }

    function interpolate(a: number, b: number): (t: number) => number;
    function interpolate(a: string, b: string): (t: number) => string;
    function interpolate(a: string | Color, b: Color): (t: number) => string;
    function interpolate(a: Array<string | Color>, b: Color[]): (t: number) => string;
    function interpolate<Range, Output>(a: Range[], b: Output[]): (t: number) => Output[];
    function interpolate<Range, Output>(a: Range[], b: Range[]): (t: number) => Output[];
    function interpolate(a: { [key: string]: string | Color }, b: { [key: string]: Color }): (t: number) => { [key: string]: string };
    function interpolate<Range, Output>(a: { [key: string]: Range }, b: { [key: string]: Output }): (t: number) => { [key: string]: Output };
    function interpolate<Range, Output>(a: { [key: string]: Range }, b: { [key: string]: Range }): (t: number) => { [key: string]: Output };

    function interpolateNumber(a: number, b: number): (t: number) => number;

    function interpolateRound(a: number, b: number): (t: number) => number;

    function interpolateString(a: string, b: string): (t: number) => string;

    function interpolateRgb(a: string | Color, b: string | Color): (t: number) => string;

    function interpolateHsl(a: string | Color, b: string | Color): (t: number) => string;

    function interpolateLab(a: string | Color, b: string | Color): (t: number) => string;

    function interpolateHcl(a: string | Color, b: string | Color): (t: number) => string;

    function interpolateArray(a: Array<string | Color>, b: Color[]): (t: number) => string[];
    function interpolateArray<Range, Output>(a: Range[], b: Range[]): (t: number) => Output[];
    function interpolateArray<Range, Output>(a: Range[], b: Output[]): (t: number) => Output[];

    function interpolateObject(a: { [key: string]: string | Color }, b: { [key: string]: Color }): (t: number) => { [key: string]: string };
    function interpolateObject<Range, Output>(a: { [key: string]: Range }, b: { [key: string]: Output }): (t: number) => { [key: string]: Output };
    function interpolateObject<Range, Output>(a: { [key: string]: Range }, b: { [key: string]: Range }): (t: number) => { [key: string]: Output };

    function interpolateTransform(a: string | Transform, b: string | Transform): (t: number) => string;

    function interpolateZoom(a: [number, number, number], b: [number, number, number]): {
        (t: number): [number, number, number];
        duration: number;
    };

    var interpolators: Array<(a: any, b: any) => (t: number) => any>;

    module time {
        var second: Interval;
        var minute: Interval;
        var hour: Interval;
        var day: Interval;
        var week: Interval;
        var sunday: Interval;
        var monday: Interval;
        var tuesday: Interval;
        var wednesday: Interval;
        var thursday: Interval;
        var friday: Interval;
        var saturday: Interval;
        var month: Interval;
        var year: Interval;

        interface Interval {
            (d: Date): Date;

            floor(d: Date): Date;

            round(d: Date): Date;

            ceil(d: Date): Date;

            range(start: Date, stop: Date, step?: number): Date[];

            offset(date: Date, step: number): Date;

            utc: {
                (d: Date): Date;

                floor(d: Date): Date;

                round(d: Date): Date;

                ceil(d: Date): Date;

                range(start: Date, stop: Date, step?: number): Date[];

                offset(date: Date, step: number): Date;
            }
        }

        function seconds(start: Date, stop: Date, step?: number): Date[];
        function minutes(start: Date, stop: Date, step?: number): Date[];
        function hours(start: Date, stop: Date, step?: number): Date[];
        function days(start: Date, stop: Date, step?: number): Date[];
        function weeks(start: Date, stop: Date, step?: number): Date[];
        function sundays(start: Date, stop: Date, step?: number): Date[];
        function mondays(start: Date, stop: Date, step?: number): Date[];
        function tuesdays(start: Date, stop: Date, step?: number): Date[];
        function wednesdays(start: Date, stop: Date, step?: number): Date[];
        function thursdays(start: Date, stop: Date, step?: number): Date[];
        function fridays(start: Date, stop: Date, step?: number): Date[];
        function saturdays(start: Date, stop: Date, step?: number): Date[];
        function months(start: Date, stop: Date, step?: number): Date[];
        function years(start: Date, stop: Date, step?: number): Date[];

        function dayOfYear(d: Date): number;
        function weekOfYear(d: Date): number;
        function sundayOfYear(d: Date): number;
        function mondayOfYear(d: Date): number;
        function tuesdayOfYear(d: Date): number;
        function wednesdayOfYear(d: Date): number;
        function fridayOfYear(d: Date): number;
        function saturdayOfYear(d: Date): number;

        function format(specifier: string): Format;

        module format {
            function multi(formats: Array<[string, (d: Date) => boolean|number]>): Format;
            function utc(specifier: string): Format;
            namespace utc {
                function multi(formats: Array<[string, (d: Date) => boolean|number]>): Format;
            }

            var iso: Format;
        }

        interface Format {
            (d: Date): string;
            parse(input: string): Date;
        }

        function scale(): Scale<number, number>;
        function scale<Output>(): Scale<Output, Output>;
        function scale<Range, Output>(): Scale<Range, Output>;

        module scale {
            function utc(): Scale<number, number>;
            function utc<Output>(): Scale<Output, Output>;
            function utc<Range, Output>(): Scale<Range, Output>;
        }


        interface Scale<Range, Output> {
            (x: Date): Output;

            invert(y: number): Date;

            domain(): Date[];
            domain(dates: number[]): Scale<Range, Output>;
            domain(dates: Date[]): Scale<Range, Output>;

            nice(): Scale<Range, Output>;
            nice(interval: Interval, step?: number): Scale<Range, Output>;

            range(): Range[];
            range(values: Range[]): Scale<Range, Output>;

            rangeRound(values: number[]): Scale<number, number>;

            interpolate(): (a: Range, b: Range) => (t: number) => Output;
            interpolate(factory: (a: Range, b: Range) => (t: number) => Output): Scale<Range, Output>;

            clamp(): boolean;
            clamp(clamp: boolean): Scale<Range, Output>;

            ticks(): Date[];
            ticks(interval: Interval, step?: number): Date[];
            ticks(count: number): Date[];

            tickFormat(count: number): (d: Date) => string;

            copy(): Scale<Range, Output>;
        }
    }

    module behavior {
        function drag<Datum>(): Drag<Datum>;

        interface Drag<Datum> {
            (selection: Selection<Datum>): void;

            on(type: string): (d: Datum, i: number) => any;
            on(type: string, listener: (d: Datum, i: number) => any): Drag<Datum>;

            origin(): (d: Datum, i: number) => { x: number; y: number };
            origin(accessor: (d: Datum, i: number) => { x: number; y: number }): Drag<Datum>;
        }

        function zoom<Datum>(): Zoom<Datum>;

        namespace zoom {
            interface Scale {
                domain(): number[];
                domain(values: number[]): Scale;

                invert(y: number): number;

                range(values: number[]): Scale;
                range(): number[];
            }
        }

        interface Zoom<Datum> {
            (selection: Selection<Datum>): void;

            translate(): [number, number];
            translate(translate: [number, number]): Zoom<Datum>;

            scale(): number;
            scale(scale: number): Zoom<Datum>;

            scaleExtent(): [number, number];
            scaleExtent(extent: [number, number]): Zoom<Datum>;

            center(): [number, number];
            center(center: [number, number]): Zoom<Datum>;

            size(): [number, number];
            size(size: [number, number]): Zoom<Datum>;

            x(): zoom.Scale;
            x(x: zoom.Scale): Zoom<Datum>;

            y(): zoom.Scale;
            y(y: zoom.Scale): Zoom<Datum>;

            on(type: string): (d: Datum, i: number) => any;
            on(type: string, listener: (d: Datum, i: number) => any): Zoom<Datum>;

            event(selection: Selection<Datum>): void;
            event(transition: Transition<Datum>): void;
        }
    }

    module geo {
        function path(): Path;

        interface Path {
            (feature: any, index?: number): string;

            area(feature: any): number;

            centroid(feature: any): [number, number];

            bounds(feature: any): [[number, number], [number, number]];

            projection(): Transform | ((coordinates: [number, number]) => [number, number]);
            projection(stream: Transform): Path;
            projection(projection: (coordinates: [number, number]) => [number, number]): Path;

            pointRadius(): number | ((datum: any, index: number) => number);
            pointRadius(radius: number): Path;
            pointRadius(radius: (datum: any, index: number) => number): Path;

            context(): CanvasRenderingContext2D;
            context(context: CanvasRenderingContext2D): Path;
        }

        function graticule(): Graticule;

        interface Graticule {
            (): any;

            lines(): any[];

            outline(): any;

            extent(): [[number, number], [number, number]];
            extent(extent: [[number, number], [number, number]]): Graticule;

            majorExtent(): [[number, number], [number, number]];
            majorExtent(extent: [[number, number], [number, number]]): Graticule;

            minorExtent(): [[number, number], [number, number]];
            minorExtent(extent: [[number, number], [number, number]]): Graticule;

            step(): [number, number];
            step(step: [number, number]): Graticule;

            majorStep(): [number, number];
            majorStep(step: [number, number]): Graticule;

            minorStep(): [number, number];
            minorStep(step: [number, number]): Graticule;

            precision(): number;
            precision(precision: number): Graticule;
        }

        function circle(): Circle;

        interface Circle {
            (...args: any[]): any;

            origin(): [number, number] | ((...args: any[]) => [number, number]);
            origin(origin: [number, number]): Circle;
            origin(origin: (...args: any[]) => [number, number]): Circle;

            angle(): number;
            angle(angle: number): Circle;

            precision(): number;
            precision(precision: number): Circle;
        }

        function area(feature: any): number;
        function centroid(feature: any): [number, number];
        function bounds(feature: any): [[number, number], [number, number]];
        function distance(a: [number, number], b: [number, number]): number;
        function length(feature: any): number;
        function interpolate(a: [number, number], b: [number, number]): (t: number) => [number, number];

        function rotation(rotate: [number, number] | [number, number, number]): Rotation;

        interface Rotation {
            (location: [number, number]): [number, number];
            invert(location: [number, number]): [number, number];
        }

        function stream(object: any, listener: Listener): void;

        interface Listener {
            point(x: number, y: number, z: number): void;
            lineStart(): void;
            lineEnd(): void;
            polygonStart(): void;
            polygonEnd(): void;
            sphere(): void;
        }

        function transform(methods: TransformMethods): Transform;

        interface TransformMethods {
            point?(x: number, y: number, z: number): void;
            lineStart?(): void;
            lineEnd?(): void;
            polygonStart?(): void;
            polygonEnd?(): void;
            sphere?(): void;
        }

        interface Transform {
            stream(stream: Listener): Listener;
        }

        function clipExtent(): ClipExtent;

        interface ClipExtent extends Transform {
            extent(): [[number, number], [number, number]];
            extent(extent: [[number, number], [number, number]]): ClipExtent;
        }

        function projection(raw: RawInvertibleProjection): InvertibleProjection;
        function projection(raw: RawProjection): Projection;

        function projectionMutator(factory: (...args: any[]) => RawInvertibleProjection): (...args: any[]) => InvertibleProjection;
        function projectionMutator(factory: (...args: any[]) => RawProjection): (...args: any[]) => Projection;

        function albers(): ConicProjection;
        function albersUsa(): ConicProjection;
        function azimuthalEqualArea(): InvertibleProjection;
        namespace azimuthalEqualArea {
            function raw(lambda: number, phi: number): [number, number];
            namespace raw {
                function invert(x: number, y: number): [number, number];
            }
        }

        function azimuthalEquidistant(): InvertibleProjection;
        namespace azimuthalEquidistant {
            function raw(lambda: number, phi: number): [number, number];
            namespace raw {
                function invert(x: number, y: number): [number, number];
            }
        }

        function conicConformal(): ConicProjection;
        namespace conicConformal {
            function raw(phi0: number, phi1: number): RawInvertibleProjection;
        }

        function conicEqualArea(): ConicProjection;
        namespace conicEqualArea {
            function raw(phi0: number, phi1: number): RawInvertibleProjection;
        }

        function conicEquidistant(): ConicProjection;
        namespace conicEquidistant {
            function raw(phi0: number, phi1: number): RawInvertibleProjection;
        }

        function equirectangular(): InvertibleProjection;
        namespace equirectangular {
            function raw(lambda: number, phi: number): [number, number];
            namespace raw {
                function invert(x: number, y: number): [number, number];
            }
        }

        function gnomonic(): InvertibleProjection;
        namespace gnomonic {
            function raw(lambda: number, phi: number): [number, number];
            namespace raw {
                function invert(x: number, y: number): [number, number];
            }
        }

        function mercator(): InvertibleProjection;
        namespace mercator {
            function raw(lambda: number, phi: number): [number, number];
            namespace raw {
                function invert(x: number, y: number): [number, number];
            }
        }

        function orthographic(): InvertibleProjection;
        namespace orthographic {
            function raw(lambda: number, phi: number): [number, number];
            namespace raw {
                function invert(x: number, y: number): [number, number];
            }
        }

        function stereographic(): InvertibleProjection;
        namespace stereographic {
            function raw(lambda: number, phi: number): [number, number];
            namespace raw {
                function invert(x: number, y: number): [number, number];
            }
        }

        function transverseMercator(): InvertibleProjection;
        namespace transverseMercator {
            function raw(lambda: number, phi: number): [number, number];
            namespace raw {
                function invert(x: number, y: number): [number, number];
            }
        }

        interface Projection {
            (location: [number, number]): [number, number];

            rotate(): [number, number, number];
            rotate(rotation: [number, number, number]): Projection;

            center(): [number, number];
            center(location: [number, number]): Projection;

            translate(): [number, number];
            translate(point: [number, number]): Projection;

            scale(): number;
            scale(scale: number): Projection;

            clipAngle(): number;
            clipAngle(angle: number): Projection;

            clipExtent(): [[number, number], [number, number]];
            clipExtent(extent: [[number, number], [number, number]]): Projection;

            precision(): number;
            precision(precision: number): Projection;

            stream(listener: Listener): Listener;
        }

        interface InvertibleProjection extends Projection {
            invert(point: [number, number]): [number, number];
        }

        interface ConicProjection extends InvertibleProjection {
            parallels(): [number, number];
            parallels(parallels: [number, number]): ConicProjection;

            rotate(): [number, number, number];
            rotate(rotation: [number, number, number]): ConicProjection;

            center(): [number, number];
            center(location: [number, number]): ConicProjection;

            translate(): [number, number];
            translate(point: [number, number]): ConicProjection;

            scale(): number;
            scale(scale: number): ConicProjection;

            clipAngle(): number;
            clipAngle(angle: number): ConicProjection;

            clipExtent(): [[number, number], [number, number]];
            clipExtent(extent: [[number, number], [number, number]]): ConicProjection;

            precision(): number;
            precision(precision: number): ConicProjection;
        }

        interface RawProjection {
            (lambda: number, phi: number): [number, number];
        }

        interface RawInvertibleProjection extends RawProjection {
            invert(x: number, y: number): [number, number];
        }
    }

    namespace svg {
        function line(): Line<[number, number]>;
        function line<T>(): Line<T>;

        interface Line<T> {
            (data: T[]): string;

            x(): number | ((d: T, i: number) => number);
            x(x: number): Line<T>;
            x(x: (d: T, i: number) => number): Line<T>;

            y(): number | ((d: T, i: number) => number);
            y(x: number): Line<T>;
            y(y: (d: T, i: number) => number): Line<T>;

            interpolate(): string | ((points: Array<[number, number]>) => string);
            interpolate(interpolate: "linear"): Line<T>;
            interpolate(interpolate: "linear-closed"): Line<T>;
            interpolate(interpolate: "step"): Line<T>;
            interpolate(interpolate: "step-before"): Line<T>;
            interpolate(interpolate: "step-after"): Line<T>;
            interpolate(interpolate: "basis"): Line<T>;
            interpolate(interpolate: "basis-open"): Line<T>;
            interpolate(interpolate: "basis-closed"): Line<T>;
            interpolate(interpolate: "bundle"): Line<T>;
            interpolate(interpolate: "cardinal"): Line<T>;
            interpolate(interpolate: "cardinal-open"): Line<T>;
            interpolate(interpolate: "cardinal-closed"): Line<T>;
            interpolate(interpolate: "monotone"): Line<T>;
            interpolate(interpolate: string | ((points: Array<[number, number]>) => string)): Line<T>;

            tension(): number;
            tension(tension: number): Line<T>;

            defined(): (d: T, i: number) => boolean;
            defined(defined: (d: T, i: number) => boolean): Line<T>;
        }

        namespace line {
            function radial(): Radial<[number, number]>;
            function radial<T>(): Radial<T>;

            interface Radial<T> {
                (data: T[]): string;

                radius(): number | ((d: T, i: number) => number);
                radius(radius: number): Radial<T>;
                radius(radius: (d: T, i: number) => number): Radial<T>;

                angle(): number | ((d: T, i: number) => number);
                angle(angle: number): Radial<T>;
                angle(angle: (d: T, i: number) => number): Radial<T>;

                interpolate(): string | ((points: Array<[number, number]>) => string);
                interpolate(interpolate: "linear"): Radial<T>;
                interpolate(interpolate: "linear-closed"): Radial<T>;
                interpolate(interpolate: "step"): Radial<T>;
                interpolate(interpolate: "step-before"): Radial<T>;
                interpolate(interpolate: "step-after"): Radial<T>;
                interpolate(interpolate: "basis"): Radial<T>;
                interpolate(interpolate: "basis-open"): Radial<T>;
                interpolate(interpolate: "basis-closed"): Radial<T>;
                interpolate(interpolate: "bundle"): Radial<T>;
                interpolate(interpolate: "cardinal"): Radial<T>;
                interpolate(interpolate: "cardinal-open"): Radial<T>;
                interpolate(interpolate: "cardinal-closed"): Radial<T>;
                interpolate(interpolate: "monotone"): Radial<T>;
                interpolate(interpolate: string | ((points: Array<[number, number]>) => string)): Radial<T>;

                tension(): number;
                tension(tension: number): Radial<T>;

                defined(): (d: T, i: number) => boolean;
                defined(defined: (d: T, i: number) => boolean): Radial<T>;
            }
        }

        function area(): Area<[number, number]>;
        function area<T>(): Area<T>;

        interface Area<T> {
            (data: T[]): string;

            x(): number | ((d: T, i: number) => number);
            x(x: number): Area<T>;
            x(x: (d: T, i: number) => number): Area<T>;

            x0(): number | ((d: T, i: number) => number);
            x0(x0: number): Area<T>;
            x0(x0: (d: T, i: number) => number): Area<T>;

            x1(): number | ((d: T, i: number) => number);
            x1(x1: number): Area<T>;
            x1(x1: (d: T, i: number) => number): Area<T>;

            y(): number | ((d: T, i: number) => number);
            y(y: number): Area<T>;
            y(y: (d: T, i: number) => number): Area<T>;

            y0(): number | ((d: T, i: number) => number);
            y0(y0: number): Area<T>;
            y0(y0: (d: T, i: number) => number): Area<T>;

            y1(): number | ((d: T, i: number) => number);
            y1(y1: number): Area<T>;
            y1(y1: (d: T, i: number) => number): Area<T>;

            interpolate(): string | ((points: Array<[number, number]>) => string);
            interpolate(interpolate: "linear"): Area<T>;
            interpolate(interpolate: "step"): Area<T>;
            interpolate(interpolate: "step-before"): Area<T>;
            interpolate(interpolate: "step-after"): Area<T>;
            interpolate(interpolate: "basis"): Area<T>;
            interpolate(interpolate: "basis-open"): Area<T>;
            interpolate(interpolate: "cardinal"): Area<T>;
            interpolate(interpolate: "cardinal-open"): Area<T>;
            interpolate(interpolate: "monotone"): Area<T>;
            interpolate(interpolate: string | ((points: Array<[number, number]>) => string)): Area<T>;

            tension(): number;
            tension(tension: number): Area<T>;

            defined(): (d: T, i: number) => boolean;
            defined(defined: (d: T, i: number) => boolean): Area<T>;
        }

        namespace area {
            function radial(): Radial<[number, number]>;
            function radial<T>(): Radial<T>;

            interface Radial<T> {
                (data: T[]): string;

                radius(): number | ((d: T, i: number) => number);
                radius(radius: number): Radial<T>;
                radius(radius: (d: T, i: number) => number): Radial<T>;

                innerRadius(): number | ((d: T, i: number) => number);
                innerRadius(innerRadius: number): Radial<T>;
                innerRadius(innerRadius: (d: T, i: number) => number): Radial<T>;

                outerRadius(): number | ((d: T, i: number) => number);
                outerRadius(outerRadius: number): Radial<T>;
                outerRadius(outerRadius: (d: T, i: number) => number): Radial<T>;

                angle(): number | ((d: T, i: number) => number);
                angle(angle: number): Radial<T>;
                angle(angle: (d: T, i: number) => number): Radial<T>;

                startAngle(): number | ((d: T, i: number) => number);
                startAngle(startAngle: number): Radial<T>;
                startAngle(startAngle: (d: T, i: number) => number): Radial<T>;

                endAngle(): number | ((d: T, i: number) => number);
                endAngle(endAngle: number): Radial<T>;
                endAngle(endAngle: (d: T, i: number) => number): Radial<T>;

                interpolate(): string | ((points: Array<[number, number]>) => string);
                interpolate(interpolate: "linear"): Radial<T>;
                interpolate(interpolate: "step"): Radial<T>;
                interpolate(interpolate: "step-before"): Radial<T>;
                interpolate(interpolate: "step-after"): Radial<T>;
                interpolate(interpolate: "basis"): Radial<T>;
                interpolate(interpolate: "basis-open"): Radial<T>;
                interpolate(interpolate: "cardinal"): Radial<T>;
                interpolate(interpolate: "cardinal-open"): Radial<T>;
                interpolate(interpolate: "monotone"): Radial<T>;
                interpolate(interpolate: string | ((points: Array<[number, number]>) => string)): Radial<T>;

                tension(): number;
                tension(tension: number): Radial<T>;

                defined(): (d: T, i: number) => boolean;
                defined(defined: (d: T, i: number) => boolean): Radial<T>;
            }
        }

        function arc(): Arc<arc.Arc>;
        function arc<T>(): Arc<T>;

        namespace arc {
            interface Arc {
                innerRadius: number;
                outerRadius: number;
                startAngle: number;
                endAngle: number;
                padAngle: number
            }
        }

        interface Arc<T> {
            (d: T, i?: number): string;

            innerRadius(): (d: T, i: number) => number;
            innerRadius(radius: number): Arc<T>;
            innerRadius(radius: (d: T, i: number) => number): Arc<T>;

            outerRadius(): (d: T, i: number) => number;
            outerRadius(radius: number): Arc<T>;
            outerRadius(radius: (d: T, i: number) => number): Arc<T>;

            cornerRadius(): (d: T, i: number) => number;
            cornerRadius(radius: number): Arc<T>;
            cornerRadius(radius: (d: T, i: number) => number): Arc<T>;

            padRadius(): string | ((d: T, i: number) => number);
            padRadius(radius: "auto"): Arc<T>;
            padRadius(radius: string): Arc<T>;
            padRadius(radius: (d: T, i: number) => number): Arc<T>;

            startAngle(): (d: T, i: number) => number;
            startAngle(angle: number): Arc<T>;
            startAngle(angle: (d: T, i: number) => number): Arc<T>;

            endAngle(): (d: T, i: number) => number;
            endAngle(angle: number): Arc<T>;
            endAngle(angle: (d: T, i: number) => number): Arc<T>;

            padAngle(): (d: T, i: number) => number;
            padAngle(angle: number): Arc<T>;
            padAngle(angle: (d: T, i: number) => number): Arc<T>;

            centroid(d: T, i?: number): [number, number];
        }

        function symbol(): Symbol<{}>;
        function symbol<T>(): Symbol<T>;

        interface Symbol<T> {
            (d: T, i?: number): string;

            type(): (d: T, i: number) => string;
            type(type: string): Symbol<T>;
            type(type: (d: T, i: number) => string): Symbol<T>;

            size(): (d: T, i: string) => number;
            size(size: number): Symbol<T>;
            size(size: (d: T, i: number) => number): Symbol<T>;
        }

        var symbolTypes: string[];

        function chord(): Chord<chord.Link<chord.Node>, chord.Node>;
        function chord<Node>(): Chord<chord.Link<Node>, Node>;
        function chord<Link, Node>(): Chord<Link, Node>;

        namespace chord {
            interface Link<Node> {
                source: Node;
                target: Node;
            }

            interface Node {
                radius: number;
                startAngle: number;
                endAngle: number
            }
        }

        interface Chord<Link, Node> {
            (d: Link, i: number): string;

            source(): (d: Link, i: number) => Node;
            source(source: Node): Chord<Link, Node>;
            source(source: (d: Link, i: number) => Node): Chord<Link, Node>;

            target(): (d: Link, i: number) => Node;
            target(target: Node): Chord<Link, Node>;
            target(target: (d: Link, i: number) => Node): Chord<Link, Node>;

            radius(): (d: Node, i: number) => number;
            radius(radius: number): Chord<Link, Node>;
            radius(radius: (d: Node, i: number) => number): Chord<Link, Node>;

            startAngle(): (d: Node, i: number) => number;
            startAngle(angle: number): Chord<Link, Node>;
            startAngle(angle: (d: Node, i: number) => number): Chord<Link, Node>;

            endAngle(): (d: Node, i: number) => number;
            endAngle(angle: number): Chord<Link, Node>;
            endAngle(angle: (d: Node, i: number) => number): Chord<Link, Node>;
        }

        function diagonal(): Diagonal<diagonal.Link<diagonal.Node>, diagonal.Node>;
        function diagonal<Node>(): Diagonal<diagonal.Link<Node>, Node>;
        function diagonal<Link, Node>(): Diagonal<Link, Node>;

        namespace diagonal {
            interface Link<Node> {
                source: Node;
                target: Node;
            }

            interface Node {
                x: number;
                y: number;
            }
        }

        interface Diagonal<Link, Node> {
            (d: Link, i?: number): string;

            source(): (d: Link, i: number) => Node;
            source(source: Node): Diagonal<Link, Node>;
            source(source: (d: Link, i: number) => { x: number; y: number; }): Diagonal<Link, Node>;

            target(): (d: Link, i: number) => Node;
            target(target: Node): Diagonal<Link, Node>;
            target(target: (d: Link, i: number) => { x: number; y: number; }): Diagonal<Link, Node>;

            projection(): (d: Node, i: number) => [number, number];
            projection(projection: (d: Node, i: number) => [number, number]): Diagonal<Link, Node>;
        }

        namespace diagonal {
            function radial(): Radial<Link<Node>, Node>;
            function radial<Node>(): Radial<Link<Node>, Node>;
            function radial<Link, Node>(): Radial<Link, Node>;

            interface Radial<Link, Node> {
                (d: Link, i: number): string;

                source(): (d: Link, i: number) => Node;
                source(source: Node): Radial<Link, Node>;
                source(source: (d: Link, i: number) => Node): Radial<Link, Node>;

                target(): (d: Link, i: number) => Node;
                target(target: Node): Radial<Link, Node>;
                target(target: (d: Link, i: number) => Node): Radial<Link, Node>;

                projection(): (d: Node, i: number) => [number, number];
                projection(projection: (d: Node, i: number) => [number, number]): Radial<Link, Node>;
            }
        }

        function axis(): Axis;

        interface Axis {
            (selection: Selection<any>): void;
            (selection: Transition<any>): void;

            scale(): any;
            scale(scale: any): Axis;

            orient(): string;
            orient(orientation: string): Axis;

            ticks(): any[];
            ticks(...args: any[]): Axis;

            tickValues(): any[];
            tickValues(values: any[]): Axis;

            tickSize(): number;
            tickSize(size: number): Axis;
            tickSize(inner: number, outer: number): Axis;

            innerTickSize(): number;
            innerTickSize(size: number): Axis;

            outerTickSize(): number;
            outerTickSize(size: number): Axis;

            tickPadding(): number;
            tickPadding(padding: number): Axis;

            tickFormat(): (t: any) => string;
            tickFormat(format: (t: any) => string): Axis;
            tickFormat(format:string): Axis;
        }

        function brush(): Brush<any>;
        function brush<T>(): Brush<T>;

        namespace brush {
            interface Scale {
                domain(): number[];
                domain(domain: number[]): Scale;

                range(): number[];
                range(range: number[]): Scale;

                invert?(y: number): number;
            }
        }

        interface Brush<T> {
            (selection: Selection<T>): void;
            (selection: Transition<T>): void;

            event(selection: Selection<T>): void;
            event(selection: Transition<T>): void;

            x(): brush.Scale;
            x(x: brush.Scale): Brush<T>;

            y(): brush.Scale;
            y(y: brush.Scale): Brush<T>;

            extent(): [number, number] | [[number, number], [number, number]];
            extent(extent: [number, number] | [[number, number], [number, number]]): Brush<T>;

            clamp(): boolean | [boolean, boolean];
            clamp(clamp: boolean | [boolean, boolean]): Brush<T>;

            clear(): void;

            empty(): boolean;

            on(type: 'brushstart'): (datum: T, index: number) => void;
            on(type: 'brush'): (datum: T, index: number) => void;
            on(type: 'brushend'): (datum: T, index: number) => void;
            on(type: string): (datum: T, index: number) => void;

            on(type: 'brushstart', listener: (datum: T, index: number) => void): Brush<T>;
            on(type: 'brush', listener: (datum: T, index: number) => void): Brush<T>;
            on(type: 'brushend', listener: (datum: T, index: number) => void): Brush<T>;
            on(type: string, listener: (datum: T, index: number) => void): Brush<T>;
        }
    }

    function xhr(url: string, mimeType?: string, callback?: (err: any, data: any) => void): Xhr;
    function xhr(url: string, callback: (err: any, data: any) => void): Xhr;

    interface Xhr {
        header(name: string): string;
        header(name: string, value: string): Xhr;

        mimeType(): string;
        mimeType(type: string): Xhr;

        responseType(): string;
        responseType(type: string): Xhr;

        response(): (request: XMLHttpRequest) => any;
        response(value: (request: XMLHttpRequest) => any): Xhr;

        get(callback?: (err: any, data: any) => void): Xhr;

        post(data?: any, callback?: (err: any, data: any) => void): Xhr;
        post(callback: (err: any, data: any) => void): Xhr;

        send(method: string, data?: any, callback?: (err: any, data: any) => void): Xhr;
        send(method: string, callback: (err: any, data: any) => void): Xhr;

        abort(): Xhr;

        on(type: "beforesend"): (request: XMLHttpRequest) => void;
        on(type: "progress"): (request: XMLHttpRequest) => void;
        on(type: "load"): (response: any) => void;
        on(type: "error"): (err: any) => void;
        on(type: string): (...args: any[]) => void;

        on(type: "beforesend", listener: (request: XMLHttpRequest) => void): Xhr;
        on(type: "progress", listener: (request: XMLHttpRequest) => void): Xhr;
        on(type: "load", listener: (response: any) => void): Xhr;
        on(type: "error", listener: (err: any) => void): Xhr;
        on(type: string, listener: (...args: any[]) => void): Xhr;
    }

    function text(url: string, mimeType?: string, callback?: (err: any, data: string) => void): Xhr;
    function text(url: string, callback: (err: any, data: string) => void): Xhr;

    function json(url: string, callback?: (err: any, data: any) => void): Xhr;

    function xml(url: string, mimeType?: string, callback?: (err: any, data: any) => void): Xhr;
    function xml(url: string, callback: (err: any, data: any) => void): Xhr;

    function html(url: string, callback?: (err: any, data: DocumentFragment) => void): Xhr;

    var csv: Dsv;
    var tsv: Dsv;
    function dsv(delimiter: string, mimeType: string): Dsv;

    interface Dsv {
        (url: string, callback: (rows: { [key: string]: string }[]) => void): DsvXhr<{ [key: string]: string }>;
        (url: string, callback: (error: any, rows: { [key: string]: string }[]) => void): DsvXhr<{ [key: string]: string }>;
        (url: string): DsvXhr<{ [key: string]: string }>;
        <T>(url: string, accessor: (row: { [key: string]: string }) => T, callback: (rows: T[]) => void): DsvXhr<T>;
        <T>(url: string, accessor: (row: { [key: string]: string }) => T, callback: (error: any, rows: T[]) => void): DsvXhr<T>;
        <T>(url: string, accessor: (row: { [key: string]: string }) => T): DsvXhr<T>;

        parse(string: string): { [key: string]: string }[];
        parse<T>(string: string, accessor: (row: { [key: string]: string }, index: number) => T): T[];

        parseRows(string: string): string[][];
        parseRows<T>(string: string, accessor: (row: string[], index: number) => T): T[];

        format(rows: Object[]): string;

        formatRows(rows: string[][]): string;
    }

    interface DsvXhr<T> extends Xhr {
        row(): (row: { [key: string]: string }) => T;
        row<U>(accessor: (row: { [key: string]: string }) => U): DsvXhr<U>;

        header(name: string): string;
        header(name: string, value: string): DsvXhr<T>;

        mimeType(): string;
        mimeType(type: string): DsvXhr<T>;

        responseType(): string;
        responseType(type: string): DsvXhr<T>;

        response(): (request: XMLHttpRequest) => any;
        response(value: (request: XMLHttpRequest) => any): DsvXhr<T>;

        get(callback?: (err: XMLHttpRequest, data: T[]) => void): DsvXhr<T>;
        post(data?: any, callback?: (err: XMLHttpRequest, data: T[]) => void): DsvXhr<T>;
        post(callback: (err: XMLHttpRequest, data: T[]) => void): DsvXhr<T>;

        send(method: string, data?: any, callback?: (err: XMLHttpRequest, data: T[]) => void): DsvXhr<T>;
        send(method: string, callback: (err: XMLHttpRequest, data: T[]) => void): DsvXhr<T>;

        abort(): DsvXhr<T>;

        on(type: "beforesend"): (request: XMLHttpRequest) => void;
        on(type: "progress"): (request: XMLHttpRequest) => void;
        on(type: "load"): (response: T[]) => void;
        on(type: "error"): (err: any) => void;
        on(type: string): (...args: any[]) => void;

        on(type: "beforesend", listener: (request: XMLHttpRequest) => void): DsvXhr<T>;
        on(type: "progress", listener: (request: XMLHttpRequest) => void): DsvXhr<T>;
        on(type: "load", listener: (response: T[]) => void): DsvXhr<T>;
        on(type: "error", listener: (err: any) => void): DsvXhr<T>;
        on(type: string, listener: (...args: any[]) => void): DsvXhr<T>;
    }

    function locale(definition: LocaleDefinition): Locale;

    interface LocaleDefinition {
        decimal: string;
        thousands: string;
        grouping: number[];
        currency: [string, string];
        dateTime: string;
        date: string;
        time: string;
        periods: [string, string];
        days: [string, string, string, string, string, string, string];
        shortDays: [string, string, string, string, string, string, string];
        months: [string, string, string, string, string, string, string, string, string, string, string, string];
        shortMonths: [string, string, string, string, string, string, string, string, string, string, string, string];
    }

    interface Locale {
        numberFormat(specifier: string): (n: number) => string;
        timeFormat: {
            (specifier: string): time.Format;
            utc(specifier: string): time.Format;
            multi(formats: Array<[string, (d: Date) => boolean|number]>): time.Format;
        }
    }

    namespace layout {
        function bundle(): Bundle<bundle.Node>;
        function bundle<T extends bundle.Node>(): Bundle<T>

        namespace bundle {
            interface Node {
                parent: Node;
            }

            interface Link<T extends Node> {
                source: T;
                target: T;
            }
        }

        interface Bundle<T extends bundle.Node> {
            (links: bundle.Link<T>[]): T[][];
        }

        function chord(): Chord;

        namespace chord {
            interface Link {
                source: Node;
                target: Node;
            }

            interface Node {
                index: number;
                subindex: number;
                startAngle: number;
                endAngle: number;
                value: number;
            }

            interface Group {
                index: number;
                startAngle: number;
                endAngle: number;
                value: number;
            }
        }

        interface Chord {
            matrix(): number[][];
            matrix(matrix: number[][]): Chord;

            padding(): number;
            padding(padding: number): Chord;

            sortGroups(): (a: number, b: number) => number;
            sortGroups(comparator: (a: number, b: number) => number): Chord;

            sortSubgroups(): (a: number, b: number) => number;
            sortSubgroups(comparator: (a: number, b: number) => number): Chord;

            sortChords(): (a: number, b: number) => number;
            sortChords(comparator: (a: number, b: number) => number): Chord;

            chords(): chord.Link[];
            groups(): chord.Group[];
        }

        function cluster(): Cluster<cluster.Result>;
        function cluster<T extends cluster.Result>(): Cluster<T>;

        namespace cluster {
            interface Result {
                parent?: Result;
                children?: Result[];
                depth?: number;
                x?: number;
                y?: number;
            }

            interface Link<T extends Result> {
                source: T;
                target: T;
            }
        }

        interface Cluster<T extends cluster.Result> {
            (root: T): T[];

            nodes(root: T): T[];

            links(nodes: T[]): cluster.Link<T>[];

            children(): (node: T) => T[];
            children(accessor: (node: T) => T[]): Cluster<T>;

            sort(): (a: T, b: T) => number;
            sort(comparator: (a: T, b: T) => number): Cluster<T>;

            separation(): (a: T, b: T) => number;
            separation(separation: (a: T, b: T) => number): Cluster<T>;

            size(): [number, number];
            size(size: [number, number]): Cluster<T>;

            nodeSize(): [number, number];
            nodeSize(nodeSize: [number, number]): Cluster<T>;

            value(): (a: T) => number;
            value(value: (a: T) => number): Cluster<T>;
        }

        function force(): Force<force.Link<force.Node>, force.Node>;
        function force<Node extends force.Node>(): Force<force.Link<Node>, Node>;
        function force<Link extends force.Link<force.Node>, Node extends force.Node>(): Force<Link, Node>;

        namespace force {
            interface Link<T extends Node> {
                source: T;
                target: T;
            }

            interface Node {
                index?: number;
                x?: number;
                y?: number;
                px?: number;
                py?: number;
                fixed?: boolean;
                weight?: number;
            }

            interface Event {
                type: string;
                alpha: number;
            }
        }

        interface Force<Link extends force.Link<force.Node>, Node extends force.Node> {
            size(): [number, number];
            size(size: [number, number]): Force<Link, Node>;

            linkDistance(): number | ((link: Link, index: number) => number);
            linkDistance(distance: number): Force<Link, Node>;
            linkDistance(distance: (link: Link, index: number) => number): Force<Link, Node>;

            linkStrength(): number | ((link: Link, index: number) => number);
            linkStrength(strength: number): Force<Link, Node>;
            linkStrength(strength: (link: Link, index: number) => number): Force<Link, Node>;

            friction(): number;
            friction(friction: number): Force<Link, Node>;

            charge(): number | ((node: Node, index: number) => number);
            charge(charge: number): Force<Link, Node>;
            charge(charge: (node: Node, index: number) => number): Force<Link, Node>;

            chargeDistance(): number;
            chargeDistance(distance: number): Force<Link, Node>;

            theta(): number;
            theta(theta: number): Force<Link, Node>;

            gravity(): number;
            gravity(gravity: number): Force<Link, Node>;

            nodes(): Node[];
            nodes(nodes: Node[]): Force<Link, Node>;

            links(): Link[];
            links(links: { source: number; target: number }[]): Force<Link, Node>;
            links(links: Link[]): Force<Link, Node>;

            start(): Force<Link, Node>;

            tick(): Force<Link, Node>;

            alpha(): number;
            alpha(value: number): Force<Link, Node>;

            resume(): Force<Link, Node>;

            stop(): Force<Link, Node>;

            on(type: string): (event: force.Event) => void;
            on(type: string, listener: (event: force.Event) => void): Force<Link, Node>;

            drag(): behavior.Drag<Node>;
            drag(selection: Selection<Node>): void;
        }

        function hierarchy(): Hierarchy<hierarchy.Result>;
        function hierarchy<T extends hierarchy.Result>(): Hierarchy<T>;

        namespace hierarchy {
            interface Result {
                parent?: Result;
                children?: Result[];
                value?: number;
                depth?: number;
            }
        }

        interface Hierarchy<T extends hierarchy.Result> {
            (root: T): T[];

            children(): (node: T) => T[];
            children(accessor: (node: T) => T[]): Hierarchy<T>;

            sort(): (a: T, b: T) => number;
            sort(comparator: (a: T, b: T) => number): Hierarchy<T>;

            value(): (node: T) => number;
            value(accessor: (node: T) => number): Hierarchy<T>;

            revalue(root: T): T[];
        }

        function histogram(): Histogram<number>;
        function histogram<T>(): Histogram<T>;

        namespace histogram {
            interface Bin<T> extends Array<T> {
                x: number;
                dx: number;
                y: number;
            }
        }

        interface Histogram<T> {
            (values: T[], index?: number): histogram.Bin<T>[];

            value(): (datum: T, index: number) => number;
            value(value: (datum: T, index: number) => number): Histogram<T>;

            range(): (values: T[], index: number) => [number, number];
            range(range: (values: T[], index: number) => [number, number]): Histogram<T>;
            range(range: [number, number]): Histogram<T>;

            bins(): (range: [number, number], values: T[], index: number) => number[];
            bins(count: number): Histogram<T>;
            bins(thresholds: number[]): Histogram<T>;
            bins(func: (range: [number, number], values: T[], index: number) => number[]): Histogram<T>;

            frequency(): boolean;
            frequency(frequency: boolean): Histogram<T>;
        }

        function pack(): Pack<pack.Node>;
        function pack<T extends pack.Node>(): Pack<T>;

        namespace pack {
            interface Node {
                parent?: Node;
                children?: Node[];
                value?: number;
                depth?: number;
                x?: number;
                y?: number;
                r?: number;
            }

            interface Link<T extends Node> {
                source: Node;
                target: Node;
            }
        }

        interface Pack<T extends pack.Node> {
            (root: T): T[];

            nodes(root: T): T[];

            links(nodes: T[]): pack.Link<T>[];

            children(): (node: T, depth: number) => T[];
            children(children: (node: T, depth: number) => T[]): Pack<T>;

            sort(): (a: T, b: T) => number;
            sort(comparator: (a: T, b: T) => number): Pack<T>;

            value(): (node: T) => number;
            value(value: (node: T) => number): Pack<T>;

            size(): [number, number];
            size(size: [number, number]): Pack<T>;

            radius(): number | ((node: T) => number);
            radius(radius: number): Pack<T>;
            radius(radius: (node: T) => number): Pack<T>;

            padding(): number;
            padding(padding: number): Pack<T>;
        }

        function partition(): Partition<partition.Node>;
        function partition<T extends partition.Node>(): Partition<T>;

        namespace partition {
            interface Link<T extends Node> {
                source: T;
                target: T;
            }

            interface Node {
                parent?: Node;
                children?: number;
                value?: number;
                depth?: number;
                x?: number;
                y?: number;
                dx?: number;
                dy?: number;
            }

        }

        interface Partition<T extends partition.Node> {
            (root: T): T[];

            nodes(root: T): T[];

            links(nodes: T[]): partition.Link<T>[];

            children(): (node: T, depth: number) => T[];
            children(children: (node: T, depth: number) => T[]): Partition<T>;

            sort(): (a: T, b: T) => number;
            sort(comparator: (a: T, b: T) => number): Partition<T>;

            value(): (node: T) => number;
            value(value: (node: T) => number): Partition<T>;

            size(): [number, number];
            size(size: [number, number]): Partition<T>;
        }

        function pie(): Pie<number>;
        function pie<T>(): Pie<T>;

        namespace pie {
            interface Arc<T> {
                value: number;
                startAngle: number;
                endAngle: number;
                padAngle: number;
                data: T;
            }
        }

        interface Pie<T> {
            (data: T[], index?: number): pie.Arc<T>[];

            value(): (datum: T, index: number) => number;
            value(accessor: (datum: T, index: number) => number): Pie<T>;

            sort(): (a: T, b: T) => number;
            sort(comparator: (a: T, b: T) => number): Pie<T>;

            startAngle(): number | ((data: T[], index: number) => number);
            startAngle(angle: number): Pie<T>;
            startAngle(angle: (data: T[], index: number) => number): Pie<T>;

            endAngle(): number | ((data: T[], index: number) => number);
            endAngle(angle: number): Pie<T>;
            endAngle(angle: (data: T[], index: number) => number): Pie<T>;

            padAngle(): number | ((data: T[], index: number) => number);
            padAngle(angle: number): Pie<T>;
            padAngle(angle: (data: T[], index: number) => number): Pie<T>;
        }

        function stack(): Stack<stack.Value[], stack.Value>;
        function stack<Value>(): Stack<Value[], Value>;
        function stack<Series, Value>(): Stack<Series, Value>;
        namespace stack {
            interface Value {
                x: number;
                y: number;
                y0?: number;
            }
        }

        interface Stack<Series, Value> {
            (layers: Series[], index?: number): Series[];

            values(): (layer: Series, index: number) => Value[];
            values(accessor: (layer: Series, index: number) => Value[]): Stack<Series, Value>;

            offset(): (data: Array<[number, number]>) => number[];
            offset(offset: "silhouette"): Stack<Series, Value>;
            offset(offset: "wiggle"): Stack<Series, Value>;
            offset(offset: "expand"): Stack<Series, Value>;
            offset(offset: "zero"): Stack<Series, Value>;
            offset(offset: string): Stack<Series, Value>;
            offset(offset: (data: Array<[number, number]>) => number[]): Stack<Series, Value>;

            order(): (data: Array<[number, number]>) => number[];
            order(order: "inside-out"): Stack<Series, Value>;
            order(order: "reverse"): Stack<Series, Value>;
            order(order: "default"): Stack<Series, Value>;
            order(order: string): Stack<Series, Value>;
            order(order: (data: Array<[number, number]>) => number[]): Stack<Series, Value>;

            x(): (value: Value, index: number) => number;
            x(accessor: (value: Value, index: number) => number): Stack<Series, Value>;

            y(): (value: Value, index: number) => number;
            y(accesor: (value: Value, index: number) => number): Stack<Series, Value>;

            out(): (value: Value, y0: number, y: number) => void;
            out(setter: (value: Value, y0: number, y: number) => void): Stack<Series, Value>;
        }

        function tree(): Tree<tree.Node>;
        function tree<T extends tree.Node>(): Tree<T>;

        namespace tree {
            interface Link<T extends Node> {
                source: T;
                target: T;
            }

            interface Node {
                parent?: Node;
                children?: Node[];
                depth?: number;
                x?: number;
                y?: number;
            }
        }

        interface Tree<T> {
            (root: T, index?: number): T[];

            nodes(root: T, index?: number): T[];

            links(nodes: T[]): tree.Link<T>[];

            children(): (datum: T, index: number) => T[];
            children(children: (datum: T, index: number) => T[]): Tree<T>;

            separation(): (a: T, b: T) => number;
            separation(separation: (a: T, b: T) => number): Tree<T>;

            size(): [number, number];
            size(size: [number, number]): Tree<T>;

            nodeSize(): [number, number];
            nodeSize(size: [number, number]): Tree<T>;

            sort(): (a: T, b: T) => number;
            sort(comparator: (a: T, b: T) => number): Tree<T>;

            value(): (datum: T, index: number) => number;
            value(value: (datum: T, index: number) => number): Tree<T>;
        }

        function treemap(): Treemap<treemap.Node>;
        function treemap<T extends treemap.Node>(): Treemap<T>;

        namespace treemap {
            interface Node {
                parent?: Node;
                children?: Node[];
                value?: number;
                depth?: number;
                x?: number;
                y?: number;
                dx?: number;
                dy?: number;
            }

            interface Link<T extends Node> {
                source: T;
                target: T;
            }

            type Padding = number | [number, number, number, number];
        }

        interface Treemap<T extends treemap.Node> {
            (root: T, index?: number): T[];

            nodes(root: T, index?: number): T[];

            links(nodes: T[]): treemap.Link<T>[];

            children(): (node: T, depth: number) => T[];
            children(children: (node: T, depth: number) => T[]): Treemap<T>;

            sort(): (a: T, b: T) => number;
            sort(comparator: (a: T, b: T) => number): Treemap<T>;

            value(): (node: T, index: number) => number;
            value(value: (node: T, index: number) => number): Treemap<T>;

            size(): [number, number];
            size(size: [number, number]): Treemap<T>;

            padding(): (node: T, depth: number) => treemap.Padding;
            padding(padding: treemap.Padding): Treemap<T>;
            padding(padding: (node: T, depth: number) => treemap.Padding): Treemap<T>;

            round(): boolean;
            round(round: boolean): Treemap<T>;

            sticky(): boolean;
            sticky(sticky: boolean): boolean;

            mode(): string;
            mode(mode: "squarify"): Treemap<T>;
            mode(mode: "slice"): Treemap<T>;
            mode(mode: "dice"): Treemap<T>;
            mode(mode: "slice-dice"): Treemap<T>;
            mode(mode: string): Treemap<T>;

            ratio(): number;
            ratio(ratio: number): Treemap<T>;
        }
    }

    namespace geom {
        function voronoi(): Voronoi<[number, number]>;
        function voronoi<T>(): Voronoi<T>;

        namespace voronoi {
            interface Link<T> {
                source: T;
                target: T;
            }
        }

        interface Voronoi<T> {
            (data: T[]): Array<[number, number]>;

            x(): (vertex: T) => number;
            x(x: (vertex: T) => number): Voronoi<T>;

            y(): (vertex: T) => number;
            y(y: (vertex: T) => number): Voronoi<T>;

            clipExtent(): [[number, number], [number, number]];
            clipExtent(extent: [[number, number], [number, number]]): Voronoi<T>;

            links(data: T[]): voronoi.Link<T>[];

            triangles(data: T[]): Array<[T, T, T]>;
        }

        /**
         * @deprecated use d3.geom.voronoi().triangles() instead
         */
        function delaunay(vertices: Array<[number, number]>): Array<[[number, number], [number, number], [number, number]]>;

        function quadtree(): Quadtree<[number, number]>;
        function quadtree<T>(nodes: T[], x1?: number, y1?: number, x2?: number, y2?: number): quadtree.Quadtree<T>;

        namespace quadtree {
            interface Node<T> {
                nodes: [Node<T>, Node<T>, Node<T>, Node<T>];
                leaf: boolean;
                point: T;
                x: number;
                y: number;
            }

            interface Quadtree<T> extends Node<T> {
                add(point: T): void;
                visit(callback: (node: Node<T>, x1: number, y1: number, x2: number, y2: number) => boolean | void): void;
                find(point: [number, number]): T;
            }
        }

        interface Quadtree<T> {
            (points: T[]): quadtree.Quadtree<T>;

            x(): (datum: T, index: number) => number;
            x(x: number): Quadtree<T>;
            x(x: (datum: T, index: number) => number): Quadtree<T>;

            y(): (datum: T, index: number) => number;
            y(y: number): Quadtree<T>;
            y(y: (datum: T, index: number) => number): Quadtree<T>;

            extent(): [[number, number], [number, number]];
            extent(extent: [[number, number], [number, number]]): Quadtree<T>;
        }

        function hull(vertices: Array<[number, number]>): Array<[number, number]>;
        function hull(): Hull<[number, number]>;
        function hull<T>(): Hull<T>;

        interface Hull<T> {
            (vertices: T[]): Array<[number, number]>;

            x(): (datum: T) => number;
            x(x: (datum: T) => number): Hull<T>;

            y(): (datum: T) => number;
            y(y: (datum: T) => number): Hull<T>;
        }

        function polygon(vertices: Array<[number, number]>): Polygon;

        interface Polygon {
            area(): number;

            centroid(): [number, number];

            clip(subject: Array<[number, number]>): Array<[number, number]>;
        }
    }
}

// we need this to exist
interface TouchList { }

// Type definitions for Globalize
// Project: https://github.com/jquery/globalize
// Definitions by: Boris Yankov <https://github.com/borisyankov/>
// Definitions: https://github.com/borisyankov/DefinitelyTyped


interface GlobalizePercent {
  pattern: string[];
  decimals: number;
  groupSizes: number[];
  //",": string;
  //".": string;
  symbol: string;
}

interface GlobalizeCurrency {
  pattern: string[];
  decimals: number;
  groupSizes: number[];
  //",": string;
  //".": string;
  symbol: string;
}

interface GlobalizeNumberFormat {
  pattern: string[];
  decimals: string;
  //",": string;
  //".": string;
  groupSizes: number[];
  //"+": string;
  //"-": string;
  NaN: string;
  negativeInfinity: string;
  positiveInfinity: string;
  percent: GlobalizePercent;
  currency: GlobalizeCurrency;
}

interface GlobalizeEra {
  name: string;
  start: any;
  offset: number;
}

interface GlobalizeDays {
  names: string[];
  namesAbbr: string[];
  namesShort: string[];
}

interface GlobalizeMonths {
  names: string[];
  namesAbbr: string[];
}

interface GlobalizePatterns {
  d: string;
  D: string;
  t: string;
  T: string;
  f: string;
  F: string;
  M: string;
  Y: string;
  S: string;
}

interface GlobalizeCalendar {
  name: string;
  // "/": string,
  // ":": string,
  firstDay: number;
  days: GlobalizeDays;
  months: GlobalizeMonths;
  AM: string[];
  PM: string[];
  eras: GlobalizeEra[];
  twoDigitYearMax: number;
  patterns: GlobalizePatterns;
}

interface GlobalizeCalendars {
  standard: GlobalizeCalendar;
}

interface GlobalizeCulture {
  name: string;
  englishName: string;
  nativeName: string;
  isRTL: boolean;
  language: string;
  numberFormat: GlobalizeNumberFormat;
  calendars: GlobalizeCalendars;
  messages: any;
}
interface GlobalizeCultures {
  [index: number]: GlobalizeCulture;
}

interface GlobalizeStatic {
  cultures: GlobalizeCultures;
  init(cultureSelector: string);
  cultureSelector: string;

  culture(): GlobalizeCulture;
  culture(cultureSelector: string): GlobalizeCulture;
  culture(cultureSelector: string[]): GlobalizeCulture;

  addCultureInfo(cultureName, baseCultureName, info?);
  findClosestCulture(cultureSelector: string);
  format(value, format, cultureSelector?);
  localize(key, cultureSelector?);

  parseDate(value: string, formats?, cultureSelector?: string): Date;
  parseInt(value: string, radix?, cultureSelector?: string): number;
  parseFloat(value: string, radix?, cultureSelector?: string): number;
}

declare module 'globalize' {
  var Globalize: GlobalizeStatic;
  
}

// Type definitions for jsTimezoneDetect
// Project: https://bitbucket.org/pellepim/jstimezonedetect
// Definitions by: Olivier Lamothe <https://github.com/olamothe/>
// Definitions: https://github.com/DefinitelyTyped/DefinitelyTyped

interface JsTimezoneDetect {
  determine: ()=> {
    name: ()=> string;
  }
}

declare var jstimezonedetect: JsTimezoneDetect;

declare module "jstimezonedetect" {
  
}

declare namespace CoveoAnalytics {
  interface Response {}

  interface SearchDocument {
    documentUri: string;
    documentUriHash: string;
  }

  interface EventBaseRequest {
    language?: string;
    userAgent?: string;
    customData?: any;
    anonymous?: boolean;
    username?: string;
    userDisplayName?: any;
    splitTestRunName?: string;
    splitTestRunVersion?: string;

    originLevel1?: string;
    originLevel2?: string;
    originLevel3?: string;
  }

  interface SearchEventRequest extends EventBaseRequest {
    searchQueryUid: string;
    queryText: string;
    actionCause: string;
    responseTime: number;
    advancedQuery?: string;
    numberOfResults?: number;
    contextual?: boolean;
    results?: SearchDocument[];
    queryPipeline?: string;
    userGroups?: string[];
  }

  interface ClickEventRequest extends EventBaseRequest {
    documentUri: string;
    documentUriHash: string;
    collectionName: string;
    sourceName: string;
    documentPosition: number;
    actionCause: string;

    searchQueryUid?: string;
    documentTitle?: string;
    documentUrl?: string;
    documentAuthor?: string;
    queryPipeline?: string;
    rankingModifier?: string;
  }

  interface CustomEventRequest extends EventBaseRequest {
    eventType: string;
    eventValue: string;
    lastSearchQueryUid?: string;
  }

  interface ViewEventRequest extends EventBaseRequest {
    location: string;
    referrer?: string;
    title?: string;
    contentIdKey?: string;
    contentIdValue?: string;
    contentType?: string;
  }

  interface DefaultEventResponse {
    raw: Response;
    visitId: string;
    visitorId: string;
  }

  interface SearchEventResponse extends DefaultEventResponse {}

  interface ClickEventResponse extends DefaultEventResponse {}

  interface CustomEventResponse extends DefaultEventResponse {}

  interface ViewEventResponse extends DefaultEventResponse {}

  interface VisitResponse {
    raw: Response;
    id: string;
    visitorId: string;
  }

  interface HealthResponse {
    raw: Response;
    status: string;
  }

  interface Client {
    sendEvent(eventType: string, request: any): Promise<Response>;
    sendSearchEvent(request: SearchEventRequest): Promise<SearchEventResponse>;
    sendClickEvent(request: ClickEventRequest): Promise<ClickEventResponse>;
    sendCustomEvent(request: CustomEventRequest): Promise<CustomEventResponse>;
    sendViewEvent(request: ViewEventRequest): Promise<ViewEventResponse>;
    getVisit(): Promise<VisitResponse>;
    getHealth(): Promise<HealthResponse>;
  }

  class HistoryStore {
    constructor();

    addElement(elem: HistoryElement): void;

    getHistory(): HistoryElement[];

    setHistory(history: HistoryElement[]): void;
    clear(): void;

    getMostRecentElement(): HistoryElement;
  }

  interface History {
    HistoryStore: {
      new (storage?: WebStorage): HistoryStore;
    };
  }

  type HistoryElement = HistoryViewElement | HistoryQueryElement | any;
  interface HistoryViewElement {
    type: string;
    uri: string;
    title?: string;
  }

  interface HistoryQueryElement {
    name: string;
    value: string;
    time: string;
  }

  interface AnalyticsClient {
    Client: Client;
  }

  class SimpleAPI {
    

    init(token: string | Client, endpoint: string): void;

    send(event: EventType, customData: any): void;

    onLoad(callback: Function): void;
  }

  interface WebStorage {
    getItem(key: string): string;
    removeItem(key: string): void;
    setItem(key: string, data: string): void;
  }
  let preferredStorage: WebStorage;

  function getAvailableStorage(): WebStorage;

  class NullStorage implements WebStorage {
    getItem(key: string): string;

    removeItem(key: string): void;

    setItem(key: string, data: string): void;
  }

  class CookieStorage implements WebStorage {
    getItem(key: string): string;

    removeItem(key: string): void;

    setItem(key: string, data: string): void;
  }

  type EventType = 'pageview';
}

interface IterableIterator<T> {}
interface Iterable<T> {}

interface Map<K, V> {
  clear(): void;
  delete(key: K): boolean;
  forEach(callbackfn: (value: V, index: K, map: Map<K, V>) => void, thisArg?: any): void;
  get(key: K): V;
  has(key: K): boolean;
  set(key: K, value?: V): Map<K, V>;
  size: number;
}

interface MapConstructor {
  new <K, V>(): Map<K, V>;
  prototype: Map<any, any>;
}
declare var Map: MapConstructor;
