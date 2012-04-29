var gadgets={};;
var gadgets=gadgets||{};
gadgets.config=function(){var A={};
return{register:function(D,C,B){if(A[D]){throw new Error('Component "'+D+'" is already registered.')
}A[D]={validators:C||{},callback:B}
},get:function(B){if(B){if(!A[B]){throw new Error('Component "'+B+'" not registered.')
}return configuration[B]||{}
}return configuration
},init:function(H,G){configuration=H;
for(var F in A){if(A.hasOwnProperty(F)){var E=A[F],D=H[F],B=E.validators;
if(!G){for(var C in B){if(B.hasOwnProperty(C)){if(!B[C](D[C])){throw new Error('Invalid config value "'+D[C]+'" for parameter "'+C+'" in component "'+F+'"')
}}}}if(E.callback){E.callback(H)
}}}},EnumValidator:function(E){var D=[];
if(arguments.length>1){for(var C=0,B;
B=arguments[C];
++C){D.push(B)
}}else{D=E
}return function(G){for(var F=0,H;
H=D[F];
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
var html4={};html4 .eflags={'OPTIONAL_ENDTAG':1,'BREAKS_FLOW':2,'EMPTY':4,'NAVIGATES':8,'CDATA':16,'RCDATA':32,'UNSAFE':64};html4
.atype={'SCRIPT':1,'STYLE':2,'IDREF':3,'NAME':4,'NMTOKENS':5,'URI':6,'FRAME':7};html4
.ELEMENTS={'a':html4 .eflags.NAVIGATES,'abbr':0,'acronym':0,'address':0,'applet':html4
.eflags.UNSAFE,'area':html4 .eflags.EMPTY|html4 .eflags.NAVIGATES,'b':0,'base':html4
.eflags.UNSAFE|html4 .eflags.EMPTY,'basefont':html4 .eflags.UNSAFE|html4 .eflags.EMPTY,'bdo':0,'big':0,'blockquote':html4
.eflags.BREAKS_FLOW,'body':html4 .eflags.UNSAFE|html4 .eflags.OPTIONAL_ENDTAG,'br':html4
.eflags.EMPTY|html4 .eflags.BREAKS_FLOW,'button':0,'caption':0,'center':html4 .eflags.BREAKS_FLOW,'cite':0,'code':0,'col':html4
.eflags.EMPTY,'colgroup':html4 .eflags.OPTIONAL_ENDTAG,'dd':html4 .eflags.OPTIONAL_ENDTAG|html4
.eflags.BREAKS_FLOW,'del':0,'dfn':0,'dir':html4 .eflags.BREAKS_FLOW,'div':html4 .eflags.BREAKS_FLOW,'dl':html4
.eflags.BREAKS_FLOW,'dt':html4 .eflags.OPTIONAL_ENDTAG|html4 .eflags.BREAKS_FLOW,'em':0,'fieldset':0,'font':0,'form':html4
.eflags.BREAKS_FLOW|html4 .eflags.NAVIGATES,'frame':html4 .eflags.UNSAFE|html4 .eflags.EMPTY,'frameset':html4
.eflags.UNSAFE,'h1':html4 .eflags.BREAKS_FLOW,'h2':html4 .eflags.BREAKS_FLOW,'h3':html4
.eflags.BREAKS_FLOW,'h4':html4 .eflags.BREAKS_FLOW,'h5':html4 .eflags.BREAKS_FLOW,'h6':html4
.eflags.BREAKS_FLOW,'head':html4 .eflags.UNSAFE|html4 .eflags.OPTIONAL_ENDTAG|html4
.eflags.BREAKS_FLOW,'hr':html4 .eflags.EMPTY|html4 .eflags.BREAKS_FLOW,'html':html4
.eflags.UNSAFE|html4 .eflags.OPTIONAL_ENDTAG|html4 .eflags.BREAKS_FLOW,'i':0,'iframe':html4
.eflags.UNSAFE,'img':html4 .eflags.EMPTY,'input':html4 .eflags.EMPTY,'ins':0,'isindex':html4
.eflags.UNSAFE|html4 .eflags.EMPTY|html4 .eflags.BREAKS_FLOW|html4 .eflags.NAVIGATES,'kbd':0,'label':0,'legend':0,'li':html4
.eflags.OPTIONAL_ENDTAG|html4 .eflags.BREAKS_FLOW,'link':html4 .eflags.UNSAFE|html4
.eflags.EMPTY,'map':0,'menu':html4 .eflags.BREAKS_FLOW,'meta':html4 .eflags.UNSAFE|html4
.eflags.EMPTY,'noframes':html4 .eflags.UNSAFE|html4 .eflags.BREAKS_FLOW,'noscript':html4
.eflags.UNSAFE,'object':html4 .eflags.UNSAFE,'ol':html4 .eflags.BREAKS_FLOW,'optgroup':0,'option':html4
.eflags.OPTIONAL_ENDTAG,'p':html4 .eflags.OPTIONAL_ENDTAG|html4 .eflags.BREAKS_FLOW,'param':html4
.eflags.UNSAFE|html4 .eflags.EMPTY,'plaintext':html4 .eflags.OPTIONAL_ENDTAG|html4
.eflags.UNSAFE|html4 .eflags.CDATA,'pre':html4 .eflags.BREAKS_FLOW,'q':0,'s':0,'samp':0,'script':html4
.eflags.UNSAFE|html4 .eflags.CDATA,'select':0,'small':0,'span':0,'strike':0,'strong':0,'style':html4
.eflags.UNSAFE|html4 .eflags.CDATA,'sub':0,'sup':0,'table':html4 .eflags.BREAKS_FLOW,'tbody':html4
.eflags.OPTIONAL_ENDTAG,'td':html4 .eflags.OPTIONAL_ENDTAG|html4 .eflags.BREAKS_FLOW,'textarea':html4
.eflags.RCDATA,'tfoot':html4 .eflags.OPTIONAL_ENDTAG,'th':html4 .eflags.OPTIONAL_ENDTAG|html4
.eflags.BREAKS_FLOW,'thead':html4 .eflags.OPTIONAL_ENDTAG,'title':html4 .eflags.UNSAFE|html4
.eflags.BREAKS_FLOW|html4 .eflags.RCDATA,'tr':html4 .eflags.OPTIONAL_ENDTAG|html4
.eflags.BREAKS_FLOW,'tt':0,'u':0,'ul':html4 .eflags.BREAKS_FLOW,'var':0,'xmp':html4
.eflags.CDATA};html4 .ATTRIBS={'abbr':0,'accept':0,'accept-charset':0,'action':html4
.atype.URI,'align':0,'alink':0,'alt':0,'archive':html4 .atype.URI,'axis':0,'background':html4
.atype.URI,'bgcolor':0,'border':0,'cellpadding':0,'cellspacing':0,'char':0,'charoff':0,'charset':0,'checked':0,'cite':html4
.atype.URI,'class':html4 .atype.NMTOKENS,'classid':html4 .atype.URI,'clear':0,'code':0,'codebase':html4
.atype.URI,'codetype':0,'color':0,'cols':0,'colspan':0,'compact':0,'content':0,'coords':0,'data':html4
.atype.URI,'datetime':0,'declare':0,'defer':0,'dir':0,'disabled':0,'enctype':0,'face':0,'for':html4
.atype.IDREF,'frame':0,'frameborder':0,'headers':0,'height':0,'href':html4 .atype.URI,'hreflang':0,'hspace':0,'id':html4
.atype.IDREF,'ismap':0,'label':0,'lang':0,'language':0,'link':0,'longdesc':html4
.atype.URI,'marginheight':0,'marginwidth':0,'maxlength':0,'media':0,'method':0,'multiple':0,'name':html4
.atype.NAME,'nohref':0,'noresize':0,'noshade':0,'nowrap':0,'object':0,'onblur':html4
.atype.SCRIPT,'onchange':html4 .atype.SCRIPT,'onclick':html4 .atype.SCRIPT,'ondblclick':html4
.atype.SCRIPT,'onfocus':html4 .atype.SCRIPT,'onkeydown':html4 .atype.SCRIPT,'onkeypress':html4
.atype.SCRIPT,'onkeyup':html4 .atype.SCRIPT,'onload':html4 .atype.SCRIPT,'onmousedown':html4
.atype.SCRIPT,'onmousemove':html4 .atype.SCRIPT,'onmouseout':html4 .atype.SCRIPT,'onmouseover':html4
.atype.SCRIPT,'onmouseup':html4 .atype.SCRIPT,'onreset':html4 .atype.SCRIPT,'onselect':html4
.atype.SCRIPT,'onsubmit':html4 .atype.SCRIPT,'onunload':html4 .atype.SCRIPT,'profile':html4
.atype.URI,'prompt':0,'readonly':0,'rel':0,'rev':0,'rows':0,'rowspan':0,'rules':0,'scheme':0,'scope':0,'scrolling':0,'selected':0,'shape':0,'size':0,'span':0,'src':html4
.atype.URI,'standby':0,'start':0,'style':html4 .atype.STYLE,'summary':0,'tabindex':0,'target':html4
.atype.FRAME,'text':0,'title':0,'type':0,'usemap':html4 .atype.URI,'valign':0,'value':0,'valuetype':0,'version':0,'vlink':0,'vspace':0,'width':0};var
css={'properties':(function(){var c=[/^\s*inherit\s+$/i,/^\s*(?:#(?:[0-9a-f]{3}){1,2}|aqua|black|blue|fuchsia|gray|green|lime|maroon|navy|olive|purple|red|silver|teal|white|yellow|transparent|inherit)\s+$/i,/^\s*(?:none|hidden|dotted|dashed|solid|double|groove|ridge|inset|outset|inherit)\s+$/i,/^\s*(?:thin|medium|thick|0|[+-]?\d+(?:\.\d+)?(?:em|ex|px|in|cm|mm|pt|pc)|inherit)\s+$/i,/^\s*(?:none|inherit)\s+$/i,/^\s*(?:url\("[^\(\)\\\"\r\n]+"\)|none|inherit)\s+$/i,/^\s*(?:0|[+-]?\d+(?:\.\d+)?(?:em|ex|px|in|cm|mm|pt|pc)|0|(?:\d+(?:\.\d+)?)%|auto|inherit)\s+$/i,/^\s*(?:0|(?:\d+(?:\.\d+)?)(?:em|ex|px|in|cm|mm|pt|pc)|0|[+-]?\d+(?:\.\d+)?%|none|inherit)\s+$/i,/^\s*(?:0|(?:\d+(?:\.\d+)?)(?:em|ex|px|in|cm|mm|pt|pc)|0|[+-]?\d+(?:\.\d+)?%|inherit)\s+$/i,/^\s*(?:auto|always|avoid|left|right|inherit)\s+$/i,/^\s*(?:0|[+-]?\d+(?:\.\d+)?m?s|0|(?:\d+(?:\.\d+)?)%|inherit)\s+$/i,/^\s*(?:0|[+-]?\d+(?:\.\d+)?|inherit)\s+$/i,/^\s*(?:normal|0|(?:\d+(?:\.\d+)?)(?:em|ex|px|in|cm|mm|pt|pc)|inherit)\s+$/i];return{'azimuth':/^\s*(?:0|[+-]?\d+(?:\.\d+)?(?:deg|g?rad)|leftwards|rightwards|inherit)\s+$/i,'background':c[0],'backgroundAttachment':/^\s*(?:scroll|fixed|inherit)\s+$/i,'backgroundColor':c[1],'backgroundImage':c[5],'backgroundPosition':/^\s*(?:(?:0|(?:\d+(?:\.\d+)?)%|0|[+-]?\d+(?:\.\d+)?(?:em|ex|px|in|cm|mm|pt|pc)|left|center|right)\s+(?:(?:0|(?:\d+(?:\.\d+)?)%|0|[+-]?\d+(?:\.\d+)?(?:em|ex|px|in|cm|mm|pt|pc)|top|center|bottom)\s+)?|inherit\s+)$/i,'backgroundRepeat':/^\s*(?:repeat|repeat-x|repeat-y|no-repeat|inherit)\s+$/i,'border':c[0],'borderBottom':c[0],'borderBottomColor':c[1],'borderBottomStyle':c[2],'borderBottomWidth':c[3],'borderCollapse':/^\s*(?:collapse|separate|inherit)\s+$/i,'borderColor':/^\s*(?:(?:(?:#(?:[0-9a-f]{3}){1,2}|aqua|black|blue|fuchsia|gray|green|lime|maroon|navy|olive|purple|red|silver|teal|white|yellow|transparent)\s+){1,4}|inherit\s+)$/i,'borderLeft':c[0],'borderLeftColor':c[1],'borderLeftStyle':c[2],'borderLeftWidth':c[3],'borderRight':c[0],'borderRightColor':c[1],'borderRightStyle':c[2],'borderRightWidth':c[3],'borderSpacing':/^\s*(?:0|[+-]?\d+(?:\.\d+)?(?:em|ex|px|in|cm|mm|pt|pc)\s+(?:0|[+-]?\d+(?:\.\d+)?(?:em|ex|px|in|cm|mm|pt|pc)\s+)?|inherit\s+)$/i,'borderStyle':/^\s*(?:(?:(?:none|hidden|dotted|dashed|solid|double|groove|ridge|inset|outset)\s+){1,4}|inherit\s+)$/i,'borderTop':c[0],'borderTopColor':c[1],'borderTopStyle':c[2],'borderTopWidth':c[3],'borderWidth':/^\s*(?:(?:(?:thin|medium|thick|0|[+-]?\d+(?:\.\d+)?(?:em|ex|px|in|cm|mm|pt|pc))\s+){1,4}|inherit\s+)$/i,'bottom':c[6],'captionSide':/^\s*(?:top|bottom|inherit)\s+$/i,'clear':/^\s*(?:none|left|right|both|inherit)\s+$/i,'clip':/^\s*(?:auto|inherit)\s+$/i,'color':/^\s*(?:#(?:[0-9a-f]{3}){1,2}|aqua|black|blue|fuchsia|gray|green|lime|maroon|navy|olive|purple|red|silver|teal|white|yellow|inherit)\s+$/i,'counterIncrement':c[4],'counterReset':c[4],'cssFloat':/^\s*(?:left|right|none|inherit)\s+$/i,'cue':c[0],'cueAfter':c[5],'cueBefore':c[5],'cursor':/^\s*(?:(?:url\("[^\(\)\\\"\r\n]+"\)\s+,\s+)*(?:auto|crosshair|default|pointer|move|e-resize|ne-resize|nw-resize|n-resize|se-resize|sw-resize|s-resize|w-resize|text|wait|help|progress|all-scroll|col-resize|hand|no-drop|not-allowed|row-resize|vertical-text)|inherit)\s+$/i,'direction':/^\s*(?:ltr|rtl|inherit)\s+$/i,'display':/^\s*(?:inline|block|list-item|run-in|inline-block|table|inline-table|table-row-group|table-header-group|table-footer-group|table-row|table-column-group|table-column|table-cell|table-caption|none|inherit)\s+$/i,'elevation':/^\s*(?:0|[+-]?\d+(?:\.\d+)?(?:deg|g?rad)|below|level|above|higher|lower|inherit)\s+$/i,'emptyCells':/^\s*(?:show|hide|inherit)\s+$/i,'font':/^\s*(?:caption|icon|menu|message-box|small-caption|status-bar|inherit)\s+$/i,'fontFamily':/^\s*(?:(?:"\w(?:[\w-]*\w)(?:\s+\w([\w-]*\w))*"|serif|sans-serif|cursive|fantasy|monospace)\s+(?:,\s+(?:"\w(?:[\w-]*\w)(?:\s+\w([\w-]*\w))*"|serif|sans-serif|cursive|fantasy|monospace)\s+)*|inherit\s+)$/i,'fontSize':/^\s*(?:xx-small|x-small|small|medium|large|x-large|xx-large|(?:small|larg)er|0|(?:\d+(?:\.\d+)?)(?:em|ex|px|in|cm|mm|pt|pc)|0|[+-]?\d+(?:\.\d+)?%|inherit)\s+$/i,'fontStyle':/^\s*(?:normal|italic|oblique|inherit)\s+$/i,'fontVariant':/^\s*(?:normal|small-caps|inherit)\s+$/i,'fontWeight':/^\s*(?:normal|bold|bolder|lighter|100|200|300|400|500|600|700|800|900|inherit)\s+$/i,'height':c[6],'left':c[6],'letterSpacing':c[12],'lineHeight':/^\s*(?:normal|0|(?:\d+(?:\.\d+)?)|0|(?:\d+(?:\.\d+)?)(?:em|ex|px|in|cm|mm|pt|pc)|0|[+-]?\d+(?:\.\d+)?%|inherit)\s+$/i,'listStyle':c[0],'listStyleImage':c[5],'listStylePosition':/^\s*(?:inside|outside|inherit)\s+$/i,'listStyleType':/^\s*(?:disc|circle|square|decimal|decimal-leading-zero|lower-roman|upper-roman|lower-greek|lower-latin|upper-latin|armenian|georgian|lower-alpha|upper-alpha|none|inherit)\s+$/i,'margin':/^\s*(?:(?:(?:0|[+-]?\d+(?:\.\d+)?(?:em|ex|px|in|cm|mm|pt|pc)|0|(?:\d+(?:\.\d+)?)%|auto)\s+){1,4}|inherit\s+)$/i,'marginBottom':c[6],'marginLeft':c[6],'marginRight':c[6],'marginTop':c[6],'maxHeight':c[7],'maxWidth':c[7],'minHeight':c[8],'minWidth':c[8],'outline':c[0],'outlineColor':/^\s*(?:#(?:[0-9a-f]{3}){1,2}|aqua|black|blue|fuchsia|gray|green|lime|maroon|navy|olive|purple|red|silver|teal|white|yellow|invert|inherit)\s+$/i,'outlineStyle':c[2],'outlineWidth':c[3],'overflow':/^\s*(?:visible|hidden|scroll|auto|inherit)\s+$/i,'padding':/^\s*(?:(?:(?:0|(?:\d+(?:\.\d+)?)(?:em|ex|px|in|cm|mm|pt|pc)|0|[+-]?\d+(?:\.\d+)?%)\s+){1,4}|inherit\s+)$/i,'paddingBottom':c[8],'paddingLeft':c[8],'paddingRight':c[8],'paddingTop':c[8],'pageBreakAfter':c[9],'pageBreakBefore':c[9],'pageBreakInside':/^\s*(?:avoid|auto|inherit)\s+$/i,'pause':/^\s*(?:(?:(?:0|[+-]?\d+(?:\.\d+)?m?s|0|(?:\d+(?:\.\d+)?)%)\s+){1,2}|inherit\s+)$/i,'pauseAfter':c[10],'pauseBefore':c[10],'pitch':/^\s*(?:0|(?:\d+(?:\.\d+)?)k?Hz|x-low|low|medium|high|x-high|inherit)\s+$/i,'pitchRange':c[11],'playDuring':/^\s*(?:auto|none|inherit)\s+$/i,'position':/^\s*(?:static|relative|absolute|fixed|inherit)\s+$/i,'quotes':c[4],'richness':c[11],'right':c[6],'speak':/^\s*(?:normal|none|spell-out|inherit)\s+$/i,'speakHeader':/^\s*(?:once|always|inherit)\s+$/i,'speakNumeral':/^\s*(?:digits|continuous|inherit)\s+$/i,'speakPunctuation':/^\s*(?:code|none|inherit)\s+$/i,'speechRate':/^\s*(?:0|[+-]?\d+(?:\.\d+)?|x-slow|slow|medium|fast|x-fast|faster|slower|inherit)\s+$/i,'stress':c[11],'tableLayout':/^\s*(?:auto|fixed|inherit)\s+$/i,'textAlign':/^\s*(?:left|right|center|justify|inherit)\s+$/i,'textDecoration':c[4],'textIndent':/^\s*(?:0|[+-]?\d+(?:\.\d+)?(?:em|ex|px|in|cm|mm|pt|pc)|0|(?:\d+(?:\.\d+)?)%|inherit)\s+$/i,'textTransform':/^\s*(?:capitalize|uppercase|lowercase|none|inherit)\s+$/i,'top':c[6],'unicodeBidi':/^\s*(?:normal|embed|bidi-override|inherit)\s+$/i,'verticalAlign':/^\s*(?:baseline|sub|super|top|text-top|middle|bottom|text-bottom|0|(?:\d+(?:\.\d+)?)%|0|[+-]?\d+(?:\.\d+)?(?:em|ex|px|in|cm|mm|pt|pc)|inherit)\s+$/i,'visibility':/^\s*(?:visible|hidden|collapse|inherit)\s+$/i,'voiceFamily':/^\s*(?:(?:(?:"\w(?:[\w-]*\w)(?:\s+\w([\w-]*\w))*"|male|female|child)\s+,\s+)*(?:"\w(?:[\w-]*\w)(?:\s+\w([\w-]*\w))*"|male|female|child)|inherit)\s+$/i,'volume':/^\s*(?:0|(?:\d+(?:\.\d+)?)|0|[+-]?\d+(?:\.\d+)?%|silent|x-soft|soft|medium|loud|x-loud|inherit)\s+$/i,'whiteSpace':/^\s*(?:normal|pre|nowrap|pre-wrap|pre-line|inherit)\s+$/i,'width':/^\s*(?:0|(?:\d+(?:\.\d+)?)(?:em|ex|px|in|cm|mm|pt|pc)|0|[+-]?\d+(?:\.\d+)?%|auto|inherit)\s+$/i,'wordSpacing':c[12],'zIndex':/^\s*(?:auto|\d+|inherit)\s+$/i};})()};var
html=(function(){var ENTITIES={'LT':'<','GT':'>','AMP':'&','NBSP':'\xa0','QUOT':'\"','APOS':'\''};var
decimalEscapeRe=/^#(\d+)$/;var hexEscapeRe=/^#x([0-9A-F]+)$/;function lookupEntity(name){name=name.toUpperCase();if(ENTITIES.hasOwnProperty(name)){return ENTITIES[name];}var
m=name.match(decimalEscapeRe);if(m){return String.fromCharCode(parseInt(m[1],10));}else
if(!(!(m=name.match(hexEscapeRe)))){return String.fromCharCode(parseInt(m[1],16));}return'';}function
decodeOneEntity(_,name){return lookupEntity(name);}var entityRe=/&(#\d+|#x[\da-f]+|\w+);/g;function
unescapeEntities(s){return s.replace(entityRe,decodeOneEntity);}var ampRe=/&/g;var
looseAmpRe=/&([^a-z#]|#(?:[^0-9x]|x(?:[^0-9a-f]|$)|$)|$)/gi;var ltRe=/</g;var gtRe=/>/g;var
quotRe=/\"/g;function escapeAttrib(s){return s.replace(ampRe,'&amp;').replace(ltRe,'&lt;').replace(gtRe,'&gt;').replace(quotRe,'&quot;');}function
normalizeRCData(rcdata){return rcdata.replace(looseAmpRe,'&amp;$1').replace(ltRe,'&lt;').replace(gtRe,'&gt;');}var
INSIDE_TAG_TOKEN=new RegExp('^\\s*(?:'+('(?:'+'([a-z][a-z-]*)'+('(?:'+'\\s*=\\s*'+('(?:'+'\"([^\"]*)\"'+'|\'([^\']*)\''+'|([^>\"\'\\s]*)'+')')+')')+'?'+')')+'|(/?>)'+'|[^\\w\\s>]+)','i');var
OUTSIDE_TAG_TOKEN=new RegExp('^(?:'+'&(\\#[0-9]+|\\#[x][0-9a-f]+|\\w+);'+'|<!--[\\s\\S]*?-->|<!w[^>]*>|<\\?[^>*]*>'+'|<(/)?([a-z][a-z0-9]*)'+'|([^<&]+)'+'|([<&]))','i');function
makeSaxParser(handler){return function parse(htmlText,param){htmlText=String(htmlText);var
htmlUpper=null;var inTag=false;var attribs=[];var tagName;var eflags;var openTag;handler.startDoc&&handler.startDoc(param);while(htmlText){var
m=htmlText.match(inTag?INSIDE_TAG_TOKEN:OUTSIDE_TAG_TOKEN);htmlText=htmlText.substring(m[0].length);if(inTag){if(m[1]){var
attribName=m[1].toLowerCase();var encodedValue=m[2]||m[3]||m[4];var decodedValue;if(encodedValue!=null){decodedValue=unescapeEntities(encodedValue);}else{decodedValue=attribName;}attribs.push(attribName,decodedValue);}else
if(m[5]){if(eflags!==undefined){if(openTag){handler.startTag&&handler.startTag(tagName,attribs,param);}else{handler.endTag&&handler.endTag(tagName,param);}}if(openTag&&eflags&(html4
.eflags.CDATA|html4 .eflags.RCDATA)){if(htmlUpper===null){htmlUpper=htmlText.toLowerCase();}else{htmlUpper=htmlUpper.substring(htmlUpper.length-htmlText.length);}var
dataEnd=htmlUpper.indexOf('</'+tagName);if(dataEnd<0){dataEnd=htmlText.length;}if(eflags&html4
.eflags.CDATA){handler.cdata&&handler.cdata(htmlText.substring(0,dataEnd),param);}else
if(handler.rcdata){handler.rcdata(normalizeRCData(htmlText.substring(0,dataEnd)),param);}htmlText=htmlText.substring(dataEnd);}tagName=eflags=openTag=undefined;attribs.length=0;inTag=false;}}else{if(m[1]){handler.pcdata&&handler.pcdata(m[0],param);}else
if(m[3]){openTag=!m[2];inTag=true;tagName=m[3].toLowerCase();eflags=html4 .ELEMENTS.hasOwnProperty(tagName)?html4
.ELEMENTS[tagName]:undefined;}else if(m[4]){handler.pcdata&&handler.pcdata(m[4],param);}else
if(m[5]){handler.pcdata&&handler.pcdata(m[5]==='&'?'&amp;':'&lt;',param);}}}handler.endDoc&&handler.endDoc(param);};}return{'normalizeRCData':normalizeRCData,'escapeAttrib':escapeAttrib,'unescapeEntities':unescapeEntities,'makeSaxParser':makeSaxParser};})();html.makeHtmlSanitizer=function(sanitizeAttributes){var
stack=[];var ignoring=false;return html.makeSaxParser({'startDoc':function(_){stack=[];ignoring=false;},'startTag':function(tagName,attribs,out){if(ignoring){return undefined;}if(!html4
.ELEMENTS.hasOwnProperty(tagName)){return undefined;}var eflags=html4 .ELEMENTS[tagName];if(eflags&html4
.eflags.UNSAFE){ignoring=!(eflags&html4 .eflags.EMPTY);return undefined;}attribs=sanitizeAttributes(tagName,attribs);if(attribs){if(!(eflags&html4
.eflags.EMPTY)){stack.push(tagName);}out.push('<',tagName);for(var i=0,n=attribs.length;i<n;i+=2){var
attribName=attribs[i],value=attribs[i+1];if(value!=null){out.push(' ',attribName,'=\"',html.escapeAttrib(value),'\"');}}out.push('>');}},'endTag':function(tagName,out){if(ignoring){ignoring=false;return undefined;}if(!html4
.ELEMENTS.hasOwnProperty(tagName)){return undefined;}var eflags=html4 .ELEMENTS[tagName];if(!(eflags&(html4
.eflags.UNSAFE|html4 .eflags.EMPTY))){var index;if(eflags&html4 .eflags.OPTIONAL_ENDTAG){for(index=stack.length;--index>=0;){var
stackEl=stack[index];if(stackEl===tagName){break;}if(!(html4 .ELEMENTS[stackEl]&html4
.eflags.OPTIONAL_ENDTAG)){return undefined;}}}else{for(index=stack.length;--index>=0;){if(stack[index]===tagName){break;}}}if(index<0){return undefined;}for(var
i=stack.length;--i>index;){var stackEl=stack[i];if(!(html4 .ELEMENTS[stackEl]&html4
.eflags.OPTIONAL_ENDTAG)){out.push('</',stackEl,'>');}}stack.length=index;out.push('</',tagName,'>');}},'pcdata':function(text,out){if(!ignoring){out.push(text);}},'rcdata':function(text,out){if(!ignoring){out.push(text);}},'cdata':function(text,out){if(!ignoring){out.push(text);}},'endDoc':function(out){for(var
i=stack.length;--i>=0;){out.push('</',stack[i],'>');}stack.length=0;}});};function
html_sanitize(htmlText,opt_urlPolicy,opt_nmTokenPolicy){var out=[];html.makeHtmlSanitizer(function
sanitizeAttribs(tagName,attribs){for(var i=0;i<attribs.length;i+=2){var attribName=attribs[i];var
value=attribs[i+1];if(html4 .ATTRIBS.hasOwnProperty(attribName)){switch(html4 .ATTRIBS[attribName]){case
html4 .atype.SCRIPT:;case html4 .atype.STYLE:value=null;case html4 .atype.IDREF:;case
html4 .atype.NAME:;case html4 .atype.NMTOKENS:{value=opt_nmTokenPolicy?opt_nmTokenPolicy(value):value;break;}case
html4 .atype.URI:{value=opt_urlPolicy&&opt_urlPolicy(value);break;}}}else{value=null;}attribs[i+1]=value;}return attribs;})(htmlText,out);return out.join('');};
var gadgets=gadgets||{};
gadgets.util=function(){function F(){var K;
var J=document.location.href;
var H=J.indexOf("?");
var I=J.indexOf("#");
if(I===-1){K=J.substr(H+1)
}else{K=[J.substr(H+1,I-H-1),"&",J.substr(I+1)].join("")
}return K.split("&")
}var D=null;
var C={};
var E=[];
var A={0:false,10:true,13:true,34:true,39:true,60:true,62:true,92:true,8232:true,8233:true};
function B(H,I){return String.fromCharCode(I)
}function G(H){C=H["core.util"]||{}
}if(gadgets.config){gadgets.config.register("core.util",null,G)
}return{getUrlParameters:function(){if(D!==null){return D
}D={};
var K=F();
var N=window.decodeURIComponent?decodeURIComponent:unescape;
for(var I=0,H=K.length;
I<H;
++I){var M=K[I].indexOf("=");
if(M===-1){continue
}var L=K[I].substring(0,M);
var J=K[I].substring(M+1);
J=J.replace(/\+/g," ");
D[L]=N(J)
}return D
},makeClosure:function(K,M,L){var J=[];
for(var I=2,H=arguments.length;
I<H;
++I){J.push(arguments[I])
}return function(){var N=J.slice();
for(var P=0,O=arguments.length;
P<O;
++P){N.push(arguments[P])
}return M.apply(K,N)
}
},makeEnum:function(I){var K={};
for(var J=0,H;
H=I[J];
++J){K[H]=H
}return K
},getFeatureParameters:function(H){return typeof C[H]==="undefined"?null:C[H]
},hasFeature:function(H){return typeof C[H]!=="undefined"
},registerOnLoadHandler:function(H){E.push(H)
},runOnLoadHandlers:function(){for(var I=0,H=E.length;
I<H;
++I){E[I]()
}},escape:function(H,L){if(!H){return H
}else{if(typeof H==="string"){return gadgets.util.escapeString(H)
}else{if(typeof H==="array"){for(var K=0,I=H.length;
K<I;
++K){H[K]=gadgets.util.escape(H[K])
}}else{if(typeof H==="object"&&L){var J={};
for(var M in H){if(H.hasOwnProperty(M)){J[gadgets.util.escapeString(M)]=gadgets.util.escape(H[M],true)
}}return J
}}}}return H
},escapeString:function(L){var I=[],K,M;
for(var J=0,H=L.length;
J<H;
++J){K=L.charCodeAt(J);
M=A[K];
if(M===true){I.push("&#",K,";")
}else{if(M!==false){I.push(L.charAt(J))
}}}return I.join("")
},unescapeString:function(H){return H.replace(/&#([0-9]+);/g,B)
}}
}();
gadgets.util.getUrlParameters();;
var shindig=shindig||{};
shindig.Auth=function(){var authToken=null;
var trusted=null;
function init(configuration){var urlParams=gadgets.util.getUrlParameters();
var config=configuration["shindig.auth"]||{};
if(config.authToken){authToken=config.authToken
}else{if(urlParams.st){authToken=urlParams.st
}}if(authToken!=null){addParamsToToken(urlParams)
}if(config.trustedJson){trusted=eval("("+config.trustedJson+")")
}}function addParamsToToken(urlParams){var args=authToken.split("&");
for(var i=0;
i<args.length;
i++){var nameAndValue=args[i].split("=");
if(nameAndValue.length==2){var name=nameAndValue[0];
var value=nameAndValue[1];
if(value==="$"){value=encodeURIComponent(urlParams[name]);
args[i]=name+"="+value
}}}authToken=args.join("&")
}gadgets.config.register("shindig.auth",null,init);
return{getSecurityToken:function(){return authToken
},updateSecurityToken:function(newToken){authToken=newToken
},getTrustedData:function(){return trusted
}}
};;
var shindig=shindig||{};
shindig.auth=new shindig.Auth();;
var gadgets=gadgets||{};
(function(){var B=null;
var C={};
var E={};
var G="en";
var F="US";
var D=0;
function A(){var I=gadgets.util.getUrlParameters();
for(var H in I){if(I.hasOwnProperty(H)){if(H.indexOf("up_")===0&&H.length>3){C[H.substr(3)]=String(I[H])
}else{if(H==="country"){F=I[H]
}else{if(H==="lang"){G=I[H]
}else{if(H==="mid"){D=I[H]
}}}}}}}gadgets.Prefs=function(){if(!B){A();
B=this
}return B
};
gadgets.Prefs.setInternal_=function(I,J){if(typeof I==="string"){C[I]=J
}else{for(var H in I){if(I.hasOwnProperty(H)){C[H]=I[H]
}}}};
gadgets.Prefs.setMessages_=function(H){msgs=H
};
gadgets.Prefs.prototype.getString=function(H){return C[H]?gadgets.util.escapeString(C[H]):""
};
gadgets.Prefs.prototype.getInt=function(H){var I=parseInt(C[H],10);
return isNaN(I)?0:I
};
gadgets.Prefs.prototype.getFloat=function(H){var I=parseFloat(C[H]);
return isNaN(I)?0:I
};
gadgets.Prefs.prototype.getBool=function(H){var I=C[H];
if(I){return I==="true"||I===true||!!parseInt(I,10)
}return false
};
gadgets.Prefs.prototype.set=function(H,I){throw new Error("setprefs feature required to make this call.")
};
gadgets.Prefs.prototype.getArray=function(L){var M=C[L];
if(M){var H=M.split("|");
var I=gadgets.util.escapeString;
for(var K=0,J=H.length;
K<J;
++K){H[K]=I(H[K].replace(/%7C/g,"|"))
}return H
}return[]
};
gadgets.Prefs.prototype.setArray=function(H,I){throw new Error("setprefs feature required to make this call.")
};
gadgets.Prefs.prototype.getMsg=function(H){return msgs[H]||""
};
gadgets.Prefs.prototype.getCountry=function(){return F
};
gadgets.Prefs.prototype.getLang=function(){return G
};
gadgets.Prefs.prototype.getModuleId=function(){return D
}
})();;
var gadgets=gadgets||{};
gadgets.json=function(){function f(n){return n<10?"0"+n:n
}Date.prototype.toJSON=function(){return[this.getUTCFullYear(),"-",f(this.getUTCMonth()+1),"-",f(this.getUTCDate()),"T",f(this.getUTCHours()),":",f(this.getUTCMinutes()),":",f(this.getUTCSeconds()),"Z"].join("")
};
var m={"\b":"\\b","\t":"\\t","\n":"\\n","\f":"\\f","\r":"\\r",'"':'\\"',"\\":"\\\\"};
function stringify(value){var a,i,k,l,r=/["\\\x00-\x1f\x7f-\x9f]/g,v;
switch(typeof value){case"string":return r.test(value)?'"'+value.replace(r,function(a){var c=m[a];
if(c){return c
}c=a.charCodeAt(0);
return"\\u00"+Math.floor(c/16).toString(16)+(c%16).toString(16)
})+'"':'"'+value+'"';
case"number":return isFinite(value)?String(value):"null";
case"boolean":case"null":return String(value);
case"object":if(!value){return"null"
}a=[];
if(typeof value.length==="number"&&!(value.propertyIsEnumerable("length"))){l=value.length;
for(i=0;
i<l;
i+=1){a.push(stringify(value[i])||"null")
}return"["+a.join(",")+"]"
}for(k in value){if(value.hasOwnProperty(k)){if(typeof k==="string"){v=stringify(value[k]);
if(v){a.push(stringify(k)+":"+v)
}}}}return"{"+a.join(",")+"}"
}}return{stringify:stringify,parse:function(text){if(/^[\],:{}\s]*$/.test(text.replace(/\\["\\\/b-u]/g,"@").replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g,"]").replace(/(?:^|:|,)(?:\s*\[)+/g,""))){return eval("("+text+")")
}return false
}}
}();;
var JSON=gadgets.json;
var _IG_Prefs=gadgets.Prefs;
_IG_Prefs._parseURL=gadgets.Prefs.parseUrl;
function _IG_Fetch_wrapper(B,A){B(A.data)
}function _IG_FetchContent(B,E,C){var D=C||{};
if(D.refreshInterval){D.REFRESH_INTERVAL=D.refreshInterval
}else{D.REFRESH_INTERVAL=3600
}var A=gadgets.util.makeClosure(null,_IG_Fetch_wrapper,E);
gadgets.io.makeRequest(B,A,D)
}function _IG_FetchXmlContent(B,E,C){var D=C||{};
if(D.refreshInterval){D.REFRESH_INTERVAL=D.refreshInterval
}else{D.REFRESH_INTERVAL=3600
}D.CONTENT_TYPE="DOM";
var A=gadgets.util.makeClosure(null,_IG_Fetch_wrapper,E);
gadgets.io.makeRequest(B,A,D)
}function _IG_FetchFeedAsJSON(B,F,C,A,D){var E=D||{};
E.CONTENT_TYPE="FEED";
E.NUM_ENTRIES=C;
E.GET_SUMMARIES=A;
gadgets.io.makeRequest(B,function(G){if(G.errors){G.data=G.data||{};
if(G.errors&&G.errors.length>0){G.data.ErrorMsg=G.errors[0]
}}F(G.data)
},E)
}function _IG_GetCachedUrl(A){return gadgets.io.getProxyUrl(A)
}function _IG_GetImageUrl(A){return gadgets.io.getProxyUrl(A)
}function _IG_RegisterOnloadHandler(A){gadgets.util.registerOnLoadHandler(A)
}function _IG_Callback(B,C){var A=arguments;
return function(){var D=Array.prototype.slice.call(arguments);
B.apply(null,D.concat(Array.prototype.slice.call(A,1)))
}
}var _args=gadgets.util.getUrlParameters;
function _gel(A){return document.getElementById?document.getElementById(A):null
}function _gelstn(A){if(A==="*"&&document.all){return document.all
}return document.getElementsByTagName?document.getElementsByTagName(A):[]
}function _gelsbyregex(D,F){var C=_gelstn(D);
var E=[];
for(var B=0,A=C.length;
B<A;
++B){if(F.test(C[B].id)){E.push(C[B])
}}return E
}function _esc(A){return window.encodeURIComponent?encodeURIComponent(A):escape(A)
}function _unesc(A){return window.decodeURIComponent?decodeURIComponent(A):unescape(A)
}function _hesc(A){return gadgets.util.escapeString(A)
}function _striptags(A){return A.replace(/<\/?[^>]+>/g,"")
}function _trim(A){return A.replace(/^\s+|\s+$/g,"")
}function _toggle(A){A=_gel(A);
if(A!==null){if(A.style.display.length===0||A.style.display==="block"){A.style.display="none"
}else{if(A.style.display==="none"){A.style.display="block"
}}}}var _global_legacy_uidCounter=0;
function _uid(){return _global_legacy_uidCounter++
}function _min(B,A){return(B<A?B:A)
}function _max(B,A){return(B>A?B:A)
}function _exportSymbols(A,B){var H={};
for(var I=0,F=B.length;
I<F;
I+=2){H[B[I]]=B[I+1]
}var E=A.split(".");
var J=window;
for(var D=0,C=E.length-1;
D<C;
++D){var G={};
J[E[D]]=G;
J=G
}J[E[E.length-1]]=H
};;
var gadgets=gadgets||{};
gadgets.io=function(){var config={};
var oauthState;
function makeXhr(){if(window.XMLHttpRequest){return new window.XMLHttpRequest()
}else{if(window.ActiveXObject){var x=new ActiveXObject("Msxml2.XMLHTTP");
if(!x){x=new ActiveXObject("Microsoft.XMLHTTP")
}return x
}}}function hadError(xobj,callback){if(xobj.readyState!==4){return true
}try{if(xobj.status!==200){callback({errors:["Error "+xobj.status]});
return true
}}catch(e){callback({errors:["Error not specified"]});
return true
}return false
}function processNonProxiedResponse(url,callback,params,xobj){if(hadError(xobj,callback)){return 
}var data={body:xobj.responseText};
callback(transformResponseData(params,data))
}var UNPARSEABLE_CRUFT="throw 1; < don't be evil' >";
function processResponse(url,callback,params,xobj){if(hadError(xobj,callback)){return 
}var txt=xobj.responseText;
txt=txt.substr(UNPARSEABLE_CRUFT.length);
var data=eval("("+txt+")");
data=data[url];
if(data.oauthState){oauthState=data.oauthState
}if(data.st){shindig.auth.updateSecurityToken(data.st)
}callback(transformResponseData(params,data))
}function transformResponseData(params,data){var resp={text:data.body,rc:data.rc,headers:data.headers,oauthApprovalUrl:data.oauthApprovalUrl,oauthError:data.oauthError,oauthErrorText:data.oauthErrorText,errors:[]};
if(resp.text){switch(params.CONTENT_TYPE){case"JSON":case"FEED":resp.data=gadgets.json.parse(resp.text);
if(!resp.data){resp.errors.push("failed to parse JSON");
resp.data=null
}break;
case"DOM":var dom;
if(window.ActiveXObject){dom=new ActiveXObject("Microsoft.XMLDOM");
dom.async=false;
dom.validateOnParse=false;
dom.resolveExternals=false;
if(!dom.loadXML(resp.text)){resp.errors.push("failed to parse XML")
}else{resp.data=dom
}}else{var parser=new DOMParser();
dom=parser.parseFromString(resp.text,"text/xml");
if("parsererror"===dom.documentElement.nodeName){resp.errors.push("failed to parse XML")
}else{resp.data=dom
}}break;
default:resp.data=resp.text;
break
}}return resp
}function makeXhrRequest(realUrl,proxyUrl,callback,paramData,method,params,processResponseFunction,opt_contentType){var xhr=makeXhr();
xhr.open(method,proxyUrl,true);
if(callback){xhr.onreadystatechange=gadgets.util.makeClosure(null,processResponseFunction,realUrl,callback,params,xhr)
}if(paramData!=null){xhr.setRequestHeader("Content-Type",opt_contentType||"application/x-www-form-urlencoded");
xhr.send(paramData)
}else{xhr.send(null)
}}function respondWithPreload(postData,params,callback){if(gadgets.io.preloaded_&&gadgets.io.preloaded_[postData.url]){var preload=gadgets.io.preloaded_[postData.url];
if(postData.httpMethod=="GET"){delete gadgets.io.preloaded_[postData.url];
if(preload.rc!==200){callback({errors:["Error "+preload.rc]})
}else{if(preload.oauthState){oauthState=preload.oauthState
}var resp={body:preload.body,rc:preload.rc,headers:preload.headers,oauthApprovalUrl:preload.oauthApprovalUrl,oauthError:preload.oauthError,oauthErrorText:preload.oauthErrorText,errors:[]};
callback(transformResponseData(params,resp))
}return true
}}return false
}function init(configuration){config=configuration["core.io"]
}var requiredConfig={proxyUrl:new gadgets.config.RegExValidator(/.*%(raw)?url%.*/),jsonProxyUrl:gadgets.config.NonEmptyStringValidator};
gadgets.config.register("core.io",requiredConfig,init);
return{makeRequest:function(url,callback,opt_params){var params=opt_params||{};
var httpMethod=params.METHOD||"GET";
var refreshInterval=params.REFRESH_INTERVAL;
var auth,st;
if(params.AUTHORIZATION&&params.AUTHORIZATION!=="NONE"){auth=params.AUTHORIZATION.toLowerCase();
st=shindig.auth.getSecurityToken()
}else{if(httpMethod==="GET"&&refreshInterval===undefined){refreshInterval=3600
}}var signOwner=true;
if(typeof params.OWNER_SIGNED!=="undefined"){signOwner=params.OWNER_SIGNED
}var signViewer=true;
if(typeof params.VIEWER_SIGNED!=="undefined"){signViewer=params.VIEWER_SIGNED
}var headers=params.HEADERS||{};
if(httpMethod==="POST"&&!headers["Content-Type"]){headers["Content-Type"]="application/x-www-form-urlencoded"
}var urlParams=gadgets.util.getUrlParameters();
var paramData={url:url,httpMethod:httpMethod,headers:gadgets.io.encodeValues(headers,false),postData:params.POST_DATA||"",authz:auth||"",st:st||"",contentType:params.CONTENT_TYPE||"TEXT",numEntries:params.NUM_ENTRIES||"3",getSummaries:!!params.GET_SUMMARIES,signOwner:signOwner,signViewer:signViewer,gadget:urlParams.url,container:urlParams.container||urlParams.synd||"default",bypassSpecCache:gadgets.util.getUrlParameters().nocache||""};
if(params.AUTHORIZATION==="OAUTH"){paramData.oauthState=oauthState||"";
for(opt in params){if(params.hasOwnProperty(opt)){if(opt.indexOf("OAUTH_")===0){paramData[opt]=params[opt]
}}}}var proxyUrl=config.jsonProxyUrl.replace("%host%",document.location.host);
if(!respondWithPreload(paramData,params,callback,processResponse)){if(httpMethod==="GET"&&refreshInterval>0){var extraparams="?refresh="+refreshInterval+"&"+gadgets.io.encodeValues(paramData);
makeXhrRequest(url,proxyUrl+extraparams,callback,null,"GET",params,processResponse)
}else{makeXhrRequest(url,proxyUrl,callback,gadgets.io.encodeValues(paramData),"POST",params,processResponse)
}}},makeNonProxiedRequest:function(relativeUrl,callback,opt_params,opt_contentType){var params=opt_params||{};
makeXhrRequest(relativeUrl,relativeUrl,callback,params.POST_DATA,params.METHOD,params,processNonProxiedResponse,opt_contentType)
},clearOAuthState:function(){oauthState=undefined
},encodeValues:function(fields,opt_noEscaping){var escape=!opt_noEscaping;
var buf=[];
var first=false;
for(var i in fields){if(fields.hasOwnProperty(i)){if(!first){first=true
}else{buf.push("&")
}buf.push(escape?encodeURIComponent(i):i);
buf.push("=");
buf.push(escape?encodeURIComponent(fields[i]):fields[i])
}}return buf.join("")
},getProxyUrl:function(url,opt_params){var params=opt_params||{};
var refresh=params.REFRESH_INTERVAL;
if(refresh===undefined){refresh="3600"
}var urlParams=gadgets.util.getUrlParameters();
return config.proxyUrl.replace("%url%",encodeURIComponent(url)).replace("%host%",document.location.host).replace("%rawurl%",url).replace("%refresh%",encodeURIComponent(refresh)).replace("%gadget%",encodeURIComponent(urlParams.url)).replace("%container%",encodeURIComponent(urlParams.container||urlParams.synd))
}}
}();
gadgets.io.RequestParameters=gadgets.util.makeEnum(["METHOD","CONTENT_TYPE","POST_DATA","HEADERS","AUTHORIZATION","NUM_ENTRIES","GET_SUMMARIES","REFRESH_INTERVAL","OAUTH_SERVICE_NAME","OAUTH_TOKEN_NAME","OAUTH_REQUEST_TOKEN","OAUTH_REQUEST_TOKEN_SECRET"]);
gadgets.io.MethodType=gadgets.util.makeEnum(["GET","POST","PUT","DELETE","HEAD"]);
gadgets.io.ContentType=gadgets.util.makeEnum(["TEXT","DOM","JSON","FEED"]);
gadgets.io.AuthorizationType=gadgets.util.makeEnum(["NONE","SIGNED","OAUTH"]);;
var gadgets=gadgets||{};
gadgets.rpc=function(){var N="__cb";
var L="";
var Y="__g2c_rpc";
var E="__c2g_rpc";
var B={};
var S=[];
var C={};
var Q={};
var H={};
var J=0;
var Z={};
var P={};
var D={};
var X={};
if(gadgets.util){X=gadgets.util.getUrlParameters()
}H[".."]=X.rpctoken||X.ifpctok||0;
function U(){return typeof window.postMessage==="function"?"wpm":typeof document.postMessage==="function"?"dpm":navigator.product==="Gecko"?"fe":"ifpc"
}function W(){if(G==="dpm"||G==="wpm"){window.addEventListener("message",function(a){O(gadgets.json.parse(a.data))
},false)
}}var G=U();
W();
B[L]=function(){throw new Error("Unknown RPC service: "+this.s)
};
B[N]=function(b,a){var c=Z[b];
if(c){delete Z[b];
c(a)
}};
function K(a){if(P[a]){return 
}if(G==="fe"){try{var c=document.getElementById(a);
c[Y]=function(d){O(gadgets.json.parse(d))
}
}catch(b){}}P[a]=true
}function R(c){var e=gadgets.json.stringify;
var a=[];
for(var d=0,b=c.length;
d<b;
++d){a.push(encodeURIComponent(e(c[d])))
}return a.join("&")
}function O(b){if(b&&typeof b.s==="string"&&typeof b.f==="string"&&b.a instanceof Array){if(H[b.f]){if(H[b.f]!=b.t){throw new Error("Invalid auth token.")
}}if(b.c){b.callback=function(c){gadgets.rpc.call(b.f,N,null,b.c,c)
}
}var a=(B[b.s]||B[L]).apply(b,b.a);
if(b.c&&typeof a!="undefined"){gadgets.rpc.call(b.f,N,null,b.c,a)
}}}function A(b,c,i,d,g){try{if(i!=".."){var a=window.frameElement;
if(typeof a[Y]==="function"){if(typeof a[Y][E]!=="function"){a[Y][E]=function(e){O(gadgets.json.parse(e))
}
}a[Y](d);
return 
}}else{var h=document.getElementById(b);
if(typeof h[Y]==="function"&&typeof h[Y][E]==="function"){h[Y][E](d);
return 
}}}catch(f){}V(b,c,i,d,g)
}function V(a,b,g,c,d){var f=gadgets.rpc.getRelayUrl(a);
if(!f){throw new Error("No relay file assigned for IFPC")
}var e=null;
if(Q[a]){e=[f,"#",R([g,J,1,0,R([g,b,"","",g].concat(d))])].join("")
}else{e=[f,"#",a,"&",g,"@",J,"&1&0&",encodeURIComponent(c)].join("")
}I(e)
}function I(d){var b;
for(var a=S.length-1;
a>=0;
--a){var f=S[a];
try{if(f&&(f.recyclable||f.readyState==="complete")){f.parentNode.removeChild(f);
if(window.ActiveXObject){S[a]=f=null;
S.splice(a,1)
}else{f.recyclable=false;
b=f;
break
}}}catch(c){}}if(!b){b=document.createElement("iframe");
b.style.border=b.style.width=b.style.height="0px";
b.style.visibility="hidden";
b.style.position="absolute";
b.onload=function(){this.recyclable=true
};
S.push(b)
}b.src=d;
setTimeout(function(){document.body.appendChild(b)
},0)
}function F(b,d){if(typeof D[b]==="undefined"){D[b]=false;
var c=null;
if(b===".."){c=parent
}else{c=frames[b]
}try{D[b]=c.gadgets.rpc.receiveSameDomain
}catch(a){}}if(typeof D[b]==="function"){D[b](d);
return true
}return false
}if(gadgets.config){function T(a){if(a.rpc.parentRelayUrl.substring(0,7)==="http://"){C[".."]=a.rpc.parentRelayUrl
}else{var e=document.location.search.substring(0).split("&");
var d="";
for(var b=0,c;
c=e[b];
++b){if(c.indexOf("parent=")===0){d=decodeURIComponent(c.substring(7));
break
}}C[".."]=d+a.rpc.parentRelayUrl
}Q[".."]=!!a.rpc.useLegacyProtocol
}var M={parentRelayUrl:gadgets.config.NonEmptyStringValidator};
gadgets.config.register("rpc",M,T)
}return{register:function(b,a){if(b==N){throw new Error("Cannot overwrite callback service")
}if(b==L){throw new Error("Cannot overwrite default service: use registerDefault")
}B[b]=a
},unregister:function(a){if(a==N){throw new Error("Cannot delete callback service")
}if(a==L){throw new Error("Cannot delete default service: use unregisterDefault")
}delete B[a]
},registerDefault:function(a){B[""]=a
},unregisterDefault:function(){delete B[""]
},call:function(h,d,i,g){++J;
h=h||"..";
if(i){Z[J]=i
}var f="..";
if(h===".."){f=window.name
}var c={s:d,f:f,c:i?J:0,a:Array.prototype.slice.call(arguments,3),t:H[h]};
if(F(h,c)){return 
}var a=gadgets.json.stringify(c);
var b=G;
if(Q[h]){b="ifpc"
}switch(b){case"dpm":var j=h===".."?parent.document:frames[h].document;
j.postMessage(a);
break;
case"wpm":var e=h===".."?parent:frames[h];
e.postMessage(a,C[h]);
break;
case"fe":A(h,d,f,a,c.a);
break;
default:V(h,d,f,a,c.a);
break
}},getRelayUrl:function(a){return C[a]
},setRelayUrl:function(b,a,c){C[b]=a;
Q[b]=!!c
},setAuthToken:function(a,b){H[a]=b;
K(a)
},getRelayChannel:function(){return G
},receive:function(a){if(a.length>4){O(gadgets.json.parse(decodeURIComponent(a[a.length-1])))
}},receiveSameDomain:function(a){a.a=Array.prototype.slice.call(a.a);
window.setTimeout(function(){O(a)
},0)
}}
}();;
var gadgets=gadgets||{};
gadgets.window=gadgets.window||{};
(function(){var A;
gadgets.window.getViewportDimensions=function(){var B,C;
if(self.innerHeight){B=self.innerWidth;
C=self.innerHeight
}else{if(document.documentElement&&document.documentElement.clientHeight){B=document.documentElement.clientWidth;
C=document.documentElement.clientHeight
}else{if(document.body){B=document.body.clientWidth;
C=document.body.clientHeight
}else{B=0;
C=0
}}}return{width:B,height:C}
};
gadgets.window.adjustHeight=function(F){var C=parseInt(F,10);
if(isNaN(C)){var H=gadgets.window.getViewportDimensions().height;
var B=document.body;
var G=document.documentElement;
if(document.compatMode=="CSS1Compat"&&G.scrollHeight){C=G.scrollHeight!=H?G.scrollHeight:G.offsetHeight
}else{var D=G.scrollHeight;
var E=G.offsetHeight;
if(G.clientHeight!=E){D=B.scrollHeight;
E=B.offsetHeight
}if(D>H){C=D>E?D:E
}else{C=D<E?D:E
}}}if(C!=A){A=C;
gadgets.rpc.call(null,"resize_iframe",null,C)
}}
}());
var _IG_AdjustIFrameHeight=gadgets.window.adjustHeight;;
gadgets.Prefs.prototype.set=function(D,E){if(arguments.length>2){var F={};
for(var C=0,B=arguments.length;
C<B;
C+=2){F[arguments[C]]=arguments[C+1]
}gadgets.Prefs.setInternal_(F)
}else{gadgets.Prefs.setInternal_(D,E)
}var A=[null,"set_pref",null,gadgets.util.getUrlParameters().ifpctok||0].concat(Array.prototype.slice.call(arguments));
gadgets.rpc.call.apply(gadgets.rpc,A)
};
gadgets.Prefs.prototype.setArray=function(C,D){for(var B=0,A=D.length;
B<A;
++B){D[B]=D[B].replace(/\|/g,"%7C")
}gadgets.Prefs.setInternal_(C,D.join("|"))
};;

