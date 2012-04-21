module Ore
  #
  # Provides methods for guessing the namespaces and directories
  # of projects. {Naming} uses the naming conventions of project names
  # defined by the
  # [Ruby Packaging Standard (RPS)](http://chneukirchen.github.com/rps/).
  #
  module Naming
    # The directory which contains executables for a project
    @@bin_dir = 'bin'

    # The directory which contains the code for a project
    @@lib_dir = 'lib'

    # The directory which contains C extension code for a project
    @@ext_dir = 'ext'

    # The directory which contains data files for a project
    @@data_dir = 'data'

    # The directory which contains unit-tests for a project
    @@test_dir = 'test'

    # The directory which contains spec-tests for a project
    @@spec_dir = 'spec'

    # The directory which contains built packages
    @@pkg_dir = 'pkg'

    # Words used in project names, but never in directory names
    @@ignore_namespaces = %w[core ruby rb java]

    # Common acronyms used in namespaces
    @@namespace_acronyms = %w[
      ffi yard i18n
      http https ftp smtp imap pop3 ssh ssl tcp udp dns rpc
      url uri www css html xhtml xml xsl json yaml csv
      posix unix bsd
      cpp asm
    ]

    # Common project prefixes and namespaces
    @@common_namespaces = {
      'rubygems' => 'Gem',
      'ar' => 'ActiveRecord',
      'dm' => 'DataMapper',
      'js' => 'JavaScript',
      'msgpack' => 'MsgPack',
      'github' => 'GitHub',
      'rdoc' => 'RDoc'
    }

    #
    # Splits the project name into individual names.
    #
    # @param [String] name
    #   The name to split.
    #
    # @return [Array<String>]
    #   The individual names of the project name.
    #
    def names_in(name)
      name.split('-').reject do |word|
        @@ignore_namespaces.include?(word)
      end
    end

    #
    # Guesses the module name for a word within a project name.
    #
    # @param [String] word
    #   The word within a project name.
    #
    # @return [String]
    #   The module name.
    #
    # @since 0.1.1
    #
    def module_of(word)
      if @@common_namespaces.has_key?(word)
        @@common_namespaces[word]
      elsif @@namespace_acronyms.include?(word)
        word.upcase
      else
        word.capitalize
      end
    end

    #
    # Guesses the module names from a project name.
    #
    # @param [String] name
    #   The name of the project.
    #
    # @return [Array<String>]
    #   The module names for a project.
    #
    def modules_of(name)
      names_in(name).map do |words|
        words.split('_').map { |word| module_of(word) }.join
      end
    end

    #
    # Guesses the full namespace for a project.
    #
    # @param [String] name
    #   The name of the project.
    #
    # @return [String]
    #   The full module namespace for a project.
    #
    def namespace_of(name)
      modules_of(name).join('::')
    end

    #
    # Converts a camel-case name to an underscored file name.
    #
    # @param [String] name
    #   The name to underscore.
    #
    # @return [String]
    #   The underscored version of the name.
    #
    def underscore(name)
      name.gsub(/[^A-Z_][A-Z][^A-Z_]/) { |cap|
        cap[0,1] + '_' + cap[1..-1]
      }.downcase
    end

    #
    # Guesses the namespace directories within `lib/` for a project.
    #
    # @param [String] name
    #   The name of the project.
    #
    # @return [Array<String>]
    #   The namespace directories for the project.
    #
    def namespace_dirs_of(name)
      names_in(name).map { |word| underscore(word) }
    end

    #
    # Guesses the namespace directory within `lib/` for a project.
    #
    # @param [String] name
    #   The name of the project.
    #
    # @return [String]
    #   The namespace directory for the project.
    #
    def namespace_path_of(name)
      File.join(namespace_dirs_of(name))
    end
  end
end