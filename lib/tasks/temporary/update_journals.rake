namespace :journals do
  desc "Update closed journals with blocked_to date"
  task set_blocked_to: :environment do
	  journals = Journal.where(:is_open => false)
    puts "Going to update #{journals.count} journals"

    ApplicationRecord.transaction do
      journals.each do |journal|
        journal.set_blocked_to!
        print "."
      end
    end

    puts " All done now!"
  end
end