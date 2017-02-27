class Syslog::Logger
  alias_attribute :local_level, :level
  include LoggerSilence
end
