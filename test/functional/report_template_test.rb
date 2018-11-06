require File.join(File.dirname(__FILE__), 'test_helper')

describe 'report-template' do
  let(:first_report) do
    {
      'id' => 1,
      'name' => 'First Report',
    }
  end
  let(:second_report) do
    {
      'id' => 2,
      'name' => 'Second Report',
    }
  end
  let(:third_report) do
    {
      'id' => 3,
      'name' => 'Third Report',
      'template' => 'Template Content',
      'default' => false,
      'created_at' => '2018-10-09 08:48:55 UTC',
      'updated_at' => '2018-10-10 11:05:45 UTC',
    }
  end
  let(:first_input) do
    {
      'template_id' => 3,
      'description' => 'Format of the generated report (csv or yaml)',
      'required' => true,
      'id' => 1,
      'name' => 'Output format',
      'options' => ['csv', 'yaml'],
    }
  end

  describe 'list' do
    let(:cmd) { %w(report-template list) }

    it 'lists all reports' do
      params = []
      api_expects(:report_templates, :index, 'List').with_params('page' => 1, 'per_page' => 1000).
        returns(index_response([first_report, second_report]))

      output = IndexMatcher.new([
        ['ID', 'NAME'],
        ['1',  'First Report'],
        ['2',  'Second Report'],
      ])
      expected_result = success_result(output)

      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'info' do
    let(:cmd) { %w(report-template info) }
    it 'loads input details' do
      params = ['--id=3']
      api_expects(:report_templates, :show, 'Show').with_params('id' => '3').
        returns(third_report)
      api_expects(:template_inputs, :index, 'list inputs').with_params(:template_id => '3').
        returns(index_response([first_input]))

      output = OutputMatcher.new([
        'Id:              3',
        'Name:            Third Report',
        'Default:         no',
        'Created at:      2018/10/09 08:48:55',
        'Updated at:      2018/10/10 11:05:45',
        'Template inputs:',
        ' 1) Name:        Output format',
        '    Description: Format of the generated report (csv or yaml)',
        '    Required:    yes',
        '    Options:     csv, yaml',
      ])
      expected_result = success_result(output)
      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'create' do
    let(:cmd) { %w(report-template create) }
    let(:tempfile) { Tempfile.new('template') }
    it 'requires --interactive or --file' do
      params = ['--name=test']
      api_expects_no_call
      expected_result = usage_error_result(
        cmd,
        'At least one of options --interactive, --file is required.',
        'Could not create the report template')
      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'creates the template' do
      params = ['--name=test', '--default=yes', "--file=#{tempfile.path}", '--locked=no', '--snippet=no']
      tempfile.write('Template content')
      tempfile.rewind
      api_expects(:report_templates, :create, 'Create template').with_params(
        'report_template' => {
          'name' => 'test',
          'template' => 'Template content',
          'snippet' => false,
          'locked' => false,
          'default' => true
        }).returns(second_report)

      result = run_cmd(cmd + params)
      assert_cmd(success_result("Report template created.\n"), result)
    end

    it 'invokes editor in interactive mode' do
      params = ['--name=test', '--default=yes', "--interactive", '--locked=no', '--snippet=no']
      HammerCLI.expects(:open_in_editor).with("", {:content_type => "report_template", :suffix => ".erb"}).returns('Template content')
      api_expects(:report_templates, :create, 'Create template').with_params(
        'report_template' => {
          'name' => 'test',
          'template' => 'Template content',
          'snippet' => false,
          'locked' => false,
          'default' => true
        }).returns(second_report)

      result = run_cmd(cmd + params)
      assert_cmd(success_result("Report template created.\n"), result)
    end
  end

  describe 'update' do
    let(:cmd) { %w(report-template update) }
    let(:tempfile) { Tempfile.new('template') }
    it 'updates the template' do
      params = ['--id=1', '--new-name=test', '--default=yes', "--file=#{tempfile.path}", '--locked=no', '--snippet=no']
      tempfile.write('Template content')
      tempfile.rewind
      api_expects(:report_templates, :update, 'Update template').with_params(
        'report_template' => {
          'name' => 'test',
          'template' => 'Template content',
          'snippet' => false,
          'locked' => false,
          'default' => true
        }).returns(second_report)

      result = run_cmd(cmd + params)
      assert_cmd(success_result("Report template updated.\n"), result)
    end

    it 'invokes editor in interactive mode' do
      params = ['--id=3', '--new-name=test', '--default=yes', "--interactive", '--locked=no', '--snippet=no']
      HammerCLI.expects(:open_in_editor).with(
        "Template Content", {:content_type => "report_template", :suffix => ".erb"}).returns('Template content')
      api_expects(:report_templates, :show, 'Show').with_params('id' => '3').returns(third_report)
      api_expects(:report_templates, :update, 'Update template').with_params(
        'report_template' => {
          'name' => 'test',
          'template' => 'Template content',
          'snippet' => false,
          'locked' => false,
          'default' => true
        }).returns(second_report)

      result = run_cmd(cmd + params)
      assert_cmd(success_result("Report template updated.\n"), result)
    end
  end

  describe 'dump' do
    let(:cmd) { %w(report-template dump) }
    it 'dump the template content' do
      params = ['--id=3']
      api_expects(:report_templates, :show, 'Show').with_params('id' => '3').returns(third_report)

      output = OutputMatcher.new('Template Content')
      expected_result = success_result(output)
      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end

  describe 'clone' do
    let(:cmd) { %w(report-template clone) }
    it 'requires --new-name' do
      params = ['--id=1']
      api_expects_no_call

      expected_result = usage_error_result(
        cmd,
        'Option --new-name is required.',
        'Could not clone the report template')
      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end

    it 'clones the template' do
      params = ['--id=1', '--new-name=zzz']

      api_expects(:report_templates, :clone, 'Clone template') do |par|
        par['id'] == '1' && par['report_template']['name'] == 'zzz'
      end.returns(second_report)

      result = run_cmd(cmd + params)
      assert_cmd(success_result("Report template cloned.\n"), result)
    end
  end

  describe 'delete' do
    let(:cmd) { %w(report-template delete) }
    it 'clones the template' do
      params = ['--id=1']

      api_expects(:report_templates, :destroy, 'Delete template').with_params(:id => '1')

      result = run_cmd(cmd + params)
      assert_cmd(success_result("Report template deleted.\n"), result)
    end
  end

  describe 'generate' do
    let(:cmd) { %w(report-template generate) }
    let(:tempfile) { Tempfile.new('template', '/tmp') }

    it 'generates the report to the file' do
      params = ['--id=3', '--path=/tmp', '--inputs=Host filter=filter']
      response = mock()
      response.stubs(:body).returns('Report')
      response.stubs(:headers).returns({:content_disposition => "filename=\"#{File.basename(tempfile.path)}\""})
      api_expects(:report_templates, :generate, 'Generate').with_params(
        'id' => '3', "input_values" => {"Host filter" => "filter"}).returns(response)

      output = OutputMatcher.new("The response has been saved to #{tempfile.path}")
      expected_result = success_result(output)
      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
      assert_equal('Report', tempfile.read)
    end

    it 'generates the report to stdout' do
      params = ['--id=3', '--inputs=Host filter=filter']
      response = mock()
      response.stubs(:body).returns('Report')
      api_expects(:report_templates, :generate, 'Generate').with_params(
        'id' => '3', "input_values" => {"Host filter" => "filter"}).returns(response)

      output = OutputMatcher.new('Report')
      expected_result = success_result(output)
      result = run_cmd(cmd + params)
      assert_cmd(expected_result, result)
    end
  end
end
