module Bosh::Workspace::Schemas
  describe Releases do
    let(:release) do
      {
        "name" => "foo",
        "version" => 1,
        "path" => "release",
        "ref" => "cec3ec1",
        "git" => "example.com/git.git"
      }
    end

    subject { Releases.new.validate(releases) }

    %w(name version).each do |field_name|
      context "missing #{field_name}" do
        let(:releases) { [release.delete_if { |k| k == field_name }] }
        it { expect { subject }.to raise_error(/#{field_name}.*missing/i) }
      end
    end

    context "latest version" do
      let(:releases) { release["version"] = "latest"; [release] }
      it { expect { subject }.to_not raise_error }
    end

    context "invalid version" do
      let(:releases) { release["version"] = "+foo"; [release] }
      it { expect { subject }.to raise_error(/version.*should match/i) }
    end

    context "optional ref" do
      let(:releases) { [release.delete_if { |k| k == "ref" }] }
      it { expect { subject }.to_not raise_error }
    end

    context "optional git" do
      let(:releases) { [release.delete_if { |k| k == "git" }] }
      it { expect { subject }.to_not raise_error }
    end

    context "optional git" do
      let(:releases) { [release.delete_if { |k| k == "path" }] }
      it { expect { subject }.to_not raise_error }
    end
  end
end
