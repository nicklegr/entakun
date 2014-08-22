Dir.chdir('../')

def test?
  false
end

def development?
  true
end

require './db'

Project.all.each do |project|
  project.staffs.each do |staff|
    task_id = staff.read_attribute(:task_id)

    if task_id && !staff.has_attribute?(:task_ids)
      # staff.write_attributes(:task_ids, [ task_id ])
      staff.task_ids = [ task_id ]
      staff.remove_attribute(:task_id)
      staff.save!
    end
  end
end
