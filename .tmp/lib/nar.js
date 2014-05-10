// Generated by LiveScript 1.2.0
var get, run, list, create, extract, install, version, exports;
get = require('./get');
run = require('./run');
list = require('./list');
create = require('./create');
extract = require('./extract');
install = require('./install');
version = require('../package.json').version;
exports = module.exports = {
  VERSION: version,
  create: create,
  extract: extract,
  run: run,
  list: list,
  install: install,
  get: get
};