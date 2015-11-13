require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'apipie_resource_mock')
require File.join(File.dirname(__FILE__), 'helpers/fake_searchables')

describe HammerCLIForeman::DependencyResolver do

  let(:resolver) { HammerCLIForeman::DependencyResolver.new }

  describe "for resource" do

    it "returns empty array for an independent resource" do
      resource = HammerCLIForeman.foreman_resource!(:bookmarks)
      resolver.resource_dependencies(resource).must_equal []
    end

    it "returns list of dependent resources" do
      resource = HammerCLIForeman.foreman_resource!(:images)
      resources = resolver.resource_dependencies(resource).map(&:name).sort_by{ |sym| sym.to_s }
      if FOREMAN_VERSION < Gem::Version.new('1.10')
        expected = [
          :compute_resources, :organizations, :locations
        ]
      else
        expected = [
          :architectures, :compute_resources, :config_templates, :locations,
          :media, :operatingsystems, :organizations, :provisioning_templates, :ptables
        ]
      end
      resources.must_equal expected.sort_by{ |sym| sym.to_s }
    end

  end

  describe "for action" do

    it "returns empty array for an independent action" do
      action = HammerCLIForeman.foreman_resource!(:organizations).action(:index)
      resolver.action_dependencies(action).must_equal []
    end

    it "returns list of dependent resources" do
      action = HammerCLIForeman.foreman_resource!(:hostgroups).action(:create)
      resources = resolver.action_dependencies(action).map(&:name).sort_by{ |sym| sym.to_s }
      if FOREMAN_VERSION < Gem::Version.new('1.10')
        expected = [
          :environments, :operatingsystems, :architectures, :media,
          :ptables, :subnets, :domains, :realms, :organizations, :locations
        ]
      else
        expected = [
          :architectures, :compute_profiles, :config_templates, :domains, :environments,
          :hostgroups, :hosts, :locations, :media, :operatingsystems, :organizations,
          :provisioning_templates, :ptables, :puppetclasses, :realms, :subnets
        ]
      end
      resources.must_equal expected.sort_by{|sym| sym.to_s}
    end

  end

end
