function getType(o) {
    return Object.prototype.toString.call(o).match(/^\[object\s(.*)\]$/)[1];
}
//function isInstance(obj, type) {
//    var ret = false,
//    isTypeAString = getType(type) == "String",
//    functionConstructor, i, l, typeArray, context;
//    if (!isTypeAString && getType(type) != "Function") {
//        throw new TypeError("type argument must be a string or function");
//    }
//    if (obj !== undefined && obj !== null && obj.constructor) {
//        //get the Function constructor
//        functionConstructor = obj.constructor;
//        while (functionConstructor != functionConstructor.constructor) {
//            functionConstructor = functionConstructor.constructor;
//        }
//        //get the object's window
//        context = functionConstructor //== Function ? self : functionConstructor("return window")();
//        //get the constructor for the type
//        if (isTypeAString) {
//            //type is a string so we'll build the context (window.Array or window.some.Type)
//            for (typeArray = type.split("."), i = 0, l = typeArray.length; i < l && context; i++) {
//                context = context[typeArray[i]];
//            }
//        } else {
//            //type is a function so execute the function passing in the object's window
//            //the return should be a constructor
//            context = type(context);
//        }
//        //check if the object is an instance of the constructor
//        if (context) {
//            ret = obj instanceof context;
//            if (!ret && (type == "Number" || type == "String" || type == "Boolean")) {
//                ret = obj.constructor == context
//            }
//        }
//    }
//    return ret;
//}


function getAllMethods(object) {
    return Object.getOwnPropertyNames(object).filter(function(property) {
                                                     return typeof object[property] == 'function';
                                                     });
}


//(function() {
// // log all calls to setArray
// var proxied = require;
//    require = function() {
//    console.log(arguments[0]);
//    return proxied.apply( this, arguments );
// };
// })();
