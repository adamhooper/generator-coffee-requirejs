assert = require('assert')
ncp = require('ncp').ncp
fs = require('fs')
path = require('path')
helpers = require('yeoman-generator').test
rimraf = require('rimraf')
spawn = require('child_process').spawn

PATHS =
  templateApp: path.join(__dirname, 'temp-template')
  testApp: path.join(__dirname, 'temp')
  nodeModules: path.join(__dirname, 'node_modules')

bowerOptions =
  offline: true
  silent: true
bowerOptions.plus = (otherOptions) ->
  ret = {}
  (ret[k] = v) for k, v of bowerOptions
  (ret[k] = v) for k, v of otherOptions
  ret

npmOptions =
  link: true
  loglevel: 'silent'

# Runs the given command and arguments.
#
# Returns an error with their output if they fail. Otherwise, is silent.
runCommand = (name, args, done) ->
  output = ''
  command = spawn(name, args)
  command.stdout.on('data', (data) -> output += data)
  command.stderr.on('data', (data) -> output += data)
  command.on 'close', (errCode) =>
    if errCode
      return done(new Error("#{name} #{args.map(JSON.stringify).join(' ')} returned error code #{errCode}. See output below:\n\n#{output}"))
    done()

copyFileSync = (from, to) ->
  # Our needs are basic.
  contents = fs.readFileSync(from)
  fs.writeFileSync(to, contents)

# Creates a test directory, __dirname/temp-template.
#
# For individual tests, copy the contents of that directory to __dirname/temp and run the test.
#
# Node modules will be saved to __dirname/temp-node_modules.
createTemplateApp = (done) ->
  helpers.testDirectory PATHS.templateApp, (err) =>
    return done(err) if err?

    app = helpers.createGenerator('coffee-requirejs:app', [ '../../app' ])
    app.options['skip-install'] = true
    appOutput = ''
    realProcessStderrWrite = process.stderr.write
    realProcessStdoutWrite = process.stdout.write
    process.stdout.write = process.stderr.write = (data) -> appOutput += data
    app.run {}, (errCode) =>
      process.stderr.write = realProcessStderrWrite
      process.stdout.write = realProcessStdoutWrite
      return done(new Error("app install returned error code #{errCode}. See output below:\n\n#{appOutput}")) if errCode

      runCommand 'npm', [ 'install' ], (err) ->
        return done(err) if err?

        runCommand 'bower', [ 'install' ], (err) ->
          return done(err) if err?

          # When copying the template app, we don't want to copy the hundreds
          # of megabytes of node_modules. Instead we can just copy a symlink.
          #
          # Assumption: no tests will modify the contents of node_modules.
          #
          # Unfortunately, node can't seem to resolve the grunt-karma -> karma
          # peer dependency when the node_modules directory is a symlink.
          # Luckily, if we call the _parent_ directory node_modules, that
          # resolution works.
          #
          # Uncool? Yes. But faster than copying lots of files for each test.
          originalNodeModules = path.join(PATHS.templateApp, 'node_modules')
          fs.renameSync(originalNodeModules, PATHS.nodeModules)
          fs.symlinkSync(PATHS.nodeModules, originalNodeModules)

          done()

# Ensures there is a template app present.
#
# (Call this before relying upon the template app.)
ensureTemplateAppCreated = (done) ->
  fs.exists PATHS.templateApp, (exists1) ->
    fs.exists PATHS.nodeModules, (exists2) ->
      return done() if exists1 && exists2
      createTemplateApp(done)

# Creates a blank app in tests/temp/ and changes into that directory.
inTestApp = (done) ->
  ensureTemplateAppCreated (err) ->
    return done(err) if err

    process.chdir(__dirname) # otherwise ncp will fail after rimraf, even though we use absolute paths
    rimraf.sync(PATHS.testApp)
    ncp PATHS.templateApp, PATHS.testApp, (err) ->
      process.chdir(PATHS.testApp) if !err
      done(err)

describe 'a coffee-requirejs generated app', ->
  realProcessStderrWrite = process.stderr.write
  realProcessStdoutWrite = process.stdout.write

  beforeEach (done) ->
    @timeout(1000 * 60 * 5) # We need to create the entire app, at least once
    inTestApp(done)

  describe 'when adding a Backbone model', ->
    beforeEach (done) ->
      @timeout(1000 * 60 * 5)
      fs.mkdirSync('test/scripts/models')
      copyFileSync('../../test/files/adding-a-backbone-model/MyModelSpec.coffee', 'test/scripts/models/MyModelSpec.coffee')
      runCommand('bower', [ 'install', 'jquery', 'underscore', 'backbone', '--save' ], done)

    it 'should add backbone to bower.json', ->
      s = fs.readFileSync('bower.json')
      j = JSON.parse(s)
      assert.ok(j.dependencies.backbone, 'backbone should now be a bower dependency')

    describe 'after running `grunt bower`', ->
      beforeEach (done) ->
        @timeout(1000 * 60 * 5)
        runCommand('grunt', [ 'bower' ], done)

      it 'should add a backbone path to the RequireJS config', ->
        s = fs.readFileSync('app/scripts/config.js', 'utf-8')
        # s starts with "requirejs.config(" and ends with ");". The rest is a JavaScript Object.
        jsonIsh = s.substring(s.indexOf('(') + 1, s.lastIndexOf(')'))
        eval("j = #{jsonIsh};")
        assert.ok(j.paths.backbone, 'backbone should be in "paths" in config.js')

      describe 'grunt test', ->
        beforeEach (done) ->
          @timeout(1000 * 60 * 5)
          runCommand 'grunt', [ 'test' ], (err) =>
            @err = err
            done()

        it 'should fail because requirejs cannot find the model', ->
          assert.ok(@err, 'grunt test should throw an error')
          assert.ok(/Error: Script error for: models\/MyModel/.test(@err.message), 'the error should be because MyModel does not exist')

      describe 'with valid code', ->
        beforeEach (done) ->
          @timeout(1000 * 60 * 5)
          fs.mkdirSync('app/scripts/models')
          copyFileSync('../../test/files/adding-a-backbone-model/MyModel.coffee', 'app/scripts/models/MyModel.coffee')
          runCommand 'grunt', [ 'test' ], (err) =>
            @err = err
            done()

        it 'should succeed', ->
          assert.ifError(@err, 'grunt test should succeed')
