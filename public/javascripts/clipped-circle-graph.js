!function(r){function e(n){if(t[n])return t[n].exports;var c=t[n]={i:n,l:!1,exports:{}};return r[n].call(c.exports,c,c.exports,e),c.l=!0,c.exports}var t={};return e.m=r,e.c=t,e.i=function(r){return r},e.d=function(r,t,n){e.o(r,t)||Object.defineProperty(r,t,{configurable:!1,enumerable:!0,get:n})},e.n=function(r){var t=r&&r.__esModule?function(){return r["default"]}:function(){return r};return e.d(t,"a",t),t},e.o=function(r,e){return Object.prototype.hasOwnProperty.call(r,e)},e.p="",e(e.s=53)}({23:function(r,e,t){"use strict";$("[data-clipped-circle-graph]").each(function(){var r=$(this),e=parseInt(r.data("percent"),10),t=30+300*e/100;e>50&&r.addClass("gt-50"),r.find(".clipped-circle-graph-progress-fill").css("transform","rotate("+t+"deg)"),r.find(".clipped-circle-graph-percents-number").html(e+"%")})},53:function(r,e,t){r.exports=t(23)}});