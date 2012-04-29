function g(a){throw a;}var k=true,l=null,m=false;function q(a){return function(){return this[a]}}function aa(a){return function(){return a}}var s;window._Messages=[].concat(window._Messages||[],{SEARCHING_FOR_MORE_MATCHES:"Searching for more matches <b>...</b>",SEARCHING_FOR_MATCHES:"Searching for matches <b>...</b>",AND_OTHERS:"And {$count} others..."});function ba(a){return"Showing events after "+a}function ca(a){return"Showing events until "+a}
function da(a,b){var c=isNaN(a)?"??":""+a;if(c.length<2)c="0"+c;return""+c+":"+(!isNaN(b)?(b<10?"0":"")+b:"??")}function ea(a,b){return""+(isNaN(a)?"??":""+(a%12||12))+":"+(!isNaN(b)?(b<10?"0":"")+b:"??")+(a<12?"am":"pm")}function fa(a){return""+(isNaN(a)?"??":""+(a%12||12))+(a<12?"am":"pm")}function ga(a,b){return""+(isNaN(a)?"??":""+(a%12||12))+":"+(!isNaN(b)?(b<10?"0":"")+b:"??")+(a<12?"":"p")}function ha(a){return""+(isNaN(a)?"??":""+(a%12||12))+(a<12?"":"p")};var ia=ia||{},t=this;function ja(a){a=a.split(".");for(var b=t,c;c=a.shift();)if(b[c]!=l)b=b[c];else return l;return b}function v(){}
function ka(a){var b=typeof a;if(b=="object")if(a){if(a instanceof Array)return"array";else if(a instanceof Object)return b;var c=Object.prototype.toString.call(a);if(c=="[object Window]")return"object";if(c=="[object Array]"||typeof a.length=="number"&&typeof a.splice!="undefined"&&typeof a.propertyIsEnumerable!="undefined"&&!a.propertyIsEnumerable("splice"))return"array";if(c=="[object Function]"||typeof a.call!="undefined"&&typeof a.propertyIsEnumerable!="undefined"&&!a.propertyIsEnumerable("call"))return"function"}else return"null";
else if(b=="function"&&typeof a.call=="undefined")return"object";return b}function la(a){return ka(a)=="array"}function ma(a){var b=ka(a);return b=="array"||b=="object"&&typeof a.length=="number"}function w(a){return typeof a=="string"}function na(a){return ka(a)=="function"}function oa(a){a=ka(a);return a=="object"||a=="array"||a=="function"}function y(a){return a[pa]||(a[pa]=++qa)}var pa="closure_uid_"+Math.floor(Math.random()*2147483648).toString(36),qa=0;
function ra(a){return a.call.apply(a.bind,arguments)}function sa(a,b){var c=b||t;if(arguments.length>2){var d=Array.prototype.slice.call(arguments,2);return function(){var e=Array.prototype.slice.call(arguments);Array.prototype.unshift.apply(e,d);return a.apply(c,e)}}else return function(){return a.apply(c,arguments)}}function z(){z=Function.prototype.bind&&Function.prototype.bind.toString().indexOf("native code")!=-1?ra:sa;return z.apply(l,arguments)}
function ta(a){var b=Array.prototype.slice.call(arguments,1);return function(){var c=Array.prototype.slice.call(arguments);c.unshift.apply(c,b);return a.apply(this,c)}}var B=Date.now||function(){return+new Date};function ua(a,b){var c=a.split("."),d=t;!(c[0]in d)&&d.execScript&&d.execScript("var "+c[0]);for(var e;c.length&&(e=c.shift());)if(!c.length&&b!==undefined)d[e]=b;else d=d[e]?d[e]:d[e]={}}
function C(a,b){function c(){}c.prototype=b.prototype;a.n=b.prototype;a.prototype=new c;a.prototype.constructor=a}Function.prototype.bind=Function.prototype.bind||function(a){if(arguments.length>1){var b=Array.prototype.slice.call(arguments,1);b.unshift(this,a);return z.apply(l,b)}else return z(this,a)};var _dbmode=m;function va(a,b){var c=String(a).toLowerCase(),d=String(b).toLowerCase();return c<d?-1:c==d?0:1}var wa=/^[a-zA-Z0-9\-_.!~*'()]*$/;function xa(a){a=String(a);if(!wa.test(a))return encodeURIComponent(a);return a}function D(a){if(!ya.test(a))return a;if(a.indexOf("&")!=-1)a=a.replace(za,"&amp;");if(a.indexOf("<")!=-1)a=a.replace(Aa,"&lt;");if(a.indexOf(">")!=-1)a=a.replace(Ba,"&gt;");if(a.indexOf('"')!=-1)a=a.replace(Ca,"&quot;");return a}var za=/&/g,Aa=/</g,Ba=/>/g,Ca=/\"/g,ya=/[&<>\"]/;
function Da(a){return a.replace(/&([^;]+);/g,function(b,c){switch(c){case "amp":return"&";case "lt":return"<";case "gt":return">";case "quot":return'"';default:if(c.charAt(0)=="#"){var d=Number("0"+c.substr(1));if(!isNaN(d))return String.fromCharCode(d)}return b}})}function Ea(){return Array.prototype.join.call(arguments,"")}
function Fa(a,b){for(var c=0,d=String(a).replace(/^[\s\xa0]+|[\s\xa0]+$/g,"").split("."),e=String(b).replace(/^[\s\xa0]+|[\s\xa0]+$/g,"").split("."),f=Math.max(d.length,e.length),h=0;c==0&&h<f;h++){var i=d[h]||"",j=e[h]||"",n=RegExp("(\\d*)(\\D*)","g"),p=RegExp("(\\d*)(\\D*)","g");do{var o=n.exec(i)||["","",""],r=p.exec(j)||["","",""];if(o[0].length==0&&r[0].length==0)break;c=Ga(o[1].length==0?0:parseInt(o[1],10),r[1].length==0?0:parseInt(r[1],10))||Ga(o[2].length==0,r[2].length==0)||Ga(o[2],r[2])}while(c==
0)}return c}function Ga(a,b){if(a<b)return-1;else if(a>b)return 1;return 0};var E=Array.prototype,Ia=E.indexOf?function(a,b,c){return E.indexOf.call(a,b,c)}:function(a,b,c){c=c==l?0:c<0?Math.max(0,a.length+c):c;if(w(a)){if(!w(b)||b.length!=1)return-1;return a.indexOf(b,c)}for(;c<a.length;c++)if(c in a&&a[c]===b)return c;return-1},Ja=E.forEach?function(a,b,c){E.forEach.call(a,b,c)}:function(a,b,c){for(var d=a.length,e=w(a)?a.split(""):a,f=0;f<d;f++)f in e&&b.call(c,e[f],f,a)},Ka=E.filter?function(a,b,c){return E.filter.call(a,b,c)}:function(a,b,c){for(var d=a.length,e=[],
f=0,h=w(a)?a.split(""):a,i=0;i<d;i++)if(i in h){var j=h[i];if(b.call(c,j,i,a))e[f++]=j}return e};function La(a,b){for(var c=a.length,d=w(a)?a.split(""):a,e=0;e<c;e++)if(e in d&&b.call(void 0,d[e],e,a))return e;return-1}function Ma(a){if(!la(a))for(var b=a.length-1;b>=0;b--)delete a[b];a.length=0}function Na(a,b){var c=Ia(a,b);c>=0&&E.splice.call(a,c,1)}function Oa(){return E.concat.apply(E,arguments)}
function Pa(a){if(la(a))return Oa(a);else{for(var b=[],c=0,d=a.length;c<d;c++)b[c]=a[c];return b}}function Qa(a){for(var b=1;b<arguments.length;b++){var c=arguments[b],d;if(la(c)||(d=ma(c))&&c.hasOwnProperty("callee"))a.push.apply(a,c);else if(d)for(var e=a.length,f=c.length,h=0;h<f;h++)a[e+h]=c[h];else a.push(c)}}function Ra(a){E.splice.apply(a,Sa(arguments,1))}function Sa(a,b,c){return arguments.length<=2?E.slice.call(a,b):E.slice.call(a,b,c)}
function Ta(a,b,c){for(var d=0,e=a.length,f;d<e;){var h=d+e>>1,i;i=b(c,a[h]);if(i>0)d=h+1;else{e=h;f=!i}}return f?d:~d}function Ua(a,b){return a>b?1:a<b?-1:0};function F(){}F.prototype.Vd=m;F.prototype.D=function(){if(!this.Vd){this.Vd=k;this.m()}};F.prototype.m=function(){};function Va(a){a&&typeof a.D=="function"&&a.D()};function Wa(a,b){for(var c in a)b.call(void 0,a[c],c,a)}function Xa(a){var b=[],c=0,d;for(d in a)b[c++]=a[d];return b}function G(a){var b=[],c=0,d;for(d in a)b[c++]=d;return b}function Ya(a){for(var b in a)return m;return k}function Za(a){var b={},c;for(c in a)b[c]=a[c];return b}var $a=["constructor","hasOwnProperty","isPrototypeOf","propertyIsEnumerable","toLocaleString","toString","valueOf"];
function ab(a){for(var b,c,d=1;d<arguments.length;d++){c=arguments[d];for(b in c)a[b]=c[b];for(var e=0;e<$a.length;e++){b=$a[e];if(Object.prototype.hasOwnProperty.call(c,b))a[b]=c[b]}}};var bb,cb,db,eb,fb,gb;function hb(){return t.navigator?t.navigator.userAgent:l}function ib(){return t.navigator}fb=eb=db=cb=bb=m;var jb;if(jb=hb()){var kb=ib();bb=jb.indexOf("Opera")==0;cb=!bb&&jb.indexOf("MSIE")!=-1;eb=(db=!bb&&jb.indexOf("WebKit")!=-1)&&jb.indexOf("Mobile")!=-1;fb=!bb&&!db&&kb.product=="Gecko"}var lb=bb,H=cb,mb=fb,I=db,nb=eb,ob=ib();gb=(ob&&ob.platform||"").indexOf("Mac")!=-1;var pb=!!ib()&&(ib().appVersion||"").indexOf("X11")!=-1,qb;
a:{var rb="",sb;if(lb&&t.opera){var tb=t.opera.version;rb=typeof tb=="function"?tb():tb}else{if(mb)sb=/rv\:([^\);]+)(\)|;)/;else if(H)sb=/MSIE\s+([^\);]+)(\)|;)/;else if(I)sb=/WebKit\/(\S+)/;if(sb){var ub=sb.exec(hb());rb=ub?ub[1]:""}}if(H){var vb,wb=t.document;vb=wb?wb.documentMode:undefined;if(vb>parseFloat(rb)){qb=String(vb);break a}}qb=rb}var xb=qb,yb={};function J(a){return yb[a]||(yb[a]=Fa(xb,a)>=0)};var zb=new Function("a","return a");var Ab;!H||J("9");var Bb=H&&!J("8");function K(a,b){this.type=a;this.a=this.target=b}C(K,F);s=K.prototype;s.m=function(){delete this.type;delete this.target;delete this.a};s.Fa=m;s.ob=k;s.ic=function(){this.Fa=k};s.Aa=function(){this.ob=m};function Cb(a,b){a&&this.init(a,b)}C(Cb,K);s=Cb.prototype;s.target=l;s.pd=l;s.Qe=0;s.Re=0;s.clientX=0;s.clientY=0;s.Se=0;s.Te=0;s.Me=0;s.keyCode=0;s.Ne=0;s.Oe=m;s.Le=m;s.Ue=m;s.Pe=m;s.xf=m;s.$=l;
s.init=function(a,b){var c=this.type=a.type;K.call(this,c);this.target=a.target||a.srcElement;this.a=b;var d=a.relatedTarget;if(d){if(mb)try{zb(d.nodeName)}catch(e){d=l}}else if(c=="mouseover")d=a.fromElement;else if(c=="mouseout")d=a.toElement;this.pd=d;this.Qe=a.offsetX!==undefined?a.offsetX:a.layerX;this.Re=a.offsetY!==undefined?a.offsetY:a.layerY;this.clientX=a.clientX!==undefined?a.clientX:a.pageX;this.clientY=a.clientY!==undefined?a.clientY:a.pageY;this.Se=a.screenX||0;this.Te=a.screenY||0;
this.Me=a.button;this.keyCode=a.keyCode||0;this.Ne=a.charCode||(c=="keypress"?a.keyCode:0);this.Oe=a.ctrlKey;this.Le=a.altKey;this.Ue=a.shiftKey;this.Pe=a.metaKey;this.xf=gb?a.metaKey:a.ctrlKey;this.c=a.state;this.$=a;delete this.ob;delete this.Fa};s.ic=function(){Cb.n.ic.call(this);if(this.$.stopPropagation)this.$.stopPropagation();else this.$.cancelBubble=k};
s.Aa=function(){Cb.n.Aa.call(this);var a=this.$;if(a.preventDefault)a.preventDefault();else{a.returnValue=m;if(Bb)try{if(a.ctrlKey||a.keyCode>=112&&a.keyCode<=123)a.keyCode=-1}catch(b){}}};s.Ie=q("$");s.m=function(){Cb.n.m.call(this);this.pd=this.a=this.target=this.$=l};function Db(a,b){this.d=b;this.b=[];a>this.d&&g(Error("[goog.structs.SimplePool] Initial cannot be greater than max"));for(var c=0;c<a;c++)this.b.push(this.a?this.a():{})}C(Db,F);Db.prototype.a=l;Db.prototype.c=l;function Eb(a){if(a.b.length)return a.b.pop();return a.a?a.a():{}}function Fb(a,b){a.b.length<a.d?a.b.push(b):Gb(a,b)}function Gb(a,b){if(a.c)a.c(b);else if(oa(b))if(na(b.D))b.D();else for(var c in b)delete b[c]}
Db.prototype.m=function(){Db.n.m.call(this);for(var a=this.b;a.length;)Gb(this,a.pop());delete this.b};var Hb;var Ib=(Hb="ScriptEngine"in t&&t.ScriptEngine()=="JScript")?t.ScriptEngineMajorVersion()+"."+t.ScriptEngineMinorVersion()+"."+t.ScriptEngineBuildVersion():"0";function Jb(){}var Kb=0;s=Jb.prototype;s.key=0;s.Za=m;s.Sb=m;s.init=function(a,b,c,d,e,f){if(na(a))this.a=k;else if(a&&a.handleEvent&&na(a.handleEvent))this.a=m;else g(Error("Invalid listener argument"));this.kb=a;this.b=b;this.src=c;this.type=d;this.capture=!!e;this.kc=f;this.Sb=m;this.key=++Kb;this.Za=m};s.handleEvent=function(a){if(this.a)return this.kb.call(this.kc||this.src,a);return this.kb.handleEvent.call(this.kb,a)};var Lb,Mb,Nb,Ob,Pb,Qb,Rb,Sb,Tb,Ub,Vb;
(function(){function a(){return{I:0,X:0}}function b(){return[]}function c(){function r(u){return h.call(r.src,r.key,u)}return r}function d(){return new Jb}function e(){return new Cb}var f=Hb&&!(Fa(Ib,"5.7")>=0),h;Qb=function(r){h=r};if(f){Lb=function(){return Eb(i)};Mb=function(r){Fb(i,r)};Nb=function(){return Eb(j)};Ob=function(r){Fb(j,r)};Pb=function(){return Eb(n)};Rb=function(){Fb(n,c())};Sb=function(){return Eb(p)};Tb=function(r){Fb(p,r)};Ub=function(){return Eb(o)};Vb=function(r){Fb(o,r)};var i=
new Db(0,600);i.a=a;var j=new Db(0,600);j.a=b;var n=new Db(0,600);n.a=c;var p=new Db(0,600);p.a=d;var o=new Db(0,600);o.a=e}else{Lb=a;Mb=v;Nb=b;Ob=v;Pb=c;Rb=v;Sb=d;Tb=v;Ub=e;Vb=v}})();var Wb={},L={},Xb={},Yb={};
function M(a,b,c,d,e){if(b)if(la(b)){for(var f=0;f<b.length;f++)M(a,b[f],c,d,e);return l}else{d=!!d;var h=L;b in h||(h[b]=Lb());h=h[b];if(!(d in h)){h[d]=Lb();h.I++}h=h[d];var i=y(a),j;h.X++;if(h[i]){j=h[i];for(f=0;f<j.length;f++){h=j[f];if(h.kb==c&&h.kc==e){if(h.Za)break;return j[f].key}}}else{j=h[i]=Nb();h.I++}f=Pb();f.src=a;h=Sb();h.init(c,f,a,b,d,e);c=h.key;f.key=c;j.push(h);Wb[c]=h;Xb[i]||(Xb[i]=Nb());Xb[i].push(h);if(a.addEventListener){if(a==t||!a.Qc)a.addEventListener(b,f,d)}else a.attachEvent(Zb(b),
f);return c}else g(Error("Invalid event type"))}function $b(a,b,c,d,e){if(la(b))for(var f=0;f<b.length;f++)$b(a,b[f],c,d,e);else{a=M(a,b,c,d,e);Wb[a].Sb=k}}function ac(a,b,c,d,e){if(la(b))for(var f=0;f<b.length;f++)ac(a,b[f],c,d,e);else{d=!!d;a:{f=L;if(b in f){f=f[b];if(d in f){f=f[d];a=y(a);if(f[a]){a=f[a];break a}}}a=l}if(a)for(f=0;f<a.length;f++)if(a[f].kb==c&&a[f].capture==d&&a[f].kc==e){bc(a[f].key);break}}}
function bc(a){if(Wb[a]){var b=Wb[a];if(!b.Za){var c=b.src,d=b.type,e=b.b,f=b.capture;if(c.removeEventListener){if(c==t||!c.Qc)c.removeEventListener(d,e,f)}else c.detachEvent&&c.detachEvent(Zb(d),e);c=y(c);e=L[d][f][c];if(Xb[c]){var h=Xb[c];Na(h,b);h.length==0&&delete Xb[c]}b.Za=k;e.yd=k;cc(d,f,c,e);delete Wb[a]}}}
function cc(a,b,c,d){if(!d.W)if(d.yd){for(var e=0,f=0;e<d.length;e++)if(d[e].Za){var h=d[e].b;h.src=l;Rb(h);Tb(d[e])}else{if(e!=f)d[f]=d[e];f++}d.length=f;d.yd=m;if(f==0){Ob(d);delete L[a][b][c];L[a][b].I--;if(L[a][b].I==0){Mb(L[a][b]);delete L[a][b];L[a].I--}if(L[a].I==0){Mb(L[a]);delete L[a]}}}}
function dc(a){var b,c=0,d=b==l;b=!!b;if(a==l)Wa(Xb,function(h){for(var i=h.length-1;i>=0;i--){var j=h[i];if(d||b==j.capture){bc(j.key);c++}}});else{a=y(a);if(Xb[a]){a=Xb[a];for(var e=a.length-1;e>=0;e--){var f=a[e];if(d||b==f.capture){bc(f.key);c++}}}}}function Zb(a){if(a in Yb)return Yb[a];return Yb[a]="on"+a}
function ec(a,b,c,d,e){var f=1;b=y(b);if(a[b]){a.X--;a=a[b];if(a.W)a.W++;else a.W=1;try{for(var h=a.length,i=0;i<h;i++){var j=a[i];if(j&&!j.Za)f&=fc(j,e)!==m}}finally{a.W--;cc(c,d,b,a)}}return Boolean(f)}function fc(a,b){var c=a.handleEvent(b);a.Sb&&bc(a.key);return c}
Qb(function(a,b){if(!Wb[a])return k;var c=Wb[a],d=c.type,e=L;if(!(d in e))return k;e=e[d];var f,h;if(Ab===undefined)Ab=H&&!t.addEventListener;if(Ab){f=b||ja("window.event");var i=k in e,j=m in e;if(i){if(f.keyCode<0||f.returnValue!=undefined)return k;a:{var n=m;if(f.keyCode==0)try{f.keyCode=-1;break a}catch(p){n=k}if(n||f.returnValue==undefined)f.returnValue=k}}n=Ub();n.init(f,this);f=k;try{if(i){for(var o=Nb(),r=n.a;r;r=r.parentNode)o.push(r);h=e[k];h.X=h.I;for(var u=o.length-1;!n.Fa&&u>=0&&h.X;u--){n.a=
o[u];f&=ec(h,o[u],d,k,n)}if(j){h=e[m];h.X=h.I;for(u=0;!n.Fa&&u<o.length&&h.X;u++){n.a=o[u];f&=ec(h,o[u],d,m,n)}}}else f=fc(c,n)}finally{if(o){o.length=0;Ob(o)}n.D();Vb(n)}return f}d=new Cb(b,this);try{f=fc(c,d)}finally{d.D()}return f});function N(){}C(N,F);s=N.prototype;s.Qc=k;s.Db=l;s.ab=function(a){this.Db=a};s.addEventListener=function(a,b,c,d){M(this,a,b,c,d)};s.removeEventListener=function(a,b,c,d){ac(this,a,b,c,d)};
s.dispatchEvent=function(a){var b=a.type||a,c=L;if(b in c){if(w(a))a=new K(a,this);else if(a instanceof K)a.target=a.target||this;else{var d=a;a=new K(b,this);ab(a,d)}d=1;var e;c=c[b];b=k in c;var f;if(b){e=[];for(f=this;f;f=f.Db)e.push(f);f=c[k];f.X=f.I;for(var h=e.length-1;!a.Fa&&h>=0&&f.X;h--){a.a=e[h];d&=ec(f,e[h],a.type,k,a)&&a.ob!=m}}if(m in c){f=c[m];f.X=f.I;if(b)for(h=0;!a.Fa&&h<e.length&&f.X;h++){a.a=e[h];d&=ec(f,e[h],a.type,m,a)&&a.ob!=m}else for(e=this;!a.Fa&&e&&f.X;e=e.Db){a.a=e;d&=ec(f,
e,a.type,m,a)&&a.ob!=m}}a=Boolean(d)}else a=k;return a};s.m=function(){N.n.m.call(this);dc(this);this.Db=l};var gc=0;function hc(a){this.c=(gc++).toString(36);this.d=new N;a=a||[];for(var b={},c=0;c<a.length;c++){var d=a[c];b[d.V()]=d;d.ab&&d.ab(this.d)}this.p=b;this.u=a.length;this.a=Za(b);this.e=a.length;M(this.d,"change",z(this.Xe,this))}C(hc,N);s=hc.prototype;s.Ua=l;s.zb=m;s.W=0;s.m=function(){hc.n.m.call(this);for(var a in this.a)Va(this.a[a]);this.d.D()};s.oa=function(){return this.e==0};s.fb=function(a){return this.a[a]};s.contains=function(a){return a in this.a};
s.vb=function(a){var b=a.V();if(b in this.a)return m;this.a[b]=a;this.e++;a.ab&&a.ab(this.d);this.W&&a.ja&&a.ja();ic(this,"added",a);jc(this);return k};s.xa=function(){return G(this.a)};s.ja=function(){this.W++;if(this.W==1)for(var a in this.a){var b=this.a[a];b.ja&&b.ja()}};s.Ma=function(){if(this.W==1)for(var a in this.a){var b=this.a[a];b.Ma&&b.Ma()}this.W--;jc(this)};function ic(a,b,c){var d=a.Ua||{};b in d||(d[b]=[]);d[b].push(c);a.Ua=d}s.Xe=function(a){ic(this,"change",a.target);this.zb=k;jc(this)};
s.A=function(a){return a===this};s.V=q("c");function jc(a){if(!a.W)if(a.Ua||a.zb){a.ja();var b=a.zb;a.zb=m;if(a.Ua){b=new kc(a.Ua);a.Ua=l;a.dispatchEvent(b);b=k}b&&a.dispatchEvent("change");a.Ma()}}function kc(a){K.call(this,"gcal-kds");this.c=a}C(kc,K);function lc(a){return a<10?"0"+a:String(a)}var mc=[,31,,31,30,31,30,31,31,30,31,30,31];function nc(a,b){return mc[b]||mc[a]||(mc[a]=28+((a&3?0:a%100||!(a%400))?1:0))}var oc={};function pc(a,b){var c=a<<4|b;return oc[c]||(oc[c]=(new Date(a,b-1,1,0,0,0,0)).getDay())}var qc=[,0,31,59,90,120,151,181,212,243,273,304,334];function rc(a,b,c){a=b<=2||29-nc(a,2);return qc[b]+c-a};var sc=1/131072;function tc(a){if((a&31)<28)return a+1;var b=a>>5&15;if((a&31)<(mc[b]||nc((a>>9)+1970,2)))return a+1;else{var c=(a>>9)+1970;if(++b>12){b=1;++c}return((c-1970<<4)+b<<5)+1+a%1}}function uc(a,b){var c=a;a%1||(a+=sc);(b-sc)%1||(b-=sc);return function(d,e){return d<b&&(e>a||d>=c)}};function vc(){}s=vc.prototype;s.k=NaN;s.i=NaN;s.h=NaN;s.q=NaN;s.s=NaN;s.v=NaN;s.toString=function(){return this.d||(this.d=this.b())};s.H=function(){return this.f()|0};s.min=function(a){return this.f()<a.f()?this:a};s.max=function(a){return this.f()>a.f()?this:a};
function wc(a,b){var c=xc(a);if(!isNaN(a.k)){c.k=NaN;c.i=NaN;c.h=a.k==b.k?rc(a.k,a.i,a.h)-rc(b.k,b.i,b.h):Math.round((Date.UTC(a.k,a.i-1,a.h)-Date.UTC(b.k,b.i-1,b.h))/864E5)}if(!isNaN(a.q)){c.q-=b.q;c.s-=b.s;c.v-=b.v}return new yc(c.h,c.q,c.s,c.v)}function zc(a){var b=a.k,c=a.i;a=a.h;if(++a>28&&a>nc(b,c)){a=1;if(++c===13){c=1;++b}}return Ac(b,c,a)}function Bc(a,b){return Cc(a.k,a.i,a.h+b).t()}s.wa=function(){return(pc(this.k,this.i)+this.h-1)%7};
s.t=function(){return Ac(this.k||0,this.i||1,this.h||1)};s.ha=function(){return new Q(this.k||0,this.i||1,this.h||1,this.q||0,this.s||0,this.v||0)};function Dc(){}C(Dc,vc);function Q(a,b,c,d,e,f){this.k=a;this.i=b;this.h=c;this.q=d;this.s=e;this.v=f}C(Q,Dc);Q.prototype.ha=function(){return this};Q.prototype.f=function(){return this.a||(this.a=((this.k-1970<<4)+this.i<<5)+this.h+(((this.q<<6)+this.s<<6)+this.v+1)*sc)};Q.prototype.b=function(){return Ea(String(this.k),lc(this.i),lc(this.h),"T",lc(this.q),lc(this.s),lc(this.v))};Q.prototype.A=function(a){return!!a&&this.constructor===a.constructor&&this.f()==a.f()};
function Ec(a){return new Q(a.getUTCFullYear(),a.getUTCMonth()+1,a.getUTCDate(),a.getUTCHours(),a.getUTCMinutes(),a.getUTCSeconds())}function Fc(a){return new Q(a.getFullYear(),a.getMonth()+1,a.getDate(),a.getHours(),a.getMinutes(),a.getSeconds())};function Gc(){}C(Gc,Dc);function Hc(a,b,c,d){var e=new Gc;e.k=a;e.i=b;e.h=c;e.a=d;return Ic[d]=e}Gc.prototype.t=function(){return this};Gc.prototype.f=q("a");Gc.prototype.b=function(){return Ea(String(this.k),lc(this.i),lc(this.h))};Gc.prototype.A=function(a){return this===a};var Ic={};function Ac(a,b,c){var d=((a-1970<<4)+b<<5)+c;return Ic[d]||Hc(a,b,c,d)}function Jc(a){return Ic[a]||Hc((a>>9)+1970,a>>5&15,a&31,a)}function Kc(a){return Ac(a.getUTCFullYear(),a.getUTCMonth()+1,a.getUTCDate())};function yc(a,b,c,d){this.c=a=((a*24+b)*60+c)*60+d;this.v=a%60;a=a/60|0;this.s=a%60;a=a/60|0;this.q=a%24;this.h=a/24|0}C(yc,vc);function Lc(a){return a.c}yc.prototype.f=function(){return this.a||(this.a=this.h+(((this.q<<6)+this.s<<6)+this.v+1)*sc)};
yc.prototype.b=function(){var a=this.q||this.s||this.v||0,b=this.h||a;b=b<0?-1:b>0?1:0;var c=b<0?"-P":"P";if(this.h)c+=this.h%7?b*this.h+"D":b*this.h/7+"W";if(a){c+="T";if(this.q)c+=b*this.q+"H";if(this.s)c+=b*this.s+"M";if(this.v)c+=b*this.v+"S"}else b||(c+="0D");return c};yc.prototype.A=function(a){return!!a&&this.constructor===a.constructor&&this.f()==a.f()};function Mc(){}C(Mc,vc);s=Mc.prototype;s.k=0;s.i=0;s.h=0;s.q=0;s.s=0;s.v=0;s.f=function(){var a=this.H();isNaN(this.q)||(a+=(((this.q<<6)+this.s<<6)+this.v+1)*sc);return a};s.H=function(){Nc(this);return((this.k-1970<<4)+this.i<<5)+this.h};function Nc(a){if(a.q||a.s||a.v){var b=(a.q*60+a.s)*60+a.v,c=Math.floor(b/86400);b-=c*86400;a.h+=c;a.v=b%60;b/=60;a.s=(b|0)%60;b/=60;a.q=(b|0)%24}Oc(a);for(b=nc(a.k,a.i);a.h<1;){a.i-=1;Oc(a);b=nc(a.k,a.i);a.h+=b}for(;a.h>b;){a.h-=b;a.i+=1;Oc(a);b=nc(a.k,a.i)}}
function Oc(a){var b;if(a.i<1||a.i>12){b=Math.floor((a.i-1)/12);a.i-=12*b;a.k+=b}}s.t=function(){Nc(this);return Ac(this.k,this.i,this.h)};s.ha=function(){Nc(this);return new Q(this.k,this.i,this.h,this.q,this.s,this.v)};s.Fc=function(){Nc(this);return vc.prototype.Fc.call(this)};s.wa=function(){Nc(this);return(pc(this.k,this.i)+this.h-1)%7};s.A=function(a){return!!a&&this.constructor==a.constructor&&this.f()==a.f()};function xc(a){return Pc(a.k||0,a.i||0,a.h||0,a.q||0,a.s||0,a.v||0)}
function Qc(a){return Pc(a.k,a.i,a.h,a.q,a.s,a.v)}function Pc(a,b,c,d,e,f){var h=new Mc;h.k=a;h.i=b;h.h=c;h.q=d;h.s=e;h.v=f;return h}function Cc(a,b,c){var d=new Mc;d.k=a;d.i=b;d.h=c;return d};function R(a,b){this.start=a;if(b.constructor===yc){var c=xc(a);c.h+=b.h;c.q+=b.q;c.s+=b.s;c.v+=b.v;this.end=this.start instanceof Q?c.ha():c.t();this.a=b}else{this.end=b;this.a=wc(this.end,this.start)}}R.prototype.toString=function(){return this.start+"/"+this.end};R.prototype.A=function(a){return!!a&&this.constructor===a.constructor&&this.start.A(a.start)&&this.end.A(a.end)};R.prototype.contains=function(a){a=a.f();return a>=this.start.f()&&a<this.end.f()};function Rc(a,b){return a.charCodeAt(b)*10+a.charCodeAt(b+1)-528}function Sc(a){var b=parseInt(a,10),c=b%100;b/=100;var d=(b|0)%100;b=b/100|0;return a.length==8?Ac(b,d,c):new Q(b,d,c,Rc(a,9),Rc(a,11),Rc(a,13))}
function Tc(a,b){var c=parseInt(a,10),d=Rc(a,5),e=Rc(a,8),f=a.length;if(a.charCodeAt(10)==84){var h=Rc(a,11),i=Rc(a,14),j=Rc(a,17);if(b){c=Date.UTC(c,d-1,e,h,i,j);d=0;if(a.charCodeAt(f-1)!=90){d=Rc(a,f-5)*60+Rc(a,f-2);d*=44-a.charCodeAt(f-6)}f=(b?Fc:Ec)(new Date(c-d*6E4))}else f=new Q(c,d,e,h,i,j)}else f=Ac(c,d,e);return f};var Uc;function Vc(a){return(a=a.className)&&typeof a.split=="function"?a.split(/\s+/):[]}function Wc(a){var b=Vc(a),c;c=Sa(arguments,1);for(var d=0,e=0;e<c.length;e++)if(!(Ia(b,c[e])>=0)){b.push(c[e]);d++}c=d==c.length;a.className=b.join(" ");return c}function Xc(a){for(var b=Vc(a),c=Sa(arguments,1),d=0,e=0;e<b.length;e++)if(Ia(c,b[e])>=0){Ra(b,e--,1);d++}a.className=b.join(" ")}
function Yc(a,b,c){for(var d=Vc(a),e=m,f=0;f<d.length;f++)if(d[f]==b){Ra(d,f--,1);e=k}if(e){d.push(c);a.className=d.join(" ")}};function Zc(a,b,c,d,e){this.a=a;this.e=b;this.g=b.wa();this.c=c;this.b=d;this.d=e||7;this.p=this.c*this.b}function $c(a){var b;if(!(b=a.j)){b=a.e.H();for(var c=a.b,d=a.d,e=[],f=0,h=0;h<a.c;h++){for(var i=0;i<c;i++){e[f++]=b;b=tc(b)}for(;i<d;i++)b=tc(b)}b=a.j=e}return b}Zc.prototype.A=function(a){return this.a.A(a.a)&&this.e.A(a.e)&&this.c==a.c&&this.b==a.b&&this.d==a.d};function ad(){}function bd(a){this.b=a}C(bd,ad);
bd.prototype.a=function(a){var b=this.b,c=xc(a);c.h=nc(a.k,a.i);b=(c.t().wa()-b+7)%7;c.h-=b+35;return new Zc(a,c.t(),7,7)};function cd(a){this.b=a}C(cd,ad);cd.prototype.a=function(a){var b=this.b,c=xc(a);c.h=0;b=(c.t().wa()-b+7)%7;c.h-=b;return new Zc(a,c.t(),6,7)};function dd(a,b,c,d,e,f,h,i,j){this.F=d;this.d=a;this.id=e||this.d.id+"_";this.className=f||"dp-";this.K=c;this.da=b;this.g={};a=h!==undefined?h:1;i=(1<<a+7)-(1<<a+(i||5));this.P=i+(i>>7);this.Y=!!j;ed[this.id]=this}C(dd,F);var ed={};s=dd.prototype;s.cb=m;s.Dc=l;s.Od=l;s.vd=0;
function fd(a,b){var c=a.id,d=a.className+"cell "+a.className,e=a.a;if(!a.c){a.u=[];for(var f=7;f--;)a.u[f]=gd[f];f=a.className;for(var h=[],i=48;i--;){var j=["cell"];if(i&2){j.push(i&1?"weekend-selected":"weekday-selected");i&8&&j.push("today-selected");j.push(i&4?"onmonth-selected":"offmonth-selected")}else{j.push(i&1?"weekend":"weekday");i&8&&j.push("today");j.push(i&4?"onmonth":"offmonth")}i&16&&j.push("day-left");i&32&&j.push("day-right");h[i]=f+j.join(" "+f)+" "}a.p=h;a.e=[];a.c=a.id+"day_";
a.j=a.id+"cur"}b.push('<table cellspacing=0 cellpadding=0 id="',c,'tbl" class="',a.className,'monthtable" style="-moz-user-select:none;-webkit-user-select:none;"><colgroup span=7>');a.Y?b.push('<tr id="',c,'header"><td colspan=',e.b-2,' id="',a.j,'" class="',d,'sb-cur">',""+hd[a.a.a.i]+" "+a.a.a.k,'</td><td colspan=2 class="',d,'sb-nav"><span id="',c,'prev" class="',d,'sb-prev goog-inline-block"></span><span id="',c,'next" class="',d,'sb-next goog-inline-block"></span></td></tr>'):b.push('<tr class="',
d,'heading"  id="',c,'header"><td id="',c,'prev" class="',d,'prev">&laquo;</td><td colspan=',e.b-2,' id="',a.j,'" class="',d,'cur">',""+hd[a.a.a.i]+" "+a.a.a.k,'</td><td id="',c,'next" class="',d,'next">&raquo;</td></tr>');b.push('<tr class="',a.className,'days">');c=a.a.g;f=a.P;for(h=0;h<e.b;h++){b.push('<td class="',d,"dayh");f>>c&1&&b.push(" ",d,"weekendh");b.push('">',a.u[c],"</td>");c=(c+1)%7}b.push("</tr>");d=a.a;e=d.b;c=a.id;f=a.P;h=a.p;i=$c(d);var n=a.Dc;j=n?a.Dc.H():1;var p=n?a.Od.H():0;
n=n?"pointer":"default";var o=a.b.H(),r=a.a.a.i,u=0;if(a.B)a.g=a.B(d);for(var O=0;O<a.a.c;O++){b.push('<tr style="cursor:',n,'" id="',c,"row_",O,'">');for(var P=d.g,A=e;A--;u++){var W=i[u],Ha=(W==o&&8)|((W>>5&15)==r&&4)|(W>=j&&W<=p&&2)|(A==e-1&&16)|(A==0&&32)|f>>P&1;P=(P+1)%7;a.e[u]=Ha;b.push('<td id="',a.c,W,'" class="',h[Ha],a.g[W],'">',W&31,"</td>")}b.push("</tr>")}b.push("</table>")}
function id(a){if(a.cb){var b=[];fd(a,b);a.d.innerHTML=b.join("");a.Z=m;var c=a.id;a=a.F;a(c+"prev").onmousedown=function(){ed[c].navigate(-1)};a(c+"next").onmousedown=function(){ed[c].navigate(1)}}}function jd(a,b){var c=b.id;if(c&&c.indexOf(a.c)==0)return Jc(parseInt(c.substr(a.c.length),10));return l}function kd(a,b){return a.F(a.c+b)}s.J=q("d");s.navigate=function(a){ld(this,Cc(this.a.a.k,this.a.a.i+a,1).t())};function ld(a,b){var c=a.a.a;if(b.k!=c.k||b.i!=c.i){a.a=a.K.a(b);a.update()}}
s.update=function(){if(this.vd)this.Z=k;else this.cb&&id(this)};s.z=q("id");function md(a,b,c,d){a.Dc=b;a.Od=c;d&&ld(a,d);if(a.vd||!a.cb)a.update();else{d=$c(a.a);b=b.H();c=c.H();for(var e=a.a.p;e--;){var f=a.e[e],h=d[e],i=h>=b&&h<=c?f|2:f&-3;if(i!=f){kd(a,$c(a.a)[e]).className=a.p[i]+(a.g[h]||"");a.e[e]=i}}}}s.m=function(){delete this.d;delete ed[this.id];dd.n.m.call(this)};function nd(){}C(nd,N);s=nd.prototype;s.uc=l;s.Ad=l;s.Xc=l;s.pb=function(a,b,c){this.R(c)};s.R=function(a){this.pb(a,a,a)};s.navigate=function(a){this.R(Bc(a>0?this.c:this.b,a))};s.contains=function(a){a=a.t();return a.f()>=this.b.f()&&a.f()<=this.c.f()};function od(a){if(!a.uc||!a.a.A(a.Xc)||!a.b.A(a.uc)||!a.c.A(a.Ad)){a.Xc=a.a;a.uc=a.b;a.Ad=a.c;a.dispatchEvent("change")}}function pd(){}C(pd,nd);pd.prototype.pb=function(a,b,c){this.d.pb(a,b,c)};pd.prototype.R=function(a){this.d.R(a)};
pd.prototype.navigate=function(a){this.d.navigate(a)};function qd(a,b){a.d&&bc(a.g);a.d=b;a.g=M(b,"change",a.e,m,a);a.e()}pd.prototype.e=function(){var a=this.d,b=a.c,c=a.a;this.b=a.b;this.c=b;this.a=c;od(this)};function rd(){}C(rd,N);function sd(a,b,c){this.a=a;this.d=b||Infinity;this.c=c;this.e=this.hb(B()+td);this.b=this.Oa();this.Kd()}C(sd,rd);var td=0;s=sd.prototype;s.hb=function(a){var b=this.a;if(b===undefined)b=(new Date(a)).getTimezoneOffset()*-6E4;else if(a>=this.d)b=this.c;return b};s.tc=function(){var a=B()+td;return this.hb(a)+a};s.Oa=function(){return new Date(this.tc())};s.gc=q("b");
s.Kd=function(){var a=this.b,b=this.Oa(),c=18E5-b.getTime()%18E5;window.setTimeout(z(this.Kd,this),c);if(a.getUTCDate()!==b.getUTCDate()){this.b=this.Oa();this.dispatchEvent("newday")}};function ud(a){this.b=a}C(ud,F);var vd=new Db(0,100),wd=[];function S(a,b,c,d,e){if(!la(c)){wd[0]=c;c=wd}for(var f=0;f<c.length;f++){var h=a,i=M(b,c[f],d||a,e||m,a.b||a);if(h.a)h.a[i]=k;else if(h.c){h.a=Eb(vd);h.a[h.c]=k;h.c=l;h.a[i]=k}else h.c=i}}function xd(a){if(a.a){for(var b in a.a){bc(b);delete a.a[b]}Fb(vd,a.a);a.a=l}else a.c&&bc(a.c)}ud.prototype.m=function(){ud.n.m.call(this);xd(this)};ud.prototype.handleEvent=function(){g(Error("EventHandler.handleEvent not implemented"))};function yd(a,b,c,d){this.b=c;this.a=a;var e=T(b);a.b=e;if(a.a)a.update();else a.a=a.K.a(e);md(a,this.b.b,this.b.c,this.b.a);this.c=new ud(this);S(this.c,c,"change",this.sd);S(this.c,a.J(),"mousedown",this.Ze);S(this.c,a.J(),"mouseover",this.bf);S(this.c,a.J(),"mouseout",this.af);S(this.c,b,"newday",this.Ge);this.d=new ud(this);this.g=b;this.e=!!d}C(yd,N);s=yd.prototype;s.La=l;s.sb=l;s.Hf=l;
s.$e=function(a){var b=jd(this.a,a.target),c=this.La;if(b&&c)if(!(this.sb||c).A(b)){this.sb=b;this.b.pb(c.min(b),c.max(b),b)}a.Aa()};s.Ze=function(a){var b=a.target,c=jd(this.a,b);if(c){this.La=c;this.e&&this.b.R(c);b=this.a.J().ownerDocument;S(this.d,b,"mousemove",this.$e);S(this.d,b,"mouseup",this.df)}else this.a.j==b.id&&this.dispatchEvent("month-title");a.Aa()};s.Cf=function(){var a=this.La;if(a){xd(this.d);this.La=l;this.sb||(this.e?this.sd():this.b.R(a));this.sb=l;this.dispatchEvent("accept")}};
s.df=yd.prototype.Cf;s.bf=function(a){if((a=jd(this.a,a.target))&&this.La==l){var b=this.a;Wc(kd(b,a.H()),b.className+"onhover")}};s.af=function(a){if(a=jd(this.a,a.target)){var b=this.a;Xc(kd(b,a.H()),b.className+"onhover")}};s.sd=function(){var a=undefined;if(this.La==l)a=this.b.a;md(this.a,this.b.b,this.b.c,a)};s.Ge=function(){var a=this.a,b=T(this.g);a.b=b;a.update()};s.m=function(){Va(this.c);Va(this.Hf);Va(this.d);Va(this.a);yd.n.m.call(this)};function U(a,b){this.c=a;this.d=!!b}var zd=/>(\s+)</g,Ad=/\s{2,}/g,Bd=/\$\{(\w+)\}/g;s=U.prototype;s.$b=m;function Cd(a){if(!a.$b){var b=a.c;delete a.c;a.d||(b=b.replace(zd,"><").replace(Ad," "));var c=[];a.b=c;a.a={};for(var d=b.match(Bd)||[],e=0,f=d.length,h=0;h<f;++h){var i=d[h],j=b.indexOf(i,e);e!=j&&c.push(b.substring(e,j));e=j+i.length;i=i.substring(2,i.length-1);j=a.a[i];if(!j){j=[];a.a[i]=j}j.push(c.length);c.push(undefined)}e!=b.length&&c.push(b.substring(e));a.$b=k}}
s.T=function(){Cd(this);var a=new U("");a.$b=k;a.b=[].concat(this.b);a.a={};for(var b in this.a)a.a[b]=this.a[b];return a};s.put=function(a,b){Cd(this);var c=this.a[a],d=c.length;if(d==1)this.b[c[0]]=b;else for(;d--;)this.b[c[d]]=b};s.toString=function(){Cd(this);return this.b.join("")};s.xa=function(){var a={},b;for(b in this.a)a[b]=l;return a};function V(a,b){this.x=a!==undefined?a:0;this.y=b!==undefined?b:0}V.prototype.T=function(){return new V(this.x,this.y)};function Dd(a,b){return new V(a.x-b.x,a.y-b.y)};function Ed(a,b){this.width=a;this.height=b}Ed.prototype.T=function(){return new Ed(this.width,this.height)};Ed.prototype.oa=function(){return!(this.width*this.height)};Ed.prototype.floor=function(){this.width=Math.floor(this.width);this.height=Math.floor(this.height);return this};Ed.prototype.round=function(){this.width=Math.round(this.width);this.height=Math.round(this.height);return this};var Fd=!H||J("9");H&&J("9");function X(a){return a?new Gd(Hd(a)):Uc||(Uc=new Gd)}function Y(a){return w(a)?document.getElementById(a):a}function Id(a,b){Wa(b,function(c,d){if(d=="style")a.style.cssText=c;else if(d=="class")a.className=c;else if(d=="for")a.htmlFor=c;else if(d in Jd)a.setAttribute(Jd[d],c);else a[d]=c})}var Jd={cellpadding:"cellPadding",cellspacing:"cellSpacing",colspan:"colSpan",rowspan:"rowSpan",valign:"vAlign",height:"height",width:"width",usemap:"useMap",frameborder:"frameBorder",maxlength:"maxLength",type:"type"};
function Kd(a){var b=a.document;if(I&&!J("500")&&!nb){if(typeof a.innerHeight=="undefined")a=window;b=a.innerHeight;var c=a.document.documentElement.scrollHeight;if(a==a.top)if(c<b)b-=15;return new Ed(a.innerWidth,b)}a=k;if(lb&&!J("9.50"))a=m;a=a?b.documentElement:b.body;return new Ed(a.clientWidth,a.clientHeight)}function Ld(a,b,c){function d(h){if(h)b.appendChild(w(h)?a.createTextNode(h):h)}for(var e=2;e<c.length;e++){var f=c[e];ma(f)&&!(oa(f)&&f.nodeType>0)?Ja(Md(f)?Pa(f):f,d):d(f)}}
function Nd(a,b){var c=a.createElement("div");if(H){c.innerHTML="<br>"+b;c.removeChild(c.firstChild)}else c.innerHTML=b;if(c.childNodes.length==1)return c.removeChild(c.firstChild);else{for(var d=a.createDocumentFragment();c.firstChild;)d.appendChild(c.firstChild);return d}}function Od(a,b){if(a.contains&&b.nodeType==1)return a==b||a.contains(b);if(typeof a.compareDocumentPosition!="undefined")return a==b||Boolean(a.compareDocumentPosition(b)&16);for(;b&&a!=b;)b=b.parentNode;return b==a}
function Hd(a){return a.nodeType==9?a:a.ownerDocument||a.document}function Md(a){if(a&&typeof a.length=="number")if(oa(a))return typeof a.item=="function"||typeof a.item=="string";else if(na(a))return typeof a.item=="function";return m}function Gd(a){this.a=a||t.document||document}s=Gd.prototype;s.J=function(a){return w(a)?this.a.getElementById(a):a};s.l=Gd.prototype.J;
s.Ke=function(){var a=this.a,b=arguments,c=b[0],d=b[1];if(!Fd&&d&&(d.name||d.type)){c=["<",c];d.name&&c.push(' name="',D(d.name),'"');if(d.type){c.push(' type="',D(d.type),'"');var e={};ab(e,d);d=e;delete d.type}c.push(">");c=c.join("")}c=a.createElement(c);if(d)if(w(d))c.className=d;else la(d)?Wc.apply(l,[c].concat(d)):Id(c,d);b.length>2&&Ld(a,c,b);return c};s.createElement=function(a){return this.a.createElement(a)};s.createTextNode=function(a){return this.a.createTextNode(a)};
function Pd(a){a=!I?a.a.documentElement:a.a.body;return new V(a.scrollLeft,a.scrollTop)}s.appendChild=function(a,b){a.appendChild(b)};s.contains=Od;function Qd(a,b,c,d){this.top=a;this.b=b;this.a=c;this.left=d}Qd.prototype.T=function(){return new Qd(this.top,this.b,this.a,this.left)};Qd.prototype.contains=function(a){a=!this||!a?m:a instanceof Qd?a.left>=this.left&&a.b<=this.b&&a.top>=this.top&&a.a<=this.a:a.x>=this.left&&a.x<=this.b&&a.y>=this.top&&a.y<=this.a;return a};function Rd(a,b,c,d){this.left=a;this.top=b;this.width=c;this.height=d}Rd.prototype.T=function(){return new Rd(this.left,this.top,this.width,this.height)};Rd.prototype.contains=function(a){return a instanceof Rd?this.left<=a.left&&this.left+this.width>=a.left+a.width&&this.top<=a.top&&this.top+this.height>=a.top+a.height:a.x>=this.left&&a.x<=this.left+this.width&&a.y>=this.top&&a.y<=this.top+this.height};function Sd(a,b){var c=Hd(a);if(c.defaultView&&c.defaultView.getComputedStyle)if(c=c.defaultView.getComputedStyle(a,l))return c[b]||c.getPropertyValue(b);return""}function Td(a,b){return a.currentStyle?a.currentStyle[b]:l}function Ud(a,b){return Sd(a,b)||Td(a,b)||a.style[b]}function Vd(a){a=a?a.nodeType==9?a:Hd(a):document;var b;if(b=H){X(a);b=m}if(b)return a.body;return a.documentElement}
function Wd(a){var b=a.getBoundingClientRect();if(H){a=a.ownerDocument;b.left-=a.documentElement.clientLeft+a.body.clientLeft;b.top-=a.documentElement.clientTop+a.body.clientTop}return b}
function Xd(a){if(H)return a.offsetParent;var b=Hd(a),c=Ud(a,"position"),d=c=="fixed"||c=="absolute";for(a=a.parentNode;a&&a!=b;a=a.parentNode){c=Ud(a,"position");d=d&&c=="static"&&a!=b.documentElement&&a!=b.body;if(!d&&(a.scrollWidth>a.clientWidth||a.scrollHeight>a.clientHeight||c=="fixed"||c=="absolute"))return a}return l}
function Yd(a){for(var b=new Qd(0,Infinity,Infinity,0),c=X(a),d=c.a.body,e=!I?c.a.documentElement:c.a.body,f;a=Xd(a);)if((!H||a.clientWidth!=0)&&(!I||a.clientHeight!=0||a!=d)&&(a.scrollWidth!=a.clientWidth||a.scrollHeight!=a.clientHeight)&&Ud(a,"overflow")!="visible"){var h=Zd(a),i;i=a;if(mb&&!J("1.9")){var j=parseFloat(Sd(i,"borderLeftWidth"));if($d(i)){var n=i.offsetWidth-i.clientWidth-j-parseFloat(Sd(i,"borderRightWidth"));j+=n}i=new V(j,parseFloat(Sd(i,"borderTopWidth")))}else i=new V(i.clientLeft,
i.clientTop);h.x+=i.x;h.y+=i.y;b.top=Math.max(b.top,h.y);b.b=Math.min(b.b,h.x+a.clientWidth);b.a=Math.min(b.a,h.y+a.clientHeight);b.left=Math.max(b.left,h.x);f=f||a!=e}d=e.scrollLeft;e=e.scrollTop;if(I){b.left+=d;b.top+=e}else{b.left=Math.max(b.left,d);b.top=Math.max(b.top,e)}if(!f||I){b.b+=d;b.a+=e}c=Kd(c.a.parentWindow||c.a.defaultView||window);b.b=Math.min(b.b,d+c.width);b.a=Math.min(b.a,e+c.height);return b.top>=0&&b.left>=0&&b.a>b.top&&b.b>b.left?b:l}
function Zd(a){var b,c=Hd(a),d=Ud(a,"position"),e=mb&&c.getBoxObjectFor&&!a.getBoundingClientRect&&d=="absolute"&&(b=c.getBoxObjectFor(a))&&(b.screenX<0||b.screenY<0),f=new V(0,0),h=Vd(c);if(a==h)return f;if(a.getBoundingClientRect){b=Wd(a);a=Pd(X(c));f.x=b.left+a.x;f.y=b.top+a.y}else if(c.getBoxObjectFor&&!e){b=c.getBoxObjectFor(a);a=c.getBoxObjectFor(h);f.x=b.screenX-a.screenX;f.y=b.screenY-a.screenY}else{b=a;do{f.x+=b.offsetLeft;f.y+=b.offsetTop;if(b!=a){f.x+=b.clientLeft||0;f.y+=b.clientTop||
0}if(I&&Ud(b,"position")=="fixed"){f.x+=c.body.scrollLeft;f.y+=c.body.scrollTop;break}b=b.offsetParent}while(b&&b!=a);if(lb||I&&d=="absolute")f.y-=c.body.offsetTop;for(b=a;(b=Xd(b))&&b!=c.body&&b!=h;){f.x-=b.scrollLeft;if(!lb||b.tagName!="TR")f.y-=b.scrollTop}}return f}function ae(a,b){var c;if(b instanceof Ed){c=b.height;b=b.width}else g(Error("missing height argument"));a.style.width=be(b,k);a.style.height=be(c,k)}function be(a,b){if(typeof a=="number")a=(b?Math.round(a):a)+"px";return a}
function ce(a){var b=lb&&!J("10");if(Ud(a,"display")!="none")return b?new Ed(a.offsetWidth||a.clientWidth,a.offsetHeight||a.clientHeight):new Ed(a.offsetWidth,a.offsetHeight);var c=a.style,d=c.display,e=c.visibility,f=c.position;c.visibility="hidden";c.position="absolute";c.display="inline";if(b){b=a.offsetWidth||a.clientWidth;a=a.offsetHeight||a.clientHeight}else{b=a.offsetWidth;a=a.offsetHeight}c.display=d;c.position=f;c.visibility=e;return new Ed(b,a)}
function de(a){var b=Zd(a);a=ce(a);return new Rd(b.x,b.y,a.width,a.height)}function ee(a,b){a.style.display=b?"":"none"}function $d(a){return"rtl"==Ud(a,"direction")}var fe=mb?"MozUserSelect":I?"WebkitUserSelect":l;function ge(a){var b=a.getElementsByTagName("*");if(fe){var c="none";a.style[fe]=c;if(b){a=0;for(var d;d=b[a];a++)d.style[fe]=c}}else if(H||lb){c="on";a.setAttribute("unselectable",c);if(b)for(a=0;d=b[a];a++)d.setAttribute("unselectable",c)}}
function he(a,b){if(/^\d+px?$/.test(b))return parseInt(b,10);else{var c=a.style.left,d=a.runtimeStyle.left;a.runtimeStyle.left=a.currentStyle.left;a.style.left=b;var e=a.style.pixelLeft;a.style.left=c;a.runtimeStyle.left=d;return e}}
function ie(a,b){if(H){var c=he(a,Td(a,b+"Left")),d=he(a,Td(a,b+"Right")),e=he(a,Td(a,b+"Top")),f=he(a,Td(a,b+"Bottom"));return new Qd(e,d,f,c)}else{c=Sd(a,b+"Left");d=Sd(a,b+"Right");e=Sd(a,b+"Top");f=Sd(a,b+"Bottom");return new Qd(parseFloat(e),parseFloat(d),parseFloat(f),parseFloat(c))}};function je(a,b,c,d,e,f,h,i){var j,n=c.offsetParent;if(n){var p=n.tagName=="HTML"||n.tagName=="BODY";if(!p||Ud(n,"position")!="static"){j=Zd(n);p||(j=Dd(j,new V(n.scrollLeft,n.scrollTop)))}}n=de(a);if(p=Yd(a)){var o=new Rd(p.left,p.top,p.b-p.left,p.a-p.top);p=Math.max(n.left,o.left);var r=Math.min(n.left+n.width,o.left+o.width);if(p<=r){var u=Math.max(n.top,o.top);o=Math.min(n.top+n.height,o.top+o.height);if(u<=o){n.left=p;n.top=u;n.width=r-p;n.height=o-u}}}p=X(a);r=X(c);if(p.a!=r.a){p=p.a.body;r=
r.a.parentWindow||r.a.defaultView;u=new V(0,0);o=Hd(p)?Hd(p).parentWindow||Hd(p).defaultView:window;var O=p;do{var P;if(o==r)P=Zd(O);else{var A=O;P=new V;if(A.nodeType==1)if(A.getBoundingClientRect){A=Wd(A);P.x=A.left;P.y=A.top}else{var W=Pd(X(A));A=Zd(A);P.x=A.x-W.x;P.y=A.y-W.y}else{W=na(A.Ie);var Ha=A;if(A.targetTouches)Ha=A.targetTouches[0];else if(W&&A.$.targetTouches)Ha=A.$.targetTouches[0];P.x=Ha.clientX;P.y=Ha.clientY}}u.x+=P.x;u.y+=P.y}while(o&&o!=r&&(O=o.frameElement)&&(o=o.parent));p=Dd(u,
Zd(p));n.left+=p.x;n.top+=p.y}a=(b&4&&$d(a)?b^2:b)&-5;b=new V(a&2?n.left+n.width:n.left,a&1?n.top+n.height:n.top);if(j)b=Dd(b,j);if(e){b.x+=(a&2?-1:1)*e.x;b.y+=(a&1?-1:1)*e.y}var x;if(h)if((x=Yd(c))&&j){x.top=Math.max(0,x.top-j.y);x.b-=j.x;x.a-=j.y;x.left=Math.max(0,x.left-j.x)}a:{j=b.T();e=0;a=(d&4&&$d(c)?d^2:d)&-5;d=ce(c);i=i?i.T():d;if(f||a!=0){if(a&2)j.x-=i.width+(f?f.b:0);else if(f)j.x+=f.left;if(a&1)j.y-=i.height+(f?f.a:0);else if(f)j.y+=f.top}if(h){if(x){f=j;e=0;if(f.x<x.left&&h&1){f.x=x.left;
e|=1}if(f.x<x.left&&f.x+i.width>x.b&&h&16){i.width-=f.x+i.width-x.b;e|=4}if(f.x+i.width>x.b&&h&1){f.x=Math.max(x.b-i.width,x.left);e|=1}if(h&2)e|=(f.x<x.left?16:0)|(f.x+i.width>x.b?32:0);if(f.y<x.top&&h&4){f.y=x.top;e|=2}if(f.y>=x.top&&f.y+i.height>x.a&&h&32){i.height-=f.y+i.height-x.a;e|=8}if(f.y+i.height>x.a&&h&4){f.y=Math.max(x.a-i.height,x.top);e|=2}if(h&8)e|=(f.y<x.top?64:0)|(f.y+i.height>x.a?128:0);h=e}else h=256;e=h;if(e&496){c=e;break a}}f=mb&&(gb||pb)&&J("1.9");if(j instanceof V){h=j.x;j=
j.y}else{h=j;j=void 0}c.style.left=be(h,f);c.style.top=be(j,f);h=d==i?k:!d||!i?m:d.width==i.width&&d.height==i.height;h||ae(c,i);c=e}return c};function ke(){}ke.prototype.c=function(){};function le(a,b){this.b=a;this.a=b}C(le,ke);le.prototype.c=function(a,b,c){je(this.b,this.a,a,b,undefined,c)};function me(a,b,c){le.call(this,a,b);this.d=c}C(me,le);me.prototype.c=function(a,b,c,d){var e=je(this.b,this.a,a,b,l,c,10,d);if(e&496){var f=this.a,h=b;if(e&48){f^=2;h^=2}if(e&192){f^=1;h^=1}e=je(this.b,f,a,h,l,c,10,d);if(e&496)this.d?je(this.b,this.a,a,b,l,c,5,d):je(this.b,this.a,a,b,l,c,0,d)}};var ne=t.window;function oe(a,b,c){if(na(a)){if(c)a=z(a,c)}else if(a&&typeof a.handleEvent=="function")a=z(a.handleEvent,a);else g(Error("Invalid listener argument"));return b>2147483647?-1:ne.setTimeout(a,b||0)};function pe(a,b){this.a=new ud(this);var c=a||l;qe(this);this.O=c;if(b)this.Sa=b}C(pe,N);s=pe.prototype;s.O=l;s.Kc=k;s.Jc=l;s.aa=m;s.zf=m;s.qc=-1;s.pc=-1;s.lc=m;s.Rc=k;s.Sa="toggle_display";s.Q=q("Sa");s.J=q("O");function re(a){qe(a);a.Kc=k}function qe(a){a.aa&&g(Error("Can not change this state of the popup while showing."))}s.Ta=function(){return this.aa||B()-this.pc<150};
s.L=function(a){if(a){if(!this.aa)if(this.dispatchEvent("beforeshow")){this.O||g(Error("Caller must call setElement before trying to show the popup"));this.ib();a=Hd(this.O);this.lc&&S(this.a,a,"keydown",this.qf,k);if(this.Kc){S(this.a,a,"mousedown",this.Cd,k);if(H){for(var b=a.activeElement;b&&b.nodeName=="IFRAME";){try{var c=I?b.document||b.contentWindow.document:b.contentDocument||b.contentWindow.document}catch(d){break}a=c;b=a.activeElement}S(this.a,a,"mousedown",this.Cd,k);S(this.a,a,"deactivate",
this.Bd)}else S(this.a,a,"blur",this.Bd)}if(this.Sa=="toggle_display"){this.O.style.visibility="visible";ee(this.O,k)}else this.Sa=="move_offscreen"&&this.ib();this.aa=k;this.qc=B();this.pc=-1;this.dispatchEvent("show")}}else se(this)};s.ib=v;
function se(a,b){if(!a.aa||!a.dispatchEvent({type:"beforehide",target:b}))return m;a.a&&xd(a.a);if(a.Sa=="toggle_display")a.zf?oe(a.ud,0,a):a.ud();else if(a.Sa=="move_offscreen"){a.O.style.left="-200px";a.O.style.top="-200px"}a.aa=m;a.pc=B();a.dispatchEvent({type:"hide",target:b});return k}s.ud=function(){this.O.style.visibility="hidden";ee(this.O,m)};s.Cd=function(a){a=a.target;if(!Od(this.O,a)&&(!this.Jc||Od(this.Jc,a))&&!(B()-this.qc<150))se(this,a)};
s.qf=function(a){if(a.keyCode==27)if(se(this,a.target)){a.Aa();a.ic()}};s.Bd=function(a){if(this.Rc){var b=Hd(this.O);if(H||lb){if((a=b.activeElement)&&Od(this.O,a))return}else if(a.target!=b)return;B()-this.qc<150||se(this)}};s.m=function(){pe.n.m.call(this);this.a.D();delete this.O;delete this.a};function te(a,b){this.c=4;this.b=b||undefined;pe.call(this,a)}C(te,pe);function ue(a,b){a.c=b;a.aa&&a.ib()}te.prototype.ib=function(){if(this.b){var a=!this.aa&&this.Q()!="move_offscreen",b=this.J();if(a){b.style.visibility="hidden";ee(b,k)}this.b.c(b,this.c,this.g);a&&ee(b,m)}};function ve(a){var b;b||(b={});var c=window,d=typeof a.href!="undefined"?a.href:String(a);a=b.target||a.target;var e=[],f;for(f in b)switch(f){case "width":case "height":case "top":case "left":e.push(f+"="+b[f]);break;case "target":case "noreferrer":break;default:e.push(f+"="+(b[f]?1:0))}f=e.join(",");if(b.noreferrer){if(b=c.open("",a,f)){d=d.replace(/;/g,"%3B");d=D(d);b.document.write('<META HTTP-EQUIV="refresh" content="0; url='+d+'">');b.document.close()}}else c.open(d,a,f)};var we=H?'<table style="table-layout:fixed" cellpadding=0 cellspacing=0><tr><td>':"",xe=H?"</tr></td></table>":"",ye=0;function ze(){if(ye)return ye;var a=document.createElement("div");a.style.cssText="visibility:hidden;overflow-y:scroll;position:absolute;top:0;width:100px;height:100px";document.body.appendChild(a);ye=a.offsetWidth-a.clientWidth||18;document.body.removeChild(a);return ye};function Ae(a){this.b=a}C(Ae,N);Ae.prototype.c=0;Ae.prototype.z=q("b");Ae.prototype.V=q("b");Ae.prototype.Tb=function(a){return this.c-a.c||va(this.w(),a.w())};function Be(a,b,c,d,e){this.a=a;this.d=b;this.g=c;this.e=d;this.c=e}Be.prototype.A=function(a){return this.b==a.b};var Ce=l;
function De(){if(Ce)return Ce;for(var a=[],b="666666888888aaaaaabbbbbbdddddda32929cc3333d96666e69999f0c2c2b1365fdd4477e67399eea2bbf5c7d67a367a994499b373b3cca2cce1c7e15229a36633cc8c66d9b399e6d1c2f029527a336699668cb399b3ccc2d1e12952a33366cc668cd999b3e6c2d1f01b887a22aa9959bfb391d5ccbde6e128754e32926265ad8999c9b1c2dfd00d78131096184cb05288cb8cb8e0ba52880066aa008cbf40b3d580d1e6b388880eaaaa11bfbf4dd5d588e6e6b8ab8b00d6ae00e0c240ebd780f3e7b3be6d00ee8800f2a640f7c480fadcb3b1440edd5511e6804deeaa88f5ccb8865a5aa87070be9494d4b8b8e5d4d47057708c6d8ca992a9c6b6c6ddd3dd4e5d6c6274878997a5b1bac3d0d6db5a69867083a894a2beb8c1d4d4dae54a716c5c8d8785aaa5aec6c3cedddb6e6e41898951a7a77dc4c4a8dcdccb8d6f47b08b59c4a883d8c5ace7dcce8531049f3501c7561ee2723ad6a58c6914268a2d38b5515dcd6a75d0a4a95c1158962181c244abda5dc4d69fcc23164e402175603f997d5cb5a89ac2182c5730487e536ca66d86c0a4afc9060d5e1821863640ad525cc8969acb125a121f753c3c995b5ab67998c2a62f62133d82155ca63279c34fa6c7942f63095a9a087ec2259add42b6d48e5f6b0281910ba7b828c3d445c8d0908755099d7000cf9911ebb42ed9c2858c500baa5a00d47f1eee9939ddb78d7549168d4500b56414d38233cda9866b3304743500914d14b37037bb9d845b123b870b50ab2671c9448ec98eae42104a70237f9643a5b15fc0c09cc7113f4725617d4585a361a0be9dbac73333335151517373738f8f8fb2b2b20f4b38227f6341a5875dc0a29bc7ba856508a59114d1bc36e9d34fddd398711616871111ad2d2dc94a4acb9292".toUpperCase(),c=
0;c<43;c++){var d=function(e){return"#"+b.substr(c*30+e*6,6)};d=new Be(d(0),d(1),d(2),d(3),d(4));d.b=c;a[c]=d}return Ce=a}for(var Ee=[26,23,41,28,33,37,35,30,38,40,24,31,27,22,25,42,29,32,34,36,39,6,1,12,9,14,4,21,8,19,7,2,11,10,3,20,13,5,15,16,17,18],Fe={},Ge=0;Ge<Ee.length;++Ge)Fe[Ee[Ge]]=Ge;var He=l;function Ie(a){a=a.toUpperCase();if(!He){He={};for(var b=De(),c=0,d=b.length;c<d;++c)He[b[c].a]=c}a=He[a]||-1;return a>=0?De()[a]||l:l}
function Je(a){a=Fe[a];if(a===undefined)return Ee[0];return Ee[(a+1)%Ee.length]};function Ke(a,b,c){this.c=a;this.a={};this.b={};this.d=c||[];Le(this,b||[])}C(Ke,F);function Me(a,b,c){a.a[b]=c;a.b[c]=(a.b[c]||0)+1}Ke.prototype.ya=function(a){this.a[a]!==undefined||Le(this,[a]);return De()[this.a[a]]||l};
function Le(a,b){for(var c=0,d=b.length;c<d;c++){var e=b[c],f=a.c[e];f!==undefined&&Me(a,e,f)}c=0;for(d=b.length;c<d;++c){e=b[c];if(a.a[e]===undefined){a:{f=a.b;var h;h=a.d;if(!h||!h.length)h=Ee;else{for(var i=Pa(Ee),j=0;j<h.length;j++)Na(i,h[j]);h=i}i=h[0];j=Infinity;for(var n=0,p=h.length;n<p;++n){var o=h[n];if(!f[o]){f=o;break a}var r=f[o];if(r<j){i=o;j=r}}f=i}Me(a,e,f)}}}Ke.prototype.m=function(){Ke.n.m.call(this);this.b=this.a=this.c=l};
Ke.prototype.T=function(){var a=new Ke(Za(this.c));a.a=Za(this.a);a.b=Za(this.b);return a};function Ne(a){hc.call(this);this.g=a||new Ke({});this.b={}}C(Ne,hc);Ne.prototype.m=function(){this.b=l;Ne.n.m.call(this)};Ne.prototype.vb=function(a,b,c){this.ja();var d=Ne.n.vb.call(this,a);if(!b){this.b[a.z()]=a;ic(this,"gdc-ctv",a)}c&&Me(this.g,a.z(),c);this.Ma();return d};Ne.prototype.j=function(a,b){w(a)||(a=a.z());var c=this.b[a],d=!!c!=b;if(b){c=this.fb(a);this.b[a]=c}else delete this.b[a];if(d){ic(this,"gdc-ctv",c);jc(this)}};function Oe(a,b){w(b)||(b=b.z());return b in a.b};function Pe(){return aa(k)};function Qe(){}C(Qe,nd);Qe.prototype.R=function(a){this.a=this.c=this.b=a;od(this)};function Re(a,b,c,d,e,f){var h=Se;h.put("id",f||"");f=X(a);h=Nd(f.a,h.toString());this.e=c;this.d=b;a=a.appendChild(h);this.c=new yd(new dd(a,this.d,d,z(f.J,f)),c,e,k);M(this.c,"accept",this.Ve,m,this);c=this.c.a;c.cb=k;id(c);this.a=new te(a);re(this.a);c=this.a;qe(c);c.lc=k;this.b=a}C(Re,F);s=Re.prototype;s.m=function(){if(this.a){this.a.D();this.a=l}this.b=l};s.L=function(a){this.a.L(a)};s.Ta=function(){return this.a.Ta()};s.Ve=function(){this.L(m)};s.J=q("b");var Se=new U('<div id="dpPopup${id}" class="dp-popup" style="display: none;"></div>');var Te=RegExp("^(?:([^:/?#.]+):)?(?://(?:([^/?#]*)@)?([\\w\\d\\-\\u0100-\\uffff.%]*)(?::([0-9]+))?)?([^?#]+)?(?:\\?([^#]*))?(?:#(.*))?$");function Ue(a){var b=a.match(Te);a=b[1];var c=b[2],d=b[3];b=b[4];var e=[];a&&e.push(a,":");if(d){e.push("//");c&&e.push(c,"@");e.push(d);b&&e.push(":",b)}return e.join("")}function Ve(a){if(a[1]){var b=a[0],c=b.indexOf("#");if(c>=0){a.push(b.substr(c));a[0]=b=b.substr(0,c)}c=b.indexOf("?");if(c<0)a[1]="?";else if(c==b.length-1)a[1]=undefined}return a.join("")}
function We(a,b,c){for(c=c||0;c<b.length;c+=2){var d=b[c],e=b[c+1],f=a;if(la(e))for(var h=0;h<e.length;h++){f.push("&",d);e[h]!==""&&f.push("=",xa(e[h]))}else if(e!=l){f.push("&",d);e!==""&&f.push("=",xa(e))}}return a}function Xe(a){return Ve(arguments.length==2?We([a],arguments[1],0):We([a],arguments,1))}var Ye=/#|$/;function Ze(a){var b={},c;for(c in a)b[a[c]]=c;this.b=b}Ze.prototype.a=function(a){return a};function $e(a,b){this.b=a;this.Zb=b}var af=/^[a-zA-Z0-9_]+$/;$e.prototype.w=function(){return this.b||""};function bf(a,b,c,d){this.e=a;this.M=b;this.a=c;a=b.f();this.c=isNaN(b.q);this.d=c.f()>=tc(a);this.p=!this.c&&c.q*60+c.s==0;this.j=(a<<1)+!this.d+a%1;this.u=d||{}}s=bf.prototype;s.Fd="";s.Pc="";s.tb="";s.pa="";s.va="";var cf=new Ze({Lf:0,Jf:1,Kf:2,Pf:3,Qf:4,Mf:5,Nf:6,Rf:-1});z(cf.a,cf);var df={invited:0,accepted:1,declined:2,tentative:3,unknown:-1};s=bf.prototype;s.Ka=-1;s.z=q("e");s.w=q("tb");s.setTitle=function(a){this.tb=a};s.Qa=aa(l);s.A=function(a){if(this==a)return k;return!!a&&a.z()==this.z()};
function ef(a,b,c){return b.j-c.j||c.a.f()-b.a.f()||a(b,c)||va(b.w(),c.w())}s.T=function(){var a=new bf(this.e,Qc(this.M).Fc(),Qc(this.a).Fc());a.Fd=this.Fd;a.Pc=this.Pc;a.tb=this.tb;a.pa=this.pa;a.va=this.va;a.b=this.b;a.Ka=this.Ka;return a};function ff(a,b,c){bf.call(this,a,b,c);this.g=[]}C(ff,bf);s=ff.prototype;s.Gc=l;s.Ja="";s.ub=l;s.Ca=m;s.Qa=q("Gc");s.N=q("ub");function gf(a,b){return a.N()&&b.N()&&a.N().Tb(b.N())||0};function hf(a){this.d=a}hf.prototype.z=q("d");function jf(a,b,c,d){this.d=a;this.g=c||a;a=this.c=b;b=this.z();b in a.a&&g(Error("Already registered an event source with id "+b));a.a[b]=new kf(b);a.b[b]=this;if(!d){lf=d=Je(lf);d=De()[d]||l}this.j=d}C(jf,hf);s=jf.prototype;s.Yb=0;s.w=q("g");s.setTitle=function(a){this.g=a};s.ya=q("j");s.Ee=function(a,b,c){a.ub=this;a.b=this.z();mf(this.c,this.z(),[a],b,c)};s.Tb=function(a){return this.Yb-a.Yb||va(this.w(),a.w())};s.Wb=function(a,b){b.call(l,[],l)};var lf=0;function nf(a){this.b=a.z();this.a=a}C(nf,Ae);nf.prototype.w=function(){return this.a.w()};nf.prototype.setTitle=function(a){if(this.w()!=a){this.a.setTitle(a);this.dispatchEvent("change")}};nf.prototype.ya=function(){return this.a.ya()};nf.prototype.N=q("a");function of(a,b){return a.a.Tb(b.a)};function pf(){Ne.call(this)}C(pf,Ne);pf.prototype.fb=function(a){return pf.n.fb.call(this,a)};function qf(a,b){var c="/"+encodeURIComponent(b)+"/",d=Xa(a.a),e=La(d,function(f){return f.N().z().indexOf(c)>-1});return e<0?l:d[e].N()};function rf(a){this.a=a;this.id=sf++;this.d="goog$calendar$CalendarList$"+this.id+"showHideCalendar";ua(this.d,z(this.a.j,this.a))}function tf(a){var b=[];a.g(b);a.c(b);a.e(b);return b.join("")}rf.prototype.g=v;rf.prototype.e=v;var uf=0,sf=0;function vf(a){rf.call(this,a)}C(vf,rf);vf.prototype.c=function(a){a.push('<div id="calendarList',this.id,'" class="calendar-list">');wf(this,Xa(this.a.a),a);a.push("</div>")};
function wf(a,b,c){var d=a.j;d.put("id",a.id);for(var e=0;e<b.length;++e){var f=b[e].N(),h=f.z(),i=++uf,j=Oe(a.a,h)?"checked":"";d.put("calIndex",i);d.put("cid",h);d.put("checked",j);d.put("titleColor",f.ya().a);d.put("name",D(f.w()));d.put("onclickCall",a.d+"(value, this.checked);");c.push(d.toString())}}vf.prototype.j=new U('<div class="calendar-row"><label for="cal${calIndex}checkbox${id}"><input type="checkbox" name="calVisibility${id}" id="cal${calIndex}checkbox${id}" value="${cid}" onclick="${onclickCall}" ${checked}><span style="color: ${titleColor}">${name}</span></label></div>');
function xf(a){rf.call(this,a);this.b=[]}C(xf,vf);function yf(a,b,c){a.b.push(new zf(b,c))}xf.prototype.c=function(a){a.push('<div id="calendarList',this.id,'" class="calendar-list">');for(var b=Xa(this.a.a),c=0;c<this.b.length;++c){var d=this.b[c];d.title&&a.push('<div class="cal-list-title">',D(d.title),"</div>");d=Ka(b,d.filter);if(!(d.length<1)){wf(this,d.sort(of),a);for(var e=0;e<d.length;++e);}}a.push("</div>")};function zf(a,b){this.title=a;this.filter=b};function Af(a,b){this.d=a;var c=b||X(),d=c.Ke("div",{style:"position:absolute;display:none;z-index:25000003"});c.appendChild(c.a.body,d);te.call(this,d);re(this)}C(Af,te);Af.prototype.e=function(){this.L(m);if(!this.Ta()){this.O.innerHTML=tf(this.d);this.L(k)}};function Bf(a,b,c){this.c=[];this.b=b||Cf;this.d=c||"gcal$func$";this.g=a}C(Bf,F);var Cf=t.gcal$func$={},Df=0,Ef=new Bf;Bf.prototype.m=function(){for(var a=0,b=this.c.length;a<b;++a)delete this.b[this.c[a]];Bf.n.m.call(this)};Bf.prototype.a=function(a,b){var c=b||this.g;if(c)a=z(a,c);c=Df++;this.b[c]=a;this.c.push(c);return this.d+"["+c+"]"};Bf.prototype.e=function(a){delete this.b[a.substring(this.d.length+1,a.length-1)]};z(Ef.a,Ef);z(Ef.e,Ef);var Ff,Gf=l,Hf=/calendar\/(?:a|hosted)\/([^\/]*)\//;function If(a,b,c){b=RegExp(String(b+"=").replace(/([-()\[\]{}+?*.$\^|,:#<!\\])/g,"\\$1").replace(/\x08/g,"\\x08")+"([^@"+c+"]*)");return(a=a.match(b))?a[1]:l}function Jf(){var a=Ff;if(a!==undefined)return a;var b;if(a=window.location.pathname.match(Hf))b=a[1];a="CAL";if(b)a+=Kf()?"HS":"H";if((a=If(document.cookie,a,";"))&&b)a=If(a,b,":");return Ff=a}function Kf(){if(Gf==l)Gf=window.location.protocol=="https:";return Gf};var Lf={};function Mf(a,b){var c=[a.k,Nf(a.i),Nf(a.h)].join("-"),d=[Nf(a.q),Nf(a.s),Nf(a.v)].join(":"),e="";if(b!==undefined)if(b==0)e="Z";else{e=b;var f=Lf[e];if(f)e=f;else{if(e<0){f="-";e=-1*e}else f="+";var h=Math.floor(e/60);if(h<10)h="0"+h;e=e%60;if(e<10)e="0"+e;e=Lf[e]=Ea(f,h,":",e)}}return Ea(c,"T",d,e)}function Nf(a){return a<10?"0"+a:String(a)}var Of=/\/feeds\/([^\/]*)/,Pf=/^(https?:\/\/.*\.google\.com.*\/calendar\/feeds\/.*\/)(basic|full|embed)/;
function Qf(a){return(a=a.match(Of))?a[1]:l}function Rf(a){var b=a.match(Pf);if(b)a=b[1]+"embed";if(Kf())a=a.replace(/^http:/,"https:");return a}function Sf(a){var b=a;if(a.substr(0,39)=="http://schemas.google.com/g/2005#event.")b=a.substr(39);a=df[b];return a!==undefined?a:l};function Tf(a,b,c,d,e){this.b=b;b=e||{};e=Uf;for(var f in e)f in b||(b[f]=e[f]);this.d=a;this.o=X(a);this.e=c;this.p=[];this.C=l;this.$a=b.showNavigation;this.qb=b.showTabs;this.rb=b.showPrintButton;this.j=b.showDateMarker;this.Ya=b.showCalendarMenu;this.ne=b.showTz;this.le=b.showSubscribeButton;this.he=b.showElementsLogo;this.Of=l;this.a=Vf++;a=this.u=new Bf(this);this.Yd=a.a(this.Pd);this.Mb=a.a(this.pe);this.Ib=a.a(this.ge);this.oe=a.a(this.Df);this.Lb=a.a(this.yf);this.F=new ud(this);this.S=d;
M(this.S,"gcal-kds",this.We,m,this);this.da=l;M(this.b.a,"newday",this.Be,m,this);this.c=new pd;d=new Qe;d.R(T(this.b.a));qd(this.c,d);this.Xb();this.Da=l;d=b.pingInterval||36E5;if(d!=-1)this.Hc=window.setInterval(z(this.Sc,this),d)}C(Tf,N);var Vf=1;Tf.prototype.m=function(){Tf.n.m.call(this);this.F.D();this.S.D();this.Hc!==undefined&&window.clearInterval(this.Hc);this.u.D()};var Uf={showNavigation:k,showPrintButton:k,showTabs:k,showDateMarker:k,showCalendarMenu:k,showSubscribeButton:k,showTz:k,showElementsLogo:m};
Tf.prototype.ge=function(a){if(this.j){var b=this.o.l("dateEditableBox"+this.a),c=this.o.l("dateMenuArrow"+this.a),d=this.o.l("arrowImg"+this.a);if(a){b.className="date-picker-on";c.className="date-picker-on date-picker-arrow-on";d.src=this.b.d+"menu_arrow_hover.gif"}else{b.className="date-picker-off";c.className="date-picker-off";d.src=this.b.d+"menu_arrow_open.gif"}}};
Tf.prototype.pe=function(){if(this.j)if(this.P.Ta())this.P.L(m);else{this.P.L(k);var a=this.o.l("dateMenuArrow"+this.a);je(a,7,this.P.J(),6,undefined,undefined,5)}};function Wf(a){if(!a.da){var b=new vf(a.S);a.da=new Af(b,a.o)}return a.da}Tf.prototype.bd=function(){return Xf};
var Xf=new U('<div class="calendar-container ${extraClasses}">${topHtml}<div class="view-cap t1-embed">&nbsp;</div><div class="view-cap t2-embed">&nbsp;</div><div class="view-container-border" id="calendarContainer${id}"><div id="viewContainer${id}" class="view-container"></div>${footer}<div id="loading${id}" class="loading">Loading...</div></div><div class="view-cap t2-embed">&nbsp;</div><div class="view-cap t1-embed">&nbsp;</div>${bottomHtml}</div>'),Yf=new U('<div class="header" id="nav${id}" ${headerStyle}>&nbsp;</div>'),
Zf=new U('<div class="date-controls"><table class="nav-table" cellpadding="0" cellspacing="0" border="0"><tr>${navContent}</tr></table></div>'),$f=new U('<td class="date-nav-buttons"><button class="today-button" id="todayButton${id}">Today</button><img id="navBack${id}" src="${protocol}calendar.google.com/googlecalendar/images/blank.gif" width=22 height=17 class="navbutton navBack"><img id="navForward${id}" src="${protocol}calendar.google.com/googlecalendar/images/blank.gif" width=22 height=17 class="navbutton navForward"></td>'),
ag=new U('<td id="dateMenuArrow${id}" class="date-picker-off" onmouseover="${hoverDatePicker}(true);"onmouseout="${hoverDatePicker}(false);"onmousedown="${toggleDatePicker}()"><img src="${imagePath}menu_arrow_open.gif" id="arrowImg${id}" class="arrowImg" width=9 height=9></td>'),bg=new U('<td id="dateEditableBox${id}" class="date-picker-off"onmouseover="${hoverDatePicker}(true);"onmouseout="${hoverDatePicker}(false);"onmousedown="${toggleDatePicker}()"><div class="date-top" id="currentDate${id}">&nbsp;</div></td>'),
cg=new U('<td class="ui-rtsr"><div class="${tab_class} t1-embed">&nbsp;</div><div class="${tab_class} t2-embed">&nbsp;</div><div class="${tab_class} ui-rtsr-name" onclick="${changeTab}(\'${viewType}\')">${tab_name}</div></td>'),dg=new U('<td class="calendar-nav"><img id="calendarListButton${id}" src="${imagePath}btn_menu6.gif" alt="" title="" width=15 height=14></td>'),eg=new U('<table id="footer${id}" class="footer" cellpadding="0" cellspacing="0"width="100%"><tr>${tz}${addButton}</tr></table>'),
fg=new U('<td valign="bottom" id="timezone">${tz}</td>'),gg=new U('<td valign="bottom"><img align="right" class="subscribe-image" src="${imagePath}calendar_plus_en.gif" height=17 onclick="${subscribe}();"></td>'),hg=new U(H&&xb<7?'<td valign="bottom" align="right"><a target="_blank" href="http://www.google.com/webelements"><span style="width:130px;height:20px;display:inline-block;filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=${imagePath}gwe.png,sizingMethod=crop);"</span></a></td>':
'<td valign="bottom"><a target="_blank" href="http://www.google.com/webelements"><img align="right"  src="${imagePath}gwe.png" width="130" height="20" border="0"></a></td>');s=Tf.prototype;s.kd=function(){var a='style="overflow:hidden'+(this.$a||this.j||this.qb||this.Ya||this.rb?'"':'; display:none"');Yf.put("id",this.a);Yf.put("headerStyle",a);return Yf.toString()};s.$c=aa("");
s.Xb=function(){var a=this.bd();a.put("topHtml",this.kd());a.put("bottomHtml",this.$c());var b=[];if(H){b.push("ie");if(J("8"))b.push("ie8");else J("7")?b.push("ie7"):b.push("ie6")}a.put("extraClasses",b.join(" "));b="";if(this.he){hg.put("imagePath",this.b.d);b=hg.toString()}else if(this.le){gg.put("subscribe",this.oe);gg.put("imagePath",this.b.d);b=gg.toString()}var c="";if(this.ne){fg.put("tz",this.b.j?"Events shown in time zone: "+this.b.P:"Events shown in your computer's time zone");c=fg.toString()}eg.put("addButton",
b);eg.put("tz",c);eg.put("id",this.a);a.put("id",this.a);a.put("footer",eg.toString());this.d.innerHTML=a.toString();this.Oc();if(this.j){a=this.o.l("dateEditableBox"+this.a);b=this.o.l("dateMenuArrow"+this.a);this.P=new Re(this.d,this.b.b,this.b.a,new bd(this.b.p),this.c,String(this.a),[a,b])}this.ra()};s.ec=function(){if(this.Da!=l)return this.Da;var a=ze(),b=this.o.l("calendarContainer"+this.a),c=ig(this);a+=b.offsetWidth-(c.offsetWidth+c.offsetLeft);return this.Da=a};
s.ra=function(){if(!(Vd(this.d).clientHeight<=0)){var a=parseInt(this.d.style.height,10)||0,b=this.yb();a-=b;b=ig(this);if(a<=0)a=1;b.style.height=a+"px";this.fa()}};s.yb=function(){var a=this.o.l("nav"+this.a).offsetHeight;return this.o.l("footer"+this.a).offsetHeight+a+4};
s.yf=function(){var a=this.C,b=a.Q().toUpperCase(),c;c=window.location.href;var d=c.search(Ye),e;b:{for(e=0;(e=c.indexOf("pvttk",e))>=0&&e<d;){var f=c.charCodeAt(e-1);if(f==38||f==63){f=c.charCodeAt(e+5);if(!f||f==61||f==38||f==35)break b}e+=6}e=-1}if(e<0)c=l;else{f=c.indexOf("&",e);if(f<0||f>d)f=d;e+=6;c=decodeURIComponent(c.substr(e,f-e).replace(/\+/g," "))}d=[];e=G(this.S.b);for(f=0;f<e.length;++f){var h=Qf(e[f]);h&&d.push(decodeURIComponent(h))}e=this.b.c;a=a.la();b=Xe(e.a+"/print_preview","dates",
a.toString(),"hl","en","ctz",e.c,"pgsz","letter","wkst",String(e.j+1),"mode",b,"wdtp",this.b.K?l:"23456","pvttk",c,"src",d);b=window.open(b.toString(),"goocalprint","location=0,status=0,fullscreen=0,directories=0,toolbar=0,menubar=0,width=600,height=680",k);try{b.document.close();b.focus()}catch(i){}};
function jg(a){if(a.qb){var b=a.p,c=a.C,d=["<table cellpadding=0 cellspacing=0><tr>"];cg.put("changeTab",a.Yd);for(var e=0;e<b.length;e++){var f=b[e],h=f===c?"ui-rtsr-selected":"ui-rtsr-unselected";if(e==0)h+=" ui-rtsr-first-tab";if(e==b.length-1)h+=" ui-rtsr-last-tab";cg.put("tab_class",h);cg.put("tab_name",f.Uc);cg.put("viewType",f.Q());d.push(cg.toString())}d.push("</tr></table>");a.o.l("calendarTabs"+a.a).innerHTML=d.join("")}}
s.Oc=function(){var a=this.o.l("nav"+this.a),b;b=[];if(this.$a){$f.put("id",this.a);$f.put("protocol",Kf()?"https://":"http://");b.push($f.toString())}if(this.j){bg.put("id",this.a);bg.put("toggleDatePicker",this.Mb);bg.put("hoverDatePicker",this.Ib);b.push(bg.toString());ag.put("id",this.a);ag.put("imagePath",this.b.d);ag.put("toggleDatePicker",this.Mb);ag.put("hoverDatePicker",this.Ib);b.push(ag.toString())}b.push('<td class="navSpacer">&nbsp;</td>');if(this.rb){b.push('<td><img src="'+this.b.d+
'icon_print.gif" style="cursor: pointer;" onclick="'+this.Lb+'()"  title="Print my calendar (shows preview)" width="16" height="16"></td>');b.push('<td><div class="tab-name" onclick="'+this.Lb+'()">Print</div></td>')}b.push('<td id="calendarTabs',this.a,'"></td>');if(this.Ya){dg.put("id",this.a);dg.put("imagePath",this.b.d);b.push(dg.toString())}if(b.length<=1)b="";else{Zf.put("navContent",b.join(""));b=Zf.toString()}a.innerHTML=b;if(this.$a){xd(this.F);a=this.o;S(this.F,a.l("navBack"+this.a),"mousedown",
this.Ce);S(this.F,a.l("navForward"+this.a),"mousedown",this.De);S(this.F,a.l("todayButton"+this.a),"mousedown",this.xd)}M(this.c,"change",this.Wd,m,this);if(this.Ya){ue(Wf(this),6);a=Wf(this);b=this.o.l("calendarListButton"+this.a);M(b,"mousedown",a.e,m,a);a.b=new le(b,7)||undefined;a.aa&&a.ib()}this.qb&&jg(this)};
s.Pd=function(a){if(typeof a=="string"){var b=a;a=l;for(var c=0;c<this.p.length;++c){var d=this.p[c];if(d.Q()==b){a=d;break}}if(!a)return m}b=a.Q().lastIndexOf("next",0)==0;if(a==this.C&&!b)return m;this.C&&this.C.P.wb();if(this.C=a){a=this.C.b;a.pb(this.c.b,this.c.c,this.c.a);qd(this.c,a)}this.Wd();this.fa();jg(this);return k};s.We=function(){this.fa()};s.fa=function(){var a=this.C;a&&!(Vd(this.d).clientHeight<=0)&&a.eb()};
s.Tc=function(a,b){var c=this;this.Ec(k);kg(this.e,G(this.S.b),a,function(d){b.call(l,d);c.Ec(c.e.vc>0)})};s.Sc=function(){if(!(!this.C||Vd(this.d).clientHeight<=0)){var a=this.e,b=this.C.la(),c=z(this.rf,this);b=lg(a,G(a.b),b,c,k);for(var d in b.a){c=a.b[d];var e=a.a[d],f=z(a.j,a,d,b);c.Wb(b.a[d],f,e.d)}}};s.rf=function(){this.fa()};s.Ec=function(a){var b=this.o.l("loading"+this.a);b.style.right=this.ec()+"px";b.style.display=a?"block":"none"};s.Be=function(){this.fa()};s.De=function(){this.C.Wc()};
s.Ce=function(){this.C.Vc()};s.xd=function(){this.navigate(T(this.b.a))};s.navigate=function(a){this.c.R(a)};s.Wd=function(){if(this.j&&this.C)this.o.l("currentDate"+this.a).innerHTML=D(mg(this.C.a.b,this.C.b.a))};s.z=q("a");function ig(a){return a.o.l("viewContainer"+a.a)}s.Df=function(){for(var a=G(this.S.b),b=[],c=0;c<a.length;++c){var d=Qf(a[c]);d&&b.push(decodeURIComponent(d))}window.open(Xe(this.b.c.a+"/render","cid",b))};function ng(){}var og={};var pg;function qg(a){this.a=a};var rg=["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],gd=["S","M","T","W","T","F","S"],sg=["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],tg=[,"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],hd=[,"January","February","March","April","May","June","July","August","September","October","November","December"];function ug(){};function vg(a){this.a=a||new wg}C(vg,ug);function xg(a,b,c,d){return(a.a.c||isNaN(b.q)?da:c&&0==b.s?d?ha:fa:d?ga:ea)(b.q,b.s)}function mg(a,b,c,d){d=(d?tg:hd)[b.i];a=b.k==a.a.a.k&&Math.abs(b.i-a.a.a.i)<4?""+d+" "+b.h:""+d+" "+b.h+", "+b.k;return""+(c?rg:sg)[b.wa()]+", "+a}
function yg(a,b,c){var d;if(isNaN(c.q))if((wc(c,b).c/3600|0)>=24){a=new R(b,c);d=a.start;var e=Bc(a.end,-1);a=d.k;b=d.i;c=d.h;var f=e.k,h=e.i;e=e.h;var i=tg[b],j=tg[h];d=a==f?b==h?c==e?""+sg[d.wa()]+", "+(""+i+" "+c+", "+a):""+i+" "+c+" \u2013 "+e+" "+a:""+i+" "+c+" \u2013 "+j+" "+e+", "+a:""+(""+i+" "+c+", "+a)+" \u2013 "+(""+j+" "+e+", "+f)}else d=mg(a,b,k);else{f=!(b.s||c.s);d=mg(a,b,k)+", "+xg(a,b,f);a=(b.t()!=c.t()?mg(a,c,k)+", ":"")+xg(a,c,f);d=""+d+" \u2013 "+a}return d}
function wg(a,b){this.c=a||m;this.b=b||0;this.a=Kc(new Date)}function zg(a,b){switch(b.b){case 1:return""+a.h+"/"+a.i;case 0:return""+a.i+"/"+a.h;case 2:return""+a.i+"/"+a.h;default:return""+a.i+"/"+a.h}};function Ag(){}C(Ag,rd);function Bg(a,b,c){this.a=new sd(a,b,c);this.a.ab(this)}C(Bg,Ag);Bg.prototype.hb=function(a){return this.a.hb(a)};Bg.prototype.tc=function(){return this.a.tc()};Bg.prototype.Oa=function(){return this.a.Oa()};Bg.prototype.gc=function(){return this.a.gc()};function T(a){return Kc(a.gc())}function Cg(a){return Ec(a.Oa())};function Dg(a,b,c){Bg.call(this,a,b,c)}C(Dg,Bg);function Eg(a,b,c,d){this.a=a;this.j=b;this.b=d||"";this.g=m;this.e="1";this.d=c?Pa(c):l}C(Eg,N);Eg.prototype.w=q("b");function Fg(a,b,c){Eg.call(this,a,a,l,b);this.c=c?c.replace("{hl}",encodeURIComponent("en")):l}C(Fg,Eg);var Gg=/^(https?:\/\/[^\/]*)\/calendar(\/((hosted)|(a)|(b))\/[^\/]*)?/,Hg=typeof window!="undefined"?window.location.href:"";Hg.replace(/#.*/,"");function Ig(a){return!!(a&&a.match(/^(?:https?:)?\/\/(?:[^:\/]+\.)?google\.com(?::\d+)?(?:\/.*$|$)/))}function Jg(a){return Ig(a)?a.replace(/^https?:\/\//i,"//"):a}function Kg(a){return(a=a.match(Gg))&&a[3]=="b"?[a[1]+"/calendar",a[2]]:l}function Lg(){var a=Kg(Hg);if(!a)return l;return parseInt(a[1].split("/")[2],10)};function Mg(a,b,c,d,e){this.g=a;this.d=b;this.j=d;this.c=c;this.b=e;a=this.g+"calendar";if(this.b!=l)a+="/b/"+this.b;else if(this.d)a+="/hosted/"+this.d;this.a=a;this.e=this.g+"calendar/feeds"}function Ng(a,b,c,d,e){if(e&&e.length>1024)e=e.substring(0,1024)+"...";return Xe(a.a+"/event","action","TEMPLATE","hl","en","text",b,"dates",c,"location",d,"ctz",a.c,"details",e)};function Og(a){for(var b in Pg)b in a||(a[b]=Pg[b]);this.Y=a.collapseAllday;b=new wg(a.format24hour,parseInt(a.dateFieldOrder,10));this.b=new vg(b);this.B=a.autoResize;this.u=(b=a.hostedDomain)?new Fg(b.name,b.title,b.maplink):l;this.g=a.baseUrl;if(!Ue(this.g))this.g=Ue(window.location.href)+this.g;this.p=a.weekstart;this.d=a.imagePath;this.j=a.timezone||l;this.P=a.timezoneLocalized;this.F=a.haveQuickAdd;if("nowMs"in a){b=parseInt(a.nowMs,10);var c=B()+td;if(Math.abs(c-b)>=3E4)td=b-B()}this.a=new Dg(Qg(a.timezoneOffsetMs),
Qg(a.timezoneNextTransitionMs),Qg(a.timezoneNextOffsetMs));this.K=a.showWeekends;this.Z=parseInt(a.firstWeekday,10);this.da=parseInt(a.workWeekLength,10);this.c=new Mg(this.g,this.u&&this.u.a||"",this.j,this.p,Lg());this.e=a.xsrftok}function Qg(a){a=parseInt(a,10);if(isNaN(a))a=undefined;return a}
var Pg={autoResize:k,baseUrl:"http://www.google.com/",collapseAllday:m,dateFieldOrder:0,format24hour:k,hostedDomain:l,imagePath:"http://www.google.com/calendar/images/",showWeekends:k,preloadEnd:l,preloadStart:l,weekstart:0,haveQuickAdd:m,firstWeekday:1,workWeekLength:5};function kf(a){this.g=a;this.c={};this.e={};this.d=this.a=this.b=l}function Rg(a,b){var c=b.start.t(),d=b.end.t(),e=c.H();d=d.H();c={};for(var f=[];e<d;e=tc(e))if(e in a.c){var h=a.c[e];if(h){for(var i in h){var j=h[i];if(j.Ca)delete h[i];else if(!(i in c)){f.push(j);c[i]=1}}Ya(h)&&delete a.c[e]}}return f};function Sg(){this.a={};this.b={};this.e={};this.c={};this.d={}}C(Sg,N);Sg.prototype.vc=0;var Tg=1;function Ug(a,b,c){this.id=a;this.e=b;this.c=c;this.d=l;this.b=[];this.a={}}function Vg(a,b,c,d){d=d||Pe();var e=c.end.t().H(),f=[];for(c=c.start.t().H();c<e;c=tc(c))for(var h=0;h<b.length;++h){var i;a:{i=d;var j=a.a[b[h]].c[c];if(j){var n=void 0;for(n in j){var p=j[n];if(!p.Ca&&i(p)){i=k;break a}}}i=m}if(i){f.push(c);break}}return f}
function kg(a,b,c,d){var e;b.sort();e=c.toString()+":"+b.join(",");if(e in a.d)d(a.d[e]);else if(e in a.c)a.c[e].push(d);else{b=lg(a,b,c,d);b.d=e;++a.vc;a.c[e]=[d];if(Ya(b.a))Wg(a,b);else for(var f in b.a){d=a.b[f];e=z(a.g,a,f,b);d.Wb(b.a[f],e)}}}
function lg(a,b,c,d,e){var f=Tg++;d=new Ug(f,d,c);for(f=0;f<b.length;++f){var h=b[f],i=a.a[h],j;j=i;var n=c,p=e?i.d:l;if(!j.b||!j.a)j=n;else{p=!!p&&(j.d==l||p>=j.d);var o=n.start.f()<j.b.f(),r=n.end.f()>j.a.f();j=!o&&!r?p?new R(j.b,j.a):l:o&&r?n:r?new R(p?j.b:j.a,n.end.t()):new R(n.start.t(),p?j.a:j.b)}if(j)d.a[h]=j;else e||d.b.push(Rg(i,c))}return d}Sg.prototype.g=function(a,b,c,d){c&&mf(this,a,c,b.c,d);b.b.push(Rg(this.a[a],b.c));delete b.a[a];if(Ya(b.a)){Wg(this,b);this.dispatchEvent("a")}};
function Wg(a,b){--a.vc;var c=Xg(a,b.b),d=b.d;a.d[d]=c;for(var e=a.c[d],f=0;f<e.length;++f)e[f](c);delete a.c[d]}Sg.prototype.j=function(a,b,c,d){if(c&&c.length){mf(this,a,c,b.c,d);b.b.push(c)}delete b.a[a];if(Ya(b.a)&&b.b.length){b.e();this.dispatchEvent("a")}};function Xg(a,b){for(var c=[],d=0;d<b.length;++d)Qa(c,b[d]);return c.sort(ta(ef,gf))}
function mf(a,b,c,d,e){b=a.a[b];for(var f=0,h=c.length;f<h;++f){var i=c[f],j=i.z(),n=b.e[j];if(n)n.Ca=k;if(i.Ca)delete b.e[j];else{var p=i.M.H();n=i.a.H();if(!i.c&&!i.p)n=tc(n);for(b.e[j]=i;p<n;p=tc(p)){var o;if(p in b.c)o=b.c[p];else{o=[];b.c[p]=o}o[j]=i}}}if(d){var r,u;if(!b.b||d.start.f()<=b.b.f()){b.b=d.start.t();r=k}if(!b.a||d.end.f()>=b.a.f()){b.a=d.end.t();u=k}if(e&&r&&u)if(!b.d||e>b.d)b.d=e}for(d=0;d<c.length;++d){e=c[d].z();if(e in a.e&&c[d].Ca)delete a.e[e];else a.e[e]=c[d]}a.d={}};var Yg="StopIteration"in t?t.StopIteration:Error("StopIteration");function Zg(){}Zg.prototype.next=function(){g(Yg)};Zg.prototype.re=function(){return this};function $g(a){if(typeof a.Pa=="function")return a.Pa();if(w(a))return a.split("");if(ma(a)){for(var b=[],c=a.length,d=0;d<c;d++)b.push(a[d]);return b}return Xa(a)}function ah(a,b,c){if(typeof a.forEach=="function")a.forEach(b,c);else if(ma(a)||w(a))Ja(a,b,c);else{var d;if(typeof a.xa=="function")d=a.xa();else if(typeof a.Pa!="function")if(ma(a)||w(a)){d=[];for(var e=a.length,f=0;f<e;f++)d.push(f)}else d=G(a);else d=void 0;e=$g(a);f=e.length;for(var h=0;h<f;h++)b.call(c,e[h],d&&d[h],a)}};function bh(a){this.b={};this.a=[];var b=arguments.length;if(b>1){b%2&&g(Error("Uneven number of arguments"));for(var c=0;c<b;c+=2)ch(this,arguments[c],arguments[c+1])}else if(a){if(a instanceof bh){b=a.xa();c=a.Pa()}else{b=G(a);c=Xa(a)}for(var d=0;d<b.length;d++)ch(this,b[d],c[d])}}s=bh.prototype;s.I=0;s.Hb=0;s.ac=q("I");s.Pa=function(){dh(this);for(var a=[],b=0;b<this.a.length;b++)a.push(this.b[this.a[b]]);return a};s.xa=function(){dh(this);return this.a.concat()};
s.A=function(a,b){if(this===a)return k;if(this.I!=a.ac())return m;var c=b||eh;dh(this);for(var d,e=0;d=this.a[e];e++)if(!c(this.get(d),a.get(d)))return m;return k};function eh(a,b){return a===b}s.oa=function(){return this.I==0};s.clear=function(){this.b={};this.Hb=this.I=this.a.length=0};
function dh(a){if(a.I!=a.a.length){for(var b=0,c=0;b<a.a.length;){var d=a.a[b];if(Object.prototype.hasOwnProperty.call(a.b,d))a.a[c++]=d;b++}a.a.length=c}if(a.I!=a.a.length){var e={};for(c=b=0;b<a.a.length;){d=a.a[b];if(!Object.prototype.hasOwnProperty.call(e,d)){a.a[c++]=d;e[d]=1}b++}a.a.length=c}}s.get=function(a,b){if(Object.prototype.hasOwnProperty.call(this.b,a))return this.b[a];return b};function ch(a,b,c){if(!Object.prototype.hasOwnProperty.call(a.b,b)){a.I++;a.a.push(b);a.Hb++}a.b[b]=c}
s.T=function(){return new bh(this)};s.re=function(a){dh(this);var b=0,c=this.a,d=this.b,e=this.Hb,f=this,h=new Zg;h.next=function(){for(;;){e!=f.Hb&&g(Error("The map has changed since the iterator was created"));b>=c.length&&g(Yg);var i=c[b++];return a?i:d[i]}};return h};function fh(){}
function gh(a,b,c){switch(typeof b){case "string":hh(a,b,c);break;case "number":c.push(isFinite(b)&&!isNaN(b)?b:"null");break;case "boolean":c.push(b);break;case "undefined":c.push("null");break;case "object":if(b==l){c.push("null");break}if(la(b)){var d=b.length;c.push("[");for(var e="",f=0;f<d;f++){c.push(e);gh(a,b[f],c);e=","}c.push("]");break}c.push("{");d="";for(e in b)if(Object.prototype.hasOwnProperty.call(b,e)){f=b[e];if(typeof f!="function"){c.push(d);hh(a,e,c);c.push(":");gh(a,f,c);d=","}}c.push("}");
break;case "function":break;default:g(Error("Unknown type: "+typeof b))}}var ih={'"':'\\"',"\\":"\\\\","/":"\\/","\u0008":"\\b","\u000c":"\\f","\n":"\\n","\r":"\\r","\t":"\\t","\u000b":"\\u000b"},jh=/\uffff/.test("\uffff")?/[\\\"\x00-\x1f\x7f-\uffff]/g:/[\\\"\x00-\x1f\x7f-\xff]/g;function hh(a,b,c){c.push('"',b.replace(jh,function(d){if(d in ih)return ih[d];var e=d.charCodeAt(0),f="\\u";if(e<16)f+="000";else if(e<256)f+="00";else if(e<4096)f+="0";return ih[d]=f+e.toString(16)}),'"')};function kh(){if(mb){this.ta={};this.Kb={};this.b=[]}}kh.prototype.a=mb;function lh(a,b){if(a.a)for(var c=y(b),d=0;d<a.b.length;d++){var e=a.b[d];mh(a,a.ta,e,c);mh(a,a.Kb,c,e)}}function nh(a,b){var c=a.Kb[b],d=a.ta[b];c&&d&&Ja(c,function(e){Ja(d,function(f){mh(this,this.ta,e,f);mh(this,this.Kb,f,e)},this)},a)}function mh(a,b,c,d){b[c]||(b[c]=[]);Ia(b[c],d)>=0||b[c].push(d)}var Z=new kh;function oh(){}oh.prototype.b=l;function ph(a){var b;if(!(b=a.b)){b={};if(qh(a)){b[0]=k;b[1]=k}b=a.b=b}return b};function rh(){return sh(th)}var th;function uh(){}C(uh,oh);function sh(a){return(a=qh(a))?new ActiveXObject(a):new XMLHttpRequest}uh.prototype.a=l;
function qh(a){if(!a.a&&typeof XMLHttpRequest=="undefined"&&typeof ActiveXObject!="undefined"){for(var b=["MSXML2.XMLHTTP.6.0","MSXML2.XMLHTTP.3.0","MSXML2.XMLHTTP","Microsoft.XMLHTTP"],c=0;c<b.length;c++){var d=b[c];try{new ActiveXObject(d);return a.a=d}catch(e){}}g(Error("Could not create ActiveXObject. ActiveX might be disabled, or MSXML might not be installed"))}return a.a}th=new uh;function vh(a){this.headers=new bh;this.a=a||l}C(vh,N);var wh=/^https?:?$/i,xh=[];function yh(a,b,c,d,e,f){var h=new vh;xh.push(h);b&&M(h,"complete",b);M(h,"ready",ta(zh,h));if(f)h.Fb=Math.max(0,f);Ah(h,a,c,d,e)}function zh(a){a.D();Na(xh,a)}s=vh.prototype;s.ia=m;s.r=l;s.Jb=l;s.Cb="";s.mf="";s.jb=0;s.Bb="";s.Vb=m;s.Ab=m;s.mc=m;s.Ba=m;s.Fb=0;s.Ha=l;s.Md="";s.If=m;
function Ah(a,b,c,d,e){a.r&&g(Error("[goog.net.XhrIo] Object is active with another request"));c=c||"GET";a.Cb=b;a.Bb="";a.jb=0;a.mf=c;a.Vb=m;a.ia=k;a.r=a.a?sh(a.a):new rh;a.Jb=a.a?ph(a.a):ph(th);lh(Z,a.r);a.r.onreadystatechange=z(a.Dd,a);try{a.mc=k;a.r.open(c,b,k);a.mc=m}catch(f){Bh(a,f);return}b=d||"";var h=a.headers.T();e&&ah(e,function(j,n){ch(h,n,j)});c=="POST"&&!Object.prototype.hasOwnProperty.call(h.b,"Content-Type")&&ch(h,"Content-Type","application/x-www-form-urlencoded;charset=utf-8");ah(h,
function(j,n){this.r.setRequestHeader(n,j)},a);if(a.Md)a.r.responseType=a.Md;if("withCredentials"in a.r)a.r.withCredentials=a.If;try{if(a.Ha){ne.clearTimeout(a.Ha);a.Ha=l}if(a.Fb>0)a.Ha=ne.setTimeout(z(a.Ff,a),a.Fb);a.Ab=k;a.r.send(b);a.Ab=m}catch(i){Bh(a,i)}}s.dispatchEvent=function(a){if(this.r){Z.a&&Z.b.push(w(this.r)?this.r:oa(this.r)?y(this.r):"");try{return vh.n.dispatchEvent.call(this,a)}finally{Z.a&&nh(Z,Z.b.pop())}}else return vh.n.dispatchEvent.call(this,a)};
s.Ff=function(){if(typeof ia!="undefined")if(this.r){this.Bb="Timed out after "+this.Fb+"ms, aborting";this.jb=8;this.dispatchEvent("timeout");if(this.r&&this.ia){this.ia=m;this.Ba=k;this.r.abort();this.Ba=m;this.jb=8;this.dispatchEvent("complete");this.dispatchEvent("abort");Ch(this)}}};function Bh(a,b){a.ia=m;if(a.r){a.Ba=k;a.r.abort();a.Ba=m}a.Bb=b;a.jb=5;Dh(a);Ch(a)}function Dh(a){if(!a.Vb){a.Vb=k;a.dispatchEvent("complete");a.dispatchEvent("error")}}
s.m=function(){if(this.r){if(this.ia){this.ia=m;this.Ba=k;this.r.abort();this.Ba=m}Ch(this,k)}vh.n.m.call(this)};s.Dd=function(){!this.mc&&!this.Ab&&!this.Ba?this.uf():Eh(this)};s.uf=function(){Eh(this)};
function Eh(a){if(a.ia)if(typeof ia!="undefined")if(!(a.Jb[1]&&Fh(a)==4&&Gh(a)==2))if(a.Ab&&Fh(a)==4)ne.setTimeout(z(a.Dd,a),0);else{a.dispatchEvent("readystatechange");if(Fh(a)==4){a.ia=m;var b;a:switch(Gh(a)){case 0:b=(b=w(a.Cb)?a.Cb.match(Te)[1]||l:a.Cb.a())?wh.test(b):self.location?wh.test(self.location.protocol):k;b=!b;break a;case 200:case 204:case 304:b=k;break a;default:b=m}if(b){a.dispatchEvent("complete");a.dispatchEvent("success")}else{a.jb=6;var c;try{c=Fh(a)>2?a.r.statusText:""}catch(d){c=
""}a.Bb=c+" ["+Gh(a)+"]";Dh(a)}Ch(a)}}}function Ch(a,b){if(a.r){var c=a.r,d=a.Jb[0]?v:l;a.r=l;a.Jb=l;if(a.Ha){ne.clearTimeout(a.Ha);a.Ha=l}if(!b){Z.a&&Z.b.push(w(c)?c:oa(c)?y(c):"");a.dispatchEvent("ready");Z.a&&nh(Z,Z.b.pop())}if(Z.a){var e=y(c);delete Z.Kb[e];for(var f in Z.ta){Na(Z.ta[f],e);Z.ta[f].length==0&&delete Z.ta[f]}}try{c.onreadystatechange=d}catch(h){}}}function Fh(a){return a.r?a.r.readyState:0}function Gh(a){try{return Fh(a)>2?a.r.status:-1}catch(b){return-1}};function Hh(a,b,c,d,e){this.e=b;this.g=a;this.b=c||"GET";this.B=d;this.d=e||"json"}C(Hh,N);var Ih=[],Jh=0;Hh.prototype.p=m;
function Kh(a){if(a.b=="SCRIPT"){var b=++Jh;Ih[b]=a;var c=Xe(a.g,"alt",a.d+"-in-script","callback","goog$calendar$GdataRequest$callback","reqid",b);a=document.createElement("script");a.src=c;c=document.createElement("div");c.style.display="none";c.innerHTML="<script defer>goog$calendar$GdataRequest$callback(null,"+b+",true);<\/script>";document.body.appendChild(a);document.body.appendChild(c)}else{a.a={};a.a["X-If-No-Redirect"]=1;a.a["Content-Type"]="application/"+(a.d=="json"?"atom+xml":"json");
if(a.e&&!a.c){if(!a.a)a.a={};a.a.Authorization="GoogleLogin auth="+a.e}if(a.b=="PUT"||a.b=="DELETE"){a.a["X-HTTP-Method-Override"]=a.b;a.j="POST"}else a.j=a.b;b=a.g;if(a.c)b=Ve([b,"&","xsrftok","=",xa(a.c)]);Lh(a,Ve([b,"&","alt","=",xa(a.d)]))}}function Lh(a,b){yh(b,z(a.u,a),a.j,a.B,a.a,2E4)}var Mh=/(text\/(plain|javascript)|application\/(json|x-javascript))/;
Hh.prototype.u=function(a){var b=a.target;a=l;var c=m;if(Gh(b)==412){var d=b.r&&Fh(b)==4?b.r.getResponseHeader("X-Redirect-Location"):undefined;if(d&&!this.p){this.p=k;Lh(this,d);return}}else if(Gh(b)==200||Gh(b)==201){c=k;try{d=b.r&&Fh(b)==4?b.r.getResponseHeader("Content-Type"):undefined}catch(e){}if(d&&Mh.test(d))try{var f;try{f=b.r?b.r.responseText:""}catch(h){f=""}a=eval("("+f+")")}catch(i){}}Nh(this,c,a)};function Nh(a,b,c){a.Bc=c;a.F=b;a.dispatchEvent(b?"complete":"error");a.D()}
ua("goog$calendar$GdataRequest$callback",function(a,b,c){var d=Ih[b];if(d){Nh(d,!c,a);delete Ih[b]}});function Oh(a,b){var c=a.title||b||"",d=Jg(a.icon);$e.call(this,c,d);this.d=a}C(Oh,$e);s=Oh.prototype;s.Yc=m;s.Zb="";s.Zc="";s.ye="";function Ph(a){Qh(a);return a.e}s.getHeight=function(){Qh(this);return this.c};function Rh(a){Qh(a);return a.Zc}s.Q=function(){Qh(this);return this.type};
function Qh(a){if(!a.Yc){var b=a.d,c=b.type;if(c){var d=2;if(c=="application/x-google-gadgets+xml")d=1;else if(c.match(/^image/i))d=3;a.type=d}if(b.hasWebContentElement){a.Zc=b.url;a.ye=b.display||"ICON";a.e=parseInt(b.width,10)||300;a.c=parseInt(b.height,10)||400;if(b.gadgetPreferences)a.a=b.gadgetPreferences}a.Yc=k}};function Sh(){}function Th(a,b,c){b=a.zd(b);return new Oh(b,c)}function Uh(a,b,c){for(a=0;a<c.length;++a)if(c[a].method=="alert"&&!c[a].absoluteTime){var d=b,e=c[a].minutes||c[a].hours*60||c[a].days*1440,f=xc(d.M);f.s-=e;d.g.push(f.ha())}}function Vh(a,b,c,d){if(c&&b.indexOf("ctz=")<0){a=b.indexOf("?")<0?"?":"&";b+=a+"ctz="+c}if(d){a=b.indexOf("?")<0?"?":"&";b+=a+"pvttk="+d}return b}function Wh(a,b,c){if(b.f()==c.f())return isNaN(c.q)?zc(c):Pc(c.k,c.i,c.h,c.q,c.s,c.v+1).ha();return c};function Xh(){}C(Xh,Sh);s=Xh.prototype;s.xb=aa("json");s.fd=function(a){return a.feed.entry||[]};s.dd=function(a){return a.entry||[]};s.gd=function(a){return a.feed.title.$t};s.w=function(a){return a.title.$t};s.hd=aa("feed");s.ld=function(a){return a.updated.$t};s.jd=function(a){return a.feed.updated.$t};
s.Lc=function(a){return Ea('<?xml version="1.0" encoding="UTF-8" ?><entry xmlns="http://www.w3.org/2005/Atom" xmlns:gCal="http://schemas.google.com/gCal/2005"><gCal:quickadd value="true"/><content>',D(a),"</content></entry>")};
s.Gd=function(a){a=a.feed.entry||[];for(var b=[],c=0;c<a.length;++c){var d=a[c],e={};e.hidden=d.gCal$hidden&&d.gCal$hidden.value=="true";var f=e,h;a:{h=encodeURIComponent("@");for(var i=d.link||[],j=0,n=i.length;j<n;++j)if(i[j].rel=="alternate"){h=Rf(i[j].href.replace("@",h));break a}h=l}f.url=h;e.color=d.gCal$color.value;e.title=d.gCal$overridename?d.gCal$overridename.value:d.title.$t;e.access=d.gCal$accesslevel.value;b.push(e)}return b};s.Id=function(a){return a.entry};s.ed=function(a){return a.gd$when};
s.zd=function(a){var b={};b.icon=a.href;b.title=a.title;b.type=a.type;if(a=a.gCal$webContent){b.hasWebContentElement=k;b.url=a.url;b.display=a.display;b.width=a.width;b.height=a.height;if(a=a.gCal$webContentGadgetPref){for(var c={},d=0;d<a.length;++d){var e=a[d];c[e.name]=e.value}b.gadgetPreferences=c}}return b};
s.Hd=function(a,b,c){for(var d=[],e=0;e<a.length;++e){var f=a[e],h=f.id.$t,i=f.title.$t,j,n=m;if(f.content)j=f.content.$t;else{j="";i="busy";n=k}var p=f.link,o=f.gd$where;o=o&&o[0];var r=f.gd$when[0],u=Tc(r.startTime,!b),O=Tc(r.endTime,!b);O=Wh(this,u,O);h=new ff(h,u,O);h.setTitle(i);h.va=j;if(p&&!n){j=0;for(n=p.length;j<n;++j)if(p[j].rel=="alternate"&&p[j].type=="text/html"){h.Ja=Vh(this,p[j].href,b,c);break}}if(o)h.pa=o.valueString;if(p)for(j=0;j<p.length;++j){o=p[j];if(o.rel==="http://schemas.google.com/gCal/2005/webContent"){i=
Th(this,o,i);h.Gc=i?i:l;break}}Uh(this,h,r.gd$reminder||[]);if(r=(r=(r=(r=f.gd$who)&&r[0])&&r.gd$attendeeStatus)&&r.value)h.Ka=Sf(r);if((f=f.gd$eventStatus)&&f.value=="http://schemas.google.com/g/2005#event.canceled")h.Ca=k;d.push(h)}return d};function Yh(){}C(Yh,Sh);s=Yh.prototype;s.xb=aa("jsonc");s.fd=function(a){return a.data.items||[]};s.dd=function(a){return a.items||[]};s.gd=function(a){return a.data.title};s.w=function(a){return a.title};s.hd=aa("data");s.ld=function(a){return a.updated};s.jd=function(a){return a.data.updated};s.Lc=function(a){a={data:{quickAdd:k,details:D(a)}};var b=[];gh(new fh,a,b);return b.join("")};
s.Gd=function(a){a=a.data.items||[];for(var b=[],c=0;c<a.length;++c){var d=a[c],e={};e.hidden=d.hidden;var f=d.eventFeedLink;f=Rf(f.replace("@",encodeURIComponent("@")));e.url=f;e.color=d.color;e.title=d.overrideName?d.overrideName:d.title;e.access=d.accessLevel;b.push(e)}return b};s.Id=function(a){return a.data};s.ed=function(a){return a.when};s.zd=function(a){a.hasWebContentElement=a.url||a.width||a.height||a.display||a.gadgetPreferences;return a};
s.Hd=function(a,b,c){for(var d=[],e=0;e<a.length;++e){var f=a[e],h=f.id,i=f.title,j,n=m;if(f.details||f.details=="")j=f.details;else{j="";i="busy";n=k}var p=f.location,o=f.when[0],r=Tc(o.start,!b),u=Tc(o.end,!b);u=Wh(this,r,u);h=new ff(h,r,u);h.setTitle(i);h.va=j;if(f.alternateLink&&!n)h.Ja=Vh(this,f.alternateLink,b,c);if(p)h.pa=p;if(f.webContent){i=Th(this,f.webContent,i);h.Gc=i?i:l}Uh(this,h,o.reminders||[]);if(o=(o=(o=f.attendees)&&o[0])&&o.status)h.Ka=Sf(o);if((f=f.status)&&"http://schemas.google.com/g/2005#event."+
f=="http://schemas.google.com/g/2005#event.canceled")h.Ca=k;d.push(h)}return d};function Zh(a,b,c,d,e,f,h){c=Rf(c);jf.call(this,c,b,d,e);this.b=a;this.e=Xe(c,"ctz",this.b.j);b=window.location.href;a=this.e.match(Te);b=b.match(Te);this.K=a[3]==b[3]&&a[1]==b[1]&&a[4]==b[4];this.F=this.b.a;this.Nb=f||0;this.a=h||(pg.a[40]?new Yh:new Xh)}C(Zh,jf);
Zh.prototype.Wb=function(a,b,c){var d=this.e,e=a.start.t(),f=a.end.t(),h=this.F.hb(B()+td);a=Mf(e.ha(),h/6E4);h=Mf(f.ha(),h/6E4);e=wc(f,e);d=Xe(d,"singleevents","true","start-min",a,"start-max",h,"max-results",e.h*48,"updated-min",c);d=$h(this,d);var i;c="SCRIPT";if(this.K){i=Jf();c="GET"}d=new Hh(d,i,c,undefined,this.a.xb());if(this.b.e)d.c=this.b.e;M(d,"complete",z(this.B,this,b));M(d,"error",z(this.u,this,b));Kh(d)};function $h(a,b){var c=b,d=Lg();if(d!=l)c=Xe(c,"sessionidx",d);return c}
Zh.prototype.B=function(a,b){var c=b.target.Bc,d=this.a.gd(c);this.w()!=d&&this.setTitle(d);d=ai(this,this.a.fd(c));a.call(l,d,this.a.jd(c))};Zh.prototype.u=function(a){a.call(l,l)};var bi=/^https?:\/\/(?:[^\/]*)\.google\.com(?:\:\d+)?\/calendar\/feeds\/[\w%\.]+\/private-(\w+)\//;function ai(a,b){var c=a.b.j,d=a.d.match(bi);d=d&&d[1];c=a.a.Hd(b,c,d);for(d=0;d<c.length;++d){var e=c[d],f=a;e.ub=f;e.b=f.z()}return c};function ci(a,b,c,d,e){Zh.call(this,a,b,c,d,e)}C(ci,Zh);ci.prototype.Yb=-1;ci.prototype.p=function(a,b){var c=this.a.Id(b.target.Bc),d;if(this.a.ed(c)){c=ai(this,[c]);jf.prototype.Ee.call(this,c[0]);d=c[0]}a&&a.call(l,d)};function di(a){this.b=a||(pg.a[40]?new Yh:new Xh)}C(di,ng);di.prototype.init=function(a,b,c){this.a=a;this.d=b;this.c=c};function ei(a,b,c,d,e){if(b.indexOf(a.c)!=0)b=a.c+b;a=c>=60?new ci(a.a,a.d,b,e,d):new Zh(a.a,a.d,b,e,d);a.Nb=c;return a}di.prototype.e=function(a,b){var c=this.b.Gd(b.target.Bc);if(c){a.ja();Ja(c,ta(this.g,a),this);a.Ma()}};
di.prototype.g=function(a,b){if(!b.hidden){var c=b.url;if(c){var d=Ie(b.color),e=b.title,f=b.access=="owner"?70:20,h;if(h=a.fb(c)){var i=h.N();i.setTitle(e);i.j=d;if(Oe(a,c)){ic(a,"gdc-ctv",h);jc(a)}h=k}else h=m;if(!h){c=ei(this,c,f,d,e);a.vb(new nf(c),k)}}}};function fi(a,b,c,d,e){this.b=a;this.j=b;this.a=c;this.d=M(b,"gcal-kds",this.p,m,this);this.e=e;this.g=m;d?gi(this):hi(this)}C(fi,F);function gi(a){if(!a.c){a.b.style.display="";if(!a.g&&a.e){a.b.innerHTML="Loading...";var b=og.goog$calendar$GdataCalendar||l,c=a.j,d;d=b.a.c;var e=d.e+"/"+encodeURIComponent(a.e);if(d.b!=l)e=Xe(e,"sessionidx",d.b);d=e;e=Jf();d=new Hh(d,e,undefined,undefined,b.b.xb());if(b.a.e)d.c=b.a.e;M(d,"complete",z(b.e,b,c));Kh(d)}else a.b.innerHTML=tf(a.a);a.g=k;a.c=k}}
function hi(a){if(a.c){a.b.style.display="none";a.c=m}}fi.prototype.p=function(){if(this.c)this.b.innerHTML=tf(this.a)};fi.prototype.m=function(){fi.n.m.call(this);bc(this.d);delete this.d};function ii(a,b,c,d,e,f){this.Gb=e;f.showSubscribeButton=m;f.showTabs=m;f.showNav=m;f.showDateMarker=m;f.showCalendarMenu=m;Tf.call(this,a,b,c,d,f);this.ce=this.u.a(this.ff);ji(this);this.je=this.u.a(this.Qd);M(c,"a",this.qd,m,this);a=this.Xa.a;b=z(this.Ye,this);a.B=b;a.update()}C(ii,Tf);s=ii.prototype;s.Da=l;s.Ga=m;s.Va=l;
s.Xb=function(){ii.n.Xb.call(this);var a=this.o.l("optionsLink"+this.a);M(a,"mousedown",this.Bf,m,this);a=this.o.l("todayLink"+this.a);M(a,"mousedown",this.xd,m,this);a=Y("picker"+this.a);this.Xa=new yd(new dd(a,this.b.b,new cd(this.b.p),z(this.o.l,this.o),"gadget-dp-"+this.a),this.b.a,this.c,k);a=this.Xa.a;a.cb=k;id(a);ge(ki(this))};s.m=function(){ii.n.m.call(this);this.Z.D()};s.kd=function(){this.Ud.put("id",this.a);return this.Ud.toString()};
s.$c=function(){if(!this.Y){var a=this.u.a(this.te),b='<div id="optionsDiv${id}" class="options-popup" style="display:none"></div><div style="position:relative;width:100%"><div id="quickAddDiv${id}" class="quickadd-popup" style="display:none"></div></div><div id="gadgetFooter${id}" class="gadget-footer"><div id="toolbar${id}"><div style="float:left;padding:2px"><span class="menu-link" id="todayLink${id}">Today</span>';b+='<span style="color: #ccc; padding: 0 3px;">|</span><span class="menu-link" id="addEventLink${id}" onclick="'+
a+'()">Add</span>';b+='</div><div id="optionsLink${id}" style="float:right;padding:2px"><span class="menu-link">Options</span><span id="optionsArrow${id}" class="menu-arrow">\u25bc</span></div><div style="clear:both"></div></div><div id="extraNav${id}" style="display:none;padding:2px"></div></div>';this.Y=new U(b)}this.Y.put("id",this.a);return this.Y.toString()};s.Oc=function(){};
s.Td=function(){var a=this.o.l("gadgetHeader"+this.a);ee(a,a.style.display=="none");this.dispatchEvent("height_changed");this.dispatchEvent("prefs_changed")};s.Sd=function(){var a=this.C;if(a){a.j=!a.j;this.fa();this.dispatchEvent("prefs_changed")}};s.te=function(){this.b.F?li(this):ve(Ng(this.b.c))};s.wf=function(){ve(this.b.c.a+"/render")};
function li(a){mi(a);if(!a.g.Ta()){var b=Y("quickAddBox"+a.a);b.value="";if(!a.Ga){Wc(b,"example");a.Ga=k}oe(function(){b.value="e.g., 7pm Dinner at Pancho's";b.focus();b.selectionStart=0;b.selectionEnd=0});a.g.L(k)}}function mi(a){if(!a.g){var b=a.a,c=Y("quickAddDiv"+b);a.g=new te(c);re(a.g);a.xc.put("id",b);a.xc.put("handleQuickEdit",a.ce);c.innerHTML=a.xc.toString();a.Ga=k;c=Y("quickAddBox"+b);M(c,"keydown",a.tf,m,a);M(c,"mousedown",a.sf,m,a);b=Y("quickAddButton"+b);M(b,"click",a.rd,m,a)}}
s.sf=function(){var a=Y("quickAddBox"+this.a);if(this.Ga){a.value="";Xc(a,"example");this.Ga=m}};s.tf=function(a){var b=Y("quickAddBox"+this.a);if(a.keyCode==27)this.g.L(m);else if(a.keyCode==13||I&&a.keyCode==3)this.rd();if(this.Ga){b.value="";Xc(b,"example");this.Ga=m}};
function ni(a,b){b=D(b);if(!a.B){var c=a.a,d=Y("messageBoxDiv"+c);a.B=new te(d);re(a.B);a.wd.put("id",c);d.innerHTML=a.wd.toString();d.style.top=a.d.style.top}Y("messageBoxContents"+a.a).innerHTML=b;a.B.L(k);a.Va&&ne.clearTimeout(a.Va);a.Va=oe(z(a.we,a),9E3)}s.we=function(){this.B&&this.B.L(m);this.Va&&ne.clearTimeout(this.Va);this.Va=l};function oi(a){a=Y("quickAddBox"+a.a).value;return a!="e.g., 7pm Dinner at Pancho's"?a:""}
s.rd=function(){var a=oi(this);if(a){var b=qf(this.S,this.Gb),c=z(this.He,this),d=z(this.ef,this);a=b.a.Lc(a);var e=Jf(),f=$h(b,b.e);a=new Hh(f,e,"POST",a,b.a.xb());if(b.b.e)a.c=b.b.e;$b(a,"complete",z(b.p,b,c));d&&$b(a,"error",d);Kh(a)}this.g.L(m)};s.ff=function(){var a;a=this.b.c;var b=oi(this);a=Xe(a.a+"/event","action","TEMPLATE","ctext",b,"hl","en","ctz",a.c);ve(a)};
function pi(a){if(!a.Ea){var b=a.a,c=a.o,d=c.l("optionsLink"+b),e=c.l("optionsDiv"+b);a.Ea=new te(e,new me(d,6,k));re(a.Ea);ue(a.Ea,7);d=[];var f=a.ve;f.put("id","toggleDatePickerLink"+b);f.put("content","Show mini calendar");d.push(f.toString());f.put("id","toggleExpiredEventsLink"+b);f.put("content","Show past events");d.push(f.toString());d.push(a.of);f=a.nf;f.put("id","showCalListLink"+b);f.put("content","Edit visible calendars");d.push(f.toString());f.put("id","gotoCalendarLink"+b);f.put("content",
"Open Calendar &raquo;");d.push(f.toString());e.innerHTML=d.join("");ge(e);d=c.l("toggleDatePickerLink"+b);M(d,"click",a.Td,m,a);d=c.l("toggleExpiredEventsLink"+b);M(d,"click",a.Sd,m,a);d=c.l("showCalListLink"+b);M(d,"click",a.Qd,m,a);c=c.l("gotoCalendarLink"+b);M(c,"click",a.wf,m,a);M(e,"click",function(){this.Ea.L(m)},m,a);M(a.Ea,"hide",function(){this.o.l("optionsArrow"+b).innerHTML="\u25bc";this.dispatchEvent("prefs_changed")},m,a)}}
s.Bf=function(){pi(this);if(!this.Ea.Ta()){var a=this.o,b=this.a;a.l("checktoggleDatePickerLink"+b).checked=qi(this);a.l("checktoggleExpiredEventsLink"+b).checked=this.C.j;this.Ea.L(k);a.l("optionsArrow"+b).innerHTML="\u25b2"}};s.qd=function(){this.Xa.a.update()};function ri(a,b){var c=ig(a).style;if(b){c.position="";c.visibility="visible";H&&a.ra()}else{c.visibility="hidden";c.position="absolute"}}function si(a,b){ri(a,m);a.K&&b!=a.K&&ee(a.K,m);ti(a,b);ee(b,k);a.K=b}
function ti(a,b){var c=ce(a.d);c.height-=a.yb();ae(b,c)}function ui(a){var b=a.K;if(b&&b.style.display!="none"){ee(b,m);ri(a,k);a.K=l}}function ji(a){var b=a.S,c=new xf(b);yf(c,"My Calendars",function(e){return e.N().Nb>=70});yf(c,"Other Calendars",function(e){return e.N().Nb<70});var d=a.o.l("calendarList"+a.a);a.Z=new fi(d,b,c,m,a.Gb);M(b,"gcal-kds",a.qd,m,a)}
s.Qd=function(){var a=vi(this);wi(this,['<div class="event-links"><span class="menu-link" id="hideCalListLink',this.a,'" style="float:left">&laquo;&nbsp;back</span><div style="clear:both"></div>'].join(""));si(this,a);gi(this.Z);a=Y("hideCalListLink"+this.a);M(a,"mousedown",this.jf,m,this)};s.jf=function(a){a&&a.Aa();a=Y("hideCalListLink"+this.a);dc(a);this.dispatchEvent("prefs_changed");xi(this);hi(this.Z);ui(this)};s.He=function(a){ni(this,"Event created.");if(a)Oe(this.S,a.b)&&this.fa();else this.Sc()};
s.ef=function(){ni(this,"Unable to create event.")};s.Ye=function(a){var b={};a=new R(a.e,new yc((a.c-1)*a.d+a.b,0,0,0));for(var c=Vg(this.e,G(this.S.b),a,function(e){return!e.Qa()}),d=0;d<c.length;++d)b[c[d]]="dp-with-events";t.clearTimeout(this.Zd);this.Zd=t.setTimeout(z(this.Tc,this,a,v),1500);return b};s.fa=function(){if(G(this.S.b).length==0)ig(this).innerHTML='<div class="view-info"><span class="menu-link" onclick="'+this.je+'()">Select some calendars to display</span></div>';else ii.n.fa.call(this)};
function wi(a,b){var c=yi(a);zi(a).style.display="none";c.innerHTML=b;c.style.display=""}function xi(a){yi(a).style.display="none";zi(a).style.display=""}s.Ec=function(a){var b=this.o.l("loading"+this.a);b.style.display=a?"block":"none";b.style.top=this.o.l("gadgetHeader"+this.a).offsetHeight+"px";b.style.right=this.ec()+"px"};s.ra=function(){var a=Ai(this),b=vi(this);if(a.style.display!="none")ti(this,a);else b.style.display!="none"?ti(this,b):Tf.prototype.ra.call(this)};
s.yb=function(){return this.o.l("gadgetHeader"+this.a).offsetHeight+ki(this).offsetHeight};function Ai(a){return a.ae||(a.ae=a.o.l("detailsContainer"+a.a))}function yi(a){return a.$d||(a.$d=a.o.l("extraNav"+a.a))}function zi(a){return a.qe||(a.qe=a.o.l("toolbar"+a.a))}function vi(a){return a.Xd||(a.Xd=a.o.l("calendarListContainer"+a.a))}function ki(a){return a.fe||(a.fe=a.o.l("gadgetFooter"+a.a))}s.ec=function(){if(this.Da==l)this.Da=ze()-ig(this).offsetLeft;return this.Da};
function qi(a){return a.o.l("gadgetHeader"+a.a).style.display!="none"}s.xc=new U('<div class="quickadd-contentbox"><div class="quickadd-box-outer"><input id="quickAddBox${id}" class="quickadd-box example"></div><input id="quickAddButton${id}" class="quickadd-button" type="button" value="Quick Add">&nbsp;<a class="quickedit-link" id="quickEdit${id}" href="javascript:${handleQuickEdit}()">edit details <strong>&raquo;</strong></a></div>');s.of='<div class="menu-separator"></div>';s.nf=new U('<div class="menu-item" id="${id}"><div class="menu-item-content">${content}</div></div>');
s.ve=new U('<div class="menu-item" id="${id}"><input class="menu-checkbox" type="checkbox" id="check${id}"><div for="check${id}" class="menu-item-check-content">${content}</div></div>');s.wd=new U('<div class="message-box"><div class="message-box-contents"  id="messageBoxContents${id}"></div><div class="t2">&nbsp;</div><div class="t1">&nbsp;</div></div>');s.Ud=new U('<div id="gadgetHeader${id}" class="gadget-header"><div class="datepicker-container"><div class="datepicker-rounder t1">&nbsp;</div><div class="datepicker-rounder t2">&nbsp;</div><div id="picker${id}" class="datepicker"></div><div class="datepicker-rounder t2">&nbsp;</div></div></div>');
s.bd=function(){return Bi};var Bi=new U('<div class="calendar-container ${extraClasses}">${topHtml}<div id="messageBoxDiv${id}" class="message-box-wrapper" style="display:none"></div><div id="viewContainer${id}" class="view-container"></div><div id="detailsContainer${id}" class="details-container" style="display:none"></div><div id="calendarListContainer${id}" class="calendar-list-container" style="display:none"><div class="calendar-list-subcontainer"><div id="calendarList${id}" class="calendar-list-content"></div></div></div>${footer}<div id="loading${id}" class="loading">Loading...</div>${bottomHtml}</div>');function Ci(a,b,c){c=c||10;if(c>a.length)return a;for(var d=[],e=0,f=0,h=0,i=0,j=0;j<a.length;j++){var n=i;i=a.charCodeAt(j);n=i>=768&&!b(n,i,k);if(e>=c&&i>32&&!n){d.push(a.substring(h,j),Di);h=j;e=0}if(f)if(i==62&&f==60)f=0;else{if(i==59&&f==38){f=0;e++}}else if(i==60||i==38)f=i;else if(i<=32)e=0;else e++}d.push(a.substr(h));return d.join("")}function Ei(a,b){return b>=1024&&b<1315}var Fi=H&&J(8),Di=I?"<wbr></wbr>":lb?"&shy;":Fi?"&#8203;":"<wbr>";function Gi(a,b){this.a=a;this.b=X(a);this.c=new Bf(this);this.d=b||30000001}C(Gi,F);s=Gi.prototype;s.G=l;s.U=l;s.m=function(){this.c.D();dc(this.U);this.U&&this.U.D();Gi.n.m.call(this)};s.xe=function(){var a=this.G;a&&a.parentNode&&a.parentNode.removeChild(a)};s.wb=function(){this.U&&this.U.L(m)};var Hi=new U('<div class="cc" style="z-index:${zIndex}"><div class="cc-titlebar"><div class="cc-close" onclick="${closeCallback}();" ></div><div class="cc-title"></div></div><div class="cc-body"></div></div>');var Ii;function Ji(a){var b=Ki["*"]+"?hl="+encodeURIComponent("en")+"&amp;q="+encodeURIComponent(a);if(Ii)b=Ii.replace("{q}",encodeURIComponent(a)).replace("{hl}","en").replace("{googUrl}",encodeURIComponent(b));return b}var Ki={"*":"http://maps.google.com/maps"};var Li=new U('<${wcTag} frameborder=0 ${wcScrolling}src="${wcUrl}" class="wc-root"></${wcTag}>');function Mi(a,b,c,d,e){this.a=b;this.d=e||X();this.Gb=c;this.b=d;d.R(T(this.a.a));M(d,"change",this.jc,m,this);this.ka=a;this.K=new Bf(this);this.e={};this.P=new Gi(ig(this.ka));a:{for(b=0;b<a.p.length;b++)if(a.p[b]===this)break a;a.p.push(this);this.ab(a);this.register();jg(a);a.ra()}}C(Mi,N);s=Mi.prototype;s.Uc="CalendarView";s.Af=m;s.m=function(){this.K.D();Mi.n.m.call(this)};s.Q=q("Gb");s.jc=function(){this.eb()};s.Wc=function(){this.b.navigate(1)};s.Vc=function(){this.b.navigate(-1)};
s.la=function(){return new R(this.b.b,zc(this.b.c))};s.eb=function(){this.P.wb()};s.register=function(){this.Lb=this.K.a(this.Ed)};s.oc=function(a){return this.Af||a.Ka!=2};
s.cc=function(a){var b=[],c=yg(this.a.b,a.M,a.a);$.put("label","When");$.put("value",c);$.put("valueClass","event-when");b.push($.toString());if(c=a.pa){$.put("label","Where");c=Ea(D(c),' (<a href="',Ji(c),'" class="menu-link" target=_blank>map</a>)');$.put("value",c);$.put("valueClass","event-where");b.push($.toString())}if(a=a.va){$.put("label","Description");$.put("value",Ci(a,Ei,15));$.put("valueClass","event-description");b.push($.toString())}return b.join(" ")};
s.Ed=function(a,b){var c=this.e[a],d=this.P,e=de(b),f=D(c.w()),h=c.Qa();if(Rh(h)){var i=Jg(Rh(h)),j=c.M,n=c.a,p=Rh(h);c=h.Q();var o;if(c==1)if(h.Q()!=1)o=l;else{i="http://www.gmodules.com/gadgets/ifr?url="+encodeURIComponent(Rh(h))+"&synd=calendar&w="+Ph(h)+"&h="+h.getHeight()+"&up_startdate="+j.t().toString()+"&up_enddate="+n.t().toString()+"&lang="+"en".replace("_","-");Qh(h);if(j=h.a)for(o in j)if(o.match(af))i+="&up_"+o+"="+encodeURIComponent(j[o]);o=i}else o=i;p=o;Li.put("wcTag",c==3?"img":"iframe");
Li.put("wcScrolling",c==1?'scrolling="no" ':"");Li.put("wcUrl",p);i=Li.toString();Ph(h);h.getHeight();c=document.body;if(c!=d.a){d.G&&d.wb();d.a=c}c=e.left;e=e.top+e.height;o=Ph(h);h=h.getHeight();if(!d.G){Hi.put("closeCallback",d.c.a(d.wb));Hi.put("zIndex",d.d);d.G=Nd(d.b.a,Hi.toString());d.U=new te(d.G);re(d.U);j=d.U;qe(j);j.lc=k;d.U.Rc=m;M(d.U,"beforehide",d.xe,m,d)}d.U.L(m);d.G.style.left="0";d.G.style.top="0";d.a.appendChild(d.G);d.G.style.display="";d.G.style.width=o+"px";d.G.childNodes[1].style.height=
h!=l?h+"px":"";d.G.childNodes[1].innerHTML=i;if(f&&f.length>0){d.G.childNodes[0].childNodes[1].innerHTML=f;d.G.childNodes[0].style.display=""}else d.G.childNodes[0].style.display="none";h=Kd(d.b.a.parentWindow||d.b.a.defaultView||window);f=h.width;i=h.height;j=Zd(d.a);o=d.G.offsetWidth;h=d.G.offsetHeight;c=Math.min(Math.max(c,10),Math.max(f-o-10,10));f=e;e=Math.min(Math.max(e,10),Math.max(i-h-10,10));if(f!=e)c+=16;c-=j.x;e-=j.y;d.G.style.left=c+"px";d.G.style.top=e+"px";d.U.L(k)}};var $=new U('<div class="detail-item"><span class="event-details-label">${label}</span><span class="${valueClass}">${value}</span></div>');
function Ni(a,b,c){var d=a.ka;a.ka.Tc(b,function(e){var f;if(!(f=d.C!=a)){f=a.la();f=!(f.start.f()<=b.start.f()&&f.end.f()>=b.end.f())}f||c(e)})};function Oi(a,b,c){this.c=Math.max(c,1);this.a=a;this.b=b;this.b.push(this.c);this.d=this.a.length}function Pi(a,b,c,d){this.key=a;this.b=b;this.mb=c;this.a=d;this.c=this.mb/this.a}function Qi(a,b,c){return new Pi(a.a[b],a.a[b+1],c,a.b[b+1]-a.b[b]||1)}function Ri(a,b,c){var d=0,e=0;if(b!==undefined){d=Ta(a.a,Ua,b);if(d<0){d=-d-1;if(d==a.d){d--;e=a.c-a.b[d]}}else if(c)e=(a.b[d+1]-a.b[d])*c}return{index:d,mb:e}}Oi.prototype.oa=function(){return!this.d};function Si(a,b,c,d){this.qb=d||28;this.p=a.c.a;this.u=Ti(this,this.p);this.Uc="Agenda";this.F={};this.Z=m;this.c=Ui++;this.Mb=this.Ya=l;this.Y=c;Mi.call(this,a,b,"agenda",new Qe,a.o)}C(Si,Mi);var Ui=1;s=Si.prototype;s.Qb=m;s.Cc=0;s.bb=l;s.Wc=function(){var a=Vi(this).scrollTop+parseInt(Vi(this).style.height,10),b=this.d.J("eventContainer"+this.c).offsetHeight;if(a>=b){this.nb(k);a=b}Wi(this,a)};
s.Vc=function(){var a=Vi(this).scrollTop-parseInt(Vi(this).style.height,10);if(a<=0){this.nb(m);a=0}Wi(this,a)};s.la=function(){return new R(this.p,this.u)};s.bc=function(a){return mg(this.a.b,a)};
s.jc=function(){if(Vi(this))if(!(this.bb&&this.bb.A(this.b.a))){var a=this.b.a,b=T(this.a.a),c=this.la();if(!(c.start.f()<=a.f()&&c.end.f()>a.f())||this.Qb&&a.A(b)&&!this.p.A(b)){a=new R(a,Ti(this,a));this.p=a.start.t();this.u=a.end.t();Ni(this,a,Xi(this,a,m,m,k,k))}else{this.bb=a;if(Yi(this).oa())a=Zi(this);else{b=Yi(this);a=a.H();a=Ri(b,a,void 0);a=Qi(b,a.index,a.mb)}$i(this,a,k,m)}}};s.eb=function(){Si.n.eb.call(this);var a=!this.B;Ni(this,this.la(),Xi(this,this.la(),m,m,m,a))};
function Xi(a,b,c,d,e,f){return function(h){if(!c){var i=ig(a.ka);aj.put("height","200px");aj.put("id",a.c);i.innerHTML=aj.toString();var j=Vi(a);i=parseInt(i.style.height,10);var n=ie(j,"margin"),p=ie(j,"padding");j.style.height=Math.max(1,i-n.top-p.top-n.a-p.a)+"px";bc(a.Ya);a.Ya=M(Vi(a),"scroll",a.hf,m,a)}a.zc(h,b,c,d,f);j=a.a.b;i=a.d.J("agenda-underflow-top"+a.c);bj.put("showingEvents_msg",ba(zg(a.p,j.a)));bj.put("functionName",a.Ib);bj.put("after","false");bj.put("look_msg","Look for earlier events");
i.innerHTML=bj.toString();i=cj(a);bj.put("showingEvents_msg",ca(zg(a.u,j.a)));bj.put("after","true");bj.put("look_msg","Look for more");i.innerHTML=bj.toString();a.Pb(h);if(e)a.jc();else c||$i(a,a.B,k,k)}}
s.zc=function(a,b,c,d,e){this.dispatchEvent("gcvbcc");var f=b.end,h=[],i=b.start;b=this.d;if(!c)this.e={};for(var j=0;j<a.length;j++)this.e[y(a[j])]=a[j];this.Y.nc(this.da,this.Lb);a=e?45:Infinity;for(e=ta(ef,gf);i.f()<f.f()&&a>0;){var n=i;j=[];n=uc(n.f(),zc(n).f());var p=this.e,o=void 0;for(o in p){var r=p[o];n(r.M.f(),r.a.f())&&j.push(r)}j=Ka(j,this.oc,this);j.sort(e);h.push(this.fc(i,j));a-=j.length;i=zc(i)}if(!c||d)this.u=i;i=h.join("");this.dispatchEvent("gcvbid");f=this.d.J("eventContainer"+
this.c);h=I?f.clientHeight:ce(f).height;if(c){b=Nd(b.a,i);d?f.appendChild(b):f.insertBefore(b,f.firstChild)}else f.innerHTML=i;this.g=l;if(c&&!d)Wi(this,Vi(this).scrollTop+((I?f.clientHeight:ce(f).height)-h));this.dispatchEvent("gcvaid")};s.Pb=function(a){if(!this.B)this.B=Zi(this);this.Z=m;this.Y.Ae(a)};
s.fc=function(a,b){var c=b.length;if(!c)return"";for(var d=[],e,f=0;f<c;f++){var h=b[f];e=["event"];if(f==0)e.push("first-event");else f==c-1&&e.push("last-event");d.push(this.Y.wc(h,a,e).toString())}dj.put("dayString",this.bc(a));dj.put("dayId",a.toString());dj.put("events",d.join(""));dj.put("extraClasses","");return dj.toString()};
function Yi(a){if(a.g)return a.g;var b;var c=a.ka.o.a;b="div".toUpperCase();if(c.querySelectorAll&&c.querySelector)b=c.querySelectorAll(b+".day");else if(c.getElementsByClassName){c=c.getElementsByClassName("day");if(b){for(var d={},e=0,f=0,h;h=c[f];f++)if(b==h.nodeName)d[e++]=h;d.length=e;b=d}else b=c}else{c=c.getElementsByTagName(b||"*");d={};for(f=e=0;h=c[f];f++){b=h.className;if(typeof b.split=="function"&&Ia(b.split(/\s+/),"day")>=0)d[e++]=h}d.length=e;b=d}e=[];f=[];for(h=0;h<b.length;h++)if(b[h].style.display!=
"none"){c=b[h].id.substring(4);d=new V(b[h].offsetLeft,b[h].offsetTop);e.push(Sc(c).H());f.push(d.y)}a.g=new Oi(e,f,(new V(cj(a).offsetLeft,cj(a).offsetTop)).y);return a.g}s.register=function(){Si.n.register.call(this);this.da=this.K.a(this.Rd);this.Ib=this.K.a(this.nb)};
s.Rd=function(a){var b=this.d.J("details-"+a.id),c=a.id.substring(0,a.id.lastIndexOf("-"));if(this.F[c]){delete this.F[c];ej(this,b,a,m)}else{if(!b.firstChild){var d=this.e[c],e=this.cc(d),f=d.Ja;if(!d.Qa()&&f){fj.put("links",this.dc(d));e+=fj.toString()}gj.put("details",e);for(b.innerHTML="<pre>"+gj.toString()+"</pre>";b.firstChild.firstChild;)b.appendChild(b.firstChild.firstChild);b.removeChild(b.firstChild);ej(this,b,a,k);this.F[c]=1;this.g=l;return}ej(this,b,a,k);this.F[c]=1}this.g=l};
s.dc=function(a){return'<a href="'+encodeURI(a.Ja)+'" target="_blank">more details&raquo;</a>&nbsp;&nbsp;<a href="'+Ng(this.a.c,a.w(),new R(a.M,a.a),a.pa,a.va)+'" target="_blank">copy to my calendar</a>'};function ej(a,b,c,d){ee(b,d);d?Yc(c,"event-summary","event-summary-expanded"):Yc(c,"event-summary-expanded","event-summary")}function Wi(a,b){Vi(a).scrollTop=Math.round(b)}function Zi(a){return new Pi(a.b.a.H(),undefined,0,1)}
function $i(a,b,c,d){a.B=b;if(c){c=Yi(a);var e=Ri(c,b.key,b.c);c=Math.min(Math.max(c.b[e.index]+e.mb,c.b[0]),c.c);Wi(a,c);a.Cc=c}if(d){b=Jc(b.b&&b.a-b.mb<30?b.b:b.key);a.bb=b;a.b.R(b)}}
s.hf=function(){var a=Vi(this),b=a.scrollTop,c=this.d.J("agendaScrollContent"+this.c).offsetHeight;if(c!=0){if(b+a.clientHeight>=c)this.nb(k);else b==0&&this.nb(m);if(Math.abs(this.Cc-b)>5){if(Yi(this).oa())a=Zi(this);else{a=Yi(this);c=Math.min(Math.max(b,a.b[0]),a.c);var d=Ta(a.b,Ua,c);if(d<0)d=-d-2;else d==a.d&&d&&d--;a=Qi(a,d,c-a.b[d])}$i(this,a,m,k);this.Cc=b}}};
s.nb=function(a){if(!(this.Qb&&!a))if(!this.Z){this.Z=k;var b=this.la();if(a){var c=b.end;this.u=b=Ti(this,b.end)}else{c=Ti(this,b.start,k);b=b.start;this.p=c}c=new R(c,b);Ni(this,c,Xi(this,c,k,a,m,a))}};function Ti(a,b,c){c=c?-1:1;b=Bc(b,c*a.qb);a=b.k;var d=b.i,e=Ac(a,d,15);return b=c<0?e.f()<=b.f()?e:Ac(a,d,1):e.f()>=b.f()?e:Ac(a,d,nc(a,d))}function Vi(a){return a.d.J("agendaEventContainer"+a.c)}function cj(a){return a.d.J("agenda-underflow-bottom"+a.c)}
var gj=new U('<div class="event-details-inner">${details}</div>'),fj=new U('<div class="event-links">${links}</div>'),dj=new U('<div class="day ${extraClasses}" id="day-${dayId}"><div class="date-label">${dayString}</div>${events}</div>'),bj=new U('${showingEvents_msg}. <span class="agenda-more" onclick="${functionName}(${after});">${look_msg}</span>'),aj=new U('<div id="agenda${id}" class="agenda-scrollboxBoundary agenda"><div id="agendaEventContainer${id}" class="scrollbox" style="height:${height};position:relative">'+
we+'<div id="agendaScrollContent${id}" style="position:relative"><div id="agenda-underflow-top${id}" class="underflow-top"> </div><div id="eventContainer${id}"> </div></div>'+xe+'<div id="agenda-underflow-bottom${id}"  class="underflow-bot" style="height:100%"> </div></div></div>');function hj(a){var b=[],c=a.a,d;for(d in c){var e=c[d].slice().sort(function(f,h){return f-h});b.push(d+": "+e.join(", "))}b.push("\nreset?");if(confirm(b.join("\n")))a.a={}};function ij(){this.a={}}(function(a){a.Sf=function(){return a.lf||(a.lf=new a)}})(ij);var jj=/\W/g;ij.prototype.log=function(a,b){if(!(b<0||b>6E5)){var c=a.replace(jj,"_");c in this.a||(this.a[c]=[]);this.a[c].push(b)}};function kj(a){this.c=a;this.a=this.b=B()};function lj(a,b,c,d){if(!Ya(a.a)){var e=lj.a+"=",f=encodeURIComponent,h=[];c=c||"";b=b||"";for(var i in a.a){h.push(b+i+c);h.push(a.a[i].join("#"))}(d||yh)(lj.b,l,"POST",e+f(h.join(":")));a.a={}}}lj.a="perf";lj.b="perf";function mj(a,b,c){this.d=a;this.c=b;this.b=c;this.a=z(this.vf,this)}C(mj,F);s=mj.prototype;s.Eb=m;s.Jd=0;s.Ra=l;s.m=function(){mj.n.m.call(this);if(this.Ra){ne.clearTimeout(this.Ra);this.Ra=l;this.Eb=m}};s.vf=function(){this.Ra=l;if(this.Eb&&!this.Jd){this.Eb=m;nj(this)}};function nj(a){a.Ra=oe(a.a,a.c);a.d.call(a.b)};function oj(a,b,c){this.ea=a;this.a=b;this.c=new ud(this);if(c||Math.random()<0.05){S(this.c,this.a,"gcvbcc",this.d);S(this.c,this.a,["gcvbid","gcvaid"],this.e)}pj(this)}C(oj,F);oj.prototype.m=function(){this.c.D()};function pj(a){var b=t.gcal$perf$serverTime,c=t.gcal$perf$headStartTime;if(b!==undefined&&c!==undefined){a.ea.log("container",B()-c+b);$b(a.a,"gcvaid",function(d){var e=B()-c;this.ea.log(d.target.Q()+"_loadTime",e);this.ea.log(d.target.Q()+"_totalLoadTime",e+b)},m,a)}}
oj.prototype.d=function(){this.b=new kj(this.ea)};oj.prototype.e=function(a){if(this.b){var b=a.type=="gcvaid",c=this.b,d=a.target.Q()+"_"+(b?"insertDom":"computeContent")||c.d,e=B();c.c.log(d,e-c.a);c.a=e;if(b){b=this.b;a=a.target.Q()+"_render"||b.d;c=B();b.c.log(a,c-b.b);b.a=c;this.b=l}}};function qj(a){pg=new qg(a.features);this.data=a;this.b=new Og(a);og.goog$calendar$GdataCalendar=new di}C(qj,F);s=qj.prototype;s.ea=l;
s.Na=function(){var a=this.data,b=Y(a.ka||"container"),c=this.b.u;if(c=c&&c.c)Ii=c;if(H)try{document.execCommand("BackgroundImageCache",m,k)}catch(d){}this.e=new Sg;this.g=new pf;var e=this.b.c.e+"/";c=a.preloadStart;var f=a.preloadEnd;if(c&&f)this.d=new R(Sc(c),Sc(f));c=og[a.calendarFactoryClass||"goog$calendar$GdataCalendar"]||l;c.init(this.b,this.e,e);e=this.g;f=a.cids||{};e.ja();for(var h in f){var i=f[h],j=this.d,n=i.color,p=i.gdata&&i.gdata[c.b.hd()],o=p?c.b.w(p):i.title;i=ei(c,h,i.access||
0,n?Ie(n):undefined,o);if(p){n=i;o=p;p=ai(n,n.a.dd(o));o=n.a.ld(o);for(var r=p.length-1;r>=0;--r){var u=p[r],O=n;u.ub=O;u.b=O.z()}mf(n.c,n.z(),p,j,o)}n=f[h].hidden;e.vb(new nf(i),n)}e.Ma();if(a.skin)b.className=b.className+" "+a.skin;b.style.position="relative";this.Ac(b);rj(this,b);this.a=this.Nc(b,a);this.ea=new ij;this.K=new oj(this.ea,this.a);if(Jf()){a=ta(lj,this.ea,window.location.pathname.substr(window.location.pathname.lastIndexOf("/")+1)+"_",void 0,void 0);window.setTimeout(a,3E5);window.setInterval(a,
36E5)}a=T(this.b.a);if(this.d&&!this.d.contains(a))a=this.d.start;this.a.navigate(a);a=this.a;b=this.data.showExpiredEvents;b!==undefined||(b=k);this.ue=new sj(a,this.b,!!this.data.showEmptyDays,b,this.Ub());this.a.Pd(this.data.view);ua("_ShowPerf",ta(hj,this.ea))};s.Mc=function(){var a=Y("calendarTitle");a=a?a.offsetHeight:0;var b=Y("warningBox");if(b)a+=b.offsetHeight;return a};function rj(a,b){var c=z(a.Ac,a,b),d=new mj(c,100);M(window,"resize",function(){if(!d.Ra&&!d.Jd)nj(d);else d.Eb=k})}
s.Ac=function(a,b){if(this.b.B){var c=this.Mc(),d;d=X(a);d=d.a.parentWindow||d.a.defaultView;d=b||Kd(d||window).height;if(this.B!=d){c=d-c;if(c<=0)c=1;a.style.height=c+"px";this.a&&this.a.ra();this.B=d}}};s.Nc=function(a,b){return new Tf(a,this.b,this.e,this.g,b)};function tj(){}tj.prototype.a=function(){return De()[Je()]||l};function uj(){}C(uj,tj);uj.prototype.a=function(a){return a.N().ya()};Ki={cn:"http://ditu.google.cn/maps",ad:"http://maps.google.ad/maps",at:"http://maps.google.at/maps",ba:"http://maps.google.ba/maps",be:"http://maps.google.be/maps",bg:"http://maps.google.bg/maps",bi:"http://maps.google.bi/maps",bj:"http://maps.google.bj/maps",ca:"http://maps.google.ca/maps",cd:"http://maps.google.cd/maps",cf:"http://maps.google.cf/maps",cg:"http://maps.google.cg/maps",ch:"http://maps.google.ch/maps",ci:"http://maps.google.ci/maps",cl:"http://maps.google.cl/maps",ao:"http://maps.google.it.ao/maps",
bw:"http://maps.google.co.bw/maps",id:"http://maps.google.co.id/maps",jp:"http://maps.google.co.jp/maps",ke:"http://maps.google.co.ke/maps",kr:"http://maps.google.co.kr/maps",ma:"http://maps.google.co.ma/maps",mz:"http://maps.google.co.mz/maps",nz:"http://maps.google.co.nz/maps",th:"http://maps.google.co.th/maps",tz:"http://maps.google.co.tz/maps",ug:"http://maps.google.co.ug/maps",gb:"http://maps.google.co.uk/maps",za:"http://maps.google.co.za/maps",zm:"http://maps.google.co.zm/maps",zw:"http://maps.google.co.zw/maps",
ar:"http://maps.google.com.ar/maps",au:"http://maps.google.com.au/maps",bh:"http://maps.google.com.bh/maps",br:"http://maps.google.com.br/maps",et:"http://maps.google.com.et/maps",gh:"http://maps.google.com.gh/maps",hk:"http://maps.google.com.hk/maps",kw:"http://maps.google.com.kw/maps",lb:"http://maps.google.com.lb/maps",ly:"http://maps.google.com.ly/maps",mt:"http://maps.google.com.mt/maps",mx:"http://maps.google.com.mx/maps",my:"http://maps.google.com.my/maps",na:"http://maps.google.com.na/maps",
ng:"http://maps.google.com.ng/maps",om:"http://maps.google.com.om/maps",qa:"http://maps.google.com.qa/maps",sa:"http://maps.google.com.sa/maps",sg:"http://maps.google.com.sg/maps",sl:"http://maps.google.com.sl/maps",tw:"http://maps.google.com.tw/maps",ua:"http://maps.google.com.ua/maps",cz:"http://maps.google.cz/maps",de:"http://maps.google.de/maps",dj:"http://maps.google.dj/maps",dk:"http://maps.google.dk/maps",dz:"http://maps.google.dz/maps",ee:"http://maps.google.ee/maps",es:"http://maps.google.es/maps",
fi:"http://maps.google.fi/maps",fr:"http://maps.google.fr/maps",ga:"http://maps.google.ga/maps",gm:"http://maps.google.gm/maps",gr:"http://maps.google.gr/maps",hr:"http://maps.google.hr/maps",hu:"http://maps.google.hu/maps",ie:"http://maps.google.ie/maps",is:"http://maps.google.is/maps",it:"http://maps.google.it/maps",li:"http://maps.google.li/maps",lt:"http://maps.google.lt/maps",lu:"http://maps.google.lu/maps",lv:"http://maps.google.lv/maps",md:"http://maps.google.md/maps",me:"http://maps.google.me/maps",
mg:"http://maps.google.mg/maps",mk:"http://maps.google.mk/maps",mu:"http://maps.google.mu/maps",mw:"http://maps.google.mw/maps",nl:"http://maps.google.nl/maps",no:"http://maps.google.no/maps",pl:"http://maps.google.pl/maps",pt:"http://maps.google.pt/maps",ro:"http://maps.google.ro/maps",rs:"http://maps.google.rs/maps",ru:"http://maps.google.ru/maps",rw:"http://maps.google.rw/maps",sc:"http://maps.google.sc/maps",se:"http://maps.google.se/maps",si:"http://maps.google.si/maps",sk:"http://maps.google.sk/maps",
sn:"http://maps.google.sn/maps",st:"http://maps.google.st/maps",td:"http://maps.google.td/maps",tg:"http://maps.google.tg/maps","*":"http://maps.google.com/maps"};function vj(){};function sj(a,b,c,d,e,f){Si.call(this,a,b,e,f);M(this.a.a,"newday",this.pf,m,this);this.rb=c;this.j=d;this.Xa=b.a}C(sj,Si);sj.prototype.Qb=k;sj.prototype.j=k;sj.prototype.$a=k;var wj=window;s=sj.prototype;s.yc=l;s.Wa=l;s.pf=function(){this.b.R(T(this.a.a))};
s.bc=function(a){var b=xj,c=mg(this.a.b,a,k,k),d=T(this.a.a),e=undefined;if(a.A(d))e="Today";else if(a.A(zc(d)))e="Tomorrow";if(e&&this.$a)c=Ea(e,' <span class="date-parentheses">(',c,")</span>");b.put("date",c);a=b.toString();if(e&&!this.$a){b=yj;b.put("marker",e);a+=b}return a};s.oc=function(a){var b=Cg(this.a.a);return sj.n.oc.call(this,a)&&(this.j||a.a.f()>=b.f())};
s.fc=function(a,b){var c=a.f()==T(this.a.a).f();dj.put("extraClasses",c?"today":"");if(b.length==0&&this.rb){c='<div class="no-events">'+("No events on "+zg(a,this.a.b.a))+"</div>";dj.put("dayString",this.bc(a));dj.put("dayId",a.toString());dj.put("events",c);return dj.toString()}return sj.n.fc.call(this,a,b)};
s.zc=function(a,b,c,d,e){wj.clearTimeout(this.yc);this.yc=this.Wa=l;for(var f=Cg(this.Xa),h=a.length,i=0;i<h;++i){var j=a[i];if(j.M.f()>f.f())zj(this,j.M.t());else j.a.f()>f.f()&&zj(this,j.a.t())}sj.n.zc.call(this,a,b,c,d,e)};s.Pb=function(a){sj.n.Pb.call(this,a);if(this.Wa){a=Lc(wc(this.Wa,Cg(this.Xa)));a=Math.min(Math.max(a+3,60),86400);this.yc=wj.setTimeout(z(this.eb,this),a*1E3)}};
s.Rd=function(a){var b=a.id.substring(0,a.id.lastIndexOf("-"));a=Sc(a.id.substring(a.id.lastIndexOf("-")+1));var c=this.e[b];if(!c.Qa()){this.bb=a;this.b.R(a);b=this.cc(c);a=this.ka;c=this.dc(c);var d=Ai(a);d.innerHTML=b;wi(a,c);si(a,d);(b=Y("hideDetailsLink"+this.c))&&M(b,"mousedown",this.kf,m,this)}};s.Ed=v;
s.cc=function(a){var b=[],c=this.a.b,d=a.N().ya();b.push('<div class="event-details-container">');b.push('<div class="event details-title" style="color:',d.a,'">',a.w(),"</div>");c=yg(c,a.M,a.a);b.push('<div class="event-when">',c,"</div>");(c=a.pa)&&b.push('<div class="event-where">',D(c),' - <a href="',Ji(c),'" class="menu-link" target=_blank>map</a>',"</div>");if(a=a.va){a=Ci(a,Ei,15);b.push('<div class="event-details-label">Description</div><pre class="event-description">',a,"</pre>")}b.push("</div>");
return b.join("")};s.dc=function(a){var b=['<div class="event-links"><span class="menu-link" id="hideDetailsLink',this.c,'" style="float:left">&laquo;&nbsp;back</span>'];a=Jg(a.Ja);var c=Lg();if(!(!a||!Ig(a)||Kg(a)||c==l)){var d=a.split("/calendar");a=d.length>2?a:d.join("/calendar/b/"+c)}a&&b.push('<a class="menu-link" style="float:right" href="',D(encodeURI(a)),'" target="_blank">more details&nbsp;&raquo;</a>');b.push('<div style="clear:both"></div>',"</div>");return b.join("")};
s.kf=function(a,b){var c=Y("hideDetailsLink"+this.c);c&&dc(c);c=this.ka;xi(c);ui(c);a&&a.Aa();b||$i(this,this.B,k,k)};function zj(a,b){b=b.ha();if(!a.Wa||a.Wa.f()>b.f())a.Wa=b}var xj=new U('<span class="date-content">${date}</span>'),yj=new U('<span class="date-marker">${marker}</span>');var Aj=/<[^>]*>|&[^;]+;/g;function Bj(a,b){return b?a.replace(Aj," "):a}
var Cj=RegExp("[\u0591-\u07ff\ufb1d-\ufdff\ufe70-\ufefc]"),Dj=RegExp("[A-Za-z\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u02b8\u0300-\u0590\u0800-\u1fff\u2c00-\ufb1c\ufe00-\ufe6f\ufefd-\uffff]"),Ej=RegExp("^[^A-Za-z\u00c0-\u00d6\u00d8-\u00f6\u00f8-\u02b8\u0300-\u0590\u0800-\u1fff\u2c00-\ufb1c\ufe00-\ufe6f\ufefd-\uffff]*[\u0591-\u07ff\ufb1d-\ufdff\ufe70-\ufefc]"),Fj=/^http:\/\/.*/,Gj=/(\(.*?\)+)|(\[.*?\]+)|(\{.*?\}+)|(<.*?>+)/g,Hj=/\s+/,Ij=/\d/;function Jj(a){for(var b=0,c=0,d=m,e=Bj(a,void 0).split(Hj),f=0;f<e.length;f++){var h=e[f];if(Ej.test(Bj(h,void 0))){b++;c++}else if(Fj.test(h))d=k;else if(Dj.test(Bj(h,void 0)))c++;else if(Ij.test(h))d=k}if((c==0?d?1:0:b/c>0.4?-1:1)==-1)a=a.charAt(0)=="<"?a.replace(/<\w+/,"$& dir=rtl"):"\n<span dir=rtl>"+a+"</span>";return a}function Kj(a){if(Cj.test(Bj(a,void 0))){var b=Cj.test(Bj(a,void 0))?"\u200f":"\u200e";a="\u202b"+a.replace(Gj,b+"$&"+b)+"\u202c"}return a};function Lj(a,b){this.a=a;this.b=b}C(Lj,vj);s=Lj.prototype;s.Ia=m;s.nc=function(a,b){this.da=a;this.e=b};s.Ae=v;
s.wc=function(a,b,c){var d=this.ze;d.put("toggleDetails",this.da);var e=a.Qa(),f;if(f=e)f=e.Zb?k:m;if(f){f=this.Gf;f.put("wc_icon_src",D(e.Zb));f.put("wc_title",D(e.w()));f.put("wc_listener",' onclick="'+this.e+"("+y(a)+', this);"');d.put("webContent",f.toString());c.push("web-content")}else d.put("webContent","");d.put("event_classes",c.join(" "));d.put("eventDuration",yg(this.a,a.M,a.a));c=m;if(a.c){e="All day";c=k}else{e=a.M.t();f=a.a.t();if(a.d||e!==f)if(e===b)e=xg(this.a,a.M,this.Ia,this.Ia);
else if(f===b)e=this.Fe+xg(this.a,a.a,this.Ia,this.Ia);else{e="All day";c=k}else e=xg(this.a,a.M,this.Ia,this.Ia)}d.put("start_time",e);d.put("allday",c?"all-day":"");d.put("title",Jj(!a.w()||a.w().match(/^\s*$/)?"(No title)":Kj(a.w())));d.put("titleColor",this.b.a(a).a);d.put("divId",y(a)+"-"+b);return d};s.ze=new U('<div class="${event_classes}"><div class="${allday} event-summary" id="${divId}" onmousedown="${toggleDetails}(this);return false;"><span class="event-time" alt="${eventDuration}"title="${eventDuration}">${start_time}</span><div class="title-wrapper"><span class="event-reply-status">&nbsp;</span><span class="event-title" style="color: ${titleColor};">${webContent}${title}</span></div></div><div class="event-details" id="details-${divId}"></div></div>');
s.Gf=new U('<span ${wc_listener} class="agenda-wc"><img src="${wc_icon_src}"class="agenda-web-content" title="${wc_title}" alt="${wc_title}"></span>');s.Fe="&raquo;&nbsp;";function Mj(a,b,c){Lj.call(this,a,b);this.d=c;this.c=Cg(c)}C(Mj,Lj);Mj.prototype.wc=function(a,b,c){b=Lj.prototype.wc.call(this,a,b,c);var d=this.c;if(a.a.f()<=d.f()){c.push("expired");b.put("event_classes",c.join(" "));b.put("titleColor",this.b.a(a).c)}else{a=a.M;if(!isNaN(a.q)){d=Pc(d.k,d.i,d.h,d.q,d.s+10,d.v);if(a.f()<=d.f()){c.push("active");b.put("event_classes",c.join(" "))}}}return b};Mj.prototype.nc=function(a,b){Mj.n.nc.call(this,a,b);this.c=Cg(this.d)};function Nj(a){qj.call(this,a)}C(Nj,qj);s=Nj.prototype;s.ue=l;s.Ic=200;s.Ub=function(){return new Mj(this.b.b,new uj,this.b.a)};s.Na=function(){var a=this.data;this.u=a.email;this.p=!!(this.u&&!a.noAgenda);this.F=a.iframeHeight||this.Ic;this.p&&Nj.n.Na.call(this);if(a.noDatepicker){this.a.Td();this.a.ra()}a.hideExpiredEvents&&this.a.Sd();ua("_afterLazyLoad",z(this.Ob,this));M(this.a,"prefs_changed",this.Nd,m,this)};
s.Ob=function(){this.Ld();M(this.a,"height_changed",this.Ld,m,this);var a=ja("gadgets.Prefs")||ja("_IG_Prefs");if(a){this.j=new a;if(a=this.data.initialPrefs){this.Nd();if(this.j&&a)for(var b in a)this.j.set(b,a[b])}}};s.Ld=function(){var a=window._IG_AdjustIFrameHeight;if(a){var b=this.a,c=b.yb();if(this.p)c+=this.F;a(c);this.Ac(b.d,c)}};
s.Nd=function(){var a=this.j;if(a){for(var b=this.a.S,c=G(b.b),d=[],e=[],f=0;f<c.length;++f){var h=c[f];d.push(Qf(h));h=b.fb(h);e.push((h?h.N():l).ya().a)}b="("+e.join(",")+")";a.set("calendarFeeds","("+d.join(",")+")");a.set("calendarColors",b);a.set("showDatepicker",qi(this.a));a.set("showExpiredEvents",this.a.C.j)}};s.Nc=function(a,b){return new ii(a,this.b,this.e,this.g,this.u,b)};s.Mc=aa(0);ua("_init",function(a){(new Nj(a)).Na()});var Oj=v;function Pj(a){(a||window).location.reload(k)};function Qj(a,b){this.c=a;this.a=b}Qj.prototype.V=q("c");Qj.prototype.T=function(){return new Qj(this.c,this.a)};function Rj(a){this.a=[];if(a)a:{var b,c;if(a instanceof Rj){b=a.xa();c=a.Pa();if(a.ac()<=0){a=this.a;for(var d=0;d<b.length;d++)a.push(new Qj(b[d],c[d]));break a}}else{b=G(a);c=Xa(a)}for(d=0;d<b.length;d++)Sj(this,b[d],c[d])}}function Sj(a,b,c){var d=a.a;d.push(new Qj(b,c));b=d.length-1;a=a.a;for(c=a[b];b>0;){d=Math.floor((b-1)/2);if(a[d].V()>c.V()){a[b]=a[d];b=d}else break}a[b]=c}
function Tj(a){var b=a.a,c=b.length,d=b[0];if(!(c<=0)){if(c==1)Ma(b);else{b[0]=b.pop();b=0;a=a.a;c=a.length;for(var e=a[b];b<Math.floor(c/2);){var f=b*2+1,h=b*2+2;f=h<c&&a[h].V()<a[f].V()?h:f;if(a[f].V()>e.V())break;a[b]=a[f];b=f}a[b]=e}return d.a}}function Uj(a){a=a.a;if(a.length!=0)return a[0].a}s=Rj.prototype;s.Pa=function(){for(var a=this.a,b=[],c=a.length,d=0;d<c;d++)b.push(a[d].a);return b};s.xa=function(){for(var a=this.a,b=[],c=a.length,d=0;d<c;d++)b.push(a[d].V());return b};s.T=function(){return new Rj(this)};
s.ac=function(){return this.a.length};s.oa=function(){return this.a.length==0};s.clear=function(){Ma(this.a)};function Vj(a,b){this.Rb=a;this.dateTime=b}function Wj(a,b){K.call(this,"eventreminder",a);this.b=b}C(Wj,K);function Xj(a){this.a=new Rj;this.b={};this.e=a;this.c=Cg(a)}C(Xj,N);Xj.prototype.d=l;var Yj=window;
Xj.prototype.g=function(){if(!this.a.oa()){var a=Cg(this.e),b=xc(a);b.v-=120;b=b.ha();var c=this.c.max(b);b=[];for(var d;!this.a.oa();){d=Uj(this.a);var e=d.Rb.z()+":"+d.dateTime.toString();if(d.dateTime.f()<=c.f()){Tj(this.a);delete this.b[e]}else if(d.dateTime.f()<=a.f()){b.push(Tj(this.a));delete this.b[e]}else{c=Lc(wc(d.dateTime,a));Zj(this,c);break}}for(c=0;c<b.length;++c)this.dispatchEvent(new Wj(this,b[c]));this.c=a}};
function Zj(a,b){a.d!==l&&Yj.clearTimeout(a.d);a.d=b!==undefined?Yj.setTimeout(z(a.g,a),Math.min(b*1E3,36E5)):l};function $j(a,b,c){this.d=a;this.c=b;this.a=c;this.b=new ud(this);S(this.b,this.d,"a",this.e);S(this.b,this.a,"newday",this.e);this.e()}C($j,F);$j.prototype.m=function(){this.b.D();$j.n.m.call(this)};
$j.prototype.e=function(){var a=G(this.d.b),b=this.c;b.a.clear();b.b={};Zj(b);var c=T(this.a);b=this.d;c=new R(c,Bc(c,60));for(var d=[],e=0;e<a.length;++e)d.push(Rg(b.a[a[e]],c));a=Xg(b,d);b=zc(T(this.a));for(c=a.length;c--;){d=a[c];if(d.Ka!=2){e=d.g;for(var f=e.length;f--;)if(e[f].f()<b.f()){var h=this.c,i=e[f],j=new Vj(d,i),n=j.Rb.z()+":"+j.dateTime.toString();if(!(n in h.b))if(h.c.f()<i.f()){Sj(h.a,i.f(),j);h.b[n]=j;i=Lc(wc(Uj(h.a).dateTime,Cg(h.e)));Zj(h,Math.max(i,0))}}}}};function ak(){}C(ak,N);function bk(){var a=ja("gadgets.rpc");a||g(Error("gadgets.rpc not provided in global namespace."));this.call=a.call;this.register=a.register;this.registerDefault=a.registerDefault;this.unregister=a.unregister;this.unregisterDefault=a.unregisterDefault}s=bk.prototype;s.call=v;s.register=v;s.registerDefault=v;s.unregister=v;s.unregisterDefault=v;function ck(a){this.a=a||new bk;this.b=0}C(ck,ak);function dk(){this.b="gm_ntfctn_"+ek++;this.a=[]}var ek=0;s=dk.prototype;s.od="";s.Ef="";s.nd="";s.Je="";s.setTitle=function(a){this.od=a;return this};function fk(a){qj.call(this,a)}C(fk,Nj);s=fk.prototype;s.hc=l;s.Ic=180;s.Ub=function(){var a=fk.n.Ub.call(this);a.Ia=k;return a};s.Na=function(){this.data.pingInterval=6E5;fk.n.Na.call(this);if(this.p){this.c=new Xj(this.b.a);M(this.c,"eventreminder",this.gf,m,this);this.P=new $j(this.e,this.c,this.b.a)}};
s.Ob=function(){var a=ja("gadgets.config"),b=m;if(a){a.init({rpc:{parentRelayUrl:"/rpc_relay.html",useLegacyProtocol:m}},k);if(a=ja("gadgets.rpc.call")){gadgets.rpc.forceParentVerifiable();var c=gadgets.rpc.getRelayUrl("..").match(Te)[3]||l;if((c&&decodeURIComponent(c))=="mail.google.com"){Oj=a;b=k}else gadgets.rpc=v}}if(b){Oj(l,"gadget-loaded");this.hc=new ck}fk.n.Ob.call(this)};
s.gf=function(a){if(this.hc){a=a.b.Rb;var b=a.M,c;if(isNaN(b.q)){c=rg[b.wa()];b=zg(b,this.b.b.a);c=""+c+" "+b}else c=xg(this.b.b,b);b=a.N().w();var d;d=a.w();if(d.indexOf("&")!=-1)if("document"in t&&d.indexOf("<")==-1){var e=t.document.createElement("div");e.innerHTML="<pre>x"+d+"</pre>";e.firstChild.normalize&&e.firstChild.normalize();d=e.firstChild.firstChild.nodeValue.slice(1);e.innerHTML="";d=d.replace(/(\r\n|\r|\n)/g,"\n")}else d=Da(d);c=(e=a.pa)?""+d+" ("+b+") - "+c+" - "+e+".":""+d+" ("+b+
") - "+c+".";b=new dk;b.nd=c;b.a.push({text:"View event",action:a.Ja});this.hc.a.call(l,"gm-notification",l,{id:b.b,title:b.od,subtitle:b.Ef,description:b.nd,icon:b.Je,actions:b.a})}};ua("_init",function(a){a.xsrftok&&oe(Pj,Math.abs(20)*36E5+Math.floor(Math.random()*Math.abs(3)*36E5));(new fk(a)).Na()});
var gadgets={};
var shindig={};;
gadgets.config=function(){var A=[];
return{register:function(D,C,B){var E=A[D];
if(!E){E=[];
A[D]=E
}E.push({validators:C||{},callback:B})
},get:function(B){if(B){return configuration[B]||{}
}return configuration
},init:function(D,K){configuration=D;
for(var B in A){if(A.hasOwnProperty(B)){var C=A[B],H=D[B];
for(var G=0,F=C.length;
G<F;
++G){var I=C[G];
if(H&&!K){var E=I.validators;
for(var J in E){if(E.hasOwnProperty(J)){if(!E[J](H[J])){throw new Error('Invalid config value "'+H[J]+'" for parameter "'+J+'" in component "'+B+'"')
}}}}if(I.callback){I.callback(D)
}}}}},EnumValidator:function(E){var D=[];
if(arguments.length>1){for(var C=0,B;
(B=arguments[C]);
++C){D.push(B)
}}else{D=E
}return function(G){for(var F=0,H;
(H=D[F]);
++F){if(G===D[F]){return true
}}}
},RegExValidator:function(B){return function(C){return B.test(C)
}
},ExistsValidator:function(B){return typeof B!=="undefined"
},NonEmptyStringValidator:function(B){return typeof B==="string"&&B.length>0
},BooleanValidator:function(B){return typeof B==="boolean"
},LikeValidator:function(B){return function(D){for(var E in B){if(B.hasOwnProperty(E)){var C=B[E];
if(!C(D[E])){return false
}}}return true
}
}}
}();;
gadgets.log=function(A){gadgets.log.logAtLevel(gadgets.log.INFO,A)
};
gadgets.warn=function(A){gadgets.log.logAtLevel(gadgets.log.WARNING,A)
};
gadgets.error=function(A){gadgets.log.logAtLevel(gadgets.log.ERROR,A)
};
gadgets.setLogLevel=function(A){gadgets.log.logLevelThreshold_=A
};
gadgets.log.logAtLevel=function(D,C){if(D<gadgets.log.logLevelThreshold_||!gadgets.log._console){return 
}var B;
var A=gadgets.log._console;
if(D==gadgets.log.WARNING&&A.warn){A.warn(C)
}else{if(D==gadgets.log.ERROR&&A.error){A.error(C)
}else{if(A.log){A.log(C)
}}}};
gadgets.log.INFO=1;
gadgets.log.WARNING=2;
gadgets.log.NONE=4;
gadgets.log.logLevelThreshold_=gadgets.log.INFO;
gadgets.log._console=window.console?window.console:window.opera?window.opera.postError:undefined;;
var tamings___=tamings___||[];
tamings___.push(function(A){___.grantRead(gadgets.log,"INFO");
___.grantRead(gadgets.log,"WARNING");
___.grantRead(gadgets.log,"ERROR");
___.grantRead(gadgets.log,"NONE");
caja___.whitelistFuncs([[gadgets,"log"],[gadgets,"warn"],[gadgets,"error"],[gadgets,"setLogLevel"],[gadgets.log,"logAtLevel"]])
});;
if(window.JSON&&window.JSON.parse&&window.JSON.stringify){gadgets.json={parse:function(B){try{return window.JSON.parse(B)
}catch(A){return false
}},stringify:function(B){try{return window.JSON.stringify(B)
}catch(A){return null
}}}
}else{gadgets.json=function(){function f(n){return n<10?"0"+n:n
}Date.prototype.toJSON=function(){return[this.getUTCFullYear(),"-",f(this.getUTCMonth()+1),"-",f(this.getUTCDate()),"T",f(this.getUTCHours()),":",f(this.getUTCMinutes()),":",f(this.getUTCSeconds()),"Z"].join("")
};
var m={"\b":"\\b","\t":"\\t","\n":"\\n","\f":"\\f","\r":"\\r",'"':'\\"',"\\":"\\\\"};
function stringify(value){var a,i,k,l,r=/["\\\x00-\x1f\x7f-\x9f]/g,v;
switch(typeof value){case"string":return r.test(value)?'"'+value.replace(r,function(a){var c=m[a];
if(c){return c
}c=a.charCodeAt();
return"\\u00"+Math.floor(c/16).toString(16)+(c%16).toString(16)
})+'"':'"'+value+'"';
case"number":return isFinite(value)?String(value):"null";
case"boolean":case"null":return String(value);
case"object":if(!value){return"null"
}a=[];
if(typeof value.length==="number"&&!value.propertyIsEnumerable("length")){l=value.length;
for(i=0;
i<l;
i+=1){a.push(stringify(value[i])||"null")
}return"["+a.join(",")+"]"
}for(k in value){if(k.match("___$")){continue
}if(value.hasOwnProperty(k)){if(typeof k==="string"){v=stringify(value[k]);
if(v){a.push(stringify(k)+":"+v)
}}}}return"{"+a.join(",")+"}"
}}return{stringify:stringify,parse:function(text){if(/^[\],:{}\s]*$/.test(text.replace(/\\["\\\/b-u]/g,"@").replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,"]").replace(/(?:^|:|,)(?:\s*\[)+/g,""))){return eval("("+text+")")
}return false
}}
}()
};;
var tamings___=tamings___||[];
tamings___.push(function(A){caja___.whitelistFuncs([[gadgets.json,"parse"],[gadgets.json,"stringify"]])
});;
gadgets.util=function(){function G(L){var M;
var K=L;
var I=K.indexOf("?");
var J=K.indexOf("#");
if(J===-1){M=K.substr(I+1)
}else{M=[K.substr(I+1,J-I-1),"&",K.substr(J+1)].join("")
}return M.split("&")
}var E=null;
var D={};
var C={};
var F=[];
var A={0:false,10:true,13:true,34:true,39:true,60:true,62:true,92:true,8232:true,8233:true};
function B(I,J){return String.fromCharCode(J)
}function H(I){D=I["core.util"]||{}
}if(gadgets.config){gadgets.config.register("core.util",null,H)
}return{getUrlParameters:function(Q){if(E!==null&&typeof Q==="undefined"){return E
}var M={};
E={};
var J=G(Q||document.location.href);
var O=window.decodeURIComponent?decodeURIComponent:unescape;
for(var L=0,K=J.length;
L<K;
++L){var N=J[L].indexOf("=");
if(N===-1){continue
}var I=J[L].substring(0,N);
var P=J[L].substring(N+1);
P=P.replace(/\+/g," ");
M[I]=O(P)
}if(typeof Q==="undefined"){E=M
}return M
},makeClosure:function(L,N,M){var K=[];
for(var J=2,I=arguments.length;
J<I;
++J){K.push(arguments[J])
}return function(){var O=K.slice();
for(var Q=0,P=arguments.length;
Q<P;
++Q){O.push(arguments[Q])
}return N.apply(L,O)
}
},makeEnum:function(J){var L={};
for(var K=0,I;
(I=J[K]);
++K){L[I]=I
}return L
},getFeatureParameters:function(I){return typeof D[I]==="undefined"?null:D[I]
},hasFeature:function(I){return typeof D[I]!=="undefined"
},getServices:function(){return C
},registerOnLoadHandler:function(I){F.push(I)
},runOnLoadHandlers:function(){for(var J=0,I=F.length;
J<I;
++J){F[J]()
}},escape:function(I,M){if(!I){return I
}else{if(typeof I==="string"){return gadgets.util.escapeString(I)
}else{if(typeof I==="array"){for(var L=0,J=I.length;
L<J;
++L){I[L]=gadgets.util.escape(I[L])
}}else{if(typeof I==="object"&&M){var K={};
for(var N in I){if(I.hasOwnProperty(N)){K[gadgets.util.escapeString(N)]=gadgets.util.escape(I[N],true)
}}return K
}}}}return I
},escapeString:function(M){if(!M){return M
}var J=[],L,N;
for(var K=0,I=M.length;
K<I;
++K){L=M.charCodeAt(K);
N=A[L];
if(N===true){J.push("&#",L,";")
}else{if(N!==false){J.push(M.charAt(K))
}}}return J.join("")
},unescapeString:function(I){if(!I){return I
}return I.replace(/&#([0-9]+);/g,B)
}}
}();
gadgets.util.getUrlParameters();;
var tamings___=tamings___||[];
tamings___.push(function(A){caja___.whitelistFuncs([[gadgets.util,"escapeString"],[gadgets.util,"getFeatureParameters"],[gadgets.util,"getUrlParameters"],[gadgets.util,"hasFeature"],[gadgets.util,"registerOnLoadHandler"],[gadgets.util,"unescapeString"]])
});;
gadgets.window=gadgets.window||{};
(function(){gadgets.window.getViewportDimensions=function(){if(self.innerHeight){x=self.innerWidth;
y=self.innerHeight
}else{if(document.documentElement&&document.documentElement.clientHeight){x=document.documentElement.clientWidth;
y=document.documentElement.clientHeight
}else{if(document.body){x=document.body.clientWidth;
y=document.body.clientHeight
}else{x=0;
y=0
}}}return{width:x,height:y}
}
})();;
gadgets.rpctx=gadgets.rpctx||{};
if(!gadgets.rpctx.wpm){gadgets.rpctx.wpm=function(){var A;
return{getCode:function(){return"wpm"
},isParentVerifiable:function(){return true
},init:function(B,C){A=C;
var D=function(E){B(gadgets.json.parse(E.data))
};
if(typeof window.addEventListener!="undefined"){window.addEventListener("message",D,false)
}else{if(typeof window.attachEvent!="undefined"){window.attachEvent("onmessage",D)
}}A("..",true);
return true
},setup:function(C,B){if(C===".."){gadgets.rpc.call(C,gadgets.rpc.ACK)
}return true
},call:function(C,G,F){var E=gadgets.rpc._getTargetWin(C);
var D=gadgets.rpc.getRelayUrl(C)||gadgets.util.getUrlParameters()["parent"];
var B=gadgets.rpc.getOrigin(D);
if(B){E.postMessage(gadgets.json.stringify(F),B)
}else{gadgets.error("No relay set (used as window.postMessage targetOrigin), cannot send cross-domain message")
}return true
}}
}()
};;
gadgets.rpctx=gadgets.rpctx||{};
if(!gadgets.rpctx.frameElement){gadgets.rpctx.frameElement=function(){var E="__g2c_rpc";
var B="__c2g_rpc";
var D;
var C;
function A(G,K,J){try{if(K!==".."){var F=window.frameElement;
if(typeof F[E]==="function"){if(typeof F[E][B]!=="function"){F[E][B]=function(L){D(gadgets.json.parse(L))
}
}F[E](gadgets.json.stringify(J));
return 
}}else{var I=document.getElementById(G);
if(typeof I[E]==="function"&&typeof I[E][B]==="function"){I[E][B](gadgets.json.stringify(J));
return 
}}}catch(H){}return true
}return{getCode:function(){return"fe"
},isParentVerifiable:function(){return false
},init:function(F,G){D=F;
C=G;
return true
},setup:function(J,F){if(J!==".."){try{var I=document.getElementById(J);
I[E]=function(K){D(gadgets.json.parse(K))
}
}catch(H){return false
}}if(J===".."){C("..",true);
var G=function(){window.setTimeout(function(){gadgets.rpc.call(J,gadgets.rpc.ACK)
},500)
};
gadgets.util.registerOnLoadHandler(G)
}return true
},call:function(F,H,G){A(F,H,G)
}}
}()
};;
gadgets.rpctx=gadgets.rpctx||{};
if(!gadgets.rpctx.nix){gadgets.rpctx.nix=function(){var C="GRPC____NIXVBS_wrapper";
var D="GRPC____NIXVBS_get_wrapper";
var F="GRPC____NIXVBS_handle_message";
var B="GRPC____NIXVBS_create_channel";
var A=10;
var J=500;
var I={};
var H;
var G=0;
function E(){var L=I[".."];
if(L){return 
}if(++G>A){gadgets.warn("Nix transport setup failed, falling back...");
H("..",false);
return 
}if(!L&&window.opener&&"GetAuthToken" in window.opener){L=window.opener;
if(L.GetAuthToken()==gadgets.rpc.getAuthToken("..")){var K=gadgets.rpc.getAuthToken("..");
L.CreateChannel(window[D]("..",K),K);
I[".."]=L;
window.opener=null;
H("..",true);
return 
}}window.setTimeout(function(){E()
},J)
}return{getCode:function(){return"nix"
},isParentVerifiable:function(){return false
},init:function(L,M){H=M;
if(typeof window[D]!=="unknown"){window[F]=function(O){window.setTimeout(function(){L(gadgets.json.parse(O))
},0)
};
window[B]=function(O,Q,P){if(gadgets.rpc.getAuthToken(O)===P){I[O]=Q;
H(O,true)
}};
var K="Class "+C+"\n Private m_Intended\nPrivate m_Auth\nPublic Sub SetIntendedName(name)\n If isEmpty(m_Intended) Then\nm_Intended = name\nEnd If\nEnd Sub\nPublic Sub SetAuth(auth)\n If isEmpty(m_Auth) Then\nm_Auth = auth\nEnd If\nEnd Sub\nPublic Sub SendMessage(data)\n "+F+"(data)\nEnd Sub\nPublic Function GetAuthToken()\n GetAuthToken = m_Auth\nEnd Function\nPublic Sub CreateChannel(channel, auth)\n Call "+B+"(m_Intended, channel, auth)\nEnd Sub\nEnd Class\nFunction "+D+"(name, auth)\nDim wrap\nSet wrap = New "+C+"\nwrap.SetIntendedName name\nwrap.SetAuth auth\nSet "+D+" = wrap\nEnd Function";
try{window.execScript(K,"vbscript")
}catch(N){return false
}}return true
},setup:function(O,K){if(O===".."){E();
return true
}try{var M=document.getElementById(O);
var N=window[D](O,K);
M.contentWindow.opener=N
}catch(L){return false
}return true
},call:function(K,N,M){try{if(I[K]){I[K].SendMessage(gadgets.json.stringify(M))
}}catch(L){return false
}return true
}}
}()
};;
gadgets.rpctx=gadgets.rpctx||{};
if(!gadgets.rpctx.rmr){gadgets.rpctx.rmr=function(){var G=500;
var E=10;
var H={};
var B;
var I;
function K(P,N,O,M){var Q=function(){document.body.appendChild(P);
P.src="about:blank";
if(M){P.onload=function(){L(M)
}
}P.src=N+"#"+O
};
if(document.body){Q()
}else{gadgets.util.registerOnLoadHandler(function(){Q()
})
}}function C(O){if(typeof H[O]==="object"){return 
}var P=document.createElement("iframe");
var M=P.style;
M.position="absolute";
M.top="0px";
M.border="0";
M.opacity="0";
M.width="10px";
M.height="1px";
P.id="rmrtransport-"+O;
P.name=P.id;
var N=gadgets.rpc.getRelayUrl(O);
if(!N){N=gadgets.rpc.getOrigin(gadgets.util.getUrlParameters()["parent"])+"/robots.txt"
}H[O]={frame:P,receiveWindow:null,relayUri:N,searchCounter:0,width:10,waiting:true,queue:[],sendId:0,recvId:0};
if(O!==".."){K(P,N,A(O))
}D(O)
}function D(O){var Q=null;
H[O].searchCounter++;
try{var N=gadgets.rpc._getTargetWin(O);
if(O===".."){Q=N.frames["rmrtransport-"+gadgets.rpc.RPC_ID]
}else{Q=N.frames["rmrtransport-.."]
}}catch(P){}var M=false;
if(Q){M=F(O,Q)
}if(!M){if(H[O].searchCounter>E){return 
}window.setTimeout(function(){D(O)
},G)
}}function J(N,P,T,S){var O=null;
if(T!==".."){O=H[".."]
}else{O=H[N]
}if(O){if(P!==gadgets.rpc.ACK){O.queue.push(S)
}if(O.waiting||(O.queue.length===0&&!(P===gadgets.rpc.ACK&&S&&S.ackAlone===true))){return true
}if(O.queue.length>0){O.waiting=true
}var M=O.relayUri+"#"+A(N);
try{O.frame.contentWindow.location=M;
var Q=O.width==10?20:10;
O.frame.style.width=Q+"px";
O.width=Q
}catch(R){return false
}}return true
}function A(N){var O=H[N];
var M={id:O.sendId};
if(O){M.d=Array.prototype.slice.call(O.queue,0);
M.d.push({s:gadgets.rpc.ACK,id:O.recvId})
}return gadgets.json.stringify(M)
}function L(X){var U=H[X];
var Q=U.receiveWindow.location.hash.substring(1);
var Y=gadgets.json.parse(decodeURIComponent(Q))||{};
var N=Y.d||[];
var O=false;
var T=false;
var V=0;
var M=(U.recvId-Y.id);
for(var P=0;
P<N.length;
++P){var S=N[P];
if(S.s===gadgets.rpc.ACK){I(X,true);
if(U.waiting){T=true
}U.waiting=false;
var R=Math.max(0,S.id-U.sendId);
U.queue.splice(0,R);
U.sendId=Math.max(U.sendId,S.id||0);
continue
}O=true;
if(++V<=M){continue
}++U.recvId;
B(S)
}if(O||(T&&U.queue.length>0)){var W=(X==="..")?gadgets.rpc.RPC_ID:"..";
J(X,gadgets.rpc.ACK,W,{ackAlone:O})
}}function F(P,S){var O=H[P];
try{var N=false;
N="document" in S;
if(!N){return false
}N=typeof S.document=="object";
if(!N){return false
}var R=S.location.href;
if(R==="about:blank"){return false
}}catch(M){return false
}O.receiveWindow=S;
function Q(){L(P)
}if(typeof S.attachEvent==="undefined"){S.onresize=Q
}else{S.attachEvent("onresize",Q)
}if(P===".."){K(O.frame,O.relayUri,A(P),P)
}else{L(P)
}return true
}return{getCode:function(){return"rmr"
},isParentVerifiable:function(){return true
},init:function(M,N){B=M;
I=N;
return true
},setup:function(O,M){try{C(O)
}catch(N){gadgets.warn("Caught exception setting up RMR: "+N);
return false
}return true
},call:function(M,O,N){return J(M,N.s,O,N)
}}
}()
};;
gadgets.rpctx=gadgets.rpctx||{};
if(!gadgets.rpctx.ifpc){gadgets.rpctx.ifpc=function(){var E=[];
var D=0;
var C;
function B(H){var F=[];
for(var I=0,G=H.length;
I<G;
++I){F.push(encodeURIComponent(gadgets.json.stringify(H[I])))
}return F.join("&")
}function A(I){var G;
for(var F=E.length-1;
F>=0;
--F){var J=E[F];
try{if(J&&(J.recyclable||J.readyState==="complete")){J.parentNode.removeChild(J);
if(window.ActiveXObject){E[F]=J=null;
E.splice(F,1)
}else{J.recyclable=false;
G=J;
break
}}}catch(H){}}if(!G){G=document.createElement("iframe");
G.style.border=G.style.width=G.style.height="0px";
G.style.visibility="hidden";
G.style.position="absolute";
G.onload=function(){this.recyclable=true
};
E.push(G)
}G.src=I;
window.setTimeout(function(){document.body.appendChild(G)
},0)
}return{getCode:function(){return"ifpc"
},isParentVerifiable:function(){return true
},init:function(F,G){C=G;
C("..",true);
return true
},setup:function(G,F){C(G,true);
return true
},call:function(F,K,I){var J=gadgets.rpc.getRelayUrl(F);
++D;
if(!J){gadgets.warn("No relay file assigned for IFPC");
return 
}var H=null;
if(I.l){var G=I.a;
H=[J,"#",B([K,D,1,0,B([K,I.s,"","",K].concat(G))])].join("")
}else{H=[J,"#",F,"&",K,"@",D,"&1&0&",encodeURIComponent(gadgets.json.stringify(I))].join("")
}A(H);
return true
}}
}()
};;
if(!gadgets.rpc){gadgets.rpc=function(){var T="__cb";
var S="";
var G="__ack";
var R=500;
var J=10;
var B={};
var C={};
var X={};
var K={};
var N=0;
var i={};
var W={};
var D={};
var f={};
var L={};
var V={};
var M=(window.top!==window.self);
var O=window.name;
var g=(function(){function j(k){return function(){gadgets.log("gadgets.rpc."+k+"("+gadgets.json.stringify(Array.prototype.slice.call(arguments))+"): call ignored. [caller: "+document.location+", isChild: "+M+"]")
}
}return{getCode:function(){return"noop"
},isParentVerifiable:function(){return true
},init:j("init"),setup:j("setup"),call:j("call")}
})();
if(gadgets.util){f=gadgets.util.getUrlParameters()
}var a=(f.rpc_earlyq==="1");
function A(){return typeof window.postMessage==="function"?gadgets.rpctx.wpm:typeof window.postMessage==="object"?gadgets.rpctx.wpm:window.ActiveXObject?gadgets.rpctx.nix:navigator.userAgent.indexOf("WebKit")>0?gadgets.rpctx.rmr:navigator.product==="Gecko"?gadgets.rpctx.frameElement:gadgets.rpctx.ifpc
}function b(o,m){var k=c;
if(!m){k=g
}L[o]=k;
var j=V[o]||[];
for(var l=0;
l<j.length;
++l){var n=j[l];
n.t=Y(o);
k.call(o,n.f,n)
}V[o]=[]
}function U(k){if(k&&typeof k.s==="string"&&typeof k.f==="string"&&k.a instanceof Array){if(K[k.f]){if(K[k.f]!==k.t){throw new Error("Invalid auth token. "+K[k.f]+" vs "+k.t)
}}if(k.s===G){window.setTimeout(function(){b(k.f,true)
},0);
return 
}if(k.c){k.callback=function(l){gadgets.rpc.call(k.f,T,null,k.c,l)
}
}var j=(B[k.s]||B[S]).apply(k,k.a);
if(k.c&&typeof j!=="undefined"){gadgets.rpc.call(k.f,T,null,k.c,j)
}}}function e(l){if(!l){return""
}l=l.toLowerCase();
if(l.indexOf("//")==0){l=window.location.protocol+l
}if(l.indexOf("://")==-1){l=window.location.protocol+"//"+l
}var m=l.substring(l.indexOf("://")+3);
var j=m.indexOf("/");
if(j!=-1){m=m.substring(0,j)
}var o=l.substring(0,l.indexOf("://"));
var n="";
var p=m.indexOf(":");
if(p!=-1){var k=m.substring(p+1);
m=m.substring(0,p);
if((o==="http"&&k!=="80")||(o==="https"&&k!=="443")){n=":"+k
}}return o+"://"+m+n
}function I(k){if(typeof k==="undefined"||k===".."){return window.parent
}k=String(k);
var j=window.frames[k];
if(j){return j
}j=document.getElementById(k);
if(j&&j.contentWindow){return j.contentWindow
}return null
}var c=A();
B[S]=function(){gadgets.warn("Unknown RPC service: "+this.s)
};
B[T]=function(k,j){var l=i[k];
if(l){delete i[k];
l(j)
}};
function P(l,j){if(W[l]===true){return 
}if(typeof W[l]==="undefined"){W[l]=0
}var k=document.getElementById(l);
if(l===".."||k!=null){if(c.setup(l,j)===true){W[l]=true;
return 
}}if(W[l]!==true&&W[l]++<J){window.setTimeout(function(){P(l,j)
},R)
}else{L[l]=g;
W[l]=true
}}function F(k,n){if(typeof D[k]==="undefined"){D[k]=false;
var m=gadgets.rpc.getRelayUrl(k);
if(e(m)!==e(window.location.href)){return false
}var l=I(k);
try{D[k]=l.gadgets.rpc.receiveSameDomain
}catch(j){gadgets.error("Same domain call failed: parent= incorrectly set.")
}}if(typeof D[k]==="function"){D[k](n);
return true
}return false
}function H(k,j,l){C[k]=j;
X[k]=!!l
}function Y(j){return K[j]
}function E(j,k){k=k||"";
K[j]=String(k);
P(j,k)
}function Q(j){function l(o){var q=o?o.rpc:{};
var n=q.parentRelayUrl;
if(n.substring(0,7)!=="http://"&&n.substring(0,8)!=="https://"&&n.substring(0,2)!=="//"){if(typeof f.parent==="string"&&f.parent!==""){if(n.substring(0,1)!=="/"){var m=f.parent.lastIndexOf("/");
n=f.parent.substring(0,m+1)+n
}else{n=e(f.parent)+n
}}}var p=!!q.useLegacyProtocol;
H("..",n,p);
if(p){c=gadgets.rpctx.ifpc;
c.init(U,b)
}E("..",j)
}var k={parentRelayUrl:gadgets.config.NonEmptyStringValidator};
gadgets.config.register("rpc",k,l)
}function Z(l,j){var k=j||f.parent;
if(k){H("..",k);
E("..",l)
}}function d(j,n,p){if(!gadgets.util){return 
}var m=document.getElementById(j);
if(!m){throw new Error("Cannot set up gadgets.rpc receiver with ID: "+j+", element not found.")
}var k=n||m.src;
H(j,k);
var o=gadgets.util.getUrlParameters(m.src);
var l=p||o.rpctoken;
E(j,l)
}function h(j,l,m){if(j===".."){var k=m||f.rpctoken||f.ifpctok||"";
if(window.__isgadget===true){Q(k)
}else{Z(k,l)
}}else{d(j,l,m)
}}return{register:function(k,j){if(k===T||k===G){throw new Error("Cannot overwrite callback/ack service")
}if(k===S){throw new Error("Cannot overwrite default service: use registerDefault")
}B[k]=j
},unregister:function(j){if(j===T||j===G){throw new Error("Cannot delete callback/ack service")
}if(j===S){throw new Error("Cannot delete default service: use unregisterDefault")
}delete B[j]
},registerDefault:function(j){B[S]=j
},unregisterDefault:function(){delete B[S]
},forceParentVerifiable:function(){if(!c.isParentVerifiable()){c=gadgets.rpctx.ifpc
}},call:function(j,k,p,n){j=j||"..";
var o="..";
if(j===".."){o=O
}++N;
if(p){i[N]=p
}var m={s:k,f:o,c:p?N:0,a:Array.prototype.slice.call(arguments,3),t:K[j],l:X[j]};
if(j!==".."&&!document.getElementById(j)){gadgets.log("WARNING: attempted send to nonexistent frame: "+j);
return 
}if(F(j,m)){return 
}var l=L[j]?L[j]:c;
if(!l){if(!V[j]){V[j]=[m]
}else{V[j].push(m)
}return 
}if(X[j]){l=gadgets.rpctx.ifpc
}if(l.call(j,o,m)===false){L[j]=g;
c.call(j,o,m)
}},getRelayUrl:function(k){var j=C[k];
if(j&&j.indexOf("//")==0){j=document.location.protocol+j
}return j
},setRelayUrl:H,setAuthToken:E,setupReceiver:h,getAuthToken:Y,getRelayChannel:function(){return c.getCode()
},receive:function(j){if(j.length>4){U(gadgets.json.parse(decodeURIComponent(j[j.length-1])))
}},receiveSameDomain:function(j){j.a=Array.prototype.slice.call(j.a);
window.setTimeout(function(){U(j)
},0)
},getOrigin:e,init:function(){if(c.init(U,b)===false){c=g
}if(M){h("..")
}},_getTargetWin:I,ACK:G,RPC_ID:O}
}();
gadgets.rpc.init()
};;
gadgets.window=gadgets.window||{};
(function(){var C;
function A(F,D){var E=window.getComputedStyle(F,"");
var G=E.getPropertyValue(D);
G.match(/^([0-9]+)/);
return parseInt(RegExp.$1,10)
}function B(){var E=0;
var D=[document.body];
while(D.length>0){var I=D.shift();
var H=I.childNodes;
for(var G=0;
G<H.length;
G++){var J=H[G];
if(typeof J.offsetTop!=="undefined"&&typeof J.scrollHeight!=="undefined"){var F=J.offsetTop+J.scrollHeight+A(J,"margin-bottom");
E=Math.max(E,F)
}D.push(J)
}}return E+A(document.body,"border-bottom")+A(document.body,"margin-bottom")+A(document.body,"padding-bottom")
}gadgets.window.adjustHeight=function(I){var F=parseInt(I,10);
var E=false;
if(isNaN(F)){E=true;
var K=gadgets.window.getViewportDimensions().height;
var D=document.body;
var J=document.documentElement;
if(document.compatMode==="CSS1Compat"&&J.scrollHeight){F=J.scrollHeight!==K?J.scrollHeight:J.offsetHeight
}else{if(navigator.userAgent.indexOf("AppleWebKit")>=0){F=B()
}else{if(D&&J){var G=J.scrollHeight;
var H=J.offsetHeight;
if(J.clientHeight!==H){G=D.scrollHeight;
H=D.offsetHeight
}if(G>K){F=G>H?G:H
}else{F=G<H?G:H
}}}}}if(F!==C&&!isNaN(F)&&!(E&&F===0)){C=F;
gadgets.rpc.call(null,"resize_iframe",null,F)
}}
}());
var _IG_AdjustIFrameHeight=gadgets.window.adjustHeight;;
var tamings___=tamings___||[];
tamings___.push(function(A){caja___.whitelistFuncs([[gadgets.window,"adjustHeight"],[gadgets.window,"getViewportDimensions"]])
});;
(function(){var I=null;
var J={};
var F=gadgets.util.escapeString;
var D={};
var H={};
var E="en";
var B="US";
var A=0;
function C(){var L=gadgets.util.getUrlParameters();
for(var K in L){if(L.hasOwnProperty(K)){if(K.indexOf("up_")===0&&K.length>3){J[K.substr(3)]=String(L[K])
}else{if(K==="country"){B=L[K]
}else{if(K==="lang"){E=L[K]
}else{if(K==="mid"){A=L[K]
}}}}}}}function G(){for(var K in H){if(typeof J[K]==="undefined"){J[K]=H[K]
}}}gadgets.Prefs=function(){if(!I){C();
G();
I=this
}return I
};
gadgets.Prefs.setInternal_=function(M,O){var N=false;
if(typeof M==="string"){if(!J.hasOwnProperty(M)||J[M]!==O){N=true
}J[M]=O
}else{for(var L in M){if(M.hasOwnProperty(L)){var K=M[L];
if(!J.hasOwnProperty(L)||J[L]!==K){N=true
}J[L]=K
}}}return N
};
gadgets.Prefs.setMessages_=function(K){D=K
};
gadgets.Prefs.setDefaultPrefs_=function(K){H=K
};
gadgets.Prefs.prototype.getString=function(K){if(K===".lang"){K="lang"
}return J[K]?F(J[K]):""
};
gadgets.Prefs.prototype.setDontEscape_=function(){F=function(K){return K
}
};
gadgets.Prefs.prototype.getInt=function(K){var L=parseInt(J[K],10);
return isNaN(L)?0:L
};
gadgets.Prefs.prototype.getFloat=function(K){var L=parseFloat(J[K]);
return isNaN(L)?0:L
};
gadgets.Prefs.prototype.getBool=function(K){var L=J[K];
if(L){return L==="true"||L===true||!!parseInt(L,10)
}return false
};
gadgets.Prefs.prototype.set=function(K,L){throw new Error("setprefs feature required to make this call.")
};
gadgets.Prefs.prototype.getArray=function(N){var O=J[N];
if(O){var K=O.split("|");
for(var M=0,L=K.length;
M<L;
++M){K[M]=F(K[M].replace(/%7C/g,"|"))
}return K
}return[]
};
gadgets.Prefs.prototype.setArray=function(K,L){throw new Error("setprefs feature required to make this call.")
};
gadgets.Prefs.prototype.getMsg=function(K){return D[K]||""
};
gadgets.Prefs.prototype.getCountry=function(){return B
};
gadgets.Prefs.prototype.getLang=function(){return E
};
gadgets.Prefs.prototype.getModuleId=function(){return A
}
})();;
var tamings___=tamings___||[];
tamings___.push(function(A){caja___.whitelistCtors([[gadgets,"Prefs",Object]]);
caja___.whitelistMeths([[gadgets.Prefs,"getArray"],[gadgets.Prefs,"getBool"],[gadgets.Prefs,"getCountry"],[gadgets.Prefs,"getFloat"],[gadgets.Prefs,"getInt"],[gadgets.Prefs,"getLang"],[gadgets.Prefs,"getMsg"],[gadgets.Prefs,"getString"],[gadgets.Prefs,"set"],[gadgets.Prefs,"setArray"]])
});;
gadgets.Prefs.prototype.set=function(D,E){var G=false;
if(arguments.length>2){var F={};
for(var C=0,B=arguments.length;
C<B;
C+=2){F[arguments[C]]=arguments[C+1]
}G=gadgets.Prefs.setInternal_(F)
}else{G=gadgets.Prefs.setInternal_(D,E)
}if(!G){return 
}var A=[null,"set_pref",null,gadgets.util.getUrlParameters().ifpctok||gadgets.util.getUrlParameters().rpctoken||0].concat(Array.prototype.slice.call(arguments));
gadgets.rpc.call.apply(gadgets.rpc,A)
};
gadgets.Prefs.prototype.setArray=function(C,D){for(var B=0,A=D.length;
B<A;
++B){if(typeof D[B]!=="number"){D[B]=D[B].replace(/\|/g,"%7C")
}}this.set(C,D.join("|"))
};;
