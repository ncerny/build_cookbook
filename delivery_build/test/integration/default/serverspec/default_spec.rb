require 'spec_helper'

context 'on Unix', if: !windows? do
  # Push-Jobs
  describe package('push-jobs-client') do
    it { should be_installed }
  end

  # ChefDK
  describe 'ChefDK' do
    context package('chefdk') do
      it { should be_installed }
    end

    context command('chef -v') do
      its(:stdout) { should match(/Chef Development Kit/) }
      its(:exit_status) { should eq 0 }
    end
  end

  # Git
  describe 'git' do
    context command('git --version') do
      its(:stdout) { should match(/git version 2.7.4/) }
      its(:exit_status) { should eq 0 }
    end
  end

  # delivery-cli
  #
  # Currently we are just building the delivery-cli for:
  # => debian 14.04
  # => rhel >= 6
  #
  # TODO: Build a cli for older versions and remove guard
  describe 'delivery-cli', if: ['14.04', '6'].include?(os[:release]) do
    context package('delivery-cli') do
      it { should be_installed }
    end

    context command('delivery --version') do
      its(:stdout) { should match(/delivery/) }
      its(:exit_status) { should eq 0 }
    end
  end

  # Workspace
  describe 'Workspace Configuration' do
    context user('dbuild') do
      it { should exist }
      it { should have_home_directory '/var/opt/delivery/workspace' }
    end

    context file('/var/opt/delivery/workspace') do
      it { should be_directory }
      it { should be_owned_by 'dbuild' }
    end

    context file('/var/opt/delivery/workspace/.chef') do
      it { should be_directory }
      it { should be_owned_by 'dbuild' }
    end

    %w(
      /var/opt/delivery/workspace/.chef/builder_key
      /var/opt/delivery/workspace/.chef/delivery.pem
      /var/opt/delivery/workspace/.chef/knife.rb
      /var/opt/delivery/workspace/etc/builder_key
      /var/opt/delivery/workspace/etc/delivery.pem
      /var/opt/delivery/workspace/etc/delivery.rb
    ).each do |dbuild_file|
      context file(dbuild_file) do
        it { should be_file }
        it { should be_owned_by 'dbuild' }
      end
    end

    %w(
      /var/opt/delivery/workspace/bin/git_ssh
      /var/opt/delivery/workspace/bin/delivery-cmd
    ).each do |root_file|
      context file(root_file) do
        it { should be_file }
        it { should be_owned_by 'root' }
      end
    end
  end
end

describe 'on Windows', if: windows? do
  # ChefDK
  describe 'ChefDK' do
    context command('chef -v') do
      its(:stdout) { should match(/Chef Development Kit/) }
      its(:exit_status) { should eq 0 }
    end
  end

  # Git
  describe 'git' do
    context command('git --version') do
      its(:stdout) { should match(/git version 2.7.4/) }
      its(:exit_status) { should eq 0 }
    end
  end

  # Workspace
  describe 'Workspace Configuration' do
    %w(
      C:/delivery/ws
      C:/delivery/ws/.chef
      C:/delivery/ws/.chef/builder_key
      C:/delivery/ws/.chef/delivery.pem
      C:/delivery/ws/.chef/knife.rb
      C:/delivery/ws/bin/git_ssh
      C:/delivery/ws/bin/delivery-cmd
      C:/delivery/ws/etc/builder_key
      C:/delivery/ws/etc/delivery.pem
      C:/delivery/ws/etc/delivery.rb
    ).each do |workspace_file|
      # We are using regular Ruby because ServerSpec existent checks are failing on Windows
      describe workspace_file do
        it 'exists' do
          expect(File.exist?(workspace_file)).to be true
        end
      end
    end
  end
end
