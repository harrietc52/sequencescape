
module DelayedJobsHelper
  def job_type(job)
    if job.name.match?(/StudyReport/)
      'generate study report'
    elsif job.name.match?(/Submission/)
      'process submission '
    else
      job.name
    end
  end

  def job_status(job)
    if job.locked_by
      'In progress'
    elsif job.failed?
      'Failed'
    elsif job.last_error?
      'error'
    else
      'pending'
    end
  end
end
