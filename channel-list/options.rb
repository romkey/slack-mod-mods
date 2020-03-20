require 'optparse'

class ModModsOptions
  attr_reader :options

  def initialize
    @options        = {}

    include_help   = 'an additional $LOAD_PATH'
    json_help      = 'output as JSON'
    csv_help       = 'output as CSV'

    op = OptionParser.new
    op.banner =  banner
    op.separator ''
    op.separator "Usage: #{name} [@options]"
    op.separator ''

    app_options(op)

    op.separator 'Ruby options:'
    op.on('-I', '--include PATH', include_help) { |value| $LOAD_PATH.unshift(*value.split(':').map{|v| File.expand_path(v)}) }
    op.separator ''

    op.separator '#{name} options:'
    op.on('-j', '--json',         json_help)    { @options[:json] = true }
    op.on('-c', '--csv',          csv_help)     { @options[:csv] = true }

    op.on('-h', '--help')    { puts op.to_s; exit }
    op.on('-v', '--version') { puts version; exit }
    op.on('-V', '--verbose') { @options[:verbose] = true }
    op.separator ''

    op.parse!(ARGV)
  end

  def banner
    'Options for ModMods for Slack'
  end

  def name
    'ModMods'
  end

  def version
    '0.0.1'
  end

  def app_options(op)
  end
end
