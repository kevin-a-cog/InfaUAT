function fnCallCoveoInProduct() {
    try {
        (function (w) {

            try {

                var CoveoInProduct;
                (() => {
                    var e = {
                        207: function (e) {
                            e.exports = function () {
                                "use strict";
                                function e(t) {
                                    return e = "function" == typeof Symbol && "symbol" == typeof Symbol.iterator ? function (e) {
                                        return typeof e
                                    }
                                     : function (e) {
                                        return e && "function" == typeof Symbol && e.constructor === Symbol && e !== Symbol.prototype ? "symbol" : typeof e
                                    },
                                    e(t)
                                }
                                var t = /^\s+/,
                                n = /\s+$/;
                                function i(e, t) {
                                    if (t = t || {}, (e = e ? e : "")instanceof i)
                                        return e;
                                    if (!(this instanceof i))
                                        return new i(e, t);
                                    var n = r(e);
                                    if (this._originalInput = e, this._r = n.r, this._g = n.g, this._b = n.b, this._a = n.a, this._roundA = Math.round(100 * this._a) / 100, this._format = t.format || n.format, this._gradientType = t.gradientType, this._r < 1)
                                        this._r = Math.round(this._r);
                                    if (this._g < 1)
                                        this._g = Math.round(this._g);
                                    if (this._b < 1)
                                        this._b = Math.round(this._b);
                                    this._ok = n.ok
                                }
                                function r(t) {
                                    var n = {
                                        r: 0,
                                        g: 0,
                                        b: 0
                                    },
                                    i = 1,
                                    r = null,
                                    s = null,
                                    c = null,
                                    u = !1,
                                    d = !1;
                                    if ("string" == typeof t)
                                        t = q(t);
                                    if ("object" == e(t)) {
                                        if (N(t.r) && N(t.g) && N(t.b))
                                            n = o(t.r, t.g, t.b), u = !0, d = "%" === String(t.r).substr(-1) ? "prgb" : "rgb";
                                        else if (N(t.h) && N(t.s) && N(t.v))
                                            r = L(t.s), s = L(t.v), n = l(t.h, r, s), u = !0, d = "hsv";
                                        else if (N(t.h) && N(t.s) && N(t.l))
                                            r = L(t.s), c = L(t.l), n = a(t.h, r, c), u = !0, d = "hsl";
                                        if (t.hasOwnProperty("a"))
                                            i = t.a
                                    }
                                    return i = E(i), {
                                        ok: u,
                                        format: t.format || d,
                                        r: Math.min(255, Math.max(n.r, 0)),
                                        g: Math.min(255, Math.max(n.g, 0)),
                                        b: Math.min(255, Math.max(n.b, 0)),
                                        a: i
                                    }
                                }
                                function o(e, t, n) {
                                    return {
                                        r: 255 * _(e, 255),
                                        g: 255 * _(t, 255),
                                        b: 255 * _(n, 255)
                                    }
                                }
                                function s(e, t, n) {
                                    e = _(e, 255),
                                    t = _(t, 255),
                                    n = _(n, 255);
                                    var i,
                                    r,
                                    o = Math.max(e, t, n),
                                    s = Math.min(e, t, n),
                                    a = (o + s) / 2;
                                    if (o == s)
                                        i = r = 0;
                                    else {
                                        var c = o - s;
                                        switch (r = a > .5 ? c / (2 - o - s) : c / (o + s), o) {
                                        case e:
                                            i = (t - n) / c + (t < n ? 6 : 0);
                                            break;
                                        case t:
                                            i = (n - e) / c + 2;
                                            break;
                                        case n:
                                            i = (e - t) / c + 4;
                                            break
                                        }
                                        i /= 6
                                    }
                                    return {
                                        h: i,
                                        s: r,
                                        l: a
                                    }
                                }
                                function a(e, t, n) {
                                    var i,
                                    r,
                                    o;
                                    function s(e, t, n) {
                                        if (n < 0)
                                            n += 1;
                                        if (n > 1)
                                            n -= 1;
                                        if (n < 1 / 6)
                                            return e + 6 * (t - e) * n;
                                        if (n < .5)
                                            return t;
                                        if (n < 2 / 3)
                                            return e + (t - e) * (2 / 3 - n) * 6;
                                        else
                                            return e
                                    }
                                    if (e = _(e, 360), t = _(t, 100), n = _(n, 100), 0 === t)
                                        i = r = o = n;
                                    else {
                                        var a = n < .5 ? n * (1 + t) : n + t - n * t,
                                        c = 2 * n - a;
                                        i = s(c, a, e + 1 / 3),
                                        r = s(c, a, e),
                                        o = s(c, a, e - 1 / 3)
                                    }
                                    return {
                                        r: 255 * i,
                                        g: 255 * r,
                                        b: 255 * o
                                    }
                                }
                                function c(e, t, n) {
                                    e = _(e, 255),
                                    t = _(t, 255),
                                    n = _(n, 255);
                                    var i,
                                    r,
                                    o = Math.max(e, t, n),
                                    s = Math.min(e, t, n),
                                    a = o,
                                    c = o - s;
                                    if (r = 0 === o ? 0 : c / o, o == s)
                                        i = 0;
                                    else {
                                        switch (o) {
                                        case e:
                                            i = (t - n) / c + (t < n ? 6 : 0);
                                            break;
                                        case t:
                                            i = (n - e) / c + 2;
                                            break;
                                        case n:
                                            i = (e - t) / c + 4;
                                            break
                                        }
                                        i /= 6
                                    }
                                    return {
                                        h: i,
                                        s: r,
                                        v: a
                                    }
                                }
                                function l(e, t, n) {
                                    e = 6 * _(e, 360),
                                    t = _(t, 100),
                                    n = _(n, 100);
                                    var i = Math.floor(e),
                                    r = e - i,
                                    o = n * (1 - t),
                                    s = n * (1 - r * t),
                                    a = n * (1 - (1 - r) * t),
                                    c = i % 6;
                                    return {
                                        r: 255 * [n, s, o, o, a, n][c],
                                        g: 255 * [a, n, n, s, o, o][c],
                                        b: 255 * [o, o, a, n, n, s][c]
                                    }
                                }
                                function u(e, t, n, i) {
                                    var r = [P(Math.round(e).toString(16)), P(Math.round(t).toString(16)), P(Math.round(n).toString(16))];
                                    if (i && r[0].charAt(0) == r[0].charAt(1) && r[1].charAt(0) == r[1].charAt(1) && r[2].charAt(0) == r[2].charAt(1))
                                        return r[0].charAt(0) + r[1].charAt(0) + r[2].charAt(0);
                                    else
                                        return r.join("")
                                }
                                function d(e, t, n, i, r) {
                                    var o = [P(Math.round(e).toString(16)), P(Math.round(t).toString(16)), P(Math.round(n).toString(16)), P(H(i))];
                                    if (r && o[0].charAt(0) == o[0].charAt(1) && o[1].charAt(0) == o[1].charAt(1) && o[2].charAt(0) == o[2].charAt(1) && o[3].charAt(0) == o[3].charAt(1))
                                        return o[0].charAt(0) + o[1].charAt(0) + o[2].charAt(0) + o[3].charAt(0);
                                    else
                                        return o.join("")
                                }
                                function f(e, t, n, i) {
                                    return [P(H(i)), P(Math.round(e).toString(16)), P(Math.round(t).toString(16)), P(Math.round(n).toString(16))].join("")
                                }
                                function h(e, t) {
                                    t = 0 === t ? 0 : t || 10;
                                    var n = i(e).toHsl();
                                    return n.s -= t / 100,
                                    n.s = M(n.s),
                                    i(n)
                                }
                                function p(e, t) {
                                    t = 0 === t ? 0 : t || 10;
                                    var n = i(e).toHsl();
                                    return n.s += t / 100,
                                    n.s = M(n.s),
                                    i(n)
                                }
                                function g(e) {
                                    return i(e).desaturate(100)
                                }
                                function m(e, t) {
                                    t = 0 === t ? 0 : t || 10;
                                    var n = i(e).toHsl();
                                    return n.l += t / 100,
                                    n.l = M(n.l),
                                    i(n)
                                }
                                function v(e, t) {
                                    t = 0 === t ? 0 : t || 10;
                                    var n = i(e).toRgb();
                                    return n.r = Math.max(0, Math.min(255, n.r - Math.round(-t / 100 * 255))),
                                    n.g = Math.max(0, Math.min(255, n.g - Math.round(-t / 100 * 255))),
                                    n.b = Math.max(0, Math.min(255, n.b - Math.round(-t / 100 * 255))),
                                    i(n)
                                }
                                function y(e, t) {
                                    t = 0 === t ? 0 : t || 10;
                                    var n = i(e).toHsl();
                                    return n.l -= t / 100,
                                    n.l = M(n.l),
                                    i(n)
                                }
                                function b(e, t) {
                                    var n = i(e).toHsl(),
                                    r = (n.h + t) % 360;
                                    return n.h = r < 0 ? 360 + r : r,
                                    i(n)
                                }
                                function w(e) {
                                    var t = i(e).toHsl();
                                    return t.h = (t.h + 180) % 360,
                                    i(t)
                                }
                                function x(e, t) {
                                    if (isNaN(t) || t <= 0)
                                        throw new Error("Argument to polyad must be a positive number");
                                    for (var n = i(e).toHsl(), r = [i(e)], o = 360 / t, s = 1; s < t; s++)
                                        r.push(i({
                                                h: (n.h + s * o) % 360,
                                                s: n.s,
                                                l: n.l
                                            }));
                                    return r
                                }
                                function S(e) {
                                    var t = i(e).toHsl(),
                                    n = t.h;
                                    return [i(e), i({
                                            h: (n + 72) % 360,
                                            s: t.s,
                                            l: t.l
                                        }), i({
                                            h: (n + 216) % 360,
                                            s: t.s,
                                            l: t.l
                                        })]
                                }
                                function k(e, t, n) {
                                    t = t || 6,
                                    n = n || 30;
                                    var r = i(e).toHsl(),
                                    o = 360 / n,
                                    s = [i(e)];
                                    for (r.h = (r.h - (o * t >> 1) + 720) % 360; --t; )
                                        r.h = (r.h + o) % 360, s.push(i(r));
                                    return s
                                }
                                function O(e, t) {
                                    t = t || 6;
                                    for (var n = i(e).toHsv(), r = n.h, o = n.s, s = n.v, a = [], c = 1 / t; t--; )
                                        a.push(i({
                                                h: r,
                                                s: o,
                                                v: s
                                            })), s = (s + c) % 1;
                                    return a
                                }
                                i.prototype = {
                                    isDark: function () {
                                        return this.getBrightness() < 128
                                    },
                                    isLight: function () {
                                        return !this.isDark()
                                    },
                                    isValid: function () {
                                        return this._ok
                                    },
                                    getOriginalInput: function () {
                                        return this._originalInput
                                    },
                                    getFormat: function () {
                                        return this._format
                                    },
                                    getAlpha: function () {
                                        return this._a
                                    },
                                    getBrightness: function () {
                                        var e = this.toRgb();
                                        return (299 * e.r + 587 * e.g + 114 * e.b) / 1e3
                                    },
                                    getLuminance: function () {
                                        var e,
                                        t,
                                        n,
                                        i,
                                        r,
                                        o,
                                        s = this.toRgb();
                                        if (e = s.r / 255, t = s.g / 255, n = s.b / 255, e <= .03928)
                                            i = e / 12.92;
                                        else
                                            i = Math.pow((e + .055) / 1.055, 2.4);
                                        if (t <= .03928)
                                            r = t / 12.92;
                                        else
                                            r = Math.pow((t + .055) / 1.055, 2.4);
                                        if (n <= .03928)
                                            o = n / 12.92;
                                        else
                                            o = Math.pow((n + .055) / 1.055, 2.4);
                                        return .2126 * i + .7152 * r + .0722 * o
                                    },
                                    setAlpha: function (e) {
                                        return this._a = E(e),
                                        this._roundA = Math.round(100 * this._a) / 100,
                                        this
                                    },
                                    toHsv: function () {
                                        var e = c(this._r, this._g, this._b);
                                        return {
                                            h: 360 * e.h,
                                            s: e.s,
                                            v: e.v,
                                            a: this._a
                                        }
                                    },
                                    toHsvString: function () {
                                        var e = c(this._r, this._g, this._b),
                                        t = Math.round(360 * e.h),
                                        n = Math.round(100 * e.s),
                                        i = Math.round(100 * e.v);
                                        return 1 == this._a ? "hsv(" + t + ", " + n + "%, " + i + "%)" : "hsva(" + t + ", " + n + "%, " + i + "%, " + this._roundA + ")"
                                    },
                                    toHsl: function () {
                                        var e = s(this._r, this._g, this._b);
                                        return {
                                            h: 360 * e.h,
                                            s: e.s,
                                            l: e.l,
                                            a: this._a
                                        }
                                    },
                                    toHslString: function () {
                                        var e = s(this._r, this._g, this._b),
                                        t = Math.round(360 * e.h),
                                        n = Math.round(100 * e.s),
                                        i = Math.round(100 * e.l);
                                        return 1 == this._a ? "hsl(" + t + ", " + n + "%, " + i + "%)" : "hsla(" + t + ", " + n + "%, " + i + "%, " + this._roundA + ")"
                                    },
                                    toHex: function (e) {
                                        return u(this._r, this._g, this._b, e)
                                    },
                                    toHexString: function (e) {
                                        return "#" + this.toHex(e)
                                    },
                                    toHex8: function (e) {
                                        return d(this._r, this._g, this._b, this._a, e)
                                    },
                                    toHex8String: function (e) {
                                        return "#" + this.toHex8(e)
                                    },
                                    toRgb: function () {
                                        return {
                                            r: Math.round(this._r),
                                            g: Math.round(this._g),
                                            b: Math.round(this._b),
                                            a: this._a
                                        }
                                    },
                                    toRgbString: function () {
                                        return 1 == this._a ? "rgb(" + Math.round(this._r) + ", " + Math.round(this._g) + ", " + Math.round(this._b) + ")" : "rgba(" + Math.round(this._r) + ", " + Math.round(this._g) + ", " + Math.round(this._b) + ", " + this._roundA + ")"
                                    },
                                    toPercentageRgb: function () {
                                        return {
                                            r: Math.round(100 * _(this._r, 255)) + "%",
                                            g: Math.round(100 * _(this._g, 255)) + "%",
                                            b: Math.round(100 * _(this._b, 255)) + "%",
                                            a: this._a
                                        }
                                    },
                                    toPercentageRgbString: function () {
                                        return 1 == this._a ? "rgb(" + Math.round(100 * _(this._r, 255)) + "%, " + Math.round(100 * _(this._g, 255)) + "%, " + Math.round(100 * _(this._b, 255)) + "%)" : "rgba(" + Math.round(100 * _(this._r, 255)) + "%, " + Math.round(100 * _(this._g, 255)) + "%, " + Math.round(100 * _(this._b, 255)) + "%, " + this._roundA + ")"
                                    },
                                    toName: function () {
                                        if (0 === this._a)
                                            return "transparent";
                                        if (this._a < 1)
                                            return !1;
                                        else
                                            return A[u(this._r, this._g, this._b, !0)] || !1
                                    },
                                    toFilter: function (e) {
                                        var t = "#" + f(this._r, this._g, this._b, this._a),
                                        n = t,
                                        r = this._gradientType ? "GradientType = 1, " : "";
                                        if (e) {
                                            var o = i(e);
                                            n = "#" + f(o._r, o._g, o._b, o._a)
                                        }
                                        return "progid:DXImageTransform.Microsoft.gradient(" + r + "startColorstr=" + t + ",endColorstr=" + n + ")"
                                    },
                                    toString: function (e) {
                                        var t = !!e;
                                        e = e || this._format;
                                        var n = !1,
                                        i = this._a < 1 && this._a >= 0;
                                        if (!t && i && ("hex" === e || "hex6" === e || "hex3" === e || "hex4" === e || "hex8" === e || "name" === e))
                                            if ("name" === e && 0 === this._a)
                                                return this.toName();
                                            else
                                                return this.toRgbString();
                                        if ("rgb" === e)
                                            n = this.toRgbString();
                                        if ("prgb" === e)
                                            n = this.toPercentageRgbString();
                                        if ("hex" === e || "hex6" === e)
                                            n = this.toHexString();
                                        if ("hex3" === e)
                                            n = this.toHexString(!0);
                                        if ("hex4" === e)
                                            n = this.toHex8String(!0);
                                        if ("hex8" === e)
                                            n = this.toHex8String();
                                        if ("name" === e)
                                            n = this.toName();
                                        if ("hsl" === e)
                                            n = this.toHslString();
                                        if ("hsv" === e)
                                            n = this.toHsvString();
                                        return n || this.toHexString()
                                    },
                                    clone: function () {
                                        return i(this.toString())
                                    },
                                    _applyModification: function (e, t) {
                                        var n = e.apply(null, [this].concat([].slice.call(t)));
                                        return this._r = n._r,
                                        this._g = n._g,
                                        this._b = n._b,
                                        this.setAlpha(n._a),
                                        this
                                    },
                                    lighten: function () {
                                        return this._applyModification(m, arguments)
                                    },
                                    brighten: function () {
                                        return this._applyModification(v, arguments)
                                    },
                                    darken: function () {
                                        return this._applyModification(y, arguments)
                                    },
                                    desaturate: function () {
                                        return this._applyModification(h, arguments)
                                    },
                                    saturate: function () {
                                        return this._applyModification(p, arguments)
                                    },
                                    greyscale: function () {
                                        return this._applyModification(g, arguments)
                                    },
                                    spin: function () {
                                        return this._applyModification(b, arguments)
                                    },
                                    _applyCombination: function (e, t) {
                                        return e.apply(null, [this].concat([].slice.call(t)))
                                    },
                                    analogous: function () {
                                        return this._applyCombination(k, arguments)
                                    },
                                    complement: function () {
                                        return this._applyCombination(w, arguments)
                                    },
                                    monochromatic: function () {
                                        return this._applyCombination(O, arguments)
                                    },
                                    splitcomplement: function () {
                                        return this._applyCombination(S, arguments)
                                    },
                                    triad: function () {
                                        return this._applyCombination(x, [3])
                                    },
                                    tetrad: function () {
                                        return this._applyCombination(x, [4])
                                    }
                                },
                                i.fromRatio = function (t, n) {
                                    if ("object" == e(t)) {
                                        var r = {};
                                        for (var o in t)
                                            if (t.hasOwnProperty(o))
                                                if ("a" === o)
                                                    r[o] = t[o];
                                                else
                                                    r[o] = L(t[o]);
                                        t = r
                                    }
                                    return i(t, n)
                                },
                                i.equals = function (e, t) {
                                    if (!e || !t)
                                        return !1;
                                    else
                                        return i(e).toRgbString() == i(t).toRgbString()
                                },
                                i.random = function () {
                                    return i.fromRatio({
                                        r: Math.random(),
                                        g: Math.random(),
                                        b: Math.random()
                                    })
                                },
                                i.mix = function (e, t, n) {
                                    n = 0 === n ? 0 : n || 50;
                                    var r = i(e).toRgb(),
                                    o = i(t).toRgb(),
                                    s = n / 100;
                                    return i({
                                        r: (o.r - r.r) * s + r.r,
                                        g: (o.g - r.g) * s + r.g,
                                        b: (o.b - r.b) * s + r.b,
                                        a: (o.a - r.a) * s + r.a
                                    })
                                },
                                i.readability = function (e, t) {
                                    var n = i(e),
                                    r = i(t);
                                    return (Math.max(n.getLuminance(), r.getLuminance()) + .05) / (Math.min(n.getLuminance(), r.getLuminance()) + .05)
                                },
                                i.isReadable = function (e, t, n) {
                                    var r,
                                    o,
                                    s = i.readability(e, t);
                                    switch (o = !1, (r = W(n)).level + r.size) {
                                    case "AAsmall":
                                    case "AAAlarge":
                                        o = s >= 4.5;
                                        break;
                                    case "AAlarge":
                                        o = s >= 3;
                                        break;
                                    case "AAAsmall":
                                        o = s >= 7;
                                        break
                                    }
                                    return o
                                },
                                i.mostReadable = function (e, t, n) {
                                    var r,
                                    o,
                                    s,
                                    a,
                                    c = null,
                                    l = 0;
                                    o = (n = n || {}).includeFallbackColors,
                                    s = n.level,
                                    a = n.size;
                                    for (var u = 0; u < t.length; u++)
                                        if ((r = i.readability(e, t[u])) > l)
                                            l = r, c = i(t[u]);
                                    if (i.isReadable(e, c, {
                                            level: s,
                                            size: a
                                        }) || !o)
                                        return c;
                                    else
                                        return n.includeFallbackColors = !1, i.mostReadable(e, ["#fff", "#000"], n)
                                };
                                var I = i.names = {
                                    aliceblue: "f0f8ff",
                                    antiquewhite: "faebd7",
                                    aqua: "0ff",
                                    aquamarine: "7fffd4",
                                    azure: "f0ffff",
                                    beige: "f5f5dc",
                                    bisque: "ffe4c4",
                                    black: "000",
                                    blanchedalmond: "ffebcd",
                                    blue: "00f",
                                    blueviolet: "8a2be2",
                                    brown: "a52a2a",
                                    burlywood: "deb887",
                                    burntsienna: "ea7e5d",
                                    cadetblue: "5f9ea0",
                                    chartreuse: "7fff00",
                                    chocolate: "d2691e",
                                    coral: "ff7f50",
                                    cornflowerblue: "6495ed",
                                    cornsilk: "fff8dc",
                                    crimson: "dc143c",
                                    cyan: "0ff",
                                    darkblue: "00008b",
                                    darkcyan: "008b8b",
                                    darkgoldenrod: "b8860b",
                                    darkgray: "a9a9a9",
                                    darkgreen: "006400",
                                    darkgrey: "a9a9a9",
                                    darkkhaki: "bdb76b",
                                    darkmagenta: "8b008b",
                                    darkolivegreen: "556b2f",
                                    darkorange: "ff8c00",
                                    darkorchid: "9932cc",
                                    darkred: "8b0000",
                                    darksalmon: "e9967a",
                                    darkseagreen: "8fbc8f",
                                    darkslateblue: "483d8b",
                                    darkslategray: "2f4f4f",
                                    darkslategrey: "2f4f4f",
                                    darkturquoise: "00ced1",
                                    darkviolet: "9400d3",
                                    deeppink: "ff1493",
                                    deepskyblue: "00bfff",
                                    dimgray: "696969",
                                    dimgrey: "696969",
                                    dodgerblue: "1e90ff",
                                    firebrick: "b22222",
                                    floralwhite: "fffaf0",
                                    forestgreen: "228b22",
                                    fuchsia: "f0f",
                                    gainsboro: "dcdcdc",
                                    ghostwhite: "f8f8ff",
                                    gold: "ffd700",
                                    goldenrod: "daa520",
                                    gray: "808080",
                                    green: "008000",
                                    greenyellow: "adff2f",
                                    grey: "808080",
                                    honeydew: "f0fff0",
                                    hotpink: "ff69b4",
                                    indianred: "cd5c5c",
                                    indigo: "4b0082",
                                    ivory: "fffff0",
                                    khaki: "f0e68c",
                                    lavender: "e6e6fa",
                                    lavenderblush: "fff0f5",
                                    lawngreen: "7cfc00",
                                    lemonchiffon: "fffacd",
                                    lightblue: "add8e6",
                                    lightcoral: "f08080",
                                    lightcyan: "e0ffff",
                                    lightgoldenrodyellow: "fafad2",
                                    lightgray: "d3d3d3",
                                    lightgreen: "90ee90",
                                    lightgrey: "d3d3d3",
                                    lightpink: "ffb6c1",
                                    lightsalmon: "ffa07a",
                                    lightseagreen: "20b2aa",
                                    lightskyblue: "87cefa",
                                    lightslategray: "789",
                                    lightslategrey: "789",
                                    lightsteelblue: "b0c4de",
                                    lightyellow: "ffffe0",
                                    lime: "0f0",
                                    limegreen: "32cd32",
                                    linen: "faf0e6",
                                    magenta: "f0f",
                                    maroon: "800000",
                                    mediumaquamarine: "66cdaa",
                                    mediumblue: "0000cd",
                                    mediumorchid: "ba55d3",
                                    mediumpurple: "9370db",
                                    mediumseagreen: "3cb371",
                                    mediumslateblue: "7b68ee",
                                    mediumspringgreen: "00fa9a",
                                    mediumturquoise: "48d1cc",
                                    mediumvioletred: "c71585",
                                    midnightblue: "191970",
                                    mintcream: "f5fffa",
                                    mistyrose: "ffe4e1",
                                    moccasin: "ffe4b5",
                                    navajowhite: "ffdead",
                                    navy: "000080",
                                    oldlace: "fdf5e6",
                                    olive: "808000",
                                    olivedrab: "6b8e23",
                                    orange: "ffa500",
                                    orangered: "ff4500",
                                    orchid: "da70d6",
                                    palegoldenrod: "eee8aa",
                                    palegreen: "98fb98",
                                    paleturquoise: "afeeee",
                                    palevioletred: "db7093",
                                    papayawhip: "ffefd5",
                                    peachpuff: "ffdab9",
                                    peru: "cd853f",
                                    pink: "ffc0cb",
                                    plum: "dda0dd",
                                    powderblue: "b0e0e6",
                                    purple: "800080",
                                    rebeccapurple: "663399",
                                    red: "f00",
                                    rosybrown: "bc8f8f",
                                    royalblue: "4169e1",
                                    saddlebrown: "8b4513",
                                    salmon: "fa8072",
                                    sandybrown: "f4a460",
                                    seagreen: "2e8b57",
                                    seashell: "fff5ee",
                                    sienna: "a0522d",
                                    silver: "c0c0c0",
                                    skyblue: "87ceeb",
                                    slateblue: "6a5acd",
                                    slategray: "708090",
                                    slategrey: "708090",
                                    snow: "fffafa",
                                    springgreen: "00ff7f",
                                    steelblue: "4682b4",
                                    tan: "d2b48c",
                                    teal: "008080",
                                    thistle: "d8bfd8",
                                    tomato: "ff6347",
                                    turquoise: "40e0d0",
                                    violet: "ee82ee",
                                    wheat: "f5deb3",
                                    white: "fff",
                                    whitesmoke: "f5f5f5",
                                    yellow: "ff0",
                                    yellowgreen: "9acd32"
                                },
                                A = i.hexNames = C(I);
                                function C(e) {
                                    var t = {};
                                    for (var n in e)
                                        if (e.hasOwnProperty(n))
                                            t[e[n]] = n;
                                    return t
                                }
                                function E(e) {
                                    if (e = parseFloat(e), isNaN(e) || e < 0 || e > 1)
                                        e = 1;
                                    return e
                                }
                                function _(e, t) {
                                    if (j(e))
                                        e = "100%";
                                    var n = T(e);
                                    if (e = Math.min(t, Math.max(0, parseFloat(e))), n)
                                        e = parseInt(e * t, 10) / 100;
                                    if (Math.abs(e - t) < 1e-6)
                                        return 1;
                                    else
                                        return e % t / parseFloat(t)
                                }
                                function M(e) {
                                    return Math.min(1, Math.max(0, e))
                                }
                                function R(e) {
                                    return parseInt(e, 16)
                                }
                                function j(e) {
                                    return "string" == typeof e && -1 != e.indexOf(".") && 1 === parseFloat(e)
                                }
                                function T(e) {
                                    return "string" == typeof e && -1 != e.indexOf("%")
                                }
                                function P(e) {
                                    return 1 == e.length ? "0" + e : "" + e
                                }
                                function L(e) {
                                    if (e <= 1)
                                        e = 100 * e + "%";
                                    return e
                                }
                                function H(e) {
                                    return Math.round(255 * parseFloat(e)).toString(16)
                                }
                                function F(e) {
                                    return R(e) / 255
                                }
                                var V,
                                $,
                                U,
                                D = ($ = "[\\s|\\(]+(" + (V = "(?:[-\\+]?\\d*\\.\\d+%?)|(?:[-\\+]?\\d+%?)") + ")[,|\\s]+(" + V + ")[,|\\s]+(" + V + ")\\s*\\)?", U = "[\\s|\\(]+(" + V + ")[,|\\s]+(" + V + ")[,|\\s]+(" + V + ")[,|\\s]+(" + V + ")\\s*\\)?", {
                                    CSS_UNIT: new RegExp(V),
                                    rgb: new RegExp("rgb" + $),
                                    rgba: new RegExp("rgba" + U),
                                    hsl: new RegExp("hsl" + $),
                                    hsla: new RegExp("hsla" + U),
                                    hsv: new RegExp("hsv" + $),
                                    hsva: new RegExp("hsva" + U),
                                    hex3: /^#?([0-9a-fA-F]{1})([0-9a-fA-F]{1})([0-9a-fA-F]{1})$/,
                                    hex6: /^#?([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$/,
                                    hex4: /^#?([0-9a-fA-F]{1})([0-9a-fA-F]{1})([0-9a-fA-F]{1})([0-9a-fA-F]{1})$/,
                                    hex8: /^#?([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})$/
                                });
                                function N(e) {
                                    return !!D.CSS_UNIT.exec(e)
                                }
                                function q(e) {
                                    e = e.replace(t, "").replace(n, "").toLowerCase();
                                    var i,
                                    r = !1;
                                    if (I[e])
                                        e = I[e], r = !0;
                                    else if ("transparent" == e)
                                        return {
                                            r: 0,
                                            g: 0,
                                            b: 0,
                                            a: 0,
                                            format: "name"
                                        };
                                    if (i = D.rgb.exec(e))
                                        return {
                                            r: i[1],
                                            g: i[2],
                                            b: i[3]
                                        };
                                    if (i = D.rgba.exec(e))
                                        return {
                                            r: i[1],
                                            g: i[2],
                                            b: i[3],
                                            a: i[4]
                                        };
                                    if (i = D.hsl.exec(e))
                                        return {
                                            h: i[1],
                                            s: i[2],
                                            l: i[3]
                                        };
                                    if (i = D.hsla.exec(e))
                                        return {
                                            h: i[1],
                                            s: i[2],
                                            l: i[3],
                                            a: i[4]
                                        };
                                    if (i = D.hsv.exec(e))
                                        return {
                                            h: i[1],
                                            s: i[2],
                                            v: i[3]
                                        };
                                    if (i = D.hsva.exec(e))
                                        return {
                                            h: i[1],
                                            s: i[2],
                                            v: i[3],
                                            a: i[4]
                                        };
                                    if (i = D.hex8.exec(e))
                                        return {
                                            r: R(i[1]),
                                            g: R(i[2]),
                                            b: R(i[3]),
                                            a: F(i[4]),
                                            format: r ? "name" : "hex8"
                                        };
                                    if (i = D.hex6.exec(e))
                                        return {
                                            r: R(i[1]),
                                            g: R(i[2]),
                                            b: R(i[3]),
                                            format: r ? "name" : "hex"
                                        };
                                    if (i = D.hex4.exec(e))
                                        return {
                                            r: R(i[1] + "" + i[1]),
                                            g: R(i[2] + "" + i[2]),
                                            b: R(i[3] + "" + i[3]),
                                            a: F(i[4] + "" + i[4]),
                                            format: r ? "name" : "hex8"
                                        };
                                    if (i = D.hex3.exec(e))
                                        return {
                                            r: R(i[1] + "" + i[1]),
                                            g: R(i[2] + "" + i[2]),
                                            b: R(i[3] + "" + i[3]),
                                            format: r ? "name" : "hex"
                                        };
                                    else
                                        return !1
                                }
                                function W(e) {
                                    var t,
                                    n;
                                    if ("AA" !== (t = ((e = e || {
                                                        level: "AA",
                                                        size: "small"
                                                    }).level || "AA").toUpperCase()) && "AAA" !== t)
                                        t = "AA";
                                    if ("small" !== (n = (e.size || "small").toLowerCase()) && "large" !== n)
                                        n = "small";
                                    return {
                                        level: t,
                                        size: n
                                    }
                                }
                                return i
                            }
                            ()
                        }
                    },
                    t = {};
                    function n(i) {
                        var r = t[i];
                        if (void 0 !== r)
                            return r.exports;
                        var o = t[i] = {
                            exports: {}
                        };
                        return e[i].call(o.exports, o, o.exports, n),
                        o.exports
                    }
                    n.d = (e, t) => {
                        for (var i in t)
                            if (n.o(t, i) && !n.o(e, i))
                                Object.defineProperty(e, i, {
                                    enumerable: !0,
                                    get: t[i]
                                })
                    },
                    n.o = (e, t) => Object.prototype.hasOwnProperty.call(e, t),
                    n.r = e => {
                        if ("undefined" != typeof Symbol && Symbol.toStringTag)
                            Object.defineProperty(e, Symbol.toStringTag, {
                                value: "Module"
                            });
                        Object.defineProperty(e, "__esModule", {
                            value: !0
                        })
                    };
                    var i = {};
                    (() => {
                        "use strict";
                        n.r(i),
                        n.d(i, {
                            customRenewAccessToken: () => Gn,
                            executeQuery: () => qn,
                            executeRecommendationQuery: () => Wn,
                            hide: () => Kn,
                            onClose: () => Bn,
                            onOpen: () => Qn,
                            setContext: () => Dn,
                            setContextValue: () => Nn,
                            setRenewAccessTokenFunction: () => Jn,
                            doRenewData: () => CoveoInProduct.varAuraControllerSearchToken,
                            show: () => Yn,
                            usingDefaultRenewFunc: () => zn
                        });
                        const e = "#IpxAuraInit",
                        t = CoveoInProductUtility.varAuraControllerSearchToken,
                        r = "https://search.cloud.coveo.com/pages/informaticasandbox/inappwidget/e1067509-2b41-493f-94be-608c476b1afd",
                        o = "<style></style>",
                        s = "",
                        a = "",
                        c = ".btn.mod-primary",
                        l = "	font-size: 12px;	font-family: canada-type-gibson,sans-serif;		bottom: 10px;	left: 50%;	",
                        u = ".btn.mod-primary:hover",
                        d = ".btn.mod-primary:focus",
                        f = "btn mod-primary",
                        h = "Engagement Catalog",
                        p = "<svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"white\" viewBox=\"0 0 22 22\"><path d=\"m11,2c-5 0-9 4-9 9s4 9 9 9 9-4 9-9-4-9-9-9m0 20c-6.1 0-11-4.9-11-11 0-6.1 4.9-11 11-11 6.1 0 11 4.9 11 11 0 6.1-4.9 11-11 11\"/><path d=\"m11,4.7c-2.2 0-4 1.8-4 4h2c0-1.1.9-2 2-2s2 .9 2 2c0 2-3 1.8-3 5h2c0-2.2 3-2.5 3-5 0-2.3-1.8-4-4-4m-1 12.3h2v-2h-2v2\"/></svg>",
                        g = "https://analytics.cloud.coveo.com/rest/ua",
                        m = "e1067509-2b41-493f-94be-608c476b1afd",
                        v = "#e1792d",
                        y = "#202123";
                        class b {
                            constructor() {
                                this.value = new Promise(((e, t) => {
                                            this.resolve = e,
                                            this.reject = t
                                        }))
                            }
                        }
                        var w = function (e, t, n, i) {
                            return new(n || (n = Promise))((function (r, o) {
                                    function s(e) {
                                        try {
                                            c(i.next(e))
                                        } catch (e) {
                                            o(e)
                                        }
                                    }
                                    function a(e) {
                                        try {
                                            c(i.throw(e))
                                        } catch (e) {
                                            o(e)
                                        }
                                    }
                                    function c(e) {
                                        var t;
                                        e.done ? r(e.value) : (t = e.value, t instanceof n ? t : new n((function (e) {
                                                    e(t)
                                                }))).then(s, a)
                                    }
                                    c((i = i.apply(e, t || [])).next())
                                }))
                        };
                        class x {
                            constructor() {
                                this.ready = new b
                            }
                            start() {
                                this.ready.resolve(!0)
                            }
                            clear() {
                                this.ready = new b
                            }
                            publish(e) {
                                return w(this, void 0, void 0, (function  * () {
                                        if (yield this.ready.value, this.pub)
                                            this.pub.postMessage(e, this.pub.originToPublishTo)
                                    }))
                            }
                            subscribe(e, t) {
                                return w(this, void 0, void 0, (function  * () {
                                        if (yield this.ready.value, this.sub)
                                            this.sub.addEventListener("message", (n => {
                                                    var i,
                                                    r,
                                                    o,
                                                    s;
                                                    const a = n.origin || (null === (r = null === (i = null == n ? void 0 : n.target) || void 0 === i ? void 0 : i.location) || void 0 === r ? void 0 : r.origin) || "";
                                                    if ("" !== a)
                                                        if ("*" === (null === (o = this.sub) || void 0 === o ? void 0 : o.originToListenFrom) || -1 !== (null === (s = this.sub) || void 0 === s ? void 0 : s.originToListenFrom.indexOf(a)))
                                                            if (n.data.key == e)
                                                                t(n)
                                                }))
                                    }))
                            }
                        }
                        class S {
                            constructor(e = new x) {
                                this.bus = e,
                                this.publishInitialization(),
                                this.publishHref(),
                                this.publishVisitorId()
                            }
                            init(e) {
                                const t = {
                                    postMessage: e.postMessage.bind(e),
                                    originToPublishTo: r
                                },
                                n = {
                                    addEventListener: window.addEventListener.bind(window),
                                    originToListenFrom: r
                                };
                                this.bus.sub = n,
                                this.bus.pub = t,
                                this.bus.start()
                            }
                            publishOpen() {
                                this.bus.publish({
                                    key: "open"
                                })
                            }
                            publishClose() {
                                this.bus.publish({
                                    key: "close"
                                })
                            }
                            publishExecuteQuery(e) {
                                this.bus.publish({
                                    key: "executeQuery",
                                    payload: {
                                        options: e
                                    }
                                })
                            }
                            publishExecuteRecommendationQuery(e) {
                                this.bus.publish({
                                    key: "executeRecommendationQuery",
                                    payload: {
                                        options: e
                                    }
                                })
                            }
                            publishContext(e) {
                                this.bus.publish({
                                    key: "context",
                                    payload: {
                                        context: e
                                    }
                                })
                            }
                            publishContextValue(e, t) {
                                this.bus.publish({
                                    key: "contextValue",
                                    payload: {
                                        contextKey: e,
                                        contextValue: t
                                    }
                                })
                            }
                            publishInitialization() {
                                this.bus.publish({
                                    key: "init",
                                    payload: {
                                        origin: location.origin
                                    }
                                })
                            }
                            publishHref() {
                                this.bus.publish({
                                    key: "href",
                                    payload: {
                                        href: document.location.href
                                    }
                                })
                            }
                            publishVisitorId() {
                                const e = localStorage.getItem("visitorId");
                                if (e)
                                    this.bus.publish({
                                        key: "visitorId",
                                        payload: {
                                            visitorId: e
                                        }
                                    })
                            }
                            subscribeToCustomTokenHasExpired(e) {
                                this.bus.subscribe("customTokenHasExpired", (() => {
                                        e()
                                    }))
                            }
                            publishNewCustomToken(e) {
                                this.bus.publish({
                                    key: "newAccessToken",
                                    payload: {
                                        token: e
                                    }
                                })
                            }
                            customRenewFunctionIsAvailable() {
                                this.bus.publish({
                                    key: "customRenewFunctionIsAvailable"
                                })
                            }
                            subscribeToHeightChanged(e) {
                                this.bus.subscribe("heightChanged", (t => {
                                        e(t.data.payload.currentHeight)
                                    }))
                            }
                        }
                        const k = new S,
                        O = new b;
                        class I extends HTMLElement {
                            constructor() {
                                super(),
                                this.attachShadow({
                                    mode: "open"
                                }),
                                this.applyStyles(),
                                this.iframe = this.buildIFrame(),
                                this.messages = new S,
                                this.iframe.onload = () => this.onIframeLoad(),
                                this.shadowRoot.append(this.iframe)
                            }
                            onIframeLoad() {
                                this.messages.init(this.iframe.contentWindow),
                                O.resolve(this)
                            }
                            applyStyles() {
                                this.style.width = "100%"
                            }
                            buildIFrame() {
                                const e = document.createElement("iframe");
                                return e.setAttribute("src", r + "?access_token=" + t),
                                e.setAttribute("sandbox", "allow-scripts allow-same-origin allow-top-navigation allow-popups allow-popups-to-escape-sandbox"),
                                e.style.height = "100%",
                                e.style.width = "100%",
                                e.style.borderStyle = "none",
                                e.style.borderRadius = "8px",
                                e
                            }
                        }
                        class A extends HTMLElement {
                            constructor() {
                                super(),
                                this.attachShadow({
                                    mode: "open"
                                }),
                                this.page = new I,
                                this.attachPage(),
                                this.applyStyles()
                            }
                            connectedCallback() {
                                this.observeDomChangeInFrame()
                            }
                            set popper(e) {
                                this.popperReference = e
                            }
                            get popper() {
                                return this.popperReference
                            }
                            attachPage() {
                                this.shadowRoot.append(this.page)
                            }
                            observeDomChangeInFrame() {
                                this.page.messages.subscribeToHeightChanged((e => this.adjustModalHeight(e)))
                            }
                            adjustModalHeight(e) {
                                let t;
                                if (e > this.desiredHeight || e < this.desiredHeight)
                                    t = this.desiredHeight;
                                else
                                    t = e;
                                if (this.style.height = `${t}px`, this.popperReference)
                                    this.popperReference.update()
                            }
                            get desiredHeight() {
                                return Math.min(720, document.documentElement.clientHeight)
                            }
                            applyStyles() {
                                this.style.display = "flex",
                                this.style.zIndex = "999999",
                                this.style.backgroundColor = "white",
                                this.style.boxShadow = "0 0 7px rgba(0,0,0,.5)",
                                this.style.height = `${this.desiredHeight}px`,
                                this.style.maxHeight = "80vh",
                                this.style.width = "80vw",
                                this.style.maxWidth = "500px",
                                this.style.opacity = "0",
                                this.style.borderRadius = "8px"
                            }
                        }
                        function C(e) {
                            if (null == e)
                                return window;
                            if ("[object Window]" !== e.toString()) {
                                var t = e.ownerDocument;
                                return t ? t.defaultView || window : window
                            }
                            return e
                        }
                        function E(e) {
                            return e instanceof C(e).Element || e instanceof Element
                        }
                        function _(e) {
                            return e instanceof C(e).HTMLElement || e instanceof HTMLElement
                        }
                        function M(e) {
                            if ("undefined" == typeof ShadowRoot)
                                return !1;
                            else
                                return e instanceof C(e).ShadowRoot || e instanceof ShadowRoot
                        }
                        var R = Math.max,
                        j = Math.min,
                        T = Math.round;
                        function P() {
                            var e = navigator.userAgentData;
                            if (null != e && e.brands && Array.isArray(e.brands))
                                return e.brands.map((function (e) {
                                        return e.brand + "/" + e.version
                                    })).join(" ");
                            else
                                return navigator.userAgent
                        }
                        function L() {
                            return !/^((?!chrome|android).)*safari/i.test(P())
                        }
                        function H(e, t, n) {
                            if (void 0 === t)
                                t = !1;
                            if (void 0 === n)
                                n = !1;
                            var i = e.getBoundingClientRect(),
                            r = 1,
                            o = 1;
                            if (t && _(e))
                                r = e.offsetWidth > 0 ? T(i.width) / e.offsetWidth || 1 : 1, o = e.offsetHeight > 0 ? T(i.height) / e.offsetHeight || 1 : 1;
                            var s = (E(e) ? C(e) : window).visualViewport,
                            a = !L() && n,
                            c = (i.left + (a && s ? s.offsetLeft : 0)) / r,
                            l = (i.top + (a && s ? s.offsetTop : 0)) / o,
                            u = i.width / r,
                            d = i.height / o;
                            return {
                                width: u,
                                height: d,
                                top: l,
                                right: c + u,
                                bottom: l + d,
                                left: c,
                                x: c,
                                y: l
                            }
                        }
                        function F(e) {
                            var t = C(e);
                            return {
                                scrollLeft: t.pageXOffset,
                                scrollTop: t.pageYOffset
                            }
                        }
                        function V(e) {
                            return e ? (e.nodeName || "").toLowerCase() : null
                        }
                        function $(e) {
                            return ((E(e) ? e.ownerDocument : e.document) || window.document).documentElement
                        }
                        function U(e) {
                            return H($(e)).left + F(e).scrollLeft
                        }
                        function D(e) {
                            return C(e).getComputedStyle(e)
                        }
                        function N(e) {
                            var t = D(e),
                            n = t.overflow,
                            i = t.overflowX,
                            r = t.overflowY;
                            return /auto|scroll|overlay|hidden/.test(n + r + i)
                        }
                        function q(e, t, n) {
                            if (void 0 === n)
                                n = !1;
                            var i = _(t),
                            r = _(t) && function (e) {
                                var t = e.getBoundingClientRect(),
                                n = T(t.width) / e.offsetWidth || 1,
                                i = T(t.height) / e.offsetHeight || 1;
                                return 1 !== n || 1 !== i
                            }
                            (t),
                            o = $(t),
                            s = H(e, r, n),
                            a = {
                                scrollLeft: 0,
                                scrollTop: 0
                            },
                            c = {
                                x: 0,
                                y: 0
                            };
                            if (i || !i && !n) {
                                if ("body" !== V(t) || N(o))
                                    a = function (e) {
                                        if (e === C(e) || !_(e))
                                            return F(e);
                                        else
                                            return {
                                                scrollLeft: (t = e).scrollLeft,
                                                scrollTop: t.scrollTop
                                            };
                                        var t
                                    }
                                (t);
                                if (_(t))
                                    (c = H(t, !0)).x += t.clientLeft, c.y += t.clientTop;
                                else if (o)
                                    c.x = U(o)
                            }
                            return {
                                x: s.left + a.scrollLeft - c.x,
                                y: s.top + a.scrollTop - c.y,
                                width: s.width,
                                height: s.height
                            }
                        }
                        function W(e) {
                            var t = H(e),
                            n = e.offsetWidth,
                            i = e.offsetHeight;
                            if (Math.abs(t.width - n) <= 1)
                                n = t.width;
                            if (Math.abs(t.height - i) <= 1)
                                i = t.height;
                            return {
                                x: e.offsetLeft,
                                y: e.offsetTop,
                                width: n,
                                height: i
                            }
                        }
                        function Q(e) {
                            if ("html" === V(e))
                                return e;
                            else
                                return e.assignedSlot || e.parentNode || (M(e) ? e.host : null) || $(e)
                        }
                        function B(e) {
                            if (["html", "body", "#document"].indexOf(V(e)) >= 0)
                                return e.ownerDocument.body;
                            if (_(e) && N(e))
                                return e;
                            else
                                return B(Q(e))
                        }
                        function z(e, t) {
                            var n;
                            if (void 0 === t)
                                t = [];
                            var i = B(e),
                            r = i === (null == (n = e.ownerDocument) ? void 0 : n.body),
                            o = C(i),
                            s = r ? [o].concat(o.visualViewport || [], N(i) ? i : []) : i,
                            a = t.concat(s);
                            return r ? a : a.concat(z(Q(s)))
                        }
                        function G(e) {
                            return ["table", "td", "th"].indexOf(V(e)) >= 0
                        }
                        function J(e) {
                            if (!_(e) || "fixed" === D(e).position)
                                return null;
                            else
                                return e.offsetParent
                        }
                        function K(e) {
                            for (var t = C(e), n = J(e); n && G(n) && "static" === D(n).position; )
                                n = J(n);
                            if (n && ("html" === V(n) || "body" === V(n) && "static" === D(n).position))
                                return t;
                            else
                                return n || function (e) {
                                    var t = /firefox/i.test(P());
                                    if (/Trident/i.test(P()) && _(e))
                                        if ("fixed" === D(e).position)
                                            return null;
                                    var n = Q(e);
                                    if (M(n))
                                        n = n.host;
                                    for (; _(n) && ["html", "body"].indexOf(V(n)) < 0; ) {
                                        var i = D(n);
                                        if ("none" !== i.transform || "none" !== i.perspective || "paint" === i.contain || -1 !== ["transform", "perspective"].indexOf(i.willChange) || t && "filter" === i.willChange || t && i.filter && "none" !== i.filter)
                                            return n;
                                        else
                                            n = n.parentNode
                                    }
                                    return null
                                }
                            (e) || t
                        }
                        var Y = "top",
                        X = "bottom",
                        Z = "right",
                        ee = "left",
                        te = "auto",
                        ne = [Y, X, Z, ee],
                        ie = "start",
                        re = "end",
                        oe = "clippingParents",
                        se = "viewport",
                        ae = "popper",
                        ce = "reference",
                        le = ne.reduce((function (e, t) {
                                    return e.concat([t + "-" + ie, t + "-" + re])
                                }), []),
                        ue = [].concat(ne, [te]).reduce((function (e, t) {
                                return e.concat([t, t + "-" + ie, t + "-" + re])
                            }), []),
                        de = ["beforeRead", "read", "afterRead", "beforeMain", "main", "afterMain", "beforeWrite", "write", "afterWrite"];
                        function fe(e) {
                            var t = new Map,
                            n = new Set,
                            i = [];
                            function r(e) {
                                n.add(e.name),
                                [].concat(e.requires || [], e.requiresIfExists || []).forEach((function (e) {
                                        if (!n.has(e)) {
                                            var i = t.get(e);
                                            if (i)
                                                r(i)
                                        }
                                    })),
                                i.push(e)
                            }
                            return e.forEach((function (e) {
                                    t.set(e.name, e)
                                })),
                            e.forEach((function (e) {
                                    if (!n.has(e.name))
                                        r(e)
                                })),
                            i
                        }
                        var he = {
                            placement: "bottom",
                            modifiers: [],
                            strategy: "absolute"
                        };
                        function pe() {
                            for (var e = arguments.length, t = new Array(e), n = 0; n < e; n++)
                                t[n] = arguments[n];
                            return !t.some((function (e) {
                                    return !(e && "function" == typeof e.getBoundingClientRect)
                                }))
                        }
                        function ge(e) {
                            if (void 0 === e)
                                e = {};
                            var t = e,
                            n = t.defaultModifiers,
                            i = void 0 === n ? [] : n,
                            r = t.defaultOptions,
                            o = void 0 === r ? he : r;
                            return function (e, t, n) {
                                if (void 0 === n)
                                    n = o;
                                var r,
                                s,
                                a = {
                                    placement: "bottom",
                                    orderedModifiers: [],
                                    options: Object.assign({}, he, o),
                                    modifiersData: {},
                                    elements: {
                                        reference: e,
                                        popper: t
                                    },
                                    attributes: {},
                                    styles: {}
                                },
                                c = [],
                                l = !1,
                                u = {
                                    state: a,
                                    setOptions: function (n) {
                                        var r = "function" == typeof n ? n(a.options) : n;
                                        d(),
                                        a.options = Object.assign({}, o, a.options, r),
                                        a.scrollParents = {
                                            reference: E(e) ? z(e) : e.contextElement ? z(e.contextElement) : [],
                                            popper: z(t)
                                        };
                                        var s = function (e) {
                                            var t = fe(e);
                                            return de.reduce((function (e, n) {
                                                    return e.concat(t.filter((function (e) {
                                                                return e.phase === n
                                                            })))
                                                }), [])
                                        }
                                        (function (e) {
                                            var t = e.reduce((function (e, t) {
                                                        var n = e[t.name];
                                                        return e[t.name] = n ? Object.assign({}, n, t, {
                                                            options: Object.assign({}, n.options, t.options),
                                                            data: Object.assign({}, n.data, t.data)
                                                        }) : t,
                                                        e
                                                    }), {});
                                            return Object.keys(t).map((function (e) {
                                                    return t[e]
                                                }))
                                        }
                                            ([].concat(i, a.options.modifiers)));
                                        if (a.orderedModifiers = s.filter((function (e) {
                                                        return e.enabled
                                                    })), 0);
                                        return a.orderedModifiers.forEach((function (e) {
                                                var t = e.name,
                                                n = e.options,
                                                i = void 0 === n ? {}
                                                 : n,
                                                r = e.effect;
                                                if ("function" == typeof r) {
                                                    var o = r({
                                                        state: a,
                                                        name: t,
                                                        instance: u,
                                                        options: i
                                                    }),
                                                    s = function () {};
                                                    c.push(o || s)
                                                }
                                            })),
                                        u.update()
                                    },
                                    forceUpdate: function () {
                                        if (!l) {
                                            var e = a.elements,
                                            t = e.reference,
                                            n = e.popper;
                                            if (pe(t, n)) {
                                                a.rects = {
                                                    reference: q(t, K(n), "fixed" === a.options.strategy),
                                                    popper: W(n)
                                                },
                                                a.reset = !1,
                                                a.placement = a.options.placement,
                                                a.orderedModifiers.forEach((function (e) {
                                                        return a.modifiersData[e.name] = Object.assign({}, e.data)
                                                    }));
                                                for (var i = 0; i < a.orderedModifiers.length; i++) {
                                                    if (0);
                                                    if (!0 !== a.reset) {
                                                        var r = a.orderedModifiers[i],
                                                        o = r.fn,
                                                        s = r.options,
                                                        c = void 0 === s ? {}
                                                         : s,
                                                        d = r.name;
                                                        if ("function" == typeof o)
                                                            a = o({
                                                                state: a,
                                                                options: c,
                                                                name: d,
                                                                instance: u
                                                            }) || a
                                                    } else
                                                        a.reset = !1, i = -1
                                                }
                                            } else if (0);
                                        }
                                    },
                                    update: (r = function () {
                                        return new Promise((function (e) {
                                                u.forceUpdate(),
                                                e(a)
                                            }))
                                    }, function () {
                                        if (!s)
                                            s = new Promise((function (e) {
                                                        Promise.resolve().then((function () {
                                                                s = void 0,
                                                                e(r())
                                                            }))
                                                    }));
                                        return s
                                    }),
                                    destroy: function () {
                                        d(),
                                        l = !0
                                    }
                                };
                                if (!pe(e, t)) {
                                    if (0);
                                    return u
                                }
                                function d() {
                                    c.forEach((function (e) {
                                            return e()
                                        })),
                                    c = []
                                }
                                return u.setOptions(n).then((function (e) {
                                        if (!l && n.onFirstUpdate)
                                            n.onFirstUpdate(e)
                                    })),
                                u
                            }
                        }
                        var me = {
                            passive: !0
                        };
                        function ve(e) {
                            return e.split("-")[0]
                        }
                        function ye(e) {
                            return e.split("-")[1]
                        }
                        function be(e) {
                            return ["top", "bottom"].indexOf(e) >= 0 ? "x" : "y"
                        }
                        function we(e) {
                            var t,
                            n = e.reference,
                            i = e.element,
                            r = e.placement,
                            o = r ? ve(r) : null,
                            s = r ? ye(r) : null,
                            a = n.x + n.width / 2 - i.width / 2,
                            c = n.y + n.height / 2 - i.height / 2;
                            switch (o) {
                            case Y:
                                t = {
                                    x: a,
                                    y: n.y - i.height
                                };
                                break;
                            case X:
                                t = {
                                    x: a,
                                    y: n.y + n.height
                                };
                                break;
                            case Z:
                                t = {
                                    x: n.x + n.width,
                                    y: c
                                };
                                break;
                            case ee:
                                t = {
                                    x: n.x - i.width,
                                    y: c
                                };
                                break;
                            default:
                                t = {
                                    x: n.x,
                                    y: n.y
                                }
                            }
                            var l = o ? be(o) : null;
                            if (null != l) {
                                var u = "y" === l ? "height" : "width";
                                switch (s) {
                                case ie:
                                    t[l] = t[l] - (n[u] / 2 - i[u] / 2);
                                    break;
                                case re:
                                    t[l] = t[l] + (n[u] / 2 - i[u] / 2);
                                    break;
                                default:
                                }
                            }
                            return t
                        }
                        var xe = {
                            top: "auto",
                            right: "auto",
                            bottom: "auto",
                            left: "auto"
                        };
                        function Se(e) {
                            var t,
                            n = e.popper,
                            i = e.popperRect,
                            r = e.placement,
                            o = e.variation,
                            s = e.offsets,
                            a = e.position,
                            c = e.gpuAcceleration,
                            l = e.adaptive,
                            u = e.roundOffsets,
                            d = e.isFixed,
                            f = s.x,
                            h = void 0 === f ? 0 : f,
                            p = s.y,
                            g = void 0 === p ? 0 : p,
                            m = "function" == typeof u ? u({
                                x: h,
                                y: g
                            }) : {
                                x: h,
                                y: g
                            };
                            h = m.x,
                            g = m.y;
                            var v = s.hasOwnProperty("x"),
                            y = s.hasOwnProperty("y"),
                            b = ee,
                            w = Y,
                            x = window;
                            if (l) {
                                var S = K(n),
                                k = "clientHeight",
                                O = "clientWidth";
                                if (S === C(n))
                                    if ("static" !== D(S = $(n)).position && "absolute" === a)
                                        k = "scrollHeight", O = "scrollWidth";
                                if (r === Y || (r === ee || r === Z) && o === re) {
                                    w = X,
                                    g -= (d && S === x && x.visualViewport ? x.visualViewport.height : S[k]) - i.height,
                                    g *= c ? 1 : -1
                                }
                                if (r === ee || (r === Y || r === X) && o === re) {
                                    b = Z,
                                    h -= (d && S === x && x.visualViewport ? x.visualViewport.width : S[O]) - i.width,
                                    h *= c ? 1 : -1
                                }
                            }
                            var I = Object.assign({
                                position: a
                            }, l && xe),
                            A = !0 === u ? function (e, t) {
                                var n = e.x,
                                i = e.y,
                                r = t.devicePixelRatio || 1;
                                return {
                                    x: T(n * r) / r || 0,
                                    y: T(i * r) / r || 0
                                }
                            }
                            ({
                                x: h,
                                y: g
                            }, C(n)) : {
                                x: h,
                                y: g
                            };
                            if (h = A.x, g = A.y, c) {
                                var E;
                                return Object.assign({}, I, ((E = {})[w] = y ? "0" : "", E[b] = v ? "0" : "", E.transform = (x.devicePixelRatio || 1) <= 1 ? "translate(" + h + "px, " + g + "px)" : "translate3d(" + h + "px, " + g + "px, 0)", E))
                            }
                            return Object.assign({}, I, ((t = {})[w] = y ? g + "px" : "", t[b] = v ? h + "px" : "", t.transform = "", t))
                        }
                        const ke = {
                            name: "offset",
                            enabled: !0,
                            phase: "main",
                            requires: ["popperOffsets"],
                            fn: function (e) {
                                var t = e.state,
                                n = e.options,
                                i = e.name,
                                r = n.offset,
                                o = void 0 === r ? [0, 0] : r,
                                s = ue.reduce((function (e, n) {
                                            return e[n] = function (e, t, n) {
                                                var i = ve(e),
                                                r = [ee, Y].indexOf(i) >= 0 ? -1 : 1,
                                                o = "function" == typeof n ? n(Object.assign({}, t, {
                                                            placement: e
                                                        })) : n,
                                                s = o[0],
                                                a = o[1];
                                                return s = s || 0,
                                                a = (a || 0) * r,
                                                [ee, Z].indexOf(i) >= 0 ? {
                                                    x: a,
                                                    y: s
                                                }
                                                 : {
                                                    x: s,
                                                    y: a
                                                }
                                            }
                                            (n, t.rects, o),
                                            e
                                        }), {}),
                                a = s[t.placement],
                                c = a.x,
                                l = a.y;
                                if (null != t.modifiersData.popperOffsets)
                                    t.modifiersData.popperOffsets.x += c, t.modifiersData.popperOffsets.y += l;
                                t.modifiersData[i] = s
                            }
                        };
                        var Oe = {
                            left: "right",
                            right: "left",
                            bottom: "top",
                            top: "bottom"
                        };
                        function Ie(e) {
                            return e.replace(/left|right|bottom|top/g, (function (e) {
                                    return Oe[e]
                                }))
                        }
                        var Ae = {
                            start: "end",
                            end: "start"
                        };
                        function Ce(e) {
                            return e.replace(/start|end/g, (function (e) {
                                    return Ae[e]
                                }))
                        }
                        function Ee(e, t) {
                            var n = t.getRootNode && t.getRootNode();
                            if (e.contains(t))
                                return !0;
                            else if (n && M(n)) {
                                var i = t;
                                do {
                                    if (i && e.isSameNode(i))
                                        return !0;
                                    i = i.parentNode || i.host
                                } while (i)
                            }
                            return !1
                        }
                        function _e(e) {
                            return Object.assign({}, e, {
                                left: e.x,
                                top: e.y,
                                right: e.x + e.width,
                                bottom: e.y + e.height
                            })
                        }
                        function Me(e, t, n) {
                            return t === se ? _e(function (e, t) {
                                var n = C(e),
                                i = $(e),
                                r = n.visualViewport,
                                o = i.clientWidth,
                                s = i.clientHeight,
                                a = 0,
                                c = 0;
                                if (r) {
                                    o = r.width,
                                    s = r.height;
                                    var l = L();
                                    if (l || !l && "fixed" === t)
                                        a = r.offsetLeft, c = r.offsetTop
                                }
                                return {
                                    width: o,
                                    height: s,
                                    x: a + U(e),
                                    y: c
                                }
                            }
                                (e, n)) : E(t) ? function (e, t) {
                                var n = H(e, !1, "fixed" === t);
                                return n.top = n.top + e.clientTop,
                                n.left = n.left + e.clientLeft,
                                n.bottom = n.top + e.clientHeight,
                                n.right = n.left + e.clientWidth,
                                n.width = e.clientWidth,
                                n.height = e.clientHeight,
                                n.x = n.left,
                                n.y = n.top,
                                n
                            }
                            (t, n) : _e(function (e) {
                                var t,
                                n = $(e),
                                i = F(e),
                                r = null == (t = e.ownerDocument) ? void 0 : t.body,
                                o = R(n.scrollWidth, n.clientWidth, r ? r.scrollWidth : 0, r ? r.clientWidth : 0),
                                s = R(n.scrollHeight, n.clientHeight, r ? r.scrollHeight : 0, r ? r.clientHeight : 0),
                                a = -i.scrollLeft + U(e),
                                c = -i.scrollTop;
                                if ("rtl" === D(r || n).direction)
                                    a += R(n.clientWidth, r ? r.clientWidth : 0) - o;
                                return {
                                    width: o,
                                    height: s,
                                    x: a,
                                    y: c
                                }
                            }
                                ($(e)))
                        }
                        function Re(e, t, n, i) {
                            var r = "clippingParents" === t ? function (e) {
                                var t = z(Q(e)),
                                n = ["absolute", "fixed"].indexOf(D(e).position) >= 0 && _(e) ? K(e) : e;
                                if (!E(n))
                                    return [];
                                else
                                    return t.filter((function (e) {
                                            return E(e) && Ee(e, n) && "body" !== V(e)
                                        }))
                            }
                            (e) : [].concat(t),
                            o = [].concat(r, [n]),
                            s = o[0],
                            a = o.reduce((function (t, n) {
                                        var r = Me(e, n, i);
                                        return t.top = R(r.top, t.top),
                                        t.right = j(r.right, t.right),
                                        t.bottom = j(r.bottom, t.bottom),
                                        t.left = R(r.left, t.left),
                                        t
                                    }), Me(e, s, i));
                            return a.width = a.right - a.left,
                            a.height = a.bottom - a.top,
                            a.x = a.left,
                            a.y = a.top,
                            a
                        }
                        function je(e) {
                            return Object.assign({}, {
                                top: 0,
                                right: 0,
                                bottom: 0,
                                left: 0
                            }, e)
                        }
                        function Te(e, t) {
                            return t.reduce((function (t, n) {
                                    return t[n] = e,
                                    t
                                }), {})
                        }
                        function Pe(e, t) {
                            if (void 0 === t)
                                t = {};
                            var n = t,
                            i = n.placement,
                            r = void 0 === i ? e.placement : i,
                            o = n.strategy,
                            s = void 0 === o ? e.strategy : o,
                            a = n.boundary,
                            c = void 0 === a ? oe : a,
                            l = n.rootBoundary,
                            u = void 0 === l ? se : l,
                            d = n.elementContext,
                            f = void 0 === d ? ae : d,
                            h = n.altBoundary,
                            p = void 0 === h ? !1 : h,
                            g = n.padding,
                            m = void 0 === g ? 0 : g,
                            v = je("number" != typeof m ? m : Te(m, ne)),
                            y = f === ae ? ce : ae,
                            b = e.rects.popper,
                            w = e.elements[p ? y : f],
                            x = Re(E(w) ? w : w.contextElement || $(e.elements.popper), c, u, s),
                            S = H(e.elements.reference),
                            k = we({
                                reference: S,
                                element: b,
                                strategy: "absolute",
                                placement: r
                            }),
                            O = _e(Object.assign({}, b, k)),
                            I = f === ae ? O : S,
                            A = {
                                top: x.top - I.top + v.top,
                                bottom: I.bottom - x.bottom + v.bottom,
                                left: x.left - I.left + v.left,
                                right: I.right - x.right + v.right
                            },
                            C = e.modifiersData.offset;
                            if (f === ae && C) {
                                var _ = C[r];
                                Object.keys(A).forEach((function (e) {
                                        var t = [Z, X].indexOf(e) >= 0 ? 1 : -1,
                                        n = [Y, X].indexOf(e) >= 0 ? "y" : "x";
                                        A[e] += _[n] * t
                                    }))
                            }
                            return A
                        }
                        function Le(e, t, n) {
                            return R(e, j(t, n))
                        }
                        const He = {
                            name: "preventOverflow",
                            enabled: !0,
                            phase: "main",
                            fn: function (e) {
                                var t = e.state,
                                n = e.options,
                                i = e.name,
                                r = n.mainAxis,
                                o = void 0 === r ? !0 : r,
                                s = n.altAxis,
                                a = void 0 === s ? !1 : s,
                                c = n.boundary,
                                l = n.rootBoundary,
                                u = n.altBoundary,
                                d = n.padding,
                                f = n.tether,
                                h = void 0 === f ? !0 : f,
                                p = n.tetherOffset,
                                g = void 0 === p ? 0 : p,
                                m = Pe(t, {
                                    boundary: c,
                                    rootBoundary: l,
                                    padding: d,
                                    altBoundary: u
                                }),
                                v = ve(t.placement),
                                y = ye(t.placement),
                                b = !y,
                                w = be(v),
                                x = "x" === w ? "y" : "x",
                                S = t.modifiersData.popperOffsets,
                                k = t.rects.reference,
                                O = t.rects.popper,
                                I = "function" == typeof g ? g(Object.assign({}, t.rects, {
                                            placement: t.placement
                                        })) : g,
                                A = "number" == typeof I ? {
                                    mainAxis: I,
                                    altAxis: I
                                }
                                 : Object.assign({
                                    mainAxis: 0,
                                    altAxis: 0
                                }, I),
                                C = t.modifiersData.offset ? t.modifiersData.offset[t.placement] : null,
                                E = {
                                    x: 0,
                                    y: 0
                                };
                                if (S) {
                                    if (o) {
                                        var _,
                                        M = "y" === w ? Y : ee,
                                        T = "y" === w ? X : Z,
                                        P = "y" === w ? "height" : "width",
                                        L = S[w],
                                        H = L + m[M],
                                        F = L - m[T],
                                        V = h ? -O[P] / 2 : 0,
                                        $ = y === ie ? k[P] : O[P],
                                        U = y === ie ? -O[P] : -k[P],
                                        D = t.elements.arrow,
                                        N = h && D ? W(D) : {
                                            width: 0,
                                            height: 0
                                        },
                                        q = t.modifiersData["arrow#persistent"] ? t.modifiersData["arrow#persistent"].padding : {
                                            top: 0,
                                            right: 0,
                                            bottom: 0,
                                            left: 0
                                        },
                                        Q = q[M],
                                        B = q[T],
                                        z = Le(0, k[P], N[P]),
                                        G = b ? k[P] / 2 - V - z - Q - A.mainAxis : $ - z - Q - A.mainAxis,
                                        J = b ? -k[P] / 2 + V + z + B + A.mainAxis : U + z + B + A.mainAxis,
                                        te = t.elements.arrow && K(t.elements.arrow),
                                        ne = te ? "y" === w ? te.clientTop || 0 : te.clientLeft || 0 : 0,
                                        re = null != (_ = null == C ? void 0 : C[w]) ? _ : 0,
                                        oe = L + J - re,
                                        se = Le(h ? j(H, L + G - re - ne) : H, L, h ? R(F, oe) : F);
                                        S[w] = se,
                                        E[w] = se - L
                                    }
                                    if (a) {
                                        var ae,
                                        ce = "x" === w ? Y : ee,
                                        le = "x" === w ? X : Z,
                                        ue = S[x],
                                        de = "y" === x ? "height" : "width",
                                        fe = ue + m[ce],
                                        he = ue - m[le],
                                        pe = -1 !== [Y, ee].indexOf(v),
                                        ge = null != (ae = null == C ? void 0 : C[x]) ? ae : 0,
                                        me = pe ? fe : ue - k[de] - O[de] - ge + A.altAxis,
                                        we = pe ? ue + k[de] + O[de] - ge - A.altAxis : he,
                                        xe = h && pe ? function (e, t, n) {
                                            var i = Le(e, t, n);
                                            return i > n ? n : i
                                        }
                                        (me, ue, we) : Le(h ? me : fe, ue, h ? we : he);
                                        S[x] = xe,
                                        E[x] = xe - ue
                                    }
                                    t.modifiersData[i] = E
                                }
                            },
                            requiresIfExists: ["offset"]
                        };
                        var Fe = function (e, t) {
                            return je("number" != typeof(e = "function" == typeof e ? e(Object.assign({}, t.rects, {
                                                placement: t.placement
                                            })) : e) ? e : Te(e, ne))
                        };
                        const Ve = {
                            name: "arrow",
                            enabled: !0,
                            phase: "main",
                            fn: function (e) {
                                var t,
                                n = e.state,
                                i = e.name,
                                r = e.options,
                                o = n.elements.arrow,
                                s = n.modifiersData.popperOffsets,
                                a = ve(n.placement),
                                c = be(a),
                                l = [ee, Z].indexOf(a) >= 0 ? "height" : "width";
                                if (o && s) {
                                    var u = Fe(r.padding, n),
                                    d = W(o),
                                    f = "y" === c ? Y : ee,
                                    h = "y" === c ? X : Z,
                                    p = n.rects.reference[l] + n.rects.reference[c] - s[c] - n.rects.popper[l],
                                    g = s[c] - n.rects.reference[c],
                                    m = K(o),
                                    v = m ? "y" === c ? m.clientHeight || 0 : m.clientWidth || 0 : 0,
                                    y = p / 2 - g / 2,
                                    b = u[f],
                                    w = v - d[l] - u[h],
                                    x = v / 2 - d[l] / 2 + y,
                                    S = Le(b, x, w),
                                    k = c;
                                    n.modifiersData[i] = ((t = {})[k] = S, t.centerOffset = S - x, t)
                                }
                            },
                            effect: function (e) {
                                var t = e.state,
                                n = e.options.element,
                                i = void 0 === n ? "[data-popper-arrow]" : n;
                                if (null != i) {
                                    if ("string" == typeof i)
                                        if (!(i = t.elements.popper.querySelector(i)))
                                            return;
                                    if (0);
                                    if (Ee(t.elements.popper, i))
                                        t.elements.arrow = i;
                                    else if (0);
                                }
                            },
                            requires: ["popperOffsets"],
                            requiresIfExists: ["preventOverflow"]
                        };
                        function $e(e, t, n) {
                            if (void 0 === n)
                                n = {
                                    x: 0,
                                    y: 0
                                };
                            return {
                                top: e.top - t.height - n.y,
                                right: e.right - t.width + n.x,
                                bottom: e.bottom - t.height + n.y,
                                left: e.left - t.width - n.x
                            }
                        }
                        function Ue(e) {
                            return [Y, Z, X, ee].some((function (t) {
                                    return e[t] >= 0
                                }))
                        }
                        var De,
                        Ne = ge({
                            defaultModifiers: [{
                                    name: "eventListeners",
                                    enabled: !0,
                                    phase: "write",
                                    fn: function () {},
                                    effect: function (e) {
                                        var t = e.state,
                                        n = e.instance,
                                        i = e.options,
                                        r = i.scroll,
                                        o = void 0 === r ? !0 : r,
                                        s = i.resize,
                                        a = void 0 === s ? !0 : s,
                                        c = C(t.elements.popper),
                                        l = [].concat(t.scrollParents.reference, t.scrollParents.popper);
                                        if (o)
                                            l.forEach((function (e) {
                                                    e.addEventListener("scroll", n.update, me)
                                                }));
                                        if (a)
                                            c.addEventListener("resize", n.update, me);
                                        return function () {
                                            if (o)
                                                l.forEach((function (e) {
                                                        e.removeEventListener("scroll", n.update, me)
                                                    }));
                                            if (a)
                                                c.removeEventListener("resize", n.update, me)
                                        }
                                    },
                                    data: {}
                                }, {
                                    name: "popperOffsets",
                                    enabled: !0,
                                    phase: "read",
                                    fn: function (e) {
                                        var t = e.state,
                                        n = e.name;
                                        t.modifiersData[n] = we({
                                            reference: t.rects.reference,
                                            element: t.rects.popper,
                                            strategy: "absolute",
                                            placement: t.placement
                                        })
                                    },
                                    data: {}
                                }, {
                                    name: "computeStyles",
                                    enabled: !0,
                                    phase: "beforeWrite",
                                    fn: function (e) {
                                        var t = e.state,
                                        n = e.options,
                                        i = n.gpuAcceleration,
                                        r = void 0 === i ? !0 : i,
                                        o = n.adaptive,
                                        s = void 0 === o ? !0 : o,
                                        a = n.roundOffsets,
                                        c = void 0 === a ? !0 : a;
                                        if (0);
                                        var l = {
                                            placement: ve(t.placement),
                                            variation: ye(t.placement),
                                            popper: t.elements.popper,
                                            popperRect: t.rects.popper,
                                            gpuAcceleration: r,
                                            isFixed: "fixed" === t.options.strategy
                                        };
                                        if (null != t.modifiersData.popperOffsets)
                                            t.styles.popper = Object.assign({}, t.styles.popper, Se(Object.assign({}, l, {
                                                            offsets: t.modifiersData.popperOffsets,
                                                            position: t.options.strategy,
                                                            adaptive: s,
                                                            roundOffsets: c
                                                        })));
                                        if (null != t.modifiersData.arrow)
                                            t.styles.arrow = Object.assign({}, t.styles.arrow, Se(Object.assign({}, l, {
                                                            offsets: t.modifiersData.arrow,
                                                            position: "absolute",
                                                            adaptive: !1,
                                                            roundOffsets: c
                                                        })));
                                        t.attributes.popper = Object.assign({}, t.attributes.popper, {
                                            "data-popper-placement": t.placement
                                        })
                                    },
                                    data: {}
                                }, {
                                    name: "applyStyles",
                                    enabled: !0,
                                    phase: "write",
                                    fn: function (e) {
                                        var t = e.state;
                                        Object.keys(t.elements).forEach((function (e) {
                                                var n = t.styles[e] || {},
                                                i = t.attributes[e] || {},
                                                r = t.elements[e];
                                                if (_(r) && V(r))
                                                    Object.assign(r.style, n), Object.keys(i).forEach((function (e) {
                                                            var t = i[e];
                                                            if (!1 === t)
                                                                r.removeAttribute(e);
                                                            else
                                                                r.setAttribute(e, !0 === t ? "" : t)
                                                        }))
                                            }))
                                    },
                                    effect: function (e) {
                                        var t = e.state,
                                        n = {
                                            popper: {
                                                position: t.options.strategy,
                                                left: "0",
                                                top: "0",
                                                margin: "0"
                                            },
                                            arrow: {
                                                position: "absolute"
                                            },
                                            reference: {}
                                        };
                                        if (Object.assign(t.elements.popper.style, n.popper), t.styles = n, t.elements.arrow)
                                            Object.assign(t.elements.arrow.style, n.arrow);
                                        return function () {
                                            Object.keys(t.elements).forEach((function (e) {
                                                    var i = t.elements[e],
                                                    r = t.attributes[e] || {},
                                                    o = Object.keys(t.styles.hasOwnProperty(e) ? t.styles[e] : n[e]).reduce((function (e, t) {
                                                                return e[t] = "",
                                                                e
                                                            }), {});
                                                    if (_(i) && V(i))
                                                        Object.assign(i.style, o), Object.keys(r).forEach((function (e) {
                                                                i.removeAttribute(e)
                                                            }))
                                                }))
                                        }
                                    },
                                    requires: ["computeStyles"]
                                }, ke, {
                                    name: "flip",
                                    enabled: !0,
                                    phase: "main",
                                    fn: function (e) {
                                        var t = e.state,
                                        n = e.options,
                                        i = e.name;
                                        if (!t.modifiersData[i]._skip) {
                                            for (var r = n.mainAxis, o = void 0 === r ? !0 : r, s = n.altAxis, a = void 0 === s ? !0 : s, c = n.fallbackPlacements, l = n.padding, u = n.boundary, d = n.rootBoundary, f = n.altBoundary, h = n.flipVariations, p = void 0 === h ? !0 : h, g = n.allowedAutoPlacements, m = t.options.placement, v = ve(m), y = c || (v === m || !p ? [Ie(m)] : function (e) {
                                                    if (ve(e) === te)
                                                        return [];
                                                    var t = Ie(e);
                                                    return [Ce(e), t, Ce(t)]
                                                }
                                                        (m)), b = [m].concat(y).reduce((function (e, n) {
                                                        return e.concat(ve(n) === te ? function (e, t) {
                                                            if (void 0 === t)
                                                                t = {};
                                                            var n = t,
                                                            i = n.placement,
                                                            r = n.boundary,
                                                            o = n.rootBoundary,
                                                            s = n.padding,
                                                            a = n.flipVariations,
                                                            c = n.allowedAutoPlacements,
                                                            l = void 0 === c ? ue : c,
                                                            u = ye(i),
                                                            d = u ? a ? le : le.filter((function (e) {
                                                                        return ye(e) === u
                                                                    })) : ne,
                                                            f = d.filter((function (e) {
                                                                        return l.indexOf(e) >= 0
                                                                    }));
                                                            if (0 === f.length)
                                                                if (f = d, 0);
                                                            var h = f.reduce((function (t, n) {
                                                                        return t[n] = Pe(e, {
                                                                            placement: n,
                                                                            boundary: r,
                                                                            rootBoundary: o,
                                                                            padding: s
                                                                        })[ve(n)],
                                                                        t
                                                                    }), {});
                                                            return Object.keys(h).sort((function (e, t) {
                                                                    return h[e] - h[t]
                                                                }))
                                                        }
                                                            (t, {
                                                                placement: n,
                                                                boundary: u,
                                                                rootBoundary: d,
                                                                padding: l,
                                                                flipVariations: p,
                                                                allowedAutoPlacements: g
                                                            }) : n)
                                                    }), []), w = t.rects.reference, x = t.rects.popper, S = new Map, k = !0, O = b[0], I = 0; I < b.length; I++) {
                                                var A = b[I],
                                                C = ve(A),
                                                E = ye(A) === ie,
                                                _ = [Y, X].indexOf(C) >= 0,
                                                M = _ ? "width" : "height",
                                                R = Pe(t, {
                                                    placement: A,
                                                    boundary: u,
                                                    rootBoundary: d,
                                                    altBoundary: f,
                                                    padding: l
                                                }),
                                                j = _ ? E ? Z : ee : E ? X : Y;
                                                if (w[M] > x[M])
                                                    j = Ie(j);
                                                var T = Ie(j),
                                                P = [];
                                                if (o)
                                                    P.push(R[C] <= 0);
                                                if (a)
                                                    P.push(R[j] <= 0, R[T] <= 0);
                                                if (P.every((function (e) {
                                                            return e
                                                        }))) {
                                                    O = A,
                                                    k = !1;
                                                    break
                                                }
                                                S.set(A, P)
                                            }
                                            if (k)
                                                for (var L = function (e) {
                                                    var t = b.find((function (t) {
                                                                var n = S.get(t);
                                                                if (n)
                                                                    return n.slice(0, e)
                                                                        .every((function (e) {
                                                                                return e
                                                                            }))
                                                                }));
                                                        if (t)
                                                            return O = t, "break"
                                                    }, H = p ? 3 : 1; H > 0; H--) {
                                                        if ("break" === L(H))
                                                            break
                                                    }
                                            if (t.placement !== O)
                                                t.modifiersData[i]._skip = !0, t.placement = O, t.reset = !0
                                        }
                                    },
                                    requiresIfExists: ["offset"],
                                    data: {
                                        _skip: !1
                                    }
                                }, He, Ve, {
                                    name: "hide",
                                    enabled: !0,
                                    phase: "main",
                                    requiresIfExists: ["preventOverflow"],
                                    fn: function (e) {
                                        var t = e.state,
                                        n = e.name,
                                        i = t.rects.reference,
                                        r = t.rects.popper,
                                        o = t.modifiersData.preventOverflow,
                                        s = Pe(t, {
                                            elementContext: "reference"
                                        }),
                                        a = Pe(t, {
                                            altBoundary: !0
                                        }),
                                        c = $e(s, i),
                                        l = $e(a, r, o),
                                        u = Ue(c),
                                        d = Ue(l);
                                        t.modifiersData[n] = {
                                            referenceClippingOffsets: c,
                                            popperEscapeOffsets: l,
                                            isReferenceHidden: u,
                                            hasPopperEscaped: d
                                        },
                                        t.attributes.popper = Object.assign({}, t.attributes.popper, {
                                            "data-popper-reference-hidden": u,
                                            "data-popper-escaped": d
                                        })
                                    }
                                }
                            ]
                        }),
                        qe = function (e, t, n, i) {
                            return new(n || (n = Promise))((function (r, o) {
                                    function s(e) {
                                        try {
                                            c(i.next(e))
                                        } catch (e) {
                                            o(e)
                                        }
                                    }
                                    function a(e) {
                                        try {
                                            c(i.throw(e))
                                        } catch (e) {
                                            o(e)
                                        }
                                    }
                                    function c(e) {
                                        var t;
                                        e.done ? r(e.value) : (t = e.value, t instanceof n ? t : new n((function (e) {
                                                    e(t)
                                                }))).then(s, a)
                                    }
                                    c((i = i.apply(e, t || [])).next())
                                }))
                        };
                        class We {
                            constructor(e) {
                                this.modal = e,
                                this.animateModal(),
                                this.animateOpacityOnIframe()
                            }
                            animateModal() {
                                this.modal.style.transitionProperty = "opacity,margin",
                                this.modal.style.transitionDuration = "0.5s",
                                this.modal.style.transitionTimingFunction = "ease-in",
                                this.modal.style.opacity = "1";
                                switch (this.modal.getAttribute("data-popper-placement")) {
                                case "bottom":
                                    this.modal.style.marginTop = "16px";
                                    break;
                                case "top":
                                    this.modal.style.marginBottom = "16px"
                                }
                            }
                            animateOpacityOnIframe() {
                                return qe(this, void 0, void 0, (function  * () {
                                        this.modal.page.iframe.style.transitionProperty = "opacity",
                                        this.modal.page.iframe.style.transitionDuration = "0.5s",
                                        this.modal.page.iframe.style.transitionTimingFunction = "ease-in",
                                        this.modal.page.iframe.style.opacity = "0",
                                        yield O.value,
                                        this.modal.page.iframe.style.opacity = "1"
                                    }))
                            }
                        }
                        class Qe {
                            constructor(e) {
                                this.props = e,
                                this.isOpen = !1,
                                this.addClickHandler()
                            }
                            addClickHandler() {
                                this.props.button.addEventListener("click", (() => this.onClick()))
                            }
                            onClick() {
                                this.isOpen ? this.close() : this.open(),
                                this.isOpen = !this.isOpen
                            }
                            open() {
                                if (!this.popUp)
                                    this.createAndAppendPopUp(), this.positionPopUp();
                                else
                                    this.popUp.style.visibility = "visible", this.popUp.style.pointerEvents = "initial", this.popUp.popper.forceUpdate();
                                this.props.onOpen()
                            }
                            close() {
                                this.popUp.style.visibility = "hidden",
                                this.popUp.style.pointerEvents = "none",
                                this.props.onClose()
                            }
                            createAndAppendPopUp() {
                                this.popUp = new A,
                                document.body.append(this.popUp)
                            }
                            positionPopUp() {
                                if (!this.popUp)
                                    return;
                                const e = Ne(this.props.button, this.popUp, {
                                    modifiers: [{
                                            name: "preventOverflow",
                                            options: {
                                                padding: {
                                                    top: this.margin,
                                                    right: 50,
                                                    bottom: this.margin,
                                                    left: this.margin
                                                }
                                            }
                                        }
                                    ],
                                    onFirstUpdate: () => {
                                        this.popUp && new We(this.popUp)
                                    }
                                });
                                this.popUp.popper = e
                            }
                            get margin() {
                                return 16
                            }
                        }
                        !function (e) {
                            e.Page = "coveo-page",
                            e.PageModal = "coveo-page-modal",
                            e.CoveoInAppWidgetFrameAnimation = "coveo-in-app-widget-frame-animation",
                            e.CoveoInAppWidgetLoader = "coveo-in-app-widget-loader"
                        }
                        (De || (De = {}));
                        const Be = n(207);
                        class ze extends HTMLElement {
                            constructor() {
                                super(),
                                this.attachShadow({
                                    mode: "open"
                                }),
                                this.shadowRoot.append(this.template().content.cloneNode(!0)),
                                this.executeAdditionalInlineJavaScript(),
                                this.executeAdditionalHeaderJavaScript()
                            }
                            connectedCallback() {
                                !this.manager && this.initManager()
                            }
                            show() {
                                this.classList.remove(this.hiddenClass)
                            }
                            hide() {
                                this.classList.add(this.hiddenClass)
                            }
                            get hiddenClass() {
                                return `${De.CoveoInAppWidgetLoader}-hidden`
                            }
                            initManager() {
                                const e = this.shadowRoot.querySelector("button");
                                if (e)
                                    this.manager = new Qe({
                                        button: e,
                                        onOpen: () => this.onOpen(),
                                        onClose: () => this.onClose()
                                    })
                            }
                            executeAdditionalInlineJavaScript() {
                                for (const e of s) {
                                    const t = document.createElement("script"),
                                    n = document.createTextNode(e);
                                    t.appendChild(n),
                                    this.shadowRoot.appendChild(t)
                                }
                            }
                            executeAdditionalHeaderJavaScript() {
                                for (const e of a) {
                                    const t = document.createElement("script");
                                    t.src = e,
                                    this.shadowRoot.appendChild(t)
                                }
                            }
                            template() {
                                const e = document.createElement("template");
                                return e.innerHTML = `\n    ${o}\n    \n    <style>\n\n    ${this.buttonStyling}\n    ${this.svgIconStyling}\n    ${this.hostStyling}\n    ${this.svgAnimationStyling}\n    ${this.buttonTextStyling}\n\n    </style>\n    \n    <button class="${f}" part="button">\n        <span class="icon" part="button-icon">\n            ${this.svgClose}\n            ${this.svgOpen}\n        </span>\n        <span class="buttonText" part="button-text">\n            ${h}\n        </span>\n    </button>\n    `,
                                e
                            }
                            get svgClose() {
                                var e;
                                const t = document.createElement("div");
                                return t.innerHTML = p,
                                null === (e = t.querySelector("svg")) || void 0 === e || e.setAttribute("fill", this.textColor),
`\n    <img class='svg-close' src='data:image/svg+xml;utf8,${t.innerHTML}' >\n    `
                            }
                            get svgOpen() {
                                return '\n    <svg class=\'svg-open\' viewBox="0 0 22 22">\n        <path d="M.818 2.232L2.232.818l19.02 19.02-1.413 1.415z"></path>\n        <path d="M.818 19.768L19.838.748l1.415 1.413L2.232 21.182z"></path>\n    </svg>\n    '
                            }
                            onOpen() {
                                k.publishOpen(),
                                this.button.classList.add("btn-open")
                            }
                            onClose() {
                                k.publishClose(),
                                this.button.classList.remove("btn-open")
                            }
                            linearGradient(e, t) {
                                return `linear-gradient(315deg, ${e} 0%, ${t} 74%);`
                            }
                            get button() {
                                return this.shadowRoot.querySelector("button")
                            }
                            get mainColor() {
                                return v || "rgb(253, 175, 34)"
                            }
                            get analogousColor() {
                                return Be(this.mainColor).analogous()[1].toRgbString()
                            }
                            get textColor() {
                                return Be(y || "rgb(255,255,255)").toRgbString()
                            }
                            get buttonStyling() {
                                return ` ${c} {\n            ${l}\n            \n            overflow: hidden;\n            position: fixed;\n    \n            user-select: none;\n            cursor: pointer;\n            border: none;\n            border-radius: 4px;\n            height: 44px;\n            width: 150px;\n            padding: 10px;\n            margin: 0;\n            vertical-align: middle;\n    \n            box-sizing: border-box;\n            display: flex;\n            align-items: center;\n            justify-content: center;\n            font-family: "Lato", Arial, Helvetica, sans-serif;\n            font-weight: 700;\n            line-height: 15px;\n            text-decoration: none;\n            text-overflow: ellipsis;\n            text-transform: uppercase;\n            white-space: nowrap;\n    \n            color: ${this.textColor};\n            background-color: ${this.mainColor};\n            background-image: ${this.linearGradient(this.analogousColor,this.mainColor)};\n        }\n\n        ${c}:before {\n            position: absolute;\n            content: "";\n            top: 0;\n            right: 0;\n            bottom: 0;\n            left: 0;\n            z-index: -1;\n            transition: opacity 0.5s linear;\n            opacity: 0;\n            background-image: ${this.linearGradient(this.mainColor,this.analogousColor)};\n        }\n\n        ${u}:before {\n            opacity: 1;\n        }\n    \n        ${d} {\n            outline: none;\n        }\n        `
                            }
                            get svgIconStyling() {
                                return `\n        .icon {\n            fill: ${this.textColor};\n            padding: 0;\n            font-size: 100%;\n            display: inline-block;\n    \n            margin-right: 8px;\n            width: 1.2em;\n            height: 1.2em;\n            vertical-align: -0.5em;\n            position: relative;\n        }\n        `
                            }
                            get hostStyling() {
                                return `\n        :host(${De.CoveoInAppWidgetLoader}) {\n            z-index: 999999;\n            position: relative;\n          }\n      \n          :host(.${this.hiddenClass}) {\n              display: none;\n          }\n        `
                            }
                            get svgAnimationStyling() {
                                return "\n        .svg-open, .svg-close {\n            transition: transform 500ms;\n            position: absolute;\n            left: 0;\n        }\n    \n        .svg-close {\n            transform: translateY(0);\n        }\n    \n        .btn-open .svg-close {\n            transform: translateY(50px);\n        }\n    \n        .svg-open {\n            transform: translateY(-50px);\n        }\n    \n        .btn-open .svg-open {\n            transform: translateY(0);\n        }\n    \n        "
                            }
                            get buttonTextStyling() {
                                return "\n            .buttonText {\n                overflow: hidden;\n                max-width: 107px;\n            }\n        "
                            }
                        }
                        class Ge {
                            constructor() {
                                this.findTargetElementUsingInterval()
                            }
                            findTargetElementUsingInterval() {
                                this.findTargetAndPopulate(),
                                window.setInterval((() => this.findTargetAndPopulate()), 200)
                            }
                            findTargetAndPopulate() {
                                const e = this.findTargetElement();
                                e && this.onTargetElementFound(e)
                            }
                            findTargetElement() {
                                const t = e;
                                try {
                                    return document.querySelector(t)
                                } catch (e) {
                                    return console.error(`${t} is not a valid CSS selector. Cannot retrieve target element.`),
                                    null
                                }
                            }
                            onTargetElementFound(e) {
                                if (this.pageIsNotChildOfElement(e))
                                    this.appendPageToElement(e), this.publishOpenAndCloseEvents(e)
                            }
                            publishOpenAndCloseEvents(e) {
                                let t = !0;
                                this.observeElementAndItsAncestors(e, (() => {
                                        const n = this.isElementVisible(e);
                                        if (n && !t)
                                            k.publishOpen();
                                        if (!n && t)
                                            k.publishClose();
                                        t = n
                                    }))
                            }
                            pageIsNotChildOfElement(e) {
                                return !e.querySelector(De.Page)
                            }
                            appendPageToElement(e) {
                                const t = new I;
                                e.append(t)
                            }
                            observeElementAndItsAncestors(e, t) {
                                if (new MutationObserver((() => t())).observe(e, {
                                        attributes: !0
                                    }), null !== e.parentElement)
                                    this.observeElementAndItsAncestors(e.parentElement, t)
                            }
                            isElementVisible(e) {
                                const t = getComputedStyle(e);
                                if ("body" === e.tagName.toLowerCase())
                                    return !0;
                                if ("none" === t.display)
                                    return !1;
                                if (!("absolute" !== t.position && "fixed" !== t.position || "hidden" !== t.visibility && "0" !== t.opacity))
                                    return !1;
                                if (0 === e.clientWidth && 0 === e.clientHeight)
                                    return !1;
                                if (null === e.parentElement)
                                    return !1;
                                else
                                    return this.isElementVisible(e.parentElement)
                            }
                        }
                        function Je(e, t) {
                            var n = {};
                            for (var i in e)
                                if (Object.prototype.hasOwnProperty.call(e, i) && t.indexOf(i) < 0)
                                    n[i] = e[i];
                            if (null != e && "function" == typeof Object.getOwnPropertySymbols) {
                                var r = 0;
                                for (i = Object.getOwnPropertySymbols(e); r < i.length; r++)
                                    if (t.indexOf(i[r]) < 0 && Object.prototype.propertyIsEnumerable.call(e, i[r]))
                                        n[i[r]] = e[i[r]]
                            }
                            return n
                        }
                        function Ke(e, t, n, i) {
                            return new(n || (n = Promise))((function (r, o) {
                                    function s(e) {
                                        try {
                                            c(i.next(e))
                                        } catch (e) {
                                            o(e)
                                        }
                                    }
                                    function a(e) {
                                        try {
                                            c(i.throw(e))
                                        } catch (e) {
                                            o(e)
                                        }
                                    }
                                    function c(e) {
                                        var t;
                                        e.done ? r(e.value) : (t = e.value, t instanceof n ? t : new n((function (e) {
                                                    e(t)
                                                }))).then(s, a)
                                    }
                                    c((i = i.apply(e, t || [])).next())
                                }))
                        }
                        var Ye;
                        function Xe() {
                            return "undefined" != typeof navigator
                        }
                        function Ze() {
                            return "undefined" != typeof document
                        }
                        function et() {
                            try {
                                return "undefined" != typeof localStorage
                            } catch (e) {
                                return !1
                            }
                        }
                        function tt() {
                            return Xe() && navigator.cookieEnabled
                        }
                        !function (e) {
                            e.search = "search",
                            e.click = "click",
                            e.custom = "custom",
                            e.view = "view",
                            e.collect = "collect"
                        }
                        (Ye || (Ye = {}));
                        const nt = [Ye.click, Ye.custom, Ye.search, Ye.view],
                        it = (e, t) => -1 !== nt.indexOf(e) ? Object.assign({
                            language: Ze() ? document.documentElement.lang : "unknown",
                            userAgent: Xe() ? navigator.userAgent : "unknown"
                        }, t) : t;
                        class rt {
                            static set(e, t, n) {
                                var i,
                                r,
                                o;
                                if (n)
                                    (i = new Date).setTime(i.getTime() + n);
                                if (-1 === (o = window.location.hostname).indexOf("."))
                                    ot(e, t, i);
                                else
                                    ot(e, t, i, (r = o.split("."))[r.length - 2] + "." + r[r.length - 1])
                            }
                            static get(e) {
                                for (var t = e + "=", n = document.cookie.split(";"), i = 0; i < n.length; i++) {
                                    var r = n[i];
                                    if (0 === (r = r.replace(/^\s+/, "")).lastIndexOf(t, 0))
                                        return r.substring(t.length, r.length)
                                }
                                return null
                            }
                            static erase(e) {
                                rt.set(e, "", -1)
                            }
                        }
                        function ot(e, t, n, i) {
                            document.cookie = `${e}=${t}` + (n ? `;expires=${n.toUTCString()}` : "") + (i ? `;domain=${i}` : "") + ";SameSite=Lax"
                        }
                        function st() {
                            if (et())
                                return localStorage;
                            if (tt())
                                return new at;
                            if (function () {
                                try {
                                    return "undefined" != typeof sessionStorage
                                } catch (e) {
                                    return !1
                                }
                            }
                                ())
                                return sessionStorage;
                            else
                                return new lt
                        }
                        class at {
                            getItem(e) {
                                return rt.get(`${at.prefix}${e}`)
                            }
                            removeItem(e) {
                                rt.erase(`${at.prefix}${e}`)
                            }
                            setItem(e, t, n) {
                                rt.set(`${at.prefix}${e}`, t, n)
                            }
                        }
                        at.prefix = "coveo_";
                        class ct {
                            constructor() {
                                this.cookieStorage = new at
                            }
                            getItem(e) {
                                return localStorage.getItem(e) || this.cookieStorage.getItem(e)
                            }
                            removeItem(e) {
                                this.cookieStorage.removeItem(e),
                                localStorage.removeItem(e)
                            }
                            setItem(e, t) {
                                localStorage.setItem(e, t),
                                this.cookieStorage.setItem(e, t, 31556926e3)
                            }
                        }
                        class lt {
                            getItem(e) {
                                return null
                            }
                            removeItem(e) {}
                            setItem(e, t) {}
                        }
                        const ut = "__coveo.analytics.history";
                        class dt {
                            constructor(e) {
                                this.store = e || st()
                            }
                            addElement(e) {
                                e.internalTime = (new Date).getTime(),
                                e = this.cropQueryElement(this.stripEmptyQuery(e));
                                let t = this.getHistoryWithInternalTime();
                                if (null != t) {
                                    if (this.isValidEntry(e))
                                        this.setHistory([e].concat(t))
                                } else
                                    this.setHistory([e])
                            }
                            addElementAsync(e) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        e.internalTime = (new Date).getTime(),
                                        e = this.cropQueryElement(this.stripEmptyQuery(e));
                                        let t = yield this.getHistoryWithInternalTimeAsync();
                                        if (null != t) {
                                            if (this.isValidEntry(e))
                                                this.setHistory([e].concat(t))
                                        } else
                                            this.setHistory([e])
                                    }))
                            }
                            getHistory() {
                                const e = this.getHistoryWithInternalTime();
                                return this.stripEmptyQueries(this.stripInternalTime(e))
                            }
                            getHistoryAsync() {
                                return Ke(this, void 0, void 0, (function  * () {
                                        const e = yield this.getHistoryWithInternalTimeAsync();
                                        return this.stripEmptyQueries(this.stripInternalTime(e))
                                    }))
                            }
                            getHistoryWithInternalTime() {
                                try {
                                    const e = this.store.getItem(ut);
                                    if (e && "string" == typeof e)
                                        return JSON.parse(e);
                                    else
                                        return []
                                } catch (e) {
                                    return []
                                }
                            }
                            getHistoryWithInternalTimeAsync() {
                                return Ke(this, void 0, void 0, (function  * () {
                                        try {
                                            const e = yield this.store.getItem(ut);
                                            if (e)
                                                return JSON.parse(e);
                                            else
                                                return []
                                        } catch (e) {
                                            return []
                                        }
                                    }))
                            }
                            setHistory(e) {
                                try {
                                    this.store.setItem(ut, JSON.stringify(e.slice(0, 20)))
                                } catch (e) {}
                            }
                            clear() {
                                try {
                                    this.store.removeItem(ut)
                                } catch (e) {}
                            }
                            getMostRecentElement() {
                                let e = this.getHistoryWithInternalTime();
                                if (null != e) {
                                    return e.sort(((e, t) => (t.internalTime || 0) - (e.internalTime || 0)))[0]
                                }
                                return null
                            }
                            cropQueryElement(e) {
                                if (e.name && e.value && "query" === e.name.toLowerCase())
                                    e.value = e.value.slice(0, 75);
                                return e
                            }
                            isValidEntry(e) {
                                let t = this.getMostRecentElement();
                                if (t && t.value == e.value)
                                    return (e.internalTime || 0) - (t.internalTime || 0) > 6e4;
                                else
                                    return !0
                            }
                            stripInternalTime(e) {
                                return e.map((e => {
                                        const {
                                            name: t,
                                            time: n,
                                            value: i
                                        } = e;
                                        return {
                                            name: t,
                                            time: n,
                                            value: i
                                        }
                                    }))
                            }
                            stripEmptyQuery(e) {
                                const {
                                    name: t,
                                    time: n,
                                    value: i
                                } = e;
                                if (t && "string" == typeof i && "query" === t.toLowerCase() && "" === i.trim())
                                    return {
                                        name: t,
                                        time: n
                                    };
                                else
                                    return e
                            }
                            stripEmptyQueries(e) {
                                return e.map((e => this.stripEmptyQuery(e)))
                            }
                        }
                        const ft = (e, t) => Ke(void 0, void 0, void 0, (function  * () {
                                if (e === Ye.view)
                                    return yield ht(t.contentIdValue), Object.assign({
                                        location: window.location.toString(),
                                        referrer: document.referrer,
                                        title: document.title
                                    }, t);
                                else
                                    return t
                            })),
                        ht = e => Ke(void 0, void 0, void 0, (function  * () {
                                    const t = new dt,
                                    n = {
                                        name: "PageView",
                                        value: e,
                                        time: JSON.stringify(new Date)
                                    };
                                    yield t.addElementAsync(n)
                                }));
                        let pt;
                        const gt = new Uint8Array(16);
                        function mt() {
                            if (!pt)
                                if (pt = "undefined" != typeof crypto && crypto.getRandomValues && crypto.getRandomValues.bind(crypto), !pt)
                                    throw new Error("crypto.getRandomValues() not supported. See https://github.com/uuidjs/uuid#getrandomvalues-not-supported");
                            return pt(gt)
                        }
                        var vt = /^(?:[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}|00000000-0000-0000-0000-000000000000)$/i;
                        function yt(e) {
                            return "string" == typeof e && vt.test(e)
                        }
                        const bt = [];
                        for (let e = 0; e < 256; ++e)
                            bt.push((e + 256).toString(16).slice(1));
                        function wt(e, t = 0) {
                            return (bt[e[t + 0]] + bt[e[t + 1]] + bt[e[t + 2]] + bt[e[t + 3]] + "-" + bt[e[t + 4]] + bt[e[t + 5]] + "-" + bt[e[t + 6]] + bt[e[t + 7]] + "-" + bt[e[t + 8]] + bt[e[t + 9]] + "-" + bt[e[t + 10]] + bt[e[t + 11]] + bt[e[t + 12]] + bt[e[t + 13]] + bt[e[t + 14]] + bt[e[t + 15]]).toLowerCase()
                        }
                        const xt = "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
                        St = "6ba7b811-9dad-11d1-80b4-00c04fd430c8";
                        var kt = {
                            randomUUID: "undefined" != typeof crypto && crypto.randomUUID && crypto.randomUUID.bind(crypto)
                        };
                        function Ot(e, t, n) {
                            if (kt.randomUUID && !t && !e)
                                return kt.randomUUID();
                            const i = (e = e || {}).random || (e.rng || mt)();
                            if (i[6] = 15 & i[6] | 64, i[8] = 63 & i[8] | 128, t) {
                                n = n || 0;
                                for (let e = 0; e < 16; ++e)
                                    t[n + e] = i[e];
                                return t
                            }
                            return wt(i)
                        }
                        function It(e, t, n, i) {
                            switch (e) {
                            case 0:
                                return t & n ^ ~t & i;
                            case 1:
                                return t ^ n ^ i;
                            case 2:
                                return t & n ^ t & i ^ n & i;
                            case 3:
                                return t ^ n ^ i
                            }
                        }
                        function At(e, t) {
                            return e << t | e >>> 32 - t
                        }
                        const Ct = function (e, t, n) {
                            function i(e, i, r, o) {
                                var s;
                                if ("string" == typeof e)
                                    e = function (e) {
                                        e = unescape(encodeURIComponent(e));
                                        const t = [];
                                        for (let n = 0; n < e.length; ++n)
                                            t.push(e.charCodeAt(n));
                                        return t
                                    }
                                (e);
                                if ("string" == typeof i)
                                    i = function (e) {
                                        if (!yt(e))
                                            throw TypeError("Invalid UUID");
                                        let t;
                                        const n = new Uint8Array(16);
                                        return n[0] = (t = parseInt(e.slice(0, 8), 16)) >>> 24,
                                        n[1] = t >>> 16 & 255,
                                        n[2] = t >>> 8 & 255,
                                        n[3] = 255 & t,
                                        n[4] = (t = parseInt(e.slice(9, 13), 16)) >>> 8,
                                        n[5] = 255 & t,
                                        n[6] = (t = parseInt(e.slice(14, 18), 16)) >>> 8,
                                        n[7] = 255 & t,
                                        n[8] = (t = parseInt(e.slice(19, 23), 16)) >>> 8,
                                        n[9] = 255 & t,
                                        n[10] = (t = parseInt(e.slice(24, 36), 16)) / 1099511627776 & 255,
                                        n[11] = t / 4294967296 & 255,
                                        n[12] = t >>> 24 & 255,
                                        n[13] = t >>> 16 & 255,
                                        n[14] = t >>> 8 & 255,
                                        n[15] = 255 & t,
                                        n
                                    }
                                (i);
                                if (16 !== (null === (s = i) || void 0 === s ? void 0 : s.length))
                                    throw TypeError("Namespace must be array-like (16 iterable integer values, 0-255)");
                                let a = new Uint8Array(16 + e.length);
                                if (a.set(i), a.set(e, i.length), a = n(a), a[6] = 15 & a[6] | t, a[8] = 63 & a[8] | 128, r) {
                                    o = o || 0;
                                    for (let e = 0; e < 16; ++e)
                                        r[o + e] = a[e];
                                    return r
                                }
                                return wt(a)
                            }
                            try {
                                i.name = e
                            } catch (e) {}
                            return i.DNS = xt,
                            i.URL = St,
                            i
                        }
                        ("v5", 80, (function (e) {
                                const t = [1518500249, 1859775393, 2400959708, 3395469782],
                                n = [1732584193, 4023233417, 2562383102, 271733878, 3285377520];
                                if ("string" == typeof e) {
                                    const t = unescape(encodeURIComponent(e));
                                    e = [];
                                    for (let n = 0; n < t.length; ++n)
                                        e.push(t.charCodeAt(n))
                                } else if (!Array.isArray(e))
                                    e = Array.prototype.slice.call(e);
                                e.push(128);
                                const i = e.length / 4 + 2,
                                r = Math.ceil(i / 16),
                                o = new Array(r);
                                for (let t = 0; t < r; ++t) {
                                    const n = new Uint32Array(16);
                                    for (let i = 0; i < 16; ++i)
                                        n[i] = e[64 * t + 4 * i] << 24 | e[64 * t + 4 * i + 1] << 16 | e[64 * t + 4 * i + 2] << 8 | e[64 * t + 4 * i + 3];
                                    o[t] = n
                                }
                                o[r - 1][14] = 8 * (e.length - 1) / Math.pow(2, 32),
                                o[r - 1][14] = Math.floor(o[r - 1][14]),
                                o[r - 1][15] = 8 * (e.length - 1) & 4294967295;
                                for (let e = 0; e < r; ++e) {
                                    const i = new Uint32Array(80);
                                    for (let t = 0; t < 16; ++t)
                                        i[t] = o[e][t];
                                    for (let e = 16; e < 80; ++e)
                                        i[e] = At(i[e - 3] ^ i[e - 8] ^ i[e - 14] ^ i[e - 16], 1);
                                    let r = n[0],
                                    s = n[1],
                                    a = n[2],
                                    c = n[3],
                                    l = n[4];
                                    for (let e = 0; e < 80; ++e) {
                                        const n = Math.floor(e / 20),
                                        o = At(r, 5) + It(n, s, a, c) + l + t[n] + i[e] >>> 0;
                                        l = c,
                                        c = a,
                                        a = At(s, 30) >>> 0,
                                        s = r,
                                        r = o
                                    }
                                    n[0] = n[0] + r >>> 0,
                                    n[1] = n[1] + s >>> 0,
                                    n[2] = n[2] + a >>> 0,
                                    n[3] = n[3] + c >>> 0,
                                    n[4] = n[4] + l >>> 0
                                }
                                return [n[0] >> 24 & 255, n[0] >> 16 & 255, n[0] >> 8 & 255, 255 & n[0], n[1] >> 24 & 255, n[1] >> 16 & 255, n[1] >> 8 & 255, 255 & n[1], n[2] >> 24 & 255, n[2] >> 16 & 255, n[2] >> 8 & 255, 255 & n[2], n[3] >> 24 & 255, n[3] >> 16 & 255, n[3] >> 8 & 255, 255 & n[3], n[4] >> 24 & 255, n[4] >> 16 & 255, n[4] >> 8 & 255, 255 & n[4]]
                            }));
                        var Et = Ct;
                        const _t = "2.26.4",
                        Mt = e => `${e.protocol}//${e.hostname}${0===e.pathname.indexOf("/")?e.pathname:` / $ {
                            e.pathname
                        }
`}${e.search}`,
                        Rt = {
                            pageview: "pageview",
                            event: "event"
                        };
                        class jt {
                            constructor({
                                client: e,
                                uuidGenerator: t = Ot
                            }) {
                                this.client = e,
                                this.uuidGenerator = t
                            }
                        }
                        class Tt extends jt {
                            constructor({
                                client: e,
                                uuidGenerator: t = Ot
                            }) {
                                super({
                                    client: e,
                                    uuidGenerator: t
                                }),
                                this.actionData = {},
                                this.pageViewId = t(),
                                this.nextPageViewId = this.pageViewId,
                                this.currentLocation = Mt(window.location),
                                this.lastReferrer = Ze() ? document.referrer : "",
                                this.addHooks()
                            }
                            getApi(e) {
                                switch (e) {
                                case "setAction":
                                    return this.setAction;
                                default:
                                    return null
                                }
                            }
                            setAction(e, t) {
                                this.action = e,
                                this.actionData = t
                            }
                            clearData() {
                                this.clearPluginData(),
                                this.action = void 0,
                                this.actionData = {}
                            }
                            getLocationInformation(e, t) {
                                return Object.assign({
                                    hitType: e
                                }, this.getNextValues(e, t))
                            }
                            updateLocationInformation(e, t) {
                                this.updateLocationForNextPageView(e, t)
                            }
                            getDefaultContextInformation(e) {
                                const t = {
                                    title: Ze() ? document.title : "",
                                    encoding: Ze() ? document.characterSet : "UTF-8"
                                },
                                n = {
                                    screenResolution: `${screen.width}x${screen.height}`,
                                    screenColor: `${screen.colorDepth}-bit`
                                },
                                i = {
                                    language: navigator.language,
                                    userAgent: navigator.userAgent
                                },
                                r = {
                                    time: Date.now(),
                                    eventId: this.uuidGenerator()
                                };
                                return Object.assign(Object.assign(Object.assign(Object.assign({}, r), n), i), t)
                            }
                            updateLocationForNextPageView(e, t) {
                                const {
                                    pageViewId: n,
                                    referrer: i,
                                    location: r
                                } = this.getNextValues(e, t);
                                if (this.lastReferrer = i, this.pageViewId = n, this.currentLocation = r, e === Rt.pageview)
                                    this.nextPageViewId = this.uuidGenerator(), this.hasSentFirstPageView = !0
                            }
                            getNextValues(e, t) {
                                return {
                                    pageViewId: e === Rt.pageview ? this.nextPageViewId : this.pageViewId,
                                    referrer: e === Rt.pageview && this.hasSentFirstPageView ? this.currentLocation : this.lastReferrer,
                                    location: e === Rt.pageview ? this.getCurrentLocationFromPayload(t) : this.currentLocation
                                }
                            }
                            getCurrentLocationFromPayload(e) {
                                if (e.page) {
                                    const t = e => e.replace(/^\/?(.*)$/, "/$1");
                                    return `${(e=>e.split("/").slice(0,3).join("/"))(this.currentLocation)}${t(e.page)}`
                                } else
                                    return Mt(window.location)
                            }
                        }
                        class Pt {
                            constructor(e, t) {
                                if (!yt(e))
                                    throw Error("Not a valid uuid");
                                this.clientId = e,
                                this.creationDate = Math.floor(t / 1e3)
                            }
                            toString() {
                                return this.clientId.replace(/-/g, "") + "." + this.creationDate.toString()
                            }
                            get expired() {
                                const e = Math.floor(Date.now() / 1e3) - this.creationDate;
                                return e < 0 || e > Pt.expirationTime
                            }
                            validate(e, t) {
                                return !this.expired && this.matchReferrer(e, t)
                            }
                            matchReferrer(e, t) {
                                try {
                                    const n = new URL(e);
                                    return t.some((e => new RegExp(e.replace(/\\/g, "\\\\").replace(/\./g, "\\.").replace(/\*/g, ".*") + "$").test(n.host)))
                                } catch (e) {
                                    return !1
                                }
                            }
                            static fromString(e) {
                                const t = e.split(".");
                                if (2 !== t.length)
                                    return null;
                                const[n, i] = t;
                                if (32 !== n.length || isNaN(parseInt(i)))
                                    return null;
                                const r = n.substring(0, 8) + "-" + n.substring(8, 12) + "-" + n.substring(12, 16) + "-" + n.substring(16, 20) + "-" + n.substring(20, 32);
                                if (yt(r))
                                    return new Pt(r, 1e3 * Number.parseInt(i));
                                else
                                    return null
                            }
                        }
                        Pt.cvo_cid = "cvo_cid",
                        Pt.expirationTime = 120;
                        (class extends jt {
                            constructor({
                                client: e,
                                uuidGenerator: t = Ot
                            }) {
                                super({
                                    client: e,
                                    uuidGenerator: t
                                })
                            }
                            getApi(e) {
                                switch (e) {
                                case "decorate":
                                    return this.decorate;
                                case "acceptFrom":
                                    return this.acceptFrom;
                                default:
                                    return null
                                }
                            }
                            decorate(e) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        if (!this.client.getCurrentVisitorId)
                                            throw new Error("Could not retrieve current clientId");
                                        try {
                                            const t = new URL(e),
                                            n = yield this.client.getCurrentVisitorId();
                                            return t.searchParams.set(Pt.cvo_cid, new Pt(n, Date.now()).toString()),
                                            t.toString()
                                        } catch (e) {
                                            throw new Error("Invalid URL provided")
                                        }
                                    }))
                            }
                            acceptFrom(e) {
                                this.client.setAcceptedLinkReferrers(e)
                            }
                        }).Id = "link";
                        const Lt = Object.keys;
                        function Ht(e) {
                            return null !== e && "object" == typeof e && !Array.isArray(e)
                        }
                        const Ft = {
                            id: "svc_ticket_id",
                            subject: "svc_ticket_subject",
                            description: "svc_ticket_description",
                            category: "svc_ticket_category",
                            productId: "svc_ticket_product_id",
                            custom: "svc_ticket_custom"
                        },
                        Vt = [...Lt(Ft).map((e => Ft[e]))].join("|"),
                        $t = new RegExp(`^(${Vt}$)`),
                        Ut = [e => $t.test(e)],
                        Dt = {
                            id: "id",
                            name: "nm",
                            brand: "br",
                            category: "ca",
                            variant: "va",
                            price: "pr",
                            quantity: "qt",
                            coupon: "cc",
                            position: "ps",
                            group: "group"
                        },
                        Nt = {
                            id: "id",
                            name: "nm",
                            brand: "br",
                            category: "ca",
                            variant: "va",
                            position: "ps",
                            price: "pr",
                            group: "group"
                        },
                        qt = {
                            action: "pa",
                            list: "pal",
                            listSource: "pls"
                        },
                        Wt = {
                            id: "ti",
                            revenue: "tr",
                            tax: "tt",
                            shipping: "ts",
                            coupon: "tcc",
                            affiliation: "ta",
                            step: "cos",
                            option: "col"
                        },
                        Qt = {
                            id: "quoteId",
                            affiliation: "quoteAffiliation"
                        },
                        Bt = {
                            id: "reviewId",
                            rating: "reviewRating",
                            comment: "reviewComment"
                        },
                        zt = {
                            add: qt,
                            bookmark_add: qt,
                            bookmark_remove: qt,
                            click: qt,
                            checkout: qt,
                            checkout_option: qt,
                            detail: qt,
                            impression: qt,
                            remove: qt,
                            refund: Object.assign(Object.assign({}, qt), Wt),
                            purchase: Object.assign(Object.assign({}, qt), Wt),
                            quickview: qt,
                            quote: Object.assign(Object.assign({}, qt), Qt),
                            review: Object.assign(Object.assign({}, qt), Bt)
                        },
                        Gt = Lt(Dt).map((e => Dt[e])),
                        Jt = Lt(Nt).map((e => Nt[e])),
                        Kt = Lt(qt).map((e => qt[e])),
                        Yt = Lt(Wt).map((e => Wt[e])),
                        Xt = Lt(Bt).map((e => Bt[e])),
                        Zt = Lt(Qt).map((e => Qt[e])),
                        en = [...Gt, "custom"].join("|"),
                        tn = [...Jt, "custom"].join("|"),
                        nn = "(pr[0-9]+)",
                        rn = "(il[0-9]+pi[0-9]+)",
                        on = new RegExp(`^${nn}(${en})$`),
                        sn = new RegExp(`^(${rn}(${tn}))|(il[0-9]+nm)$`),
                        an = new RegExp(`^(${Kt.join("|")})$`),
                        cn = new RegExp(`^(${Yt.join("|")})$`),
                        ln = new RegExp(`^${nn}custom$`),
                        un = new RegExp(`^${rn}custom$`),
                        dn = new RegExp(`^(${["loyaltyCardId","loyaltyTier","thirdPartyPersona","companyName","favoriteStore","storeName","userIndustry","userRole","userDepartment","businessUnit",...Xt,...Zt].join("|")})$`),
                        fn = [e => sn.test(e), e => on.test(e), e => an.test(e), e => cn.test(e), e => dn.test(e)],
                        hn = [ln, un],
                        pn = Object.assign(Object.assign(Object.assign(Object.assign({}, {
                                            anonymizeIp: "aip"
                                        }), {
                                        eventCategory: "ec",
                                        eventAction: "ea",
                                        eventLabel: "el",
                                        eventValue: "ev",
                                        page: "dp",
                                        visitorId: "cid",
                                        clientId: "cid",
                                        userId: "uid",
                                        currencyCode: "cu"
                                    }), {
                                    hitType: "t",
                                    pageViewId: "pid",
                                    encoding: "de",
                                    location: "dl",
                                    referrer: "dr",
                                    screenColor: "sd",
                                    screenResolution: "sr",
                                    title: "dt",
                                    userAgent: "ua",
                                    language: "ul",
                                    eventId: "z",
                                    time: "tm"
                                }), ["contentId", "contentIdKey", "contentType", "searchHub", "tab", "searchUid", "permanentId", "contentLocale"].reduce(((e, t) => Object.assign(Object.assign({}, e), {
                                            [t]: t
                                        })), {})),
                        gn = Object.assign(Object.assign({}, pn), {
                            svcAction: "svc_action",
                            svcActionData: "svc_action_data"
                        }),
                        mn = Lt(gn).map((e => gn[e])),
                        vn = e => -1 !== mn.indexOf(e),
                        yn = e => "custom" === e,
                        bn = e => {
                            let t;
                            return [...hn].every((n => {
                                    var i;
                                    return t = null === (i = n.exec(e)) || void 0 === i ? void 0 : i[1],
                                    !Boolean(t)
                                })),
                            t
                        },
                        wn = (e, t) => Lt(t).reduce(((n, i) => Object.assign(Object.assign({}, n), {
                                    [`${e}${i}`]: t[i]
                                })), {});
                        class xn {
                            constructor(e) {
                                this.opts = e
                            }
                            sendEvent(e, t) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        if (!navigator.sendBeacon)
                                            throw new Error('navigator.sendBeacon is not supported in this browser. Consider adding a polyfill like "sendbeacon-polyfill".');
                                        const {
                                            baseUrl: n,
                                            preprocessRequest: i
                                        } = this.opts,
                                        r = this.encodeForEventType(e, t),
                                        o = yield this.getQueryParamsForEventType(e),
                                        s = {
                                            url: `${n}/analytics/${e}?${o}`,
                                            body: new Blob([r], {
                                                type: "application/x-www-form-urlencoded"
                                            })
                                        }, {
                                            url: a,
                                            body: c
                                        } = Object.assign(Object.assign({}, s), i ? yield i(s, "analyticsBeacon") : {});
                                        console.log(`Sending beacon for "${e}" with: `, JSON.stringify(t)),
                                        navigator.sendBeacon(a, c)
                                    }))
                            }
                            deleteHttpCookieVisitorId() {
                                return Promise.resolve()
                            }
                            encodeForEventType(e, t) {
                                return this.isEventTypeLegacy(e) ? this.encodeForLegacyType(e, t) : this.encodeForFormUrlEncoded(Object.assign({
                                        access_token: this.opts.token
                                    }, t))
                            }
                            getQueryParamsForEventType(e) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        const {
                                            token: t,
                                            visitorIdProvider: n
                                        } = this.opts,
                                        i = yield n.getCurrentVisitorId();
                                        return [t && this.isEventTypeLegacy(e) ? `access_token=${t}` : "", i ? `visitorId=${i}` : "", "discardVisitInfo=true"].filter((e => !!e)).join("&")
                                    }))
                            }
                            isEventTypeLegacy(e) {
                                return -1 !== [Ye.click, Ye.custom, Ye.search, Ye.view].indexOf(e)
                            }
                            encodeForLegacyType(e, t) {
                                return `${e}Event=${encodeURIComponent(JSON.stringify(t))}`
                            }
                            encodeForFormUrlEncoded(e) {
                                return Object.keys(e).filter((t => !!e[t])).map((t => `${encodeURIComponent(t)}=${encodeURIComponent(this.encodeValue(e[t]))}`)).join("&")
                            }
                            encodeValue(e) {
                                return "number" == typeof e || "string" == typeof e || "boolean" == typeof e ? e : JSON.stringify(e)
                            }
                        }
                        const Sn = window.fetch;
                        class kn {
                            constructor(e) {
                                this.opts = e
                            }
                            sendEvent(e, t) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        const {
                                            baseUrl: n,
                                            visitorIdProvider: i,
                                            preprocessRequest: r
                                        } = this.opts,
                                        o = this.shouldAppendVisitorId(e) ? yield this.getVisitorIdParam() : "",
                                        s = {
                                            url: `${n}/analytics/${e}${o}`,
                                            credentials: "include",
                                            mode: "cors",
                                            headers: this.getHeaders(),
                                            method: "POST",
                                            body: JSON.stringify(t)
                                        },
                                        a = Object.assign(Object.assign({}, s), r ? yield r(s, "analyticsFetch") : {}), {
                                            url: c
                                        } = a,
                                        l = Je(a, ["url"]),
                                        u = yield Sn(c, l);
                                        if (u.ok) {
                                            const e = yield u.json();
                                            if (e.visitorId)
                                                i.setCurrentVisitorId(e.visitorId);
                                            return e
                                        } else {
                                            try {
                                                u.json()
                                            } catch (e) {}
                                            throw console.error(`An error has occured when sending the "${e}" event.`, u, t),
                                            new Error(`An error has occurred when sending the "${e}" event. Check the console logs for more details.`)
                                        }
                                    }))
                            }
                            deleteHttpCookieVisitorId() {
                                return Ke(this, void 0, void 0, (function  * () {
                                        const {
                                            baseUrl: e
                                        } = this.opts,
                                        t = `${e}/analytics/visit`;
                                        yield Sn(t, {
                                            headers: this.getHeaders(),
                                            method: "DELETE"
                                        })
                                    }))
                            }
                            shouldAppendVisitorId(e) {
                                return -1 !== [Ye.click, Ye.custom, Ye.search, Ye.view].indexOf(e)
                            }
                            getVisitorIdParam() {
                                return Ke(this, void 0, void 0, (function  * () {
                                        const {
                                            visitorIdProvider: e
                                        } = this.opts,
                                        t = yield e.getCurrentVisitorId();
                                        return t ? `?visitor=${t}` : ""
                                    }))
                            }
                            getHeaders() {
                                const {
                                    token: e
                                } = this.opts;
                                return Object.assign(Object.assign({}, e ? {
                                        Authorization: `Bearer ${e}`
                                    }
                                         : {}), {
                                    "Content-Type": "application/json"
                                })
                            }
                        }
                        class On {
                            constructor(e, t) {
                                if (et() && tt())
                                    this.storage = new ct;
                                else if (et())
                                    this.storage = localStorage;
                                else
                                    console.warn("BrowserRuntime detected no valid storage available.", this), this.storage = new lt;
                                this.client = new kn(e),
                                this.beaconClient = new xn(e),
                                window.addEventListener("beforeunload", (() => {
                                        const e = t();
                                        for (let {
                                            eventType: t,
                                            payload: n
                                        }
                                            of e)
                                            this.beaconClient.sendEvent(t, n)
                                    }))
                            }
                        }
                        class In {
                            constructor(e, t) {
                                this.storage = t || new lt,
                                this.client = new kn(e)
                            }
                        }
                        const An = ["1", 1, "yes", !0];
                        function Cn() {
                            return Xe() && [navigator.globalPrivacyControl, navigator.doNotTrack, navigator.msDoNotTrack, window.doNotTrack].some((e => -1 !== An.indexOf(e)))
                        }
                        const En = "v15",
                        _n = {
                        default:
                            "https://analytics.cloud.coveo.com/rest/ua",
                            production: "https://analytics.cloud.coveo.com/rest/ua",
                            hipaa: "https://analyticshipaa.cloud.coveo.com/rest/ua"
                        };
                        class Mn {
                            constructor(e) {
                                if (this.acceptedLinkReferrers = [], !e)
                                    throw new Error("You have to pass options to this constructor");
                                this.options = Object.assign(Object.assign({}, this.defaultOptions), e),
                                this.visitorId = "",
                                this.bufferedRequests = [],
                                this.beforeSendHooks = [ft, it].concat(this.options.beforeSendHooks),
                                this.afterSendHooks = this.options.afterSendHooks,
                                this.eventTypeMapping = {};
                                const t = {
                                    baseUrl: this.baseUrl,
                                    token: this.options.token,
                                    visitorIdProvider: this,
                                    preprocessRequest: this.options.preprocessRequest
                                };
                                if (this.runtime = this.options.runtimeEnvironment || this.initRuntime(t), Cn())
                                    this.clear(), this.runtime.storage = new lt
                            }
                            get defaultOptions() {
                                return {
                                    endpoint: _n.default,
                                    token: "",
                                    version: En,
                                    beforeSendHooks: [],
                                    afterSendHooks: []
                                }
                            }
                            get version() {
                                return _t
                            }
                            initRuntime(e) {
                                if ("undefined" != typeof window && Ze())
                                    return new On(e, (() => {
                                            const e = [...this.bufferedRequests];
                                            return this.bufferedRequests = [],
                                            e
                                        }));
                                else if ("undefined" != typeof navigator && "ReactNative" == navigator.product)
                                    console.warn("\n        We've detected you're using React Native but have not provided the corresponding runtime, \n        for an optimal experience please use the \"coveo.analytics/react-native\" subpackage.\n        Follow the Readme on how to set it up: https://github.com/coveo/coveo.analytics.js#using-react-native\n    ");
                                return new In(e)
                            }
                            get storage() {
                                return this.runtime.storage
                            }
                            determineVisitorId() {
                                return Ke(this, void 0, void 0, (function  * () {
                                        try {
                                            return this.extractClientIdFromLink(window.location.href) || (yield this.storage.getItem("visitorId")) || Ot()
                                        } catch (e) {
                                            return console.log("Could not get visitor ID from the current runtime environment storage. Using a random ID instead.", e),
                                            Ot()
                                        }
                                    }))
                            }
                            getCurrentVisitorId() {
                                return Ke(this, void 0, void 0, (function  * () {
                                        if (!this.visitorId) {
                                            const e = yield this.determineVisitorId();
                                            yield this.setCurrentVisitorId(e)
                                        }
                                        return this.visitorId
                                    }))
                            }
                            setCurrentVisitorId(e) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        this.visitorId = e,
                                        yield this.storage.setItem("visitorId", e)
                                    }))
                            }
                            setClientId(e, t) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        if (yt(e))
                                            this.setCurrentVisitorId(e.toLowerCase());
                                        else {
                                            if (!t)
                                                throw Error("Cannot generate uuid client id without a specific namespace string.");
                                            this.setCurrentVisitorId(Et(e, Et(t, "38824e1f-37f5-42d3-8372-a4b8fa9df946")))
                                        }
                                    }))
                            }
                            getParameters(e, ...t) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        return yield this.resolveParameters(e, ...t)
                                    }))
                            }
                            getPayload(e, ...t) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        const n = yield this.resolveParameters(e, ...t);
                                        return yield this.resolvePayloadForParameters(e, n)
                                    }))
                            }
                            get currentVisitorId() {
                                if ("string" != typeof(this.visitorId || this.storage.getItem("visitorId")))
                                    this.setCurrentVisitorId(Ot());
                                return this.visitorId
                            }
                            set currentVisitorId(e) {
                                this.visitorId = e,
                                this.storage.setItem("visitorId", e)
                            }
                            extractClientIdFromLink(e) {
                                if (Cn())
                                    return null;
                                try {
                                    const t = new URL(e).searchParams.get(Pt.cvo_cid);
                                    if (null == t)
                                        return null;
                                    const n = Pt.fromString(t);
                                    if (!n || !Ze() || !n.validate(document.referrer, this.acceptedLinkReferrers))
                                        return null;
                                    else
                                        return n.clientId
                                } catch (e) {}
                                return null
                            }
                            resolveParameters(e, ...t) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        const {
                                            variableLengthArgumentsNames: n = [],
                                            addVisitorIdParameter: i = !1,
                                            usesMeasurementProtocol: r = !1,
                                            addClientIdParameter: o = !1
                                        } = this.eventTypeMapping[e] || {},
                                        s = yield[e => n.length > 0 ? this.parseVariableArgumentsPayload(n, e) : e[0], e => Ke(this, void 0, void 0, (function  * () {
                                                        return Object.assign(Object.assign({}, e), {
                                                            visitorId: i ? yield this.getCurrentVisitorId() : ""
                                                        })
                                                    })), e => Ke(this, void 0, void 0, (function  * () {
                                                        if (o)
                                                            return Object.assign(Object.assign({}, e), {
                                                                clientId: yield this.getCurrentVisitorId()
                                                            });
                                                        else
                                                            return e
                                                    })), e => r ? this.ensureAnonymousUserWhenUsingApiKey(e) : e, t => this.beforeSendHooks.reduce(((t, n) => Ke(this, void 0, void 0, (function  * () {
                                                                const i = yield t;
                                                                return yield n(e, i)
                                                            }))), t)].reduce(((e, t) => Ke(this, void 0, void 0, (function  * () {
                                                            const n = yield e;
                                                            return yield t(n)
                                                        }))), Promise.resolve(t));
                                        return s
                                    }))
                            }
                            resolvePayloadForParameters(e, t) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        const {
                                            usesMeasurementProtocol: n = !1
                                        } = this.eventTypeMapping[e] || {};
                                        return yield[t => this.removeEmptyPayloadValues(t, e), e => this.validateParams(e), e => n ? (e => {
                                                const t = !!e.action && zt[e.action] || {};
                                                return Lt(e).reduce(((n, i) => {
                                                        const r = t[i] || gn[i] || i;
                                                        return Object.assign(Object.assign({}, n), {
                                                            [r]: e[i]
                                                        })
                                                    }), {})
                                            })(e) : e, e => n ? this.removeUnknownParameters(e) : e, e => n ? this.processCustomParameters(e) : this.mapCustomParametersToCustomData(e)].reduce(((e, t) => Ke(this, void 0, void 0, (function  * () {
                                                        const n = yield e;
                                                        return yield t(n)
                                                    }))), Promise.resolve(t))
                                    }))
                            }
                            makeEvent(e, ...t) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        const {
                                            newEventType: n = e
                                        } = this.eventTypeMapping[e] || {},
                                        i = yield this.resolveParameters(e, ...t),
                                        r = yield this.resolvePayloadForParameters(e, i);
                                        return {
                                            eventType: n,
                                            payload: r,
                                            log: t => Ke(this, void 0, void 0, (function  * () {
                                                    return this.bufferedRequests.push({
                                                        eventType: n,
                                                        payload: Object.assign(Object.assign({}, r), t)
                                                    }),
                                                    yield Promise.all(this.afterSendHooks.map((n => n(e, Object.assign(Object.assign({}, i), t))))),
                                                    yield this.deferExecution(),
                                                    yield this.sendFromBufferWithFetch()
                                                }))
                                        }
                                    }))
                            }
                            sendEvent(e, ...t) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        return (yield this.makeEvent(e, ...t)).log({})
                                    }))
                            }
                            deferExecution() {
                                return new Promise((e => setTimeout(e, 0)))
                            }
                            sendFromBufferWithFetch() {
                                return Ke(this, void 0, void 0, (function  * () {
                                        const e = this.bufferedRequests.shift();
                                        if (e) {
                                            const {
                                                eventType: t,
                                                payload: n
                                            } = e;
                                            return this.runtime.client.sendEvent(t, n)
                                        }
                                    }))
                            }
                            clear() {
                                this.storage.removeItem("visitorId");
                                (new dt).clear()
                            }
                            deleteHttpOnlyVisitorId() {
                                this.runtime.client.deleteHttpCookieVisitorId()
                            }
                            makeSearchEvent(e) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        return this.makeEvent(Ye.search, e)
                                    }))
                            }
                            sendSearchEvent(e) {
                                var {
                                    searchQueryUid: t
                                } = e,
                                n = Je(e, ["searchQueryUid"]);
                                return Ke(this, void 0, void 0, (function  * () {
                                        return (yield this.makeSearchEvent(n)).log({
                                            searchQueryUid: t
                                        })
                                    }))
                            }
                            makeClickEvent(e) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        return this.makeEvent(Ye.click, e)
                                    }))
                            }
                            sendClickEvent(e) {
                                var {
                                    searchQueryUid: t
                                } = e,
                                n = Je(e, ["searchQueryUid"]);
                                return Ke(this, void 0, void 0, (function  * () {
                                        return (yield this.makeClickEvent(n)).log({
                                            searchQueryUid: t
                                        })
                                    }))
                            }
                            makeCustomEvent(e) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        return this.makeEvent(Ye.custom, e)
                                    }))
                            }
                            sendCustomEvent(e) {
                                var {
                                    lastSearchQueryUid: t
                                } = e,
                                n = Je(e, ["lastSearchQueryUid"]);
                                return Ke(this, void 0, void 0, (function  * () {
                                        return (yield this.makeCustomEvent(n)).log({
                                            lastSearchQueryUid: t
                                        })
                                    }))
                            }
                            makeViewEvent(e) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        return this.makeEvent(Ye.view, e)
                                    }))
                            }
                            sendViewEvent(e) {
                                return Ke(this, void 0, void 0, (function  * () {
                                        return (yield this.makeViewEvent(e)).log({})
                                    }))
                            }
                            getVisit() {
                                return Ke(this, void 0, void 0, (function  * () {
                                        const e = yield fetch(`${this.baseUrl}/analytics/visit`),
                                        t = yield e.json();
                                        return this.visitorId = t.visitorId,
                                        t
                                    }))
                            }
                            getHealth() {
                                return Ke(this, void 0, void 0, (function  * () {
                                        const e = yield fetch(`${this.baseUrl}/analytics/monitoring/health`);
                                        return yield e.json()
                                    }))
                            }
                            registerBeforeSendEventHook(e) {
                                this.beforeSendHooks.push(e)
                            }
                            registerAfterSendEventHook(e) {
                                this.afterSendHooks.push(e)
                            }
                            addEventTypeMapping(e, t) {
                                this.eventTypeMapping[e] = t
                            }
                            setAcceptedLinkReferrers(e) {
                                if (Array.isArray(e) && e.every((e => "string" == typeof e)))
                                    this.acceptedLinkReferrers = e;
                                else
                                    throw Error("Parameter should be an array of domain strings")
                            }
                            parseVariableArgumentsPayload(e, t) {
                                const n = {};
                                for (let i = 0, r = t.length; i < r; i++) {
                                    const r = t[i];
                                    if ("string" == typeof r)
                                        n[e[i]] = r;
                                    else if ("object" == typeof r)
                                        return Object.assign(Object.assign({}, n), r)
                                }
                                return n
                            }
                            isKeyAllowedEmpty(e, t) {
                                return -1 !== ({
                                    [Ye.search]: ["queryText"]
                                }
                                    [e] || []).indexOf(t)
                            }
                            removeEmptyPayloadValues(e, t) {
                                return Object.keys(e).filter((n => {
                                        return this.isKeyAllowedEmpty(t, n) || null != (i = e[n]) && "" !== i;
                                        var i
                                    })).reduce(((t, n) => Object.assign(Object.assign({}, t), {
                                            [n]: e[n]
                                        })), {})
                            }
                            removeUnknownParameters(e) {
                                return Object.keys(e).filter((e => {
                                        if ((e => [...fn, ...Ut, vn, yn].some((t => t(e))))(e))
                                            return !0;
                                        else
                                            console.log(e, "is not processed by coveoua")
                                    })).reduce(((t, n) => Object.assign(Object.assign({}, t), {
                                            [n]: e[n]
                                        })), {})
                            }
                            processCustomParameters(e) {
                                const {
                                    custom: t
                                } = e,
                                n = Je(e, ["custom"]);
                                let i = {};
                                if (t && Ht(t))
                                    i = this.lowercaseKeys(t);
                                const r = Lt(o = n).reduce(((e, t) => {
                                            const n = bn(t);
                                            if (n)
                                                return Object.assign(Object.assign({}, e), wn(n, o[t]));
                                            else
                                                return Object.assign(Object.assign({}, e), {
                                                    [t]: o[t]
                                                })
                                        }), {});
                                var o;
                                return Object.assign(Object.assign({}, i), r)
                            }
                            mapCustomParametersToCustomData(e) {
                                const {
                                    custom: t
                                } = e,
                                n = Je(e, ["custom"]);
                                if (t && Ht(t)) {
                                    const i = this.lowercaseKeys(t);
                                    return Object.assign(Object.assign({}, n), {
                                        customData: Object.assign(Object.assign({}, i), e.customData)
                                    })
                                } else
                                    return e
                            }
                            lowercaseKeys(e) {
                                const t = Object.keys(e);
                                let n = {};
                                return t.forEach((t => {
                                        n[t.toLowerCase()] = e[t]
                                    })),
                                n
                            }
                            validateParams(e) {
                                const {
                                    anonymizeIp: t
                                } = e,
                                n = Je(e, ["anonymizeIp"]);
                                if (void 0 !== t)
                                    if (-1 == ["0", "false", "undefined", "null", "{}", "[]", ""].indexOf(`${t}`.toLowerCase()))
                                        n.anonymizeIp = 1;
                                return n
                            }
                            ensureAnonymousUserWhenUsingApiKey(e) {
                                const {
                                    userId: t
                                } = e,
                                n = Je(e, ["userId"]);
                                if ((null == (i = this.options.token) ? void 0 : i.startsWith("xx")) && !t)
                                    return n.userId = "anonymous", n;
                                else
                                    return e;
                                var i
                            }
                            get baseUrl() {
                                return function (e = _n.default, t = En) {
                                    const n = -1 !== e.indexOf(".cloud.coveo.com");
                                    return `${e}${n?"":"/rest"}/${t}`
                                }
                                (this.options.endpoint, this.options.version)
                            }
                        }
                        var Rn,
                        jn;
                        !function (e) {
                            e.contextChanged = "contextChanged",
                            e.expandToFullUI = "expandToFullUI",
                            e.openUserActions = "openUserActions",
                            e.showPrecedingSessions = "showPrecedingSessions",
                            e.showFollowingSessions = "showFollowingSessions",
                            e.clickViewedDocument = "clickViewedDocument",
                            e.clickPageView = "clickPageView"
                        }
                        (Rn || (Rn = {})),
                        function (e) {
                            e.interfaceLoad = "interfaceLoad",
                            e.interfaceChange = "interfaceChange",
                            e.didyoumeanAutomatic = "didyoumeanAutomatic",
                            e.didyoumeanClick = "didyoumeanClick",
                            e.resultsSort = "resultsSort",
                            e.searchboxSubmit = "searchboxSubmit",
                            e.searchboxClear = "searchboxClear",
                            e.searchboxAsYouType = "searchboxAsYouType",
                            e.breadcrumbFacet = "breadcrumbFacet",
                            e.breadcrumbResetAll = "breadcrumbResetAll",
                            e.documentQuickview = "documentQuickview",
                            e.documentOpen = "documentOpen",
                            e.omniboxAnalytics = "omniboxAnalytics",
                            e.omniboxFromLink = "omniboxFromLink",
                            e.searchFromLink = "searchFromLink",
                            e.triggerNotify = "notify",
                            e.triggerExecute = "execute",
                            e.triggerQuery = "query",
                            e.undoTriggerQuery = "undoQuery",
                            e.triggerRedirect = "redirect",
                            e.pagerResize = "pagerResize",
                            e.pagerNumber = "pagerNumber",
                            e.pagerNext = "pagerNext",
                            e.pagerPrevious = "pagerPrevious",
                            e.pagerScrolling = "pagerScrolling",
                            e.staticFilterClearAll = "staticFilterClearAll",
                            e.staticFilterSelect = "staticFilterSelect",
                            e.staticFilterDeselect = "staticFilterDeselect",
                            e.facetClearAll = "facetClearAll",
                            e.facetSearch = "facetSearch",
                            e.facetSelect = "facetSelect",
                            e.facetSelectAll = "facetSelectAll",
                            e.facetDeselect = "facetDeselect",
                            e.facetExclude = "facetExclude",
                            e.facetUnexclude = "facetUnexclude",
                            e.facetUpdateSort = "facetUpdateSort",
                            e.facetShowMore = "showMoreFacetResults",
                            e.facetShowLess = "showLessFacetResults",
                            e.queryError = "query",
                            e.queryErrorBack = "errorBack",
                            e.queryErrorClear = "errorClearQuery",
                            e.queryErrorRetry = "errorRetry",
                            e.recommendation = "recommendation",
                            e.recommendationInterfaceLoad = "recommendationInterfaceLoad",
                            e.recommendationOpen = "recommendationOpen",
                            e.likeSmartSnippet = "likeSmartSnippet",
                            e.dislikeSmartSnippet = "dislikeSmartSnippet",
                            e.expandSmartSnippet = "expandSmartSnippet",
                            e.collapseSmartSnippet = "collapseSmartSnippet",
                            e.openSmartSnippetFeedbackModal = "openSmartSnippetFeedbackModal",
                            e.closeSmartSnippetFeedbackModal = "closeSmartSnippetFeedbackModal",
                            e.sendSmartSnippetReason = "sendSmartSnippetReason",
                            e.expandSmartSnippetSuggestion = "expandSmartSnippetSuggestion",
                            e.collapseSmartSnippetSuggestion = "collapseSmartSnippetSuggestion",
                            e.showMoreSmartSnippetSuggestion = "showMoreSmartSnippetSuggestion",
                            e.showLessSmartSnippetSuggestion = "showLessSmartSnippetSuggestion",
                            e.openSmartSnippetSource = "openSmartSnippetSource",
                            e.openSmartSnippetSuggestionSource = "openSmartSnippetSuggestionSource",
                            e.openSmartSnippetInlineLink = "openSmartSnippetInlineLink",
                            e.openSmartSnippetSuggestionInlineLink = "openSmartSnippetSuggestionInlineLink",
                            e.recentQueryClick = "recentQueriesClick",
                            e.clearRecentQueries = "clearRecentQueries",
                            e.recentResultClick = "recentResultClick",
                            e.clearRecentResults = "clearRecentResults",
                            e.noResultsBack = "noResultsBack",
                            e.showMoreFoldedResults = "showMoreFoldedResults",
                            e.showLessFoldedResults = "showLessFoldedResults",
                            e.copyToClipboard = "copyToClipboard",
                            e.caseAttach = "caseAttach",
                            e.caseDetach = "caseDetach"
                        }
                        (jn || (jn = {}));
                        jn.triggerNotify,
                        jn.triggerExecute,
                        jn.triggerQuery,
                        jn.triggerRedirect,
                        jn.queryError,
                        jn.queryErrorBack,
                        jn.queryErrorClear,
                        jn.queryErrorRetry,
                        jn.pagerNext,
                        jn.pagerPrevious,
                        jn.pagerNumber,
                        jn.pagerResize,
                        jn.pagerScrolling,
                        jn.facetSearch,
                        jn.facetShowLess,
                        jn.facetShowMore,
                        jn.recommendation,
                        jn.likeSmartSnippet,
                        jn.dislikeSmartSnippet,
                        jn.expandSmartSnippet,
                        jn.collapseSmartSnippet,
                        jn.openSmartSnippetFeedbackModal,
                        jn.closeSmartSnippetFeedbackModal,
                        jn.sendSmartSnippetReason,
                        jn.expandSmartSnippetSuggestion,
                        jn.collapseSmartSnippetSuggestion,
                        jn.showMoreSmartSnippetSuggestion,
                        jn.showLessSmartSnippetSuggestion,
                        jn.clearRecentQueries,
                        jn.recentResultClick,
                        jn.clearRecentResults,
                        jn.showLessFoldedResults,
                        Rn.expandToFullUI,
                        Rn.openUserActions,
                        Rn.showPrecedingSessions,
                        Rn.showFollowingSessions,
                        Rn.clickViewedDocument,
                        Rn.clickPageView,
                        jn.caseDetach;
                        const Tn = Object.assign({}, Rt),
                        Pn = Object.keys(Tn).map((e => Tn[e]));
                        class Ln extends Tt {
                            constructor({
                                client: e,
                                uuidGenerator: t = Ot
                            }) {
                                super({
                                    client: e,
                                    uuidGenerator: t
                                }),
                                this.ticket = {}
                            }
                            getApi(e) {
                                const t = super.getApi(e);
                                if (null !== t)
                                    return t;
                                switch (e) {
                                case "setTicket":
                                    return this.setTicket;
                                default:
                                    return null
                                }
                            }
                            addHooks() {
                                this.addHooksForEvent(),
                                this.addHooksForPageView(),
                                this.addHooksForSVCEvents()
                            }
                            setTicket(e) {
                                this.ticket = e
                            }
                            clearPluginData() {
                                this.ticket = {}
                            }
                            addHooksForSVCEvents() {
                                this.client.registerBeforeSendEventHook(((e, ...[t]) => -1 !== Pn.indexOf(e) ? this.addSVCDataToPayload(e, t) : t)),
                                this.client.registerAfterSendEventHook(((e, ...[t]) => {
                                        if (-1 !== Pn.indexOf(e))
                                            this.updateLocationInformation(e, t);
                                        return t
                                    }))
                            }
                            addHooksForPageView() {
                                this.client.addEventTypeMapping(Tn.pageview, {
                                    newEventType: Ye.collect,
                                    variableLengthArgumentsNames: ["page"],
                                    addVisitorIdParameter: !0,
                                    usesMeasurementProtocol: !0
                                })
                            }
                            addHooksForEvent() {
                                this.client.addEventTypeMapping(Tn.event, {
                                    newEventType: Ye.collect,
                                    variableLengthArgumentsNames: ["eventCategory", "eventAction", "eventLabel", "eventValue"],
                                    addVisitorIdParameter: !0,
                                    usesMeasurementProtocol: !0
                                })
                            }
                            addSVCDataToPayload(e, t) {
                                var n;
                                const i = Object.assign(Object.assign(Object.assign(Object.assign({}, this.getLocationInformation(e, t)), this.getDefaultContextInformation(e)), this.action ? {
                                            svcAction: this.action
                                        }
                                             : {}), Object.keys(null !== (n = this.actionData) && void 0 !== n ? n : {}).length > 0 ? {
                                        svcActionData: this.actionData
                                    }
                                         : {}),
                                r = this.getTicketPayload();
                                return this.clearData(),
                                Object.assign(Object.assign(Object.assign({}, r), i), t)
                            }
                            getTicketPayload() {
                                return e = this.ticket,
                                Lt(e).filter((t => void 0 !== e[t])).reduce(((t, n) => {
                                        const i = Ft[n] || n;
                                        return Object.assign(Object.assign({}, t), {
                                            [i]: e[n]
                                        })
                                    }), {});
                                var e
                            }
                        }
                        var Hn,
                        Fn,
                        Vn;
                        Ln.Id = "svc",
                        function (e) {
                            e.click = "click",
                            e.flowStart = "flowStart"
                        }
                        (Hn || (Hn = {})),
                        function (e) {
                            e.enterInterface = "ticket_create_start",
                            e.fieldUpdate = "ticket_field_update",
                            e.fieldSuggestionClick = "ticket_classification_click",
                            e.suggestionClick = "suggestion_click",
                            e.suggestionRate = "suggestion_rate",
                            e.nextCaseStep = "ticket_next_stage",
                            e.caseCancelled = "ticket_cancel",
                            e.caseSolved = "ticket_cancel",
                            e.caseCreated = "ticket_create"
                        }
                        (Fn || (Fn = {})),
                        function (e) {
                            e.quit = "Quit",
                            e.solved = "Solved"
                        }
                        (Vn || (Vn = {}));
                        function $n(e) {
                            const t = `IPX is no longer injecting a "${e}" global. If you would like to use it, please load the following script before IPX:\n\n<script type="text/javascript" src="https://static.cloud.coveo.com/coveo.analytics.js/2/coveoua.js"><\/script>`;
                            if (!(e in window))
                                Object.defineProperty(window, e, {
                                    get: () => console.warn(t)
                                })
                        }
                        $n("coveoua"),
                        $n("coveoanalytics");
                        var Un = function (e, t, n, i) {
                            return new(n || (n = Promise))((function (r, o) {
                                    function s(e) {
                                        try {
                                            c(i.next(e))
                                        } catch (e) {
                                            o(e)
                                        }
                                    }
                                    function a(e) {
                                        try {
                                            c(i.throw(e))
                                        } catch (e) {
                                            o(e)
                                        }
                                    }
                                    function c(e) {
                                        var t;
                                        e.done ? r(e.value) : (t = e.value, t instanceof n ? t : new n((function (e) {
                                                    e(t)
                                                }))).then(s, a)
                                    }
                                    c((i = i.apply(e, t || [])).next())
                                }))
                        };
                        window.customElements.define(De.Page, I),
                        window.customElements.define(De.PageModal, A),
                        window.customElements.define(De.CoveoInAppWidgetLoader, ze),
                        new class {
                            constructor() {
                                this.trackPageView(),
                                this.initExperience()
                            }
                            trackPageView() {
                                new Mn({
                                    token: t,
                                    endpoint: g
                                }).sendCustomEvent({
                                    eventType: "appNavigation",
                                    eventValue: "pageView",
                                    originLevel2: "default",
                                    originLevel3: document.location.href,
                                    language: navigator.language,
                                    customData: {
                                        IPX: !0,
                                        IPX_ID: m,
                                        referrer: document.location.href
                                    }
                                })
                            }
                            initExperience() {
                                e ? this.createEmbeddedSearchPage() : this.createButton()
                            }
                            createEmbeddedSearchPage() {
                                new Ge
                            }
                            createButton() {
                                const e = document.createElement(De.CoveoInAppWidgetLoader);
                                document.body.appendChild(e)
                            }
                        },
                        O.value.then((e => {
                                k.init(e.iframe.contentWindow),
                                k.subscribeToCustomTokenHasExpired((() => Un(void 0, void 0, void 0, (function  * () {
                                                try {
                                                    const e = yield Gn();
                                                    k.publishNewCustomToken(e)
                                                } catch (e) {
                                                    k.publishNewCustomToken(""),
                                                    console.error("Failed to renew the access token. Please check your renew access token function", e)
                                                }
                                            }))))
                            }));
                        const Dn = e => k.publishContext(e),
                        Nn = (e, t) => k.publishContextValue(e, t),
                        qn = e => k.publishExecuteQuery(e),
                        Wn = e => k.publishExecuteRecommendationQuery(e),
                        Qn = () => k.publishOpen(),
                        Bn = () => k.publishClose();
                        var zn = !0,
                        Gn = () => Promise.resolve("");
                        const Jn = e => {
                            if (Gn = e, zn)
                                k.customRenewFunctionIsAvailable(), zn = !1
                        },
                        Kn = () => {
                            const e = document.querySelector(De.CoveoInAppWidgetLoader);
                            e && e.hide()
                        },
                        Yn = () => {
                            const e = document.querySelector(De.CoveoInAppWidgetLoader);
                            e && e.show()
                        }
                    })(),
                    CoveoInProduct = i
                })();

                w.CoveoInProduct = CoveoInProduct;

            } catch (error) {
                console.log('error' + 'fnCallCoveoInProduct onInit : ' + error.message);
            }
        })(window);

    } catch (error) {
        console.log('fnCallCoveoInProduct' + error);
    }
}