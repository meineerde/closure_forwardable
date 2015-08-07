module ClosureForwardable
  # Version information about ClosureForwardable.
  # We follow semantic versioning
  module Version
    # MAJOR version. It is incremented after incompatible API changes
    MAJOR = 0
    # MINOR version. It is incremented after adding functionality in a
    # backwards-compatible manner
    MINOR = 1
    # PATCH version. It is incremented when making backwards-compatible
    # bug-fixes.
    PATCH  = 0

    # A standard string representation of the version parts
    STRING = [MAJOR, MINOR, PATCH].compact.join('.').freeze

    # @return [Gem::Version] the version of the currently loaded
    #   ClosureForwardable as a `Gem::Version`
    def self.gem_version
      Gem::Version.new to_s
    end

    # @return [String] the ClosureForwardable version as a semver-compliant
    #   string
    def self.to_s
      STRING
    end
  end

  # The ClosureForwardable version as a semver-compliant string
  # @see Version::STRING
  VERSION = Version::STRING
end
