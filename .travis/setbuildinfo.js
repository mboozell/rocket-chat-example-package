var BUILD_INFO_PATH = '../public/buildinfo/buildinfo.txt';
var PACKAGES_PATH = '../.meteor/versions';
var BUILD_PATH = '../../build';
var LineByLineReader = require('line-by-line');
var mkdirp = require('mkdirp');
var fs = require('fs');
var lr = new LineByLineReader(BUILD_INFO_PATH);

var firstline = "";


if (process.env.TRAVIS_BUILD_NUMBER)  {
	var transformVersion = function (firstline) {
		var versions = firstline.split(".");
		var verstring = versions[0] + '.' + versions[1] +  '.'  + process.env.TRAVIS_BRANCH + '.' + process.env.TRAVIS_BUILD_NUMBER + '\n';
		if (process.env.TRAVIS_TAG) {
			verstring = TRAVIS_TAG + '\n';

		}

		return verstring;
	};



	lr.on('error', function (err) {
		// 'err' contains error object
	});

	lr.on('line', function (line) {
		if (firstline == "") {
			firstline = line;
		}
	});

	lr.on('end', function () {
		var packages = fs.readFileSync(PACKAGES_PATH);
		var verinfo = transformVersion(firstline);
		var content = verinfo + packages;
		mkdirp.sync(BUILD_PATH);
		fs.writeFileSync(BUILD_PATH + "/version.txt", verinfo);
		fs.writeFileSync(BUILD_INFO_PATH, content);
		console.log('Version is ' + verinfo);
	});
}
