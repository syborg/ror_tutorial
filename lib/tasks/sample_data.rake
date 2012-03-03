namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    # primer els User
    Rake::Task['db:reset'].invoke
    [["Marcel Massana", "xaxaupua@gmail.com", "collonets"],
    ["Pep Massana", "fitxia@gmail.com", "collonets"],
    ["Example User", "example@railstutorial.org", "foobar"]].each do |arr|
      user=User.create!(:name => arr[0],
                 :email => arr[1],
                 :password => arr[2],
                 :password_confirmation => arr[2])
      # MME fem aixo perque "user.admin = true" no funcionaria perque
      # al model l'atribut admin no es a la llista "attr_accessible" i
      # per tant no es pot incialitzar en massa
      user.toggle!(:admin)
    end
    97.times do |n|
      name  = Faker::Name.name
      email = Faker::Internet.email
      password  = "password"
      User.create!(:name => name,
                   :email => email,
                   :password => password,
                   :password_confirmation => password)
    end
    # despres els Micropost dels 5 primers
    User.find(:all, limit: 5).each do |usr|
      1.upto(10).each do
        mp=usr.microposts.build(:content=>Faker::Lorem.sentences(2).join(" "))
        mp.save!
      end
    end


  end
end