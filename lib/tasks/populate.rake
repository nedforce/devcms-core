require 'faker'

namespace :db do
  namespace :populate do

    desc 'Create synonym data. The thesaurus should be delimited with semi-collons and linebreaks'
    task :synonyms => :environment do
      thesaurus = File.join(RAILS_ROOT, 'thesaurus', 'basis-nl.txt')
      f = File.open(thesaurus)
      begin
        while l = f.readline
          words = l.split(';')
          original = words.shift
          words.each do |w|
            Synonym.create(:original => original.strip, :name => w.strip, :weight => 0.25)
          end
        end
      rescue EOFError
        f.close
      end
    end


    desc 'Create initial users:
            one with admin permissions on the root node (login: \'webmaster\', password: \'admin\')
            one with editor permissions on the business section node (login: \'redacteur\', password: \'editor\')
            one with final_editor permissions on the business section node and the inhabitants section node (login: \'eindredacteur\', password: \'final_editor\')'
    task(:privileged_users => :environment) do
      if Node.root
        u = User.create!(:login => 'webmaster', :email_address => "webmaster@example.com", :password => 'admin', :password_confirmation => 'admin')
        u.update_attribute(:verified, true)
        u.give_role_on('admin', Node.root)
        u = User.create!(:login => 'redacteur', :email_address => "redacteur@example.com", :password => 'editor', :password_confirmation => 'editor')
        u.update_attribute(:verified, true)
        u.give_role_on('editor', Node.root)
        u = User.create!(:login => 'eindredacteur', :email_address => "eindredacteur@example.com", :password => 'final_editor', :password_confirmation => 'final_editor')
        u.update_attribute(:verified, true)
        u.give_role_on('final_editor', Node.root)
      else
        raise 'Root node missing. A root node is required for this task.'
      end
    end

    desc 'Create users for all indexers'
    task(:indexer_users => :environment) do
      if Node.root
        u = User.create!(:login => 'luminis', :email_address => "luminis@example.com", :password => 'asdY23jhnASD8sd', :password_confirmation => 'asdY23jhnASD8sd')
        u.update_attribute(:verified, true)
        u.give_role_on('indexer', Node.root)
      else
        raise 'Root node missing. A root node is required for this task.'
      end
    end

    desc 'Create approximately 1000 User instances with random data'
    task(:users => :environment) do
      ActiveRecord::Base.transaction do
        1000.times do
          login = Faker::Name.name
          email = Faker::Internet.email

          login = login.gsub(/\s+/, '_')
          names = login.split('_', 2)

          User.create(
            :login => login,
            :first_name => names[0],
            :surname => names[1],
            :email_address => email,
            :password => login,
            :password_confirmation => login,
            :verified => true
          )
        end

      end
    end

    desc 'Create a node structure with semi-random content'
    task(:nodes => :environment) do
      ActiveRecord::Base.transaction do
        root_section = Site.create!(:title => 'Website', :description => Faker::Lorem.sentence)
        root_section.node.update_attributes!(:layout => "default", :layout_variant => 'default', :layout_configuration => {'template_color'=>'default'})

        news_archive = NewsArchive.create!(:parent =>root_section.node, :title => 'Home', :description => Faker::Lorem.sentence)
        news_archive.node.update_attributes!(:url_alias => 'home-nieuws', :show_in_menu => true)

        8.times do
          NewsItem.create!(:parent =>news_archive.node, :title => Faker::Lorem.sentence[0..12], :preamble => Faker::Lorem.paragraph, :body => Faker::Lorem.paragraph, :publication_start_date => rand(50).days.ago)
        end

        inhabitants_section = Section.create!(:parent =>root_section.node, :title => 'Bewoners', :description => Faker::Lorem.sentence)
        inhabitants_section.node.update_attribute(:show_in_menu, true)

        5.times do
          page = Page.create!(:parent =>inhabitants_section.node, :title => Faker::Lorem.sentence[0..12], :preamble => Faker::Lorem.paragraph, :body => Faker::Lorem.paragraph, :expires_on => Settler[:default_expiration_time].days.from_now.to_s)
          page.node.update_attribute(:show_in_menu, true)
        end

        poll = Poll.create!(:parent =>inhabitants_section.node, :title => 'Bewoners poll')
        poll.node.update_attribute(:show_in_menu, true)

        pq = poll.poll_questions.create!(:parent =>poll.node, :question => 'Wat is jouw favoriete wijk?', :active => true)
        pq.poll_options.create(:text => 'Wijk 1')
        pq.poll_options.create(:text => 'Wijk 2')
        pq.poll_options.create(:text => 'Wijk 3')

        pq2 = poll.poll_questions.create!(:parent =>poll.node, :question => 'Wie is jouw favoriete wethouder?')
        pq2.poll_options.create(:text => 'Meneer A')
        pq2.poll_options.create(:text => 'Mevrouw X')
        pq2.poll_options.create(:text => 'Meneer B')

        business_section = Section.create!(:parent =>root_section.node, :title => 'Bedrijven', :description => Faker::Lorem.sentence)
        business_section.node.update_attribute(:show_in_menu, true)

        5.times do
          page = Page.create!(:parent =>business_section.node, :title => Faker::Lorem.sentence[0..12], :preamble => Faker::Lorem.paragraph, :body => Faker::Lorem.paragraph, :expires_on => Settler[:default_expiration_time].days.from_now.to_s)
          page.node.update_attribute(:show_in_menu, true)
        end

        business_districts_section = Section.create!(:parent =>business_section.node, :title => 'Bedrijventerreinen', :description => Faker::Lorem.sentence)
        business_districts_section.node.update_attribute(:show_in_menu, true)

        3.times do
          page = Page.create!(:parent =>business_districts_section.node, :title => Faker::Lorem.sentence[0..12], :preamble => Faker::Lorem.paragraph, :body => Faker::Lorem.paragraph, :expires_on => Settler[:default_expiration_time].days.from_now.to_s)
          page.node.update_attribute(:show_in_menu, true)
        end

        page = Page.create!(:parent =>root_section.node, :title => 'Gemeenteraad', :preamble => Faker::Lorem.paragraph, :body => Faker::Lorem.paragraph, :expires_on => Settler[:default_expiration_time].days.from_now.to_s)
        page.node.update_attribute(:show_in_menu, true)

        page = Page.create!(:parent =>root_section.node, :title => 'Stadhuis', :preamble => Faker::Lorem.paragraph, :body => Faker::Lorem.paragraph, :expires_on => Settler[:default_expiration_time].days.from_now.to_s)
        page.node.update_attribute(:show_in_menu, true)
      end
    end

    desc 'First performs a database reset, then creates 1000 User instances and node structure.'
    task :all do
      if RAILS_ENV == "production" && (!ENV.has_key?("RESET_PRODUCTION") || ENV["RESET_PRODUCTION"] != "true")
        raise "Set RESET_PRODUCTION=true if you really want to do this for the production database."
      end

      #puts 'Resetting database...'
      #Rake::Task["db:reset"].invoke
      puts 'Populating database with users...'
      Rake::Task["db:populate:users"].invoke
      puts 'Populating database with node structure...'
      Rake::Task["db:populate:nodes"].invoke
      puts 'Populating database with user rights...'
      Rake::Task["db:populate:privileged_users"].invoke
      puts 'Finished.'
    end
  end
end

