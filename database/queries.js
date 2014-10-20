'use strict';

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
