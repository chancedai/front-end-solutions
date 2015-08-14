/*
--------------------------------------------------------
suggest.js - Input Suggest
Version 2.3 (Update 2013/02/11)

Copyright (c) 2006-2013 onozaty (http://www.enjoyxstudy.com)

Released under an MIT-style license.

For details, see the web site:
 http://www.enjoyxstudy.com/javascript/suggest/

--------------------------------------------------------
*/
(function(exports) {
    var extend = function(dest, src) {
            for (var property in src) {
                dest[property] = src[property];
            }
            return dest;
        };
    var addEvent = (exports.addEventListener ?
            function(element, type, func) {
                element.addEventListener(type, func, false);
            } :
            function(element, type, func) {
                element.attachEvent('on' + type, func);
            });
    // Utils
    var byId = function(element) {
        return (typeof element == 'string') ? document.getElementById(element) : element;
    };
    var _stopEvent = function(event) {
        if (event.preventDefault) {
            event.preventDefault();
            event.stopPropagation();
        } else {
            event.returnValue = false;
            event.cancelBubble = true;
        }
    };
    var getEventSrc = function(event) {
        return event.target || event.srcElement;
    };
    var escapeHTML = function(value) {
        return value.replace(/\&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
            .replace(/\"/g, '&quot;').replace(/\'/g, '&#39;');
    };
    var KEYCODE = {
        TAB: 9,
        RETURN: 13,
        ESC: 27,
        UP: 38,
        DOWN: 40
    };
    var Suggest = window.Suggest = {};
    /*-- Suggest.Local ------------------------------------*/
    Suggest.Local = function() {
        this.init.apply(this, arguments);
    };
    Suggest.Local.prototype = {
        init: function(input, suggestArea, data,opt) {

            this.input = byId(input);
            this.suggestArea = byId(suggestArea);
            this.data = data;
            this.oldText = this.getInputText();

            if (opt){
                this.setOptions(opt);
            }

            // reg event
            addEvent(this.input, 'focus', this._bind(this.checkLoop));
            addEvent(this.input, 'blur', this._bind(this.inputBlur));
            addEvent(this.suggestArea, 'blur', this._bind(this.inputBlur));

            addEvent(this.input, 'keydown', this._bindEvent(this.keyEvent));

            // init
            this.clearListWrap();
        },

        // options
        interval: 500,
        dispMax: 20,
        listTagName: 'div',
        prefix: false,
        ignoreCase: true,
        highlight: false,
        dispAllKey: false,
        classMouseOver: 'over',
        classSelect: 'select',
        hookBeforeSearch: function() {},

        setOptions: function(options) {
            extend(this, options);
        },

        inputBlur: function() {

            setTimeout(this._bind(function() {

                if (document.activeElement == this.suggestArea || document.activeElement == this.input) {
                    // keep suggestion
                    return;
                }
                this.changeUnactive();
                this.oldText = this.getInputText();

                if (this.timerId) clearTimeout(this.timerId);
                this.timerId = null;

                setTimeout(this._bind(this.clearListWrap), 500);
            }, 500));
        },

        checkLoop: function() {
            var text = this.getInputText();
            if (text != this.oldText) {
                this.oldText = text;
                this.search();
            }
            if (this.timerId) clearTimeout(this.timerId);
            this.timerId = setTimeout(this._bind(this.checkLoop), this.interval);
        },

        search: function() {

            // init
            this.clearListWrap();

            var text = this.getInputText();

            if (text == '' || text == null) return;

            this.hookBeforeSearch(text);
            var resultList = this.getData(text);
            if (resultList.length != 0) this.createSuggestArea(resultList);
        },

        getData: function(text) {

            var resultList = [];
            var temp;
            this.suggestIndexList = [];

            for (var i = 0, length = this.data.length; i < length; i++) {
                if ((temp = this.isMatch(this.data[i], text)) != null) {
                    resultList.push(temp);
                    this.suggestIndexList.push(i);

                    if (this.dispMax != 0 && resultList.length >= this.dispMax) break;
                }
            }
            return resultList;
        },

        isMatch: function(value, pattern) {

            if (value == null) return null;

            var pos = (this.ignoreCase) ?
                value.toLowerCase().indexOf(pattern.toLowerCase()) : value.indexOf(pattern);

            if ((pos == -1) || (this.prefix && pos != 0)) return null;

            if (this.highlight) {
                return (escapeHTML(value.substr(0, pos)) + '<strong>' + escapeHTML(value.substr(pos, pattern.length)) + '</strong>' + escapeHTML(value.substr(pos + pattern.length)));
            } else {
                return escapeHTML(value);
            }
        },

      clearListWrap: function() {
            this.suggestArea.innerHTML = '';
            this.suggestArea.style.display = 'none';
            this.suggestList = null;
            this.suggestIndexList = null;
            this.activePosition = null;
        },
        createSuggestArea: function(resultList) {
            this.suggestList = [];
            this.inputValueBackup = this.input.value;

            for (var i = 0, length = resultList.length; i < length; i++) {
                var element = document.createElement(this.listTagName);
                element.innerHTML = resultList[i];
                this.suggestArea.appendChild(element);

                addEvent(element, 'click', this._bindEvent(this.listClick, i));
                addEvent(element, 'mouseover', this._bindEvent(this.listMouseOver, i));
                addEvent(element, 'mouseout', this._bindEvent(this.listMouseOut, i));

                this.suggestList.push(element);
            }

            this.suggestArea.style.display = '';
            this.suggestArea.scrollTop = 0;
        },

        getInputText: function() {
            return this.input.value;
        },

        setInputText: function(text) {
            this.input.value = text;
        },

        // key event
        keyEvent: function(event) {

            if (!this.timerId) {
                this.timerId = setTimeout(this._bind(this.checkLoop), this.interval);
            }

            if (this.dispAllKey && event.ctrlKey && this.getInputText() == '' && !this.suggestList && event.keyCode == KEYCODE.DOWN) {
                // dispAll
                _stopEvent(event);
                this.keyEventDispAll();
            } else if (event.keyCode == KEYCODE.UP ||
                event.keyCode == KEYCODE.DOWN) {
                // key move
                if (this.suggestList && this.suggestList.length != 0) {
                    _stopEvent(event);
                    this.keyEventMove(event.keyCode);
                }
            } else if (event.keyCode == KEYCODE.RETURN) {
                // fix
                if (this.suggestList && this.suggestList.length != 0) {
                    _stopEvent(event);
                    this.keyEventReturn();
                }
            } else if (event.keyCode == KEYCODE.ESC) {
                // cancel
                if (this.suggestList && this.suggestList.length != 0) {
                    _stopEvent(event);
                    this.keyEventEsc();
                }
            } else {
                this.keyEventOther(event);
            }
        },

        keyEventDispAll: function() {

            // init
            this.clearListWrap();

            this.oldText = this.getInputText();

            this.suggestIndexList = [];
            for (var i = 0, length = this.data.length; i < length; i++) {
                this.suggestIndexList.push(i);
            }

            this.createSuggestArea(this.data);
        },

        keyEventMove: function(keyCode) {

            this.changeUnactive();

            if (keyCode == KEYCODE.UP) {
                // up
                if (this.activePosition == null) {
                    this.activePosition = this.suggestList.length - 1;
                } else {
                    this.activePosition--;
                    if (this.activePosition < 0) {
                        this.activePosition = null;
                        this.input.value = this.inputValueBackup;
                        this.suggestArea.scrollTop = 0;
                        return;
                    }
                }
            } else {
                // down
                if (this.activePosition == null) {
                    this.activePosition = 0;
                } else {
                    this.activePosition++;
                }

                if (this.activePosition >= this.suggestList.length) {
                    this.activePosition = null;
                    this.input.value = this.inputValueBackup;
                    this.suggestArea.scrollTop = 0;
                    return;
                }
            }

            this.changeActive(this.activePosition);
        },

        keyEventReturn: function() {

            this.clearListWrap();
            this.moveEnd();
        },

        keyEventEsc: function() {

            this.clearListWrap();
            this.input.value = this.inputValueBackup;
            this.oldText = this.getInputText();

            if (exports.opera) setTimeout(this._bind(this.moveEnd), 5);
        },

        keyEventOther: function(event) {},

        changeActive: function(index) {

            this.setStyleActive(this.suggestList[index]);

            this.setInputText(this.data[this.suggestIndexList[index]]);

            this.oldText = this.getInputText();
            this.input.focus();
        },

        changeUnactive: function() {

            if (this.suggestList != null && this.suggestList.length > 0 && this.activePosition != null) {
                this.setStyleUnactive(this.suggestList[this.activePosition]);
            }
        },

        listClick: function(event, index) {

            this.changeUnactive();
            this.activePosition = index;
            this.changeActive(index);

            this.clearListWrap();
            this.moveEnd();
        },

        listMouseOver: function(event, index) {
            this.setStyleMouseOver(this.getEventSrc(event));
        },

        listMouseOut: function(event, index) {

            if (!this.suggestList) return;

            var element = this.getEventSrc(event);

            if (index == this.activePosition) {
                this.setStyleActive(element);
            } else {
                this.setStyleUnactive(element);
            }
        },

        setStyleActive: function(element) {
            element.className = this.classSelect;

            // auto scroll
            var offset = element.offsetTop;
            var offsetWithHeight = offset + element.clientHeight;

            if (this.suggestArea.scrollTop > offset) {
                this.suggestArea.scrollTop = offset
            } else if (this.suggestArea.scrollTop + this.suggestArea.clientHeight < offsetWithHeight) {
                this.suggestArea.scrollTop = offsetWithHeight - this.suggestArea.clientHeight;
            }
        },

        setStyleUnactive: function(element) {
            element.className = '';
        },

        setStyleMouseOver: function(element) {
            element.className = this.classMouseOver;
        },

        moveEnd: function() {

            if (this.input.createTextRange) {
                this.input.focus(); // Opera
                var range = this.input.createTextRange();
                range.move('character', this.input.value.length);
                range.select();
            } else if (this.input.setSelectionRange) {
                this.input.setSelectionRange(this.input.value.length, this.input.value.length);
            }
        },


        _bind: function(func) {
            var self = this;
            var args = Array.prototype.slice.call(arguments, 1);
            return function() {
                func.apply(self, args);
            };
        },
        _bindEvent: function(func) {
            var self = this;
            var args = Array.prototype.slice.call(arguments, 1);
            return function(event) {
                event = event || exports.event;
                func.apply(self, [event].concat(args));
            };
        }

    };

})(window);