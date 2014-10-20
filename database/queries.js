'use strict';

var _ = require('lodash');

module.exports.combineQueries = function (queries) {
  var result = {};

  _.forEach(queries, function (query) {
    _.merge(result, query);
  });

  return result;
}

module.exports.getUnarchived = function () {
  return { status: '0' };
}

module.exports.getArchived = function () {
  return { status: '1' };
}

module.exports.getAll = function () {
  return {};
}

module.exports.getWithUrlRegex = function (urlRegex) {
  return { resolved_url : urlRegex };
}
