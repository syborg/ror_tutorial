namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    make_users
    make_microposts
    make_relationships
  end
end

# crea usuaris, els 3 primers son administradors
def make_users
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
end

# crea microposts pels 5 primers usuaris
def make_microposts
  User.find(:all, limit: 10).each do |usr|
    1.upto(10).each do
      mp=usr.microposts.build(:content=>Faker::Lorem.sentences(2).join(" "))
      mp.save!
    end
  end
end

# crea relationships aleatoris pels 10 primers usuaris
def make_relationships
  allusers = User.all
  users = allusers[0..9]
  users.each do |user|
    following = allusers.sort_by {rand(allusers.size)}[0..rand(20)]
    followers = allusers.sort_by {rand(allusers.size)}[0..rand(20)]
    following.each { |followed| user.follow!(followed) unless (user==followed || user.following?(followed))}
    followers.each { |follower| follower.follow!(user) unless (follower==user || follower.following?(user))}
  end
  # Versio original del tutorial
  #user  = users.first
  #following = users[1..50]
  #followers = users[3..40]
  #following.each { |followed| user.follow!(followed) }
end