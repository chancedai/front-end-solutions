;(function(win){
    var crel = (function(){
        // based on http://stackoverflow.com/questions/384286/javascript-isdom-how-do-you-check-if-a-javascript-object-is-a-dom-object
        var isNode = typeof Node === 'object'
            ? function (object) { return object instanceof Node }
            : function (object) {
                return object
                    && typeof object === 'object'
                    && typeof object.nodeType === 'number'
                    && typeof object.nodeName === 'string';
            };

        function crel(){
            var document = window.document,
                args = arguments, //Note: assigned to a variable to assist compilers. Saves about 40 bytes in closure compiler. Has negligable effect on performance.
                element = document.createElement(args[0]),
                child,
                settings = args[1],
                childIndex = 2,
                argumentsLength = args.length,
                attributeMap = crel.attrMap;

            // shortcut
            if(argumentsLength === 1){
                return element;
            }

            if(typeof settings !== 'object' || isNode(settings)) {
                --childIndex;
                settings = null;
            }

            // shortcut if there is only one child that is a string
            if((argumentsLength - childIndex) === 1 && typeof args[childIndex] === 'string' && element.textContent !== undefined){
                element.textContent = args[childIndex];
            }else{
                for(; childIndex < argumentsLength; ++childIndex){
                    child = args[childIndex];

                    if(child == null){
                        continue;
                    }

                    if(!isNode(child)){
                        child = document.createTextNode(child);
                    }

                    element.appendChild(child);
                }
            }

            for(var key in settings){
                if(!attributeMap[key]){
                    element.setAttribute(key, settings[key]);
                }else{
                    var attr = crel.attrMap[key];
                    if(typeof attr === 'function'){
                        attr(element, settings[key]);
                    }else{
                        element.setAttribute(attr, settings[key]);
                    }
                }
            }

            return element;
        }

        // Used for mapping one kind of attribute to the supported version of that in bad browsers.
        // String referenced so that compilers maintain the property name.
        crel['attrMap'] = {};

        // String referenced so that compilers maintain the property name.
        crel["isNode"] = isNode;

        return crel;
    })();
    win.JsonHuman = (function(){
        var toString = Object.prototype.toString,
            ARRAY = 1,
            BOOL = 2,
            INT = 3,
            FLOAT = 4,
            STRING = 5,
            OBJECT = 6,
            FUNCTION = 7,
            UNK = 99;

        function makePrefixer(prefix) {
            return function (name) {
                return prefix + "-" + name;
            };
        }

        function getType(obj) {
            var type = typeof obj;

            if (type === "boolean") {
                return BOOL;
            } else if (type === "string") {
                return STRING;
            } else if (type === "number") {
                return (obj % 1 === 0) ? INT : FLOAT;
            } else if (type === "function") {
                return FUNCTION;
            } else if (toString.call(obj) === '[object Array]') {
                return ARRAY;
            } else if (obj === Object(obj)) {
                return OBJECT;
            } else {
                return UNK;
            }
        }

        function _format(data, prefixer) {
            var result, container, key, keyNode, valNode,
                isEmpty = true,
                p = prefixer,
                accum = [],
                type = getType(data);
            var tbody;
            switch (type) {
            case BOOL:
                result = crel("span", {"class": p("type-bool")}, "" + data);
                break;
            case STRING:
                if (data !== "") {
                    result = crel("span", {"class": p("type-string")}, "");
                    result.innerHTML = data
                        .replace(/&/g, '&amp;')
                        .replace(/ /g, "&nbsp;")
                        .replace(/</g, '&lt;')
                        .replace(/>/g, '&gt;')
                        .replace(/[\r\n]/g, '<br/>')
                        .replace(/"/g, '&quot;'); // ")
                } else {
                    result = crel("span",
                             {"class": p("type-string") + " " + p("empty")},
                             "(Empty Text)");
                }
                break;
            case INT:
                result = crel("span",
                             {"class": p("type-int") + " " + p("type-number")},
                              "" + data);
                break;
            case FLOAT:
                result = crel("span",
                             {"class": p("type-float") + " " + p("type-number")},
                             "" + data);
                break;
            case OBJECT:
                result = crel("table", {"class": p("type-object")},
                    tbody = crel('tbody'));
                for (key in data) {
                    isEmpty = false;
                    keyNode = crel("th",
                             {"class": p("key") + " " + p("object-key")},
                             "" + key);
                    valNode = crel("td",
                             {"class": p("value") + " " + p("object-value")},
                             _format(data[key], p));
                    tbody.appendChild(crel("tr", keyNode, valNode));
                }

                if (isEmpty) {
                    tbody = crel("span",
                             {"class": p("type-object") + " " + p("empty")},
                             "(Empty Object)");
                }
                break;
            case FUNCTION:
                result = crel("span", {"class": p("type-function")}, "" + data);
                break;
            case ARRAY:
                if (data.length > 0) {
                    result = crel("table", {"class": p("type-array")},
                        tbody = crel('tbody'));
                    for (key = 0; key < data.length; key += 1) {
                        keyNode = crel("th",
                                 {"class": p("key") + " " + p("array-key")},
                                 "" + key);
                        valNode = crel("td",
                                 {"class": p("value") + " " + p("array-value")},
                                 _format(data[key], p));
                        tbody.appendChild(crel("tr", keyNode, valNode));
                    }
                } else {
                    result = crel("span",
                             {"class": p("type-array") + " " + p("empty")},
                             "(Empty List)");
                }
                break;
            default:
                result = crel("span", {"class": p("type-unk")},
                              "" + data);
                break;
            }

            return result;
        }

        function format(data, options) {
            options = options || {};
            var result,
                prefixer = makePrefixer(options.prefix || "jh");

            result = _format(data, prefixer);
            result.className = result.className + " " + prefixer("root");

            return result;
        }

        return {
            format: format
        };
    })();
})(this);
