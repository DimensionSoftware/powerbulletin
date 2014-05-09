// super simple module for the most common nodejs use case.
exports.markdown = require("../src/markdown");
exports.parse = exports.markdown.toHTML;
