module Nanoc3::CLI

  class CreateLayoutCommand < Cri::Command # :nodoc:

    def name
      'create_layout'
    end

    def aliases
      [ 'cl' ]
    end

    def short_desc
      'create a layout'
    end

    def long_desc
      'Create a new layout in the current site.'
    end

    def usage
      "nanoc create_layout [identifier]"
    end

    def option_definitions
      [
        # --vcs
        {
          :long => 'vcs', :short => 'c', :argument => :required,
          :desc => 'select the VCS to use'
        }
      ]
    end

    def run(options, arguments)
      # Check arguments
      if arguments.length != 1
        $stderr.puts "usage: #{usage}"
        exit 1
      end

      # Extract arguments
      identifier = arguments[0].cleaned_identifier

      # Make sure we are in a nanoc site directory
      @base.require_site

      # Set VCS if possible
      @base.set_vcs(options[:vcs])

      # Check whether layout is unique
      if !@base.site.layouts.find { |l| l.identifier == identifier }.nil?
        $stderr.puts "A layout already exists at #{identifier}. Please " +
                     "pick a unique name for the layout you are creating."
        exit 1
      end

      # Check whether layout is not at /
      if identifier == '/'
        $stderr.puts "There cannot be a layout with the identifier '/'; " +
                     "please pick a different identifier for this layout."
        exit 1
      end

      # Setup notifications
      Nanoc3::NotificationCenter.on(:file_created) do |file_path|
        Nanoc3::CLI::Logger.instance.file(:high, :create, file_path, :color => @base.color?)
      end

      # Create layout
      @base.site.data_source.create_layout(
        "<html>\n" +
        "  <head>\n" +
        "    <title><%= @page.title %></title>\n" +
        "  </head>\n" +
        "  <body>\n" +
        "    <p>Hi, I'm a new layout. Please customize me!</p>\n" +
        "<%= yield %>\n" +
        "  </body>\n" +
        "</html>\n",
        { :filter => 'erb' },
        identifier
      )

      puts "A layout has been created at #{identifier}."
    end

  end

end