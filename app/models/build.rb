class Build < ActiveRecord::Base
  belongs_to :project

  # Delayed::Job interface
  def perform
    # FileUtils.mkdir_p(File.join("builds", project_dir))
    project_dir = project.build_dir
    # FileUtils.mkdir_p(File.join("builds", project_dir))
    build_dir = File.join(project_dir, Time.now.strftime("%Y%m%d%H%M") + "_" + commit)
    command = "git clone #{project.vcs_source} \"#{build_dir}\""
    `#{command}`
    self.stdout = `cd #{build_dir} && rake 2>&1 | tee rake.log`
    Rails.logger.debug("*" * 5000)
    Rails.logger.debug(self.stdout.inspect)
    Rails.logger.debug(self.save!)
    Rails.logger.debug("*" * 5000)
    return false
  end

  def after(job)
    Rails.logger.debug("Job after hook")
    Rails.logger.debug(job.inspect)
  end

  def success(job)
    Rails.logger.debug("Job success hook")
    Rails.logger.debug(job.inspect)
  end

  def error(job, exception)
    Rails.logger.debug("Job error hook")
    Rails.logger.debug(job.inspect)
    Rails.logger.debug(exception.inspect)
  end
end