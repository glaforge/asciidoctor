require 'test_helper'

context 'Document' do

  context 'Example document' do
    test 'document title' do
      doc = example_document(:asciidoc_index)
      assert_equal 'AsciiDoc Home Page', doc.doctitle
      assert_equal 'AsciiDoc Home Page', doc.name
      assert_equal 14, doc.blocks.size
      assert_equal :preamble, doc.blocks[0].context
      assert doc.blocks[1].is_a? ::Asciidoctor::Section
    end
  end

  context 'Default settings' do
    test 'safe mode level set to SECURE by default' do
      doc = Asciidoctor::Document.new
      assert_equal Asciidoctor::SafeMode::SECURE, doc.safe
    end

    test 'safe mode level set using string' do
      doc = Asciidoctor::Document.new [], :safe => 'server'
      assert_equal Asciidoctor::SafeMode::SERVER, doc.safe

      doc = Asciidoctor::Document.new [], :safe => 'foo'
      assert_equal Asciidoctor::SafeMode::SECURE, doc.safe
    end

    test 'safe mode level set using symbol' do
      doc = Asciidoctor::Document.new [], :safe => :server
      assert_equal Asciidoctor::SafeMode::SERVER, doc.safe

      doc = Asciidoctor::Document.new [], :safe => :foo
      assert_equal Asciidoctor::SafeMode::SECURE, doc.safe
    end

    test 'safe mode level set using integer' do
      doc = Asciidoctor::Document.new [], :safe => 10
      assert_equal Asciidoctor::SafeMode::SERVER, doc.safe

      doc = Asciidoctor::Document.new [], :safe => 100
      assert_equal 100, doc.safe
    end

    test 'safe mode attributes are set on document' do
      doc = Asciidoctor::Document.new
      assert_equal Asciidoctor::SafeMode::SECURE, doc.attr('safe-mode-level')
      assert_equal 'secure', doc.attr('safe-mode-name')
      assert doc.attr?('safe-mode-secure')
      assert !doc.attr?('safe-mode-unsafe')
      assert !doc.attr?('safe-mode-safe')
      assert !doc.attr?('safe-mode-server')
    end

    test 'safe mode level can be set in the constructor' do
      doc = Asciidoctor::Document.new [], :safe => Asciidoctor::SafeMode::SAFE
      assert_equal Asciidoctor::SafeMode::SAFE, doc.safe
    end

    test 'safe model level cannot be modified' do
      doc = Asciidoctor::Document.new
      begin
        doc.safe = Asciidoctor::SafeMode::UNSAFE
        flunk 'safe mode property of Asciidoctor::Document should not be writable!' 
      rescue
      end
    end
  end

  context 'Load APIs' do
    test 'should load input file' do
      sample_input_path = fixture_path('sample.asciidoc')
      doc = Asciidoctor.load(File.new(sample_input_path), :safe => Asciidoctor::SafeMode::SAFE)
      assert_equal 'Document Title', doc.doctitle
      assert_equal File.expand_path(sample_input_path), doc.attr('docfile')
      assert_equal File.expand_path(File.dirname(sample_input_path)), doc.attr('docdir')
    end

    test 'should load input file from filename' do
      sample_input_path = fixture_path('sample.asciidoc')
      doc = Asciidoctor.load_file(sample_input_path, :safe => Asciidoctor::SafeMode::SAFE)
      assert_equal 'Document Title', doc.doctitle
      assert_equal File.expand_path(sample_input_path), doc.attr('docfile')
      assert_equal File.expand_path(File.dirname(sample_input_path)), doc.attr('docdir')
    end

    test 'should load input IO' do
      input = StringIO.new(<<-EOS)
Document Title
==============

preamble
      EOS
      doc = Asciidoctor.load(input, :safe => Asciidoctor::SafeMode::SAFE)
      assert_equal 'Document Title', doc.doctitle
      assert !doc.attr?('docfile')
      assert_equal doc.base_dir, doc.attr('docdir')
    end

    test 'should load input string' do
      input = <<-EOS
Document Title
==============

preamble
      EOS
      doc = Asciidoctor.load(input, :safe => Asciidoctor::SafeMode::SAFE)
      assert_equal 'Document Title', doc.doctitle
      assert !doc.attr?('docfile')
      assert_equal doc.base_dir, doc.attr('docdir')
    end

    test 'should load input string array' do
      input = <<-EOS
Document Title
==============

preamble
      EOS
      doc = Asciidoctor.load(input.lines.entries, :safe => Asciidoctor::SafeMode::SAFE)
      assert_equal 'Document Title', doc.doctitle
      assert !doc.attr?('docfile')
      assert_equal doc.base_dir, doc.attr('docdir')
    end

    test 'should accept attributes as array' do
	  # NOTE there's a tab character before idseparator
      doc = Asciidoctor.load('text', :attributes => %w(toc numbered   source-highlighter=coderay idprefix	idseparator=-))
      assert doc.attributes.is_a?(Hash)
      assert doc.attr?('toc')
      assert_equal '', doc.attr('toc')
      assert doc.attr?('numbered')
      assert_equal '', doc.attr('numbered')
      assert doc.attr?('source-highlighter')
      assert_equal 'coderay', doc.attr('source-highlighter')
      assert doc.attr?('idprefix')
      assert_equal '', doc.attr('idprefix')
      assert doc.attr?('idseparator')
      assert_equal '-', doc.attr('idseparator')
    end

    test 'should accept attributes as empty array' do
      doc = Asciidoctor.load('text', :attributes => [])
      assert doc.attributes.is_a?(Hash)
    end

    test 'should accept attributes as string' do
	  # NOTE there's a tab character before idseparator
      doc = Asciidoctor.load('text', :attributes => 'toc numbered  source-highlighter=coderay idprefix	idseparator=-')
      assert doc.attributes.is_a?(Hash)
      assert doc.attr?('toc')
      assert_equal '', doc.attr('toc')
      assert doc.attr?('numbered')
      assert_equal '', doc.attr('numbered')
      assert doc.attr?('source-highlighter')
      assert_equal 'coderay', doc.attr('source-highlighter')
      assert doc.attr?('idprefix')
      assert_equal '', doc.attr('idprefix')
      assert doc.attr?('idseparator')
      assert_equal '-', doc.attr('idseparator')
    end

    test 'should accept values containing spaces in attributes string' do
	  # NOTE there's a tab character before self:
      doc = Asciidoctor.load('text', :attributes => 'idprefix idseparator=-   note-caption=Note\ to\	self: toc')
      assert doc.attributes.is_a?(Hash)
      assert doc.attr?('idprefix')
      assert_equal '', doc.attr('idprefix')
      assert doc.attr?('idseparator')
      assert_equal '-', doc.attr('idseparator')
      assert doc.attr?('note-caption')
      assert_equal "Note to	self:", doc.attr('note-caption')
    end

    test 'should accept attributes as empty string' do
      doc = Asciidoctor.load('text', :attributes => '')
      assert doc.attributes.is_a?(Hash)
    end

    test 'should accept attributes as nil' do
      doc = Asciidoctor.load('text', :attributes => nil)
      assert doc.attributes.is_a?(Hash)
    end
  end

  context 'Render APIs' do
    test 'should render document to string' do
      sample_input_path = fixture_path('sample.asciidoc')

      output = Asciidoctor.render_file(sample_input_path, :header_footer => true)
      assert !output.empty?
      assert_xpath '/html', output, 1
      assert_xpath '/html/head', output, 1
      assert_xpath '/html/body', output, 1
      assert_xpath '/html/head/title[text() = "Document Title"]', output, 1
      assert_xpath '/html/body/*[@id="header"]/h1[text() = "Document Title"]', output, 1
    end

    test 'should accept attributes as array' do
      sample_input_path = fixture_path('sample.asciidoc')
      output = Asciidoctor.render_file(sample_input_path, :attributes => %w(numbered idprefix idseparator=-))
      assert_css '#section-a', output, 1
    end

    test 'should accept attributes as string' do
      sample_input_path = fixture_path('sample.asciidoc')
      output = Asciidoctor.render_file(sample_input_path, :attributes => 'numbered idprefix idseparator=-')
      assert_css '#section-a', output, 1
    end

    test 'should include docinfo files for html backend' do
      sample_input_path = fixture_path('basic.asciidoc')

      output = Asciidoctor.render_file(sample_input_path,
          :header_footer => true, :safe => Asciidoctor::SafeMode::SERVER, :attributes => {'docinfo' => ''})
      assert !output.empty?
      assert_css 'script[src="modernizr.js"]', output, 1
      assert_css 'meta[http-equiv="imagetoolbar"]', output, 0

      output = Asciidoctor.render_file(sample_input_path,
          :header_footer => true, :safe => Asciidoctor::SafeMode::SERVER, :attributes => {'docinfo1' => ''})
      assert !output.empty?
      assert_css 'script[src="modernizr.js"]', output, 0
      assert_css 'meta[http-equiv="imagetoolbar"]', output, 1

      output = Asciidoctor.render_file(sample_input_path,
          :header_footer => true, :safe => Asciidoctor::SafeMode::SERVER, :attributes => {'docinfo2' => ''})
      assert !output.empty?
      assert_css 'script[src="modernizr.js"]', output, 1
      assert_css 'meta[http-equiv="imagetoolbar"]', output, 1
    end

    test 'should include docinfo files for docbook backend' do
      sample_input_path = fixture_path('basic.asciidoc')

      output = Asciidoctor.render_file(sample_input_path,
          :header_footer => true, :backend => 'docbook', :safe => Asciidoctor::SafeMode::SERVER, :attributes => {'docinfo' => ''})
      assert !output.empty?
      assert_css 'productname', output, 0
      assert_css 'copyright', output, 1

      output = Asciidoctor.render_file(sample_input_path,
          :header_footer => true, :backend => 'docbook', :safe => Asciidoctor::SafeMode::SERVER, :attributes => {'docinfo1' => ''})
      assert !output.empty?
      assert_css 'productname', output, 1
      assert_css 'copyright', output, 0

      output = Asciidoctor.render_file(sample_input_path,
          :header_footer => true, :backend => 'docbook', :safe => Asciidoctor::SafeMode::SERVER, :attributes => {'docinfo2' => ''})
      assert !output.empty?
      assert_css 'productname', output, 1
      assert_css 'copyright', output, 1
    end

    test 'should not include docinfo files by default' do
      sample_input_path = fixture_path('basic.asciidoc')

      output = Asciidoctor.render_file(sample_input_path,
          :header_footer => true, :safe => Asciidoctor::SafeMode::SERVER)
      assert !output.empty?
      assert_css 'script[src="modernizr.js"]', output, 0
      assert_css 'meta[http-equiv="imagetoolbar"]', output, 0

      output = Asciidoctor.render_file(sample_input_path,
          :header_footer => true, :backend => 'docbook', :safe => Asciidoctor::SafeMode::SERVER)
      assert !output.empty?
      assert_css 'productname', output, 0
      assert_css 'copyright', output, 0
    end

    test 'should not include docinfo files if safe mode is SECURE or greater' do
      sample_input_path = fixture_path('basic.asciidoc')

      output = Asciidoctor.render_file(sample_input_path,
          :header_footer => true, :attributes => {'docinfo2' => ''})
      assert !output.empty?
      assert_css 'script[src="modernizr.js"]', output, 0
      assert_css 'meta[http-equiv="imagetoolbar"]', output, 0

      output = Asciidoctor.render_file(sample_input_path,
          :header_footer => true, :backend => 'docbook', :attributes => {'docinfo2' => ''})
      assert !output.empty?
      assert_css 'productname', output, 0
      assert_css 'copyright', output, 0
    end

    test 'should link to default stylesheet by default' do
      sample_input_path = fixture_path('basic.asciidoc')
      output = Asciidoctor.render_file(sample_input_path, :header_footer => true)
      assert_css 'html:root > head > link[rel="stylesheet"][href="./asciidoctor.css"]', output, 1
    end

    test 'should link to default stylesheet by default if linkcss is unset in document' do
      input = <<-EOS
= Document Title
:linkcss!:

text
      EOS

      output = Asciidoctor.render(input, :header_footer => true)
      assert_css 'html:root > head > link[rel="stylesheet"][href="./asciidoctor.css"]', output, 1
    end

    test 'should link to default stylesheet by default if linkcss is unset' do
      input = <<-EOS
= Document Title

text
      EOS

      output = Asciidoctor.render(input, :header_footer => true, :attributes => {'linkcss!' => ''})
      assert_css 'html:root > head > link[rel="stylesheet"][href="./asciidoctor.css"]', output, 1
    end

    test 'should embed default stylesheet if safe mode is less than secure and linkcss is unset' do
      sample_input_path = fixture_path('basic.asciidoc')
      output = Asciidoctor.render_file(sample_input_path, :header_footer => true,
          :safe => Asciidoctor::SafeMode::SAFE, :attributes => {'linkcss!' => ''})
      assert_css 'html:root > head > style', output, 1
      stylenode = xmlnodes_at_css 'html:root > head > style', output, 1
      styles = stylenode.first.content
      assert !styles.nil?
      assert !styles.strip.empty?
    end

    test 'should not link to stylesheet if stylesheet is unset' do
      input = <<-EOS
= Document Title

text
      EOS

      output = Asciidoctor.render(input, :header_footer => true, :attributes => {'stylesheet!' => ''})
      assert_css 'html:root > head > link[rel="stylesheet"]', output, 0
    end

    test 'should link to custom stylesheet if specified in stylesheet attribute' do
      input = <<-EOS
= Document Title

text
      EOS

      output = Asciidoctor.render(input, :header_footer => true, :attributes => {'stylesheet' => './custom.css'})
      assert_css 'html:root > head > link[rel="stylesheet"][href="./custom.css"]', output, 1
    end

    test 'should resolve custom stylesheet relative to stylesdir' do
      input = <<-EOS
= Document Title

text
      EOS

      output = Asciidoctor.render(input, :header_footer => true, :attributes => {'stylesheet' => 'custom.css', 'stylesdir' => './stylesheets'})
      assert_css 'html:root > head > link[rel="stylesheet"][href="./stylesheets/custom.css"]', output, 1
    end

    test 'should resolve custom stylesheet to embed relative to stylesdir' do
      sample_input_path = fixture_path('basic.asciidoc')
      output = Asciidoctor.render_file(sample_input_path, :header_footer => true, :safe => Asciidoctor::SafeMode::SAFE,
          :attributes => {'stylesheet' => 'custom.css', 'stylesdir' => './stylesheets', 'linkcss!' => ''})
      stylenode = xmlnodes_at_css 'html:root > head > style', output, 1
      styles = stylenode.first.content
      assert !styles.nil?
      assert !styles.strip.empty?
    end

    test 'should render document in place' do
      sample_input_path = fixture_path('sample.asciidoc')
      sample_output_path = fixture_path('sample.html')
      begin
        Asciidoctor.render_file(sample_input_path, :in_place => true)
        assert File.exist?(sample_output_path)
        output = File.read(sample_output_path)
        assert !output.empty?
        assert_xpath '/html', output, 1
        assert_xpath '/html/head', output, 1
        assert_xpath '/html/body', output, 1
        assert_xpath '/html/head/title[text() = "Document Title"]', output, 1
        assert_xpath '/html/body/*[@id="header"]/h1[text() = "Document Title"]', output, 1
      ensure
        FileUtils::rm(sample_output_path)
      end
    end

    test 'should render document to file' do
      sample_input_path = fixture_path('sample.asciidoc')
      sample_output_path = fixture_path('result.html')
      begin
        Asciidoctor.render_file(sample_input_path, :to_file => sample_output_path)
        assert File.exist?(sample_output_path)
        output = File.read(sample_output_path)
        assert !output.empty?
        assert_xpath '/html', output, 1
        assert_xpath '/html/head', output, 1
        assert_xpath '/html/body', output, 1
        assert_xpath '/html/head/title[text() = "Document Title"]', output, 1
        assert_xpath '/html/body/*[@id="header"]/h1[text() = "Document Title"]', output, 1
      ensure
        FileUtils::rm(sample_output_path)
      end
    end

    test 'wip should render document to file when base dir is set' do
      sample_input_path = fixture_path('sample.asciidoc')
      sample_output_path = fixture_path('result.html')
      fixture_dir = fixture_path('')
      begin
        Asciidoctor.render_file(sample_input_path, :to_file => 'result.html', :base_dir => fixture_dir)
        assert File.exist?(sample_output_path)
        output = File.read(sample_output_path)
        assert !output.empty?
        assert_xpath '/html', output, 1
        assert_xpath '/html/head', output, 1
        assert_xpath '/html/body', output, 1
        assert_xpath '/html/head/title[text() = "Document Title"]', output, 1
        assert_xpath '/html/body/*[@id="header"]/h1[text() = "Document Title"]', output, 1
      rescue => e
        flunk e.message
      ensure
        FileUtils::rm(sample_output_path, :force => true)
      end
    end

    test 'in_place option must not be used with to_file option' do
      sample_input_path = fixture_path('sample.asciidoc')
      sample_output_path = fixture_path('result.html')
      assert_raise ArgumentError do
        begin
          Asciidoctor.render_file(sample_input_path, :to_file => sample_output_path, :in_place => true)
        ensure
          FileUtils::rm(sample_output_path) if File.exists? sample_output_path
        end
      end
    end

    test 'in_place option must not be used with to_dir option' do
      sample_input_path = fixture_path('sample.asciidoc')
      sample_output_path = fixture_path('result.html')
      assert_raise ArgumentError do
        begin
          Asciidoctor.render_file(sample_input_path, :to_dir => '', :in_place => true)
        ensure
          FileUtils::rm(sample_output_path) if File.exists? sample_output_path
        end
      end
    end

    test 'output should be relative to to_dir option' do
      sample_input_path = fixture_path('sample.asciidoc')
      output_dir = File.join(File.dirname(sample_input_path), 'test_output')
      Dir.mkdir output_dir if !File.exists? output_dir
      sample_output_path = File.join(output_dir, 'sample.html')
      begin
        Asciidoctor.render_file(sample_input_path, :to_dir => output_dir)
        assert File.exists? sample_output_path
      ensure
        FileUtils::rm(sample_output_path) if File.exists? sample_output_path
        FileUtils::rmdir output_dir
      end
    end

    test 'missing directories should be created if mkdirs is enabled' do
      sample_input_path = fixture_path('sample.asciidoc')
      output_dir = File.join(File.join(File.dirname(sample_input_path), 'test_output'), 'subdir')
      sample_output_path = File.join(output_dir, 'sample.html')
      begin
        Asciidoctor.render_file(sample_input_path, :to_dir => output_dir, :mkdirs => true)
        assert File.exists? sample_output_path
      ensure
        FileUtils::rm(sample_output_path) if File.exists? sample_output_path
        FileUtils::rmdir output_dir
        FileUtils::rmdir File.dirname(output_dir)
      end
    end

    test 'to_file should be relative to to_dir when both given' do
      sample_input_path = fixture_path('sample.asciidoc')
      base_dir = File.dirname(sample_input_path)
      sample_rel_output_path = File.join('test_output', 'result.html')
      output_dir = File.dirname(File.join(base_dir, sample_rel_output_path))
      Dir.mkdir output_dir if !File.exists? output_dir
      sample_output_path = File.join(base_dir, sample_rel_output_path)
      begin
        Asciidoctor.render_file(sample_input_path, :to_dir => base_dir, :to_file => sample_rel_output_path)
        assert File.exists? sample_output_path
      ensure
        FileUtils::rm(sample_output_path) if File.exists? sample_output_path
        FileUtils::rmdir output_dir
      end
    end
  end

  context 'Renderer' do
    test 'built-in HTML5 views are registered by default' do
      doc = document_from_string ''
      assert_equal 'html5', doc.attributes['backend']
      assert doc.attributes.has_key? 'backend-html5'
      assert_equal 'html', doc.attributes['basebackend']
      assert doc.attributes.has_key? 'basebackend-html'
      renderer = doc.renderer
      assert !renderer.nil?
      views = renderer.views
      assert !views.nil?
      assert_equal 33, views.size
      assert views.has_key? 'document'
      assert views['document'].is_a?(Asciidoctor::HTML5::DocumentTemplate)
      assert_equal 'ERB', views['document'].eruby.to_s
    end

    test 'built-in DocBook45 views are registered when backend is docbook45' do
      doc = document_from_string '', :attributes => {'backend' => 'docbook45'}
      renderer = doc.renderer
      assert_equal 'docbook45', doc.attributes['backend']
      assert doc.attributes.has_key? 'backend-docbook45'
      assert_equal 'docbook', doc.attributes['basebackend']
      assert doc.attributes.has_key? 'basebackend-docbook'
      assert !renderer.nil?
      views = renderer.views
      assert !views.nil?
      assert_equal 33, views.size
      assert views.has_key? 'document'
      assert views['document'].is_a?(Asciidoctor::DocBook45::DocumentTemplate)
      assert_equal 'ERB', views['document'].eruby.to_s
    end
  
    test 'can set erubis as eRuby implementation' do
      doc = Asciidoctor::Document.new [], :eruby => 'erubis', :header_footer => true
      assert $LOADED_FEATURES.detect {|p| p == 'erubis.rb' || p.end_with?('/erubis.rb') }.nil?
      renderer = doc.renderer
      assert $LOADED_FEATURES.detect {|p| p == 'erubis.rb' || p.end_with?('/erubis.rb') }
      views = renderer.views
      assert !views.nil?
      assert views.has_key? 'document'
      assert_equal 'Erubis::FastEruby', views['document'].eruby.to_s
      assert_equal 'Erubis::FastEruby', views['document'].template.class.to_s
    end
  end

  context 'Structure' do
    test 'document with no doctitle' do
      doc = document_from_string('Snorf')
      assert_nil doc.doctitle
      assert_nil doc.name
      assert !doc.has_header?
      assert_nil doc.header
    end

    test 'document with doctitle defined as attribute entry' do
     input = <<-EOS
:doctitle: Document Title

preamble

== First Section
     EOS
     doc = document_from_string input
     assert_equal 'Document Title', doc.doctitle
     assert doc.has_header?
     assert_equal 'Document Title', doc.header.title
     assert_equal 'Document Title', doc.first_section.title
    end

    test 'document with title attribute entry overrides doctitle' do
     input = <<-EOS
= Title
:title: Document Title

preamble

== First Section
     EOS
     doc = document_from_string input
     assert_equal 'Document Title', doc.doctitle
     assert_equal 'Document Title', doc.title
     assert doc.has_header?
     assert_equal 'Title', doc.header.title
     assert_equal 'Title', doc.first_section.title
    end

    test 'document with doctitle attribute entry overrides header title and doctitle' do
     input = <<-EOS
= Title
:doctitle: Override

preamble

== First Section
     EOS
     doc = document_from_string input
     assert_equal 'Override', doc.doctitle
     assert_nil doc.title
     assert doc.has_header?
     assert_equal 'Override', doc.header.title
     assert_equal 'Override', doc.first_section.title
    end

    test 'doctitle attribute entry above header overrides header title and doctitle' do
     input = <<-EOS
:doctitle: Override
= Title

preamble

== First Section
     EOS
     doc = document_from_string input
     assert_equal 'Override', doc.doctitle
     assert_nil doc.title
     assert doc.has_header?
     assert_equal 'Override', doc.header.title
     assert_equal 'Override', doc.first_section.title
    end

    test 'should recognize document title when preceded by blank lines' do
      input = <<-EOS
:doctype: book

= Title

preamble

== Section 1

text
      EOS
      output = render_string input, :safe => Asciidoctor::SafeMode::SAFE
      assert_css '#header h1', output, 1
      assert_css '#content h1', output, 0
    end
     
    test 'should not choke on empty source' do
      doc = Asciidoctor::Document.new ''
      assert doc.blocks.empty?
      assert_nil doc.doctitle
      assert !doc.has_header?
      assert_nil doc.header
    end

    test 'should not choke on nil source' do
      doc = Asciidoctor::Document.new nil
      assert doc.blocks.empty?
      assert_nil doc.doctitle
      assert !doc.has_header?
      assert_nil doc.header
    end

    test 'with metadata' do
      input = <<-EOS
= AsciiDoc
Stuart Rackham <founder@asciidoc.org>
v8.6.8, 2012-07-12: See changelog.

== Version 8.6.8

more info...
      EOS
      output = render_string input
      assert_xpath '//*[@id="header"]/span[@id="author"][text() = "Stuart Rackham"]', output, 1
      assert_xpath '//*[@id="header"]/span[@id="email"]/a[@href="mailto:founder@asciidoc.org"][text() = "founder@asciidoc.org"]', output, 1
      assert_xpath '//*[@id="header"]/span[@id="revnumber"][text() = "version 8.6.8,"]', output, 1
      assert_xpath '//*[@id="header"]/span[@id="revdate"][text() = "2012-07-12"]', output, 1
      assert_xpath '//*[@id="header"]/span[@id="revremark"][text() = "See changelog."]', output, 1
    end

    test 'with metadata to DocBook' do
      input = <<-EOS
= AsciiDoc
Stuart Rackham <founder@asciidoc.org>
v8.6.8, 2012-07-12: See changelog.

== Version 8.6.8

more info...
      EOS
      output = render_string input, :backend => 'docbook'
      assert_xpath '/article/articleinfo', output, 1
      assert_xpath '/article/articleinfo/title[text() = "AsciiDoc"]', output, 1
      assert_xpath '/article/articleinfo/date[text() = "2012-07-12"]', output, 1
      assert_xpath '/article/articleinfo/author/firstname[text() = "Stuart"]', output, 1
      assert_xpath '/article/articleinfo/author/surname[text() = "Rackham"]', output, 1
      assert_xpath '/article/articleinfo/author/email[text() = "founder@asciidoc.org"]', output, 1
      assert_xpath '/article/articleinfo/revhistory', output, 1
      assert_xpath '/article/articleinfo/revhistory/revision', output, 1
      assert_xpath '/article/articleinfo/revhistory/revision/revnumber[text() = "8.6.8"]', output, 1
      assert_xpath '/article/articleinfo/revhistory/revision/date[text() = "2012-07-12"]', output, 1
      assert_xpath '/article/articleinfo/revhistory/revision/authorinitials[text() = "SR"]', output, 1
      assert_xpath '/article/articleinfo/revhistory/revision/revremark[text() = "See changelog."]', output, 1
    end

    test 'should create authorgroup in DocBook when multiple authors' do
      input = <<-EOS
= Document Title
Doc Writer <thedoctor@asciidoc.org>; Junior Writer <junior@asciidoctor.org>

content
      EOS

      output = render_string input, :backend => 'docbook'
      assert_xpath '//articleinfo/author', output, 0
      assert_xpath '//articleinfo/authorgroup', output, 1
      assert_xpath '//articleinfo/authorgroup/author', output, 2
      assert_xpath '//articleinfo/authorgroup/author[1]/firstname[text() = "Doc"]', output, 1
      assert_xpath '//articleinfo/authorgroup/author[2]/firstname[text() = "Junior"]', output, 1
    end

    test 'with header footer' do
      doc = document_from_string "= Title\n\npreamble"
      assert !doc.attr?('embedded')
      result = doc.render
      assert_xpath '/html', result, 1
      assert_xpath '//*[@id="header"]', result, 1
      assert_xpath '//*[@id="header"]/h1', result, 1
      assert_xpath '//*[@id="footer"]', result, 1
      assert_xpath '//*[@id="preamble"]', result, 1
    end

    test 'no header footer' do
      doc = document_from_string "= Title\n\npreamble", :header_footer => false
      assert doc.attr?('embedded')
      result = doc.render
      assert_xpath '/html', result, 0
      assert_xpath '/h1', result, 0
      assert_xpath '/*[@id="header"]', result, 0
      assert_xpath '/*[@id="footer"]', result, 0
      assert_xpath '/*[@id="preamble"]', result, 1
    end

    test 'enable title when no header footer' do
      result = render_string("= Title\n\npreamble", :header_footer => false, :attributes => {'notitle!' => ''})
      assert_xpath '/html', result, 0
      assert_xpath '/h1', result, 1
      assert_xpath '/*[@id="header"]', result, 0
      assert_xpath '/*[@id="footer"]', result, 0
      assert_xpath '/*[@id="preamble"]', result, 1
      assert_xpath '(/*)[1]/self::h1', result, 1
      assert_xpath '(/*)[2]/self::*[@id="preamble"]', result, 1
    end

    test 'parse header only' do
      input = <<-EOS
= Document Title
Author Name
:foo: bar

preamble
      EOS

      doc = document_from_string input, :parse_header_only => true
      assert_equal 'Document Title', doc.doctitle
      assert_equal 'Author Name', doc.author
      assert_equal 'bar', doc.attributes['foo']
      # there would be at least 1 block had it parsed beyond the header
      assert_equal 0, doc.blocks.size
    end

    test 'renders footnotes in footer' do
      input = <<-EOS
A footnote footnote:[An example footnote.];
a second footnote with a reference ID footnoteref:[note2,Second footnote.];
finally a reference to the second footnote footnoteref:[note2].
      EOS

      output = render_string input
      assert_css '#footnotes', output, 1
      assert_css '#footnotes .footnote', output, 2
      assert_css '#footnotes .footnote#_footnote_1', output, 1
      assert_xpath '//div[@id="footnotes"]/div[@id="_footnote_1"]/a[@href="#_footnoteref_1"][text()="1"]', output, 1
      text = xmlnodes_at_xpath '//div[@id="footnotes"]/div[@id="_footnote_1"]/text()', output, 1
      assert_equal '. An example footnote.', text.text.strip
      assert_css '#footnotes .footnote#_footnote_2', output, 1
      assert_xpath '//div[@id="footnotes"]/div[@id="_footnote_2"]/a[@href="#_footnoteref_2"][text()="2"]', output, 1
      text = xmlnodes_at_xpath '//div[@id="footnotes"]/div[@id="_footnote_2"]/text()', output, 1
      assert_equal '. Second footnote.', text.text.strip
    end

    test 'renders footnotes block in embedded document by default' do
      input = <<-EOS
Text that has supporting information{empty}footnote:[An example footnote.].
      EOS

      output = render_string input, :header_footer => false
      assert_css '#footnotes', output, 1
    end

    test 'does not render footnotes block in embedded document if nofootnotes attribute is set' do
      input = <<-EOS
Text that has supporting information{empty}footnote:[An example footnote.].
      EOS

      output = render_string input, :header_footer => false, :attributes => {'nofootnotes' => ''}
      assert_css '#footnotes', output, 0
    end
  end

  context 'Backends and Doctypes' do 
    test 'html5 backend doctype article' do
      result = render_string("= Title\n\npreamble", :attributes => {'backend' => 'html5'})
      assert_xpath '/html', result, 1
      assert_xpath '/html/body[@class="article"]', result, 1
      assert_xpath '/html//*[@id="header"]/h1[text() = "Title"]', result, 1
      assert_xpath '/html//*[@id="preamble"]//p[text() = "preamble"]', result, 1
    end

    test 'html5 backend doctype book' do
      result = render_string("= Title\n\npreamble", :attributes => {'backend' => 'html5', 'doctype' => 'book'})
      assert_xpath '/html', result, 1
      assert_xpath '/html/body[@class="book"]', result, 1
      assert_xpath '/html//*[@id="header"]/h1[text() = "Title"]', result, 1
      assert_xpath '/html//*[@id="preamble"]//p[text() = "preamble"]', result, 1
    end

    test 'docbook45 backend doctype article' do
      input = <<-EOS
= Title

preamble

== First Section

section body
      EOS
      result = render_string(input, :attributes => {'backend' => 'docbook45'})
      assert_xpath '/article', result, 1
      assert_xpath '/article/articleinfo/title[text() = "Title"]', result, 1
      assert_xpath '/article/simpara[text() = "preamble"]', result, 1
      assert_xpath '/article/section', result, 1
      assert_xpath '/article/section[@id = "_first_section"]/title[text() = "First Section"]', result, 1
      assert_xpath '/article/section[@id = "_first_section"]/simpara[text() = "section body"]', result, 1
    end

    test 'docbook45 backend doctype article no title' do
      result = render_string('text', :attributes => {'backend' => 'docbook45'})
      assert_xpath '/article', result, 1
      assert_xpath '/article/articleinfo/date', result, 1
      assert_xpath '/article/simpara[text() = "text"]', result, 1
    end

    test 'docbook45 backend doctype book' do
      input = <<-EOS
= Title

preamble

== First Chapter

chapter body
      EOS
      result = render_string(input, :attributes => {'backend' => 'docbook45', 'doctype' => 'book'})
      assert_xpath '/book', result, 1
      assert_xpath '/book/bookinfo/title[text() = "Title"]', result, 1
      assert_xpath '/book/preface/simpara[text() = "preamble"]', result, 1
      assert_xpath '/book/chapter', result, 1
      assert_xpath '/book/chapter[@id = "_first_chapter"]/title[text() = "First Chapter"]', result, 1
      assert_xpath '/book/chapter[@id = "_first_chapter"]/simpara[text() = "chapter body"]', result, 1
    end

    test 'docbook45 backend doctype book no title' do
      result = render_string('text', :attributes => {'backend' => 'docbook45', 'doctype' => 'book'})
      assert_xpath '/book', result, 1
      assert_xpath '/book/bookinfo/date', result, 1
      assert_xpath '/book/simpara[text() = "text"]', result, 1
    end

    test 'docbook45 backend parses out subtitle' do
      input = <<-EOS
= Document Title: Subtitle
:doctype: book

text
      EOS
      result = render_string input, :backend => 'docbook45'
      assert_xpath '/book', result, 1
      assert_xpath '/book/bookinfo/title[text() = "Document Title"]', result, 1
      assert_xpath '/book/bookinfo/subtitle[text() = "Subtitle"]', result, 1
    end

    test 'should be able to set backend using :backend option key' do
      doc = Asciidoctor::Document.new([], :backend => 'html5')
      assert_equal 'html5', doc.attributes['backend']
    end

    test ':backend option should override backend attribute' do
      doc = Asciidoctor::Document.new([], :backend => 'html5', :attributes => {'backend' => 'docbook45'})
      assert_equal 'html5', doc.attributes['backend']
    end

    test 'should be able to set doctype using :doctype option key' do
      doc = Asciidoctor::Document.new([], :doctype => 'book')
      assert_equal 'book', doc.attributes['doctype']
    end

    test ':doctype option should override doctype attribute' do
      doc = Asciidoctor::Document.new([], :doctype => 'book', :attributes => {'doctype' => 'article'})
      assert_equal 'book', doc.attributes['doctype']
    end

    test 'do not override explicit author initials' do
      input = <<-EOS
= AsciiDoc
Stuart Rackham <founder@asciidoc.org>
:Author Initials: SJR

more info...
      EOS
      output = render_string input, :attributes => {'backend' => 'docbook45'}
      assert_xpath '/article/articleinfo/authorinitials[text()="SJR"]', output, 1
    end

    test 'attribute entry can appear immediately after document title' do
      input = <<-EOS
Reference Guide
===============
:toc:

preamble
      EOS
      doc = document_from_string input
      assert doc.attr?('toc')
      assert_equal '', doc.attr('toc')
    end

    test 'attribute entry can appear before author line under document title' do
      input = <<-EOS
Reference Guide
===============
:toc:
Dan Allen

preamble
      EOS
      doc = document_from_string input
      assert doc.attr?('toc')
      assert_equal '', doc.attr('toc')
      assert_equal 'Dan Allen', doc.attr('author')
    end
  end
end
