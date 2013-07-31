#
# Author:: Prabhu Das (<prabhu.das@clogeny.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'functional/resource/base'
require 'chef/mixin/shell_out'

describe Chef::Resource::BffPackage do
  include Chef::Mixin::ShellOut

  let(:new_resource) do
     new_resource = Chef::Resource::BffPackage.new(@pkg_name, run_context)
     new_resource.source @pkg_path
     new_resource
  end

  before(:all) do
    case ohai[:platform]
    # Due to dependency issues , different rpm pkgs are used in different platforms.
    when "aix"
      FileUtils.cp 'spec/functional/assets/glib-1.2.10-2.aix4.3.ppc.rpm' , "/tmp/glib-1.2.10-2.aix4.3.ppc.rpm"
      @pkg_name = "glib"
      @pkg_version = "1.2.10-2"
      @pkg_path = "/tmp/glib-1.2.10-2.aix4.3.ppc.rpm"
    end
  end

  after(:all) do
    FileUtils.rm @pkg_path
  end

  context "package install action" do
    it "should create a package" do
      new_resource.run_action(:install)
      rpm_pkg_should_be_installed(new_resource)
    end

    after(:each) do
      shell_out("rpm -qa | grep #{@pkg_name}-#{@pkg_version} | xargs rpm -e")
    end
  end
  context "package remove action" do
    before(:each) do
      shell_out("rpm -i #{@pkg_path.sub(%r{^/tmp/}, "")}")
    end

    it "should remove an existing package" do
      new_resource.run_action(:remove)
      rpm_pkg_should_not_be_installed(new_resource)
    end
  end
end
