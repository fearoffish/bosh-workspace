require "bosh/workspace"
require "git"

module Bosh::Cli::Command
  class DeploymentPatch < Base
    include Bosh::Workspace::ProjectDeploymentHelper

    usage "create deployment patch"
    desc "Extract patch from the current directory and optionally writes to file"
    def create(deployment_patch)
      require_project_deployment
      current_deployment_patch.to_file(deployment_patch)
      say "Wrote patch to #{deployment_patch}"
    end

    usage "apply deployment patch"
    desc "Apply a build patch to the current working directory"
    option "--dry-run", "only show the changes without applying them"
    option "--no-commit", "do not commit applied changes"
    def apply(deployment_patch)
      require_project_deployment
      @patch = Bosh::Workspace::DeploymentPatch.from_file(deployment_patch)
      validate_deployment_patch(@patch, deployment_patch)

      if current_deployment_patch.changes?(@patch)
        if !options[:dry_run]
          @patch.apply(current_deployment_file, templates_dir)
          repo.commit_all changes_message  unless options[:no_commit]
          say "Successfully applied deployment patch:"
        else
          say "Deployment patch:"
        end

        say patch_changes_table
      else
        say "No changes, nothing to do"
      end
    end

    private

    def templates_dir
      File.join(Dir.getwd, 'templates')
    end

    def current_deployment_file
      @current_deployment_file ||= project_deployment.file
    end

    def current_deployment_patch
      @current_deployment_patch ||= begin
        Bosh::Workspace::DeploymentPatch
          .create(current_deployment_file, templates_dir)
      end
    end

    def validate_deployment_patch(patch, file)
      unless patch.valid?
        say("Validation errors:".make_red)
        patch.errors.each { |error| say("- #{error}") }
        err("'#{file}' is not valid".make_red)
      end
    end

    def repo
      @repo ||= Git.open(Dir.getwd)
    end

    def patch_changes
      @patch_changes ||= current_deployment_patch.changes(@patch)
    end

    def changes_message
      "Applied " + patch_changes.map { |k, v| "#{k} #{v}" }.join(', ').to_s
    end

    def patch_changes_table
      table do |t|
        patch_changes.each { |k, v| t << [k.to_s, v] }
      end
    end
  end
end
