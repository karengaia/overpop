window['___jsl']={'u':'http:\/\/www-gm-opensocial.googleusercontent.com\/gadgets\/js\/rpc.js?container=gm&nocache=0&debug=0&c=1&v=eb36f14be0fae72e9d22ed88fdc21d05&sv=1','f':['rpc']};
var gadgets=window.gadgets||{},shindig=window.shindig||{},osapi=window.osapi||{};
;
if(!gadgets.config){gadgets.config=function(){var ___jsl;
var components={};
var configuration;
function foldConfig(origConfig,updConfig){for(var key in updConfig){if(!updConfig.hasOwnProperty(key)){continue
}if(typeof origConfig[key]==="object"&&typeof updConfig[key]==="object"){foldConfig(origConfig[key],updConfig[key])
}else{origConfig[key]=updConfig[key]
}}}function getLoadingScript(){var scripts=document.scripts||document.getElementsByTagName("script");
if(!scripts||scripts.length==0){return null
}var scriptTag;
if(___jsl.u){for(var i=0;
!scriptTag&&i<scripts.length;
++i){var candidate=scripts[i];
if(candidate.src&&candidate.src.indexOf(___jsl.u)==0){scriptTag=candidate
}}}if(!scriptTag){scriptTag=scripts[scripts.length-1]
}if(!scriptTag.src){return null
}return scriptTag
}function getInnerText(scriptNode){var scriptText="";
if(scriptNode.nodeType==3||scriptNode.nodeType==4){scriptText=scriptNode.nodeValue
}else{if(scriptNode.innerText){scriptText=scriptNode.innerText
}else{if(scriptNode.firstChild){var content=[];
for(var child=scriptNode.firstChild;
child;
child=child.nextSibling){content.push(getInnerText(child))
}scriptText=content.join("")
}}}return scriptText
}function parseConfig(configText){var config;
try{eval("config=("+configText+"\n)")
}catch(e){}if(typeof config==="object"){return config
}try{eval("config=({"+configText+"\n})")
}catch(e){}return typeof config==="object"?config:{}
}function augmentConfig(baseConfig){var loadScript=getLoadingScript();
if(!loadScript){return
}var scriptText=getInnerText(loadScript);
var configAugment=parseConfig(scriptText);
if(___jsl.f&&___jsl.f.length==1){var feature=___jsl.f[0];
if(!configAugment[feature]){var newConfig={};
newConfig[___jsl.f[0]]=configAugment;
configAugment=newConfig
}}foldConfig(baseConfig,configAugment)
}return{register:function(component,opt_validators,opt_callback){var registered=components[component];
if(!registered){registered=[];
components[component]=registered
}registered.push({validators:opt_validators||{},callback:opt_callback})
},get:function(opt_component){if(opt_component){return configuration[opt_component]||{}
}return configuration
},init:function(config,opt_noValidation){___jsl=window.___jsl||{};
if(configuration){foldConfig(configuration,config)
}else{configuration=config
}augmentConfig(configuration);
var inlineOverride=window.___config||{};
foldConfig(configuration,inlineOverride);
for(var name in components){if(components.hasOwnProperty(name)){var componentList=components[name],conf=configuration[name];
for(var i=0,j=componentList.length;
i<j;
++i){var component=componentList[i];
if(conf&&!opt_noValidation){var validators=component.validators;
for(var v in validators){if(validators.hasOwnProperty(v)){if(!validators[v](conf[v])){throw new Error('Invalid config value "'+conf[v]+'" for parameter "'+v+'" in component "'+name+'"')
}}}}if(component.callback){component.callback(configuration)
}}}}},update:function(updateConfig,opt_replace){configuration=opt_replace?{}:configuration||{};
foldConfig(configuration,updateConfig)
}}
}()
};;
gadgets.config.isGadget=false;
gadgets.config.isContainer=true;;
(function(){gadgets.config.EnumValidator=function(d){var c=[];
if(arguments.length>1){for(var b=0,a;
(a=arguments[b]);
++b){c.push(a)
}}else{c=d
}return function(f){for(var e=0,g;
(g=c[e]);
++e){if(f===c[e]){return true
}}return false
}
};
gadgets.config.RegExValidator=function(a){return function(b){return a.test(b)
}
};
gadgets.config.ExistsValidator=function(a){return typeof a!=="undefined"
};
gadgets.config.NonEmptyStringValidator=function(a){return typeof a==="string"&&a.length>0
};
gadgets.config.BooleanValidator=function(a){return typeof a==="boolean"
};
gadgets.config.LikeValidator=function(a){return function(c){for(var d in a){if(a.hasOwnProperty(d)){var b=a[d];
if(!b(c[d])){return false
}}}return true
}
}
})();;
gadgets.util=function(){var a=null;
function b(e){var f;
var c=e.indexOf("?");
var d=e.indexOf("#");
if(d===-1){f=e.substr(c+1)
}else{f=[e.substr(c+1,d-c-1),"&",e.substr(d+1)].join("")
}return f.split("&")
}return{getUrlParameters:function(p){var d=typeof p==="undefined";
if(a!==null&&d){return a
}var l={};
var f=b(p||document.location.href);
var n=window.decodeURIComponent?decodeURIComponent:unescape;
for(var h=0,g=f.length;
h<g;
++h){var m=f[h].indexOf("=");
if(m===-1){continue
}var c=f[h].substring(0,m);
var o=f[h].substring(m+1);
o=o.replace(/\+/g," ");
try{l[c]=n(o)
}catch(k){}}if(d){a=l
}return l
}}
}();
gadgets.util.getUrlParameters();;
gadgets.log=(function(){var e=1;
var a=2;
var f=3;
var c=4;
var d=function(i){b(e,i)
};
gadgets.warn=function(i){b(a,i)
};
gadgets.error=function(i){b(f,i)
};
gadgets.setLogLevel=function(i){h=i
};
function b(j,i){if(j<h||!g){return
}if(j===a&&g.warn){g.warn(i)
}else{if(j===f&&g.error){g.error(i)
}else{if(g.log){g.log(i)
}}}}d.INFO=e;
d.WARNING=a;
d.NONE=c;
var h=e;
var g=window.console?window.console:window.opera?window.opera.postError:undefined;
return d
})();;
var tamings___=tamings___||[];
tamings___.push(function(a){___.grantRead(gadgets.log,"INFO");
___.grantRead(gadgets.log,"WARNING");
___.grantRead(gadgets.log,"ERROR");
___.grantRead(gadgets.log,"NONE");
caja___.whitelistFuncs([[gadgets,"log"],[gadgets,"warn"],[gadgets,"error"],[gadgets,"setLogLevel"]])
});;
if(window.JSON&&window.JSON.parse&&window.JSON.stringify){gadgets.json=(function(){var a=/___$/;
return{parse:function(c){try{return window.JSON.parse(c)
}catch(b){return false
}},stringify:function(c){try{return window.JSON.stringify(c,function(e,d){return !a.test(e)?d:null
})
}catch(b){return null
}}}
})()
};;
if(!(window.JSON&&window.JSON.parse&&window.JSON.stringify)){gadgets.json=function(){function f(n){return n<10?"0"+n:n
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
}return""
}return{stringify:stringify,parse:function(text){if(/^[\],:{}\s]*$/.test(text.replace(/\\["\\\/b-u]/g,"@").replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,"]").replace(/(?:^|:|,)(?:\s*\[)+/g,""))){return eval("("+text+")")
}return false
}}
}()
};;
gadgets.json.flatten=function(c){var d={};
if(c===null||c===undefined){return d
}for(var a in c){if(c.hasOwnProperty(a)){var b=c[a];
if(null===b||undefined===b){continue
}d[a]=(typeof b==="string")?b:gadgets.json.stringify(b)
}}return d
};;
var tamings___=tamings___||[];
tamings___.push(function(a){___.tamesTo(gadgets.json.stringify,safeJSON.stringify);
___.tamesTo(gadgets.json.parse,safeJSON.parse)
});;
var __getUrlParameters=gadgets.util.getUrlParameters;
gadgets.util=function(){var d={};
var c={};
var e=[];
var a={0:false,10:true,13:true,34:true,39:true,60:true,62:true,92:true,8232:true,8233:true};
function b(g,h){return String.fromCharCode(h)
}function f(g){d=g["core.util"]||{}
}if(gadgets.config){gadgets.config.register("core.util",null,f)
}return{getUrlParameters:__getUrlParameters,makeClosure:function(l,n,m){var k=[];
for(var h=2,g=arguments.length;
h<g;
++h){k.push(arguments[h])
}return function(){var o=k.slice();
for(var q=0,p=arguments.length;
q<p;
++q){o.push(arguments[q])
}return n.apply(l,o)
}
},makeEnum:function(h){var j,g,k={};
for(j=0;
(g=h[j]);
++j){k[g]=g
}return k
},getFeatureParameters:function(g){return typeof d[g]==="undefined"?null:d[g]
},hasFeature:function(g){return typeof d[g]!=="undefined"
},getServices:function(){return c
},registerOnLoadHandler:function(g){e.push(g)
},runOnLoadHandlers:function(){for(var h=0,g=e.length;
h<g;
++h){e[h]()
}},escape:function(g,m){if(!g){return g
}else{if(typeof g==="string"){return gadgets.util.escapeString(g)
}else{if(typeof g==="array"){for(var l=0,h=g.length;
l<h;
++l){g[l]=gadgets.util.escape(g[l])
}}else{if(typeof g==="object"&&m){var k={};
for(var n in g){if(g.hasOwnProperty(n)){k[gadgets.util.escapeString(n)]=gadgets.util.escape(g[n],true)
}}return k
}}}}return g
},escapeString:function(m){if(!m){return m
}var h=[],l,n;
for(var k=0,g=m.length;
k<g;
++k){l=m.charCodeAt(k);
n=a[l];
if(n===true){h.push("&#",l,";")
}else{if(n!==false){h.push(m.charAt(k))
}}}return h.join("")
},unescapeString:function(g){if(!g){return g
}return g.replace(/&#([0-9]+);/g,b)
},attachBrowserEvent:function(i,h,j,g){if(typeof i.addEventListener!="undefined"){i.addEventListener(h,j,g)
}else{if(typeof i.attachEvent!="undefined"){i.attachEvent("on"+h,j)
}else{gadgets.warn("cannot attachBrowserEvent: "+h)
}}},removeBrowserEvent:function(i,h,j,g){if(i.removeEventListener){i.removeEventListener(h,j,g)
}else{if(i.detachEvent){i.detachEvent("on"+h,j)
}else{gadgets.warn("cannot removeBrowserEvent: "+h)
}}}}
}();;
var tamings___=tamings___||[];
tamings___.push(function(a){caja___.whitelistFuncs([[gadgets.util,"escapeString"],[gadgets.util,"getFeatureParameters"],[gadgets.util,"getUrlParameters"],[gadgets.util,"hasFeature"],[gadgets.util,"registerOnLoadHandler"],[gadgets.util,"unescapeString"]])
});;
gadgets.rpctx=gadgets.rpctx||{};
if(!gadgets.rpctx.wpm){gadgets.rpctx.wpm=function(){var b,g;
var h;
var j=false;
var i=false;
var d=false;
function c(l,m,k){if(typeof window.addEventListener!="undefined"){window.addEventListener(l,m,k)
}else{if(typeof window.attachEvent!="undefined"){window.attachEvent("on"+l,m)
}}}function e(l,m,k){if(window.removeEventListener){window.removeEventListener(l,m,k)
}else{if(window.detachEvent){window.detachEvent("on"+l,m)
}}}function a(){var k=false;
function l(m){if(m.data=="postmessage.test"){k=true;
if(typeof m.origin==="undefined"){i=true
}}}c("message",l,false);
window.postMessage("postmessage.test","*");
if(k){j=true
}e("message",l,false)
}function f(m){var n=gadgets.json.parse(m.data);
if(d){if(!n||!n.f){return
}var l=gadgets.rpc.getRelayUrl(n.f)||gadgets.util.getUrlParameters()["parent"];
var k=gadgets.rpc.getOrigin(l);
if(!i?m.origin!==k:m.domain!==/^.+:\/\/([^:]+).*/.exec(k)[1]){return
}}b(n)
}return{getCode:function(){return"wpm"
},isParentVerifiable:function(){return true
},init:function(k,l){b=k;
g=l;
a();
if(!j){h=function(n,o,m){n.postMessage(o,m)
}
}else{h=function(n,o,m){window.setTimeout(function(){n.postMessage(o,m)
},0)
}
}c("message",f,false);
g("..",true);
return true
},setup:function(m,l,k){d=k;
if(m===".."){if(d){gadgets.rpc._createRelayIframe(l)
}else{gadgets.rpc.call(m,gadgets.rpc.ACK)
}}return true
},call:function(l,o,n){var k=gadgets.rpc.getTargetOrigin(l);
var m=gadgets.rpc._getTargetWin(l);
if(k){h(m,gadgets.json.stringify(n),k)
}else{gadgets.error("No relay set (used as window.postMessage targetOrigin), cannot send cross-domain message")
}return true
},relayOnload:function(l,k){g(l,true)
}}
}()
};;
;
gadgets.rpctx=gadgets.rpctx||{};
if(!gadgets.rpctx.frameElement){gadgets.rpctx.frameElement=function(){var e="__g2c_rpc";
var b="__c2g_rpc";
var d;
var c;
function a(g,k,j){try{if(k!==".."){var f=window.frameElement;
if(typeof f[e]==="function"){if(typeof f[e][b]!=="function"){f[e][b]=function(l){d(gadgets.json.parse(l))
}
}f[e](gadgets.json.stringify(j));
return true
}}else{var i=document.getElementById(g);
if(typeof i[e]==="function"&&typeof i[e][b]==="function"){i[e][b](gadgets.json.stringify(j));
return true
}}}catch(h){}return false
}return{getCode:function(){return"fe"
},isParentVerifiable:function(){return false
},init:function(f,g){d=f;
c=g;
return true
},setup:function(j,f){if(j!==".."){try{var i=document.getElementById(j);
i[e]=function(k){d(gadgets.json.parse(k))
}
}catch(h){return false
}}if(j===".."){c("..",true);
var g=function(){window.setTimeout(function(){gadgets.rpc.call(j,gadgets.rpc.ACK)
},500)
};
gadgets.util.registerOnLoadHandler(g)
}return true
},call:function(f,h,g){return a(f,h,g)
}}
}()
};;
;
gadgets.rpctx=gadgets.rpctx||{};
if(!gadgets.rpctx.nix){gadgets.rpctx.nix=function(){var c="GRPC____NIXVBS_wrapper";
var d="GRPC____NIXVBS_get_wrapper";
var f="GRPC____NIXVBS_handle_message";
var b="GRPC____NIXVBS_create_channel";
var a=10;
var j=500;
var i={};
var h;
var g=0;
function e(){var l=i[".."];
if(l){return
}if(++g>a){gadgets.warn("Nix transport setup failed, falling back...");
h("..",false);
return
}if(!l&&window.opener&&"GetAuthToken" in window.opener){l=window.opener;
if(l.GetAuthToken()==gadgets.rpc.getAuthToken("..")){var k=gadgets.rpc.getAuthToken("..");
l.CreateChannel(window[d]("..",k),k);
i[".."]=l;
window.opener=null;
h("..",true);
return
}}window.setTimeout(function(){e()
},j)
}return{getCode:function(){return"nix"
},isParentVerifiable:function(){return false
},init:function(l,m){h=m;
if(typeof window[d]!=="unknown"){window[f]=function(o){window.setTimeout(function(){l(gadgets.json.parse(o))
},0)
};
window[b]=function(o,q,p){if(gadgets.rpc.getAuthToken(o)===p){i[o]=q;
h(o,true)
}};
var k="Class "+c+"\n Private m_Intended\nPrivate m_Auth\nPublic Sub SetIntendedName(name)\n If isEmpty(m_Intended) Then\nm_Intended = name\nEnd If\nEnd Sub\nPublic Sub SetAuth(auth)\n If isEmpty(m_Auth) Then\nm_Auth = auth\nEnd If\nEnd Sub\nPublic Sub SendMessage(data)\n "+f+"(data)\nEnd Sub\nPublic Function GetAuthToken()\n GetAuthToken = m_Auth\nEnd Function\nPublic Sub CreateChannel(channel, auth)\n Call "+b+"(m_Intended, channel, auth)\nEnd Sub\nEnd Class\nFunction "+d+"(name, auth)\nDim wrap\nSet wrap = New "+c+"\nwrap.SetIntendedName name\nwrap.SetAuth auth\nSet "+d+" = wrap\nEnd Function";
try{window.execScript(k,"vbscript")
}catch(n){return false
}}return true
},setup:function(o,k){if(o===".."){e();
return true
}try{var m=document.getElementById(o);
var n=window[d](o,k);
m.contentWindow.opener=n
}catch(l){return false
}return true
},call:function(k,n,m){try{if(i[k]){i[k].SendMessage(gadgets.json.stringify(m))
}}catch(l){return false
}return true
}}
}()
};;
;
gadgets.rpctx=gadgets.rpctx||{};
if(!gadgets.rpctx.rmr){gadgets.rpctx.rmr=function(){var g=500;
var e=10;
var h={};
var b;
var i;
function k(p,n,o,m){var q=function(){document.body.appendChild(p);
p.src="about:blank";
if(m){p.onload=function(){l(m)
}
}p.src=n+"#"+o
};
if(document.body){q()
}else{gadgets.util.registerOnLoadHandler(function(){q()
})
}}function c(o){if(typeof h[o]==="object"){return
}var p=document.createElement("iframe");
var m=p.style;
m.position="absolute";
m.top="0px";
m.border="0";
m.opacity="0";
m.width="10px";
m.height="1px";
p.id="rmrtransport-"+o;
p.name=p.id;
var n=gadgets.rpc.getRelayUrl(o);
if(!n){n=gadgets.rpc.getOrigin(gadgets.util.getUrlParameters()["parent"])+"/robots.txt"
}h[o]={frame:p,receiveWindow:null,relayUri:n,searchCounter:0,width:10,waiting:true,queue:[],sendId:0,recvId:0};
if(o!==".."){k(p,n,a(o))
}d(o)
}function d(o){var q=null;
h[o].searchCounter++;
try{var n=gadgets.rpc._getTargetWin(o);
if(o===".."){q=n.frames["rmrtransport-"+gadgets.rpc.RPC_ID]
}else{q=n.frames["rmrtransport-.."]
}}catch(p){}var m=false;
if(q){m=f(o,q)
}if(!m){if(h[o].searchCounter>e){return
}window.setTimeout(function(){d(o)
},g)
}}function j(n,p,t,s){var o=null;
if(t!==".."){o=h[".."]
}else{o=h[n]
}if(o){if(p!==gadgets.rpc.ACK){o.queue.push(s)
}if(o.waiting||(o.queue.length===0&&!(p===gadgets.rpc.ACK&&s&&s.ackAlone===true))){return true
}if(o.queue.length>0){o.waiting=true
}var m=o.relayUri+"#"+a(n);
try{o.frame.contentWindow.location=m;
var q=o.width==10?20:10;
o.frame.style.width=q+"px";
o.width=q
}catch(r){return false
}}return true
}function a(n){var o=h[n];
var m={id:o.sendId};
if(o){m.d=Array.prototype.slice.call(o.queue,0);
m.d.push({s:gadgets.rpc.ACK,id:o.recvId})
}return gadgets.json.stringify(m)
}function l(x){var u=h[x];
var q=u.receiveWindow.location.hash.substring(1);
var y=gadgets.json.parse(decodeURIComponent(q))||{};
var n=y.d||[];
var o=false;
var t=false;
var v=0;
var m=(u.recvId-y.id);
for(var p=0;
p<n.length;
++p){var s=n[p];
if(s.s===gadgets.rpc.ACK){i(x,true);
if(u.waiting){t=true
}u.waiting=false;
var r=Math.max(0,s.id-u.sendId);
u.queue.splice(0,r);
u.sendId=Math.max(u.sendId,s.id||0);
continue
}o=true;
if(++v<=m){continue
}++u.recvId;
b(s)
}if(o||(t&&u.queue.length>0)){var w=(x==="..")?gadgets.rpc.RPC_ID:"..";
j(x,gadgets.rpc.ACK,w,{ackAlone:o})
}}function f(p,s){var o=h[p];
try{var n=false;
n="document" in s;
if(!n){return false
}n=typeof s.document=="object";
if(!n){return false
}var r=s.location.href;
if(r==="about:blank"){return false
}}catch(m){return false
}o.receiveWindow=s;
function q(){l(p)
}if(typeof s.attachEvent==="undefined"){s.onresize=q
}else{s.attachEvent("onresize",q)
}if(p===".."){k(o.frame,o.relayUri,a(p),p)
}else{l(p)
}return true
}return{getCode:function(){return"rmr"
},isParentVerifiable:function(){return true
},init:function(m,n){b=m;
i=n;
return true
},setup:function(o,m){try{c(o)
}catch(n){gadgets.warn("Caught exception setting up RMR: "+n);
return false
}return true
},call:function(m,o,n){return j(m,n.s,o,n)
}}
}()
};;
;
gadgets.rpctx=gadgets.rpctx||{};
if(!gadgets.rpctx.ifpc){gadgets.rpctx.ifpc=function(){var e=[];
var d=0;
var c;
function b(h){var f=[];
for(var k=0,g=h.length;
k<g;
++k){f.push(encodeURIComponent(gadgets.json.stringify(h[k])))
}return f.join("&")
}function a(j){var g;
for(var f=e.length-1;
f>=0;
--f){var k=e[f];
try{if(k&&(k.recyclable||k.readyState==="complete")){k.parentNode.removeChild(k);
if(window.ActiveXObject){e[f]=k=null;
e.splice(f,1)
}else{k.recyclable=false;
g=k;
break
}}}catch(h){}}if(!g){g=document.createElement("iframe");
g.style.border=g.style.width=g.style.height="0px";
g.style.visibility="hidden";
g.style.position="absolute";
g.onload=function(){this.recyclable=true
};
e.push(g)
}g.src=j;
window.setTimeout(function(){document.body.appendChild(g)
},0)
}return{getCode:function(){return"ifpc"
},isParentVerifiable:function(){return true
},init:function(f,g){c=g;
c("..",true);
return true
},setup:function(g,f){c(g,true);
return true
},call:function(f,k,i){var j=gadgets.rpc.getRelayUrl(f);
++d;
if(!j){gadgets.warn("No relay file assigned for IFPC");
return false
}var h=null;
if(i.l){var g=i.a;
h=[j,"#",b([k,d,1,0,b([k,i.s,"","",k].concat(g))])].join("")
}else{h=[j,"#",f,"&",k,"@",d,"&1&0&",encodeURIComponent(gadgets.json.stringify(i))].join("")
}a(h);
return true
}}
}()
};;
if(!gadgets.rpc){gadgets.rpc=function(){var E="__cb";
var L="";
var M="__ack";
var f=500;
var y=10;
var c="|";
var n={};
var P={};
var u={};
var t={};
var r=0;
var j={};
var k={};
var J={};
var e={};
var l={};
var v={};
var s=(window.top!==window.self);
var p=window.name;
var B=function(){};
var I=0;
var S=1;
var a=2;
var O=window.console&&console.log?console.log:function(){};
var K=(function(){function W(X){return function(){O(X+": call ignored")
}
}return{getCode:function(){return"noop"
},isParentVerifiable:function(){return true
},init:W("init"),setup:W("setup"),call:W("call")}
})();
if(gadgets.util){e=gadgets.util.getUrlParameters()
}function C(){return typeof window.postMessage==="function"?gadgets.rpctx.wpm:typeof window.postMessage==="object"?gadgets.rpctx.wpm:window.ActiveXObject?gadgets.rpctx.nix:navigator.userAgent.indexOf("WebKit")>0?gadgets.rpctx.rmr:navigator.product==="Gecko"?gadgets.rpctx.frameElement:gadgets.rpctx.ifpc
}function i(ab,Z){var X=z;
if(!Z){X=K
}l[ab]=X;
var W=v[ab]||[];
for(var Y=0;
Y<W.length;
++Y){var aa=W[Y];
aa.t=x(ab);
X.call(ab,aa.f,aa)
}v[ab]=[]
}var A=false,N=false;
function G(){if(N){return
}function W(){A=true
}gadgets.util.attachBrowserEvent(window,"unload",W,false);
N=true
}function h(W,aa,X,Z,Y){if(!t[aa]||t[aa]!==X){gadgets.error("Invalid auth token. "+t[aa]+" vs "+X);
B(aa,a)
}Y.onunload=function(){if(k[aa]&&!A){B(aa,S);
gadgets.rpc.removeReceiver(aa)
}};
G();
Z=gadgets.json.parse(decodeURIComponent(Z));
z.relayOnload(aa,Z)
}function T(X){if(X&&typeof X.s==="string"&&typeof X.f==="string"&&X.a instanceof Array){if(t[X.f]){if(t[X.f]!==X.t){gadgets.error("Invalid auth token. "+t[X.f]+" vs "+X.t);
B(X.f,a)
}}if(X.s===M){window.setTimeout(function(){i(X.f,true)
},0);
return
}if(X.c){X.callback=function(Y){gadgets.rpc.call(X.f,E,null,X.c,Y)
}
}var W=(n[X.s]||n[L]).apply(X,X.a);
if(X.c&&typeof W!=="undefined"){gadgets.rpc.call(X.f,E,null,X.c,W)
}}}function o(Y){if(!Y){return""
}Y=Y.toLowerCase();
if(Y.indexOf("//")==0){Y=window.location.protocol+Y
}if(Y.indexOf("://")==-1){Y=window.location.protocol+"//"+Y
}var Z=Y.substring(Y.indexOf("://")+3);
var W=Z.indexOf("/");
if(W!=-1){Z=Z.substring(0,W)
}var ab=Y.substring(0,Y.indexOf("://"));
var aa="";
var ac=Z.indexOf(":");
if(ac!=-1){var X=Z.substring(ac+1);
Z=Z.substring(0,ac);
if((ab==="http"&&X!=="80")||(ab==="https"&&X!=="443")){aa=":"+X
}}return ab+"://"+Z+aa
}function w(X,W){return"/"+X+(W?c+W:"")
}function q(Z){if(Z.charAt(0)=="/"){var X=Z.indexOf(c);
var Y=X>0?Z.substring(1,X):Z.substring(1);
var W=X>0?Z.substring(X+1):null;
return{id:Y,origin:W}
}else{return null
}}function V(Y){if(typeof Y==="undefined"||Y===".."){return window.parent
}var X=q(Y);
if(X){return window.top.frames[X.id]
}Y=String(Y);
var W=window.frames[Y];
if(W){return W
}W=document.getElementById(Y);
if(W&&W.contentWindow){return W.contentWindow
}return null
}function D(Z){var Y=null;
var W=H(Z);
if(W){Y=W
}else{var X=q(Z);
if(X){Y=X.origin
}else{if(Z==".."){Y=e.parent
}else{Y=document.getElementById(Z).src
}}}return o(Y)
}var z=C();
n[L]=function(){O("Unknown RPC service: "+this.s)
};
n[E]=function(X,W){var Y=j[X];
if(Y){delete j[X];
Y(W)
}};
function R(Z,X,W){if(k[Z]===true){return
}if(typeof k[Z]==="undefined"){k[Z]=0
}var Y=V(Z);
if(Z===".."||Y!=null){if(z.setup(Z,X,W)===true){k[Z]=true;
return
}}if(k[Z]!==true&&k[Z]++<y){window.setTimeout(function(){R(Z,X,W)
},f)
}else{l[Z]=K;
k[Z]=true
}}function F(X,aa){if(typeof J[X]==="undefined"){J[X]=false;
var Z=H(X);
if(o(Z)!==o(window.location.href)){return false
}var Y=V(X);
try{J[X]=Y.gadgets.rpc.receiveSameDomain
}catch(W){gadgets.error("Same domain call failed: parent= incorrectly set.")
}}if(typeof J[X]==="function"){J[X](aa);
return true
}return false
}function H(X){var W=P[X];
if(W&&W.substring(0,1)==="/"){if(W.substring(1,2)==="/"){W=document.location.protocol+W
}else{W=document.location.protocol+"//"+document.location.host+W
}}return W
}function U(X,W,Y){if(!/http(s)?:\/\/.+/.test(W)){if(W.indexOf("//")==0){W=window.location.protocol+W
}else{if(W.charAt(0)=="/"){W=window.location.protocol+"//"+window.location.host+W
}else{if(W.indexOf("://")==-1){W=window.location.protocol+"//"+W
}}}}P[X]=W;
u[X]=!!Y
}function x(W){return t[W]
}function d(W,Y,X){Y=Y||"";
t[W]=String(Y);
R(W,Y,X)
}function b(W,X){function Y(ac){var ab=ac?ac.rpc:{};
var aa=ab.useLegacyProtocol;
if(typeof aa==="string"){aa=aa==="true"
}var Z=ab.parentRelayUrl||"";
Z=o(e.parent)+Z;
var ad=!!aa;
U("..",Z,ad);
if(ad){z=gadgets.rpctx.ifpc;
z.init(T,i)
}d("..",W,X||e.forcesecure)
}gadgets.config.register("rpc",null,Y)
}function Q(Z,W,aa){var X=aa||e.forcesecure||false;
var Y=W||e.parent;
if(Y){U("..",Y);
d("..",Z,X)
}}function m(Y,aa,W,Z){if(Y.charAt(0)!="/"){if(!gadgets.util){return
}var ae=document.getElementById(Y);
if(!ae){throw new Error("Cannot set up gadgets.rpc receiver with ID: "+Y+", element not found.")
}}var ac=aa||ae.src;
U(Y,ac);
var ad=gadgets.util.getUrlParameters(ac);
var X=W||ad.rpctoken;
var ab=Z||ad.forcesecure;
d(Y,X,ab)
}function g(W,Y,aa,Z){if(W===".."){var X=aa||e.rpctoken||e.ifpctok||"";
if(window.__isgadget===true){b(X,Z)
}else{Q(X,Y,Z)
}}else{m(W,Y,aa,Z)
}}return{config:function(W){if(typeof W.securityCallback==="function"){B=W.securityCallback
}},register:function(X,W){if(X===E||X===M){throw new Error("Cannot overwrite callback/ack service")
}if(X===L){throw new Error("Cannot overwrite default service: use registerDefault")
}n[X]=W
},unregister:function(W){if(W===E||W===M){throw new Error("Cannot delete callback/ack service")
}if(W===L){throw new Error("Cannot delete default service: use unregisterDefault")
}delete n[W]
},registerDefault:function(W){n[L]=W
},unregisterDefault:function(){delete n[L]
},forceParentVerifiable:function(){if(!z.isParentVerifiable()){z=gadgets.rpctx.ifpc
}},call:function(W,X,ac,aa){W=W||"..";
var ab="..";
if(W===".."){ab=p
}else{if(W.charAt(0)=="/"){ab=w(p,gadgets.rpc.getOrigin(location.href))
}}++r;
if(ac){j[r]=ac
}var Z={s:X,f:ab,c:ac?r:0,a:Array.prototype.slice.call(arguments,3),t:t[W],l:u[W]};
if(W!==".."&&q(W)==null&&!document.getElementById(W)){return
}if(F(W,Z)){return
}var Y=l[W]||z;
if(!Y){if(!v[W]){v[W]=[Z]
}else{v[W].push(Z)
}return
}if(u[W]){Y=gadgets.rpctx.ifpc
}if(Y.call(W,ab,Z)===false){l[W]=K;
z.call(W,ab,Z)
}},getRelayUrl:H,setRelayUrl:U,setAuthToken:d,setupReceiver:g,getAuthToken:x,removeReceiver:function(W){delete P[W];
delete u[W];
delete t[W];
delete k[W];
delete J[W];
delete l[W]
},getRelayChannel:function(){return z.getCode()
},receive:function(X,W){if(X.length>4){T(gadgets.json.parse(decodeURIComponent(X[X.length-1])))
}else{h.apply(null,X.concat(W))
}},receiveSameDomain:function(W){W.a=Array.prototype.slice.call(W.a);
window.setTimeout(function(){T(W)
},0)
},getOrigin:o,getTargetOrigin:D,init:function(){if(z.init(T,i)===false){z=K
}if(s){g("..")
}},_getTargetWin:V,_parseSiblingId:q,_createRelayIframe:function(W,Y){var ab=H("..");
if(!ab){return null
}var aa=ab+"#..&"+p+"&"+W+"&"+encodeURIComponent(gadgets.json.stringify(Y));
var X=document.createElement("iframe");
X.style.border=X.style.width=X.style.height="0px";
X.style.visibility="hidden";
X.style.position="absolute";
function Z(){document.body.appendChild(X);
X.src='javascript:"<html></html>"';
X.src=aa
}if(document.body){Z()
}else{gadgets.util.registerOnLoadHandler(function(){Z()
})
}return X
},ACK:M,RPC_ID:p,SEC_ERROR_LOAD_TIMEOUT:I,SEC_ERROR_FRAME_PHISH:S,SEC_ERROR_FORGED_MSG:a}
}();
gadgets.rpc.init()
};;
gadgets.config.init({"rpc":{"parentRelayUrl":"/rpc_relay.html"}});
