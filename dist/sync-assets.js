'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _regenerator = require('babel-runtime/regenerator');

var _regenerator2 = _interopRequireDefault(_regenerator);

var _asyncToGenerator2 = require('babel-runtime/helpers/asyncToGenerator');

var _asyncToGenerator3 = _interopRequireDefault(_asyncToGenerator2);

var _logger = require('./logger');

var _logger2 = _interopRequireDefault(_logger);

var _store = require('./store');

var _parallelLimit = require('async/parallelLimit');

var _parallelLimit2 = _interopRequireDefault(_parallelLimit);

var _filter = require('async/filter');

var _filter2 = _interopRequireDefault(_filter);

var _path = require('path');

var _path2 = _interopRequireDefault(_path);

var _axios = require('axios');

var _axios2 = _interopRequireDefault(_axios);

var _fsExtra = require('fs-extra');

var _fsExtra2 = _interopRequireDefault(_fsExtra);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// Generated by CoffeeScript 2.4.1
// Deps
var downloadAssetToCacheDir, downloadfoundAssetsToCacheDir, isNewAsset, makeDest, publishCache;

exports.default = (0, _asyncToGenerator3.default)( /*#__PURE__*/_regenerator2.default.mark(function _callee() {
  return _regenerator2.default.wrap(function _callee$(_context) {
    while (1) {
      switch (_context.prev = _context.next) {
        case 0:
          _context.next = 2;
          return downloadfoundAssetsToCacheDir();

        case 2:
          return _context.abrupt('return', publishCache());

        case 3:
        case 'end':
          return _context.stop();
      }
    }
  }, _callee, this);
}));

// Download URLs to the cache directory

downloadfoundAssetsToCacheDir = function () {
  var _ref2 = (0, _asyncToGenerator3.default)( /*#__PURE__*/_regenerator2.default.mark(function _callee2() {
    var e, newAssets, tasks;
    return _regenerator2.default.wrap(function _callee2$(_context2) {
      while (1) {
        switch (_context2.prev = _context2.next) {
          case 0:
            _context2.next = 2;
            return (0, _filter2.default)(_store.foundAssets, isNewAsset);

          case 2:
            newAssets = _context2.sent;

            _logger2.default.info('Downloading ' + newAssets.length + ' asset(s) to cache, ' + _store.options.concurrency + ' at a time');
            tasks = newAssets.map(downloadAssetToCacheDir);
            _context2.prev = 5;
            _context2.next = 8;
            return (0, _parallelLimit2.default)(tasks, _store.options.concurrency);

          case 8:
            _context2.next = 14;
            break;

          case 10:
            _context2.prev = 10;
            _context2.t0 = _context2['catch'](5);

            e = _context2.t0;
            _logger2.default.warn('Download errors were encountered');

          case 14:
            return _context2.abrupt('return', _logger2.default.success('Downloading to cache complete'));

          case 15:
          case 'end':
            return _context2.stop();
        }
      }
    }, _callee2, this, [[5, 10]]);
  }));

  return function downloadfoundAssetsToCacheDir() {
    return _ref2.apply(this, arguments);
  };
}();

// Check if an asset has already been downloaded
isNewAsset = function isNewAsset(_ref3, callback) {
  var newUrl = _ref3.newUrl;

  return _fsExtra2.default.access(makeDest(newUrl), function (err) {
    return callback(null, !!err);
  });
};

// Make the local path given a remote URL
makeDest = function makeDest(url) {
  return _path2.default.join(_store.options.cacheDir, url);
};

// Download an asset to the cache directory if it's new. Not using async/await in
// here because parallelLimit() doesn't work with it when it's been transpiled.
downloadAssetToCacheDir = function downloadAssetToCacheDir(_ref4) {
  var oldUrl = _ref4.oldUrl,
      newUrl = _ref4.newUrl;

  return function (resolve) {
    var dest;
    dest = makeDest(newUrl);
    _fsExtra2.default.ensureDirSync(_path2.default.dirname(dest)); // Make the directory path
    return (0, _axios2.default)(oldUrl, {
      responseType: 'stream'
    }).then(function (response) {
      return response.data.pipe(_fsExtra2.default.createWriteStream(dest));
    }).catch(function (error) {
      _logger2.default.error('Error while downloading ' + oldUrl + ' to ' + dest);
      return _logger2.default.error(error);
    }).finally(function () {
      return resolve();
    });
  };
};

// Publish the cache contents to the public directory
publishCache = function publishCache() {
  _logger2.default.info("Publishing the cache directory");
  console.log(_store.options.cacheDir, _store.options.publicDir);
  _fsExtra2.default.copySync(_store.options.cacheDir, _store.options.publicDir, {
    overwrite: true
  });
  return _logger2.default.success("Publishing cache directory complete");
};